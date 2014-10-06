fs               = require 'fs'
path             = require 'path'
CONFIG_DIR       = path.join(process.cwd(),'config')

# **Config** - *encapsulates certain [`nconf`](https://github.com/flatiron/nconf)
# behaviors for a consistent way to load configuration data from files
# or the environment.*
#
# EXAMPLE OF USE
#
#     var config = require('inote-util').config.init();
#     var prop = config.get('my:property');
#
# `Config` will load the configuration from several sources.
#
# In order of precedence:
#
# 1. "Override" values passed to the `init` function.
#
# 2. Command line parameters (`--name value`).
#
# 3. A JSON-format configuration file (from a location deterimined by
#    `NODE_ENV`, `config_dir` or `config_file`).
#
# 4. Environment variables.
#
# 5. A "default" JSON-format configuration file at `${config_dir}/config.json`.
#
# 6. "Default" values passed to the `init` function.
#
# To discover a configuration file (as used in step 3 above), `Config` will:
#
# a. Look for `NODE_ENV`, `config_dir` or `config_file` environment variables.
#
# b. If `config_dir` is set, the value will be used as the "parent" directory
#    of the configuration files.  (If `config_dir` is not set, it defaults to
#    the directory `config` within the working directory from which the current
#    Node.js process was launched.)
#
# c. If `NODE_ENV` is set and a file named `${NODE_ENV}.json` exists within
#    the `config_dir`, that file will be used.
#
# d. If `config_file` is set, that file will be used.
#

class Config

  constructor:(defaults=null,overrides=null)->
    @init(defaults,overrides) if defaults? or overrides?

  _load_if_exists:(file)=>
    if file? and fs.existsSync(file)
      @nconf.file(file)
      return true
    else
      return false

  init:(defaults=null,overrides=null)->
    @nconf = require 'nconf'
    @nconf.overrides(overrides) if overrides?                           # First, use any overrides that are provided.
    @nconf.argv()                                                       # Next, command line parameters.
    @nconf.env ['NODE_ENV','config_file','config_dir']                  # Then, fetch certain values from the environment variables (but nothing else yet), if they aren't already set.
    config_dir = @nconf.get('config_dir')                               # Now, if there is a `config_dir` directory specified, use that instead of the default `CONFIG_DIR`.
    if config_dir?
      if fs.existsSync(config_dir)
        CONFIG_DIR = config_dir
      else
        console.error "Custom config_dir #{config_dir} not found; aborting."
        process.exit(1)
    else
      config_dir = CONFIG_DIR
    if @nconf.get('NODE_ENV')?                                          # If there is a `[CONFIG_DIR]/[NODE_ENV].json` file, try to load that.
      @_load_if_exists(path.join(config_dir,"#{@nconf.get('NODE_ENV')}.json"))
    config_file = @nconf.get('config_file')                             #If there is a `config_file` variable, try to load that.
    if config_file?
      unless @_load_if_exists(config_file)
        console.error "Custom config_file #{config_file} not found; aborting."
        process.exit(1)
    @nconf.env()                                                        # Pull remaining values from the environment variables
    @_load_if_exists(path.join(config_dir,'config.json'))               # Finally if there is a `[CONFIG_DIR]/config.json` configuration file, use that.
    @nconf.defaults(defaults) if defaults?                              # ...and use any provided defaults.
    return @nconf

exports.config = new Config()
