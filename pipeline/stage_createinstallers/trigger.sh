#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

"${SCRIPT_DIR}/../shared/start_docker.sh" "$@" \
--dockerimage ubuntu \
--dockerpackages "qemu-user qemu-user-static unzip rsync bzip2 docker.io" \
--dockercommand "/pipeline/stage_createinstallers/job.sh"