#!/bin/bash

git submodule update --remote
git submodule sync
cd duplicati
git reset --hard
git remote add duplicati https://github.com/duplicati/duplicati.git
git fetch duplicati
git merge --no-commit duplicati/master
git remote rm duplicati
cd ..
