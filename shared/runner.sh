#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

echo $@
parse_options "$@"
echo "docker runner received options $FORWARD_OPTS"
cd /duplicati
./BuildTools/PipeLine/shared/setup_docker.sh --dockerpackages "$DOCKER_PACKAGES"
$DOCKER_COMMAND $FORWARD_OPTS