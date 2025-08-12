import datetime
import os
import re
import shlex
import sys
import time
from pathlib import Path
from typing import Iterator

import docker
import mkdocs_gen_files
import yaml
from docker.errors import APIError, ContainerError, DockerException, ImageNotFound
from mkdocs.plugins import get_plugin_logger

DIRECT_LOGGING = os.environ.get("DIRECT_LOGGING") == "1"

if DIRECT_LOGGING:
    from loguru import logger
else:
    logger = get_plugin_logger("test_code_blocks")

DOCS_DEV_MODE = os.environ.get("DOCS_DEV_MODE") == "1"
CLIENT = None

if not DOCS_DEV_MODE:
    try:
        CLIENT = docker.from_env()
    except DockerException as e:
        errors: list[Exception] = [e]

        if sys.platform == "win32":
            logger.info("`docker.from_env()` failed. Trying Windows-specific named pipe.")
            socket_urls = ["npipe:////./pipe/docker_engine"]
        else:  # If not windows: default to unix-like behaviour
            logger.info("`docker.from_env()` failed. Trying common Unix sockets.")
            socket_urls = [
                "unix://var/run/docker.sock",
                "unix://var/run/docker/docker.sock",
                "unix://var/run/podman.sock",
                "unix://var/run/podman/podman.sock",
            ]

        for socket in socket_urls:
            try:
                CLIENT = docker.DockerClient(base_url=socket)
                break
            except Exception as e:
                errors.append(e)
        else:
            raise ExceptionGroup("Couldn't find a valid docker socket!", errors)
    except Exception as e:
        logger.error(
            "A critical error occurred while connecting to the Docker daemon. Is Docker installed and running?"
        )
        raise ConnectionError("Could not connect to Docker daemon.") from e

assert CLIENT is not None, "`CLIENT` should not be `None`!"


def run_docker_test(
    page_path,
    docker_image,
    code_blocks,
    shell="bash",
    volumes_config_for_page=None,
    init_commands_for_page=None,
):
    """
    Executes code blocks sequentially in a specified Docker container.
    Handles Docker-in-Docker setup and command interpolation via a wrapper.
    Returns True for success, False for failure, and any captured output.
    `volumes_config_for_page` is expected to be a list of dicts from the page's frontmatter.
    `init_commands_for_page` is a list of commands from the page's frontmatter to run once.
    """
    if not CLIENT:
        return False, "Docker client not initialized. Cannot run tests."

    logger.info(f"Testing {page_path} with image {docker_image} and shell {shell}...")
    container = None
    success = True
    output_log = []

    docker_volumes_dict = {}
    if volumes_config_for_page:
        for vol_item in volumes_config_for_page:
            host_path = Path(vol_item["host_path"]).resolve()
            container_path = vol_item["container_path"]
            mode = vol_item.get("mode", "rw")

            docker_volumes_dict[str(host_path)] = {"bind": container_path, "mode": mode}
    else:
        logger.info(
            f"No 'volumes' specified in frontmatter for {page_path}. Running without custom volumes."
        )

    try:
        output_log.append(f"Ensuring Docker image '{docker_image}' is available...")
        try:
            CLIENT.images.pull(docker_image)
            output_log.append(f"Image '{docker_image}' pulled successfully (or already present).")
        except ImageNotFound:
            output_log.append(f"ERROR: Docker image '{docker_image}' not found.")
            return False, "\n".join(output_log)
        except APIError as e:
            output_log.append(f"ERROR: Docker API error pulling image '{docker_image}': {e}")
            return False, "\n".join(output_log)

        container_name = (
            f"mkdocs-test-{page_path.stem.replace('/', '-')}-{Path(page_path).parent.name}-{shell}"
        )
        output_log.append(f"Starting container: {container_name} with shell {shell}")

        container = CLIENT.containers.run(
            image=docker_image,
            name=container_name,
            detach=True,
            remove=True,
            command=["tail", "-f", "/dev/null"],
            volumes=docker_volumes_dict,
            environment={"SHELL": shell, "EDITOR": "micro"},
            privileged=True,
        )
        output_log.append(f"Container '{container.id}' started.")

        output_log.append("Starting dockerd inside the container...")
        dockerd_startup_cmd = "nohup dockerd > /var/log/dockerd.log 2>&1 &"
        dockerd_check_cmd = "docker info"

        exec_result = container.exec_run(
            cmd=["bash", "-c", dockerd_startup_cmd],
            stream=False,
            demux=True,
            detach=True,
        )
        if exec_result.exit_code != 0:
            output_log.append(
                f"ERROR: Failed to initiate dockerd startup command. Exit code: {exec_result.exit_code}"
            )
            stdout_err = exec_result.output[0].decode("utf-8") if exec_result.output[0] else ""
            stderr_err = exec_result.output[1].decode("utf-8") if exec_result.output[1] else ""
            if stdout_err:
                output_log.append(f"STDOUT: {stdout_err}")
            if stderr_err:
                output_log.append(f"STDERR: {stderr_err}")
            success = False
            return success, "\n".join(output_log)

        if init_commands_for_page:
            output_log.append("\n--- Executing Initialization Commands ---")
            for i, init_cmd_str in enumerate(init_commands_for_page):
                output_log.append(f"  Init command {i + 1}: `{init_cmd_str}`")
                try:
                    init_result = container.exec_run(
                        cmd=["bash", "-c", init_cmd_str],
                        stream=False,
                        demux=True,
                    )
                    stdout = init_result.output[0].decode("utf-8") if init_result.output[0] else ""
                    stderr = init_result.output[1].decode("utf-8") if init_result.output[1] else ""

                    if stdout:
                        output_log.append("  STDOUT:\n" + stdout)
                    if stderr:
                        output_log.append("  STDERR:\n" + stderr)

                    if init_result.exit_code != 0:
                        success = False
                        output_log.append(
                            f"ERROR: Init command failed with exit code {init_result.exit_code}"
                        )
                        break
                except Exception as e:
                    success = False
                    output_log.append(
                        f"ERROR: An error occurred during init command execution: {e}"
                    )
                    break

        max_wait_time = 90
        poll_interval = 1
        output_log.append(f"Polling for dockerd readiness (max {max_wait_time}s)...")

        for _ in range(int(max_wait_time / poll_interval)):
            try:
                check_result = container.exec_run(
                    cmd=["bash", "-c", dockerd_check_cmd], stream=False, demux=True
                )
                if check_result.exit_code == 0:
                    output_log.append("dockerd is up and running.")
                    break
            except Exception as e:
                output_log.append(f"Warning during dockerd check: {e}")
            time.sleep(poll_interval)
        else:
            output_log.append(
                f"ERROR: Timed out waiting for dockerd to start after {max_wait_time} seconds. Check container logs for dockerd output."
            )
            success = False
            try:
                dockerd_logs = container.exec_run(
                    cmd="cat /var/log/dockerd.log", stream=False, demux=True
                )
                if dockerd_logs.exit_code == 0:
                    output_log.append(
                        "\n--- /var/log/dockerd.log ---\n" + dockerd_logs.output[0].decode("utf-8")
                    )
                else:
                    output_log.append(
                        f"Could not retrieve dockerd logs: {dockerd_logs.output[1].decode('utf-8')}"
                    )
            except Exception as log_e:
                output_log.append(f"Failed to retrieve dockerd logs: {log_e}")

            return success, "\n".join(output_log)

        for i, (lang, code_block_content, command_wrapper) in enumerate(code_blocks):
            output_log.append(f"\n--- Executing Block {i + 1} ({lang}) with {shell} ---")

            commands_to_execute = []
            if lang in ["sh", "bash", "fish", "zsh", "nu"]:
                individual_lines = code_block_content.strip().split("\n")

                for line in individual_lines:
                    line = line.strip()
                    if not line:
                        continue
                    if command_wrapper:
                        commands_to_execute.append(
                            command_wrapper.replace("{command}", line).replace("{shell}", shell)
                        )
                    else:
                        commands_to_execute.append(line)
            elif lang == "python":
                commands_to_execute.append(f"python -c '{code_block_content}'")
            elif lang == "elixir":
                commands_to_execute.append(f"elixir -e '{code_block_content}'")
            else:
                if command_wrapper:
                    commands_to_execute.append(
                        command_wrapper.replace("{command}", code_block_content)
                    )
                else:
                    commands_to_execute.append(code_block_content)

            for j, command_str in enumerate(commands_to_execute):
                output_log.append(f"  Executing command {j + 1}: `{command_str}`")

                cmd_to_pass_to_exec_run = []
                if command_wrapper or lang not in ["sh", "bash", "fish", "zsh", "nu"]:
                    cmd_to_pass_to_exec_run = shlex.split(command_str)
                else:
                    cmd_to_pass_to_exec_run = [shell, "-c", command_str]

                try:
                    result = container.exec_run(
                        cmd=cmd_to_pass_to_exec_run,
                        stream=False,
                        demux=True,
                    )
                    stdout = result.output[0].decode("utf-8") if result.output[0] else ""
                    stderr = result.output[1].decode("utf-8") if result.output[1] else ""
                    exit_code = result.exit_code

                    if stdout:
                        output_log.append("  STDOUT:\n" + stdout)
                    if stderr:
                        output_log.append("  STDERR:\n" + stderr)

                    if exit_code != 0:
                        success = False
                        output_log.append(f"  ERROR: Command failed with exit code {exit_code}")
                        break

                except ContainerError as e:
                    success = False
                    output_log.append(f"  ERROR: Container execution failed: {e}")
                    err = "No error on stderr..." if e.stderr is None else e.stderr
                    details = err.decode("utf-8") if isinstance(err, bytes) else err
                    output_log.append(f"  Details: {details}")
                    break
                except APIError as e:
                    success = False
                    output_log.append(f"  ERROR: Docker API error during exec: {e}")
                    break
                except Exception as e:
                    success = False
                    output_log.append(
                        f"  ERROR: An unexpected error occurred during execution: {e}"
                    )
                    break
            if not success:
                break
    except ImageNotFound:
        success = False
        output_log.append(f"ERROR: Docker image '{docker_image}' not found for testing.")
    except APIError as e:
        success = False
        output_log.append(f"ERROR: Docker API error: {e}")
    except Exception as e:
        success = False
        output_log.append(f"An unexpected error occurred during test setup: {e}")
    finally:
        if container:
            output_log.append(
                f"\nStopping and removing container: {container.name} ({container.id})"
            )
            try:
                container.stop(timeout=10)
            except APIError as e:
                output_log.append(
                    f"WARNING: Could not stop/remove container '{container.name}': {e}"
                )
            except Exception as e:
                output_log.append(f"WARNING: An error occurred during container cleanup: {e}")

    return success, "\n".join(output_log)


def filter_targets(x: Iterator[Path]) -> Iterator[Path]:
    if len(sys.argv) < 2:
        return x
    else:
        targets = [Path(p) for p in sys.argv[1:]]

        def filter_condition(ix: Path) -> bool:
            return ix.relative_to("./docs") in targets

        return filter(filter_condition, x)


def main():
    docs_dir = Path("docs")
    shells = ("bash", "fish", "zsh", "nu")
    current_time = datetime.datetime.now(datetime.timezone.utc)

    all_test_results = []
    overall_success = True

    for path in sorted(filter_targets(docs_dir.rglob("*.md"))):
        logger.info(f"Running tests for {path}")
        with path.open("r", encoding="utf-8") as f:
            content = f.read()

        code_block_regex = re.compile(
            r"```(?P<lang>\w+)\s*\{?\s*\.test-block\s*(?:#(?P<docker_id>\S+))?\s*(?:wrapper=\"(?P<wrapper>.*?)\")?\s*\}?\n(?P<code>.*?)\n```",
            re.DOTALL,
        )

        # MODIFIED: From a single list to a dictionary to group tests by image
        tests_by_image = {}

        # --- Get page-level configuration ---
        default_docker_image = None
        volumes_for_page = None
        init_commands_for_page = None

        front_matter_match = re.match(r"---(?P<frontmatter>.*?)\n---", content, re.DOTALL)
        if front_matter_match:
            try:
                fm = yaml.safe_load(front_matter_match.group("frontmatter"))
                # This is now a fallback image if a block doesn't specify its own
                default_docker_image = fm.get("docker_image")
                volumes_for_page = fm.get("volumes")
                init_commands_for_page = fm.get("init_commands")
            except yaml.YAMLError as e:
                logger.warning(f"Could not parse frontmatter in {path}: {e}")

        for match in code_block_regex.finditer(content):
            block_docker_id = match.group("docker_id")
            image_for_block = block_docker_id or default_docker_image

            if not image_for_block:
                logger.warning(
                    f"Skipping a test block in {path.name} because it has no image ID (#image) "
                    f"and no default 'docker_image' is set in the frontmatter."
                )
                continue

            lang = match.group("lang")
            code = match.group("code")
            command_wrapper = match.group("wrapper")

            tests_by_image.setdefault(image_for_block, []).append((lang, code, command_wrapper))

        if tests_by_image:
            for docker_image, code_blocks in tests_by_image.items():
                n_blocks = len(code_blocks)
                if n_blocks < 1:
                    logger.info(f"No code blocks found. Skipping tests for {path.name}")
                    continue
                logger.info(f"Found {n_blocks} blocks for image '{docker_image}' in {path.name}")

                for shell in shells:
                    current_test_status = {}
                    current_test_status["page"] = str(path)
                    current_test_status["shell"] = shell
                    current_test_status["docker_image"] = docker_image

                    success, log = run_docker_test(
                        page_path=path,
                        docker_image=docker_image,
                        code_blocks=code_blocks,
                        shell=shell,
                        volumes_config_for_page=volumes_for_page,
                        init_commands_for_page=init_commands_for_page,
                    )

                    current_test_status["success"] = success
                    current_test_status["log"] = log
                    all_test_results.append(current_test_status)

                    if not success:
                        overall_success = False
                        logger.error(
                            f"Tests failed for '{docker_image}' in {path.name} with {shell}. See final output file."
                        )
                        break

                if not overall_success:
                    pass

    output_md_path = Path("test_results.md")

    with mkdocs_gen_files.open(output_md_path, "w") as f:
        f.write("# Comprehensive Code Block Test Results\n\n")
        f.write(f"Generated on {current_time.strftime('%Y-%m-%d %H:%M:%S %Z')}\n\n")

        if overall_success:
            f.write("## ✅ All Tests Passed Across All Pages and Shells!\n\n")
        else:
            f.write("## ❌ Some Tests Failed. Please review the logs below.\n\n")

        for result in all_test_results:
            f.write("---\n")
            f.write(f"### Results for Page: `{result['page']}`\n")
            f.write(f"**Docker Image:** `{result['docker_image']}`\n")
            f.write(f"**Shell:** `{result['shell']}`\n")

            if result["success"]:
                f.write("Status: ✅ Passed\n\n")
            else:
                f.write("Status: ❌ Failed\n\n")
            f.write("```text\n")
            f.write(result["log"])
            f.write("\n```\n")

    if not overall_success:
        raise RuntimeError("Some tests failed.")


if __name__ == "__main__":
    if DOCS_DEV_MODE:
        logger.warning("Dev mode: skipping code block tests!")
    else:
        main()
