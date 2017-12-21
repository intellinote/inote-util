fs         = require 'fs'
path       = require 'path'
HOME_DIR   = path.join(__dirname,'..')
LIB_COV    = path.join(HOME_DIR,'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
#------------------------------------------------------------------------------#
sprintf    = require("sprintf-js").sprintf
#------------------------------------------------------------------------------#
Util       = require(path.join(LIB_DIR,'util')).Util
LogUtil    = require(path.join(LIB_DIR,'log-util')).LogUtil
FileUtil   = require(path.join(LIB_DIR,'file-util')).FileUtil
AsyncUtil  = require(path.join(LIB_DIR,'async-util')).AsyncUtil
ObjectUtil = require(path.join(LIB_DIR,'object-util')).ObjectUtil
DustUtil   = require(path.join(LIB_DIR,'dust-util')).DustUtil.DustUtil
#------------------------------------------------------------------------------#

class L10nUtil

  constructor:(config)->
    config ?= {}
    @locale_re = /^([a-z]+)(-([a-z]+))??$/i
    if config.dust? or config.dust_util?
      @dust_util = config.dust_util ? new DustUtil(config.dust)

  set_dust_util:(dust_util)=>
    @dust_util = dust_util

  add_dust_helpers:(dust)=>
    if dust instanceof DustUtil
      @dust_util ?= dust
      dust = dust.dust
    if dust? and not @dust_util?
      @dust_util = new DustUtil(dust)
    if not dust?
      @dust_util ?= new DustUtil()
      dust = @dust_util.ensure_dust()
    dust.helpers ?= {}
    dust.helpers.l10n = @l10n_dust_helper

  l10n_dust_helper:(chunk, context, bodies, params)=>
    @dust_util ?= new DustUtil()
    localize_fn = @dust_util.ctx_get(context, ['localizer', 'localize', 'localization', 'l10n'])
    if typeof localize_fn is 'object'
      localize_fn = @make_localizer(localize_fn)
    unless localize_fn? and typeof localize_fn is 'function'
      LogUtil.tperr "ERROR: l10n helper called but localization is missing or invalid. Will render :else block."
      localize_fn = ()->null
    key = params.key ? @dust_util.eval_dust_string (bodies.block ? ""), chunk, context
    key = key?.trim?() ? ""
    sprintf_args = []
    if params.args? and Array.isArray(params.args)
      sprintf_args = params.args
    else if params.args?
      sprintf_args = (@dust_util.eval_dust_string(params.args, chunk, context)).split(',')
    else
      non_arg_params = null
      for pn, pv of params
        pv = @dust_util.eval_dust_string(pv, chunk, context)
        match = pn.match(/^arg([0-9]+)$/)
        if match? and match[1]?
          sprintf_args[Util.to_int(match[1])] = pv
        else unless pn is 'key'
          non_arg_params ?= {}
          non_arg_params[pn] = pv
      if sprintf_args.length is 0 and non_arg_params?
        sprintf_args = non_arg_params
    result = localize_fn key, sprintf_args
    if result?
      return chunk.write(result)
    else if bodies.else?
      return chunk.render(bodies.else, context)
    else
      return chunk.write("")


  identify_and_expand_locales:(req)=>
    return @expand_locales(@identify_locales(req))

  identify_locales:(req)=>
    locales = null
    if req?
      accept_language = req.header?('accept-language') # Accept-Language: fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5
      if accept_language?
        parts = accept_language.split(';')
        for part in parts
          sub_parts = part.split(',')
          for sub_part in sub_parts
            parsed = @parse_locale(sub_part.trim())
            if parsed?
              locales ?= []
              locales.push parsed
    return locales

  parse_locale:(locale)=>
    unless locale?
      return locale
    else
      matches = locale?.match @locale_re
      if matches?[1]?
        return [matches?[1], matches?[3]]
      else
        return null

  expand_locales:(locales)->
    unless locales?
      return locales
    else
      to_return = []
      langs_found = [ ]
      last_lang = null
      for locale in (locales ? [])
        if last_lang? and (locale[0] isnt last_lang)
          unless last_lang in langs_found
            to_return.push [last_lang, null]
            langs_found.push last_lang
            last_lang = null
        to_return.push locale
        if not locale[1]?
          langs_found.push locale[0]
        else
          last_lang = locale[0]
      if last_lang? and not (last_lang in langs_found)
        to_return.push [last_lang, null]
      return to_return

  # accepted - an array of [ 'lang', 'REGION' ] elements
  # available - a map of `lang-region` (lower case)
  # default_value - returned when no match is found
  match_locale:(accepted, available, default_value)->
    unless accepted? and available?
      return default_value
    else
      for locale in accepted
        key = locale[0].toLowerCase()
        if locale[1]?
          key = "#{key}-#{locale[1].toLowerCase()}"
        if available[key]?
          return key
      return default_value

  load_l10n_files:(dir, options, callback)=>
    if typeof options is 'function' and not callback?
      callback = options
      options = null
    options ?= {}
    options.pattern ?= /^.+\.json/
    FileUtil.ls dir, options, (err, filelist)=>
      available_locales = {}
      action = (filename, index, list, next)->
        key = path.parse(filename).name.toLowerCase()
        # console.log "KEY:", key
        full_filename = path.resolve(dir, filename)
        # console.log "FULL:", full_filename
        FileUtil.load_json full_filename, {allow_comments:true, strip_comments:true}, (err, json)=>
          if err?
            LogUtil.tperr "Encountered error loading #{full_filename}. The error will be ignored:", err
          else if json?
            available_locales[key] = json
          next()
      AsyncUtil.for_each_async filelist, action, ()=>
        for name, value of available_locales
          parsed = @parse_locale(name)
          if parsed[1]? and available_locales[parsed[0]]?
            available_locales[name] = ObjectUtil.merge(available_locales[parsed[0]], value)
        callback null, available_locales

  #coffeelint:disable=cyclomatic_complexity
  localize:(localization_data, key, args...)->
    # if args contains exactly one, array-valued element, assume the args were passed in an array rather than as a variable number of arguments
    if (Array.isArray(args)) and (args.length is 1) and (Array.isArray(args[0]))
      args = args[0]
    template = localization_data?[key]
    if template?
      if typeof template in ['string', 'number', 'boolean']
        return sprintf "#{template}", args...
      else if Array.isArray(template)
        LogUtil.tperr "Array-valued template at key #{key} is not supported."
        return null
      else
        if template[args?[0]]?
          return sprintf "#{template[args[0]]}", args...
        else if template["#{args?[0]}"]?
          str = "#{args[0]}"
          return sprintf "#{template[str]}", args...
        else if (Util.to_int(args[0]) is 0) and (template['0']? or template['none']? or template[0]? or template['plural']?)
          return sprintf "#{template['0'] ? template['none'] ? template[0] ? template['plural']}", args...
        else if (Util.to_int(args?[0]) is 1) and (template['1']? or template['one']? or template[1]? or template['singular']?)
          return sprintf "#{template['1'] ? template['one'] ? template[1] ? template['singular']}", args...
        else if (Util.to_int(args?[0]) > 1) and (template['2']? or template['many']? or template[2]? or template['plural']?)
          return sprintf "#{template['2'] ? template['many'] ? template[2] ? template['plural']}", args...
        else if not args?[0]? and template['null']?
          return sprintf "#{template['null']}", args...
        else if args?[0]? and (template['not-null']? or template['not_null']? or template['notnull'])
          return sprintf "#{template['not-null'] ? template['not_null'] ? template['notnull']}", args...
        else
          return null
    else
      return null
  #coffeelint:enable=cyclomatic_complexity

  make_localizer:(localization_data)=>
    return (key, args...)=>
      return @localize(localization_data, key, args...)

exports.L10nUtil = new L10nUtil()
exports.L10nUtil.constructor = exports.L10nUtil.L10nUtil = L10nUtil
exports.L10nUtil.init = (config)->return new L10nUtil(config)
