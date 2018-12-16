#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

PACKAGES="qemu-user qemu-user-static unzip rsync bzip2"
parse_options "$@" \
--dockerimage teracy/ubuntu:16.04-dind-latest \
--gittag $(git rev-parse --short HEAD) \
--dockerpackages "$PACKAGES" \
--sourcecache "$ZIP_CACHE" \
--targetcache "$INSTALLER_CACHE" \
--dockercommand "./BuildTools/PipeLine/stage_createinstallers/create.sh"

pull_docker_image
run_with_docker