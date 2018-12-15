#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function test_install () {
    apt-get update && apt-get install -y wget unzip
    nuget install NUnit.Runners -Version 3.5.0 -OutputDirectory testrunner
}

parse_options "$@"
travis_mark_begin "PREPARING FOR TEST"
test_install
travis_mark_end "PREPARING FOR TEST"

