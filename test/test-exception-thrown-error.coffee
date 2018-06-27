require 'coffee-errors'
#------------------------------------------------------------------------------#
assert               = require 'assert'
fs                   = require 'fs'
path                 = require 'path'
HOME_DIR             = path.join(__dirname, '..')
LIB_COV              = path.join(HOME_DIR, 'lib-cov')
LIB_DIR              = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
ExceptionThrownError = require(path.join(LIB_DIR,'exception-thrown-error')).ExceptionThrownError


describe 'ExceptionThrownError',->
  # constructor:(@message,@timeout,@method)->

  it "constructor accepts various optional parameters", (done)=>
    the_error = null
    try
      will_fail = new ThisDoesNotExist()
    catch err
      the_error = err
    tests = [
      [ "no args", [], "An unspecified function threw an uncaught, unspecified exception.", undefined, undefined ]
      [ "error only", [the_error], "An unspecified function threw the uncaught exception \"ReferenceError: ThisDoesNotExist is not defined\".", the_error, undefined ]
      [ "function only", [Date.now], "Function \"now\" threw an uncaught, unspecified exception.", undefined, "now" ]
      [ "message only", ["ERR!"], "ERR!", undefined, undefined ]
      #
      [ "error and function", [the_error, Date.now], "Function \"now\" threw the uncaught exception \"ReferenceError: ThisDoesNotExist is not defined\".", the_error, "now" ]
      [ "function and error", [Date.now, the_error], "Function \"now\" threw the uncaught exception \"ReferenceError: ThisDoesNotExist is not defined\".", the_error, "now" ]
      [ "error and message", [the_error, "Error"], "Error", the_error, undefined ]
      [ "message and error", ["Error", the_error], "Error", the_error, undefined ]
      [ "function and message", [Date.now, "Error"], "Error", undefined, "now" ]
      [ "message and function", ["Error", Date.now], "Error", undefined, "now" ]
      #
      [ "mesage and error and function", ["Oops.", the_error, Date.now], "Oops.", the_error, "now" ]
      [ "mesage and function and error", ["Oops.", Date.now, the_error], "Oops.", the_error, "now" ]
      [ "function and error and message", [Date.now, the_error, "Error"], "Error", the_error, "now" ]
      [ "function and message and error", [Date.now, "Error", the_error], "Error", the_error, "now" ]
      [ "error and function and message", [the_error, Date.now, "Error"], "Error", the_error, "now" ]
      [ "error and message and function", [the_error, "Error", Date.now], "Error", the_error, "now" ]
    ]
    for test in tests
      label = test[0]
      args = test[1]
      expected_message = test[2]
      expected_exception = test[3]
      expected_function_name = test[4]
      err = new ExceptionThrownError(args...)
      assert.ok err?
      assert.equal expected_message, err.message, "#{label} (message)"
      assert.equal expected_exception, err.exception, "#{label} (exception)"
      assert.equal expected_exception, err.error, "#{label} (error)"
      assert.equal expected_function_name, err.function?.name, "#{label} (function name)"
    done()
