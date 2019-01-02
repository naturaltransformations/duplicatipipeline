#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/shared/error_handling.sh"
. "${SCRIPT_DIR}/.local_config.sh"

${ROOT_DIR}/pipeline/shared/sync_repo.sh

${ROOT_DIR}/pipeline/jobs/build_job.sh
# ${ROOT_DIR}/pipeline/jobs/unittest1_job.sh
# ${ROOT_DIR}/pipeline/jobs/unittest2_job.sh
# ${ROOT_DIR}/pipeline/jobs/unittest3_job.sh
# ${ROOT_DIR}/pipeline/jobs/unittest4_job.sh
# ${ROOT_DIR}/pipeline/jobs/unittest5_job.sh
${ROOT_DIR}/pipeline/jobs/package_job.sh
${ROOT_DIR}/pipeline/jobs/packages_job.sh
${ROOT_DIR}/pipeline/jobs/sign_job.sh
# ${ROOT_DIR}/pipeline/jobs/upload_job.sh
