Rod Waldhoff
Here's the process I follow:
Make sure everything is working (make test or even better make test-module-install).
Perform a git-flow release (git flow release start; update version number; commit; git flow release finish; git push --all --follow-tags).
Run make clean test-module-install (which generates inote-util-vNEWVERISON.tgz). This archive should include the *.js files.
Run npm publish inote-util-vNEWVERISON.tgz
