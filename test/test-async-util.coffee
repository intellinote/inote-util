require 'coffee-errors'
#------------------------------------------------------------------------------#
should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
AsyncUtil = require(path.join(LIB_DIR,'async-util')).AsyncUtil
Sequencer = require(path.join(LIB_DIR,'async-util')).Sequencer

describe 'AsyncUtil',->

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
    target = 300
    times_run = 0
    predicate = ()=>
      times_run++
      return (Date.now() - start_time) >= target
    AsyncUtil.wait_until predicate, 10, (err,complete)=>
      initial_times_run = times_run
      should.not.exist err
      complete.should.equal true
      times_run.should.be.above 1
      AsyncUtil.wait target, ()=>
        times_run.should.equal initial_times_run
        done()

  it "wait_for is an alias for wait_until and treats negative delay (and null delay) as default delay", (done)=>
    start_time = Date.now()
    target = 300
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

  it "throttled fork limits the number of methods running in parallel", (done)=>
    args = [0...5]
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
      num_true(running).should.be.below 4
      running[step] = true
      AsyncUtil.wait ((1+args.length)*100)-(step*100), ()->
        num_true(running).should.be.below 4
        running[step] = false
        order_done.push step
        ran[step] = true
        next(step)

    args = [0...5]
    methods = args.map ()->method
    AsyncUtil.throttled_fork 3, methods, args, (results)=>
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
      for elt of running
        elt.should.not.be.ok
      for elt of ran
        elt.should.be.ok
      done()
