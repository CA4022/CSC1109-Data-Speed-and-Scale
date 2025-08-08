# Variables loaded from the environment for build arguments
BASE_NAME := env("BASE_NAME")
CONTAINER_CMD := env("CONTAINER_ENV")

BASE_OPENSUSE_VERSION := env("BASE_OPENSUSE_VERSION")
BASE_DOCKER_VERSION := env("BASE_DOCKER_VERSION")
BASE_COMPOSE_VERSION := env("BASE_COMPOSE_VERSION")
BASE_BASH_VERSION := env("BASE_BASH_VERSION")
BASE_GIT_VERSION := env("BASE_GIT_VERSION")
BASE_GCC_VERSION := env("BASE_GCC_VERSION")

# Lists available just commands
default:
    @just --list

# Get the image name from a target directory
get_image_name target_dir='.':
    #!/usr/bin/env bash
    # Generate container name from the target directory path.
    # Note: Can't speak for how reliable this will be. Nobody in their right mind willingly writes
    #   sed/awk code by hand. As dubious as the practice can be: this line is 90% vibe coded.
    PATH_COMPONENT=$(echo "{{target_dir}}" | sed -e 's|^\(./\)\?containers/||' | tr '/' '\n' | sed -e 's/^\.//' -e 's/\.$//' | awk 'NF' | paste -sd-)
    echo "$BASE_NAME-$PATH_COMPONENT"

# Get the version string from a target directory
get_version target_dir='.':
    #!/usr/bin/env bash
    VERSION_FILE="{{target_dir}}/VERSION"
    if [ ! -f "$VERSION_FILE" ]; then
        echo "Error: '{{target_dir}}/VERSION' not found." >&2
        exit 1
    fi
    cat {{target_dir}}/VERSION

# Get the tag for a given directory.
get_tag target_dir='.':
    #!/usr/bin/env bash
    echo "$(just get_image_name {{target_dir}}):$(just get_version {{target_dir}})"


# Get the latest tag for a given directory.
get_latest_tag target_dir='.':
    #!/usr/bin/env bash
    echo "$(just get_image_name {{target_dir}}):latest"

update_project_version:
    @uv run ./utils/version.py

# Bump the CalVer version in a target directory's VERSION file
bump_version target_dir='.':
    #!/usr/bin/env bash
    set -euo pipefail
    VERSION_FILE="{{target_dir}}/VERSION"

    if [ ! -f "$VERSION_FILE" ]; then
        echo "Error: '$VERSION_FILE' not found. Cannot bump version." >&2
        exit 1
    fi

    current_version=$(cat "$VERSION_FILE")
    today_date=$(date +"%Y.%m.%d")
    new_version=""

    if [[ "${current_version:0:10}" == "$today_date" ]]; then
        echo "CalVer: Same day, incrementing revision."
        if [[ "$current_version" == "$today_date" ]]; then
            new_version="${today_date}.1"
        else
            revision_num=${current_version##*.}
            new_revision=$((revision_num + 1))
            new_version="${today_date}.${new_revision}"
        fi
    else
        echo "CalVer: New day, resetting version."
        new_version="$today_date"
    fi

    echo "Setting new version to: $new_version"
    echo "$new_version" > "$VERSION_FILE"
    just --justfile {{justfile()}} update_project_version

bump_all_versions:
    #!/usr/bin/env bash
    fd --full-path -H0 -t f VERSION | while IFS= read -r -d '' target_dir; do
        just --justfile {{justfile()}} bump_version "$(dirname $target_dir)"
    done

# Build a container image from a target directory
build target_dir='.':
    #!/usr/bin/env bash
    set -euo pipefail
    TAG=$(just --justfile {{justfile()}} get_tag '{{target_dir}}')
    echo "Building image with tag: ${TAG}"

    {{ CONTAINER_CMD }} build \
        --build-arg BASE_OPENSUSE_VERSION="{{BASE_OPENSUSE_VERSION}}" \
        --build-arg BASE_DOCKER_VERSION="{{BASE_DOCKER_VERSION}}" \
        --build-arg BASE_COMPOSE_VERSION="{{BASE_COMPOSE_VERSION}}" \
        --build-arg BASE_BASH_VERSION="{{BASE_BASH_VERSION}}" \
        --build-arg BASE_GIT_VERSION="{{BASE_GIT_VERSION}}" \
        --build-arg BASE_GCC_VERSION="{{BASE_GCC_VERSION}}" \
        -t "${TAG}" \
        {{target_dir}}

# Run a container from a target directory's build
run target_dir +args:
    #!/usr/bin/env bash
    set -euo pipefail
    TAG=$(just --justfile {{justfile()}} get_tag '{{target_dir}}')
    echo "Running image: ${TAG} with extra args '{{args}}'"
    {{ CONTAINER_CMD }} run --privileged {{args}} --hostname "${TAG}" --rm -it "${TAG}"

# Test a container from a target directory's build
test target_dir='.' log_file='/tmp/build_test_log.txt':
    #!/usr/bin/env bash
    set -euo pipefail
    TAG=$(just --justfile {{justfile()}} get_tag '{{target_dir}}')
    echo "Testing image: ${TAG}"
    {{ CONTAINER_CMD }} run --privileged --entrypoint="" --rm "${TAG}" /test/test.sh {{log_file}}

# Build and then run the container
build_and_run target_dir +run_args:
    @just --justfile {{justfile()}} build '{{target_dir}}'
    @just --justfile {{justfile()}} run '{{target_dir}}' {{run_args}}

# Build and then test the container
build_and_test target_dir='.' log_file='/tmp/build_test_log.txt':
    @just --justfile {{justfile()}} build '{{target_dir}}'
    @just --justfile {{justfile()}} test '{{target_dir}}' '{{log_file}}'

publish repo_url target_dir='.':
    #!/usr/bin/env bash
    set -e
    echo "Tagging and pushing image to {{repo_url}}..."

    VERSION_TAG_LOCAL=$(just get_tag {{ target_dir }})
    LATEST_TAG_LOCAL=$(just get_latest_tag {{ target_dir }})
    VERSION_TAG_REMOTE="{{repo_url}}/$VERSION_TAG_LOCAL"
    LATEST_TAG_REMOTE="{{repo_url}}/$LATEST_TAG_LOCAL"

    {{ CONTAINER_CMD }} tag $VERSION_TAG_LOCAL $VERSION_TAG_REMOTE
    {{ CONTAINER_CMD }} tag $VERSION_TAG_REMOTE $LATEST_TAG_REMOTE
    {{ CONTAINER_CMD }} push $VERSION_TAG_REMOTE
    {{ CONTAINER_CMD }} push $LATEST_TAG_REMOTE
    echo "Image pushed successfully."

test_docs:
    sudo uv run ./utils/test_code_blocks.py
