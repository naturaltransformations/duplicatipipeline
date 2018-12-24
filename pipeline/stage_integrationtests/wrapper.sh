#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="python-pip rsync"
"${SCRIPT_DIR}/../shared/utils.sh" "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--dockercommand "/pipeline/stage_integrationtests/test.sh"