require 'coffee-errors'
#------------------------------------------------------------------------------#
should    = require 'should'
fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join __dirname, '..'
LIB_COV   = path.join HOMEDIR, 'lib-cov'
LIB       = path.join HOMEDIR, 'lib'
LIB_DIR   = if fs.existsSync(LIB_COV) then LIB_COV else LIB
index     = require(path.join(LIB_DIR,'index'))

describe "index",->

  it "exports Util and Sequencer", (done)->
    index.Util.should.exist
    index.Sequencer.should.exist
    done()

  it "exports SimpleCache", (done)->
    index.SimpleCache.should.exist
    done()

  it "exports Stopwatch", (done)->
    index.Stopwatch.should.exist
    done()

  it "exports config", (done)->
    index.config.should.exist
    done()

  it "exports IOUtil", (done)->
    index.IOUtil.should.exist
    done()

  it "exports WorkQueue", (done)->
    index.WorkQueue.should.exist
    done()

  it "exports StringUtil", (done)->
    index.StringUtil.should.exist
    done()

  it "exports ZipUtil", (done)->
    index.ZipUtil.should.exist
    done()

  it "exports LogUtil", (done)->
    index.LogUtil.should.exist
    index.LogUtil.init.should.exist
    index.LogUtil.LogUtil.should.exist
    done()

  it "exports FileLogger", (done)->
    index.FileLogger.should.exist
    done()

  it "exports AsyncUtil", (done)->
    index.AsyncUtil.should.exist
    index.Sequencer.should.exist
    index.Util.for_each_async.should.exist
    index.Util.procedure.should.exist
    done()

  it "exports S3Model", (done)->
    index.S3Model.should.exist
    done()

  it "exports L10nUtil", (done)->
    index.L10nUtil.should.exist
    done()

  it "exports TimeoutError", (done)->
    index.TimeoutError.should.exist
    done()

  it "exports ExceptionThrownError", (done)->
    index.ExceptionThrownError.should.exist
    done()
