#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

parse_options "$@"
pull_mono_docker_image
sync_and_use_zip_cache
#https://itnext.io/docker-in-docker-521958d34efd

run_with_mono_docker "./BuildTools/PipeLine/create_zip/install.sh;\
./BuildTools/PipeLine/create_zip/create.sh $FORWARD_OPTS"
