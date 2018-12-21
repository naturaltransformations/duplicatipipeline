#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

function sync_cache () {
  travis_mark_begin "SYNCING CACHE"
  rsync -a --delete "/source_1/" "/duplicati/"
  for (( i=2; i<${#SOURCE_CACHE[@]}+1; i++ )); do
    echo "syncing ${SOURCE_CACHE[$i-1]} to ${TARGET_CACHE}"
    rsync -a "/source_${i}/" "/duplicati/"
  done
  travis_mark_end "SYNCING CACHE"
}

shift
parse_options "$@"

/source_1/BuildTools/PipeLine/shared/setup_docker.sh --dockerpackages "$DOCKER_PACKAGES"
sync_cache
cd /duplicati
$DOCKER_COMMAND "$@"