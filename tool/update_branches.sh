#!/usr/bin/env bash
###
#  Sync the beta and dev branch with stable
###

set -e

git checkout stable
git pull --ff-only

git checkout beta
git pull --ff-only
git merge stable --ff

git push origin beta

git checkout stable