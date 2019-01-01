#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"
. "${SCRIPT_DIR}/params.sh"

${ROOT_DIR}/pipeline/stage_deploy/trigger.sh \
${FORWARD_OPTS[@]} \
--awskeyid $AWS_ACCESS_KEY_ID \
--awssecret $AWS_SECRET_ACCESS_KEY \
--awsbucket $AWS_BUCKET_URI \
--dockeruser $DOCKER_USER \
--dockerpassword $DOCKER_PASSWORD \
--dockerrepo $DOCKER_REPO  \
--sourcedir "${SIGN_DIR}" \
--sourcedir "${PACKAGES_DIR}" \
--targetdir "${UPLOAD_DIR}" | ts