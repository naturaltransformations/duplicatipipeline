#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

echo -n | openssl s_client -connect scan.coverity.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sudo tee -a /etc/ssl/certs/ca-

parse_options "$@"
pull_mono_docker_image
sync_and_use_test_cache
run_with_mono_docker "./BuildTools/PipeLine/unittest/setup_docker.sh;\
./BuildTools/PipeLine/unittest/test.sh $TEST_CATEGORIES $TEST_DATA"