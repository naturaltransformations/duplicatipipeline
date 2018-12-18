#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/shared/utils.sh"
set -o pipefail

#${SCRIPT_DIR}/stage_build/wrapper.sh | ts
#${SCRIPT_DIR}/stage_unittests/wrapper.sh --testcategories BulkNormal --testdata data.zip | ts
#${SCRIPT_DIR}/stage_unittests/wrapper.sh --testcategories Border | ts
#${SCRIPT_DIR}/stage_createarchive/wrapper.sh | ts
#${SCRIPT_DIR}/stage_createinstallers/wrapper.sh --installers docker,debian,fedora,synology | ts
${SCRIPT_DIR}/stage_deploy/wrapper.sh --awskeyid $(grep aws_access_key_id ~/.aws/credentials | cut -d= -f2 | xargs) --awssecret $(grep aws_secret_access_key ~/.aws/credentials | cut -d= -f2 | xargs ) --awsbucket s3://akiai5v4du3unrva4wxa-test | ts