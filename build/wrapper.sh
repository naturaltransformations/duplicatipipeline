#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

parse_options "$@" --dockerimage mono

sync_and_use_build_cache
pull_docker_image
run_with_docker "\
./BuildTools/PipeLine/build/setup_docker.sh $FORWARD_OPTS;\
./BuildTools/PipeLine/build/build.sh $FORWARD_OPTS"