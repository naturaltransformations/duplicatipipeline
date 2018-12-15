#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/shared.sh"

TRAVIS_BUILD_DIR="${SCRIPT_DIR}/../../"
BUILD_CACHE="${TRAVIS_BUILD_DIR}/../.cache"
${TRAVIS_BUILD_DIR}/BuildTools/PipeLine/build/wrapper.sh --repodir "${TRAVIS_BUILD_DIR}" --cache "$BUILD_CACHE" | ts
${TRAVIS_BUILD_DIR}/BuildTools/PipeLine/unittest/wrapper.sh --categories BulkNormal --data data.zip --cache "$BUILD_CACHE" | ts
${TRAVIS_BUILD_DIR}/BuildTools/PipeLine/package/wrapper.sh --cache "$BUILD_CACHE" | ts
