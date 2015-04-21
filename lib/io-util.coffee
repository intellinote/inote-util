fs      = require 'fs'
request = require 'request'
DEBUG   = (/(^|,)inote-?util($|,)/i.test process?.env?.NODE_DEBUG) or (/(^|,)IOUtil($|,)/.test process?.env?.NODE_DEBUG)
################################################################################

class IOUtil

  @pipe_to_buffer:(readable_stream,callback)=>
    data = []
    length = 0
    readable_stream.on 'data', (chunk)=>
      if chunk?
        data.push chunk
        length += chunk.length
    readable_stream.on 'error', (err)=>
      callback(err)
    readable_stream.on 'end', ()=>
      callback null, Buffer.concat(data)

  @pipe_to_file:(readable_stream,dest,options,callback)=>
    if options? and typeof options is 'function' and not callback?
      callback = options
      options = null
    out = fs.createWriteStream(dest,options)
    out.on 'close', callback
    out.on 'error', callback
    readable_stream.pipe(out)

  @download_to_buffer:(url,callback)=>
    params = {}
    if typeof url is 'string'
      params.url = url
    else
      params = url
    params.encoding = null
    request params, (err,response,body)=>
      if typeof body is 'string'
        body = new Buffer(body,'binary')
      if err?
        callback(err)
      else unless /^2[0-9][0-9]$/.test "#{response?.statusCode}"
        callback(response,body)
      else
        callback(null,body)

  @download_to_file:(url,dest,options,callback)=>
    if options? and typeof options is 'function' and not callback?
      callback = options
      options = null
    params = {}
    if typeof url is 'string'
      params.url = url
    else
      params = url
    out = fs.createWriteStream(dest,options)
    out.on 'close', callback
    out.on 'error', callback
    request(params).pipe(out)

exports.IOUtil = IOUtil
