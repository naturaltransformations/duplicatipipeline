#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/shared.sh"
set -o pipefail

${SCRIPT_DIR}/build/wrapper.sh | ts
${SCRIPT_DIR}/unittest/wrapper.sh --categories BulkNormal --data data.zip | ts
${SCRIPT_DIR}/create_zip/wrapper.sh | ts
${SCRIPT_DIR}/create_installers/wrapper.sh --installers debian,fedora | ts
