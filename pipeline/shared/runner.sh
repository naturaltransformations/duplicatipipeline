#!/bin/bash
. "$( cd "$(dirname "$0")" ; pwd -P )/error_handling.sh"
. "$( cd "$(dirname "$0")" ; pwd -P )/markers.sh"

function sync_cache () {
  rsync_delete_option="--delete"
  for (( i=1; i<$NUM_SOURCE_CACHES+1; i++ )); do
    travis_mark_begin "SYNCING CACHE source_${i}"
    rsync -a $rsync_delete_option "/source_${i}/" "/application/"
    unset rsync_delete_option
    travis_mark_end "SYNCING CACHE source_${i}"
  done

}

function setup () {
   if [ -f /sbin/apk ]; then
      apk --update add $DOCKER_PACKAGES
      return
   fi

   if [ -f /usr/bin/apt-get ]; then
      export DEBIAN_FRONTEND=noninteractive
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
        --*)
          if [[ $2 =~ ^--.* || -z $2 ]]; then
            FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
          else
            FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
            FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
          fi
          ;;
        * )
          break
          ;;
      esac
      if [[ $2 =~ ^--.* || -z $2 ]]; then
        shift
      else
        shift
        shift
      fi
  done
}

parse_options "$@"

setup
sync_cache
cd /application
$DOCKER_COMMAND "${FORWARD_OPTS[@]}"