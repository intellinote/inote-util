fs                   = require 'fs'
path                 = require 'path'
HOME_DIR             = path.join(__dirname,'..')
LIB_COV              = path.join(HOME_DIR,'lib-cov')
LIB_DIR              = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
#-------------------------------------------------------------------------------#
DEBUG                = (/(^|,)async-?util($|,)/i.test process?.env?.NODE_DEBUG)
#-------------------------------------------------------------------------------#
Util                 = require(path.join(LIB_DIR,'util')).Util
ExceptionThrownError = require(path.join(LIB_DIR,'exception-thrown-error')).ExceptionThrownError
TimeoutError         = require(path.join(LIB_DIR,'timeout-error')).TimeoutError
#-------------------------------------------------------------------------------#

class AsyncUtil

  # Invokes the specified async method, calling back with an error
  # if the method takes longer than the specified timeout.
  #
  # Parameters:
  #  * `method` - a function
  #  * `args` - an array of argumetns to be passed to the function (optional; defaults to `[]`)
  #  * `timeout` - timeout in milliseconds, or `true`  (optional; defaults to `1000`)
  #  * `callback` - will be called when the method completes or times out (but not both)
  #               - signature: `(timeout_or_thrown_error, method_callback_params...)`
  #
  # If the first argument passed to `callback` is `undefined` then the function executed normally.
  # If the first argument is a `TimeoutError` the method timed out before completing.
  # If the first argument is a `ExceptionThrownError` the call to `method(args...)` threw an exception.
  @invoke_with_timeout:(method, args, timeout, callback)->
    if not callback? and typeof timeout is 'function'
      callback  = timeout
      timeout = undefined
    if not callback? and typeof args is 'function'
      callback = args
      args = undefined
    if typeof args in ['number','boolean'] and not timeout?
      timeout = args
      args = undefined
    args ?= []
    if args? and not Array.isArray(args)
      args = [args]
    if not timeout? or timeout is true
      timeout = 1000
    called_back = false
    timer = AsyncUtil.wait timeout, ()->
      unless called_back
        called_back = true
        callback new TimeoutError(timeout, method)
    wrapped_callback = (callback_args...)->
      unless called_back
        called_back = true
        AsyncUtil.cancel_wait timer
        callback undefined, callback_args...
    args = args.concat [wrapped_callback]
    try
      method args...
    catch err
      unless called_back
        called_back = true
        AsyncUtil.cancel_wait timer
        callback new ExceptionThrownError(err, method)

  # emulates the signature and structure of `invoke_with_timeout`
  # but only usess the timeout if `timeout` is `true` or a positive integer
  @maybe_invoke_with_timeout:(method, args, timeout, callback)->
    if not callback? and typeof timeout is 'function'
      callback  = timeout
      timeout = undefined
    if not callback? and typeof args is 'function'
      callback = args
      args = undefined
    args ?= []
    if timeout?
      @invoke_with_timeout method, args, timeout, callback
    else
      called_back = false
      wrapped_callback = (callback_args...)->
        unless called_back
          called_back = true
          callback undefined, callback_args...
      args = args.concat [wrapped_callback]
      try
        method args...
      catch err
        unless called_back
          called_back = true
          callback new ExceptionThrownError(err, method)

  @wait_until:(predicate,delay,args...,callback)=>
    if typeof delay is 'function' and not callback?
      callback = delay
      delay = null
    delay = Util.to_int(delay)
    if delay? and delay < 0
      delay = null
    delay ?= 100
    interval_id = null
    action = ()=>
      process.nextTick ()=>
        wait_over = null
        err = null
        try
          wait_over = predicate()
        catch e
          err = e
        unless wait_over is false
          @cancel_interval(interval_id)
          callback?(err,wait_over)
          callback = null
    interval_id = @interval(delay, args..., action)
    return interval_id

  @wait_for:(predicate,delay,callback)=>return @wait_until(predicate,delay,callback)

  # Wait `delay` milliseconds then invoke `cb`.
  # Much like `setTimeout`, but with a more sensible argument sequence for CoffeeScript
  @wait:(delay,args...,cb)->
    fn = (args...)->
      process.nextTick ()->
        cb(args...)
    return setTimeout(fn, delay, args...)
  @set_timeout:(delay,args...,cb)=>
    return @wait(delay,args...,cb)
  @setTimeout:(delay,args...,cb)=>
    return @wait(delay,args...,cb)

  # Alias for `window.clearTimeout`
  @cancel_wait:(id)->
    clearTimeout(id)
  @cancelWait:(id)=>
    @cancel_wait(id)
  @cancelTimeout:(id)=>
    @cancel_wait(id)
  @cancel_timeout:(id)=>
    @cancel_wait(id)
  @clearTimeout:(id)=>
    @cancel_wait(id)
  @clear_timeout:(id)=>
    @cancel_wait(id)
  @clearWait:(id)=>
    @cancel_wait(id)
  @clear_wait:(id)=>
    @cancel_wait(id)

  # Like `setInterval`, but with a more sensible argument sequence for CoffeeScript
  @interval:(delay,args...,cb)->
    return setInterval(cb,delay,args...)
  @set_interval:(delay,args...,cb)=>
    return @interval(delay,args...,cb)
  @setInterval:(delay,args...,cb)=>
    return @interval(delay,args...,cb)

  # Alias for `window.clearInterval`
  @cancel_interval:(id)->
    clearInterval(id)
  @cancelInterval:(id)=>
    @cancel_interval(id)
  @clear_interval:(id)=>
    @cancel_interval(id)
  @clearInterval:(id)=>
    @cancel_interval(id)

  # TODO support timeouts in `for_async`
  # **for_async** - *executes an asynchronous `for` loop.*
  #
  # Accepts 5 function-valued parameters:
  #  * `initialize` - an initialization function (no arguments passed, no return value is expected)
  #  * `condition` - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned)
  #  * `action` - the action to take (a single callback function is passed and should be invoked at the end of the action, no return value is expected)
  #  * `increment` - called at the end of every `action`, prior to `condition`  (no arguments passed, no return value is expected)
  #  * `whendone` - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected)
  #
  # For example, the loop:
  #
  #     for(var i=0; i<10; i++) { console.log(i); }
  #
  # could be implemented as:
  #
  #     var i;
  #     init = function() { i = 0; }
  #     cond = function() { return i < 10; }
  #     actn = function(next) { console.log(i); next(); }
  #     incr = function() { i = i + 1; }
  #     done = function() { }
  #     for_async(init,cond,actn,incr,done)
  #
  @for_async:(initialize,condition,action,increment,options,whendone)=>
    if typeof options is "function" and not whendone?
      whendone = options
      options = undefined
    timeout = options?.timeout
    looper = ()->
      if condition()
        action ()->
          increment()
          looper()
      else
        whendone() if whendone?
    initialize()
    looper()

  # TODO support timeouts in `for_each_async`
  # **for_each_async** - *executes an asynchronous `forEach` loop.*
  #
  # Accepts 3 parameters:
  #  * `list` - the array to iterate over
  #  * `action` - the function with the signature (value,index,list,next) indicating the action to take; the provided function `next` *must* be called at the end of processing
  #  * `whendone` - called at the end of the loop
  #
  # For example, the loop:
  #
  #     [0..10].foreach (elt,index,array)-> console.log elt
  #
  # could be implemented as:
  #
  #     for_each_async [0..10], (elt,index,array,next)->
  #       console.log elt
  #       next()
  #
  @for_each_async:(list,action,whendone)=>
    i = null
    init = ()-> i = 0
    cond = ()-> (i < list.length)
    incr = ()-> i += 1
    act  = (next)-> action(list[i],i,list,next)
    @for_async(init, cond, act, incr, whendone)

  @fork_for_each_async:(list,action,whendone)=>
    methods = list.map ()->action
    args = []
    for elt,i in list
      args.push([ elt, i, list ])
    @fork methods, args, whendone

  @throttled_fork_for_each_async:(max_parallel,list,action,options,whendone)=>
    if typeof options is "function" and not whendone?
      whendone = options
      options = undefined
    methods = list.map ()->action
    args = []
    for elt,i in list
      args.push [ elt, i, list ]
    @throttled_fork max_parallel, methods, args, options, whendone

  # Run the given array of methods asynchronously, invoking `callback` when done
  # - `methods` - an array of methods
  # - `args_for_methods` - an array of arrays; the contents of each array (plus a callback method) with be passed to the corresponding `method` when invoked
  # - `callback` - the method called when all methods have completed; the single argument passed to `callback` will be an array containing the arguments passed to each method's callback (as an array)
  @fork:(methods, args_for_methods, callback)->
    if (not callback?) and (typeof args_for_methods is 'function')
      callback = args_for_methods
      args_for_methods = null
    results = []
    remaining_callbacks = methods.length
    for method, index in methods
      do (method,index)->
        method_args = args_for_methods?[index] ? []
        unless Array.isArray(method_args)
          method_args = [method_args]
        method method_args..., (callback_args...)->
          results[index] = callback_args
          remaining_callbacks--
          if remaining_callbacks is 0
            callback(results)

  # Just like `fork` save that at most `max_parallel` methods will run at any one time
  @throttled_fork:(max_parallel, methods, args_for_methods, options, callback)->
    if (not callback?) and typeof options is 'function'
      callback = options
      options = undefined
    if (not callback?) and typeof args_for_methods is 'function'
      callback = args_for_methods
      args_for_methods = undefined
    timeout = options?.timeout
    results = []
    errors = []
    currently_running = 0
    next_to_run = 0
    remaining_callbacks = methods.length
    run_more = ()->
      while (currently_running < max_parallel) and (next_to_run < methods.length)
        index = next_to_run
        currently_running++
        next_to_run++
        do (index)->
          method_args = args_for_methods?[index] ? []
          unless Array.isArray(method_args)
            method_args = [method_args]
          method = methods[index]
          after_method = (err, callback_args...)->
            results[index] = callback_args
            errors[index] = err
            currently_running--
            remaining_callbacks--
            if remaining_callbacks is 0
              callback(results, errors)
            else
              run_more()
          try
            if timeout?
              AsyncUtil.invoke_with_timeout method, method_args, timeout, (timed_out, callback_args...)->
                if timed_out?
                  after_method timed_out
                else
                  after_method undefined, callback_args...
            else
              method method_args..., (callback_args...)->
                after_method undefined, callback_args...
          catch err
            after_method new ExceptionThrownError(err, method)

    run_more()


  # **procedure** - *generates a new `Sequencer` object, as described below.*
  @procedure:()=>(new Sequencer())

################################################################################

# **Sequencer** - *a simple asynchronous-method-chaining utility*
#
# The `Sequencer` class provides a simple utility for
# chaining together callback-based methods in a more "linear"
# style.
#
# For example, rather than writing (in CoffeeScript):
#
#     method_one ()=>
#       method_two ()=>
#         method_three ()=>
#           and_so_on ()=>
#
# We can flatten the calls out like this:
#
#     procedure = Util.procedure()
#     procedure.first( method_one )
#     procedure.then( method_two )
#     procedure.then( method_three )
#     procedure.then( and_so_on )
#     procedure.run()
#
# Each call to `then` appends the given callback method
# to the chain.
#
# Each callback method is passed a `next_step` function that *must*
# be called to trigger the next step in the processing.
#
# Hence the typical use of the class looks something like this:
#
#     s = new Sequencer()
#     s.first (done)->
#        # do something, then invoke the callback
#        done()
#     s.next (done)->
#        # do something else, then invoke the callback
#        done()
#     s.next (done)->
#        # do one more thing, then invoke the callback
#        done()
#     s.run()
#
# When `run` is invoked, each asynchronous  method is executed in sequence.
#
# The `first` method is optional (you can just use `next` instead), but when
# invoked `first` will remove any methods previously added to the chain.
#
# You `last` methods is an optional short-hand for adding one final method to
# the chain and then running it.  E.g., the last two lines of our example:
#
#     procedure.then( and_so_on )
#     procedure.run()
#
# Could be re-written:
#
#     procedure.last( and_so_on )
#
# Note that the sequence is not cleared when `run` is invoked, so one may
# invoke `run` more than once to execute the sequence again.
#
#coffeelint:disable=no_this
class Sequencer
  constructor:()->
    @list = []

  # `first` removes any methods previously added to
  # the chain, and then adds the given method to
  # the newly empty list.
  first:(step)=>
    @list = []
    @list.push step
    return this

  # `next` adds a new method to the chain
  next:(step)=>
    @list.push step
    return this

  # `then` is an alias for `next`
  then:(step)=>@next(step)

  # `last` will add the given method to the chain
  # and then invoke `run(callback)` to execute the
  # entire procedure.
  last:(step,callback)=>
    @next(step)
    @run(callback)
    return this

  # `finally` is an alias for `last`
  finally:(step,callback)=>@last(step,callback)

  # `run` will execute each function in the chain in sequence.
  # When a `callback` method is provided it will be
  # invoked after all methods in the chain have completed execution.
  run:(args...,callback)=>
    action = (step,index,list,next)=>
      step args..., (new_args...)=>
        args = new_args
        next()
    AsyncUtil.for_each_async @list,action,()=>callback?(args...)
    return this

  # Note that each `Sequencer` method returns the `Sequencer` object
  # itself.  Hence given (predefined) functions `a`, `b`, and `c`,
  # one could invoke:
  #
  #     (new Sequencer()).first(a).then(b).finally(c)
  #
#coffeelint:enable=no_this

exports.AsyncUtil = AsyncUtil
exports.Sequencer = Sequencer
