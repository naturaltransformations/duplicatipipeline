#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"
. "${SCRIPT_DIR}/params.sh"

${ROOT_DIR}/pipeline/stage_createinstallers/trigger.sh \
${FORWARD_OPTS[@]} \
--installers fedora \
--sourcedir "${BUILD_DIR}" \
--sourcedir "${ARCHIVE_DIR}" \
--keeptargetfilter "./Updates/.*target/.*" \
--targetdir "${PACKAGE_FEDORA_DIR}" | ts
