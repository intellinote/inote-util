should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
NetUtil   = require(path.join(LIB_DIR,'net-util')).NetUtil

describe 'NetUtil',->

  it "can get the current pid",(done)=>
    (typeof NetUtil.get_pid()).should.equal "number"
    done()

  it "can get a random port in the given range",(done)=>
    port = NetUtil.random_port(2000,100)
    port.should.not.be.below 2000
    port.should.not.be.above 2100
    done()

  it "can get an unused port",(done)=>
    port = NetUtil.get_unused_port()
    (typeof port).should.equal "number"
    NetUtil.is_port_in_use port, (err, in_use)=>
      should.not.exist err
      in_use.should.equal false
      done()
    port.should.not.be.below 2000
