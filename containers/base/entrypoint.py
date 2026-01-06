#!/usr/bin/env python3.12

import asyncio
import os
from pathlib import Path
import shutil
import subprocess


SPLASH = """\033[35m
     .o88b. .d8888.  .o88b.  db  db  .d88b.  .d888b.
    d8P  Y8 88'  YP d8P  Y8 o88 o88 .8P  88. 88' `8D
    8P      `8bo.   8P       88  88 88  d'88 `V8o88'
    8b        `Y8b. 8b       88  88 88 d' 88    d8'
    Y8b  d8 db   8D Y8b  d8  88  88 `88  d8'   d8'
     `Y88P' `8888Y'  `Y88P'  VP  VP  `Y88P'   d8'\033[0m"""


def display_markdown(files: list[str]):
    filepaths = (p for p in (Path(f).expanduser() for f in files) if p.exists())
    with subprocess.Popen(["glow"], stdin=subprocess.PIPE) as glow_proc:
        assert glow_proc.stdin is not None
        for fpath in filepaths:
            with fpath.open("rb") as f:
                glow_proc.stdin.write(f.read())
        glow_proc.stdin.close()
        glow_proc.wait()


async def start_daemon(
    command: str,
    check_command: str,
    log_file: str = "/dev/null",
    poll_interval: int = 1,
    timeout: int = 60,
) -> None:
    with open(log_file, "wb") as log:
        process = await asyncio.create_subprocess_shell(command, stdout=log, stderr=log)

    async def poll_daemon():
        while True:
            check_process = await asyncio.create_subprocess_shell(
                check_command,
                stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.DEVNULL,
            )
            await check_process.wait()

            if check_process.returncode == 0:
                break

            if process.returncode is not None:
                msg = f"Daemon '{command}' exited unexpectedly with code {process.returncode}."
                msg = f"{msg} Check logs at {log_file}."
                raise RuntimeError(msg)

            print(f"Waiting for {command}...")
            await asyncio.sleep(poll_interval)

    try:
        await asyncio.wait_for(poll_daemon(), timeout=timeout)
    except asyncio.TimeoutError as e:
        print(f"❌ Timed out after {timeout} seconds waiting for {command}.")
        if process.returncode is None:
            process.terminate()
            await process.wait()
        raise e


class Selector:
    def __init__(self, name: str, prompt: str, items: list[tuple[str, str, str]]):
        self.name = name
        self.prompt = prompt
        self.options = tuple(i[0] for i in items)
        self.icons = {i[0]: i[1] for i in items}
        self.commands = {i[0]: i[2] for i in items}

    async def select(self):
        # Enforce sanity checks to prevent configuration problems
        assert hasattr(self, "options")
        assert hasattr(self, "icons")
        assert hasattr(self, "commands")
        for i in self.options:
            assert i in self.icons
            assert i in self.commands

        while True:
            print(self.prompt)
            for i, opt in enumerate(self.options):
                print(f"{i}) {opt} {self.icons[opt]}")
            choice = input("Enter a choice [default=0]: ")
            try:
                choice = choice if choice else 0
                choice = choice if choice in self.options else self.options[int(choice)]
                break
            except ValueError:
                print()
                print(f"{choice} is not a valid choice! Please try again.")
            except IndexError:
                print()
                print(f"Option {choice} does not exist! Please try again.")
            print()
        self.choice = choice

    def print_choice(self, indent: int = 0):
        print(f"{' ' * indent * 4}{self.name}: {self.choice} {self.icons[self.choice]}")

    def start(self):
        raise NotImplementedError("The method `start` has not been implemented for this selector.")


class EnvSelector(Selector):
    def __init__(self, name: str, prompt: str, items: list[tuple[str, str, str]], env_var: str):
        super().__init__(name, prompt, items)
        self.env_var = env_var

    async def select(self):
        if self.env_var in os.environ and os.environ[self.env_var]:
            existing = os.environ[self.env_var]
            if existing in self.commands.values():
                self.choice = next(opt for opt, cmd in self.commands.items() if cmd == existing)
                print(
                    f'{self.name} is already set to "{self.choice}" ({
                        existing
                    }), skipping selection.'
                )
                return
        await super().select()

    def start(self):
        os.environ[self.env_var] = self.commands[self.choice]


class ShellSelector(Selector):
    def __init__(
        self,
        name: str,
        prompt: str,
        items: list[tuple[str, str, str]],
        selectors: list[Selector] | None = None,
    ):
        super().__init__(name, prompt, items)
        self.selectors = selectors if selectors is not None else []

    async def select(self):
        print()
        if "SHELL" in os.environ and os.environ["SHELL"]:
            existing_shell = os.environ["SHELL"]
            if existing_shell in self.commands.values():
                self.choice = next(
                    opt for opt, cmd in self.commands.items() if cmd == existing_shell
                )
                print(
                    f'{self.name} is already set to "{self.choice}" ({
                        existing_shell
                    }), skipping selection.'
                )
            else:
                await super().select()
        else:
            await super().select()
        print()

        for s in self.selectors:
            await s.select()
            print()

    def print_choice(self, indent: int = 0):
        super().print_choice(indent=indent)
        for s in self.selectors:
            s.print_choice(indent=indent)

    def start(self):
        assert hasattr(self, "choice")
        os.environ["SHELL"] = self.commands[self.choice]
        print("Launching shell with:")
        self.print_choice(indent=1)
        print()
        for s in self.selectors:
            s.start()
        try:
            os.execvp(self.commands[self.choice], [self.commands[self.choice]])
        except FileNotFoundError as e:
            msg = (f"Error: The shell '{self.choice}' could not be found on your system.",)
            raise EnvironmentError(msg) from e


async def main():
    daemon_startup = None
    # has_docker = shutil.which("docker") is not None
    # daemon_startup = (
    #     asyncio.create_task(start_daemon("dockerd", "docker info", "/var/log/dockerd.log"))
    #     if has_docker
    #     else None
    # )

    selector = ShellSelector(
        "Shell",
        "\x1b[32m\033[0m Please choose your preferred shell environment:",
        [
            ("fish", "\x1b[31m󰈺\033[0m", "fish"),
            ("bash", "", "brush-hl"),
            ("zshell", "", "zsh"),
            ("nushell", "\x1b[32m❯\033[0m", "nu"),
        ],
        [
            EnvSelector(
                "Editor",
                "\033[90m\033[0m Please select your default text editor:",
                [
                    ("micro", "\x1b[38;5;97mμ\033[0m", "micro"),
                    ("vim", "\x1b[38;5;2m\033[0m", "vim"),
                    ("neovim", "\x1b[38;5;12m\033[0m", "nvim"),
                    ("emacs", "\x1b[38;5;5m\033[0m", "emacs"),
                ],
                "EDITOR",
            )
        ],
    )

    try:
        await selector.select()
        print(SPLASH)
        display_markdown(["~/CSC1109.md", "/lab/lab.md"])
        if daemon_startup is not None:
            await daemon_startup
        selector.start()

    except (RuntimeError, asyncio.TimeoutError, EnvironmentError) as e:
        if daemon_startup and not daemon_startup.done():
            daemon_startup.cancel()
        raise e
    except asyncio.CancelledError as e:
        raise e


if __name__ == "__main__":
    asyncio.run(main())
