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
    options ?= {}
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
        callback(new Error("Expected 2xx series status code for #{url}, found #{response?.statusCode}."),body,response)
      else
        callback(null,body,response)

  @download_to_file:(url,dest,options,callback)=>
    if options? and typeof options is 'function' and not callback?
      callback = options
      options = null
    params = {}
    options ?= {}
    if typeof url is 'string'
      params.url = url
    else
      params = url
    out = fs.createWriteStream(dest,options)
    out.on 'close', callback
    out.on 'error', callback
    request(params).pipe(out)

  @download_to_data_uri:(url,callback)=>
    @download_to_buffer url, (err, buffer, response)=>
      if err?
        callback err
      else unless buffer?
        callback null, null
      else
        data_uri = "data:"
        if response?.headers?["content-type"]?
          data_uri += response.headers["content-type"] # TODO maybe should strip any trailing `;charset` etc.?
        data_uri += ";base64,"
        data_uri += buffer.toString("base64")
        callback null, data_uri

exports.IOUtil = exports.IoUtil = IOUtil
