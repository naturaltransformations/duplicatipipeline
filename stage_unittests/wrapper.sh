#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

# rename to config.sh
PACKAGES="wget unzip rsync"
parse_options "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--sourcecache "$BUILD_CACHE" \
--targetcache "$TEST_CACHE" \
--dockercommand "./BuildTools/PipeLine/stage_unittests/test.sh"

pull_docker_image
run_with_docker