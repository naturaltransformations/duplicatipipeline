#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="libgtk2.0-cil"
parse_options "$@" --dockerimage mono --dockerpackages "$PACKAGES"

sync_and_use_build_cache
pull_docker_image
run_with_docker "./BuildTools/PipeLine/stage_build/build.sh $FORWARD_OPTS"