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
