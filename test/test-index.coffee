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

  it "exports Stopwatch", (done)->
    index.Stopwatch.should.exist
    done()

  it "exports config", (done)->
    index.config.should.exist
    done()
