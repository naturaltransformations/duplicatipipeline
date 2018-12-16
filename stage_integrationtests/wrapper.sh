#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"


function build_binaries () {
    . "${SCRIPT_DIR}/build-wrapper.sh" --redirect
}

echo -n | openssl s_client -connect scan.coverity.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sudo tee -a /etc/ssl/certs/ca-

function start_in_docker() {
    docker run -v "${CACHE_DIR}:/duplicati" mono /bin/bash -c "cd /duplicati;\
    ./BuildTools/scripts/travis/integrationtest/install.sh;\
    ./BuildTools/scripts/travis/integrationtest/test.sh"
}

parse_options "$@"

load_mono
