require 'coffee-errors'
#------------------------------------------------------------------------------#
#coffeelint:disable=cyclomatic_complexity
fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Util       = require(path.join(LIB_DIR,'index')).Util
WebUtil    = require(path.join(LIB_DIR,'index')).WebUtil
RandomUtil = require(path.join(LIB_DIR,'index')).RandomUtil
ArrayUtil  = require(path.join(LIB_DIR,'index')).ArrayUtil
Stream     = require 'stream'
zipstream  = require 'zipstream'
assert     = require 'assert'
should     = require 'should'

describe 'Util',->

  it "can get_funky_json data",(done)->
    tests = [
      [ {foo:{bar:true}}, ["foo", "bar"],  true ]
      [ {foo:{bar:true}}, ["foox", "bar"],  undefined ]
      [ {foo:{bar:true}}, ["foo", "barx"],  undefined ]
      [ {foo:{bar:true}}, ["foo", "bar", "x"],  undefined ]
      [ {foo:{bar:"str"}}, ["foo", "bar"],  "str" ]
      [ {foo:{bar:{$:"str"}}}, ["foo", "bar"],  "str" ]
      [ {foo:{"@bar":"str"}}, ["foo", "bar"],  "str" ]
      [ {foo:{bar:true}}, ["foo"],  {bar:true} ]
      [ {foo:{bar:true}}, [],  {foo:{bar:true}} ]
    ]
    for test in tests
      json = test[0]
      path = test[1]
      expected = test[2]
      found = Util.get_funky_json(json, path...)
      assert.deepEqual found, expected
      found = Util.gfj(json, path...)
      assert.deepEqual found, expected
    done()

  it "can check semver ranges",(done)->
    tests = [
      [ "v0.10.33", ">=0.10.45", false ]
      [ "0.10.33",  ">=0.10.45", false ]
      [ "v0.10.45", ">=0.10.45", true  ]
      [ "0.10.45",  ">=0.10.45", true  ]
      [ "v4.4.4",   ">=0.10.45", true  ]
      [ "4.4.4",    ">=0.10.45", true  ]
      [ "v0.10.33", "0.10.33",   true  ]
      [ "0.10.33",  "0.10.33",   true  ]
    ]
    for test in tests
      found = Util.version_satisfies test[0], test[1]
      found.should.equal test[2]
    done()

  it "to_unit uses singular or plural as appropriate",(done)->
    tests = [
      [ -3, "singular", "plurals", "-3 plurals" ]
      [ -1, "singular", "plurals", "-1 singular" ]
      [ 0, "singular", "plurals", "0 plurals" ]
      [ 1, "singular", "plurals", "1 singular" ]
      [ 3, "singular", "plurals", "3 plurals" ]
      [ -3, "foo", null, "-3 foos" ]
      [ -1, "foo", null, "-1 foo" ]
      [ 0, "foo", null, "0 foos" ]
      [ 1, "foo", null, "1 foo" ]
      [ 3, "foo", null, "3 foos" ]
    ]
    for test in tests
      found = Util.to_unit(test[0...3]...)
      found.should.equal test[3]
    done()

  it "duration accepts times as Dates or millis",(done)->
    now = new Date()
    later = new Date(now.getTime() + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123)
    Util.duration(later,now).string.brief.short.should.equal "6h 2m 3s 123m"
    Util.duration(later.getTime(),now).string.brief.short.should.equal "6h 2m 3s 123m"
    Util.duration(later,now.getTime()).string.brief.short.should.equal "6h 2m 3s 123m"
    Util.duration(later.getTime(),now.getTime()).string.brief.short.should.equal "6h 2m 3s 123m"
    done()

  it "duration can parse a duration in various human-readable forms",(done)->
    tests = [
      [ 123, "123m" ]
      [ 3*1000 + 123, "3s 123m" ]
      [ 2*60*1000 + 3*1000 + 123, "2m 3s 123m" ]
      [ 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "6h 2m 3s 123m" ]
      [ 5*24*60*60*1000 + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "5d 6h 2m 3s 123m" ]
      [ 3*7*24*60*60*1000 + 5*24*60*60*1000 + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "3w 5d 6h 2m 3s 123m" ]
      [ 9*52*7*24*60*60*1000 + 3*7*24*60*60*1000 + 5*24*60*60*1000 + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "9y 3w 5d 6h 2m 3s 123m" ]
    ]
    for test in tests
      found = Util.duration(test[0],0)
      found.string.brief.short.should.equal test[1]
    tests = [
      [ 123, "123 milliseconds" ]
      [ 3*1000, "3 seconds" ]
      [ 1*60*1000, "1 minute" ]
      [ 6*60*60*1000, "6 hours" ]
      [ 5*24*60*60*1000, "5 days" ]
      [ 3*7*24*60*60*1000, "3 weeks" ]
      [ 9*52*7*24*60*60*1000, "9 years" ]
    ]
    for test in tests
      found = Util.duration(test[0],0)
      found.string.min.long.should.equal test[1]
    done()

  it "smart_join can join arrays in flexible ways",(done)->
    array = [ "Tom", "Dick", "Harry" ]
    (Util.smart_join(array)).should.equal "Tom,Dick,Harry"
    (Util.smart_join(array,{})).should.equal "Tom,Dick,Harry"
    (Util.smart_join(array, ", ")).should.equal "Tom, Dick, Harry"
    (Util.smart_join(array, {delimiter:", "})).should.equal "Tom, Dick, Harry"
    (Util.smart_join(array, ", ", " and ")).should.equal "Tom, Dick and Harry"
    (Util.smart_join(array, {delimiter:", ",last:" and "})).should.equal "Tom, Dick and Harry"
    (Util.smart_join(array, {delimiter:", ",first:" and "})).should.equal "Tom and Dick, Harry"
    (Util.smart_join(array, {delimiter:", ",first:" and ",last:" & "})).should.equal "Tom and Dick & Harry"
    (Util.smart_join(array, {delimiter:", ",before:"Every ",first:" and ",last:" & ",after:"."})).should.equal "Every Tom and Dick & Harry."
    done()

  it "smart_join can handle degenerate cases",(done)->
    options =
      before: "B"
      first: "F"
      delimiter: "D"
      last: "L"
      after: "A"
    tests = [
      { input:null, expected: null }
      { input:[], expected: "BA" }
      { input:[1], expected: "B1A" }
      { input:[1,2], expected: "B1F2A" }
      { input:[1,2,3], expected: "B1F2L3A" }
      { input:[1,2,3,4], expected: "B1F2D3L4A" }
      { input:[1,2,3,4,5], expected: "B1F2D3D4L5A" }
    ]
    for test in tests
      found = Util.smart_join test.input, options
      if test.expected?
        found.should.equal test.expected
      else
        should.not.exist found
    done()

  it "can match ISO8601 dates",(done)->
    Util.iso_8601_regexp().test((new Date()).toISOString()).should.be.ok
    matches = "2014-12-17T23:55:22.192Z".match Util.iso_8601_regexp()
    matches[0].should.equal "2014-12-17T23:55:22.192Z" # full string
    matches[1].should.equal "2014-12-17"               # full date
    matches[2].should.equal "2014"                     # year
    matches[3].should.equal "12"                       # month
    matches[4].should.equal "17"                       # day
    matches[5].should.equal "23:55:22.192Z"            # full time
    matches[6].should.equal "23"                       # hours
    matches[7].should.equal "55"                       # minutes
    matches[8].should.equal "22.192"                   # seconds.millis
    matches[9].should.equal "22"                       # seconds (no millis)
    matches[10].should.equal "192"                     # milliseconds
    matches[11].should.equal "Z"                       # timezone
    done()

  it "can nullify blank attributes of an object",(done)->
    obj = {
      foo: null
      bar: "xyzzy"
      abc: '    '
      xyz: ''
    }
    result = Util.blank_to_null(obj)
    should.exist result
    should.not.exist result.foo
    should.not.exist result.abc
    should.not.exist result.xyz
    result.bar.should.equal 'xyzzy'
    done()

  it "ArrayUtil.shuffle can perform an in-place shuffle of an array",(done)->
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
        shuffled = ArrayUtil.shuffle([].concat(test))
      else
        shuffled = ArrayUtil.shuffle(test)
      if test? and Array.isArray(test)
        if test?.length > 1
          assert.notDeepEqual test, shuffled # this test may actually fail once in a while since the original array is a valid shuffling
        assert.deepEqual test.sort(), shuffled.sort()
      else
        assert.equal test, shuffled
    done()

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
    hex = Util.random_bytes(byte_count,'hex')
    (/^[0-9a-f]+$/.test hex).should.be.ok
    hex.length.should.equal 2*byte_count
    done()

  it "random_bytes(n,'buffer') returns a buffer rather than a string ",(done)->
    byte_count = 25
    bytes = Util.random_bytes(byte_count,'buffer')
    bytes.length.should.equal byte_count
    done()

  it "random_bytes(enc,count) also works",(done)->
    hex = Util.random_bytes('hex')
    (/^[0-9a-f]+$/.test hex).should.be.ok
    hex = Util.random_bytes(20,'hex')
    hex.length.should.equal 40
    (/^[0-9a-f]+$/.test hex).should.be.ok
    hex = Util.random_bytes('hex',20)
    hex.length.should.equal 40
    (/^[0-9a-f]+$/.test hex).should.be.ok
    done()

  it "random_hex returns random hex digits",(done)->
    hex = Util.random_hex(63)
    hex.length.should.equal 63
    (/^[0-9a-f]+$/.test hex).should.be.ok
    done()

  it "random_Alphanumeric returns base-62 values",(done)->
    for c in [0,1,3,117]
      str = Util.random_Alphanumeric(c)
      (/^[0-9a-zA-Z]*$/.test str).should.be.ok
      str.length.should.equal c
    long = Util.random_Alphanumeric(300)
    (/[0-9]/.test(long)).should.equal true
    (/[a-z]/.test(long)).should.equal true
    (/[A-Z]/.test(long)).should.equal true
    done()

  it "random_string returns characters from the specified alphabet",(done)->
    for c in [0,1,3,117]
      str = Util.random_string("aeiouyAEIOUY357",c)
      (/^[aeiouyAEUIOY357]*$/.test str).should.be.ok
      str.length.should.equal c
    done()

  it "random_string has smart default parameters",(done)->
    for c in [0,1,3,117]
      #
      count_only = Util.random_string(c)
      (/^[0-9a-zA-Z]*$/.test count_only).should.be.ok
      count_only.length.should.equal c
      #
      alphabet_only = Util.random_string("aeiou")
      (/^[aeiou]*$/.test alphabet_only).should.be.ok
      alphabet_only.length.should.equal 32
      #
      rng_only = Util.random_string(Util.seed_rng("xyzzy"))
      (/^[0-9a-zA-Z]*$/.test rng_only).should.be.ok
      rng_only.length.should.equal 32
      #
      alphabet_and_count = Util.random_string("aeiou",c)
      (/^[aeiou]*$/.test alphabet_and_count).should.be.ok
      alphabet_and_count.length.should.equal c
      #
      alphabet_and_rng = Util.random_string("aeiou",Util.seed_rng("xyzzy"))
      (/^[aeiou]*$/.test alphabet_and_rng).should.be.ok
      alphabet_and_rng.length.should.equal 32
      #
      count_and_rng = Util.random_string(c,Util.seed_rng("xyzzy"))
      (/^[0-9a-zA-Z]*$/.test count_and_rng).should.be.ok
      count_and_rng.length.should.equal c
      #
      alphabet_count_and_rng = Util.random_string("aeiou",c,Util.seed_rng("xyzzy"))
      (/^[aeiou]*$/.test alphabet_count_and_rng).should.be.ok
      alphabet_count_and_rng.length.should.equal c
    done()

  it "random_alphanumeric returns base-36 values",(done)->
    for c in [0,1,3,117]
      str = Util.random_alphanumeric(c)
      (/^[0-9a-z]*$/.test str).should.be.ok
      str.length.should.equal c
    done()

  it "random_alphanumeric returns base-36 values (seed_rng case)",(done)->
    Util.set_rng(Util.seed_rng("hello."))
    for c in [0,1,3,117]
      str = Util.random_alphanumeric(c)
      (/^[0-9a-z]*$/.test str).should.be.ok
      str.length.should.equal c
    Util.set_rng()
    done()

  it "random_numeric returns random decimal digits",(done)->
    digits = Util.random_numeric(63)
    digits.length.should.equal 63
    (/^[0-9]+$/.test digits).should.be.ok
    done()

  it "random_ALPHA returns random UPPERCASE letters",(done)->
    letters = Util.random_ALPHA(63)
    letters.length.should.equal 63
    (/^[A-Z]+$/.test letters).should.be.ok
    done()

  it "random_alpha returns random lowercase letters",(done)->
    letters = Util.random_alpha(63)
    letters.length.should.equal 63
    (/^[a-z]+$/.test letters).should.be.ok
    done()

  it "random_Alpha returns random Mixed-Case letters",(done)->
    letters = Util.random_Alpha(630)
    letters.length.should.equal 630
    (/^[a-zA-Z]+$/.test letters).should.be.ok
    (/[a-z]/.test letters).should.be.ok # it is unlikely that there are no lowercase letters
    (/[A-Z]/.test letters).should.be.ok # it is unlikely that there are no uppercase letters
    done()

  it "random_element returns a random element of an array",(done)->
    a = [0...10]
    for i in [0...20]
      e = Util.random_element(a)
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
      [k,v] = Util.random_element(m)
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
      found = Util.random_element(t[0])
      (found is t[1]).should.be.ok
    done()

  it "random_alphanumeric passes a rough test of randomness",(done)->
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(Util.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.6
        done()

  it "random_alphanumeric passes a rough test of randomness (seed_rng case)",(done)->
    Util.set_rng(Util.seed_rng("hello."))
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(Util.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.65
        done()

  it "random_alphanumeric passes a rough test of randomness (seed_rng case)",(done)->
    Util.set_rng(Util.seed_rng("hello."))
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(Util.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.65
        done()

  it "random_alphanumeric passes a rough test of randomness (seed_rng case 2)",(done)->
    Util.set_rng(Util.seed_rng("goodbye."))
    old_nextTick = process.nextTick
    process.nextTick = setImmediate
    stream = new Stream.Readable()
    loops = 512
    size = 64
    for i in [0..loops]
      stream.push(Util.random_alphanumeric(size))
    stream.push null
    zip = zipstream.createZip({ level: 1 })
    zip.addFile (stream),{name:"random.txt"}, ()->
      zip.finalize (count)->
        process.nextTick = old_nextTick
        #console.log (count/(loops*size))
        (count/(loops*size)).should.not.be.below 0.65
        done()

  it "seed_random ensures we get the same values for the same seed",(done)->
    rng1 = Util.seed_rng(1234567)
    rng2 = Util.seed_rng(1234567)
    rng3 = Util.seed_rng(168)
    rng4 = Util.seed_rng(168)
    old1 = old3 = ""
    for i in [0..1000]
      str1 = Util.random_alphanumeric(64,rng1)
      str2 = Util.random_alphanumeric(64,rng2)
      str3 = Util.random_alphanumeric(64,rng3)
      str4 = Util.random_alphanumeric(64,rng4)
      str1.should.equal str2
      str2.should.not.equal str3
      str3.should.equal str4
      str1.should.not.equal old1
      str3.should.not.equal old3
      old1 = str1
      old3 = str3
    done()

  it "slow_equals compares two buffers for equality",(done)->
    a = Util.random_bytes(2048)
    b = Util.random_bytes(2048)
    c = b.slice(0,2040)
    Util.slow_equals(a,a)[0].should.be.ok
    Util.slow_equals(a,b)[0].should.not.be.ok
    Util.slow_equals(b,a)[0].should.not.be.ok
    Util.slow_equals(b,b)[0].should.be.ok
    Util.slow_equals(b,c)[0].should.not.be.ok
    Util.slow_equals(c,b)[0].should.not.be.ok
    Util.slow_equals(c,c)[0].should.be.ok
    done()

  it "slow_equals takes a similar amount of time whether buffers are equal or not equal",(done)->
    @timeout(12000)
    reps = 300
    prefix_length = 32768
    length = 16384
    prefix = Util.random_bytes(prefix_length)
    a = prefix+Util.random_bytes(length)
    b = prefix+Util.random_bytes(length)
    Util.std_equals = (a,b)->[(a is b),b.length,(if (a is b) then 0 else a.length)]
    # compute time to compare with the standard `==` function
    start = Date.now()
    for i in [0...reps]
      Util.std_equals(a,a)[2].should.equal 0
      Util.std_equals(b,b)[2].should.equal 0
    std_equal = Date.now() - start
    start = Date.now()
    for i in [0...reps]
      Util.std_equals(a,b)[2].should.not.equal 0
      Util.std_equals(b,a)[2].should.not.equal 0
    std_not_equal = Date.now() - start
    # compute time to compare with the slow_equals function
    start = Date.now()
    for i in [0...reps]
      Util.slow_equals(a,a)[2].should.equal 0
      Util.slow_equals(b,b)[2].should.equal 0
    slow_equal = Date.now() - start
    start = Date.now()
    for i in [0...reps]
      Util.slow_equals(a,b)[2].should.not.equal 0
      Util.slow_equals(b,a)[2].should.not.equal 0
    slow_not_equal = Date.now() - start
    # calculate ratio of equal vs. not-equal times
    std_equal = 1 if std_equal is 0
    std_not_equal = 1 if std_not_equal is 0
    if std_not_equal > std_equal
      std = std_equal / std_not_equal
    else
      std = std_not_equal / std_equal
    slow_equal = 1 if slow_equal is 0
    slow_not_equal = 1 if slow_not_equal is 0
    if slow_not_equal > slow_equal
      slow = slow_equal / slow_not_equal
    else
      slow = slow_not_equal / slow_equal
    Math.abs(1-slow).should.be.below Math.abs(1-std)
    done()

  it "can hash passwords (basic case)",(done)->
    [salt,hash] = Util.hash_password('password')
    Buffer.isBuffer(salt).should.be.ok
    Buffer.isBuffer(hash).should.be.ok
    done()

  it "can hash passwords (known salt case)",(done)->
    [salt,hash] = Util.hash_password('password')
    Buffer.isBuffer(salt).should.be.ok
    Buffer.isBuffer(hash).should.be.ok
    [salt2,hash2] = Util.hash_password('password',salt)
    salt2.toString('hex').should.equal salt.toString('hex')
    hash2.toString('hex').should.equal hash.toString('hex')
    [salt3,hash3] = Util.hash_password('different',salt)
    salt3.toString('hex').should.equal salt.toString('hex')
    hash3.toString('hex').should.not.equal hash.toString('hex')
    done()

  it "can hash passwords (salt as number case)",(done)->
    [salt,hash] = Util.hash_password('password',12)
    Buffer.isBuffer(salt).should.be.ok
    salt.length.should.equal 12
    Buffer.isBuffer(hash).should.be.ok
    [salt,hash] = Util.hash_password('password',128)
    Buffer.isBuffer(salt).should.be.ok
    salt.length.should.equal 128
    Buffer.isBuffer(hash).should.be.ok
    done()

  it "can hash passwords (salt as string case)",(done)->
    [salt,hash] = Util.hash_password('password','salt')
    Buffer.isBuffer(salt).should.be.ok
    salt.toString().should.equal 'salt'
    Buffer.isBuffer(hash).should.be.ok
    done()

  it "can hash passwords (with pepper case)",(done)->
    [salt,hash] = Util.hash_password('password',null,'pepper')
    Buffer.isBuffer(salt).should.be.ok
    Buffer.isBuffer(hash).should.be.ok
    [salt2,hash2] = Util.hash_password('password',salt,'pepper')
    salt2.toString('hex').should.equal salt.toString('hex')
    hash2.toString('hex').should.equal hash.toString('hex')
    [salt3,hash3] = Util.hash_password('different',salt,'pepper')
    salt3.toString('hex').should.equal salt.toString('hex')
    hash3.toString('hex').should.not.equal hash.toString('hex')
    done()

  it "can hash passwords (specifying hash type case)",(done)->
    pepper = Util.random_bytes('buffer')
    [salt,hash] = Util.hash_password('password',null,pepper,'md5')
    Buffer.isBuffer(salt).should.be.ok
    Buffer.isBuffer(hash).should.be.ok
    [salt2,hash2] = Util.hash_password('password',salt,pepper,'md5')
    salt2.toString('hex').should.equal salt.toString('hex')
    hash2.toString('hex').should.equal hash.toString('hex')
    [salt3,hash3] = Util.hash_password('password',salt,'pepper')
    salt3.toString('hex').should.equal salt.toString('hex')
    hash3.toString('hex').should.not.equal hash.toString('hex')
    done()

  it "can hash passwords (map parameter case)",(done)->
    pepper = Util.random_bytes('buffer')
    [salt,hash] = Util.hash_password({password:'password',pepper:pepper,hash:'md5'})
    Buffer.isBuffer(salt).should.be.ok
    Buffer.isBuffer(hash).should.be.ok
    [salt2,hash2] = Util.hash_password({password:'password',salt:salt,pepper:pepper,hash:'md5'})
    salt2.toString('hex').should.equal salt.toString('hex')
    hash2.toString('hex').should.equal hash.toString('hex')
    done()

  it "requires a password to hash",(done)->
    try
      [salt,hash] = Util.hash_password()
      "execption not thrown".is.not.ok
    catch err
      should.exist err
    done()

  it "can validate hashed passwords",(done)->
    [salt,hash] = Util.hash_password('password')
    Util.validate_hashed_password(hash,'password',salt).should.be.ok
    Util.validate_hashed_password(hash,'other',salt).should.not.be.ok
    Util.validate_hashed_password(hash,'password',salt,'pepper').should.not.be.ok
    done()

  it "subset_of compares arrays as sets",(done)->
    for [a,b,result] in [
      [[1],[1],true]
      [[1],[2],false]
      [[1],[1,2],true]
      [[1,2],[1],false]
      [[1,2],[1,2],true]
      [[1,2],[1,2,3],true]
      [[1,1,2,2,2,2],[3,3,3,1,2,3],true]
    ]
      Util.subset_of(a,b).should.equal result
      Util.is_subset_of(a,b).should.equal result
    done()

  it "subset_of throws an error when non-array values are passed",(done)->
    err = null
    try
      should.not.exist(Util.subset_of("abcd",1234))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "strict_subset_of compares arrays as sets",(done)->
    for [a,b,result] in [
      [[1],[1],false]
      [[1],[2],false]
      [[1],[1,2],true]
      [[1,2],[1],false]
      [[1,2],[1,2],false]
      [[1,2],[1,2,3],true]
      [[1,1,2,2,2,2],[3,3,3,1,2,3],true]
    ]
      Util.strict_subset_of(a,b).should.equal result
      Util.is_strict_subset_of(a,b).should.equal result
    done()

  it "strict_subset_of throws an error when non-array values are passed",(done)->
    err = null
    try
      should.not.exist(Util.strict_subset_of("abcd",1234))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "arrays_are_equal compares arrays as sequences",(done)->
    for [a,b,result] in [
      [[1],[1],true]
      [[1,1],[1,1,1],false]
      [[1],[2],false]
      [[1,2],[1,2],true]
      [[2,1],[1,2],false]
      [[1,2,2],[1,2,2],true]
      [[1,null,2],[1,null,2],true]
    ]
      Util.arrays_are_equal(a,b).should.equal result
    done()

  it "arrays_are_equal throws error on non-array parameters",(done)->
    try
      Util.arrays_are_equal(2,{foo:'bar'})
      "Expected error".should.not.exist
    catch err
      done()

  it "uniquify strips duplicate values from an array",(done)->
    for [input,expected] in [
      [[],[]]
      [[1],[1]]
      [[null],[null]]
      [[null,null],[null]]
      [[1,1],[1]]
      [[1,2,2,3,3,3,4,4,4,4],[1,2,3,4]]
      [[1,2,3,4,2,3,4,3,4,4],[1,2,3,4]]
      [[1,null,2,3,4,2,null,3,4,3,4,4],[1,null,2,3,4]]
    ]
      Util.arrays_are_equal(Util.uniquify(input),expected).should.be.ok
    done()

  it "uniquify strips duplicate keys from an array of maps",(done)->
    for [input,expected] in [
      [[],[]]
      [[{key:1}],[{key:1}]]
      [[{key:null}],[{key:null}]]
      [[{key:null},{key:null}],[{key:null}]]
      [[{key:1},{key:null}],[{key:1},{key:null}]]
      [[{key:1},{key:2}],[{key:1},{key:2}]]
      [[{key:2},{key:1},{key:2}],[{key:2},{key:1}]]
      [[{key:1},{key:2},{key:1}],[{key:1},{key:2}]]
      [[{key:1},{key:1}],[{key:1}]]
      [[{key:1},{key:2},{key:2},{key:3},{key:3},{key:3}],[{key:1},{key:2},{key:3}]]
    ]
      # console.log input,Util.uniquify(input,'key'),expected
      get_key = (x)->x?.key
      Util.arrays_are_equal(Util.uniquify(input,'key').map(get_key),expected.map(get_key)).should.be.ok
    done()

  it "sets_are_equal compares arrays as sets",(done)->
    for [a,b,result] in [
      [[1],[1],true]
      [[1,1],[1,1,1],true]
      [[1],[2],false]
      [[1],[1,2],false]
      [[1,2,2],[1,1,2],true]
      [[1,2],[1],false]
      [[1,2],[1,2],true]
      [[1,2],[1,2,3],false]
      [[1,1,2,2,2,2,3],[3,3,3,1,2,3],true]
    ]
      Util.sets_are_equal(a,b).should.equal result
    done()

  it "sets_are_equal throws an error when non-array values are passed",(done)->
    err = null
    try
      should.not.exist(Util.sets_are_equal("abcd",1234))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "round_decimal rounds a numeric value to the specified number of signficant digits",(done)->
    invalid = [
      null
      "foo17bar"
      "17bar"
      "foo17"
      "123.456.789"
      "--12345"
      "+12345"
      ""
      NaN
    ]
    for value in invalid
      should.not.exist Util.round_decimal(value,10)
    tests = [
      [ 123.456, 0, '123' ]
      [ 123.456, 1, '123.5' ]
      [ 123.456, 2, '123.46' ]
      [ 123.456, 3, '123.456' ]
      [ 123.456, 4, '123.4560' ]
      [ 123.456, 5, '123.45600' ]
      [ .456, 0, '0' ]
      [ .456, 1, '0.5' ]
      [ .456, 2, '0.46' ]
      [ .456, 3, '0.456' ]
      [ .456, 4, '0.4560' ]
      [ .456, 5, '0.45600' ]
      [ 123.456, -1, '120' ]
      [ 123.456, -2, '100' ]
      [ 123.456, -3, '0' ]
    ]
    for [value,round_to,expected] in tests
      found = Util.round_decimal(value,round_to)
      found = Util.round_decimal("#{value}",round_to)
      found = Util.round_decimal("  #{value}\t",round_to)
      found.should.equal expected
    done()

  it "is_int identifies integers",(done)->
    Util.is_int(null).should.not.be.ok
    Util.is_int("foo").should.not.be.ok
    Util.is_int("").should.not.be.ok
    Util.is_int("-").should.not.be.ok
    Util.is_int("0.0").should.not.be.ok
    Util.is_int(".0").should.not.be.ok
    Util.is_int(3.14159).should.not.be.ok
    Util.is_int("3.0").should.not.be.ok
    Util.is_int(3).should.be.ok
    Util.is_int(-3).should.be.ok
    Util.is_int("3").should.be.ok
    Util.is_int("-3").should.be.ok
    Util.is_int("0").should.be.ok
    Util.is_int(0).should.be.ok
    Util.is_int("-0").should.be.ok
    done()

  it "to_int converts integers",(done)->
    should.not.exist Util.to_int(null)
    should.not.exist Util.to_int("foo")
    should.not.exist Util.to_int("")
    should.not.exist Util.to_int("-")
    should.not.exist Util.to_int("3-5")
    should.not.exist Util.to_int("-3-5")
    should.not.exist Util.to_int("-3.5.5")
    should.not.exist Util.to_int(3.14159)
    Util.to_int("0").should.equal(0)
    Util.to_int("-0").should.equal(0)
    Util.to_int("1").should.equal(1)
    Util.to_int("2").should.equal(2)
    Util.to_int(0).should.equal(0)
    Util.to_int(-0).should.equal(0)
    Util.to_int(1).should.equal(1)
    Util.to_int(2).should.equal(2)
    should.not.exist Util.to_int("xyzzy")
    done()

  it "is_float identifies decimals",(done)->
    Util.is_float(null).should.not.be.ok
    Util.is_float("foo").should.not.be.ok
    Util.is_float("").should.not.be.ok
    Util.is_float("-").should.not.be.ok
    Util.is_float(".").should.not.be.ok
    Util.is_float("0.0").should.be.ok
    Util.is_float(".0").should.be.ok
    Util.is_float(3.14159).should.be.ok
    Util.is_float("3.0").should.be.ok
    Util.is_float(3).should.be.ok
    Util.is_float(-3).should.be.ok
    Util.is_float("3").should.be.ok
    Util.is_float("-3").should.be.ok
    Util.is_float("0").should.be.ok
    Util.is_float(0).should.be.ok
    Util.is_float("-0").should.be.ok
    done()

  it "to_float converts decimals",(done)->
    should.not.exist Util.to_float(null)
    should.not.exist Util.to_float("foo")
    should.not.exist Util.to_float("")
    should.not.exist Util.to_float("-")
    should.not.exist Util.to_float(".")
    should.not.exist Util.to_float("3.")
    should.not.exist Util.to_float("3-5")
    should.not.exist Util.to_float("-3-5")
    should.not.exist Util.to_float("-3.5.5")
    should.not.exist Util.to_float("xyzzy")
    Util.to_float(3.14159).should.equal 3.14159
    Util.to_float(.14159).toString().should.equal "0.14159"
    Util.to_float(-3.14159).toString().should.equal "-3.14159"
    Util.to_float(-.14159).toString().should.equal "-0.14159"
    Util.to_float("0").toString().should.equal("0")
    Util.to_float("-0").toString().should.equal("0")
    Util.to_float("0.0").toString().should.equal("0")
    Util.to_float(".0").toString().should.equal("0")
    Util.to_float("-0").toString().should.equal("0")
    Util.to_float("1").toString().should.equal("1")
    Util.to_float("2").toString().should.equal("2")
    Util.to_float(0).toString().should.equal("0")
    Util.to_float(-0).toString().should.equal("0")
    Util.to_float(1).toString().should.equal("1")
    Util.to_float(2).toString().should.equal("2")
    done()

  it "remote_ip returns the remote ip associated with a request",(done)=>
    should.not.exist Util.remote_ip(null)
    should.not.exist Util.remote_ip({})
    Util.remote_ip({headers:{'x-forwarded-for':'127.0.0.1'}}).should.equal '127.0.0.1'
    done()

  it "handle_error returns false if there is no error",(done)=>
    Util.handle_error(null,()->throw new Error("should not be invoked")).should.equal false
    done()

  it "handle_error invokes the callback method on error",(done)=>
    Util.handle_error("ERROR",((x)->x.should.equal "ERROR"; done())).should.equal true

  it "handle_error throws the error when the callback method is null",(done)=>
    Util.handle_error(null,null).should.equal false
    try
      Util.handle_error("THE ERROR")
      "Expected an error to be thrown.".should.not.exist
    catch err
      err.should.equal "THE ERROR"
      done()

  it "handle_error logs the error when the callback method is null and throw_on_error parameter is false",(done)=>
    Util.handle_error(null,null).should.equal false
    original_console_error = console.error
    after_handle_error = false
    error_logged = false
    try
      console.error = (args...)=>
        console.error = original_console_error
        error_logged = true
        args[1].should.equal "THE ERROR"
      (Util.handle_error("THE ERROR",null,false)).should.be.ok
      error_logged.should.be.ok
      done()
    finally
      console.error = original_console_error


  it "can convert between rgb and hex color definitions",(done)->
    should.not.exist Util.rgb_to_hex(null)
    should.not.exist Util.rgb_string_to_triplet(null)
    should.not.exist Util.hex_to_rgb_string(null)
    should.not.exist Util.hex_to_rgb_triplet(null)
    h2r = {
      "#FF0000" :"rgb(255,0,0)"
      "#00FF00" :"rgb(0,255,0)"
      "#0000FF" :"rgb(0,0,255)"
      "#ff0000" :"rgb(255,0,0)"
      "#00ff00" :"rgb(0,255,0)"
      "#0000ff" :"rgb(0,0,255)"
      "FF0000"  :"rgb(255,0,0)"
      "00FF00"  :"rgb(0,255,0)"
      "0000FF"  :"rgb(0,0,255)"
      "ff0000"  :"rgb(255,0,0)"
      "00ff00"  :"rgb(0,255,0)"
      "0000ff"  :"rgb(0,0,255)"
      "#e1d9c6" :"rgb(225,217,198)"
      "#333003" :"rgb(51,48,3)"
      "#897654" :"rgb(137,118,84)"
      "#EeCaBd" :"rgb(238,202,189)"
      "000000"  :"rgb(0,0,0)"
      "010203"  :"rgb(1,2,3)"
      "010203"  :"rgb(1,2,3)"
    }
    for h,r of h2r
      Util.hex_to_rgb_string(h).should.equal r
    r2h = {
      "rgb(255,0,0)":"#ff0000"
      "rgb(0,255,0)":"#00ff00"
      "rgb(0,0,255)":"#0000ff"
      "RGB(255,0,0)":"#ff0000"
      "RGB(0,255,0)":"#00ff00"
      "RGB(0,0,255)":"#0000ff"
      "rgb( 255, 0, 0)":"#ff0000"
      "rgb( 0 , 255 , 0 )":"#00ff00"
      "rgb(0, 0, 255)":"#0000ff"
      "rgb(255,0,0)":"#ff0000"
      "rgb(0,255,  0)":"#00ff00"
      "rgb(0, 0,255)":"#0000ff"
      "rgb(225,217,198)":"#e1d9c6"
      "rgb(51,48,3)":"#333003"
      "rgb(137,118,84)":"#897654"
      "rgb(238,202,189)":"#eecabd"
      "rgb(0,0,0)":"#000000"
      "rgb(1,2,3)":"#010203"
    }
    for r,h of r2h
      Util.rgb_to_hex(r).should.equal h
    done()

  it "compare sorts strings smartly", (done)->
    list = [
      "Omega"
      "beta"
      "Gamma"
      "Beta"
      "omega"
      "alpha"
      "Alpha"
      "gamma"
    ]
    list = list.sort(Util.compare)
    # javascript's String.localeCompare changed "A before a" to "a before A" around version 0.12
    if /v0\.10/.test process.version
      list[0].should.equal "Alpha"
      list[1].should.equal "alpha"
      list[2].should.equal "Beta"
      list[3].should.equal "beta"
      list[4].should.equal "Gamma"
      list[5].should.equal "gamma"
      list[6].should.equal "Omega"
      list[7].should.equal "omega"
    else
      list[0].should.equal "alpha"
      list[1].should.equal "Alpha"
      list[2].should.equal "beta"
      list[3].should.equal "Beta"
      list[4].should.equal "gamma"
      list[5].should.equal "Gamma"
      list[6].should.equal "omega"
      list[7].should.equal "Omega"
    done()

  it "compare compares elements", (done)->
    Util.compare(0,0).should.equal 0
    Util.compare(1,0).should.be.above 0
    Util.compare(0,1).should.be.below 0
    Util.compare(null,null).should.equal 0
    Util.compare(1,null).should.be.above 0
    Util.compare(null,1).should.be.below 0
    Util.compare("ABCD","ABCD").should.equal 0
    Util.compare("ABCE","ABCD").should.be.above 0
    Util.compare("ABCD","ABCE").should.be.below 0
    Util.compare("z","A").should.be.above 0
    Util.compare("Z","a").should.be.above 0
    if /^v0\.10/.test process.version
      Util.compare("a","A").should.be.above 0
      Util.compare("A","a").should.be.below 0
    else
      Util.compare("a","A").should.be.below 0
      Util.compare("A","a").should.be.above 0
    done()

  it "case_insensitive_compare compares elements in a case insenstive way", (done)->
    Util.case_insensitive_compare(0,0).should.equal 0
    Util.case_insensitive_compare(1,0).should.be.above 0
    Util.case_insensitive_compare(0,1).should.be.below 0
    Util.case_insensitive_compare(null,null).should.equal 0
    Util.case_insensitive_compare(1,null).should.be.above 0
    Util.case_insensitive_compare(null,1).should.be.below 0
    Util.case_insensitive_compare("ABCD","ABCD").should.equal 0
    Util.case_insensitive_compare("abcd","abcd").should.equal 0
    Util.case_insensitive_compare("Z","a").should.be.above 0
    Util.case_insensitive_compare("z","A").should.be.above 0
    Util.case_insensitive_compare("Z","A").should.be.above 0
    Util.case_insensitive_compare("z","a").should.be.above 0
    Util.case_insensitive_compare("a","a").should.equal 0
    Util.case_insensitive_compare("A","A").should.equal 0
    if /v0\.10/.test process.version
      Util.case_insensitive_compare("A","a").should.be.below 0
      Util.case_insensitive_compare("a","A").should.be.above 0
    else
      Util.case_insensitive_compare("A","a").should.be.above 0
      Util.case_insensitive_compare("a","A").should.be.below 0
    done()

  it "field_comparator generates simple field comparators", (done)->
    Util.field_comparator('x')({x:0},{x:0}).should.equal 0
    Util.field_comparator('x')({x:1},{x:0}).should.be.above 0
    Util.field_comparator('x')({x:0},{x:1}).should.be.below 0
    Util.field_comparator('x')({x:null},{x:null}).should.equal 0
    Util.field_comparator('x')({x:1},{x:null}).should.be.above 0
    Util.field_comparator('x')({x:null},{x:1}).should.be.below 0
    Util.field_comparator('x')(null,null).should.equal 0
    Util.field_comparator('x')({x:1},null).should.be.above 0
    Util.field_comparator('x')(null,{x:1}).should.be.below 0
    done()

  it "path_comparator generates compound field comparators", (done)->
    Util.path_comparator(['x','y','z'])({x:{y:{z:0}}},{x:{y:{z:0}}}).should.equal 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:1}}},{x:{y:{z:0}}}).should.be.above 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:0}}},{x:{y:{z:1}}}).should.be.below 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:null}}},{x:{y:{z:null}}}).should.equal 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:1}}},{x:{y:{z:null}}}).should.be.above 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:null}}},{x:{y:{z:1}}}).should.be.below 0
    Util.path_comparator(['x','y','z'])({x:{y:null}},{x:{y:null}}).should.equal 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:1}}},{x:{y:null}}).should.be.above 0
    Util.path_comparator(['x','y','z'])({x:{y:null}},{x:{y:{z:1}}}).should.be.below 0
    Util.path_comparator(['x','y','z'])({x:null},{x:null}).should.equal 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:1}}},{x:null}).should.be.above 0
    Util.path_comparator(['x','y','z'])({x:null},{x:{y:{z:1}}}).should.be.below 0
    Util.path_comparator(['x','y','z'])(null,null).should.equal 0
    Util.path_comparator(['x','y','z'])({x:{y:{z:1}}},null).should.be.above 0
    Util.path_comparator(['x','y','z'])(null,{x:{y:{z:1}}}).should.be.below 0
    done()

  it "desc_comparator reverses the given comparator", (done)->
    Util.desc_comparator(Util.compare)(0,0).should.equal 0
    Util.desc_comparator(Util.compare)(1,0).should.be.below 0
    Util.desc_comparator(Util.compare)(0,1).should.be.above 0
    Util.desc_comparator(Util.compare)(null,null).should.equal 0
    Util.desc_comparator(Util.compare)(1,null).should.be.below 0
    Util.desc_comparator(Util.compare)(null,1).should.be.above 0
    Util.descending_comparator(Util.compare)(0,0).should.equal 0
    Util.descending_comparator(Util.compare)(1,0).should.be.below 0
    Util.descending_comparator(Util.compare)(0,1).should.be.above 0
    Util.descending_comparator(Util.compare)(null,null).should.equal 0
    Util.descending_comparator(Util.compare)(1,null).should.be.below 0
    Util.descending_comparator(Util.compare)(null,1).should.be.above 0
    done()

  it "composite comparator creates a chain of comparators", (done)->
    chain = [
      Util.field_comparator('a')
      Util.path_comparator(['b1','b2','b3'])
      Util.field_comparator('c')
    ]
    o = (a,b,c)=>{a:a,b1:{b2:{b3:b}},c:c}
    Util.composite_comparator(chain)(o(0,0,0),o(0,0,0)).should.equal 0
    Util.composite_comparator(chain)(o(1,0,0),o(1,0,0)).should.equal 0
    Util.composite_comparator(chain)(o(1,0,1),o(1,0,1)).should.equal 0
    Util.composite_comparator(chain)(o(1,1,1),o(0,0,0)).should.be.above 0
    Util.composite_comparator(chain)(o(0,0,0),o(1,1,1)).should.be.below 0
    Util.composite_comparator(chain)(o(1,1,1),o(1,0,0)).should.be.above 0
    Util.composite_comparator(chain)(o(1,0,0),o(1,1,1)).should.be.below 0
    Util.composite_comparator(chain)(o(1,1,1),o(1,1,0)).should.be.above 0
    Util.composite_comparator(chain)(o(1,1,0),o(1,1,1)).should.be.below 0
    done()

  it "can paginate lists", (done)->
    list = [0...10]
    list.length.should.equal 10
    list[0].should.equal 0
    list[9].should.equal 9
    #
    l_0_100 = Util.paginate_list list, 0, 100
    l_0_100.length.should.equal 10
    l_0_100[0].should.equal 0
    l_0_100[9].should.equal 9
    #
    l_5_100 = Util.paginate_list list, 5, 100
    l_5_100.length.should.equal 5
    l_5_100[0].should.equal 5
    l_5_100[4].should.equal 9
    #
    l_9_100 = Util.paginate_list list, 9, 100
    l_9_100.length.should.equal 1
    l_9_100[0].should.equal 9
    #
    l_23_100 = Util.paginate_list list, 23, 100
    l_23_100.length.should.equal 0
    #
    l_0_8 = Util.paginate_list list, 0, 8
    l_0_8.length.should.equal 8
    l_0_8[0].should.equal 0
    l_0_8[7].should.equal 7
    #
    l_0_3 = Util.paginate_list list, 0, 2
    l_0_3.length.should.equal 2
    l_0_3[0].should.equal 0
    l_0_3[1].should.equal 1
    #
    l_0_1 = Util.paginate_list list, 0, 1
    l_0_1.length.should.equal 1
    l_0_1[0].should.equal 0
    #
    l_0_0 = Util.paginate_list list, 0, 0
    l_0_0.length.should.equal 0
    #
    l_1_1 = Util.paginate_list list, 1, 1
    l_1_1.length.should.equal 1
    l_1_1[0].should.equal 1
    #
    l_3_5 = Util.paginate_list list, 3, 5
    l_3_5.length.should.equal 5
    l_3_5[0].should.equal 3
    l_3_5[4].should.equal 7
    #
    l_5_5 = Util.paginate_list list, 5, 5
    l_5_5.length.should.equal 5
    l_5_5[0].should.equal 5
    l_5_5[4].should.equal 9
    #
    l_7_5 = Util.paginate_list list, 7, 5
    l_7_5.length.should.equal 3
    l_7_5[0].should.equal 7
    l_7_5[2].should.equal 9
    #
    done()

  it "can encode and decode base64", (done)->
    should.not.exist Util.b64e(null)
    should.not.exist Util.b64d(null)
    mapping = {
      'YQ==':'a'
      'SGVsbG8gV29ybGQ=': 'Hello World'
      'TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=':'Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.'
      'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZyBhbmQgc29tZSBleHRy':'The quick brown fox jumps over the lazy dog and some extr'
    }
    for e,d of mapping
      Util.b64d(e).should.equal d
      Util.b64e(d).should.equal e
    done()


  it "can generate and unpad UUID values", (done)->
    Util.uuid().should.be.ok
    # by default, Util.uuid doesn't generate anything
    should.not.exist Util.uuid(null)
    should.not.exist Util.uuid(null,null)
    should.not.exist Util.uuid(null,false)
    should.not.exist Util.pad_uuid()
    should.not.exist Util.pad_uuid(null)
    should.not.exist Util.pad_uuid(null,null)
    should.not.exist Util.pad_uuid(null,false)
    # but if you pass `true` for the second argument, Util.uuid will generate a new uuid
    should.exist Util.uuid(null,true)
    # Util.uuid generates unique values
    Util.uuid(null,true).should.not.equal(Util.uuid(null,true))
    # Util.uuid generats a 32-character UUID -- stripped of the optional dashes
    Util.uuid(null,true).length.should.equal 32
    # given a non-null value, Util.uuid will return it, stripped of dashes
    Util.uuid("34d1c554-7367-91d4-cc73-814f0be1ce6a").should.equal("34d1c554736791d4cc73814f0be1ce6a")
    Util.uuid("34d1c554-7367-91d4-cc73-814f0be1ce6a",true).should.equal("34d1c554736791d4cc73814f0be1ce6a")
    Util.uuid("34d1c554-7367-91d4-cc73-814f0be1ce6a",false).should.equal("34d1c554736791d4cc73814f0be1ce6a")
    Util.uuid("34d1c554736791d4cc73814f0be1ce6a").should.equal("34d1c554736791d4cc73814f0be1ce6a")
    Util.uuid("34d1c554736791d4cc73814f0be1ce6a",true).should.equal("34d1c554736791d4cc73814f0be1ce6a")
    Util.uuid("34d1c554736791d4cc73814f0be1ce6a",false).should.equal("34d1c554736791d4cc73814f0be1ce6a")
    # given a non-null value, Util.pad_uuid will return a padded UUID
    Util.pad_uuid("34d1c554-7367-91d4-cc73-814f0be1ce6a").should.equal("34d1c554-7367-91d4-cc73-814f0be1ce6a")
    Util.pad_uuid("34d1c554-7367-91d4-cc73-814f0be1ce6a",true).should.equal("34d1c554-7367-91d4-cc73-814f0be1ce6a")
    Util.pad_uuid("34d1c554-7367-91d4-cc73-814f0be1ce6a",false).should.equal("34d1c554-7367-91d4-cc73-814f0be1ce6a")
    Util.pad_uuid("34d1c554736791d4cc73814f0be1ce6a").should.equal("34d1c554-7367-91d4-cc73-814f0be1ce6a")
    Util.pad_uuid("34d1c554736791d4cc73814f0be1ce6a",true).should.equal("34d1c554-7367-91d4-cc73-814f0be1ce6a")
    Util.pad_uuid("34d1c554736791d4cc73814f0be1ce6a",false).should.equal("34d1c554-7367-91d4-cc73-814f0be1ce6a")
    done()

  it "uuid throws an error when non-null, not-string values is passed",(done)->
    err = null
    try
      should.not.exist(Util.uuid(1234))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "uuid throws an error when an invalid string value is passed",(done)->
    err = null
    try
      should.not.exist(Util.uuid("xxx"))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "can trim null values from the end of an array", (done)->
    pairs = [
      [ [1,2,3,4],                [1,2,3,4] ]
      [ [1,2,3,4,null],           [1,2,3,4] ]
      [ [1,2,3,null,4],           [1,2,3,null,4] ]
      [ [1,2,3,null,4,null],      [1,2,3,null,4] ]
      [ [1,2,3,null,4,null,null], [1,2,3,null,4] ]
      [ [null,null,null,1],       [null,null,null,1] ]
      [ [null,null,null],         [] ]
      [ [],                       [] ]
    ]
    for pair in pairs
      found = Util.trim_trailing_null(pair[0])
      found.length.should.equal pair[1].length
      for elt,i in pair[1]
        if elt?
          found[i].should.equal elt
        else
          should.not.exist found[i]
    done()

  it "can left-pad an array to a specified length", (done)->
    tuples = [
      [ 4, 'x', [], ['x','x','x','x'] ]
      [ 4, 'x', ['y'], ['x','x','x','y'] ]
      [ 3, 'x', ['y'], ['x','x','y'] ]
      [ 3, 'x', ['y','z'], ['x','y','z'] ]
      [ 3, 'x', ['a','b','c'], ['a','b','c'] ]
      [ 2, 'x', ['a','b','c'], ['a','b','c'] ]
      [ 0, 'x', ['a','b','c'], ['a','b','c'] ]
      [ 0, 'x', [], [] ]
    ]
    for [width,pad,arr,expected] in tuples
      found = Util.lpad(arr,width,pad)
      found.length.should.equal expected.length
      for elt,i in expected
        if elt?
          found[i].should.equal elt
        else
          should.not.exist found[i]
    done()

  it "can right-shift args", (done)->
    pairs = [
      [ ['x',null], [null,'x'] ]
      [ ['a',null,'b',null,null], [null,null,'a',null,'b'] ]
      [ [null,null,null,null], [null,null,null,null] ]
      [ [], [] ]
    ]
    for p in pairs
      found = Util.right_shift_args(p[0]...)
      found.length.should.equal p[1].length
      for elt,i in p[1]
        if elt?
          found[i].should.equal elt
        else
          should.not.exist found[i]
    done()

  it "can help chain several async methods together without excessive nesting (with last)", (done)->
    steps_executed = [false,false,false,false]
    proc = Util.procedure()
    proc.first (next)->
      steps_executed[0] = true
      steps_executed[1].should.not.be.ok
      steps_executed[2].should.not.be.ok
      steps_executed[3].should.not.be.ok
      next()
    proc.next (next)->
      steps_executed[0].should.be.ok
      steps_executed[1] = true
      steps_executed[2].should.not.be.ok
      steps_executed[3].should.not.be.ok
      next()
    proc.then (next)->
      steps_executed[0].should.be.ok
      steps_executed[1].should.be.ok
      steps_executed[2] = true
      steps_executed[3].should.not.be.ok
      next()
    proc.finally ()->
      steps_executed[0].should.be.ok
      steps_executed[1].should.be.ok
      steps_executed[2].should.be.ok
      steps_executed[3] = true
      done()

  it "can help chain several async methods together without excessive nesting (with run)", (done)->
    steps_executed = [false,false,false,false]
    proc = Util.procedure()
    proc.first (next)->
      steps_executed[0] = true
      steps_executed[1].should.not.be.ok
      steps_executed[2].should.not.be.ok
      steps_executed[3].should.not.be.ok
      next()
    proc.next (next)->
      steps_executed[0].should.be.ok
      steps_executed[1] = true
      steps_executed[2].should.not.be.ok
      steps_executed[3].should.not.be.ok
      next()
    proc.then (next)->
      steps_executed[0].should.be.ok
      steps_executed[1].should.be.ok
      steps_executed[2] = true
      steps_executed[3].should.not.be.ok
      next()
    proc.then (next)->
      steps_executed[0].should.be.ok
      steps_executed[1].should.be.ok
      steps_executed[2].should.be.ok
      steps_executed[3] = true
      next()
    proc.run ()=>
      steps_executed[0].should.be.ok
      steps_executed[1].should.be.ok
      steps_executed[2].should.be.ok
      steps_executed[3].should.be.ok
      done()

  it "WebUtil can apppend query string values", (done)->
    foo = "https://example.com/no-qs"
    bar = "https://example.com/with-qs?has-qs=true"
    assert.equal WebUtil.append_query_string(foo, "x=y&y=z"), "https://example.com/no-qs?x=y&y=z"
    assert.equal WebUtil.append_query_string(bar, "x=y&y=z"), "https://example.com/with-qs?has-qs=true&x=y&y=z"
    assert.equal WebUtil.append_query_string(foo, null), "https://example.com/no-qs"
    assert.equal WebUtil.append_query_string(bar, null), "https://example.com/with-qs?has-qs=true"
    assert.equal WebUtil.append_query_string(foo, {x:'y',y:'z'}), "https://example.com/no-qs?x=y&y=z"
    assert.equal WebUtil.append_query_string(bar, {x:'y',y:'z'}), "https://example.com/with-qs?has-qs=true&x=y&y=z"
    assert.equal WebUtil.append_query_string(foo, { }), "https://example.com/no-qs?"
    assert.equal WebUtil.append_query_string(bar, { }), "https://example.com/with-qs?has-qs=true&"
    assert.equal WebUtil.append_query_string(foo, "x", "y"), "https://example.com/no-qs?x=y"
    assert.equal WebUtil.append_query_string(bar, "x", "y"), "https://example.com/with-qs?has-qs=true&x=y"
    assert.equal WebUtil.append_query_string(foo, "x", ["a","b","c"]), "https://example.com/no-qs?x=a&x=b&x=c"
    assert.equal WebUtil.append_query_string(bar, "x", ["a","b","c"]), "https://example.com/with-qs?has-qs=true&x=a&x=b&x=c"
    done()
