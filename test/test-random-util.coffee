require 'coffee-errors'
#------------------------------------------------------------------------------#
fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
#------------------------------------------------------------------------------#
assert     = require 'assert'
should     = require 'should'
#------------------------------------------------------------------------------#
RandomUtil = require(path.join(LIB_DIR,'index')).RandomUtil

describe 'RandomUtil',->

  it "RandomUtil.shuffle can perform an in-place shuffle of an array",(done)->
    tests = [
      null,
      "foo"
      { a:1 }
      [ ]
      [ 1 ]
      [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
      [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]
      [ 1...52 ]
      [ 1...1000 ]
    ]
    for test in tests
      if Array.isArray(test)
        shuffled = RandomUtil.shuffle([].concat(test))
      else
        shuffled = RandomUtil.shuffle(test)
      if test? and Array.isArray(test)
        if test?.length > 1
          assert.notDeepEqual test, shuffled # this test may actually fail once in a while since the original array is a valid shuffling
        assert.deepEqual test.sort(), shuffled.sort()
      else
        assert.equal test, shuffled
    done()

  it "random_bytes returns random bytes in the specified encoding",(done)->
    byte_count = 25
    hex = RandomUtil.random_bytes(byte_count,'hex')
    (/^[0-9a-f]+$/.test hex).should.be.ok
    hex.length.should.equal 2*byte_count
    done()

  it "random_bytes(n,'buffer') returns a buffer rather than a string ",(done)->
    byte_count = 25
    bytes = RandomUtil.random_bytes(byte_count,'buffer')
    bytes.length.should.equal byte_count
    done()

  it "random_bytes(enc,count) also works",(done)->
    hex = RandomUtil.random_bytes('hex')
    (/^[0-9a-f]+$/.test hex).should.be.ok
    hex = RandomUtil.random_bytes(20,'hex')
    hex.length.should.equal 40
    (/^[0-9a-f]+$/.test hex).should.be.ok
    hex = RandomUtil.random_bytes('hex',20)
    hex.length.should.equal 40
    (/^[0-9a-f]+$/.test hex).should.be.ok
    done()

  it "random_hex returns random hex digits",(done)->
    hex = RandomUtil.random_hex(63)
    hex.length.should.equal 63
    (/^[0-9a-f]+$/.test hex).should.be.ok
    done()

  it "random_Alphanumeric returns base-62 values",(done)->
    for c in [0,1,3,117]
      str = RandomUtil.random_Alphanumeric(c)
      (/^[0-9a-zA-Z]*$/.test str).should.be.ok
      str.length.should.equal c
    long = RandomUtil.random_Alphanumeric(300)
    (/[0-9]/.test(long)).should.equal true
    (/[a-z]/.test(long)).should.equal true
    (/[A-Z]/.test(long)).should.equal true
    done()

  it "random_string returns characters from the specified alphabet",(done)->
    for c in [0,1,3,117]
      str = RandomUtil.random_string("aeiouyAEIOUY357",c)
      (/^[aeiouyAEUIOY357]*$/.test str).should.be.ok
      str.length.should.equal c
    done()

  it "random_string has smart default parameters",(done)->
    for c in [0,1,3,117]
      #
      count_only = RandomUtil.random_string(c)
      (/^[0-9a-zA-Z]*$/.test count_only).should.be.ok
      count_only.length.should.equal c
      #
      alphabet_only = RandomUtil.random_string("aeiou")
      (/^[aeiou]*$/.test alphabet_only).should.be.ok
      alphabet_only.length.should.equal 32
      #
      rng_only = RandomUtil.random_string(RandomUtil.seed_rng("xyzzy"))
      (/^[0-9a-zA-Z]*$/.test rng_only).should.be.ok
      rng_only.length.should.equal 32
      #
      alphabet_and_count = RandomUtil.random_string("aeiou",c)
      (/^[aeiou]*$/.test alphabet_and_count).should.be.ok
      alphabet_and_count.length.should.equal c
      #
      alphabet_and_rng = RandomUtil.random_string("aeiou",RandomUtil.seed_rng("xyzzy"))
      (/^[aeiou]*$/.test alphabet_and_rng).should.be.ok
      alphabet_and_rng.length.should.equal 32
      #
      count_and_rng = RandomUtil.random_string(c,RandomUtil.seed_rng("xyzzy"))
      (/^[0-9a-zA-Z]*$/.test count_and_rng).should.be.ok
      count_and_rng.length.should.equal c
      #
      alphabet_count_and_rng = RandomUtil.random_string("aeiou",c,RandomUtil.seed_rng("xyzzy"))
      (/^[aeiou]*$/.test alphabet_count_and_rng).should.be.ok
      alphabet_count_and_rng.length.should.equal c
    done()

  it "random_alphanumeric returns base-36 values",(done)->
    for c in [0,1,3,117]
      str = RandomUtil.random_alphanumeric(c)
      (/^[0-9a-z]*$/.test str).should.be.ok
      str.length.should.equal c
    done()

  it "random_alphanumeric returns base-36 values (seed_rng case)",(done)->
    Util.set_rng(RandomUtil.seed_rng("hello."))
    for c in [0,1,3,117]
      str = RandomUtil.random_alphanumeric(c)
      (/^[0-9a-z]*$/.test str).should.be.ok
      str.length.should.equal c
    RandomUtil.set_rng()
    done()

  it "random_numeric returns random decimal digits",(done)->
    digits = RandomUtil.random_numeric(63)
    digits.length.should.equal 63
    (/^[0-9]+$/.test digits).should.be.ok
    done()

  it "random_ALPHA returns random UPPERCASE letters",(done)->
    letters = RandomUtil.random_ALPHA(63)
    letters.length.should.equal 63
    (/^[A-Z]+$/.test letters).should.be.ok
    done()

  it "random_alpha returns random lowercase letters",(done)->
    letters = RandomUtil.random_alpha(63)
    letters.length.should.equal 63
    (/^[a-z]+$/.test letters).should.be.ok
    done()

  it "random_Alpha returns random Mixed-Case letters",(done)->
    letters = RandomUtil.random_Alpha(630)
    letters.length.should.equal 630
    (/^[a-zA-Z]+$/.test letters).should.be.ok
    (/[a-z]/.test letters).should.be.ok # it is unlikely that there are no lowercase letters
    (/[A-Z]/.test letters).should.be.ok # it is unlikely that there are no uppercase letters
    done()

  it "random_element returns a random element of an array",(done)->
    a = [0...10]
    for i in [0...20]
      e = RandomUtil.random_element(a)
      (e in a).should.be.ok
    done()

  it "random_element returns a random pair from a map",(done)->
    m = {
      a:"A"
      b:"B"
      c:"C"
      d:"D"
      e:"E"
      f:"F"
      g:"G"
    }
    for i in [0...20]
      [k,v] = RandomUtil.random_element(m)
      (k in Object.keys(m)).should.be.ok
      v.should.equal(k.toUpperCase())
    done()


  it "random_element handles nulls and empty collections sensibly",(done)->
    tests = [
      [null,undefined]
      [undefined,undefined]
      [[],undefined]
      [{},undefined]
      ["foobar",undefined]
    ]
    for t in tests
      found = RandomUtil.random_element(t[0])
      (found is t[1]).should.be.ok
    done()

  it "random_alphanumeric passes a rough test of randomness",(done)->
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(RandomUtil.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.6
        done()

  it "random_alphanumeric passes a rough test of randomness (seed_rng case)",(done)->
    RandomUtil.set_rng(RandomUtil.seed_rng("hello."))
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(RandomUtil.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.65
        done()

  it "random_alphanumeric passes a rough test of randomness (seed_rng case)",(done)->
    RandomUtil.set_rng(RandomUtil.seed_rng("hello."))
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(RandomUtil.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.65
        done()

  it "random_alphanumeric passes a rough test of randomness (seed_rng case 2)",(done)->
    RandomUtil.set_rng(RandomUtil.seed_rng("goodbye."))
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(RandomUtil.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.65
        done()

  it "seed_random ensures we get the same values for the same seed",(done)->
    rng1 = RandomUtil.seed_rng(1234567)
    rng2 = RandomUtil.seed_rng(1234567)
    rng3 = RandomUtil.seed_rng(168)
    rng4 = RandomUtil.seed_rng(168)
    old1 = old3 = ""
    for i in [0..1000]
      str1 = RandomUtil.random_alphanumeric(64,rng1)
      str2 = RandomUtil.random_alphanumeric(64,rng2)
      str3 = RandomUtil.random_alphanumeric(64,rng3)
      str4 = RandomUtil.random_alphanumeric(64,rng4)
      str1.should.equal str2
      str2.should.not.equal str3
      str3.should.equal str4
      str1.should.not.equal old1
      str3.should.not.equal old3
      old1 = str1
      old3 = str3
    done()
