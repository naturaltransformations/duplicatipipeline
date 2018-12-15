#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function setup () {
   apt-get update
   apt-get install -y \
      apt-transport-https ca-certificates software-properties-common unzip bzip2 qemu-user qemu-user-static curl unzip bash
}

parse_options "$@"
travis_mark_begin "SETUP DOCKER IMAGE"
setup
travis_mark_end "SETUP DOCKER IMAGE"