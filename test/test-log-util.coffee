should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
LogUtil  = require( path.join( LIB_DIR, "log-util")).LogUtil

LOGGER = { }
LOGGER.LOG = []
LOGGER.ERR = []
LOGGER.log = (args...)->LOGGER.LOG.push(args)
LOGGER.err = (args...)->LOGGER.ERR.push(args)
LOGUTIL = LogUtil.init(logger:LOGGER)

describe 'LogUtil',->

  beforeEach (done)->
    done()

  afterEach (done)->
    LOGGER.LOG = []
    LOGGER.ERR = []
    done()

  it 'can log to stdout with a timestamp', (done)->
    LOGUTIL.tlog "This is a message for stdout.", 1, 2, 3
    LOGGER.LOG.length.should.equal 1
    LOGGER.LOG[0].length.should.equal 5
    LOGGER.LOG[0][0].should.match /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.*\]$/
    LOGGER.LOG[0][1].should.equal "This is a message for stdout."
    LOGGER.LOG[0][2].should.equal 1
    LOGGER.LOG[0][3].should.equal 2
    LOGGER.LOG[0][4].should.equal 3
    done()

  it 'can log to stderr with a timestamp', (done)=>
    LOGUTIL.terr "This is a message for stderr.", 1, 2, 3
    LOGGER.ERR.length.should.equal 1
    LOGGER.ERR[0].length.should.equal 5
    LOGGER.ERR[0][0].should.match /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.*\]$/
    LOGGER.ERR[0][1].should.equal "This is a message for stderr."
    LOGGER.ERR[0][2].should.equal 1
    LOGGER.ERR[0][3].should.equal 2
    LOGGER.ERR[0][4].should.equal 3
    done()

  it 'can log to stdout with a timestamp and pid', (done)=>
    LOGUTIL.tplog "This is a message for stdout.", 1, 2, 3
    LOGGER.LOG.length.should.equal 1
    LOGGER.LOG[0].length.should.equal 6
    LOGGER.LOG[0][0].should.match /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.*\]$/
    LOGGER.LOG[0][1].should.match /^\[p:[0-9]+\]$/
    LOGGER.LOG[0][2].should.equal "This is a message for stdout."
    LOGGER.LOG[0][3].should.equal 1
    LOGGER.LOG[0][4].should.equal 2
    LOGGER.LOG[0][5].should.equal 3
    done()

  it 'can log to stderr with a timestamp and pid', (done)=>
    LOGUTIL.tperr "This is a message for stderr.", 1, 2, 3
    LOGGER.ERR.length.should.equal 1
    LOGGER.ERR[0].length.should.equal 6
    LOGGER.ERR[0][0].should.match /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.*\]$/
    LOGGER.ERR[0][1].should.match /^\[p:[0-9]+\]$/
    LOGGER.ERR[0][2].should.equal "This is a message for stderr."
    LOGGER.ERR[0][3].should.equal 1
    LOGGER.ERR[0][4].should.equal 2
    LOGGER.ERR[0][5].should.equal 3
    done()
