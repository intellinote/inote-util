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
#   resolve_ip 'itunes.com', (err, res) ->
#     console.log res
# 
###

class DNSUtil
  @resolve_ip = (hostName, callback, timeout=100) ->
    dns.resolve hostName, (err, addresses) ->
      if err?
        callback err,null
      else
        _resolve_ip addresses.shift(), timeout, callback

  _resolve_ip = (address, timeout, callback) ->
    if address
      http.get({
        hostname: address,
        rejectUnauthorized: false, # this is set to false to avoid ssl errors
        timeout: timeout
      }, (res) ->
        if res and res.statusCode
          callback null,res.socket.remoteAddress
      ).on 'error', (err) ->
        _resolve_ip addresses.shift(), timeout, callback
    else
      console.log 'seems like the domain is down'
      callback new Error "Seems like the domain is down", null

exports.DNSUtil = DNSUtil