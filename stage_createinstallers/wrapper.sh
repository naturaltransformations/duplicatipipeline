#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="qemu-user qemu-user-static unzip"
parse_options "$@" \
--dockerimage teracy/ubuntu:16.04-dind-latest \
--gittag $(git rev-parse --short HEAD) \
--dockerpackages "$PACKAGES" \
--dockercommand "./BuildTools/PipeLine/stage_createinstallers/create.sh"

pull_docker_image
sync_and_use_installer_cache
run_with_docker