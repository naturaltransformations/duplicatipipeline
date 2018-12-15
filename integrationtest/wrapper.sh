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

BUILD=false

while true ; do
    case "$1" in
	--rebuild)
		BUILD=true
		;;
    --cache)
        CACHE_DIR=$2
        shift
        ;;
    --* | -* )
        echo "unknown option $1, please use --help."
        exit 1
        ;;
    * )
        break
        ;;
    esac
    shift
done

load_mono

if $BUILD
then
    build_binaries
fi

start_in_docker