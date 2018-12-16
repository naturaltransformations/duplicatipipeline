#!/bin/bash

pip install selenium
pip install --upgrade urllib3
mono "${TRAVIS_BUILD_DIR}"/Duplicati/GUI/Duplicati.GUI.TrayIcon/bin/Release/Duplicati.Server.exe &
python guiTests/guiTest.py