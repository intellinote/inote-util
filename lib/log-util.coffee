class LogUtil

  constructor:(config)->
    config ?= {}
    @DEBUG = config.DEBUG ? config.debug ? false
    @logger = config.logger ? console
    if @logger.err? and not @logger.error?
      @logger.error ?= @logger.err
    else if @logger.error? and not @logger.err?
      @logger.err ?= @logger.error
    @logger.log ?= console.log
    @logger.error ?= console.error
    @logger.info ?= console.info
    @logger.warn ?= console.warn
    @prefix = config.prefix ? null
    @_init_functions()

  # format a timestamp
  _fts:(d)=>
    "[#{(d ? new Date()).toISOString()}]"

  # format a PID
  _fpid:(p)=>
    "[p:#{p ? process.pid ? '?'}]"

  _init_functions:()=>
    @log = (args...)=>@_m("log", args...)
    @tlog = (args...)=>@_tm("log", args...)
    @tplog = (args...)=>@_tpm("log", args...)
    @err = @error = (args...)=>@_m("error", args...)
    @terr = @terror = (args...)=>@_tm("error", args...)
    @tperr = @tperror = (args...)=>@_tpm("error", args...)
    @warn = (args...)=>@_m("warn", args...)
    @twarn = (args...)=>@_tm("warn", args...)
    @tpwarn = (args...)=>@_tpm("warn", args...)
    @info = (args...)=>@_m("info", args...)
    @tinfo = (args...)=>@_tm("info", args...)
    @tpinfo = (args...)=>@_tpm("info", args...)

  debug:(args...)=>
    if @DEBUG
      @log args...

  tdebug:(args...)=>
    if @DEBUG
      @tlog args...

  tpdebug:(args...)=>
    if @DEBUG
      @tplog args...

  _m:(method,args...)=>
    if @prefix?
      @logger[method] @prefix, args...
    else
      @logger[method] args...

  _tm:(method,args...)=>
    if @prefix?
      @logger[method] @_fts(), @prefix, args...
    else
      @logger[method] @_fts(), args...

  _tpm:(method,args...)=>
    if @prefix?
      @logger[method] @_fts(), @_fpid(), @prefix, args...
    else
      @logger[method] @_fts(), @_fpid(), args...

exports.LogUtil = new LogUtil()
exports.LogUtil.constructor = exports.LogUtil.LogUtil = LogUtil
exports.LogUtil.init = (config)->return new LogUtil(config)

# console.log exports
# # LU = new LogUtil()
# # LU.tpinfo("foo","bar",3)
