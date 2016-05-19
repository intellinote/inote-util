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
  'async-util'
  'config'
  'file-util'
  'io-util'
  'net-util'
  'object-util'
  'stopwatch'
  'string-util'
  'util'
  'work-queue'
  'zip-util'
  'log-util'
]

# Now we simply load (`require`) the requisite files and pass along whatever
# they've exported to the module's `exports` object.

for file in sources
  exported = require path.join(LIB_DIR,file)
  for k,v of exported
    exports[k] = v

for fn in ["read_stdin_sync","load_json_file_sync","load_json_stdin_sync"]
  exports.Util[fn] = exports.FileUtil[fn]

for fn in ['trim', 'isnt_blank', 'is_blank', 'blank_to_null', 'truncate', 'escape_for_json', 'escape_for_regexp', 'truthy_string', 'falsey_string', 'lpad', 'lpad_string', 'rpad', 'rpad_string']
  exports.Util[fn] = exports.StringUtil[fn]

for fn in ['for_async', 'for_each_async', 'fork', 'throttled_fork', 'procedure']
  exports.Util[fn] = exports.AsyncUtil[fn]
