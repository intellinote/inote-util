fs         = require 'fs'
path       = require 'path'
HOMEDIR    = path.join(__dirname,'..')
LIB_COV    = path.join(HOMEDIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')

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


  # **truncate** - *a minimally "smart" truncation that attempts to truncate a string at a word boundaries
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

  # Replaces any single quotes in `param` with the sequence `'\''`
  # (quote, slash, quote, quote) and then wraps `param` in single quotes,
  # returning a string that can be safely used "as is" in bash/shell command
  # line argument.
  #
  # When `quote_specials` is `false` (the default) the following parameters
  # will NOT be escaped or quoted:
  #  - `<`
  #  - `>`
  #  - `>>`
  #  - `|`
  #  - `||`
  #  - `&`
  #  - `&&`
  #  - `*`
  #  - `.`
  #  - `..`
  #  - `2>&1`
  #  - anything ending with `*`
  # when `quote_specials` is `true`, ALL parameters will be escaped.
  @escape_for_bash:(param, quote_specials = false)=>
    if param?
      quote_specials ?= false
      # if the parameter is `<`, `<`, `*`, `.`, `&&` or ends with `*`, don't quote it
      if quote_specials or not ( (param in ['<','>','>>','.','..','*','|','||','&','&&','2>&1']) or /\*$/.test(param) )
        param = "#{param}".replace(/'/g,"'\\''") # replace single quotes with `\'`
        param = "'#{param}'"
    return param

  @escape_for_shell:(param, quote_specials = false)=>@escape_for_bash(param, quote_specials)

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
        return @lpad_array(value,width,pad)
      else
        return @lpad_string(value,width,pad)

  # **lpad_array** - *left-pad an array.*
  #
  # Returns an array of at least `width` elements generated
  # by prepending the specified `pad_elt` to (a copy of) the
  # given `value`.
  @lpad_array:(value=[],width=8,pad_elt=null)=>
    while value.length < width
      value = [pad_elt].concat value
    return value

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
        return @rpad_array(value,width,pad)
      else
        return @rpad_string(value,width,pad)

  # **rpad_array** - *right-pad an array.*
  #
  # Returns an array of at least `width` elements generated
  # by appending the specified `pad_elt` to (a copy of) the
  # given `value`.
  @rpad_array:(value=[],width=8,pad_elt=null)=>
    while value.length < width
      value.push pad_elt
    return value

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

exports.StringUtil = StringUtil
