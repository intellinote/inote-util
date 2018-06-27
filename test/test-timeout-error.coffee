require 'coffee-errors'
#------------------------------------------------------------------------------#
assert       = require 'assert'
fs           = require 'fs'
path         = require 'path'
HOME_DIR     = path.join(__dirname, '..')
LIB_COV      = path.join(HOME_DIR, 'lib-cov')
LIB_DIR      = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
TimeoutError = require(path.join(LIB_DIR,'timeout-error')).TimeoutError


describe 'TimeoutError',->
  # constructor:(@message,@timeout,@method)->

  it "constructor accepts various optional parameters", (done)=>
    tests = [
      [ "no args", [], "An unspecified function timed-out after an unspecified duration.", undefined, undefined ]
      #
      [ "message only", ["TIMEOUT!"], "TIMEOUT!", undefined, undefined ]
      [ "function only", [Date.now], "Function \"now\" timed-out after an unspecified duration.", undefined, "now" ]
      [ "timeout only", [4321], "An unspecified function timed-out after 4321 milliseconds.", 4321, undefined ]
      #
      [ "timeout and function", [1234, Date.now], "Function \"now\" timed-out after 1234 milliseconds.", 1234, "now" ]
      [ "function and timeout", [Date.now, 1234], "Function \"now\" timed-out after 1234 milliseconds.", 1234, "now" ]
      [ "message and timeout", ["TIMEOUT!",1234], "TIMEOUT!", 1234, undefined ]
      [ "timeout and message", [1234,"TIMEOUT!"], "TIMEOUT!", 1234, undefined ]
      [ "message and function", ["TIMEOUT!",Date.now], "TIMEOUT!", undefined, "now" ]
      [ "function and message", [Date.now,"TIMEOUT!"], "TIMEOUT!", undefined, "now" ]
      #
      [ "message and timeout and function", ["Timeout!", 1234, Date.now], "Timeout!", 1234, "now" ]
      [ "message and function and timeout", ["Timeout!", Date.now, 1234], "Timeout!", 1234, "now" ]
      [ "timeout and message and function", [1234, "Timeout!", Date.now], "Timeout!", 1234, "now" ]
      [ "timeout and function and message", [1234, Date.now, "Timeout!"], "Timeout!", 1234, "now" ]
      [ "function and timeout and message", [Date.now, 1234, "Timeout!"], "Timeout!", 1234, "now" ]
      [ "function and message and timeout", [Date.now, "Timeout!", 1234], "Timeout!", 1234, "now" ]
    ]
    for test in tests
      label = test[0]
      args = test[1]
      expected_message = test[2]
      expected_timeout = test[3]
      expected_function_name = test[4]
      err = new TimeoutError(args...)
      assert.ok err?
      assert.equal expected_message, err.message, "#{label} (message)"
      assert.equal expected_timeout, err.timeout, "#{label} (timeout)"
      assert.equal expected_function_name, err.function?.name, "#{label} (function name)"
    done()
