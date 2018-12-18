#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="rsync"
run "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--sourcecache "$BUILD_CACHE" \
--targetcache "$ZIP_CACHE" \
--dockercommand "./BuildTools/PipeLine/stage_createarchive/create.sh"