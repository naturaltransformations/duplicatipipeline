#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/error_handling.sh"

PACKAGES="libgtk2.0-cil rsync"
"${SCRIPT_DIR}/../shared/utils.sh" "$@" --dockerimage mono \
--dockerpackages "$PACKAGES" \
--dockercommand "/pipeline/stage_build/build.sh"