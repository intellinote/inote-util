# # Stopwatch
#
# A simple timer.
#
# ## Importing
#
#     SW = require('stopwatch').Stopwatch
#
# ## Basic Use
#
#     timer = SW.start();
#     // ...do something...
#     timer.stop();
#     console.log("Start Time:  ",timer.start_time);
#     console.log("Finish Time: ",timer.finish_time);
#     console.log("Elapsed Time:",timer.elapsed_time);
#
# ## Wrapped (Synchronous)
#
#     timer = SW.time( some_method );
#     console.log("some_method took",timer.elapsed_time,"millis to complete.");
#
# ## "Cookies"
#
# The `start` and `time` methods accept an optional map of attributes
# that will be bundled with the returned timer.  For example:
#
#     timer = SW.start({label:"foo"});
#     // ...do something...
#     timer.stop();
#     console.log(timer.label," Start Time:  ",timer.start_time);
#     console.log(timer.label,"Finish Time: ",timer.finish_time);
#     console.log(timer.label,"Elapsed Time:",timer.elapsed_time);
#
class Stopwatch

  # ## Methods

  # **start** - *start a new timer*
  #
  # Returns a running timer.
  #
  # The returned object will have a `stop()` method
  # by which to stop the timer and a `start_time` attribute
  # indicating the date and time at which the timer was started.
  #
  # Once stopped, the attributes `finish_time` and `elapsed_time`
  # will be available in the timer.
  #
  # Any properties of the optional `base` object will also be
  # availble in the returned timer.
  start:(base={})->
    data = {}
    if base?
      for n,v of base
        if base.hasOwnProperty n
          data[n] = v
    data.start_time = new Date()
    data.stop = ()->
      data.finish_time = new Date()
      data.elapsed_time = data.finish_time - data.start_time
      delete data.stop
      return data
    return data

  # **time** - *time a synchronous method*
  #
  # Runs the specified function, returning a stopped
  # timer indicating how long the function took to execute.
  #
  # Any properties of the optional `base` object will also be
  # availble in the returned timer.
  time:(base,fn)->
    if typeof base is 'function'
      fn = base
      base = fn
    timer = @start(base)
    fn()
    return timer.stop()

# ## Exports

# `Stopwatch` is exported as a singleton object.
exports.Stopwatch = new Stopwatch()
