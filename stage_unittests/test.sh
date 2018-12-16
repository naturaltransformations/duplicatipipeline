#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

function get_and_extract_test_zip () {
    travis_mark_begin "DOWNLOADING TEST DATA $CAT"
    # test if zip file exists and contains no errors, otherwise redownload
    unzip -t ~/download/"${CAT}"/"${TEST_DATA}" &> /dev/null || \
    wget --progress=dot:giga "https://s3.amazonaws.com/duplicati-test-file-hosting/${TEST_DATA}" -O ~/download/"${CAT}"/"${TEST_DATA}"
    unzip -q ~/download/"${CAT}"/"${TEST_DATA}" -d ${UNITTEST_BASEFOLDER}
    travis_mark_end "DOWNLOADING TEST DATA $CAT"
}

function start_test () {
    echo -n | openssl s_client -connect scan.coverity.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | tee -a /etc/ssl/certs/ca-
    nuget install NUnit.Runners -Version 3.5.0 -OutputDirectory testrunner

    for CAT in $(echo $TEST_CATEGORIES | sed "s/,/ /g")
    do
        # prepare dirs
        if [ ! -d ~/tmp ]; then mkdir ~/tmp; fi
        if [ ! -d ~/download/"${CAT}" ]; then mkdir -p ~/download/"${CAT}"; fi
        export UNITTEST_BASEFOLDER=~/duplicati_testdata/"${CAT}"
        rm -rf ${UNITTEST_BASEFOLDER} && mkdir -p ${UNITTEST_BASEFOLDER}

        if [[ ${TEST_DATA} != "" ]]; then
            get_and_extract_test_zip
        fi

        travis_mark_begin "UNIT TESTING CATEGORY $CAT"
        mono "${DUPLICATI_ROOT}"/testrunner/NUnit.ConsoleRunner.3.5.0/tools/nunit3-console.exe \
        "${DUPLICATI_ROOT}"/Duplicati/UnitTest/bin/Release/Duplicati.UnitTest.dll --where:cat==$CAT --workers=1
        travis_mark_end "UNIT TESTING CATEGORY $CAT"
    done
}

parse_options "$@"

travis_mark_begin "UNIT TESTING"
start_test
travis_mark_end "UNIT TESTING"
