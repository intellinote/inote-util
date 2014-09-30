should    = require 'should'
fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join __dirname, '..'
LIB_COV   = path.join HOMEDIR, 'lib-cov'
LIB       = path.join HOMEDIR, 'lib'
LIB_DIR   = if fs.existsSync(LIB_COV) then LIB_COV else LIB
Stopwatch = require(path.join(LIB_DIR,'stopwatch')).Stopwatch

describe "Stopwatch",->

  beforeEach (done)->
    @method_started = false
    @method_finished = false
    @a_slow_method = ()=>
      @method_started = true
      foo = [1]
      for i in [1...1000]
        sum = 0
        for j in [0...i]
          sum += foo[j]
        foo[i] = j
      @method_finished = true
    done()

  it "can be used for timing \"inline\".", (done)->
    # start the timer
    timer = Stopwatch.start()
    # validate the initial state
    timer.should.exist
    timer.start_time.should.exist
    should.not.exist timer.finish_time
    should.not.exist timer.elapsed_time
    # run some method
    @a_slow_method()
    # stop the timer
    timer.stop()
    # validate the end state
    timer.start_time.should.exist
    timer.finish_time.should.exist
    timer.elapsed_time.should.exist
    timer.finish_time.should.be.above timer.start_time
    timer.elapsed_time.should.be.above 0
    should.not.exist timer.stop
    # validate that the method was executed
    @method_started.should.be.ok
    @method_finished.should.be.ok
    # done
    done()

  it "can be used to track \"lap\" times.", (done)->
    # start the timer
    timer = Stopwatch.start()
    # validate the initial state
    timer.start_time.should.exist
    should.not.exist timer.finish_time
    should.not.exist timer.elapsed_time
    should.not.exist timer.laps
    # run some method
    @a_slow_method()
    # mark the lap time
    timer.lap()
    # validate the intermediate state
    should.not.exist timer.finish_time
    should.not.exist timer.elapsed_time
    timer.laps.should.exist
    timer.laps.length.should.equal 1
    timer.laps[0].lap_start_time.should.equal timer.start_time
    timer.laps[0].lap_finish_time.should.exist
    timer.laps[0].lap_finish_time.should.be.above timer.laps[0].lap_start_time
    timer.laps[0].lap_time.should.equal (timer.laps[0].lap_finish_time - timer.laps[0].lap_start_time)
    timer.laps[0].lap_elapsed_time.should.equal (timer.laps[0].lap_finish_time - timer.start_time)
    # run some method
    @a_slow_method()
    # mark the lap time
    timer.lap()
    # validate the intermediate state
    should.not.exist timer.finish_time
    should.not.exist timer.elapsed_time
    timer.laps.should.exist
    timer.laps.length.should.equal 2
    timer.laps[1].lap_start_time.should.equal timer.laps[0].lap_finish_time
    timer.laps[1].lap_finish_time.should.exist
    timer.laps[1].lap_finish_time.should.be.above timer.laps[1].lap_start_time
    timer.laps[1].lap_time.should.equal (timer.laps[1].lap_finish_time - timer.laps[1].lap_start_time)
    timer.laps[1].lap_elapsed_time.should.equal (timer.laps[1].lap_finish_time - timer.start_time)
    # run some method
    @a_slow_method()
    # mark the lap time
    timer.lap()
    # validate the intermediate state
    should.not.exist timer.finish_time
    should.not.exist timer.elapsed_time
    timer.laps.should.exist
    timer.laps.length.should.equal 3
    timer.laps[2].lap_start_time.should.equal timer.laps[1].lap_finish_time
    timer.laps[2].lap_finish_time.should.exist
    timer.laps[2].lap_finish_time.should.be.above timer.laps[2].lap_start_time
    timer.laps[2].lap_time.should.equal (timer.laps[2].lap_finish_time - timer.laps[2].lap_start_time)
    timer.laps[2].lap_elapsed_time.should.equal (timer.laps[2].lap_finish_time - timer.start_time)
    # run some method
    @a_slow_method()
    # stop the timer
    timer.stop()
    # validate the end state
    timer.start_time.should.exist
    timer.finish_time.should.exist
    timer.elapsed_time.should.exist
    timer.finish_time.should.be.above timer.start_time
    timer.elapsed_time.should.be.above 0
    timer.laps.should.exist
    timer.laps.length.should.equal 4
    timer.laps[3].lap_start_time.should.equal timer.laps[2].lap_finish_time
    timer.laps[3].lap_finish_time.should.exist
    timer.laps[3].lap_finish_time.should.be.above timer.laps[3].lap_start_time
    timer.laps[3].lap_finish_time.should.equal timer.finish_time
    timer.laps[3].lap_time.should.equal (timer.laps[3].lap_finish_time - timer.laps[3].lap_start_time)
    timer.laps[3].lap_elapsed_time.should.equal (timer.laps[3].lap_finish_time - timer.start_time)
    timer.laps[3].lap_elapsed_time.should.equal timer.elapsed_time
    should.not.exist timer.stop
    should.not.exist timer.lap
    done()

  it "doesn't always give the same time.", (done)->
    result = []
    result[2] = Stopwatch.start()
    result[1] = Stopwatch.start()
    result[0] = Stopwatch.start().stop()
    @a_slow_method()
    result[1] = result[1].stop()
    @a_slow_method()
    result[2] = result[2].stop()
    result[2].elapsed_time.should.be.above result[1].elapsed_time
    result[1].elapsed_time.should.be.above result[0].elapsed_time
    done()

  it "can wrap a method in order to time it.", (done)->
    @method_started.should.not.be.ok
    @method_finished.should.not.be.ok
    result = Stopwatch.time @a_slow_method
    @method_started.should.be.ok
    @method_finished.should.be.ok
    result.should.exist
    result.start_time.should.exist
    result.finish_time.should.exist
    result.elapsed_time.should.exist
    result.finish_time.should.be.above result.start_time
    result.elapsed_time.should.be.above 0
    done()

  it "returns any provided data (wrapped)", (done)->
    @method_started.should.not.be.ok
    @method_finished.should.not.be.ok
    result = Stopwatch.time { alpha:1, beta:2 }, @a_slow_method
    @method_started.should.be.ok
    @method_finished.should.be.ok
    result.should.exist
    result.start_time.should.exist
    result.finish_time.should.exist
    result.elapsed_time.should.exist
    result.finish_time.should.be.above result.start_time
    result.elapsed_time.should.be.above 0
    result.alpha.should.equal 1
    result.beta.should.equal 2
    done()
