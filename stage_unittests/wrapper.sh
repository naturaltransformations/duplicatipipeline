#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="wget unzip rsync"
"${SCRIPT_DIR}/../shared/utils.sh" "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--dockercommand "./BuildTools/PipeLine/stage_unittests/test.sh"