#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="zip rsync awscli coreutils"
run "$@" \
--dockerimage debian:jessie-slim \
--dockerpackages "$PACKAGES" \
--sourcecache "$INSTALLER_CACHE" \
--targetcache "$DEPLOY_CACHE" \
--dockercommand "./BuildTools/PipeLine/stage_deploy/deploy.sh"