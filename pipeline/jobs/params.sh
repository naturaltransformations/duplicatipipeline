#!/bin/bash

function add_option () {
  FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
  FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
}

FORWARD_OPTS=()
add_option "--releaseversion" "2.0.4.$(cat "${ROOT_DIR}"/duplicati//Updates/build_version.txt)"
add_option "--gittag" "$(cd "${ROOT_DIR}"/duplicati;git rev-parse --short HEAD)"

export FORWARD_OPTS
