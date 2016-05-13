fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Util       = require(path.join(LIB_DIR,'util')).Util
mkdirp     = require 'mkdirp'
remove     = require 'remove'
DEBUG      = (/(^|,)file-?util($|,)/i.test process?.env?.NODE_DEBUG)

class FileUtil

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

################################################################################

exports.FileUtil = FileUtil
