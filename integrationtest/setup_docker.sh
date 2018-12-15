#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function setup () {
    sudo pip install selenium
    sudo pip install --upgrade urllib3
}

parse_options "$@"
travis_mark_begin "SETUP DOCKER IMAGE"
setup
travis_mark_end "SETUP DOCKER IMAGE"

