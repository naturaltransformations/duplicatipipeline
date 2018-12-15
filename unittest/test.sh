#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function get_and_extract_test_zip () {
    # download and extract testdata
    echo "travis_fold:start:download_extract_testdata"
    echo "+ DOWNLOADING TEST DATA"

    # test if zip file exists and contains no errors, otherwise redownload
    unzip -t ~/download/"${CAT}"/"${ZIPFILE}" &> /dev/null || \
    wget --progress=dot:giga "https://s3.amazonaws.com/duplicati-test-file-hosting/${ZIPFILE}" -O ~/download/"${CAT}"/"${ZIPFILE}"
    unzip -q ~/download/"${CAT}"/"${ZIPFILE}" -d ${UNITTEST_BASEFOLDER}
    echo "travis_fold:end:download_extract_testdata"
}

function set_permissions () {
    if id travis &> /dev/null
    then
        TESTUSER=travis
    else
        TESTUSER=$(whoami)
    fi
    chown -R $TESTUSER ${UNITTEST_BASEFOLDER}
    chmod -R 755 ${UNITTEST_BASEFOLDER}
}

function start_test () {
    for CAT in $(echo $CATEGORIES | sed "s/,/ /g")
    do
        # prepare dirs
        if [ ! -d ~/tmp ]; then mkdir ~/tmp; fi
        if [ ! -d ~/download/"${CAT}" ]; then mkdir -p ~/download/"${CAT}"; fi
        export UNITTEST_BASEFOLDER=~/duplicati_testdata/"${CAT}"
        rm -rf ${UNITTEST_BASEFOLDER} && mkdir -p ${UNITTEST_BASEFOLDER}

        if [[ $ZIPFILE != "" ]]; then
            get_and_extract_test_zip
        fi

        set_permissions

        echo "travis_fold:start:unit_test_$CAT"
        echo "+ START UNIT TESTING CATEGORY $CAT"
        mono "${DUPLICATI_ROOT}"/testrunner/NUnit.ConsoleRunner.3.5.0/tools/nunit3-console.exe \
        "${DUPLICATI_ROOT}"/Duplicati/UnitTest/bin/Release/Duplicati.UnitTest.dll --where:cat==$CAT --workers=1
        echo "travis_fold:end:unit_test_$CAT"
        echo "+ DONE UNIT TESTING CATEGORY $CAT"
    done
}

CATEGORIES=$1
ZIPFILE=$2

start_test
