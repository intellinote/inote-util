fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Util    = require(path.join(LIB_DIR,'util')).Util
shell   = require 'shelljs'
cluster = require 'cluster'
net     = require 'net'
DEBUG   = (/(^|,)inote-?util($|,)/i.test process?.env?.NODE_DEBUG) or (/(^|,)NetUtil($|,)/.test process?.env?.NODE_DEBUG)

class NetUtil

  # returns the (cluster-aware) PID, or a random number if no PID is available
  @get_pid:()=>
    @random_pid ?= Math.round(Math.random()*32768)
    return cluster?.worker?.process?.pid ? process?.pid ? @random_pid

  # returns a random value between min and min+range
  @random_port:(min=2000,range=1000)=>
    return min+Math.round(Math.random()*range)

  # attempts to discover an unused port, otherwise returns a random (hopefully unused) port
  @get_unused_port:()=>
    base_port = 2000 + (@get_pid() % 10000)
    command = "for port in $(seq #{base_port} 65000); do echo -ne \"\\035\" | telnet 127.0.0.1 $port > /dev/null 2>&1; [ $? -eq 1 ] && echo \"$port\" && break; done"
    port = null
    try
      output = shell.exec command, {silent:true}
      port = Util.to_int(output?.output?.trim())
    catch err
      console.error "ERROR in NetUtil.get_unused_port: ", err
    unless port?
      port = @random_port()
    return port

  @is_port_in_use:(port, callback)=>
    server = net.createServer()
    server.once "error", (err)=>
      if err? and err.code is 'EADDRINUSE'
        callback null, true
      else
        callback(err)
    server.once "listening", ()=>
      server.once "close", ()=>
        callback null, false
      server.close()
    server.listen port

exports.NetUtil = NetUtil
