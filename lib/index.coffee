# This `index.coffee` (or the generated `index.js`) file is the base file that
# in loaded when a user `require`s `inote-util`.

# <i style="color:#666;font-size:80%">(Note: If you are viewing the [docco](http://jashkenas.github.io/docco/)-generated HTML version of this file, use the "Jump To..." menu in the upper right corner to navigate to the annotated versions of other source files.)</i>

# ## Calculate LIB_DIR

# As we do throughout the source files in this module, in order to
# support test coverage analysis, we deterine whether we should load
# additional local files from the default `lib` directory or from the
# `lib-cov` directory that contains an instrumented version of
# the source code (when present).

fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join __dirname, '..'
LIB_COV   = path.join HOMEDIR, 'lib-cov'
LIB       = path.join HOMEDIR, 'lib'
LIB_DIR   = if fs.existsSync(LIB_COV) then LIB_COV else LIB

# ## Export Objects to the External Namespace

# `sources` enumerates the files from which we'll load objects to export.

sources = [
  'util'
  'stopwatch'
  'config'
]

# Now we simply load (`require`) the requisite files and pass along whatever
# they've exported to the module's `exports` object.

for file in sources
  exported = require path.join(LIB_DIR,file)
  for k,v of exported
    exports[k] = v
