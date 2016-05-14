should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
IOUtil   = require(path.join(LIB_DIR,'io-util')).IOUtil
FileUtil = require(path.join(LIB_DIR,'file-util')).FileUtil


describe 'IOUtil',->

  it "can download URL content to a buffer",(done)->
    IOUtil.download_to_buffer "https://www.intellinote.net/", (err,buffer)=>
      should.not.exist err
      should.exist buffer
      Buffer.isBuffer(buffer).should.be.ok
      buffer.length.should.not.be.below 1
      str = buffer.toString()
      str.should.match /<html/i
      done()

  it "can download URL content to a file",(done)->
    dest_file = path.join(HOMEDIR,'test','IOUTIL-TEST-FILE.TXT')
    IOUtil.download_to_file "https://www.intellinote.net/", dest_file, (err)=>
      should.not.exist err
      buffer = fs.readFileSync(dest_file)
      should.exist buffer
      buffer.length.should.not.be.below 1
      str = buffer.toString()
      str.should.match /<html/i
      FileUtil.rm dest_file
      done()

  it "can pipe stream content to a buffer",(done)->
    src_file = path.join(HOMEDIR,'test','test-io-util.coffee')
    in_stream = fs.createReadStream(src_file)
    IOUtil.pipe_to_buffer in_stream, (err,buffer)=>
      should.not.exist err
      should.exist buffer
      buffer.length.should.not.be.below 1
      str = buffer.toString()
      str.should.match /IOUtil/
      str.should.match /can pipe stream content to a buffer/
      done()

  it "can pipe stream content to a file",(done)->
    dest_file = path.join(HOMEDIR,'test','IOUTIL-TEST-FILE.TXT')
    src_file = path.join(HOMEDIR,'test','test-io-util.coffee')
    in_stream = fs.createReadStream(src_file)
    IOUtil.pipe_to_file in_stream, dest_file, (err)=>
      should.not.exist err
      buffer = fs.readFileSync(dest_file)
      should.exist buffer
      buffer.length.should.not.be.below 1
      str = buffer.toString()
      str.should.match /IOUtil/
      str.should.match /can pipe stream content to a file/
      FileUtil.rm dest_file
      done()
