#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

function sync_cache () {
  travis_mark_begin "SYNCING CACHE"
  rsync -a --delete "/.cache"/ "/duplicati/"
  travis_mark_end "SYNCING CACHE"
}

shift
parse_options "$@"

/.cache/BuildTools/PipeLine/shared/setup_docker.sh --dockerpackages "$DOCKER_PACKAGES"
sync_cache
cd /duplicati
$DOCKER_COMMAND "$@"