require 'coffee-errors'
#------------------------------------------------------------------------------#
should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
IOUtil   = require(path.join(LIB_DIR,'io-util')).IOUtil
FileUtil = require(path.join(LIB_DIR,'file-util')).FileUtil
IMAGE_AS_DATA_URI = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAANcAAAAoCAYAAABtuW95AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2hpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDowMTgwMTE3NDA3MjA2ODExODA4M0Q2ODBDRUZCRDEwQiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpBMzlBRUJFQUJFQTQxMUUzQUZCM0Y5RDA5NzRERjZCMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpBMzlBRUJFOUJFQTQxMUUzQUZCM0Y5RDA5NzRERjZCMyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MDE4MDExNzQwNzIwNjgxMTgwODNENjgwQ0VGQkQxMEIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MDE4MDExNzQwNzIwNjgxMTgwODNENjgwQ0VGQkQxMEIiLz4gPC9yZGY6RGVzY3Jp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"

describe 'IOUtil',->

  # it "can download URL content to a buffer",(done)=>
  #   @timeout 5000
  #   IOUtil.download_to_buffer "https://www.intellinote.net/", (err,buffer)=>
  #     should.not.exist err
  #     should.exist buffer
  #     Buffer.isBuffer(buffer).should.be.ok
  #     buffer.length.should.not.be.below 1
  #     str = buffer.toString()
  #     str.should.match /<html/i
  #     done()

  # it "can download URL content to a file",(done)=>
  #   @timeout 5000
  #   dest_file = path.join(HOMEDIR,'test','IOUTIL-TEST-FILE.TXT')
  #   IOUtil.download_to_file "https://www.intellinote.net/", dest_file, (err)=>
  #     should.not.exist err
  #     buffer = fs.readFileSync(dest_file)
  #     should.exist buffer
  #     buffer.length.should.not.be.below 1
  #     str = buffer.toString()
  #     str.should.match /<html/i
  #     FileUtil.rm dest_file
  #     done()

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

  it "can download URL content to data URI",(done)->
    @timeout 5000
    IOUtil.download_to_data_uri "https://api.intellinote.net/rest/img/intellinote-logo.png", (err,uri)=>
      should.not.exist err
      should.exist uri
      uri.should.equal IMAGE_AS_DATA_URI
      done()
