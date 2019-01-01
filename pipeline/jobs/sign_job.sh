#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"
. "${SCRIPT_DIR}/params.sh"

${ROOT_DIR}/pipeline/stage_sign/trigger.sh \
${FORWARD_OPTS[@]} \
--signingkeyfilepassword "$SIGNING_KEY_FILE_PASSWORD" \
--gpgcredentialsfile "$GPG_CREDENTIALS_FILE" \
--gpgkeyfile "$GPG_KEY_FILE" \
--sourcedir "${BUILD_DIR}" \
--sourcedir "${PACKAGES_DIR}" \
--keeptargetfilter "./Updates/.*target/.*" \
--targetdir "${SIGN_DIR}" | ts
