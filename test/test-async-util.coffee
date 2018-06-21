require 'coffee-errors'
#------------------------------------------------------------------------------#
should   = require 'should'
assert   = require 'assert'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
AsyncUtil = require(path.join(LIB_DIR,'async-util')).AsyncUtil
Sequencer = require(path.join(LIB_DIR,'async-util')).Sequencer

describe 'AsyncUtil',->

  it "invoke_with_timeout will execute the given method", (done)=>
    cb = (timed_out, err, msg)->
      assert.ok not timed_out?, timed_out
      assert.ok not err?, err
      assert.equal msg, "OK"
      done()
    method = (arg1, arg2, callback)->
      AsyncUtil.wait 100, ()->
        assert.equal arg1, "one"
        assert.equal arg2, 2
        callback(undefined,"OK")
    AsyncUtil.invoke_with_timeout method, ["one", 2], cb

  it "invoke_with_timeout will call-back if the given method takes too long to complete", (done)=>
    cb = (timed_out, err, msg)->
      assert.ok timed_out?
      done()
    method = (arg1, arg2, callback)->
      AsyncUtil.wait 100, ()->
        assert.equal arg1, "one"
        assert.equal arg2, 2
        callback(undefined,"OK")
    AsyncUtil.invoke_with_timeout method, ["one", 2], 50, cb

  it "invoke_with_timeout will call-back if the given method throws an error", (done)=>
    cb = (error_found, err, msg)->
      assert.ok error_found?
      done()
    method = (arg1, arg2, callback)->
      assert.equal arg1, "one"
      assert.equal arg2, 2
      throw new Error("dummy error")
    AsyncUtil.invoke_with_timeout method, ["one", 2], cb

  it "wait is like setTimeout but with a more coffee-friendly API", (done)=>
    DELAY = 20
    start_time = Date.now()
    fn = (arg1, arg2)->
      stop_time = Date.now()
      assert.ok stop_time-start_time >= DELAY
      assert.equal arg1, "arg-one"
      assert.equal arg2, 2
      done()
    AsyncUtil.wait DELAY, "arg-one", 2, fn

  it "wait returns a timer-id that can be used to cancel the timer", (done)=>
    DELAY = 20
    fn1_called = false
    fn1 = ()->
      fn1_called = true
      assert.fail "Expected this function to be cancelled."
    fn2 = ()->
      assert.ok not fn1_called, "Expected fn1 to be cancelled but it was called instead."
      done()
    id1 = AsyncUtil.wait DELAY, fn1
    id2 = AsyncUtil.wait DELAY*1.5, fn2
    assert.ok id1?
    assert.ok id2?
    AsyncUtil.cancel_wait id1

  it "set_timeout returns a timer-id that can be used to cancel the timer", (done)=>
    DELAY = 20
    fn1_called = false
    fn1 = ()->
      fn1_called = true
      assert.fail "Expected this function to be cancelled."
    fn2 = ()->
      assert.ok not fn1_called, "Expected fn1 to be cancelled but it was called instead."
      done()
    id1 = AsyncUtil.set_timeout DELAY, fn1
    id2 = AsyncUtil.set_timeout DELAY*1.5, fn2
    assert.ok id1?
    assert.ok id2?
    AsyncUtil.cancel_wait id1

  it "interval is like setInterval but with a more coffee-friendly API", (done)=>
    DELAY = 15
    call_count = 0
    start_time = Date.now()
    id = null
    fn = (arg1, arg2)->
      call_count += 1
      if call_count is 2
        stop_time = Date.now()
        AsyncUtil.cancel_interval id
        assert.ok stop_time-start_time >= DELAY*2
        assert.ok stop_time-start_time <= DELAY*3
        assert.equal arg1, "arg-one"
        assert.equal arg2, 2
        done()
      else
        assert.ok call_count < 2
    id = AsyncUtil.interval DELAY, "arg-one", 2, fn

  it "set_interval is like setInterval but with a more coffee-friendly API", (done)=>
    DELAY = 15
    call_count = 0
    start_time = Date.now()
    id = null
    fn = (arg1, arg2)->
      call_count += 1
      if call_count is 2
        stop_time = Date.now()
        AsyncUtil.cancel_interval id
        assert.ok stop_time-start_time >= DELAY*2
        assert.ok stop_time-start_time <= DELAY*3
        assert.equal arg1, "arg-one"
        assert.equal arg2, 2
        done()
      else
        assert.ok call_count < 2
    id = AsyncUtil.set_interval DELAY, "arg-one", 2, fn


  it "setInterval is like setInterval but with a more coffee-friendly API", (done)=>
    DELAY = 15
    call_count = 0
    start_time = Date.now()
    id = null
    fn = (arg1, arg2)->
      call_count += 1
      if call_count is 2
        stop_time = Date.now()
        AsyncUtil.cancelInterval id
        assert.ok stop_time-start_time >= DELAY*2
        assert.ok stop_time-start_time <= DELAY*3
        assert.equal arg1, "arg-one"
        assert.equal arg2, 2
        done()
      else
        assert.ok call_count < 2
    id = AsyncUtil.setInterval DELAY, "arg-one", 2, fn


  it "for_each_async can execute an async for-each loop", (done)=>
    numbers = [1..100]
    total = 0
    count = 0
    action = (number, index, list, next)=>
      count++
      total += number
      index.should.equal (number-1)
      index.should.equal (count-1)
      list.length.should.equal numbers.length
      next()
    AsyncUtil.for_each_async numbers, action, ()=>
      total.should.equal 5050
      count.should.equal numbers.length
      done()

  it "procedure can execute a series of async steps", (done)=>
    step_one_executed = false
    step_two_executed = false
    step_three_executed = false
    step_one = (next)=>
      step_one_executed.should.equal false
      step_two_executed.should.equal false
      step_three_executed.should.equal false
      step_one_executed = true
      next("foo","bar")
    step_two = (foo,bar,next)=>
      foo.should.equal "foo"
      bar.should.equal "bar"
      step_one_executed.should.equal true
      step_two_executed.should.equal false
      step_three_executed.should.equal false
      step_two_executed = true
      next()
    step_three = ()=>
      step_one_executed.should.equal true
      step_two_executed.should.equal true
      step_three_executed.should.equal false
      step_three_executed = true
      done()
    P = AsyncUtil.procedure()
    P.first step_one
    P.then step_two
    P.finally step_three

  it "wait_until can wait for a condition to be true", (done)=>
    start_time = Date.now()
    target = 20
    times_run = 0
    predicate = ()=>
      times_run++
      return (Date.now() - start_time) >= target
    AsyncUtil.wait_until predicate, 5, (err,complete)=>
      initial_times_run = times_run
      should.not.exist err
      complete.should.equal true
      times_run.should.be.above 1
      AsyncUtil.wait target, ()=>
        times_run.should.equal initial_times_run
        done()

  it "wait_for is an alias for wait_until and treats negative delay (and null delay) as default delay", (done)=>
    start_time = Date.now()
    target = 200
    times_run = 0
    predicate = ()=>
      times_run++
      return (Date.now() - start_time) >= target
    AsyncUtil.wait_for predicate, -10, (err,complete)=>
      initial_times_run = times_run
      should.not.exist err
      complete.should.equal true
      times_run.should.be.above 1
      AsyncUtil.wait target, ()=>
        times_run.should.equal initial_times_run
        done()

  it "wait_until passes error to callback when encountered", (done)=>
    start_time = Date.now()
    target = 300
    times_run = 0
    predicate = ()=>
      times_run++
      if (Date.now() - start_time) >= target
        throw new Error("Mock Error")
      else
        return false
    AsyncUtil.wait_until predicate, (err,complete)=>
      should.exist err
      should.not.exist complete
      times_run.should.be.above 1
      done()

  it "fork runs methods in parallel", (done)=>
    method_one_started = false
    method_one_val = null
    method_one_finished = false
    method_two_started = false
    method_two_finished = false
    method_two_val_one = null
    method_two_val_two = null
    method_one = (val, next)=>
      method_one_started = true
      method_one_val = val
      AsyncUtil.wait 10, ()=>
        method_two_started.should.be.ok
        method_two_finished.should.not.be.ok
      AsyncUtil.wait 400, ()=>
        method_two_started.should.be.ok
        method_two_finished.should.be.ok
        method_one_finished = true
        next("ABC",val)
    method_two = (val1, val2, next)=>
      method_two_started = true
      method_two_val_one = val1
      method_two_val_two = val2
      AsyncUtil.wait 10, ()=>
        method_one_started.should.be.ok
        method_one_finished.should.not.be.ok
      AsyncUtil.wait 200, ()=>
        method_one_started.should.be.ok
        method_one_finished.should.not.be.ok
        method_two_finished = true
        next("XYZ",val1, val2)
    when_done = (results)=>
      results.length.should.equal 2
      results[0].length.should.equal 2
      results[0][0].should.equal "ABC"
      results[0][1].should.equal "abc"
      results[1].length.should.equal 3
      results[1][0].should.equal "XYZ"
      results[1][1].should.equal "x"
      results[1][2].should.equal "yz"
      method_one_finished.should.be.ok
      method_two_finished.should.be.ok
      done()
    methods = [ method_one, method_two ]
    args = [ [ "abc" ], ["x","yz"] ]
    AsyncUtil.fork methods, args, when_done

  it "fork_for_each_async works", (done)=>
    args = [0...5]
    ran = args.map ()->false
    action = (elt, index, list, next)=>
      elt.should.equal index
      ran[elt].should.not.be.ok
      ran[elt] = true
      next(elt)
    when_done = (results)=>
      for i in args
        results[i][0].should.equal i
      for elt in ran
        elt.should.be.ok
      done()
    AsyncUtil.fork_for_each_async args, action, when_done

  it "throttled_fork_for_each_async works", (done)=>
    args = [0...10]
    ran = args.map ()->false
    running = args.map ()->false
    num_true = (list)->
      count = 0
      for elt in list
        if elt
          count++
      return count
    action = (elt, index, list, next)=>
      elt.should.equal index
      running[elt] = true
      num_true(running).should.be.below 5
      ran[elt].should.not.be.ok
      AsyncUtil.wait 200, ()->
        num_true(running).should.be.below 5
        ran[elt] = true
        running[elt] = false
        next(elt)
    when_done = (results)=>
      for i in args
        results[i][0].should.equal i
      for elt in ran
        elt.should.be.ok
      for elt in running
        elt.should.not.be.ok
      done()
    AsyncUtil.throttled_fork_for_each_async 4, args, action, when_done

  it "throttled_fork_for_each_async works even when one of the methods throws an exception", (done)=>
    args = [0...10]
    ran = args.map ()->false
    running = args.map ()->false
    num_true = (list)->
      count = 0
      for elt in list
        if elt
          count++
      return count
    action = (elt, index, list, next)=>
      elt.should.equal index
      running[elt] = true
      num_true(running).should.be.below 5
      ran[elt].should.not.be.ok
      if elt%3 is 0
        num_true(running).should.be.below 5
        ran[elt] = true
        running[elt] = false
        throw new Error("Mock error")
      else
        AsyncUtil.wait 200, ()->
          num_true(running).should.be.below 5
          ran[elt] = true
          running[elt] = false
          next(elt)
    when_done = (results, errors)=>
      for i in args
        if i%3 is 0
          errors[i].should.be.ok
        else
          results[i][0].should.equal i
      for elt in ran
        elt.should.be.ok
      for elt in running
        elt.should.not.be.ok
      done()
    AsyncUtil.throttled_fork_for_each_async 4, args, action, when_done

  it "throttled fork limits the number of methods running in parallel", (done)=>
    NUM_METHODS = 5
    LIMIT = 3
    args = [0...NUM_METHODS]
    order_done = []
    running = args.map ()->false
    ran = args.map ()->false
    num_true = (list)->
      count = 0
      for elt in list
        if elt
          count++
      return count
    method = (step,next)->
      num_true(running).should.be.below LIMIT+1
      running[step] = true
      AsyncUtil.wait ((1+args.length)*100)-(step*100), ()->
        num_true(running).should.be.below LIMIT+1
        running[step] = false
        order_done.push step
        ran[step] = true
        next(step)
    methods = args.map ()->method
    AsyncUtil.throttled_fork LIMIT, methods, args, (results)=>
      # with throttle=3, methods 0,1,2 start at the same time:
      # at t=000 : start 0,1,2 running for 600, 500, 400 respectively
      # at t=400 : end 2, start 3 running for 300
      # at t=500 : end 1, start 4 running for 200
      # at t=600 : end 0
      # at t=700 : end 4
      for step, i in [ 2, 1, 0 ]
        order_done[i].should.equal step
      for i in args
        results[i][0].should.equal i
      for elt in running
        elt.should.not.be.ok
      for elt in ran
        elt.should.be.ok
      done()

  it "throttled fork runs all the methods", (done)=>
    NUM_METHODS = 7
    LIMIT = 3
    args = [0...NUM_METHODS]
    running = args.map ()->false
    ran = args.map ()->false
    num_true = (list)->
      count = 0
      for elt in list
        if elt
          count++
      return count
    method = (step,next)->
      num_true(running).should.be.below LIMIT+1
      running[step] = true
      AsyncUtil.wait 30, ()->
        num_true(running).should.be.below LIMIT+1
        running[step] = false
        ran[step] = true
        next(step)
    methods = args.map ()->method
    AsyncUtil.throttled_fork LIMIT, methods, args, (results)=>
      for i in args
        results[i][0].should.equal i
      for elt in running
        elt.should.not.be.ok
      for elt in ran
        elt.should.be.ok
      done()

  it "throttled fork keeps going even if an exception is thrown by one of the methods", (done)=>
    NUM_METHODS = 7
    LIMIT = 3
    THROW_FOR_METHODS = [2,5,6]
    args = [0...NUM_METHODS]
    running = args.map ()->false
    ran = args.map ()->false
    num_true = (list)->
      count = 0
      for elt in list
        if elt
          count++
      return count
    method = (step,next)->
      num_true(running).should.be.below LIMIT+1
      running[step] = true
      if step in THROW_FOR_METHODS
        num_true(running).should.be.below LIMIT+1
        running[step] = false
        ran[step] = true
        throw new Error("Dummy exception #{step}.")
      else
        AsyncUtil.wait 30, ()->
          num_true(running).should.be.below LIMIT+1
          running[step] = false
          ran[step] = true
          next(step)
    methods = args.map ()->method
    AsyncUtil.throttled_fork LIMIT, methods, args, (results , errors)=>
      for i in args
        unless i in THROW_FOR_METHODS
          results[i][0].should.equal i
        else
          errors[i].should.be.ok
      for elt, i in running
        elt.should.not.be.ok
      for elt, i in ran
        elt.should.be.ok
      done()

  it "throttled fork keeps going even if an one of the methods times out", (done)=>
    NUM_METHODS = 7
    LIMIT = 3
    DELAY_FOR = [2,5]
    timed_out = []
    args = [0...NUM_METHODS]
    running = args.map ()->false
    ran = args.map ()->false
    num_true = (list)->
      count = 0
      for elt in list
        if elt
          count++
      return count
    method = (step,next)->
      num_true(running).should.be.below LIMIT+1
      running[step] = true
      if step in DELAY_FOR
        num_true(running).should.be.below LIMIT+1
        running[step] = false
        AsyncUtil.wait 2000, ()->
          ran[step] = true
      else
        AsyncUtil.wait 30, ()->
          num_true(running).should.be.below LIMIT+1
          running[step] = false
          ran[step] = true
          next(step)
    methods = args.map ()->method
    AsyncUtil.throttled_fork LIMIT, methods, args, {timeout:60}, (results , errors)=>
      for i in args
        unless i in DELAY_FOR
          results[i][0].should.equal i
        else
          errors[i].should.be.ok
      for elt, i in running
        elt.should.not.be.ok
      for elt, i in ran
        assert.equal elt, (not (i in DELAY_FOR))
      done()
