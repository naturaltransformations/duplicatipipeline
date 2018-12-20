#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="zip rsync awscli coreutils perl"
run "$@" \
--dockerimage teracy/ubuntu:16.04-dind-latest \
--dockerpackages "$PACKAGES" \
--dockercommand "./BuildTools/PipeLine/stage_deploy/deploy.sh"