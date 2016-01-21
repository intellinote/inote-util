fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
MapUtil    = require(path.join(LIB_DIR,'object-util')).MapUtil
uuid       = require 'node-uuid'
crypto     = require 'crypto'
mkdirp     = require 'mkdirp'
request    = require 'request'
remove     = require 'remove'
seedrandom = require 'seedrandom'
DEBUG      = (/(^|,)inote-?util($|,)/i.test process?.env?.NODE_DEBUG) or (/(^|,)Util($|,)/.test process?.env?.NODE_DEBUG)

################################################################################

class LogUtil
  @_fdt:(d)=>"[#{(d ? new Date()).toISOString()}]"
  @tlog:(args...)=>console.log @_fdt(),args...
  @terr:(args...)=>console.error @_fdt(),args...

class DateUtil

  @DAY_OF_WEEK = [
    "Sunday"
    "Monday"
    "Tuesday"
    "Wednesday"
    "Thursday"
    "Friday"
    "Saturday"
  ]

  @MONTH = [
    "January"
    "February"
    "March"
    "April"
    "May"
    "June"
    "July"
    "August"
    "September"
    "October"
    "November"
    "December"
  ]

  @format_datetime_long:(dt = new Date())=>
    if typeof dt is 'string'
      try
        dt = new Date(dt)
      catch e
        return null
    return "#{@format_date_long(dt)} at #{@format_time_long(dt)}"

  @format_time_long:(dt = new Date())=>
    hours = dt.getUTCHours() % 12
    if hours is 0
      hours = 12
    minutes = dt.getUTCMinutes()
    if minutes < 10
      minutes = "0#{minutes}"
    if dt.getUTCHours() > 12
      ampm = "PM"
    else
      ampm = "AM"
    return "#{hours}:#{minutes} #{ampm} GMT"

  @format_date_long:(dt = new Date())=>
    if typeof dt is 'string'
      try
        dt = new Date(dt)
      catch e
        return null
    return "#{@DAY_OF_WEEK[dt.getUTCDay()]} #{dt.getUTCDate()} #{@MONTH[dt.getUTCMonth()]} #{dt.getUTCFullYear()}"

  @to_unit:(value,singular,plural)=>
    unless plural?
      plural = "#{singular}s"
    if value is 1 or value is -1
      return "#{value} #{singular}"
    else
      return "#{value} #{plural}"

  @start_time: Date.now()

  @duration:(now,start)=>
    start ?= @start_time
    now ?= Date.now()
    if start instanceof Date
      start = start.getTime()
    if now instanceof Date
      now = now.getTime()
    #
    result       = {}
    result.begin = start
    result.end   = now
    result.delta = now - start
    #
    duration                 = result.delta
    result.in_millis         = {}
    result.in_millis.millis  = duration % (1000)
    duration                -= result.in_millis.millis
    result.in_millis.seconds = duration % (1000 * 60)
    duration                -= result.in_millis.seconds
    result.in_millis.minutes = duration % (1000 * 60 * 60)
    duration                -= result.in_millis.minutes
    result.in_millis.hours   = duration % (1000 * 60 * 60 * 24)
    duration                -= result.in_millis.hours
    result.in_millis.days    = duration % (1000 * 60 * 60 * 24 * 7)
    duration                -= result.in_millis.days
    result.in_millis.weeks   = duration % (1000 * 60 * 60 * 24 * 7 * 52)
    duration                -= result.in_millis.weeks
    result.in_millis.years   = duration
    #
    result.raw         = {}
    result.raw.millis  = result.in_millis.millis
    result.raw.seconds = result.in_millis.seconds / (1000)
    result.raw.minutes = result.in_millis.minutes / (1000 * 60)
    result.raw.hours   = result.in_millis.hours   / (1000 * 60 * 60)
    result.raw.days    = result.in_millis.days    / (1000 * 60 * 60 * 24)
    result.raw.weeks   = result.in_millis.weeks   / (1000 * 60 * 60 * 24 * 7)
    result.raw.years   = result.in_millis.years   / (1000 * 60 * 60 * 24 * 7 * 52)
    #
    result.whole         = {}
    result.whole.millis  = Math.round(result.raw.millis)
    result.whole.seconds = Math.round(result.raw.seconds)
    result.whole.minutes = Math.round(result.raw.minutes)
    result.whole.hours   = Math.round(result.raw.hours)
    result.whole.days    = Math.round(result.raw.days)
    result.whole.weeks   = Math.round(result.raw.weeks)
    result.whole.years   = Math.round(result.raw.years)
    #
    result.array = {}
    result.array.full = {}
    result.array.full.values = [
      result.whole.years
      result.whole.weeks
      result.whole.days
      result.whole.hours
      result.whole.minutes
      result.whole.seconds
      result.whole.millis
    ]
    result.array.full.short  = [
      "#{result.whole.years}y"
      "#{result.whole.weeks}w"
      "#{result.whole.days}d"
      "#{result.whole.hours}h"
      "#{result.whole.minutes}m"
      "#{result.whole.seconds}s"
      "#{result.whole.millis}m"
    ]
    result.array.full.long  = [
      @to_unit(result.whole.years,"year")
      @to_unit(result.whole.weeks,"week")
      @to_unit(result.whole.days,"day")
      @to_unit(result.whole.hours,"hour")
      @to_unit(result.whole.minutes,"minute")
      @to_unit(result.whole.seconds,"second")
      @to_unit(result.whole.millis,"milli")
    ]
    result.array.full.no_millis = {}
    result.array.full.no_millis.values = [].concat(result.array.full.values[0...-1])
    result.array.full.no_millis.short = [].concat(result.array.full.short[0...-1])
    result.array.full.no_millis.long = [].concat(result.array.full.long[0...-1])
    #
    values = [].concat(result.array.full.values)
    values.shift() while values.length > 0 and values[0] is 0
    result.array.brief = {}
    result.array.brief.values = values
    result.array.brief.short = []
    result.array.brief.long  = []
    result.array.brief.no_millis = {}
    result.array.brief.no_millis.values = values[0...-1]
    result.array.brief.no_millis.short = []
    result.array.brief.no_millis.long  = []
    values = [].concat(values)
    for unit in [ 'milli','second','minute','hour','day','week','year' ]
      v = values.pop()
      if v?
        result.array.brief.short.unshift "#{v}#{unit.substring(0,1)}"
        result.array.brief.long.unshift @to_unit(v,unit)
        unless unit is 'milli'
          result.array.brief.no_millis.short.unshift "#{v}#{unit.substring(0,1)}"
          result.array.brief.no_millis.long.unshift @to_unit(v,unit)
      else
        break
    #
    result.array.min = {}
    result.array.min.units = []
    result.array.min.short = []
    result.array.min.long  = []
    result.array.min.no_millis = {}
    result.array.min.no_millis.units = []
    result.array.min.no_millis.short = []
    result.array.min.no_millis.long  = []
    for unit, i in [ 'year','week','day','hour','minute','second','milli']
      v = result.array.full.values[i]
      unless v is 0
        result.array.min.short.push "#{v}#{unit.substring(0,1)}"
        result.array.min.long.push @to_unit(v,unit)
        result.array.min.units.push unit
        unless unit is 'milli'
          result.array.min.no_millis.short.push "#{v}#{unit.substring(0,1)}"
          result.array.min.no_millis.long.push @to_unit(v,unit)
          result.array.min.no_millis.units.push unit
    #
    result.string = {}
    result.string.full = {}
    result.string.full.micro = result.array.full.short.join('')
    result.string.full.short = result.array.full.short.join(' ')
    result.string.full.long = result.array.full.long.join(' ')
    result.string.full.verbose = ArrayUtil.smart_join(result.array.full.long, ", ", " and ")
    result.string.full.no_millis = {}
    result.string.full.no_millis.micro = result.array.full.no_millis.short.join('')
    result.string.full.no_millis.short = result.array.full.no_millis.short.join(' ')
    result.string.full.no_millis.long = result.array.full.no_millis.long.join(' ')
    result.string.full.no_millis.verbose = ArrayUtil.smart_join(result.array.full.no_millis.long, ", ", " and ")
    result.string.brief = {}
    result.string.brief.micro = result.array.brief.short.join('')
    result.string.brief.short = result.array.brief.short.join(' ')
    result.string.brief.long = result.array.brief.long.join(' ')
    result.string.brief.verbose = ArrayUtil.smart_join(result.array.brief.long, ", ", " and ")
    result.string.brief.no_millis = {}
    result.string.brief.no_millis.micro = result.array.brief.no_millis.short.join('')
    result.string.brief.no_millis.short = result.array.brief.no_millis.short.join(' ')
    result.string.brief.no_millis.long = result.array.brief.no_millis.long.join(' ')
    result.string.brief.no_millis.verbose = ArrayUtil.smart_join(result.array.brief.no_millis.long, ", ", " and ")
    result.string.min = {}
    result.string.min.micro = result.array.min.short.join('')
    result.string.min.short = result.array.min.short.join(' ')
    result.string.min.long = result.array.min.long.join(' ')
    result.string.min.verbose = ArrayUtil.smart_join(result.array.min.long, ", ", " and ")
    result.string.min.no_millis = {}
    result.string.min.no_millis.micro = result.array.min.no_millis.short.join('')
    result.string.min.no_millis.short = result.array.min.no_millis.short.join(' ')
    result.string.min.no_millis.long = result.array.min.no_millis.long.join(' ')
    result.string.min.no_millis.verbose = ArrayUtil.smart_join(result.array.min.no_millis.long, ", ", " and ")
    return result


  # **iso_8601_regexp** - *returns a regular expression that can be used to validate an iso 8601 format date*
  # note that currently only the fully-specified datetime format is supported (not dates without times or durations).
  @iso_8601_regexp:()=>/^((\d{4})-(\d{2})-(\d{2}))T((\d{2})\:(\d{2})\:((\d{2})(?:\.(\d{3}))?)((?:[A-Za-z]+)|(?:[+-]\d{2}\:\d{2})))$/

################################################################################

class StringUtil

  # **trim** - *removes leading and trailing whitespace from a (possibly `null`) string.*
  @trim:(str)=>str?.replace /(^\s+)|(\s+$)/ig, ""

  # **isnt_blank** - *returns `true` iff the given string is not `null` and contains at least one non-whitespace character.*
  @isnt_blank:(str)=>(str? and /[^\s]/.test(str))

  # **is_blank** - *returns `true` iff the given string is `null`, empty or only contains whitespace characters.*
  @is_blank:(str)=>not(@isnt_blank(str))

  # **blank_to_null** - converts blank strings or attribute values to `null`.
  @blank_to_null:(data)=>
    if typeof data is 'string'
      if @is_blank(data)
        return null
    else
      for k,v of data
        if @is_blank(v)
          delete data[k]
          data[k] = undefined
    return data


  # **truncate** - *a minimally "smart" truncation that attempts to truncate a string at a word boundarie*
  #
  # truncates `text` to at most `width` characters, appending the specified
  # `marker` when an actual truncation occurred.  (pass an empty string--`''`--to
  # prevent a marker from being added to the truncated string.)
  #
  # the returned string will be *at most* `width` characters wide (including the
  # `marker`), but it may be less if the method can find a more suitable breaking
  # point near the end of the string.  (specifically, the algorithm tries to avoid
  # truncating a string in the middle of a "word".)
  @truncate:(text,width,marker='…')=>
    if not text? or not text.length? or text.length <= width
      return text
    else
      marker ?= ''
      max_shorten = 10 # maximum number of characters to step back while looking for a word boundary
      break_chars = /\.|\!|\?|\,|\:|\-|\s|\0|\)|\(|\[|\]|\{|\}|\\|\/|\\|\<|\>|\"|\'/ # characters recognized as word boundaries
      short_width = max_width = width-(marker.length)
      while short_width > (width-max_shorten)
        if break_chars.test(text.charAt(short_width))
          return "#{text.substring(0,short_width)}#{marker}"
        else
          short_width--
      return "#{text.substring(0,max_width)}#{marker}"


  # **escape_for_json** - *escapes a string for use as literal characters in a JSON string.*
  #
  # Escapes the given string so that it can be inserted
  # into a JSON string.  For example, given:
  #
  #     He said, "I know."
  #
  # `escape_for_json` returns:
  #
  #     He said, \"I know.\"
  #
  # Note that the returned string is *not* wrapped in quotation marks.
  @escape_for_json:(str)=>
    if str?
      str = JSON.stringify(str)
      str = str.substring(1,str.length-1)
      return str
    else
      return null


  # **escape_for_regexp** - *escapes a string for use as literal characters in regular expression.*
  @escape_for_regexp:(str)=>str?.replace(/([.?*+^$[\]\/\\(){}|-])/g, "\\$1")

  # Returns true if the given string is `t`, `true`, `y`, `yes`, `on`, `1`, etc.
  @truthy_string:(s)=>/^((T(rue)?)|(Y(es)?)|(ON)|1)$/i.test("#{s}")

  # Returns true if the given string is `f`, `false`, `no`, `off`, `0`, etc.
  @falsey_string:(s)=>/^((F(alse)?)|(No?)|(OFF)|0)$/i.test("#{s}")

  # **lpad** - *left-pad a string or array.*
  #
  # When `value` is an array, this method invokes `lpad_array`.
  # When `value` is a string, this method invokes `lpad_string`.
  @lpad:(value,width,pad)=>
    unless value?
      throw new Error("value must not be null")
    else
      if Array.isArray(value)
        return Util.lpad_array(value,width,pad)
      else
        return @lpad_string(value,width,pad)


  # **lpad_string** - *left-pad a string.*
  #
  # Returns a string of at least `width` characters generated
  # by prepending the specified `pad_char` to (a copy of) the
  # given `value`.
  #
  # `pad_char` *should* be exactly one character wide.
  @lpad_string:(value="",width=8,pad_char=" ")=>
    if "#{pad_char}".length is 0
      throw new Error("pad must not be empty")
    value = "#{value}"
    while value.length < width
      value = pad_char + value
    return value


  # **rpad** - *right-pad a string or array.*
  #
  # When `value` is an array, this method invokes `rpad_array`.
  # When `value` is a string, this method invokes `rpad_string`.
  @rpad:(value,width,pad)=>
    unless value?
      throw new Error("value must not be null")
    else
      if Array.isArray(value)
        return Util.rpad_array(value,width,pad)
      else
        return @rpad_string(value,width,pad)

  # **rpad_string** - *right-pad a string.*
  #
  # Returns a string of at least `width` characters generated
  # by appending the specified `pad_char` to (a copy of) the
  # given `value`.
  #
  # `pad_char` *should* be exactly one character wide.
  @rpad_string:(value="",width=8,pad_char=" ")=>
    if "#{pad_char}".length is 0
      throw new Error("pad must not be empty")
    else
      value = "#{value}"
      while value.length < width
        value += pad_char
      return value

################################################################################

class ArrayUtil

  @lpad:StringUtil.lpad

  # **lpad_array** - *left-pad an array.*
  #
  # Returns an array of at least `width` elements generated
  # by prepending the specified `pad_elt` to (a copy of) the
  # given `value`.
  @lpad_array:(value=[],width=8,pad_elt=null)=>
    while value.length < width
      value = [pad_elt].concat value
    return value

  @rpad:StringUtil.rpad

  # **rpad_array** - *right-pad an array.*
  #
  # Returns an array of at least `width` elements generated
  # by appending the specified `pad_elt` to (a copy of) the
  # given `value`.
  @rpad_array:(value=[],width=8,pad_elt=null)=>
    while value.length < width
      value.push pad_elt
    return value

  # ***smart_join*** - *like `Array.prototype.join` but with an optional final delimiter*
  #
  # E.g., `smart_join(["Tom","Dick","Harry"],", "," and ")` yields `Tom, Dick and Harry`.
  #
  # Alternatively, the `delimiter` parameter can be a map of options:
  #
  #  * `before` - appears before the list
  #  * `first` - appears between the first and second element
  #  * `last` - appears between the next-to-last and last element
  #  * `delimiter` - appears between other elements (if any)
  #  * `after` - appears after the list
  #
  # E.g., given:
  #
  #      var options = {
  #        before: "B",
  #        first: "F",
  #        delimiter: "D",
  #        last: "L",
  #        after: "A"
  #      }
  #
  # and
  #
  #      var a = [1,2,3,4,5]
  #
  # then `smart_join(a,options)` yields `"B1F2D3D4L5A"`.
  @smart_join:(array,delimiter,last)=>
    unless array?
      return null
    else
      if typeof delimiter is 'object'
        options = delimiter
        before = options.before
        first = options.first
        delimiter = options.delimiter
        last = options.last
        after = options.after
      if first? and last?
        [head,middle...,tail] = array
      else if first? and not last?
        [head,middle...] = array
      else if last? and not first?
        [middle...,tail] = array
      else
        middle = array
      if tail? and middle.length is 0
        middle = [tail]
        tail = undefined
      buffer = []
      if before?
        buffer.push before
      if head?
        buffer.push head
        if middle?.length > 0
          buffer.push first
      if middle?
        buffer.push middle.join(delimiter)
      if tail?
        if last?
          buffer.push last
        buffer.push tail
      if after?
        buffer.push after
      return buffer.join("")

  # **trim_trailing_null** - *remove trailing `null` values from an array*
  #
  # Removes any trailing `null` values from the given array.
  # Leading or interspersed `null` values are left alone.
  # E.g., given `[null,'foo',null,'bar',null,null]` returns `[null,'foo',null,'bar']`.
  @trim_trailing_null: (a)=>
    a = [].concat(a)
    b = []
    while a.length > 0
      v = a.pop()
      if v?
        b.unshift v
      else if b.length > 0
        b.unshift v
    return b

  # **right_shift_args** - *convert trailing `null` values to leading `null` values*
  #
  # Given a list of arguments that might contain trailing `null` values, returns an array
  # of the same length, but with leading rather than trailing `null`s.
  # E.g,.:
  #
  #     right_shift_args('a',null)
  #
  # returns:
  #
  #     [ null, 'a' ]
  #
  # and,
  #
  #     right_shift_args(1,null,2,null,null)
  #
  # returns:
  #
  #     [ null, null, 1, null, 2 ]
  #
  # This method can be used to allow the leading arguments to a function to
  # be the optional ones.  For example, consider the function signature:
  #
  #     function foo(a,b,callback)
  #
  # Using `right_shift_args` we can make `a` and `b` the optional arguments such that
  # `foo(callback)` is equivalent to `foo(null,null,callback)` and `foo('x',callback)`
  # is equivalent to `foo(null,'x',callback)`.
  #
  # In CoffeeScript, this can be achieved with the following idiom:
  #
  #     foo:(a,b,c)->
  #       [a,b,c] = Util.right_shift_args(a,b,c)
  #
  # In JavaScript, you'll need to unwind the returned array on your own:
  #
  #     function foo(a,b,c,d) {
  #       var args = Util.right_shift_args(a,b,c,d);
  #       a = args[0]; b = args[1]; c = args[2]; d = args[3];
  #     }
  #
  @right_shift_args: (values...)=>@lpad(@trim_trailing_null(values),values.length,null)

  # **paginate_list** - *extract a sub-array based on offset and limit*
  #
  # Given a list (array), returns the sublist defined by `offset` and `limit`.
  @paginate_list:(list,offset=0,limit=20)=>list[offset...(offset+limit)]

  # **subset_of** - *check whether on array contains another arrays as if they are sets *
  #
  # Given two arrays `a` and `b`, returns `true` if every element of
  # `a` is also found in `b`.
  #
  # Note that the arrays are treated as true *sets*.  The number of times
  # a given entry appears in each array is ignored--only the presence or
  # absence of a value is significant. (For example, `[1,1]` is considered
  # a subset of `[1]`.)
  @subset_of:(a,b)=>
    unless a? and Array.isArray(a) and b? and Array.isArray(b)
      throw new Error("Expected arrays.")
    else
      for e in a
        unless e in b
          return false
       return true

  # **is_subset_of** - *an alias for `subset_of`*
  @is_subset_of:(args...)=>@subset_of(args...)

  # **strict_subset_of** - *check whether on array strictly contains another arrays as if they are sets *
  #
  # Given two arrays `a` and `b`, returns `true` if every element of
  # `a` is also found in `b` *and* at least one element of `b` does not
  # appear in `a`.
  #
  # Note that the arrays are treated as true *sets*.  The number of times
  # a given entry appears in each array is ignored--only the presence or
  # absence of a value is significant. (For example, `[1,1]` is considered
  # a subset of `[1]`.)
  @strict_subset_of:(a,b)=>@subset_of(a,b) and not @subset_of(b,a) # Note: there are probably more efficient ways to do this.

  # **is_strict_subset_of** - *an alias for `strict_subset_of`*
  @is_strict_subset_of:(args...)=>@strict_subset_of(args...)

  # **sets_are_equal** - *compare two arrays as if they were sets*
  #
  # Given two arrays `a` and `b`, returns `true` if every element of
  # `a` is also found in `b` and every element of `b` is also found in `a`.
  #
  # Note that the arrays are treated as true *sets*.  Both the order of
  # and number of times a given entry appears in each array is ignored--only
  # the presence or absence of a value is significant. (For example, `[1,2]` has
  # set equality with `[2,1]` and `[1,2,1]` has set equality with `[2,2,1]`.)
  @sets_are_equal:(a,b)=>
    unless a? and Array.isArray(a) and b? and Array.isArray(b)
      throw new Error("Expected arrays.")
    else
      for e in a
        unless e in b
          return false
      for e in b
        unless e in a
          return false
      return true

  # Returns `true` iff the given arrays contain equal (`===`) elements in the
  # exact same order.  (Also see `sets_are_equal`).
  @arrays_are_equal:(a,b)=>
    unless a? and Array.isArray(a) and b? and Array.isArray(b)
      throw new Error("Expected arrays.")
    else
      unless a.length is b.length
        return false
      else
        for elt,i in a
          unless elt is b[i]
            return false
        return true

  # Returns a clone of `array` with duplicate values removed
  # When `key` is specified, elements of the array are treated as maps, and the
  # specified key field is used to test for equality
  @uniquify:(array,key)=>
    clone = []
    if key?
      keys = []
      for elt in array
        unless elt[key] in keys
          clone.push elt
          keys.push elt[key]
    else
      for elt in array
        unless elt in clone
          clone.push elt
    return clone

################################################################################

class NumberUtil

  # **round_decimal** - *round a number to the specified precision*
  #
  # Formats the given `value` as a decimal string with `digits` signficant
  # digits to the right of the decimal point.
  #
  # For example, given `v = 1234.567` then:
  #
  #  - `round_decimal(v,0)` yields `"1235"`
  #  - `round_decimal(v,1)` yields `"1234.6"`
  #  - `round_decimal(v,2)` yields `"1234.57"`
  #  - `round_decimal(v,3)` yields `"1234.567"`
  #  - `round_decimal(v,4)` yields `"1234.5670"`
  #  - `round_decimal(v,5)` yields `"1234.56700"`
  #  - `round_decimal(v,-1)` yields `"1230"`
  #  - `round_decimal(v,-2)` yields `"1200"`
  #  - `round_decimal(v,-3)` yields `"1000"`
  #  - `round_decimal(v,-4)` yields `"0"`
  #
  # Returns `null` if `value` is not a number and cannot
  # be coerced into one.  (Note that this method uses a less
  # permissive form of coercion that `parseInt` and `parseFloat`.
  # The input value must be a decimal string in standard (non-scientific)
  # notation.)
  @round_decimal:(value,digits=0)=>
    unless value?
      return null
    else
      unless typeof value is 'number'
        if /^\s*-?(([0-9]+(\.[0-9]+))|(\.[0-9]+))\s*$/.test "#{value}"
          value = parseFloat(value)
        else
          return null
      if isNaN(value)
        return null
      else if digits >= 0
        return value.toFixed(digits)
      else
        factor = Math.pow(10,Math.abs(digits))
        return "#{(Math.round(value/factor))*factor}"

  # **is_int** - *check if the given object is an (optionally signed) simple integer value*
  #
  # Returns `true` if the given value is (or can be converted to) a
  # valid integer (without any rounding).  E.g., `is_int(3)` and `is_int("3")`
  # yield `true` but `is_int(3.14159)` and `is_int("3.0")` yield `false`.
  @is_int:(v)=>
    unless v?
      return false
    else
      return /^-?((0)|([1-9][0-9]*))$/.test "#{v}"

  # **to_int** - *returns a valid integer or null*
  @to_int:(v)=>
    if v? and @is_int(v)
      v = parseInt(v)
      if isNaN(v)
        return null
      else
        return v
    else
      return null

################################################################################

class ColorUtil

  # **hex_to_rgb_triplet** - *convert a hex-based `#rrggbb` string to decimal `[r,g,b]` values*
  #
  # Given an HTML/CSS-style hex color string, yields an array of the R,G and B values.
  # E.g. `hex_to_rgb("#3300FF")` yields `[51,0,255]`.
  # The leading `#` character is optional, and both uppercase and lowercase letters
  # are supported.
  @hex_to_rgb_triplet:(hex)=>
    result = /^\s*#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})\s*$/i.exec(hex)
    if result?
      return [
        parseInt(result[1],16)
        parseInt(result[2],16)
        parseInt(result[3],16)
      ]
    else
      return null

  # **hex_to_rgb_strng** - *convert a hex-based `#rrggbb` string to a decimal-based `rgb(r,g,b)` string*
  #
  # Given an HTML/CSS-style hex color string, yields the corresponding `rgb(R,G,B)`
  # form.  E.g. `hex_to_rgb("#3300FF")` yields `rgb(51,0,255)`.
  # The leading `#` character is optional, and both uppercase and lowercase letters
  # are supported.
  @hex_to_rgb_string:(hex)=>
    [r,g,b] = @hex_to_rgb_triplet(hex) ? [null,null,null]
    if r? and g? and b?
      return "rgb(#{r},#{g},#{b})"
    else
      return null

  # **rgb_string_to_triplet** - *extract the `[r,g,b]` values from an `rgb(r,g,b)` string*
  @rgb_string_to_triplet:(rgb)=>
    result = /^\s*rgb\s*\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*\)\s*$/i.exec(rgb)
    if result?
      r = parseInt(result[1])
      g = parseInt(result[2])
      b = parseInt(result[3])
      return [r,g,b]
    else
      return null

  # **rgb_to_hex** - *convert `r`, `g` and `b` components or an `rgb(r,g,b`) string to a hex-based `#rrggbb` string*
  #
  # Given an RGB triplet returns the equivalent HTML/CSS-style hex string.
  # E.g, `rgb_to_hex(51,0,255)` yields `#3300FF`.
  @rgb_to_hex:(r,g,b)=>
    if typeof r is 'string' and not g? and not b?
      [r,g,b] = @rgb_string_to_triplet(r) ? [null,null,null]
    unless r? and g? and b?
      return null
    else
      i2h = (i)->
        h = i.toString(16)
        return if h.length is 1 then "0#{h}" else h
      return "##{i2h(r)}#{i2h(g)}#{i2h(b)}"

################################################################################

class RandomUtil

  # **random_bytes** - *generate a string of random bytes*
  #
  # Generates a string of `count` pseudo-random bytes in the specified encoding.
  # (Defaults to `hex`.)
  #
  # Note that `count` specifies the number of *bytes* to be generated. The encoded
  # string may be more or less than `count` *characters*.
  @random_bytes:(count=32,enc='hex')=>
    if typeof count is 'string'
      if typeof enc is 'number'
        [count,enc] = [enc,count]
      else
        enc = count
        count = 32
    bytes = crypto.randomBytes(count)
    if /buffer/i.test enc
      return bytes
    else
      return bytes.toString(enc)

  @seed_rng:(seed)->new Math.seedrandom(seed)
  @set_rng:(rng = Math.random)=>@rng = rng
  @rng:Math.random
    
  # **random_hex** - *generate a string of `count` pseudo-random characters from the set ``[0-9a-f]``.
  @random_hex:(count=32,rng)=>@_random_digits(count,16,rng)

  # **random_alphanumeric** - *generate a string of `count` pseudo-random characters from the set `[a-z0-9]`.
  @random_alphanumeric:(count=32,rng)=>@_random_digits(count,36,rng)

  # **random_numeric** - *generate a string of `count` pseudo-random characters from the set `[0-9]`.*
  @random_numeric:(count=32,rng)=>@_random_digits(count,10,rng)

  # **random_Alpha** - *generate a string of `count` pseudo-random characters from the set `[a-zA-Z]` (mixed case).
  @random_Alpha:(count=32,rng)=>@_random_alpha(count,'M',rng)

  # **random_ALPHA** - *generate a string of `count` pseudo-random characters from the set `[A-Z]` (upper case).
  @random_ALPHA:(count=32,rng)=>@_random_alpha(count,'U',rng)

  # **random_alpha** - *generate a string of `count` pseudo-random characters from the set `[a-z]` (lower case).
  @random_alpha:(count=32,rng)=>@_random_alpha(count,'L',rng)

  # lettercase = 'upper', 'lower', 'both' (or 'mixed')
  @_random_alpha:(count=32,lettercase='lower',rng)=>
    rng ?= @rng
    str = ""
    include_upper = /^(u|b|m)/i.test lettercase
    include_lower = not /^u/i.test lettercase # everything but `UPPER` includes `LOWER`, to avoid both checks being false
    while str.length < count
      char = Math.floor(rng()*26)
      if include_upper and include_lower
        if rng() > 0.5
          char += 97 # a
        else
          char += 65 # A
      else if include_upper
        char += 65 # A
      else
        char += 97 # a
      str += String.fromCharCode(char)
    return str

  # **random_element** - *selects a random element from the given array (or map)*
  # In the case of a map, a random key/value pair will be returned as a two-element array.
  @random_element:(collection,rng)=>
    unless collection?
      return undefined
    else
      if Array.isArray(collection)
        unless collection.length > 0
          return undefined
        else
          rng ?= @rng
          index = Math.floor(rng()*collection.length)
          return collection[index]
      else if collection? and typeof collection is 'object'
        key = @random_element(Object.keys(collection),rng)
        return [key,collection[key]]

  # **_random_digits** - *generate a string of random bytes in the specfied base number system*
  # (An internal method that generates `count` characters in the specified base.)
  @_random_digits:(args...)=> #count=32,base,rng
    ints = []
    rng = null
    while args.length > 0
      a = args.shift()
      if typeof a is 'function'
        if rng?
          throw new Error("Unexpected arguments: #{args}")
        else
          rng = a
      else
        if ints.length is 2 and a?
          throw new Error("Unexpected arguments: #{args}")
        else
          ints.push a
    [count,base] = ints
    count ?= 32
    base ?= 10
    rng ?= @rng
    str = ""
    while str.length < count
      str += rng().toString(base).substring(2)
    if str.length > count
      str = str.substring(0,count)
    return str

################################################################################

class PasswordUtil

  # Compare the `expected_digest` with the hash computed from the remaining
  # parameters.
  @validate_hashed_password:(expected_digest,password,salt,pepper,hash_type)=>
    [salt,digest] = @hash_password(password,salt,pepper,hash_type)
    password = undefined # forget password when no longer needed
    return Util.slow_equals(expected_digest,digest)[0]

  # Hash the given `password`, optionally using the given `salt`.
  # If no `salt` is provided a new random salt will be generated.
  # Returns `[salt,digest]`.
  # options := { password, salt, pepper, hash_type }
  @hash_password:(password,salt,pepper,hash_type)=>
    # parse input parameters
    if typeof password is 'object'
      hash_type = password.hash_type
      pepper = password.pepper
      salt = password.salt
      password = password.password
    # set defaults
    hash_type ?= 'sha512'
    salt ?= 64
    # convert types
    password = new Buffer(password) if password? and not Buffer.isBuffer(password)
    pepper = new Buffer(pepper) if pepper? and not Buffer.isBuffer(pepper)
    if typeof salt is 'number'
      salt = RandomUtil.random_bytes(salt,'buffer')
    else unless Buffer.isBuffer(salt)
      salt = new Buffer(salt)
    # validate inputs
    if not password?
      throw new Error("password parameter is required")
    else
      # calculate hash
      hash = crypto.createHash(hash_type)
      hash.update salt
      if pepper?
        hash.update pepper
      hash.update password
      password = undefined # forget password when no longer needed
      digest = hash.digest()
      # return generated salt and calculated hash
      return [salt,digest]

################################################################################

class ComparatorUtil

  # **slow_equals** - *constant-time comparison of two buffers for equality*
  # Performs a byte by byte comparision of the given buffers
  # but does it in *constant* time (rather than aborting as soon
  # as a delta is discovered). `a^b` (`a xor b`) would be better
  # if supported.
  #
  # To prevent optimizations from short-cutting this process, an array
  # containing `[ equal?, number-of-identical-bytes, number-of-different-bytes ]`
  # is returned.
  #
  # For equality tests, you'll want something like `if(Util.slow_equals(a,b)[0])`.
  #
  @slow_equals:(a,b)=>
    same_count = delta_count = 0
    if b.length > a.length
      [a,b] = [b,a]
    for i in [0...a.length]
      if a[i] isnt b[i]
        delta_count += 1
      else
        same_count += 1
    if (delta_count is 0 and a.length is b.length)
      return [true,same_count,delta_count]
    else
      return [false,same_count,delta_count]


  # **compare** - *a basic comparator function*
  #
  # A basic comparator.
  #
  # When `a` and `b` are strings, they are compared in a case-folded
  # sort (`a` before `B`) using `String.prototype.localeCompare`.
  #
  # Otherwise JavaScript's default `<` and `>` operators are used.
  #
  # This method `null` values, which are sorted before any non-null values.
  #
  # Returns:
  #  - a positive integer when `a > b`, or when `a` is not `null` and `b` is `null`
  #  - a negative integer when `a < b`, or when `a` is `null` and `b` is not `null`
  #  - zero (`0`) otherwise (when `!(a > b) && !(a < b)` or when both `a` and `b` are `null`).
  @compare:(a,b)=>
    if a? and b?
      if a.localeCompare? and b.localeCompare? and a.toUpperCase? and b.toUpperCase?
        A = a.toUpperCase()
        B = b.toUpperCase()
        val = A.localeCompare(B)
        if val is 0
          return a.localeCompare(b)
        else
          return val
      else
        return  (if a > b then 1 else (if a < b then -1 else 0))
    else if a? and not b?
      return 1
    else if b? and not a?
      return -1
    else
      return 0

  # **case_insensitive_compare** - *a case-insensitive comparator function*
  #
  # Compares to elements (exactly like `compare`), with two exceptions:
  #   1. Any string-valued argument is converted to upper case before the comparison.
  #   2. If the case-insensitive comparison yields `0` (i.e., the two case-insensitive
  #      values are equal), a case-sensitive comparison is used as a tie-breaker).
  @case_insensitive_compare:(a,b)=>
    if a?.toUpperCase?
      A = a.toUpperCase()
    else
      A = a
    if b?.toUpperCase?
      B = b.toUpperCase()
    else
      B = b
    result = @compare(A,B)
    if result is 0
      result = @compare(a,b)
    return result

  # **field_comparator** - *compares objects based on an attribute*
  #
  # Generates a comparator that compares objects based on the specified field.
  # E.g., `field_comparator('foo')` will compare two objects `A` and `B`
  # based on the value of `A.foo` and `B.foo`.
  #
  # When `ignore_case` is `true`, string-valued fields will be compared in a
  # case-insensitive way.
  @field_comparator:(field,ignore_case=false)=>@path_comparator([field],ignore_case)

  # **path_operator** - *compares objects based on (optionally nested) attributes*
  #
  # Generates a comparator that compares objects based on the value obtained
  # by walking the given path (in an object graph).
  #
  # E.g., `path_comparator(['foo','bar'])` will compare two objects `A` and `B`
  # based on the value of `A.foo.bar` and `B.foo.bar`.
  #
  # If a `null` value is encountered while walking the object-graph, the
  # two values are immediately compared.  (Hence given:
  #
  #     a = { foo: null }
  #     b = { foo: { bar: null } }
  #     path = [ 'foo','bar' ]
  #
  # `path_comparator(path)(a,b)` will compare `null` and `{ bar: null }`, since
  # the value of `a.foo` is `null`.)
  #
  # When `ignore_case` is `true`, string-valued fields will be compared in a
  # case-insensitive way.
  #
  @path_comparator:(path,ignore_case=false)=>
    (a,b)=>
      fn = if ignore_case then 'case_insensitive_compare' else 'compare'
      A = a
      B = b
      for f in path
        A = A?[f]
        B = B?[f]
        unless A? and B? # should we continue walking the graph if one of the values is not-null?
          return Util[fn](A,B)
      return Util[fn](A,B)

  # **desc_comparator** - *reverses another comparison function.*
  #
  # Generates a comparator that reverses the sort order of the input comparator.
  # I.e., if when sorted by comparator `c` an array is ordered `[1,2,3]`, the
  # array will be ordered `[3,2,1]` when sorted by `desc_comparator(c)`.
  @desc_comparator:(c)=>((a,b)->(c(b,a)))

  # **descending_comparator** - *an alias for `desc_comparator`*
  @descending_comparator:(args...)=>@desc_comparator(args...)

  # **composite_comparator** - *chains several comparison functions into one*
  #
  # Given a list (array) of comparators, generates a comparator that first
  # compares elements by list[0], then list[1], etc. until a non-equal
  # comparision is found, or we run out of comparators.
  @composite_comparator:(list)=>
    (a,b)->
      for c in list
        r = c(a,b)
        unless r is 0
          return r
      return 0

################################################################################

class FileUtil

  # Replaces invalid characters from and truncates very long filenames.
  # This method will accept (and return) a full path but will only operate on the "basename".
  @sanitize_filename:(str)=>
    BAD_CHARS = /[^-A-Za-z0-9_]/g
    SUBST_CHAR = '-'
    MAX_EXTENSION = 260
    MAX_BASENAME  = 260
    parent = path.dirname(str) ? ''
    ext = path.extname(str) ? ''
    base = path.basename(str,ext) ? ''
    if /^\..+/.test ext
      ext = "."+ext.substring(1).replace(BAD_CHARS,SUBST_CHAR)
    if ext?.length > MAX_EXTENSION
      ext = ext.substring(0,MAX_EXTENSION)
    base = base.replace(BAD_CHARS,SUBST_CHAR)
    if base?.length > MAX_BASENAME
      base = base.substring(0,MAX_BASENAME)
    if parent?.length > 0
      return path.join(parent,"#{base}#{ext}")
    else
      return "#{base}#{ext}"

  @uniquify_filename:(dir,basename,ext='',minpadwidth=3,maxpadwidth=5)=>
    max_attempts = Math.pow(10,maxpadwidth)
    unless fs.existsSync(path.join(dir,"#{basename}#{ext}"))
      return "#{basename}#{ext}"
    else
      i = 1
      while fs.existsSync(path.join(dir,"#{basename}-#{Util.lpad(i,minpadwidth,'0')}#{ext}"))
        if i > max_attempts
          throw new Error("Unable to obtain a unique filename for \"#{basename}#{ext}\" in \"#{dir}\" after #{max_attempts} attempts.")
        else
          i += 1
      return "#{basename}-#{Util.lpad(i,minpadwidth,'0')}#{ext}"

  # Attempts to recursively create the specified directory, ignoring errors.
  # Set `NODE_DEBUG=inote-util` to view errors.
  # Returns `true` if no errors encountered, `false` otherwise
  @mkdir:(dir)=>
    if dir?
      try
        mkdirp.sync(dir)
        return true
      catch e
        if DEBUG
          console.error "FileUtil.mkdir",e
        return false
    else
      return false

  # Attempts to remove the specified file, ignoring errors.
  # Set `NODE_DEBUG=inote-util` to view errors.
  # Returns `true` if no errors encountered, `false` otherwise
  @rm:(files...)=>
    result = false
    if files? and files.length > 0
      result = true
      for file in files
        try
          fs.unlinkSync(file)
        catch e
          result = false
          if DEBUG
            console.error "FileUtil.rm",e
    return result

  # Attempts to (recursively) remove the specified directory(s) or file(s), ignoring errors.
  # Set `NODE_DEBUG=inote-util` to view errors.
  # Returns `true` if no errors encountered, `false` otherwise
  @rmdir:(dirs...)=>
    result = false
    if dirs? and dirs.length > 0
      result = true
      for dir in dirs
        try
          remove.removeSync(dir)
        catch e
          result = false
          if DEBUG
            console.error "FileUtil.rmdir",e
    return result

  @read_stdin_sync:(end_byte="\x04",buffer_size=512)->
    read_buf = new Buffer(buffer_size)
    bytes_read = 0
    all_buf = new Buffer(buffer_size)
    all_bytes_read = 0
    end_byte_read = false
    fd = process?.stdin?.fd
    unless fd?
      throw new Error("Unable to obtain stdin.fd")
    else
      while true
        try
          bytes_read = fs.readSync fd, read_buf, 0, buffer_size, null
          temp_buf = new Buffer(all_bytes_read + bytes_read)
          all_buf.copy temp_buf, 0, 0, all_bytes_read
          read_buf.copy temp_buf, all_bytes_read, 0, bytes_read
          all_buf = temp_buf
          all_bytes_read += bytes_read
          for b in bytes_read
            if b is end_byte
              end_byte_read = true
              break
          if end_byte_read
            break
        catch err
          if err.code is 'EOF'
            break
          else
            throw err
        if bytes_read is 0
          break
      return all_buf

  @load_json_file_sync:(file,ignore_errors=false)->
    try
      return JSON.parse(fs.readFileSync(file).toString())
    catch err
      if ignore_errors
        return null
      else
        throw err

  @load_json_stdin_sync:(end_byte="\x04",buffer_size=512,ignore_errors=false)=>
    try
      return JSON.parse(@read_stdin_sync(end_byte,buffer_size))
    catch err
      if ignore_errors
        return null
      else
        throw err

  # naive version of the Unix `touch` command
  @touch:(file,callback)=>
    fs.open file, "wx", (err, fd)=>
      if fd?
        fs.close fd, (err)=>
          callback?()
      else
        callback?()

################################################################################

class WebUtil
  # Identifies the "client IP" for the given request in various circumstances
  @remote_ip:(req)=>
    req?.get?('x-forwarded-for') ?
    req?.headers?['x-forwarded-for'] ?
    req?.connection?.remoteAddress ?
    req?.socket?.remoteAddress ?
    req?.connection?.socket?.remoteAddress

  # replaces the now deprecated `req.param` found in Express.js
  @param:(req,name,default_value)=>
    return (req?.params?[name] ? (req?.body?[name] ? (req?.query?[name] ? default_value)))

class IOUtil

  @pipe_to_buffer:(readable_stream,callback)=>
    data = []
    length = 0
    readable_stream.on 'data', (chunk)=>
      if chunk?
        data.push chunk
        length += chunk.length
    readable_stream.on 'error', (err)=>
      callback(err)
    readable_stream.on 'end', ()=>
      callback null, Buffer.concat(data)

  @pipe_to_file:(readable_stream,dest,options,callback)=>
    if options? and typeof options is 'function' and not callback?
      callback = options
      options = null
    out = fs.createWriteStream(dest,options)
    out.on 'close', callback
    out.on 'error', callback
    readable_stream.pipe(out)

  @download_to_buffer:(url,callback)=>
    params = {}
    if typeof url is 'string'
      params.url = url
    else
      params = url
    request params, (err,response,body)=>
      if err?
        callback(err)
      else unless /^2[0-9][0-9]$/.test request?.statusCode
        callback(response,body)
      else
        callback(null,body)

  @download_to_file:(url,dest,options,callback)=>
    if options? and typeof options is 'function' and not callback?
      callback = options
      options = null
    params = {}
    if typeof url is 'string'
      params.url = url
    else
      params = url
    out = fs.createWriteStream(dest,options)
    out.on 'close', callback
    out.on 'error', callback
    request(params).pipe(out)

################################################################################

class ErrorUtil

  # **handle_error** - *invoke a callback on error*
  #
  # If `err` is `null` (or `undefined`), returns
  # `false`.
  #
  # If `err` is not `null`, and `callback` exists,
  # invokes `callback(err)` and returns `true`.
  #
  # If `err` is not `null`, `callback` does not
  # exist and `thrown_when_no_callback` is `true`
  # (the default), `throws` the given error.
  #
  # If `err` is not `null`, `callback` does not
  # exist and `thrown_when_no_callback` is `false`,
  # prints the `err` to STDERR and returns `true`.
  #
  # Particularly useful for the CoffeeScript idiom:
  #
  #     some_error_generating_function a, b, (err,foo,bar)->
  #       unless Util.handle_error err, callback
  #         # ...continue processing...
  #
  # rather than:
  #
  #     some_error_generating_function a, b, (err,foo,bar)->
  #       if err?
  #         callback(err)
  #       else
  #         # ...continue processing...
  #
  @handle_error:(err,callback,throw_when_no_callback=true)=>
    if err?
      if callback?
        callback(err)
        return true
      else if throw_when_no_callback
        throw err
      else
        console.error "ERROR",err
    else
      return false

################################################################################

class IdUtil

  # **uuid** - *normalize or generate a UUID value*
  #
  # When a UUID value `v` is provided, a normalized value is returned (downcased and
  # with any dashes (`-`) removed, matching `/^[0-9a-f]{32}$/`).
  #
  # E.g., given `02823B75-8C4A-3BC4-7F03-0A8482D5A9AB`, returns `02823b758c4a3bc47f030a8482d5a9ab`.
  # If `generate` is `true` and `v` is `null`, a new (normalized) UUID value is generated and returned.
  @uuid:(v,generate=false)=>
    unless v?
      if generate
        v = @uuid(uuid.v1())
      else
        return null
    else unless v.replace?
      throw new Error("Expected string but found #{typeof v}",v)
    else unless /^[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}$/i.test v
      throw new Error("Encountered invalid UUID format #{v}.")
    return v.replace(/-/g,'').toLowerCase()

  # **pad_uuid** - *normalize or generate a *padded* UUID value*
  #
  # When a UUID value `v` is provided, a normalized value is returned (matching
  # `/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/`).
  #
  # If `generate` is `true` and `v` is `null`, a new (normalized) UUID value
  # is generated and returned.
  @pad_uuid:(v,generate=false)=>
    v = @uuid(v,generate)
    if v?
      return (v.substring(0,8)+"-"+v.substring(8,12)+"-"+v.substring(12,16)+"-"+v.substring(16,20)+"-"+v.substring(20))
    else
      return null

################################################################################

class Base64

  # **b64e** - *encodes a buffer as Base64*
  #
  # Base64-encodes the given Buffer or string, returning a string.
  # When a string value is provided, the optional `output_encoding` attribute
  # specifies the encoding to use when converting characters to bytes.
  @encode:(buf,output_encoding='utf8')=>
    if not buf?
      return null
    else
      unless buf instanceof Buffer
        buf = new Buffer(buf.toString(),output_encoding)
      return buf.toString('base64')

  # **b64d** - *decodes a Base64-encoded string*
  #
  # Base64-decodes the given Buffer or string, returning a string.
  # The optional `output_encoding` attribute specifies the encoding to use
  # when converting bytes to characters.
  @decode:(buf,output_encoding='utf8')=>
    if not buf?
      return null
    else
      unless buf instanceof Buffer
        buf = new Buffer(buf.toString(),'base64')
      return buf.toString(output_encoding)

################################################################################

class AsyncUtil

  # Wait `delay` milliseconds then invoke `cb`.
  # Much like `setTimeout`, but with a more sensible argument sequence for CoffeeScript
  @wait:(delay,cb)=>process.nextTick(()=>setTimeout(cb,delay))
  @set_timeout:(delay,cb)=>@wait(delay,cb)
  @setTimeout:(delay,cb)=>@wait(delay,cb)

  # Alias for `window.clearTimeout`
  @cancel_wait:(id)=>clearTimeout(id)
  @clearTimeout:(id)=>@cancel_wait(id)
  @clear_timeout:(id)=>@cancel_wait(id)

  # Like `setInterval`, but with a more sensible argument sequence for CoffeeScript
  @interval:(delay,cb)=>setInterval(cb,delay)
  @set_interval:(delay,cb)=>interval(cb,delay)
  @setInterval:(delay,cb)=>@interval(delay,cb)

  # Alias for `window.clearInterval`
  @cancel_interval:(id)=>clearInterval(id)
  @cancelInterval:(id)=>@cancel_interval(id)
  @clear_interval:(id)=>@cancel_interval(id)
  @clearInterval:(id)=>@cancel_interval(id)

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
  #     var i = 0;
  #     init = function() { i = 0; }
  #     cond = function() { return i < 10; }
  #     actn = function(next) { console.log(i); next(); }
  #     incr = function() { i = i + 1; }
  #     done = function() { }
  #     for_async(init,cond,actn,incr,done)
  #
  @for_async:(initialize,condition,action,increment,whendone)=>
    looper = ()->
      if condition()
        action ()->
          increment()
          looper()
      else
        whendone() if whendone?
    initialize()
    looper()

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
    i = m = null
    init = ()-> i = 0
    cond = ()-> (i < list.length)
    incr = ()-> i += 1
    act  = (next)-> action(list[i],i,list,next)
    @for_async(init, cond, act, incr, whendone)



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
        method method_args..., (callback_args...)->
          results[index] = callback_args
          remaining_callbacks--
          if remaining_callbacks is 0
            callback(results)

  # Just like `fork` save that at most `max_parallel` methods will run at any one time
  @throttled_fork: (max_parallel, methods, args_for_methods, callback)->
    if (not callback?) and typeof args_for_methods is 'function'
      callback = args_for_methods
      args_for_methods = null
    results = []
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
          method = methods[index]
          method method_args..., (callback_args...)->
            results[index] = callback_args
            currently_running--
            remaining_callbacks--
            if remaining_callbacks is 0
              callback(results)
            else
              run_more()
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
    Util.for_each_async @list,action,()=>callback?(args...)
    return this

  # Note that each `Sequencer` method returns the `Sequencer` object
  # itself.  Hence given (predefined) functions `a`, `b`, and `c`,
  # one could invoke:
  #
  #     (new Sequencer()).first(a).then(b).finally(c)
  #
#coffeelint:enable=no_this


# **Util** - *collects assorted utility functions*
class Util

  @to_unit:               DateUtil.to_unit
  @start_time:            DateUtil.start_time
  @duration:              DateUtil.duration
  @iso_8601_regexp:       DateUtil.iso_8601_regexp

  @trim:                  StringUtil.trim
  @isnt_blank:            StringUtil.isnt_blank
  @is_blank:              StringUtil.is_blank
  @blank_to_null:         StringUtil.blank_to_null
  @truncate:              StringUtil.truncate
  @escape_for_json:       StringUtil.escape_for_json
  @escape_for_regexp:     StringUtil.escape_for_regexp
  @truthy_string:         StringUtil.truthy_string
  @falsey_string:         StringUtil.falsey_string
  @lpad:                  StringUtil.lpad
  @lpad_string:           StringUtil.lpad_string
  @rpad:                  StringUtil.rpad
  @rpad_string:           StringUtil.rpad_string

  @lpad_array:            ArrayUtil.lpad_array
  @rpad_array:            ArrayUtil.rpad_array
  @smart_join:            ArrayUtil.smart_join
  @trim_trailing_null:    ArrayUtil.trim_trailing_null
  @right_shift_args:      ArrayUtil.right_shift_args
  @paginate_list:         ArrayUtil.paginate_list
  @subset_of:             ArrayUtil.subset_of
  @is_subset_of:          ArrayUtil.is_subset_of
  @strict_subset_of:      ArrayUtil.strict_subset_of
  @is_strict_subset_of:   ArrayUtil.is_strict_subset_of
  @sets_are_equal:        ArrayUtil.sets_are_equal
  @arrays_are_equal:      ArrayUtil.arrays_are_equal
  @uniquify:              ArrayUtil.uniquify

  @round_decimal:         NumberUtil.round_decimal
  @is_int:                NumberUtil.is_int
  @to_int:                NumberUtil.to_int

  @remove_null:           MapUtil.remove_null
  @remove_falsey:         MapUtil.remove_falsey
  @merge:                 MapUtil.merge
  @shallow_clone:         MapUtil.shallow_clone
  @object_array_to_map:   MapUtil.object_array_to_map

  @hex_to_rgb_triplet:    ColorUtil.hex_to_rgb_triplet
  @hex_to_rgb_string:     ColorUtil.hex_to_rgb_string
  @rgb_string_to_triplet: ColorUtil.rgb_string_to_triplet
  @rgb_to_hex:            ColorUtil.rgb_to_hex

  @random_bytes:          RandomUtil.random_bytes
  @random_hex:            RandomUtil.random_hex
  @random_alphanumeric:   RandomUtil.random_alphanumeric
  @random_numeric:        RandomUtil.random_numeric
  @random_alpha:          RandomUtil.random_alpha
  @random_ALPHA:          RandomUtil.random_ALPHA
  @random_Alpha:          RandomUtil.random_Alpha
  @random_element:        RandomUtil.random_element
  @seed_rng:              RandomUtil.seed_rng
  @set_rng:               RandomUtil.set_rng
  @random_digits:         RandomUtil._random_digits

  @validate_hashed_password:PasswordUtil.validate_hashed_password
  @hash_password:PasswordUtil.hash_password

  @slow_equals:ComparatorUtil.slow_equals
  @compare:ComparatorUtil.compare
  @case_insensitive_compare:ComparatorUtil.case_insensitive_compare
  @field_comparator:ComparatorUtil.field_comparator
  @path_comparator:ComparatorUtil.path_comparator
  @desc_comparator:ComparatorUtil.desc_comparator
  @descending_comparator:ComparatorUtil.descending_comparator
  @composite_comparator:ComparatorUtil.composite_comparator

  @read_stdin_sync:FileUtil.read_stdin_sync
  @load_json_file_sync:FileUtil.load_json_file_sync
  @load_json_stdin_sync:FileUtil.load_json_stdin_sync

  @remote_ip:WebUtil.remote_ip

  @handle_error:ErrorUtil.handle_error

  @uuid:IdUtil.uuid
  @pad_uuid:IdUtil.pad_uuid
  @b64e:Base64.encode
  @b64d:Base64.decode

  @for_async:AsyncUtil.for_async
  @for_each_async:AsyncUtil.for_each_async
  @fork:AsyncUtil.fork
  @throttled_fork:AsyncUtil.throttled_fork
  @procedure:AsyncUtil.procedure

################################################################################

exports.ArrayUtil      = ArrayUtil
exports.AsyncUtil      = AsyncUtil
exports.Base64         = Base64
exports.ColorUtil      = ColorUtil
exports.ComparatorUtil = ComparatorUtil
exports.DateUtil       = DateUtil
exports.ErrorUtil      = ErrorUtil
exports.FileUtil       = FileUtil
exports.IdUtil         = IdUtil
exports.LogUtil        = LogUtil
exports.MapUtil        = MapUtil
exports.NumberUtil     = NumberUtil
exports.PasswordUtil   = PasswordUtil
exports.RandomUtil     = RandomUtil
exports.Sequencer      = Sequencer
exports.StringUtil     = StringUtil
exports.Util           = Util
exports.WebUtil        = WebUtil

################################################################################

# (TESTS FOR STDIN METHODS)
# if require.main is module
#   if /^-?-?read(-|_)?stdin$/.test process.argv[2]
#     console.log Util.read_stdin_sync().toString()
#   else if /^-?-?read(-|_)?stdin(-|_)?json$/.test process.argv[2]
#     console.log Util.load_json_stdin_sync()
