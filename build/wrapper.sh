#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

parse_options "$@"

setup_cache
load_mono
build_in_docker