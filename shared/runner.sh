#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

function sync_and_use_cache () {
  rsync -a --delete "/.cache"/ "/duplicati/"
}

parse_options "$@"
echo "docker runner received options $FORWARD_OPTS"

/.cache/BuildTools/PipeLine/shared/setup_docker.sh --dockerpackages "$DOCKER_PACKAGES"
sync_and_use_cache
cd /duplicati
$DOCKER_COMMAND $FORWARD_OPTS