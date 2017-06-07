fs   = require('fs')
util = require('util')


class FileLogger

  # config.out_file - where to write stdout stuff to
  # config.err_file - where to write stderr stuff to
  constructor:(config)->
    @_configure(config)

  _configure:(config)=>
    if (@out_stream? or @err_stream?) and not @closed
      @close()
    config ?= {}
    config.err_file ?= config.out_file ? "log.err"
    config.out_file ?= "log.out"
    @out_stream = fs.createWriteStream(config.out_file,{flags:'a'})
    @out_stream.on "finish", (()->undefined)
    if config.err_file is config.out_file
      @err_stream = @out_stream
    else
      @err_stream = fs.createWriteStream(config.err_file,{flags:'a'})
      @err_stream.on "finish", (()->undefined)
    @closed = false

  _format_log_line:()->
    return util.format.apply(null,arguments)+"\n"

  log:(args...)=>
    unless @closed
      @out_stream.write(@_format_log_line(args...))

  info:(args...)=>
    unless @closed
      @out_stream.write(@_format_log_line(args...))

  error:(args...)=>
    unless @closed
      @err_stream.write(@_format_log_line(args...))

  err:(args...)=>
    unless @closed
      @err_stream.write(@_format_log_line(args...))

  warn:(args...)=>
    unless @closed
      @err_stream.write(@_format_log_line(args...))

  is_closed:()=>@closed

  close:()=>
    unless @closed
      @closed = true
      try
        @out_stream.end()
        @out_stream = null
      catch err
        # ignored
      try
        @err_stream.end()
        @err_stream = null
      catch err
        # ignored

  end:()=>@close()

exports.FileLogger = FileLogger
