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
