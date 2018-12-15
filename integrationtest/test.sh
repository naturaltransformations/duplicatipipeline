#!/bin/bash

mono "${TRAVIS_BUILD_DIR}"/Duplicati/GUI/Duplicati.GUI.TrayIcon/bin/Release/Duplicati.Server.exe &
python guiTests/guiTest.py