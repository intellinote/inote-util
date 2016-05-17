should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
LogUtil  = require( path.join( LIB_DIR, "log-util")).LogUtil

CONSOLE_LOG = console.log
CONSOLE_ERR = console.error

restore_console = ()->
  console.log = CONSOLE_LOG
  console.error = CONSOLE_ERR

describe 'LogUtil',=>

  afterEach (done)=>
    restore_console()
    done()

  it 'can log to stdout with a timestamp', (done)=>
    log = []
    console.log = (args...)->log.push args
    LogUtil.tlog "This is a message for stdout.", 1, 2, 3
    restore_console()
    log.length.should.equal 1
    log[0].length.should.equal 5
    log[0][0].should.match /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.*\]$/
    log[0][1].should.equal "This is a message for stdout."
    log[0][2].should.equal 1
    log[0][3].should.equal 2
    log[0][4].should.equal 3
    done()

  it 'can log to stderr with a timestamp', (done)=>
    err  = []
    console.error = (args...)->err.push args
    LogUtil.terr "This is a message for stderr.", 1, 2, 3
    restore_console()
    err.length.should.equal 1
    err[0].length.should.equal 5
    err[0][0].should.match /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.*\]$/
    err[0][1].should.equal "This is a message for stderr."
    err[0][2].should.equal 1
    err[0][3].should.equal 2
    err[0][4].should.equal 3
    done()
