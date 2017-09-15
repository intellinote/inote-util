#!/bin/bash

# THE PURPOSE OF THIS SCRIPT
#
# This script will publish an npm-module version of this repository
# to git so that it can be installed with a command like:
#
#  npm install "git+ssh://git@bitbucket.org/intellinote/$MOD_NAME.git#npm-v$MOD_VER"
#

# HOW TO USE THIS SCRIPT
#
# This script assumes:
#   (1) The local version of this repository lives in a directory
#       named $MOD_NAME (where $MOD_NAME is the value of the `name`
#       attribute in `package.json`)
#   (2) The path `../$MOD_NAME-npm` points to a clone of this repository.
#   (3) An `npm` branch exists in this repository (locally and on the
#       origin server).
#
# First, follow the git-flow process to create a "release" version of the repo:
#   (1) Run `make clean test` to make sure the code is working properly.
#   (2) Commit all of your changes to the develop branch.
#   (3) Run `git flow release start X.Y.Z` (for version X.Y.Z)
#   (4) Edit `package.json` to reflect that version number.
#   (5) Run `git commit package.json "bump version number to X.Y.Z"` to commit
#       your changes
#   (6) Run `git flow release finish X.Y.Z` to complete the release.
#   (7) Run `git push --all --follow-tags` to push the rlease to the origin.
#
# Next, prepare an NPM package and publish it to bitbucket/git:
#   (1) Run `make clean test-module-install` to generate the `name-vX.Y.Z`
#       module directory and test that it works properly.
#   (2) Run this script (via `./publish-npm-module-to-git.sh`).
#   (3) The `npm` branch in git should now be updated to reflect version
#       X.Y.Z and there should now be an `npm-vX.Y.Z` branch in git
#       (at the origin).
#

MOD_NAME="`node -e "console.log(require('./package.json').name)"`"
MOD_VER="`node -e "console.log(require('./package.json').version)"`"
cd "../$MOD_NAME-npm"
git checkout develop && git pull && git checkout master && git pull && git checkout npm && git pull
rm -rf *
cp -r ../$MOD_NAME/$MOD_NAME-v$MOD_VER/* .
git add *
git commit * -m "publish version $MOD_VER"
git push
git branch npm-v$MOD_VER
git push --set-upstream origin npm-v$MOD_VER
