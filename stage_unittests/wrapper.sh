#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

# rename to config.sh
PACKAGES="wget unzip rsync"
run "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--sourcecache "$BUILD_CACHE" \
--targetcache "$TEST_CACHE" \
--dockercommand "./BuildTools/PipeLine/stage_unittests/test.sh"