#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

parse_options "$@" --dockerimage mono
pull_docker_image
sync_and_use_zip_cache
#https://itnext.io/docker-in-docker-521958d34efd

run_with_docker "\
./BuildTools/PipeLine/create_zip/setup_docker.sh;\
./BuildTools/PipeLine/create_zip/create.sh $FORWARD_OPTS"
