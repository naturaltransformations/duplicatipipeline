#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

#PACKAGES="python-pip rsync"
#--dockerimage mono \
PACKAGES="python-pip rsync mono-complete"
"${SCRIPT_DIR}/../shared/start_docker.sh" "$@" \
--dockerimage selenium/standalone-firefox \
--dockerpackages "$PACKAGES" \
--dockerasroot \
--dockersharedmem \
--dockercommand "sudo -u seluser /pipeline/stage_integrationtests/job.sh"