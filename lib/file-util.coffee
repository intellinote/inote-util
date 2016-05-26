fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
DATA       = path.join HOMEDIR, "data"
Util       = require(path.join(LIB_DIR,'util')).Util
mkdirp     = require 'mkdirp'
remove     = require 'remove'
DEBUG      = (/(^|,)file-?util($|,)/i.test process?.env?.NODE_DEBUG)
mmmagic    = require('mmmagic')
magic      = new mmmagic.Magic(mmmagic.MAGIC_MIME_TYPE)

class FileUtil

  # `callback(null,true)` if `file` identifies an existing file (not directory)
  @is_file:(file,callback)=>
    fs.stat file, (err,stat)=>
      if err? and err.code is 'ENOENT'
        callback(null,false)
      else
        callback err, ((stat?.isFile?()) ? false)

  # `callback(null,true)` if `file` identifies an existing directory
  @is_dir:(file,callback)=>
    fs.stat file, (err,stat)=>
      if err? and err.code is 'ENOENT'
        callback(null,false)
      else
        callback err, ((stat?.isDirectory?()) ? false)

  # `callback(null,true)` if `file` identifies an existing directory
  @is_directory:(file,callback)=>
    @is_dir(file,callback)

  # internal utility: `callback(null,true)` if `file` matches the regular
  # expression `pattern` (if any) and is one of the specified `types` (if any).
  # * `file` - a string presenting a filename
  # * `pattern` - a regular expression
  # * `types` - either a string or array of strings, containing `file` or `directory`
  @_file_matches:(dir,file,pattern,types,callback)=>
    if typeof pattern is 'function' and not types? and not callback?
      callback = pattern
      pattern = null
    else if typeof types is 'function' and not callback?
      callback = types
      types = null
    if types? and typeof types is 'string'
      types = [types]
    if pattern? and not pattern.test(file)
      callback null, false
    else if types?
      full_path = path.join(dir,file)
      fs.stat full_path, (err,stat)=>
        if err? and err.code is 'ENOENT'
          callback null, false
        else if err?
          callback err
        else
          if stat.isFile() and ("file" in types)
            callback null, true
          else if stat.isDirectory() and (("dir" in types) or ("directory" in types))
            callback null, true
          else
            callback null, false
    else
      callback null, true

  @ls:(dir, options, callback)=>
    if typeof options is 'function' and not callback?
      callback = options
      options = null
    options ?= {}
    recurse = Util.truthy_string(options.recurse ? false)
    pattern = options.pattern
    types   = options.types ? options.type
    fs.readdir dir, (err,files)=>
      if err? or not files?
        callback(null,null)
      else
        found = []
        # find matching files
        action = (file, index, list, next)=>
          @_file_matches dir, file, pattern, types, (err, matched)=>
            if err?
              callback(err)
            else if matched
              found.push path.join(dir,file)
              next()
            else
              next()
        Util.for_each_async files, action, ()=>
          # recurse if needed
          unless recurse
            callback null, found
          else
            action = (file, index, list, next)=>
              full_file = path.join(dir,file)
              @is_dir full_file, (err,is_dir)=>
                if err?
                  callback(err)
                else
                  if is_dir
                    @ls full_file, options, (err,files_in_dir)=>
                      if err?
                        callback(err)
                      else
                        if files_in_dir?
                          found = found.concat(files_in_dir)
                        next()
                  else
                    next()
            Util.for_each_async files, action, ()=>
              callback null, found

  # Replaces invalid characters from and truncates very long filenames.
  # This method will accept (and return) a full path but will only operate on the "basename".
  @sanitize_filename:(str)=>
    BAD_CHARS = /[^-A-Za-z0-9_]/g
    SUBST_CHAR = '-'
    MAX_EXTENSION = 260
    MAX_BASENAME  = 260
    parent = path.dirname(str) ? ''
    ext = path.extname(str) ? ''
    base = path.basename(str,ext) ? ''
    if /^\..+/.test ext
      ext = "."+ext.substring(1).replace(BAD_CHARS,SUBST_CHAR)
    if ext?.length > MAX_EXTENSION
      ext = ext.substring(0,MAX_EXTENSION)
    base = base.replace(BAD_CHARS,SUBST_CHAR)
    if base?.length > MAX_BASENAME
      base = base.substring(0,MAX_BASENAME)
    if parent?.length > 0
      return path.join(parent,"#{base}#{ext}")
    else
      return "#{base}#{ext}"

  @uniquify_filename:(dir,basename,ext='',minpadwidth=3,maxpadwidth=5)=>
    max_attempts = Math.pow(10,maxpadwidth)
    unless fs.existsSync(path.join(dir,"#{basename}#{ext}"))
      return "#{basename}#{ext}"
    else
      i = 1
      while fs.existsSync(path.join(dir,"#{basename}-#{Util.lpad(i,minpadwidth,'0')}#{ext}"))
        if i > max_attempts
          throw new Error("Unable to obtain a unique filename for \"#{basename}#{ext}\" in \"#{dir}\" after #{max_attempts} attempts.")
        else
          i += 1
      return "#{basename}-#{Util.lpad(i,minpadwidth,'0')}#{ext}"

  # Attempts to recursively create the specified directory, ignoring errors.
  # Set `NODE_DEBUG=inote-util` to view errors.
  # Returns `true` if no errors encountered, `false` otherwise
  @mkdir:(dir)=>
    if dir?
      try
        mkdirp.sync(dir)
        return true
      catch e
        if DEBUG
          console.error "FileUtil.mkdir",e
        return false
    else
      return false

  # Attempts to remove the specified file, ignoring errors.
  # Set `NODE_DEBUG=inote-util` to view errors.
  # Returns `true` if no errors encountered, `false` otherwise
  @rm:(files...)=>
    result = false
    if files? and files.length > 0
      result = true
      for file in files
        try
          fs.unlinkSync(file)
        catch e
          result = false
          if DEBUG
            console.error "FileUtil.rm",e
    return result

  # Attempts to (recursively) remove the specified directory(s) or file(s), ignoring errors.
  # Set `NODE_DEBUG=inote-util` to view errors.
  # Returns `true` if no errors encountered, `false` otherwise
  @rmdir:(dirs...)=>
    result = false
    if dirs? and dirs.length > 0
      result = true
      for dir in dirs
        try
          remove.removeSync(dir)
        catch e
          result = false
          if DEBUG
            console.error "FileUtil.rmdir",e
    return result

  @read_stdin_sync:(end_byte="\x04",buffer_size=512)->
    read_buf = new Buffer(buffer_size)
    bytes_read = 0
    all_buf = new Buffer(buffer_size)
    all_bytes_read = 0
    end_byte_read = false
    fd = process?.stdin?.fd
    unless fd?
      throw new Error("Unable to obtain stdin.fd")
    else
      while true
        try
          bytes_read = fs.readSync fd, read_buf, 0, buffer_size, null
          temp_buf = new Buffer(all_bytes_read + bytes_read)
          all_buf.copy temp_buf, 0, 0, all_bytes_read
          read_buf.copy temp_buf, all_bytes_read, 0, bytes_read
          all_buf = temp_buf
          all_bytes_read += bytes_read
          for b in bytes_read
            if b is end_byte
              end_byte_read = true
              break
          if end_byte_read
            break
        catch err
          if err.code is 'EOF'
            break
          else
            throw err
        if bytes_read is 0
          break
      return all_buf

  @load_json_file_sync:(file,ignore_errors=false)->
    try
      return JSON.parse(fs.readFileSync(file).toString())
    catch err
      if ignore_errors
        return null
      else
        throw err

  @load_json_stdin_sync:(end_byte="\x04",buffer_size=512,ignore_errors=false)=>
    try
      return JSON.parse(@read_stdin_sync(end_byte,buffer_size))
    catch err
      if ignore_errors
        return null
      else
        throw err

  # naive version of the Unix `touch` command
  @touch:(file,callback)=>
    fs.open file, "wx", (err, fd)=>
      if fd?
        fs.close fd, (err)=>
          callback?()
      else
        callback?()

  # "manually" copy a file - works across platforms and filesystems
  # consider using shell.exec('cp ...') instead?
  @copy_file:(src,dest,callback)=>
    callback_called = false
    done = (err)=>
      unless callback_called
        callback_called = true
        callback(err)
    input = fs.createReadStream(src)
    input.on "error", (err)=>done(err)
    output = fs.createWriteStream(dest)
    output.on "error", (err)=>done(err)
    output.once "close", ()=>done()
    input.pipe(output)

  # "manually" rename a file - works across platforms and filesystems
  # consider using shell.exec('mv ...') instead?
  @move_file:(src,dest,callback)=>
    callback_called = false
    done = (err)=>
      unless callback_called
        callback_called = true
        callback(err)
    input = fs.createReadStream(src)
    input.on "error", (err)=>done(err)
    output = fs.createWriteStream(dest)
    output.on "error", (err)=>done(err)
    output.once "close", ()=>
      @rm(src)
      done()
    input.pipe(output)

  @file_age:(file,callback)=>
    @file_mtime file, (err, mtime)=>
      if err?
        callback err
      else unless mtime?
        callback null, null
      else
        callback null, Date.now() - mtime

  @file_mtime:(file,callback)=>
    fs.exists file, (exists)=>
      unless exists
        callback null, false
      else
        fs.stat file, (err,stats)=>
          if err?
            callback err
          else
            callback null, stats.mtime?.getTime?() ? stats.ctime?.getTime?()

  @file_age_sync:(file,callback)=>
    mtime = @file_mtime_sync(file)
    if mtime
      return Date.now() - mtime
    else
      return mtime

  @file_mtime_sync:(file)=>
    unless fs.existsSync file
      return false
    else
      stat = fs.statSync file
      return stat.mtime?.getTime?() ? stat.ctime?.getTime?()

  @replace_extension:(filename,ext)=>
    if ext? and not /^\./.test ext
      ext = ".#{ext}"
    new_filename = @strip_extension(filename)
    if ext?
      new_filename = "#{new_filename}#{ext}"
    return new_filename
  @replace_ext:(filename,ext)=>@replace_extension(filename,ext)

  @strip_extension:(filename)=>
    if filename?
      dir = path.dirname(filename)
      file = path.basename(filename)
      ext = path.extname(file)
      if ext? and ext.length > 0
        file = file.substring(0, file.length - ext.length)
      return path.join(dir,file)
    else
      return filename
  @strip_ext:(filename)=>@strip_extension(filename)

  @get_extension:(filename)=>
    ext = Util.blank_to_null(path.extname(filename)) ? filename
    if /^\./.test ext
      ext = ext.substring(1,ext.length)
    return ext
  @get_ext:(filename)=>@get_extension(filename)



  @_rank_mime:(mime)=>
    unless mime?
      return 0
    else if mime is "application/unknown"
      return 10
    else if mime is "application/octet-stream"
      return 20
    else if mime in ["text/text","image/image","audio/audio","video/video","application/application"]
      return 30
    else if mime in ["text/plain",]
      return 40
    else if mime in ["text/html","text/xml"]
      return 100
    else
      return 99999

  @_choose_mime:(mime_a,mime_b)=>
    norm_a = @_normalize_mime(mime_a)
    norm_b = @_normalize_mime(mime_b)
    rank_a = @_rank_mime(norm_a)
    rank_b = @_rank_mime(norm_b)
    if rank_a > rank_b
      return mime_a
    else if rank_b > rank_a
      return mime_b
    else # rank_a == rank_b
      # try un-normed
      rank_a = @_rank_mime(mime_a)
      rank_b = @_rank_mime(mime_b)
      if rank_a >= rank_b
        return mime_a
      else
        return mime_b

  # callback:(err, mime-type)
  @get_mime:(filename, callback)=>
    @get_mime_via_magic filename, (err, by_magic)=>
      by_ext = @get_mime_for_ext(filename)
      callback err, @_choose_mime(by_magic, by_ext)
  @get_mime_type:(filename,callback)=>@get_mime(filename,callback)
  @get_file_mime_type:(filename,callback)=>@get_mime(filename,callback)

  @get_mime_via_magic:(filename, callback)=>
    magic.detectFile(filename,callback)
  @get_mime_type_via_magic:(filename,callback)=>@get_mime_via_magic(filename,callback)
  @get_file_mime_type_via_magic:(filename,callback)=>@get_mime_via_magic(filename,callback)

  # callback:(err, is_pdf)
  @is_pdf:(filename, callback)=>@file_is_pdf(filename,callback)

  # callback:(err, is_pdf)
  @file_is_pdf:(filename, callback)=>@file_is_mime(filename,/^application\/pdf/i,callback)

  # callback:(err, is_mime_type)
  @is_mime:(filename, mime_pattern, callback)=>
    @file_is_mime(filename, mime_pattern, callback)

  # callback:(err, is_mime_type)
  @file_is_mime:(filename, mime_pattern, callback)=>
    @get_mime filename, (err,mime)=>
      if err?
        callback(err)
      else
        if typeof mime_pattern is 'string'
          callback null, (mime is mime_pattern)
        else
          callback null, (mime_pattern.test(mime))

  @_normalize_ext:(ext)=>
    if ext?
      if /^\./.test ext        # strip the leading `.` if any
        ext = ext.substring(1)
      ext = ext?.toLowerCase() # downcase
    return ext

  @_normalize_mime:(mime)=>
    if mime?
      # strip the encoding info if any (`application/json; charset=utf-8` => `application/json`)
      match = mime.match /^\s*([^\/\s]+\/[^\s;\/]+)\s*(;.*)?$/
      if match?[1]?
        mime = match[1]
      mime = mime?.toLowerCase() # downcase
    return mime

  # returns the MIME type associated with the given filename or extension
  # ("associated" in @_ext_to_mime map)
  @get_mime_for_ext:(ext)=>
    ext = @get_extension(ext)
    return @get_ext_to_mime_map()[ext] ? @get_ext_to_mime_map()[@_normalize_ext(ext)]
  @get_mime_for_extension:(ext)=>@get_mime_for_ext(ext)

  # returns the file extension (no leading `.`)  associated with the given MIME type
  # ("associated" in @_mime_to_ext_map)
  @get_ext_for_mime:(mime)=>
    return @get_mime_to_ext_map()[mime] ? @get_mime_to_ext_map()[@_normalize_mime(mime)]
  @get_extension_for_mime:(mime)=>@get_ext_for_mime(mime)

  # mapping of file extensions to mime types
  @_ext_to_mime_map:null
  @_EXT_TO_MIME_MAP:null

  # mapping of mime types to file extensions
  @_mime_to_ext_map:null
  @_MIME_TO_EXT_MAP:null

  # get the currently active extension-to-mime mapping
  @get_ext_to_mime_map:()=>
    @_ext_to_mime_map ?= @_get_EXT_TO_MIME_MAP()
    return @_ext_to_mime_map
  @get_extension_to_mime_map:()=>@get_ext_to_mime_map()

  # get the currently active mime-to-extension mapping
  @get_mime_to_ext_map:()=>
    @_mime_to_ext_map ?= @_get_MIME_TO_EXT_MAP()
    return @_mime_to_ext_map
  @get_mime_to_extension_map:()=>@get_mime_to_ext_map()

  # set the currently active extension-to-mime mapping.
  # set to `null` to reset to default mapping
  @set_ext_to_mime_map:(mapping)=>
    @_ext_to_mime_map = mapping
  @set_extension_to_mime_map:(mapping)=>@set_ext_to_mime_map(mapping)

  # set the currently active mime-to-extension mapping
  # set to `null` to reset to default mapping
  @set_mime_to_ext_map:(mapping)=>
    @_mime_to_ext_map = mapping
  @set_mime_to_extension_map:()=>@set_mime_to_ext_map(mapping)

  # add to the currently active mime-to-extension mapping
  # accepts a pair of strings (mime,ext) or one or more maps
  @add_to_mime_to_ext_map:(mappings...)=>
    if mappings?.length is 2 and ((typeof mappings[0]) is 'string') and ((typeof mappings[1]) is 'string')
      pair = {}
      pair[mappings[0]] = mappings[1]
      mappings = [pair]
    @_mime_to_ext_map = Util.merge(@get_mime_to_ext_map(),mappings...)
  @add_to_mime_to_extension_map:(mappings...)=>@add_mime_to_ext_map(mappings...)

  # add to the currently active extension-to-mime mapping
  # accepts a pair of strings (ext,mime) or one or more maps
  @add_to_ext_to_mime_map:(mappings...)=>
    if mappings?.length is 2 and ((typeof mappings[0]) is 'string') and ((typeof mappings[1]) is 'string')
      pair = {}
      pair[mappings[0]] = mappings[1]
      mappings = [pair]
    @_ext_to_mime_map = Util.merge(@get_ext_to_mime_map(),mappings...)
  @add_to_extension_to_mime_map:(mappings...)=>@add_ext_to_mime_map(mappings...)

  # Lazily load the `ext-to-mime.json` file into the `_EXT_TO_MIME_MAP` map.
  @_get_EXT_TO_MIME_MAP:()=>
    unless @_EXT_TO_MIME_MAP?
      @_EXT_TO_MIME_MAP = JSON.parse(fs.readFileSync(path.join(DATA,"ext-to-mime.json")))
    return @_EXT_TO_MIME_MAP

  # Lazily load the `mime-to-ext.json` file into the `_MIME_TO_EXT_MAP` map.
  @_get_MIME_TO_EXT_MAP:()=>
    unless @_MIME_TO_EXT_MAP?
      @_MIME_TO_EXT_MAP = JSON.parse(fs.readFileSync(path.join(DATA,"mime-to-ext.json")))
    return @_MIME_TO_EXT_MAP


################################################################################

exports.FileUtil = FileUtil
