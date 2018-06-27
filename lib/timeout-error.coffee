# coffeelint:disable=no_stand_alone_at
class TimeoutError
  constructor:(args...)-> #@message,@timeout,@function
    args ?= []
    for arg, i in args
      if i >= 3
        break
      else
        switch typeof arg
          when 'function'
            @function = arg
          when 'number'
            @timeout = arg
          when 'string'
            @message = arg
    #
    @name = @constructor.name
    @stack = (new Error()).stack
    #
    unless @message? and @message.length > 0
      if @timeout? and @function?
        if typeof @function is 'function' and @function.name?
          function_name = @function.name
        else
          function_name = @function
        @message = "Function \"#{function_name}\" timed-out after #{@timeout} milliseconds."
      else if @timeout? and (not @function?)
        @message = "An unspecified function timed-out after #{@timeout} milliseconds."
      else if (not @timeout?) and @function?
        if typeof @function is 'function' and @function.name?
          function_name = @function.name
        else
          function_name = @function
        @message = "Function \"#{function_name}\" timed-out after an unspecified duration."
      else
        @message = "An unspecified function timed-out after an unspecified duration."
    Error.captureStackTrace(@, @constructor)
  @:: = new Error()
  @::constructor = @
# coffeelint:enable=no_stand_alone_at

exports.TimeoutError = TimeoutError
