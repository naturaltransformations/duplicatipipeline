#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="rsync"
"${SCRIPT_DIR}/../shared/utils.sh" "$@" \
--dockerimage mono \
--dockerpackages "$PACKAGES" \
--dockercommand "./BuildTools/PipeLine/stage_createarchive/create.sh"