#!/bin/bash
. "$( cd "$(dirname "$0")" ; pwd -P )/../shared/error_handling.sh"

export DUPLICATI_ROOT="/application/"
declare -a FORWARD_OPTS

releasetype="nightly"

export workingdir
export releaseversion
export dockerrepo
export releasetype="$releasetype"
export RELEASE_CHANGELOG_FILE="${DUPLICATI_ROOT}/changelog.txt"
export RELEASE_CHANGELOG_NEWS_FILE="${DUPLICATI_ROOT}/changelog-news.txt" # never in repo due to .gitignore
export RELEASE_TIMESTAMP=$(date +%Y-%m-%d)
export RELEASE_NAME="${releaseversion}_${releasetype}_${RELEASE_TIMESTAMP}"
export RELEASE_FILE_NAME="duplicati-${RELEASE_NAME}"
export RELEASE_NAME_SIMPLE="duplicati-${releaseversion}"
export BUILDTAG="${releasetype}_${RELEASE_TIMESTAMP}_${gittag}"
export BUILDTAG=${BUILDTAG//-}
export UPDATE_SOURCE="${DUPLICATI_ROOT}/Updates/build/${BUILDTAG}_source"
export UPDATE_TARGET="${DUPLICATI_ROOT}/Updates/build/${BUILDTAG}_target"
export ZIPFILE="${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip"
#  BUILDTAG_RAW=$(echo "${RELEASE_FILE_NAME}" | cut -d "." -f 1-4 | cut -d "-" -f 2-4)

