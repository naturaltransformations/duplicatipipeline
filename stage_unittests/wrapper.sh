#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="wget unzip"
parse_options "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--dockercommand "./BuildTools/PipeLine/stage_unittests/test.sh"

sync_and_use_test_cache
pull_docker_image
run_with_docker