class ObjectUtil

  @deep_equals:(a,b)=>@deep_equal(a,b)

  @deep_equal:(a,b)=>
    if not a? and not b?                               # if both null/undefined -> equal
      return true
    else if a? isnt b?                                 # if only one is null/undefined -> not equal
      return false
    else if Array.isArray(a) isnt Array.isArray(b)     # if only one is an array -> not equal
      return false
    else if Array.isArray(a) and Array.isArray(b)      # if both are arrays...
      unless a.length is b.length                      # ...different length -> not equal
        return false
      else                                             # ...else do an element by element comparision
        for elt, i in a
          unless @deep_equal(elt, b[i])
            return false
        return true
    else if @is_true_object(a) isnt @is_true_object(b) # if only one is an object (map) -> not equal
      return false
    else if @is_true_object(a) and @is_true_object(b)  # if both are objects, compare all each element of _both_ objects
      checked = []
      for n, v of a
        unless @deep_equal v, b[n]
          return false
        else
          checked.push n
      for n, v of b
        unless n in checked
          unless @deep_equal v, a[n]
            return false
      return true
    else
      return a is b                                    # otherwise just compare with `is`

  @__JSON_DIFF_ADD: "a"
  @__JSON_DIFF_REM: "d"
  @__JSON_DIFF_CHG: "c"
  @__JSON_DIFF_NIL: undefined

  @is_true_object:(obj)->
    return obj? and (typeof obj is 'object') and (not Array.isArray(obj))

  @__diff_non_objects:(old_val, new_val)=>
      if old_val? and not new_val?
        return @__JSON_DIFF_REM
      else if new_val? and not old_val? # could happen when a null or undefiend value is stored in old_map
        return @__JSON_DIFF_ADD
      else if not new_val? and not old_val?
        return @__JSON_DIFF_NIL
      else if Array.isArray(old_val) and Array.isArray(new_val)
        if @deep_equal old_val, new_val
          return @__JSON_DIFF_NIL
        else
          return @__JSON_DIFF_CHG
      else if Array.isArray(old_val) isnt Array.isArray(new_val)
        return @__JSON_DIFF_CHG
      else unless (typeof old_val) is (typeof new_val)
        return @__JSON_DIFF_CHG
      else if old_val isnt new_val
        return @__JSON_DIFF_CHG
      else
        return @__JSON_DIFF_NIL

  @__diff_objects:(old_map, new_map)=>
    delta = null
    check_fn = (name, val_a, val_b)=>
      if @is_true_object(val_a) and @is_true_object(val_b)
        child = @__diff_objects val_a, val_b
        if child?
          delta ?= {}
          delta[name] = child
      else
        child = @__diff_non_objects val_a, val_b
        if child?
          delta ?= {}
          delta[name] = child
    checked = []
    for name, old_val of old_map # check elements of old_map
      new_val = new_map[name]
      check_fn(name, old_val, new_val)
      checked.push name
    for name, new_val of new_map # check (any unchecked) elements of new_map
      unless name in checked
        old_val = old_map[name]
        check_fn(name, old_val, new_val)
    return delta

  @json_diff:(old_map, new_map)=>@diff_json(old_map, new_map)

  @diff_json:(old_map, new_map)=>
    if @is_true_object(old_map) and @is_true_object(new_map)
      return @__diff_objects old_map, new_map
    else
      return @__diff_non_objects old_map, new_map

  # converts `{"foo":{"bar":3}}` to `{"foo.bar":3}`
  @flatten_map:(map, delim=".")=>
    @_flatten_map([],{},map,delim)

  @_flatten_map:(ancestory,flat,map,delim=".")=>
    for n, v of map
      new_ancestory = ancestory.slice(0)
      new_ancestory.push n
      if v? and typeof v is 'object' and not Array.isArray(v)
        flat = @_flatten_map new_ancestory, flat, v, delim
      else
        flat[new_ancestory.join(delim)] = v
    return flat

  # **remove_null** - *`delete` any attribute whose value evaluates to null*
  # Returns a new map or array, with `null` values removed.
  @remove_null:(map)=>
    unless map?
      return null
    else if Array.isArray(map)
      new_array = []
      for elt in map
        if elt?
          new_array.push elt
      return new_array
    else if typeof map is 'object'
      new_map = {}
      for n,v of map
        if v?
          new_map[n] = v
      return new_map
    else
      return map

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
    for m in args ? []
      for n,v of m ? {}
        map[n] = v
    return map

  # **deep_merge** - *recursively merge multiple maps into a new, combined map*
  @deep_merge:(args...)=>
    map = {}
    if args.length is 1 and Array.isArray(args[0])
      args = args[0]
    for m in args ? []
      for n,v of m ? {}
        if v? and (typeof v is 'object') and (not Array.isArray(v))
          unless map[n]? and (typeof map[n] is 'object') and (not Array.isArray(v))
            map[n] = @shallow_clone(v)
          else
            map[n] = @deep_merge map[n], v
        else
          map[n] = v
    return map

  # **shallow_clone** - *create a "shallow" copy of a mqp*
  #
  # Creates an independent map with the same keys as `map`.
  # The entries within the `map` will *not* be cloned.
  # The new map will contain a reference to the same underlying object
  # as the original map.
  #
  # If `map` is `null`, the value `null` is returned.
  @shallow_clone:(map)=>
    unless map?
      return null
    else if Array.isArray(map)
      new_array = []
      new_array = new_array.concat(map)
      return new_array
    else if typeof map is 'string'
      return new String(map)
    else if typeof map in ['number','boolean']
      return map
    else
      new_map = {}
      for k,v of map
        new_map[k] = v
      return new_map

  # **deep_clone** - *create a copy of a map*
  #
  # Creates an independent map with the same keys as `map`.
  # Any map- or array-valued entry in `map` will be cloned in a recursive fashion.
  #
  # If `map` is `null`, the value `null` is returned.
  @deep_clone:(map)=>
    unless map?
      return null
    else if Array.isArray(map)
      new_array = []
      for elt in map
        new_array.push @deep_clone(elt)
      return new_array
    else if typeof map in ['string','number','boolean']
      return @shallow_clone(map)
    else
      new_map = {}
      for k,v of map
        new_map[k] = @deep_clone(v)
      return new_map

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


  # returns the attribute value at `path` in `json`
  @get_json_path:(json, path...)->
    if typeof path is 'string'
      path = [path]
    if path.length is 1 and Array.isArray(path[0])
      path = path[0]
    for name in path
      json = json?[name]
      unless json?
        return null
    return json

  # like `get_json_path` except `@name` and `name.$` are supported
  @get_funky_json_path:(json, path...)->
    if typeof path is 'string'
      path = [path]
    if path.length is 1 and Array.isArray(path[0])
      path = path[0]
    for name in path
      json = json[name] ? json["@#{name}"]
      unless json?
        return null
    return json?.$ ? json

################################################################################

exports.ObjectUtil = exports.MapUtil = ObjectUtil
