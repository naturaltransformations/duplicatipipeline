#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

#PACKAGES="zip rsync coreutils perl mono-complete gpg curl"
"${SCRIPT_DIR}/../shared/start_docker.sh" "$@" \
--dockerimage naturaltransformations/ubuntu_sign \
--gpgpath "/usr/bin/gpg" \
--dockermountkeys \
--dockercommand "/pipeline/stage_sign/job.sh"