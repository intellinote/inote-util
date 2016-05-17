class LogUtil

  # format a timestamp
  @_fts:(d)=>
    "[#{(d ? new Date()).toISOString()}]"

  # format a PID
  @_fpid:(p)=>
    "[p:#{p ? process.pid ? '?'}]"

  @tlog:(args...)=>
    console.log @_fts(),args...

  @terr:(args...)=>
    console.error @_fts(),args...

  @tplog:(args...)=>
    console.log @_fts(),@_fpid(),args...

  @tperr:(args...)=>
    console.error @_fts(),@_fpid(),args...

exports.LogUtil = LogUtil
