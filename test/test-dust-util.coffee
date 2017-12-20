require 'coffee-errors'
#------------------------------------------------------------------------------#
fs         = require 'fs'
path       = require 'path'
HOME_DIR   = path.join(__dirname, '..')
LIB_COV    = path.join(HOME_DIR, 'lib-cov')
LIB_DIR    = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR, 'lib')
#------------------------------------------------------------------------------#
assert     = require 'assert'
#------------------------------------------------------------------------------#
DustUtil   = require(path.join(LIB_DIR, 'dust-util')).DustUtil.DustUtil
StringUtil = require(path.join(LIB_DIR, 'string-util')).StringUtil
#------------------------------------------------------------------------------#

describe 'DustUtil', ()->

  it "renders templates from strings", (done)->
    du = new DustUtil()
    template = "Hello {name}!"
    context = { name: "World" }
    du.render_template template, context, (err, output)->
      assert.ok not err?, err
      assert.equal output, "Hello World!"
      done()

  it "compiles templates and later renders them", (done)->
    du = new DustUtil()
    template_source = "Hello {name}!"
    template = du.compile_template template_source
    context = { name: "World" }
    du.render_template template, context, (err, output)->
      assert.ok not err?, err
      assert.equal output, "Hello World!"
      done()

  it "supports creation of helper tags", (done)->
    du = new DustUtil()
    my_helper = (chunk, context, bodies, params)->
      assert.equal du.ctx_get(context, ["not_name", "name"]), "World"
      assert.equal du.ctx_get(context, "name"), "World"
      flag = StringUtil.truthy_string(du.eval_dust_string(params.flag, chunk, context))
      return du.render_if_else flag, chunk, context, bodies, params
    du.ensure_dust().helpers ?= {}
    du.ensure_dust().helpers.myhelper = my_helper
    source = '{@myhelper flag="{the_flag}"}TRUE{:else}FALSE{/myhelper}!'
    template = du.compile_template(source)
    context = { name: "World", the_flag: true }
    du.render_template template, context, (err, output)->
      assert.ok not err?, err
      assert.equal output, "TRUE!"
      context = { name: "World", the_flag: false }
      du.render_template template, context, (err, output)->
        assert.ok not err?, err
        assert.equal output, "FALSE!"
        done()
