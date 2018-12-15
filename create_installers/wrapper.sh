#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"


parse_options "$@" --dockerimage adobeplatform/jenkins-dind --gittag $(git rev-parse --short HEAD)
pull_docker_image
sync_and_use_installer_cache

run_with_docker "\
./BuildTools/PipeLine/create_installers/setup_docker.sh;\
./BuildTools/PipeLine/create_installers/create.sh $FORWARD_OPTS"