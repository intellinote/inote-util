fs                         = require 'fs'
path                       = require 'path'
HOME_DIR                   = path.join(__dirname,'..')
LIB_COV                    = path.join(HOME_DIR,'lib-cov')
LIB_DIR                    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
Util                       = require(path.join(LIB_DIR,'util')).Util
cluster                    = require 'cluster'
dns                        = require 'dns'
https                      = require 'https'
net                        = require 'net'
shell                      = require 'shelljs'
URL                        = require 'url'
DEFAULT_RESOLVE_IP_TIMEOUT = 333

class NetUtil

  @normalize_url:(url)=>
    return URL.parse(url)?.href ? url

  # returns the (cluster-aware) PID, or a random (but consistent) number if no PID is available
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

  # TODO - when addresses resolves to single IP is there a way to fall back to the default node behavior? this method exists to handle the case when the hostname resolves to multiple ips
  # TODO - when test all IPs in parallel (or at least up to some moderately large limit, say 64) and callback with the first that works; see AsyncUtil.fork_for_each_async for example.
  # TODO - need to support ports other than 443
  @resolve_hostname:(url, timeout, callback)=>
    parsed_url = URL.parse url
    if typeof timeout is 'function' and not callback?
      callback = timeout
      timeout = null
    timeout ?= DEFAULT_RESOLVE_IP_TIMEOUT
    dns.resolve parsed_url.hostname, (err, addresses)=>
      if err?
        callback err,null
      # try hitting different ips only if the host name resolves to multiple ips, else return the hostname back
      else if addresses.length > 1
        @_resolve_hostname parsed_url, addresses.shift(), timeout, addresses, callback
      else
        callback(err, url)

  # (hostname is only passed for the purpose of the text in the error)
  @_resolve_hostname:(parsed_url, address, timeout, addresses, callback)=>
    if parsed_url.port?
      port = parsed_url.port
    else
      port = 443
    if address?
      https.get({
        hostname: address,
        # set host name in the headers to avoid ssl error.
        headers:{
          host: parsed_url.hostname
        },
        timeout: timeout,
        port: port
      }, (res) ->
        if res?.statusCode?
          url = parsed_url.protocol+'//'+res.socket.remoteAddress+':'+port+parsed_url.path
          callback null, url
      ).on 'error', (err)=>
        @_resolve_hostname parsed_url, addresses.shift(), timeout, addresses, callback
    else
      callback new Error "Unable to find live server for host '#{parsed_url.hostname}'."

exports.NetUtil = NetUtil
