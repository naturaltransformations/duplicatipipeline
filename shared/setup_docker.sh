#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

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

parse_options "$@"
travis_mark_begin "INSTALLING DOCKER PACKAGES"
setup
travis_mark_end "INSTALLING DOCKER PACKAGES"