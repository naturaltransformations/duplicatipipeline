#!/bin/bash

git submodule update --remote
git submodule sync
git submodule update --init --recursive --remote
cd duplicati
git reset --hard
git remote add nightly_fixes https://github.com/verhoek/duplicati.git
git fetch nightly_fixes
git merge --no-commit nightly_fixes/nightly_builds
git remote rm nightly_fixes
cd ..
