#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="zip rsync coreutils perl mono-complete gpg"
"${SCRIPT_DIR}/../shared/start_docker.sh" "$@" \
--dockerimage ubuntu \
--dockerpackages "$PACKAGES" \
--gpgpath "/usr/bin/gpg" \
--dockermountkeys \
--dockercommand "/pipeline/stage_sign/job.sh"