fs                                          = require 'fs'
path                                        = require 'path'
HOME_DIR                                    = path.join(__dirname,'..')
LIB_COV                                     = path.join(HOME_DIR,'lib-cov')
LIB_DIR                                     = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
Util                                        = require(path.join(LIB_DIR,'util')).Util
AsyncUtil                                   = require(path.join(LIB_DIR,'async-util')).AsyncUtil
cluster                                     = require 'cluster'
dns                                         = require 'dns'
http                                        = require 'http'
https                                       = require 'https'
net                                         = require 'net'
shelljs                                     = require 'shelljs'
URL                                         = require 'url'
DEFAULT_RESOLVE_HOSTNAME_TIMEOUT            = 333
DEFAULT_RESOLVE_HOSTNAME_MAX_PARALLEL_TESTS = 16

class NetUtil

  @normalize_url:(url)=>
    return URL.parse(url)?.href ? url

  # Returns the (cluster-aware) PID, or a random (but consistent) number if no PID is available
  @get_pid:()=>
    @random_pid ?= Math.round(Math.random()*32768)
    return cluster?.worker?.process?.pid ? process?.pid ? @random_pid

  # returns a random value between min and min+range
  @random_port:(min=2000,range=1000)=>
    return min+Math.round(Math.random()*range)

  # attempts to discover an unused port,
  # otherwise returns a random (hopefully unused) port
  @get_unused_port:()=>
    base_port = 2000 + (@get_pid() % 10000)
    command = "for port in $(seq #{base_port} 65000); do echo -ne \"\\035\" | telnet 127.0.0.1 $port > /dev/null 2>&1; [ $? -eq 1 ] && echo \"$port\" && break; done"
    port = null
    try
      output = shelljs.exec command, {silent:true}
      port = Util.to_int(output?.output?.trim())
    catch err
      console.error "ERROR in NetUtil.get_unused_port: ", err
    unless port?
      port = @random_port()
    return port

  # checks if the specified port is in use.
  # callback: `(err, port_in_use)`
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

  # Identifies a "live" IP address for the given domain name, respecting
  # [round-robin DNS](https://en.wikipedia.org/wiki/Round-robin_DNS) entries when found.
  #
  # Sometimes a DNS lookup will return not just one but a list of IP addresses.
  # The expected behavior in this case is that if the first IP address in the
  # list fails to respond, the client should move on to the second IP address,
  # and so on.
  #
  # However, node.js does not adhere to this expected behavior. If the first
  # IP adddress returned fails, the reques will fail outright.  Apparently
  # [there is no intent to change this behavior](https://github.com/nodejs/node/issues/708).
  #
  # This method provides a work-around for Node's default behavior.
  # For a given domain name, it will use `dns.resolve` (rather than `dns.lookup`)
  # to obtain a list of one or more IP addresses.  It will then test the IP
  # addresses, calling back with the IP address of the first server that responds.
  #
  # Parameters:
  #  * `host` - the domain name to resolve
  #  * `options` - an optional map of configuration options, supportin the following keys:
  #     * `protocol` - protocol for the request used to test each server; one of `http:` or `https:`; defaults to `https:`
  #     * `port` - port for the request used to test each server; when `protocol` is `http:`, defaults to `80`; otherwise defaults to `443`
  #     * `path` - path for the request used to test each server; defaults to `/`
  #     * `timeout` - request timeout (in milliseconds), defaults to `DEFAULT_RESOLVE_HOSTNAME_TIMEOUT`
  #     * `max_parallel_tests` - number of IP addresses to check simultaneously; defaults to `DEFAULT_RESOLVE_HOSTNAME_MAX_PARALLEL_TESTS`
  #     * `reject_unauthorized` - when `false`, problems validating the server's SSL certificate will be ignored; defalts to `true`.
  # * `callback` - callback method with the signature `(err, ip_addresses)`
  #
  @resolve_hostname:(host, options, callback)=>
    # swap options and callback if options is not provided
    if typeof options is 'function' and not callback?
      callback = options
      options = null
    # parse options (or set defaults)
    options ?= {}
    protocol = options.protocol ? "https:"
    protocol = protocol.toLowerCase()
    unless /:$/.test protocol
      protocol = protocol + ":"
    port = Util.to_int(options.port) ? if protocol is 'http:' then 80 else 443
    path = options.path ? "/"
    timeout = Util.to_int(options.timeout) ? DEFAULT_RESOLVE_HOSTNAME_TIMEOUT
    max_parallel_tests = Util.to_int(options.max_parallel_tests) ? DEFAULT_RESOLVE_HOSTNAME_MAX_PARALLEL_TESTS
    reject_unauthorized = Util.truthy_string(options.reject_unauthorized ? options.rejectUnauthorized ? true)
    # Cconvert hostname to one or more IPs, and try to find one that works:
    dns.resolve host, (err, ip_addresses)->
      if err?
        callback err
      else
        called_back = false
        # Define a method that tests a single IP address.
        test_ip_action = (ip_address, index, list, next)->
          if called_back                                                        #   If we've already returned an IP for this host, skip this test.
            next()
          else                                                                  #   Otherwise attempt a GET request to see if the IP address is live.
            client = if protocol is 'http:' then http else https
            client.get({
              protocol: protocol
              host: ip_address
              port: port
              path: path
              headers: {
                Host: host
              }
              timeout: timeout
              rejectUnauthorized: reject_unauthorized
            }, (res) ->
              if res?.statusCode? and res?.socket?.remoteAddress?               #   If it worked...
                if not called_back                                              #   ...and we haven't called back yet...
                  callback null, res.socket.remoteAddress                       #   ...callback with the discovered IP address...
                  called_back = true                                            #   ...note that we've called back, and we're done.
            ).on 'error', next                                                  #   Otherwise just keep going.
        # Use that method to test the ip_addresses returned by `dns.resolve`.
        AsyncUtil.throttled_fork_for_each_async max_parallel_tests, ip_addresses, test_ip_action, ()->
          if not called_back                                                    # If we get to "when_done" and still haven't called back yet, none of the IPs worked.
            callback new Error "Unable to find live server for host '#{host}'."

exports.NetUtil = NetUtil
