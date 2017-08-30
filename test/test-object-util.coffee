should  = require 'should'
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
ObjectUtil    = require(path.join(LIB_DIR,'object-util')).ObjectUtil
assert = require 'assert'

describe 'ObjectUtil',->

  it "can identifiy true objects", (done)->
    tests = [
      [null, false]
      [{}, true]
      [{foo:"bar"}, true]
      [[], false]
      [[1], false]
      ["string", false]
      [3.14159, false]
      [console.log, false]
    ]
    for test in tests
      assert.equal ObjectUtil.is_true_object(test[0]), test[1], JSON.stringify(test)
    done()

  it "can compute deep-equal", (done)->
    tests = [
      # A           B           A == B?
      # comparing identical objects of various types
      [ undefined     , undefined       , true  ]
      [ null          , undefined       , true  ]
      [ undefined     , null            , true  ]
      [ 1             , 1               , true  ]
      [ "X"           , "X"             , true  ]
      [ true          , true            , true  ]
      [ []            , []              , true  ]
      [ [null]        , [undefined]     , true  ]
      [ {}            , {}              , true  ]
      [ [1]           , [1]             , true  ]
      [ [1,2]         , [1,2]           , true  ]
      [ [1,[2,3]]     , [1,[2,3]]       , true  ]
      [ [1,{},null]   , [1,{},null]     , true  ]
      [ {x:null}      , {x:null}        , true  ]
      [ {x:null}      , {x:undefined}   , true  ]
      [ {x:null}      , {}              , true  ]
      [ {x:1,y:2}     , {y:2,x:1}       , true  ]
      [ {x:[]}        , {x:[]}          , true  ]
      [ {x:[{y:[3]}]} , {x:[{y:[3]}]}   , true  ]

      # comparing non-null with null/undefined
      [ false          , null           , false ]
      [ null           , false          , false ]
      [ 1              , null           , false ]
      [ null           , 1              , false ]
      [ "x"            , null           , false ]
      [ null           , "x"            , false ]
      [ {}             , null           , false ]
      [ null           , {}             , false ]
      [ []             , null           , false ]
      [ null           , []             , false ]
      #
      [ false          , undefined      , false ]
      [ undefined      , false          , false ]
      [ 1              , undefined      , false ]
      [ undefined      , 1              , false ]
      [ "x"            , undefined      , false ]
      [ undefined      , "x"            , false ]
      [ {}             , undefined      , false ]
      [ undefined      , {}             , false ]
      [ []             , undefined      , false ]
      [ undefined      , []             , false ]

      # comparing simple, non-equal objects
      [ false          , true           , false ]
      [ true           , false          , false ]
      [ 1              , true           , false ]
      [ 1              , 2              , false ]
      [ "x"            , "y"            , false ]
      [ ""             , "  "           , false ]
      [ 1              , "1"            , false ]
      [ []             , {}             , false ]
      [ [1]            , []             , false ]
      [ [null]         , []             , false ]
      [ {x:null}       , []             , false ]
      [ {x:[{y:[3]}]}  , {x:[{y:[3,4]}]} , false ]
      [ [null]         , []              , false ]
      [ [1,1]          , [1]             , false ]

    ]
    for test in tests
      val_a    = test[0]
      val_b    = test[1]
      expected = test[2]
      found    = ObjectUtil.deep_equal val_a, val_b
      assert.equal expected, found, "deep_equal(#{JSON.stringify(val_a)},#{JSON.stringify(val_b)}) yielded '#{found}' expected '#{expected}'."
      found2   = ObjectUtil.deep_equals val_a, val_b
      assert.equal expected, found, "deep_equals(#{JSON.stringify(val_a)},#{JSON.stringify(val_b)}) yielded '#{found2}' expected '#{expected}'."
    done()

  it "can diff two JSON/map objects", (done)->
    a = {
      "foo": {
        "bar": {
          "xyzzy": [1,2,3,4]
          "nil": null
          "cbaab": [1,2,3,4]
          "z": {}
        }
        "foo":"1"
      }
    }
    b = {
      "foo": {
        "foo":1
        "bar": {
          "xyzzy": [1,2,3,4],
          "cbaab": [4,3,2,1]
        }
        "x": 3,
      }
    }
    d = {
      foo: {
        foo: "c"
        x: "a"
        bar: {
          z: "d"
          cbaab: "c"
        }
      }
    }
    assert.deepEqual ObjectUtil.json_diff(a,b), d
    done()

  it "can diff two JSON/map objects - edge cases", (done)->
    tests = [
      # OLD-MAP     NEW-MAP     EXPECTED
      [ undefined , undefined , undefined ]
      [ null      , undefined , undefined ]
      [ undefined , null      , undefined ]
      [ 1         , 1         , undefined ]
      [ "X"       , "X"       , undefined ]
      [ true      , true      , undefined ]
      [ []        , []        , undefined ]
      [ {}        , {}        , undefined ]
      [ [{}]      , [{}]        , undefined ]
      [ [1]       , [1]       , undefined ]
      [ [1,2]     , [1,2]     , undefined ]
      [ [1,[2,3]] , [1,[2,3]] , undefined ]
      [ [1,{}]    , [1,{}]    , undefined ]
      [ {x:[{y:[3]}]} , {x:[{y:[3]}]}   , undefined  ]
      [ {x:null}      , {}              , undefined  ]
      [ [{},[{x:null}]]  , [{},[{}]]    , undefined ]

      [ false     , null      , "d" ]
      [ null      , false     , "a" ]
      [ 1         , null      , "d" ]
      [ null      , 1         , "a" ]
      [ "x"       , null      , "d" ]
      [ null      , "x"       , "a" ]
      [ {}        , null      , "d" ]
      [ null      , {}        , "a" ]
      [ []       , null       , "d" ]
      [ null      , []        , "a" ]

      [ false     , true      , "c" ]
      [ true      , false     , "c" ]
      [ 1         , true      , "c" ]
      [ 1         , 2         , "c" ]
      [ "x"       , "y"       , "c" ]
      [ ""        , "  "      , "c" ]
      [ []        , {}        , "c" ]
      [ {}        , []        , "c" ]
      [ []        , [[]]      , "c" ]
      [ [{}]      , [[]]      , "c" ]
      [ [{}]      , []        , "c" ]
      [ 1         , null      , "d" ]
      [ null      , 1         , "a" ]
      [ "x"       , null      , "d" ]
      [ null      , "x"       , "a" ]
      [ {}        , null      , "d" ]
      [ null      , {}        , "a" ]
      [ []        , null      , "d" ]
      [ null      , []        , "a" ]

    ]
    for test in tests
      old_map  = test[0]
      new_map  = test[1]
      expected = test[2]
      found = ObjectUtil.json_diff old_map, new_map
      if not expected?
        assert not found?,  JSON.stringify(test) + "; found #{found}"
      else
        assert.deepEqual expected, found, JSON.stringify(test) + "; found #{found}"
    done()

  it "remove_null ignores non-array, non-map objects",(done)->
    ObjectUtil.remove_null("foo").should.equal "foo"
    ObjectUtil.remove_null(8).should.equal 8
    should.not.exist ObjectUtil.remove_null(null)
    done()

  it "remove_null removes null values from maps",(done)->
    input = {
      foo:null
      undef:undefined
      bar:0
    }
    output =  ObjectUtil.remove_null(input)
    should.not.exist output.foo
    should.not.exist output.undef
    output.bar.should.equal 0
    done()

  it "remove_null removes null values from arrays",(done)->
    input = [
      1
      null
      2
      undefined
      3
      0
    ]
    output =  ObjectUtil.remove_null(input)
    output.length.should.equal 4
    output[0].should.equal 1
    output[1].should.equal 2
    output[2].should.equal 3
    output[3].should.equal 0
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
    c = ObjectUtil.merge(a,b)
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
    for m in [ObjectUtil.merge(list),ObjectUtil.merge(list...)]
      m.a.should.equal 1
      m.b.should.equal 'two'
      m.c.should.equal 'iii'
      m.d.should.equal 'four'
      m.e.should.equal 'five'
      m.f.should.equal 'vi'
    done()

  it "merge skips null objects",(done)->
    list = [
      {
        a: 1
        b: 2
        c: 3
        e: 5
      },
      null,
      {
        b: "two"
        c: "three"
        d: "four"
        e: "five"
      },
      {
        c: "iii"
        f: "vi"
      },
      null
    ]
    for m in [ObjectUtil.merge(list),ObjectUtil.merge(list...)]
      m.a.should.equal 1
      m.b.should.equal 'two'
      m.c.should.equal 'iii'
      m.d.should.equal 'four'
      m.e.should.equal 'five'
      m.f.should.equal 'vi'
    done()

  it "merge is shallow; deep_merge is deep",(done)->
    list = [
      {
        a: 1
        b: {
          b0: "First"
          b1: [ false, false ]
        }
      },
      {
        a: {
          a1: true
          a2: {
            a21: true
          }
          a3: "X"
        }
        b: {
          b1: true
          b2: {
            b21: true
          }
          b3: "X"
        }
        c: {
          c1: "SECOND"
        }
      },
      {
        a: {
          a2: {
            a22: true
          }
        }
        b: {
          b2: {
            b22: 17
          }
          b3: "Y"
          b4: "Z"
        }
        c: {
          c1: {
            c11: "THIRD"
          }
        }
      }
    ]
    for m in [ObjectUtil.merge(list),ObjectUtil.merge(list...)]
      should.not.exist m.a.a1
      should.not.exist m.a.a2.a21
      m.a.a2.a22.should.equal true
      should.not.exist m.b.b0
      should.not.exist m.b.b1
      should.not.exist m.b.b2.b21
      m.b.b2.b22.should.equal 17
    for m in [ObjectUtil.deep_merge(list),ObjectUtil.deep_merge(list...)]
      m.a.a1.should.equal true
      m.a.a2.a21.should.equal true
      m.a.a2.a22.should.equal true
      m.a.a2.a22.should.equal true
      m.b.b0.should.equal 'First'
      m.b.b1.should.equal true
      m.b.b2.b21.should.equal true
      m.b.b2.b22.should.equal 17
      m.b.b3.should.equal 'Y'
      m.b.b4.should.equal 'Z'
      m.c.c1.c11.should.equal 'THIRD'
    done()

  it "remove_falsey returns null for null",(done)->
    should.not.exist (ObjectUtil.remove_falsey(null))
    done()

  it "remove_falsey strips null values from arrays",(done)->
    tests = [
      {in:[1,2,3],out:[1,2,3]}
      {in:[],out:[]}
      {in:[null,null,null],out:[]}
      {in:[null],out:[]}
      {in:[null,1,2,null],out:[1,2]}
      {in:[null,1,null,2,null,null,3],out:[1,2,3]}
    ]
    for test in tests
      found = ObjectUtil.remove_falsey(test.in)
      found.length.should.equal test.out.length
      for e,i in found
        e.should.equal test.out[i]
    done()

  it "remove_falsey strips falsey values from arrays",(done)->
    tests = [
      {in:[1,2,3],out:[1,2,3]}
      {in:[],out:[]}
      {in:[null,null,null],out:[]}
      {in:[null],out:[]}
      {in:[null,1,2,null],out:[1,2]}
      {in:[null,1,null,2,null,null,3],out:[1,2,3]}
      {in:[null,'',0,false],out:[]}
      {in:[false],out:[]}
      {in:['',1,2,0],out:[1,2]}
      {in:[0,1,null,2,false,'',3],out:[1,2,3]}
    ]
    for test in tests
      found = ObjectUtil.remove_falsey(test.in)
      found.length.should.equal test.out.length
      for e,i in found
        e.should.equal test.out[i]
    done()

  it "remove_falsey strips falsey values from maps",(done)->
    tests = [
      {in:{a:1,b:2,c:3},out:{a:1,b:2,c:3}}
      {in:{},out:{}}
      {in:{a:null,b:null,c:null},out:{}}
      {in:{a:null},out:{}}
      {in:{a:null,b:1,c:2,d:null},out:{b:1,c:2}}
      {in:{a:null,b:1,c:null,d:2,e:null,f:null,g:3},out:{b:1,d:2,g:3}}
      {in:{a:false,b:0,c:null},out:{}}
      {in:{a:0},out:{}}
      {in:{a:false,b:1,c:2,d:0},out:{b:1,c:2}}
      {in:{a:0,b:1,c:false,d:2,e:null,f:'',g:3},out:{b:1,d:2,g:3}}
    ]
    for test in tests
      found = ObjectUtil.remove_falsey(test.in)
      Object.keys(found).length.should.equal Object.keys(test.out).length
      for n,v of found
        v.should.equal test.out[n]
    done()

  it "remove_falsey returns input value for scalar types",(done)->
    for value in [ 1, 3.14, 'string', true ]
      ObjectUtil.remove_falsey(value).should.equal value
    done()

  it "remove_falsey returns null for falsey scalar types",(done)->
    for value in [ 0, false, '' ]
      should.not.exist ObjectUtil.remove_falsey(value)
    done()

  it "object_array_to_map creates a map using the specified key",(done)->
    for [input,key,options,expected] in [
      [ [ {a:'X', b:'X'}, {a:'Y',b:'Y'}, {a:'X', b:'Z'} ], 'a', null, { X:{a:'X',b:'Z'}, Y:{a:'Y',b:'Y'} } ]
      [ [ {a:'X', b:'X'}, {a:'Y',b:'Y'}, {a:'X', b:'Z', c:'C'} ], 'a', {duplicates:'skip'}, { X:{a:'X',b:'X'}, Y:{a:'Y',b:'Y'} } ]
      [ [ {a:'X', b:'X'}, {a:'Y',b:'Y'}, {a:'X', c:'C'} ], 'a', {duplicates:'merge'}, { X:{a:'X',b:'X',c:'C'}, Y:{a:'Y',b:'Y'} } ]
      [ [ {a:'X', b:'X'}, {a:'Y',b:'Y'}, {a:'X', c:'C'} ], 'a', {duplicates:'stack'}, { X:[{a:'X',b:'X'},{a:'X',c:'C'}], Y:{a:'Y',b:'Y'} } ]
      [ [ {a:'X', b:'X'}, {a:'Y',b:'Y'}, {a:'X', c:'C'},  {a:'X', d:'D'} ], 'a', {duplicates:'stack'}, { X:[{a:'X',b:'X'},{a:'X',c:'C'},{a:'X',d:'D'}], Y:{a:'Y',b:'Y'} } ]
    ]
      found = ObjectUtil.object_array_to_map(input,key,options)
      for k,v of expected
        if Array.isArray(v)
          for elt,i in v
            for k2,v2 of elt
              found[k][i][k2].should.equal v2
        else
          for k2,v2 of v
            found[k][k2].should.equal v2
    done()

  it "object_array_to_map throws error on unrecognzied duplicates policy",(done)->
    try
      ObjectUtil.object_array_to_map [{a:'X'}], 'a', duplicates:'foo'
      "Expected error".should.not.exist
    catch err
      done()

  it "shallow_clone returns null for null",(done)->
    should.not.exist (ObjectUtil.shallow_clone(null))
    done()

  it "shallow_clone returns source for string, boolean, number",(done)->
    ObjectUtil.shallow_clone("a string").should.equal "a string"
    ObjectUtil.shallow_clone(false).should.equal false
    ObjectUtil.shallow_clone(17).should.equal 17
    done()

  it "shallow_clone creates a shallow copy of a map",(done)->
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
    clone = ObjectUtil.shallow_clone(map)
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

  it "deep_clone creates a deep copy of an array",(done)->
    a = [
      1
      true
      {
        alpha:"A"
        beta:"B"
      }
      [ 8, 6, 7, 5, 3, 0, 9]
      null
      "end"
    ]
    b = ObjectUtil.deep_clone a
    b.length.should.equal a.length
    a.push "beyond the end"
    b.length.should.not.equal a.length
    b[0].should.equal a[0]
    b[1].should.equal a[1]
    b[2].alpha.should.equal a[2].alpha
    b[2].beta.should.equal a[2].beta
    a[2].gamma = "G"
    should.not.exist b[2].gamma
    b[3].length.should.equal a[3].length
    b[3][0].should.equal a[3][0]
    b[3][1].should.equal a[3][1]
    b[3][2].should.equal a[3][2]
    b[3][3].should.equal a[3][3]
    b[3][4].should.equal a[3][4]
    b[3][5].should.equal a[3][5]
    b[3][6].should.equal a[3][6]
    b[3][0] = "Eight"
    b[3][0].should.not.equal a[3][0]
    a[3][6] = "Nine"
    b[3][6].should.not.equal a[3][6]
    b[0].should.equal a[0]
    should.not.exist b[4]
    b[5].should.equal a[5]
    a[1] = "a different value"
    b[1].should.not.equal a[1]
    done()

  it "deep_clone returns null for null",(done)->
    should.not.exist (ObjectUtil.deep_clone(null))
    done()

  it "deep_clone returns source for string, boolean, number",(done)->
    ObjectUtil.deep_clone("a string").should.equal "a string"
    ObjectUtil.deep_clone(false).should.equal false
    ObjectUtil.deep_clone(17).should.equal 17
    done()

  it "can flatten maps",(done)->
    src = {
      "A": {
        "b1": {
          "c1": 7,
          "c2": {
            "d": "X"
          }
        },
        "b2": 3,
        "": {
          "X":"y"
        }
      },
      "A2":"foo"
    }
    flat = ObjectUtil.flatten_map src, ":"
    flat["A:b1:c1"].should.equal 7
    flat["A:b1:c2:d"].should.equal "X"
    flat["A:b2"].should.equal 3
    flat["A::X"].should.equal "y"
    flat['A2'].should.equal "foo"
    Object.keys(flat).length.should.equal 5
    done()
