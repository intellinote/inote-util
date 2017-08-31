assert   = require 'assert'
should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOME_DIR = path.join(__dirname,'..')
LIB_COV  = path.join(HOME_DIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
NetUtil  = require(path.join(LIB_DIR,'net-util')).NetUtil
URL      = require 'url'

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

  it "calls-back with an error if the hostname does not resolve", (done)=>
    NetUtil.resolve_hostname 'https://itunesssssss.com', (err, res)=>
      assert err.code is 'ENOTFOUND'
      assert not res?
      done()

  # this is a brittle test - since the host address for itunes can change any time
  it "ensure that itunes resolves as desired", (done)=>
    ips = ['17.172.224.35', '17.178.96.29', '17.142.160.29']
    NetUtil.resolve_hostname 'https://itunes.com', (err,res)=>
      assert not err?
      parsed_url = URL.parse res
      assert.equal parsed_url.hostname in ips, true, 'address mismatch'
      done()
  
  it "ensure that host name is returned back if the domain resolves to only one ip", (done)=>
    NetUtil.resolve_hostname 'https://google.com', (err,res)=>
      assert not err?
      assert res is 'https://google.com'
      done()