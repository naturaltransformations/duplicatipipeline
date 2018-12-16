#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="rsync"
parse_options "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--sourcecache "$BUILD_CACHE" \
--targetcache "$ZIP_CACHE" \
--dockercommand "./BuildTools/PipeLine/stage_createarchive/create.sh"

pull_docker_image
run_with_docker
