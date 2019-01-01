#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"
. "${SCRIPT_DIR}/params.sh"

${ROOT_DIR}/pipeline/stage_createinstallers/trigger.sh \
${FORWARD_OPTS[@]} \
--installers docker,fedora,debian,synology \
--sourcedir "${BUILD_DIR}" \
--sourcedir "${ARCHIVE_DIR}" \
--keeptargetfilter "./Updates/.*target/.*" \
--targetdir "${PACKAGES_DIR}" \
--dockerrepo $DOCKER_REPO | ts
