#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

parse_options "$@"

sync_and_use_build_cache
pull_mono_docker_image
run_with_mono_docker "./BuildTools/PipeLine/build/setup_docker.sh $FORWARD_OPTS;\
./BuildTools/PipeLine/build/build.sh $FORWARD_OPTS"