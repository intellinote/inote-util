fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
StringUtil = require(path.join(LIB_DIR,'string-util')).StringUtil
shell      = require 'shelljs'
DEBUG      = (/(^|,)zip-?util($|,)/i.test process?.env?.NODE_DEBUG)

class ZipUtil

  @zip:(wd,inputs,output,callback)=>
    if wd? and inputs? and typeof output is 'function' and not callback?
      [wd, inputs, output, callback] = [null, wd, inputs, output]
    unless inputs? and output?
      callback?(new Error("Missing or invalid parameters."))
    else
      unless Array.isArray(inputs)
        inputs = [inputs]
      args = []
      if wd?
        args.push "cd"
        args.push wd
        args.push "&&"
      args.push "zip"
      args.push "-r"
      args.push "-9"
      args.push output
      args = args.concat inputs
      args = args.map (p)->StringUtil.escape_for_bash(p)
      cmd = args.join ' '
      # console.log cmd
      shell.exec cmd, {silent:true}, (exit_code,output)=>
        err = null
        if exit_code isnt 0
          err = new Error("Non-zero exit code (#{exit_code}) encountered for \"#{cmd}\". Output: #{output}")
        callback(err,exit_code,output)

  @unzip:(wd,zipfile,outdir,callback)=>
    if wd? and zipfile? and typeof outdir is 'function' and not callback?
      [wd, zipfile, outdir, callback] = [null, wd, zipfile, outdir]
    unless zipfile?
      callback?(new Error("Missing or invalid parameters."))
    else
      args = []
      if wd?
        args.push "cd"
        args.push wd
        args.push "&&"
      if outdir?
        args.push "mkdir"
        args.push "-p"
        args.push path.dirname outdir
        args.push "&&"
      args.push "unzip"
      args.push "-o"
      if outdir?
        args.push "-d"
        args.push outdir
      args.push zipfile
      args = args.map (p)->StringUtil.escape_for_bash(p)
      cmd = args.join ' '
      # console.log cmd
      shell.exec cmd, {silent:true}, (exit_code,output)=>
        err = null
        if exit_code isnt 0
          err = new Error("Non-zero exit code (#{exit_code}) encountered for \"#{cmd}\". Output: #{output}")
        callback(err,exit_code,output)

  @contents:(zipfile,callback)=>
    args = []
    args.push "unzip"
    args.push "-Z1"
    args.push zipfile
    args = args.map (p)->StringUtil.escape_for_bash(p)
    cmd = args.join ' '
    # console.log cmd
    shell.exec cmd, {silent:true}, (exit_code,output)=>
      if exit_code isnt 0
        callback new Error("Non-zero exit code (#{exit_code}) encountered for \"#{cmd}\". Output: #{output}")
      else
        contents = output?.trim().split("\n")
        callback null, contents

exports.ZipUtil = ZipUtil

if require.main is module
  if process.argv.length < 3 or (not (process.argv[2] in ['zip','unzip','ls']))
    console.log "USE: #{path.basename process.argv[0]} #{path.basename process.argv[1]} zip   <WD> <ZIP-FILE> <INPUT[S]>"
    console.log " or: #{path.basename process.argv[0]} #{path.basename process.argv[1]} unzip <WD> <ZIP-FILE> <DEST>"
    console.log " or: #{path.basename process.argv[0]} #{path.basename process.argv[1]} ls <ZIP-FILE>"
    process.exit 1
  else
    on_exit = (err,exit_code,output)=>
      if err?
        console.error "ERROR: ", err
        if output?
          console.error output
      else if output?
        console.log output
      process.exit exit_code
    if process.argv[2] is 'zip'
      ZipUtil.zip process.argv[3], [process.argv[5...]], process.argv[4], on_exit
    else if process.argv[2] is 'unzip'
      ZipUtil.unzip process.argv[3], process.argv[4], process.argv[5], on_exit
    else if process.argv[2] is 'ls'
      ZipUtil.contents process.argv[3], (err, list)=>
        if err?
          console.error "ERROR: ", err
          process.exit 1
        else
          console.log list.join("\n")
