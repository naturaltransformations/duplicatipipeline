#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"
. "${SCRIPT_DIR}/params.sh"

${ROOT_DIR}/pipeline/stage_build/trigger.sh \
${FORWARD_OPTIONS[@]} \
--sourcedir "${ROOT_DIR}/duplicati" \
--targetdir "${BUILD_DIR}" | ts
