#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function setup () {
    apt-get update && apt-get install -y git libgtk2.0-cil
    eval nuget restore Duplicati.sln $IF_QUIET_SUPPRESS_OUTPUT

    if [ ! -d "${DUPLICATI_ROOT}"/packages/SharpCompress.0.18.2 ]; then
        ln -s "${DUPLICATI_ROOT}"/packages/sharpcompress.0.18.2 "${DUPLICATI_ROOT}"/packages/SharpCompress.0.18.2
    fi
}

parse_options $@
travis_mark_begin "SETUP DOCKER IMAGE"
setup
travis_mark_end "SETUP DOCKER IMAGE"