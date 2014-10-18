should  = require 'should'
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Util    = require(path.join(LIB_DIR,'util')).Util


describe 'Util',->

  it "can trim leading and trailing whitespace from a possibly null string",(done)->
    tests = [
      [ null, null ]
      [ "", "" ]
      [ "   ", ""]
      [ "\t \t", ""]
      [ "\tfoo\t", "foo"]
      [ "  \tfoo\t\t", "foo"]
      [ "  foo", "foo"]
      [ " foo\tbar ", "foo\tbar"]
      [ "foo bar", "foo bar"]
    ]
    for [value,expected] in tests
      found = Util.trim(value)
      if expected?
        found.should.equal expected
      else
        should.not.exist found
    done()

  it "can identify blank and non-blank strings",(done)->
    tests = [
      [ null, true ]
      [ "", true ]
      [ "/", false ]
      [ "   ", true]
      [ "\t \t", true]
      [ "\tfoo\t", false]
      [ "  \tfoo\t\t", false]
      [ "  foo", false]
      [ " foo\tbar ", false]
      [ "foo bar", false]
    ]
    for [value,blank] in tests
      Util.is_blank(value).should.equal blank
      Util.isnt_blank(value).should.equal not blank
    done()

  it "can escape strings for regular expressions",(done)->
    tests = [
      [ "", "" ]
      [ "\\", "\\\\"] # note this is `\` and `\\`
      [ "/", "\\/"]  # note this is `/` and `\/`
      [ "[{|}]", "\\[\\{\\|\\}\\]"]
    ]
    for [str,expected] in tests
      Util.escape_for_regexp(str).should.equal expected
    done()

  it "can truncate in a smartish way",(done)->
   tests = [
     [ '123456789', 11, null, '123456789' ]
     [ '123456789', 10, null, '123456789' ]
     [ '123456789', 9, null, '123456789' ]
     [ '123456789', 8, null, '1234567…' ]
     [ '123456789', 7, null, '123456…' ]
     [ '123456789', 11, '...','123456789' ]
     [ '123456789', 10, '...','123456789' ]
     [ '123456789', 9, '...', '123456789' ]
     [ '123456789', 8, '...', '12345...' ]
     [ '123456789', 7, '...',  '1234...' ]
     [ '123456789', 11, '','123456789' ]
     [ '123456789', 10, '','123456789' ]
     [ '123456789', 9, '', '123456789' ]
     [ '123456789', 8, '', '12345678' ]
     [ '123456789', 7, '', '1234567' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 50, null, 'The quick brown fox jumped over the lazy dogs.' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 47, null, 'The quick brown fox jumped over the lazy dogs.' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 46, null, 'The quick brown fox jumped over the lazy dogs.' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 45, null, 'The quick brown fox jumped over the lazy…' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 44, null, 'The quick brown fox jumped over the lazy…' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 43, null, 'The quick brown fox jumped over the lazy…' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 40, null, 'The quick brown fox jumped over the…' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 39, null, 'The quick brown fox jumped over the…' ]
     [ 'The quick brown foxjumpedoverthelazydogs.', 39, null, 'The quick brown foxjumpedoverthelazydo…' ]
     [ 'The quick brown foxjumpedoverthelazydogs.', 38, null, 'The quick brown foxjumpedoverthelazyd…' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 25, null, 'The quick brown fox…' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 45, '...', 'The quick brown fox jumped over the lazy...' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 44, '...', 'The quick brown fox jumped over the lazy...' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 43, '...', 'The quick brown fox jumped over the lazy...' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 40, '...', 'The quick brown fox jumped over the...' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 39, '...', 'The quick brown fox jumped over the...' ]
     [ 'The quick brown foxjumpedoverthelazydogs.', 39, '...', 'The quick brown foxjumpedoverthelazy...' ]
     [ 'The quick brown foxjumpedoverthelazydogs.', 38, '...', 'The quick brown foxjumpedoverthelaz...' ]
     [ 'The quick brown fox jumped over the lazy dogs.', 25, '...', 'The quick brown fox...' ]
   ]
   for [text,width,marker,expected] in tests
     Util.truncate(text,width,marker).should.equal expected
     Util.truncate(text,width,marker).length.should.not.be.above width
   done()


  it "merge combines two maps",(done)->
    a = {
      a: 1
      b: 2
      c: 3
      e: 5
    }
    b = {
      b: "two"
      c: "three"
      d: "four"
      e: "five"
    }
    c = Util.merge(a,b)
    c.a.should.equal 1
    c.b.should.equal 'two'
    c.c.should.equal 'three'
    c.d.should.equal 'four'
    c.e.should.equal 'five'
    done()

  it "merge combines more than two maps",(done)->
    list = [
      {
        a: 1
        b: 2
        c: 3
        e: 5
      },
      {
        b: "two"
        c: "three"
        d: "four"
        e: "five"
      },
      {
        c: "iii"
        f: "vi"
      }
    ]
    for m in [Util.merge(list),Util.merge(list...)]
      m.a.should.equal 1
      m.b.should.equal 'two'
      m.c.should.equal 'iii'
      m.d.should.equal 'four'
      m.e.should.equal 'five'
      m.f.should.equal 'vi'
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

  it "random_hex returns random hex digits",(done)->
    hex = Util.random_hex(63)
    hex.length.should.equal 63
    (/^[0-9a-f]+$/.test hex).should.be.ok
    done()

  it "random_alphanumeric returns base-36 values",(done)->
    for c in [0,1,3,117]
      str = Util.random_alphanumeric(c)
      (/^[0-9a-z]*$/.test str).should.be.ok
      str.length.should.equal c
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
    reps = 3000
    length = 4096
    a = Util.random_bytes(length)
    b = Util.random_bytes(length)
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
    # slow version should be closer to 1 than the standard
    # console.log Math.abs(1-slow),Math.abs(1-std)
    Math.abs(1-slow).should.be.below Math.abs(1-std)
    done()

  it "shallow_clone returns null for null",(done)->
    should.not.exist (Util.shallow_clone(null))
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

  it "shallow clone creates a shallow copy of a map",(done)->
    i = 1
    f = 1.234
    s = "Lorem Ipsum"
    a = [ 1, "two", null, "four", {five:5} ]
    o = { a: 1, b: 2, c: 3, meta: { d:4, e:5 } }
    map =
      int: i
      float: f
      string: s
      array: a
      obj: o
    clone = Util.shallow_clone(map)
    clone.int.should.equal 1
    clone.float.should.equal 1.234
    clone.string.should.equal "Lorem Ipsum"
    clone.array.length.should.equal 5
    clone.array[0].should.equal 1
    clone.array[1].should.equal "two"
    should.not.exist clone.array[2]
    clone.array[3].should.equal "four"
    clone.array[4].five.should.equal 5
    clone.obj.a.should.equal 1
    clone.obj.b.should.equal 2
    clone.obj.c.should.equal 3
    clone.obj.meta.d.should.equal 4
    clone.obj.meta.e.should.equal 5
    # console.log JSON.stringify(clone)
    a.push "SIX"
    a[4].five = "V"
    o.meta.f = 6
    o.g = 7
    # console.log JSON.stringify(clone)
    clone.int.should.equal 1
    clone.float.should.equal 1.234
    clone.string.should.equal "Lorem Ipsum"
    clone.array.length.should.equal 6
    clone.array[0].should.equal 1
    clone.array[1].should.equal "two"
    should.not.exist clone.array[2]
    clone.array[3].should.equal "four"
    clone.array[4].five.should.equal "V"
    clone.obj.meta.f.should.equal 6
    clone.obj.g.should.equal 7
    done()

  it "lpad pads strings from the left",(done)->
    tests = [
      [ '',     3, null, '   ' ]
      [ 'X',    3, null, '  X' ]
      [ 'XY',   3, null, ' XY' ]
      [ 'XYZ',  3, null, 'XYZ' ]
      [ 'WXYZ', 3, null, 'WXYZ' ]
      [ '',     3, '#',  '###' ]
      [ 'X',    3, '#',  '##X' ]
      [ 'XY',   3, '#',  '#XY' ]
      [ 'XYZ',  3, '#',  'XYZ' ]
      [ 'WXYZ', 3, '#',  'WXYZ' ]
    ]
    for [value,width,char,expected] in tests
      found = Util.lpad(value,width,char)
      found.should.equal expected
    done()

  it "rpad pads strings from the right",(done)->
    tests = [
      [ '',     3, null, '   ' ]
      [ 'X',    3, null, 'X  ' ]
      [ 'XY',   3, null, 'XY ' ]
      [ 'XYZ',  3, null, 'XYZ' ]
      [ 'WXYZ', 3, null, 'WXYZ' ]
      [ '',     3, '#',  '###' ]
      [ 'X',    3, '#',  'X##' ]
      [ 'XY',   3, '#',  'XY#' ]
      [ 'XYZ',  3, '#',  'XYZ' ]
      [ 'WXYZ', 3, '#',  'WXYZ' ]
    ]
    for [value,width,char,expected] in tests
      found = Util.rpad(value,width,char)
      found.should.equal expected
    done()

  it "rpad pads arrays from the right",(done)->
    tests = [
      [ [],     3, 'x', ['x','x','x' ] ]
      [ ['X'],  3, 'x', ['X','x','x' ] ]
      [ ['X','Y'],  3, 'x', ['X','Y','x' ] ]
      [ ['X','Y','Z'],  3, 'x', ['X','Y','Z' ] ]
      [ ['W','X','Y','Z'],  3, 'x', ['W','X','Y','Z' ] ]
    ]
    for [value,width,pad,expected] in tests
      found = Util.rpad(value,width,pad)
      found.length.should.equal expected.length
      for e,i in expected
        found[i].should.equal e
    done()

  it "lpad throws an error when a null value is passed",(done)->
    err = null
    try
      should.not.exist(Util.lpad())
    catch e
      err = e
    finally
      should.exist err
      done()

  it "lpad throws an error when an empty pad-string is passed",(done)->
    err = null
    try
      should.not.exist(Util.lpad("",3,""))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "rpad throws an error when a null value is passed",(done)->
    err = null
    try
      should.not.exist(Util.rpad())
    catch e
      err = e
    finally
      should.exist err
      done()

  it "rpad throws an error when an empty pad-string is passed",(done)->
    err = null
    try
      should.not.exist(Util.rpad("",3,""))
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
    done()

  it "escape_for_json escapes a json substring",(done)->
    tests = [
      [ 1, '1'  ]
      [ '', '' ]
      [ ' ', ' ' ]
      [ "\n", "\\n" ]
      [ "\"", "\\\"" ]
      [ "\\", "\\\\" ]
      [ 'alpha', 'alpha' ]
      [ 'alpha "beta" gamma', 'alpha \\"beta\\" gamma' ]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      found = Util.escape_for_json(input)
      found.should.equal expected
    should.not.exist Util.escape_for_json(null)
    done()

  it "handle_error invokes the callback method on error",(done)=>
    Util.handle_error(null,()->throw new Error("should not be invoked")).should.equal false
    Util.handle_error("ERROR",((x)->x.should.equal "ERROR"; done())).should.equal true

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
    Util.compare("Z","a").should.be.below 0
    Util.compare("a","A").should.be.above 0
    Util.compare("A","a").should.be.below 0
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
    Util.case_insensitive_compare("A","a").should.be.below 0
    Util.case_insensitive_compare("a","A").should.be.above 0
    Util.case_insensitive_compare("a","a").should.equal 0
    Util.case_insensitive_compare("A","A").should.equal 0
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
    # by default, Util.uuid doesn't generate anything
    should.not.exist Util.uuid()
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
