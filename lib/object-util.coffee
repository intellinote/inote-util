class ObjectUtil

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

################################################################################

exports.ObjectUtil = exports.MapUtil = ObjectUtil
