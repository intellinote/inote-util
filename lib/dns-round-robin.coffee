dns = require('dns')
URL = require('url')
http = require('https')
addresses=[]

###
# have set default time out for http.get to 100 milliseconds
#
# resolve_ip function resolves a domain name to all the corresponding host and try hitting 
#   one by one until a response is got from the host (this response can even be a 404 or 400).
#   
# Example usage:
#   resolve_ip 'itunes.com', (res) ->
#     console.log res
#     return
###

class ResolveIP
  @resolve_ip = (hostName, cb, timeout=100) ->
    port = 443
    console.log(hostName)
    dns.resolve hostName, (err, addresses) ->
      if err
        console.log 'invalid domain name'
        throw err
      console.log(addresses)
      _resolve_ip addresses.shift(), port, cb, timeout
      return
    return

  _resolve_ip = (address, port, cb, timeout) ->
    if address
      http.get({
        hostname: address
        port: port
        rejectUnauthorized: false, # this is set to false to avoid ssl errors
        timeout: timeout
      }, (res) ->
        if res and res.statusCode
          cb res.socket.remoteAddress
        return
      ).on 'error', (err) ->
        _resolve_ip addresses.shift()
        return
    else
      console.log 'seems like the domain is down'
      throw new Error('Seems like the domain is down')
    return

exports.ResolveIP = ResolveIP