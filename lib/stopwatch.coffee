# <i style="color:#666;font-size:80%">(Note: If you are viewing the [docco](http://jashkenas.github.io/docco/)-generated HTML version of this file, use the "Jump To..." menu in the upper right corner to navigate to the annotated versions of other source files.)</i>

# `Stopwatch` is a simple utility that can be used to track and
# report the time it takes to do some thing in your JavaScript
# code.
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

# ## The Implementation

# **Stopwatch** - *a simple timer.*

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

  # The `start` method generates a new timer object.
  start:(base={})->

    timer = {}

    # If any `base` object was provided, copy its properties into the timer.
    if base?
      for n,v of base
        timer[n] = v

    # `timer.start_time` contains the initial start time.
    timer.start_time = new Date()

    # `timer.stop()` stops the timer; it can only be stopped once.
    # Once stopped, the `finish_time` and `elapsed_time` value are calculated.
    timer.stop = ()->
      # If any lap times have been taken, add one final lap
      # (and make sure to reuse the *exact* same finish time as the final lap).
      if timer.laps?
        timer.lap()
        timer.finish_time = timer.laps[timer.laps.length-1].lap_finish_time
      # Otherwise use the current time.
      else
        timer.finish_time = new Date()

      # Elapsed time is simply the duration from start to finish.
      timer.elapsed_time = timer.finish_time - timer.start_time

      # Remove the `stop` and `lap` methods, this timer is done.
      delete timer.stop
      delete timer.lap

      return timer

    # `timer.lap()` records a lap-time in a (newly created) `timer.laps` array.
    # Each lap descriptor inclues `lap_start_time`, `lap_finish_time`,
    # `lap_time` and `lap_elapsed_time` (where `lap_time` is the duration of the
    # lap itself and `lap_elapsed_time` is the duration from the start of the
    # overall timer to the end of the lap).
    # an optional `label` can be associated with the lap
    timer.lap = (label)->
      lap_finish = new Date()
      if timer.laps?
        lap_start = timer.laps[timer.laps.length-1].lap_finish_time
      else
        lap_start = timer.start_time
      timer.laps ?= []
      timer.laps.push {
        lap_start_time: lap_start
        lap_finish_time: lap_finish
        lap_time: lap_finish - lap_start
        lap_elapsed_time: lap_finish - timer.start_time
        label: label
      }
      return timer
    return timer

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
