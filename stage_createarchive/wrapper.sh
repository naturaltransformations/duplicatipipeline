#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

parse_options "$@" --dockerimage mono \
--dockercommand "./BuildTools/PipeLine/stage_createarchive/create.sh"

pull_docker_image
sync_and_use_zip_cache
run_with_docker
