#!/bin/bash
. "$( cd "$(dirname "$0")" ; pwd -P )/error_handling.sh"
. "$( cd "$(dirname "$0")" ; pwd -P )/markers.sh"

function sync_cache () {
  travis_mark_begin "SYNCING CACHES"
  rsync -a --delete "/source_1/" "/duplicati/"
  for (( i=2; i<$NUM_SOURCE_CACHES+1; i++ )); do
    rsync -a "/source_${i}/" "/duplicati/"
  done
  travis_mark_end "SYNCING CACHES"
}

function setup () {
   if [ -f /sbin/apk ]; then
      apk --update add $DOCKER_PACKAGES
      return
   fi

   if [ -f /usr/bin/apt-get ]; then
      apt-get update && apt-get install -y $DOCKER_PACKAGES
      return
   fi
}

function parse_options () {
  while true ; do
      case "$1" in
      --dockercommand)
          DOCKER_COMMAND="$2"
          ;;
      --dockerpackages)
          DOCKER_PACKAGES="$2"
          ;;
      "" )
        break
        ;;
      esac
      FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
      FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
      shift
      shift
  done
}

parse_options "$@"

setup
sync_cache
cd /duplicati
$DOCKER_COMMAND "${FORWARD_OPTS[@]}"