require 'coffee-errors'
#------------------------------------------------------------------------------#
#coffeelint:disable=cyclomatic_complexity
should  = require 'should'
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
StringUtil    = require(path.join(LIB_DIR,'string-util')).StringUtil
Stream  = require 'stream'
zipstream = require 'zipstream'

describe 'StringUtil',->

  it "can recognize truthy strings",(done)->
    tests = [
      [ null,       false ]
      [ "",         false ]
      [ " ",        false ]
      [ true,       true ]
      [ false,      false ]
      [ new Date(), false ]
      [ 1,          true ]
      [ 0,          false ]
      [ -1,         false ]
      [ 2,          false ]
      [ "true",     true ]
      [ "TRUE",     true ]
      [ "tRuE",     true ]
      [ "t",        true ]
      [ "T",        true ]
      [ "Yes",      true ]
      [ "yes",      true ]
      [ "y",        true ]
      [ "Y",        true ]
      [ "on",       true ]
      [ "oN",       true ]
      [ "off",      false ]
      [ "1",        true ]
    ]
    for [value,expected] in tests
      found = StringUtil.truthy_string(value)
      found.should.equal expected
    done()

  it "can recognize falsey strings",(done)->
    tests = [
      [ null,       false ]
      [ "",         false ]
      [ " ",        false ]
      [ true,       false ]
      [ false,      true ]
      [ new Date(), false ]
      [ 1,          false ]
      [ 0,          true ]
      [ -1,         false ]
      [ 2,          false ]
      [ "true",     false ]
      [ "false",    true ]
      [ "False",    true ]
      [ "FALSE",    true ]
      [ "t",        false ]
      [ "F",        true ]
      [ "f",        true ]
      [ "No" ,      true ]
      [ "no",       true ]
      [ "n",        true ]
      [ "N",        true ]
      [ "off",      true ]
      [ "oFF",      true ]
      [ "on",       false ]
      [ "1",        false ]
      [ "0",        true ]
    ]
    for [value,expected] in tests
      found = StringUtil.falsey_string(value)
      found.should.equal expected
    done()

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
      found = StringUtil.trim(value)
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
      StringUtil.is_blank(value).should.equal blank
      StringUtil.isnt_blank(value).should.equal not blank
      if blank
        should.not.exist StringUtil.blank_to_null(value)
      else
        StringUtil.blank_to_null(value).should.equal value
    done()

  it "can nullify blank attributes of an object",(done)->
    obj = {
      foo: null
      bar: "xyzzy"
      abc: '    '
      xyz: ''
    }
    result = StringUtil.blank_to_null(obj)
    should.exist result
    should.not.exist result.foo
    should.not.exist result.abc
    should.not.exist result.xyz
    result.bar.should.equal 'xyzzy'
    done()

  it "can escape strings for regular expressions",(done)->
    tests = [
      [ "", "" ]
      [ "\\", "\\\\"] # note this is `\` and `\\`
      [ "/", "\\/"]  # note this is `/` and `\/`
      [ "[{|}]", "\\[\\{\\|\\}\\]"]
    ]
    for [str,expected] in tests
      StringUtil.escape_for_regexp(str).should.equal expected
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
      StringUtil.truncate(text,width,marker).should.equal expected
      StringUtil.truncate(text,width,marker).length.should.not.be.above width
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
      found = StringUtil.lpad(value,width,char)
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
      found = StringUtil.rpad(value,width,char)
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
      found = StringUtil.rpad(value,width,pad)
      found.length.should.equal expected.length
      for e,i in expected
        found[i].should.equal e
    done()

  it "lpad throws an error when a null value is passed",(done)->
    err = null
    try
      should.not.exist(StringUtil.lpad())
    catch e
      err = e
    finally
      should.exist err
      done()

  it "lpad throws an error when an empty pad-string is passed",(done)->
    err = null
    try
      should.not.exist(StringUtil.lpad("",3,""))
    catch e
      err = e
    finally
      should.exist err
      done()

  it "rpad throws an error when a null value is passed",(done)->
    err = null
    try
      should.not.exist(StringUtil.rpad())
    catch e
      err = e
    finally
      should.exist err
      done()

  it "rpad throws an error when an empty pad-string is passed",(done)->
    err = null
    try
      should.not.exist(StringUtil.rpad("",3,""))
    catch e
      err = e
    finally
      should.exist err
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
      found = StringUtil.escape_for_json(input)
      found.should.equal expected
    should.not.exist StringUtil.escape_for_json(null)
    done()

  it "escape_for_bash escapes command line parameters",(done)->
    tests = [
      [ 1, "'1'"  ]
      [ '', "''" ]
      [ ' ', "' '" ]
      [ "\n", "'\n'" ]
      [ true, "'true'" ]
      [ false, "'false'" ]
      [ "Here's Johnny", "'Here'\\''s Johnny'" ]
      [ "Special characters like < & \" \\ ! etc. don't need to be escaped.", "'Special characters like < & \" \\ ! etc. don'\\''t need to be escaped.'" ]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      found = StringUtil.escape_for_bash(input)
      found.should.equal expected
    done()

  it "escape_for_bash doesn't choke on null",(done)->
    should.not.exist StringUtil.escape_for_bash(null)
    done()

  it "escape_for_bash doesn't escape special characters and sequences by default",(done)->
    should.not.exist StringUtil.escape_for_bash(null)
    tests = [
      ['<', '<']
      ['>', '>']
      ['>>', '>>']
      ['|', '|']
      ['||', '||']
      ['&', '&']
      ['&&', '&&']
      ['*', '*']
      ['.', '.']
      ['2>&1', '2>&1']
      ['/foo/*', '/foo/*']
      ['./*', './*']
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      found = StringUtil.escape_for_bash(input)
      found.should.equal expected
      found = StringUtil.escape_for_bash(input,false)
      found.should.equal expected
    done()

  it "escape_for_bash DOES escape special characters and sequences when asked",(done)->
    should.not.exist StringUtil.escape_for_bash(null)
    tests = [
      ['<',  "'<'"]
      ['>',  "'>'"]
      ['>>', "'>>'"]
      ['|',  "'|'"]
      ['||', "'||'"]
      ['&',  "'&'"]
      ['&&', "'&&'"]
      ['*',  "'*'"]
      ['.',  "'.'"]
      ['2>&1', "'2>&1'"]
      ['/foo/*', "'/foo/*'"]
      ['./*', "'./*'"]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      found = StringUtil.escape_for_bash(input,true)
      found.should.equal expected
    done()
