# This class contains some basic utilties for working with
# [dust.js](https://akdubya.github.io/dustjs/).
#
# Note that to avoid adding an unnecessary dependency it does not include or
# import the dust engine by default.
#
# The `ensure_dust` function will lazily-require `dustjs-linkedin` if
# the `@dust` attribute is not otherwise set.
class DustUtil

  constructor:(dust)->
    @set_dust(dust)

  set_dust:(dust)=>
    @dust = dust

  get_dust:()=>
    return @dust

  # Lazily require `dustjs-linkedin` so that this file can be
  # instantiated without having `dustjs-linkedin` available.
  ensure_dust:()=>
    if @dust?
      return @dust
    else
      @set_dust(require('dustjs-linkedin'))
      return @dust

  # Compiles dust template source code into a "dust function".
  #
  # `template_source` - the source of the dust template (a string)
  #
  # Returns the compiled function.
  #
  # Uses `ensure_dust`, which may `require('dustjs-linked')`.
  compile_template:(template_source)=>
    return @ensure_dust().compileFn template_source

  # Renders a dust template in the given context, calling-back with
  # the generated output.
  #
  # `template` - compiled dust function of dust template source (as a string)
  # `context` - dust context (or map)
  # `callback` - signature `(err, output)`
  #
  # Uses `ensure_dust`, which may `require('dustjs-linked')`.
  render_template:(template, context, callback)->
    if typeof context is 'function' and not callback?
      callback = context
      context = null
    context ?= { }
    if typeof template is 'function'
      template(context, callback)
    else
      @ensure_dust().renderSource template, context, callback

  # when `str` is a dust function, renders it and returns result
  # otherwise returns `str`.
  #
  # - `str` - dust fragment
  # - `chunk` - currently executing chunk
  # - `context` containing context
  eval_dust_string:(str, chunk, context)->
    if typeof str is "function"
      if str.length is 0
        str = str()
      else
        buf = ''
        (chunk.tap (data) ->
          buf += data; return '').render( str, context ).untap()
        str = buf
    return str

  # renders bodies.block iff b is true, bodies.else otherwise
  render_if_else:(b, chunk, context, bodies, params)->
    if b is true
       if bodies?.block?
         chunk = chunk.render(bodies.block, context)
    else
      if bodies?.else?
        chunk = chunk.render(bodies.else, context)
    return chunk

  ctx_get:(context, names, default_value)->
    unless context?
      return default_value
    else
      unless Array.isArray(names)
        names = [names]
      if typeof context.get is 'function' and context.stack? # context is a dust context
        get = (x)->context.get(x)
      else # else a regular map
        get = (x)->context[x]
      for name in names
        val = get(name)
        if val?
          return val
      return default_value
    # if bodies.block?
    # return chunk.capture bodies.block, context, (body_data, chunk) ->

  maybe_capture_block:(chunk, block, context, callback)->
    callback @eval_dust_string(block ? "", chunk, context), chunk

  ensure_empty_template:()=>
    unless @empty_template?
      @empty_template = @compile_template("")
    return @empty_template

exports.DustUtil = new DustUtil()
exports.DustUtil.constructor = exports.DustUtil.DustUtil = DustUtil
exports.DustUtil.init = (dust)->return new DustUtil(dust)
