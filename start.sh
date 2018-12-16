#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/shared/utils.sh"
set -o pipefail

#${SCRIPT_DIR}/stage_build/wrapper.sh | ts
#${SCRIPT_DIR}/stage_unittests/wrapper.sh --testcategories BulkNormal --testdata data.zip | ts
${SCRIPT_DIR}/stage_unittests/wrapper.sh --testcategories Border | ts
#${SCRIPT_DIR}/stage_createarchive/wrapper.sh | ts
#${SCRIPT_DIR}/stage_createinstallers/wrapper.sh --installers docker,debian,fedora,synology | ts
