# <i style="color:#666;font-size:80%">(Note: If you are viewing the [docco](http://jashkenas.github.io/docco/)-generated HTML version of this file, use the "Jump To..." menu in the upper right corner to navigate to the annotated versions of other source files.)</i>
uuid    = require 'node-uuid'
crypto  = require 'crypto'

# **Util** - *collects assorted utility functions*
class Util

  # ## String Manipulation and Formatting

  # **trim** - *removes leading and trailing whitespace from a (possibly `null`) string.*
  @trim:(str)=>str?.replace /(^\s+)|(\s+$)/ig, ""

  # **isnt_blank** - *returns `true` iff the given string is not `null` and contains at least one non-whitespace character.*
  @isnt_blank:(str)=>(str? and /[^\s]/.test(str))

  # **is_blank** - *returns `true` iff the given string is `null`, empty or only contains whitespace characters.*
  @is_blank:(str)=>not(@isnt_blank(str))

  # **blank_to_null** - converts blank strings or attribute values to `null`.
  @blank_to_null:(data)=>
    if typeof data is 'string'
      if Util.is_blank(data)
        return null
    else
      for k,v of data
        if Util.is_blank(v)
          delete data[k]
          data[k] = undefined
    return data

  # **truncate** - *a minimally "smart" truncation that attempts to truncate a string at a word boundarie*
  #
  # Truncates `text` to at most `width` characters, appending the specified
  # `marker` when an actual truncation occurred.  (Pass an empty string--`''`--to
  # prevent a marker from being added to the truncated string.)
  #
  # The returned string will be *at most* `width` characters wide (including the
  # `marker`), but it may be less if the method can find a more suitable breaking
  # point near the end of the string.  (Specifically, the algorithm tries to avoid
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

  # ## Padding (of Strings and Arrays)

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

  # ## Numbers

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
      return /^-?[1-9][0-9]*$/.test "#{v}"

  # ## Objects and Arrays

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
  @right_shift_args: (values...)=>@lpad(Util.trim_trailing_null(values),values.length,null)

  # **paginate_list** - *extract a sub-array based on offset and limit*
  #
  # Given a list (array), returns the sublist defined by `offset` and `limit`.
  @paginate_list:(list,offset=0,limit=20)=>list[offset...(offset+limit)]

  # **remove_falsey** - *`delete` any attribute whose value evaluates to false*
  # Returns a new map or array, with "falsey" values removed.
  @remove_falsey:(map)=>
    unless map?
      return map
    else if Array.isArray(map)
      new_array = []
      for elt in map
        if elt
          new_array.push elt
      return new_array
    else if typeof map is 'object'
      new_map = {}
      for n,v of map
        if v
          new_map[n] = v
      return new_map
    else unless  map
      return null
    else
      return map

  # **merge** - *merge multiple maps into a new, combined map*
  #
  # Given two (or more) maps, `a` and `b`, creates a new map containing the
  # elements of each. If `a` and `b` share a key, the value in `b` will
  # overwrite the value in `a`.
  @merge:(args...)=>
    map = {}
    if args.length is 1 and Array.isArray(args[0])
      args = args[0]
    for m in args
      for n,v of m
        map[n] = v
    return map

  # **shallow_clone** - *create a "shallow" copy of an object*
  #
  # Creates an independent map with the same keys as `map`.
  # Any object-valued entry in `map` will *not* be cloned.
  # The new map will contain a reference to the same underlying object
  # as the original map.
  #
  # If `map` is `null`, the value `null` is returned.
  @shallow_clone:(map)=>
    if map?
      new_map = {}
      for k,v of map
        new_map[k] = v
      return new_map
    else
      return null

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
        console.log elt
        unless elt in clone
          clone.push elt
          console.log "pushed"
    return clone

  # Given a list of objects, creates a map from `elt[key_field]` to `elt`.
  #
  # The `options` map may contain:
  #
  #  * `transform` - a function used to transform the value of
  #    `elt[key_field]` before using it as the map key.
  #
  #  * `duplicates` - a string indicating how to handle duplicate keys:
  #     * `duplicates="overwrite"` - replace the old value with the new value (the default)
  #     * `duplicates="stack"` - create an array containing both values (in sequecne)
  #     * `duplicates="merge"` - merge the objects using `Util.merge(old,new)`
  #     * `duplicates="skip"` - keep the old value and ignore the new one
  @object_array_to_map:(array,key_field,options={})=>
    xform = options?.transform ? ((x)->x)
    duplicates = options?.duplicates ? "overwrite"
    unless duplicates in ["overwrite","stack","merge","skip"]
     throw new Error("Unrecognized value for duplicates option. Found \"#{duplicates}\". Expected \"overwrite\", \"stack\", \"skip\", \"merge\" or null.")
    map = {}
    for elt in array
      key = xform(elt[key_field])
      if map[key]? and duplicates isnt "overwrite"
        if duplicates is 'stack'
          if Array.isArray(map[key])
            map[key].push elt
          else
            map[key] = [map[key],elt]
        else if duplicates is 'merge'
          map[key] = @merge(map[key],elt)
        # else if duplicates is 'skip'
        #   # do nothing
      else
        map[key] = elt
    return map

  # ## Colors

  # **hex_to_rgb_triplet** - *convert a hex-based `#rrggbb` string to decimal `[r,g,b]` values*
  #
  # Given an HTML/CSS-style hex color string, yields an array of the R,G and B values.
  # E.g. `hex_to_rgb("#3300FF")` yields `[51,0,255]`.
  # The leading `#` character is optional, and both uppercase and lowercase letters
  # are supported.
  @hex_to_rgb_triplet:(hex)=>
    result = /^\s*#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})\s*$/i.exec(hex);
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

  # ## Random Bytes and Strings

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

  # **random_hex** - *generate a string of random hexadecimal characters*
  #
  # Generates a string of `count` pseudo-random hexadecimal digits.
  @random_hex:(count=32)=>Util._random_digits(count,16)

  # **random_alphanumeric** - *generate a string of random numbers and letters*
  #
  # Generates a string of `count` pseudo-random characters from the set `[a-z0-9]`.
  @random_alphanumeric:(count=32)=>Util._random_digits(count,36)

  # **_random_digits** - *generate a string of random bytes in the specfied base number system*
  #
  # (An internal method that generates `count` characters in the specfified base.)
  @_random_digits:(count=32,base)=>
    str = ""
    while str.length < count
      str += Math.random().toString(base).substring(2)
    if str.length > count
      str = str.substring(0,count)
    return str

  # ## Comparators and Sorting

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
      salt = Util.random_bytes(salt,'buffer')
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

  # **compare** - *a basic comparator function*
  #
  # A basic comparator, using JavaScript's default `<` and `>` operators.
  # Allows `null` values, which are sorted before any non-null values.
  #
  # Returns:
  #  - a positive integer when `a > b`, or when `a` is not `null` and `b` is `null`
  #  - a negative integer when `a < b`, or when `a` is `null` and `b` is not `null`
  #  - zero (`0`) otherwise (when `!(a > b) && !(a < b)` or when both `a` and `b` are `null`).
  @compare:(a,b)=>
    if a? and b?
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
    result = Util.compare(A,B)
    if result is 0
      result = Util.compare(a,b)
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

  # ## Various Other Utilities

  # Identifies the "client IP" for the given request in various circumstances
  @remote_ip:(req)=>
    req?.get?('x-forwarded-for') ?
    req?.headers?['x-forwarded-for'] ?
    req?.connection?.remoteAddress ?
    req?.socket?.remoteAddress ?
    req?.connection?.socket?.remoteAddress

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
        v = Util.uuid(uuid.v1())
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

  # **b64e** - *encodes a buffer as Base64*
  #
  # Base64-encodes the given Buffer or string, returning a string.
  # When a string value is provided, the optional `output_encoding` attribute
  # specifies the encoding to use when converting characters to bytes.
  @b64e:(buf,output_encoding='utf8')=>
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
  @b64d:(buf,output_encoding='utf8')=>
    if not buf?
      return null
    else
      unless buf instanceof Buffer
        buf = new Buffer(buf.toString(),'base64')
      return buf.toString(output_encoding)

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
    init = ()-> i = 0;
    cond = ()-> (i < list.length)
    incr = ()-> i += 1
    act  = (next)-> action(list[i],i,list,next)
    Util.for_async(init, cond, act, incr, whendone)

  # **procedure** - *generates a new `Sequencer` object, as described below.*
  @procedure:()=>(new Sequencer())

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


# ## Exports

# The `Util` and `Sequencer` types are exported by this module.

exports.Util = Util
exports.Sequencer = Sequencer
