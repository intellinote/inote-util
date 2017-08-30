fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
ResolveIP = require(path.join(LIB_DIR,'dns-round-robin')).DNSUtil
assert =  require('assert')

describe 'ResolveIP',->

  it "throw an error on invalid domain", (done)->
    ResolveIP.resolve_ip 'itunesssssss.com', (err, res)->
      assert err.code is 'ENOTFOUND'
      done()

  #this is a brittle test - since the host address for itunes
  #can change any time
  it "ensure that itunes resolves as desired", (done)->
    ResolveIP.resolve_ip 'itunes.com', (err,res)->
      ips = ['17.172.224.35', '17.178.96.29', '17.142.160.29']
      console.log res
      assert.equal res in ips, true, 'address mismatch'
      done()
