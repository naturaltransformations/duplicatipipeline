#!/bin/bash
. /pipeline/shared/duplicati.sh
. /pipeline/shared/markers.sh

function start_test () {
    pip install selenium
    pip install --upgrade urllib3

    # wget "https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux32.tar.gz"
    # tar -xvzf geckodriver*
    # chmod +x geckodriver
    # export PATH=$PATH:/duplicati/

    #echo -n | openssl s_client -connect scan.coverity.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | tee -a /etc/ssl/certs/ca-
    mono "${DUPLICATI_ROOT}/Duplicati/GUI/Duplicati.GUI.TrayIcon/bin/Release/Duplicati.Server.exe" &
    cd
    python /application/guiTests/guiTest.py
}

parse_duplicati_options "$@"

travis_mark_begin "INTEGRATION TESTING"
start_test
travis_mark_end "INTEGRATION TESTING"