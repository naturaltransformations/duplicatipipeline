#!/bin/bash

export PATH="$PATH:${ROOT_DIR}/pipeline/docker-run"
. error_handling.sh

function add_option () {
  FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
  FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
}

FORWARD_OPTS=()
add_option "--releaseversion" "2.0.4.$(cat "${ROOT_DIR}"/duplicati/Updates/build_version.txt)"
add_option "--gittag" "$(cd "${ROOT_DIR}"/duplicati;git log --pretty=format:"%h" --before="$(date -d yesterday +%F)" HEAD -n1)"

export FORWARD_OPTS
