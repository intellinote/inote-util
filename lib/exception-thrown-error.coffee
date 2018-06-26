# coffeelint:disable=no_stand_alone_at
class ExceptionThrownError
  constructor:(args...)-> #@message,@exception,@function
    args ?= []
    for arg, i in args
      if i >= 3
        break
      else
        switch typeof arg
          when 'function'
            @function = arg
          when 'object'
            if arg?
              @exception = @error = arg
          when 'string'
            @message = arg
    #
    @name = @constructor.name
    @stack = (new Error()).stack
    #
    unless @message? and @message.length > 0
      if @exception? and @function?
        if typeof @function is 'function' and @function.name?
          function_name = @function.name
        else
          function_name = @function
        @message = "Function \"#{function_name}\" threw the uncaught exception \"#{@exception}\"."
      else if @exception? and (not @function?)
        @message = "An unspecified function threw the uncaught exception \"#{@exception}\"."
      else if (not @exception?) and @function?
        if typeof @function is 'function' and @function.name?
          function_name = @function.name
        else
          function_name = @function
        @message = "Function \"#{function_name}\" threw an uncaught, unspecified exception."
      else
        @message = "An unspecified function threw an uncaught, unspecified exception."
    Error.captureStackTrace(@, @constructor)
  @:: = new Error()
  @::constructor = @
# coffeelint:enable=no_stand_alone_at

exports.ExceptionThrownError = ExceptionThrownError
