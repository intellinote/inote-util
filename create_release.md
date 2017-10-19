# Create a release

```
git flow release start v1.11.0
vi package.json
gcom 'bump to version 1.11.0'
git flow release finish 'v1.11.0'
git push --all --follow-tags
```

## Push to npm

`npm publish`

Note: you need access to the intellinote npm project that only Rod can grant. JOD has this access, feel free to bug him.
Rod Waldhoff
Here's the process I follow:
Make sure everything is working (make test or even better make test-module-install).
Perform a git-flow release (git flow release start; update version number; commit; git flow release finish; git push --all --follow-tags).
Run make clean test-module-install (which generates inote-util-vNEWVERISON.tgz). This archive should include the *.js files.
Run npm publish inote-util-vNEWVERISON.tgz
