#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="rsync"
"${SCRIPT_DIR}/../shared/start_docker.sh" "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--dockercommand "/pipeline/stage_createarchive/job.sh"