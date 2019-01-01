#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"
. "${SCRIPT_DIR}/params.sh"

${ROOT_DIR}/pipeline/stage_createarchive/trigger.sh \
${FORWARD_OPTS[@]} \
--sourcedir "${BUILD_DIR}" \
--targetdir "${ARCHIVE_DIR}" \
--keeptargetfilter "./Updates/.*" \
--keepsourcefilter "\(./BuildTools/\|./Installer/\).*" \
--signingkeyfilepassword "$SIGNING_KEY_FILE_PASSWORD" \
--signingkeyfile "$AUTO_UPDATE_KEY_FILE" | ts
