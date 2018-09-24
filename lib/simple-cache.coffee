# fs                     = require 'fs'
# path                   = require 'path'
# HOME_DIR               = path.join(__dirname,'..')
# LIB_COV                = path.join(HOME_DIR,'lib-cov')
# LIB_DIR                = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
#------------------------------------------------------------------------------#
DEFAULT_TTL            = 5*60*1000
DEFAULT_VALUE          = undefined
DEFAULT_PURGE_INTERVAL = undefined

class SimpleCache

  constructor:(config)->
    config ?= {}
    @set_default_ttl(config.default_ttl ? config["default-ttl"] ? config.ttl ? DEFAULT_TTL)
    @set_default_value(config.default_value ? config["default-value"] ? config.default_val ? config["default-val"] ? config.value ? config.val ? config.default ?  DEFAULT_VALUE)
    @set_purge_interval(config.purge_interval ? config["purge-interval"] ?  DEFAULT_PURGE_INTERVAL)
    @cache = {}

  # sets the time-to-live (in milliseconds) that will be used when no other value is specified in `set`
  # (defaults to `300000` (five minutes).)
  set_default_ttl:(ttl)=>
    @default_ttl = ttl

  # sets the value returned by `get` when the specified key is missing or expired.
  # (defaults to `undefined`)
  set_default_value:(value)=>
    @default_value = value

  # when set to a positive integer value, (roughly) every `purge_interval` milliseconds all expired entries will be removed from the cache
  # when set to any other value, the existing purge interval (if any) will be canceled
  set_purge_interval:(purge_interval)=>
    if @purge_worker?
      clearInterval @purge_worker
    if purge_interval > 0
      @purge_worker = setInterval @purge_expired_entries, purge_interval

  # stops any existing purge-interval
  clear_purge_interval:()=>
    @set_purge_interval(null)

  # get the value associated with the given `key`, assuming it has not yet expired
  # `options` is entirely option but when present may include
  #  * `ignore_ttl` - a boolean that when `true` causes the value to be returned (and the cache entry not to be deleted) regardless of the TTL status
  #  * `default` - a value to return when there is no valid entry in the cache for the given key (overrides `default_value`)
  get:(key,options)=>
    options ?= {}
    [expiry, value] = @cache[key] ? []
    if expiry? and expiry < Date.now() and (not options.ignore_ttl)
      value = undefined
      delete @cache[key]
    return value ? options.default ? DEFAULT_VALUE

  # alias for `contains_key`
  contains:(key,options)=>
    return @contains_key(key, options)

  # returns `true` if there is an un-expired entry for the given `key` (even if that value is `undefined` or `null`)
  # `options` is entirely option but when present may include:
  #  * `ignore_ttl` (see `get`)
  contains_key:(key,options)=>
    options ?= {}
    [expiry, value] = @cache[key] ? []
    if expiry? and expiry < Date.now() and (not options.ignore_ttl)
      expiry = undefined
      delete @cache[key]
    return expiry?

  # alias for `set`
  put:(key,value,options)=>
    return @set key, value, options

  # set the `value` to be associated with the given `key
  # `options` is entirely option but when present may include
  #  * `ttl` - an integer number of milliseconds from now for which to consider this element valid (defaults to `default_ttl`)
  set:(key,value,options)=>
    options ?= {}
    ttl = options.ttl ? @default_ttl
    expiry = Date.now() + ttl
    @cache[key] = [expiry, value]
    return value

  # alias for `get_set`
  get_put:(key,value,options)=>
    return @get_set key, value, options


  # same as `set` save that the previous entry in the cache (if any) is returned
  get_set:(key,value,options)=>
    old_value = @get key, options
    @set key, value, options
    return old_value

  # returns all currently live keys in the cache
  # options:
  #  - `ignore_ttl` - when `true` keys will be returned whether or not the corresponding entry is expired
  #  - `all` - when `true`, same as `ignore_ttl`
  keys:(options)=>
    options ?= {}
    if options.ignore_ttl or options.all
      return Object.keys(@cache)
    else
      now = Date.now()
      keys = []
      for key, [expiry, value] of @cache
        if expiry < now
          delete @cache[key]
        else
          keys.push key
      return keys

  # returns all currently live elements in the cache as any array of values.
  # options:
  #  - `ignore_ttl` - when `true` elements will be returned whether or not the corresponding entry is expired
  #  - `all` - when `true`, same as `ignore_ttl`
  values:(options)=>
    options ?= {}
    now = Date.now()
    values = []
    for key, [expiry, value] of @cache
      if expiry < now and not (options.all or options.ignore_ttl)
        delete @cache.key
      else
        values.push value
    return values

  # returns all currently live elements in the cache as any array of `[key, value]` pairs.
  # options:
  #  - `ignore_ttl` - when `true` elements will be returned whether or not the corresponding entry is expired
  #  - `all` - when `true`, same as `ignore_ttl`
  pairs:(options)=>
    options ?= {}
    now = Date.now()
    pairs = []
    for key, [expiry, value] of @cache
      if expiry < now and not (options.all or options.ignore_ttl)
        delete @cache.key
      else
        pairs.push [key, value]
    return pairs

  # removes the specified element from the cache (if any)
  clear:(key,options)=>
    delete @cache[key]

  # same as `clear` save that the previous entry in the cache (if any) is returned
  get_clear:(key,options)=>
    old_value = @get key, options
    @clear key, options
    return old_value

  # clears all keys matching the given regexp
  # (or more generally, all keys for which `pattern.test(key)` yields `true`)
  clear_matching:(pattern,options)=>
    keys = @keys(all:true)
    for key in keys
      if pattern.test(key)
        @clear(key,options)

  clear_all:(options)=>
    @cache = {}

  purge_expired_entries:(options)=>
    ignored = @keys(options) # currently the `keys` method deletes expired entries automatically, so just use that
    return undefined

exports.SimpleCache = SimpleCache
