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

git checkout dev
git pull --ff-only
git merge beta --ff

git push origin beta
git push origin dev

git checkout stable