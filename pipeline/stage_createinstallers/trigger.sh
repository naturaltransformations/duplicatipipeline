#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="qemu-user qemu-user-static unzip rsync bzip2"
"${SCRIPT_DIR}/../shared/start_docker.sh" "$@" \
--dockerimage teracy/ubuntu:16.04-dind-latest \
--dockerpackages "$PACKAGES" \
--dockercommand "/pipeline/stage_createinstallers/job.sh"