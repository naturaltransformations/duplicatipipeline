#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="zip rsync awscli coreutils perl"
"${SCRIPT_DIR}/../shared/utils.sh" "$@" \
--dockerimage teracy/ubuntu:16.04-dind-latest \
--dockerpackages "$PACKAGES" \
--dockercommand "/pipeline/stage_deploy/deploy.sh"