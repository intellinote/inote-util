require 'coffee-errors'
#------------------------------------------------------------------------------#
fs       = require 'fs'
path     = require 'path'
HOME_DIR = path.join(__dirname, '..')
LIB_COV  = path.join(HOME_DIR, 'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR, 'lib')
#------------------------------------------------------------------------------#
assert   = require 'assert'
#------------------------------------------------------------------------------#
SimpleCache = require(path.join(LIB_DIR, 'simple-cache')).SimpleCache
AsyncUtil = require(path.join(LIB_DIR, 'async-util')).AsyncUtil
#------------------------------------------------------------------------------#
SHORT_TTL = 50

describe 'SimpleCache', ()->

  it "can store, retrieve and clear entries", (done)->
    cache = new SimpleCache()
    assert.ok not cache.get("key-foo")?
    assert.ok not cache.contains("key-foo")
    assert.ok not cache.get("key-bar")?
    assert.ok not cache.contains("key-bar")
    cache.put("key-foo","value-foo")
    cache.put("key-bar","value-bar")
    assert.equal "value-foo", cache.get("key-foo")
    assert.ok cache.contains("key-foo")
    assert.equal "value-bar", cache.get("key-bar")
    assert.ok cache.contains("key-bar")
    assert.equal "value-foo", cache.get_put("key-foo","new-value-foo")
    assert.equal "new-value-foo", cache.get("key-foo")
    assert.ok cache.contains("key-foo")
    assert.ok "key-foo" in cache.keys()
    assert.ok "key-bar" in cache.keys()
    assert.ok "new-value-foo" in cache.values()
    assert.ok "value-bar" in cache.values()
    pairs = cache.pairs()
    assert.equal pairs?.length, 2
    if pairs[0]?[0] is "key-foo"
      assert.deepEqual pairs, [["key-foo","new-value-foo"], ["key-bar", "value-bar"]]
    else
      assert.deepEqual pairs, [["key-bar","value-bar"], ["key-foo", "new-value-foo"]]
    assert.equal "new-value-foo", cache.get_clear("key-foo")
    assert.ok not cache.get("key-foo")?
    assert.ok not cache.contains("key-foo")
    assert.equal "value-bar", cache.get("key-bar")
    cache.clear_matching(/foo/)
    assert.equal "value-bar", cache.get("key-bar")
    cache.clear_matching(/bar/)
    assert.ok not cache.get("key-bar")?
    done()

  it "doesn't return expired entries unless asked to", (done)->
    cache = new SimpleCache(ttl:SHORT_TTL)
    assert.ok not cache.get("key-foo")?
    assert.ok not cache.contains("key-foo")
    assert.ok not cache.get("key-bar")?
    assert.ok not cache.contains("key-bar")
    cache.put("key-foo","value-foo")
    cache.put("key-bar","value-bar")
    assert.equal "value-foo", cache.get("key-foo")
    assert.ok cache.contains("key-foo")
    assert.equal "value-bar", cache.get("key-bar")
    assert.ok cache.contains("key-bar")
    process.nextTick ()->
      AsyncUtil.wait SHORT_TTL+5, ()->
        process.nextTick ()->
          assert.equal "value-foo", cache.get("key-foo", ignore_ttl:true)
          assert.ok cache.contains("key-foo", ignore_ttl:true)
          assert.equal "value-bar", cache.get("key-bar", ignore_ttl:true)
          assert.ok cache.contains("key-bar", ignore_ttl:true)
          assert.ok not cache.get("key-foo")?
          assert.ok not cache.contains("key-foo")
          assert.ok not cache.get("key-bar")?
          assert.ok not cache.contains("key-bar")
          done()


  it "can automatically purge expired entries", (done)->
    cache = new SimpleCache(ttl:SHORT_TTL, purge_interval: SHORT_TTL/2)
    assert.ok cache.purge_worker?
    assert.ok not cache.get("key-foo")?
    assert.ok not cache.contains("key-foo")
    assert.ok not cache.get("key-bar")?
    assert.ok not cache.contains("key-bar")
    cache.put("key-foo","value-foo")
    cache.put("key-bar","value-bar")
    assert.equal "value-foo", cache.get("key-foo")
    assert.ok cache.contains("key-foo")
    assert.equal "value-bar", cache.get("key-bar")
    assert.ok cache.contains("key-bar")
    process.nextTick ()->
      AsyncUtil.wait 2*SHORT_TTL+5, ()->
        process.nextTick ()->
          # unlike the previous case values are missing even ignore_ttl is true
          assert.ok not cache.get("key-foo", ignore_ttl:true)?
          assert.ok not cache.contains("key-foo", ignore_ttl:true)
          assert.ok not cache.get("key-bar", ignore_ttl:true)?
          assert.ok not cache.contains("key-bar", ignore_ttl:true)
          assert.ok not cache.get("key-foo")?
          assert.ok not cache.contains("key-foo")
          assert.ok not cache.get("key-bar")?
          assert.ok not cache.contains("key-bar")
          done()
