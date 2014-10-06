should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
TEST_DIR = path.join(HOMEDIR,'test')

describe 'Config',=>

  beforeEach (done)=>
    @original_node_env = process.env.NODE_ENV
    @original_config_file = process.env.config_file
    @original_config_dir = process.env.config_dir
    done()

  afterEach (done)=>
    # restore environment variables
    if @original_node_env
      process.env.NODE_ENV = @original_node_env
    else
      delete process.env.NODE_ENV
    if @original_config_file?
      process.env.config_file = @original_config_file
    else
      delete process.env.config_file
    if @original_config_dir?
      process.env.config_dir = @original_config_dir
    else
      delete process.env.config_dir
    # purge config from required files
    delete require.cache[path.join(LIB_DIR,'config.coffee')]
    delete require.cache[path.join(LIB_DIR,'config.js')]
    # purge nconf from required files
    for key, value of require.cache
      if /\/node_modules\/nconf\//.test key
        delete require.cache[key]
    done()

  it 'can load configuration file based on NODE_ENV', (done)=>
    process.env.NODE_ENV = 'unit-testing'
    config  = require(path.join(LIB_DIR,'config')).config.init()
    config.get('mock-config').should.be.ok
    config.get('mock-config:source').should.equal 'config/unit-testing.json'
    done()

  it 'supports properties of various types', (done)=>
    process.env.NODE_ENV = 'unit-testing'
    config  = require(path.join(LIB_DIR,'config')).config.init()
    config.get('mock-config').should.be.ok
    config.get('mock-config:bool-value').should.equal true
    config.get('mock-config:int-value').should.equal 17
    config.get('mock-config:float-value').should.equal 3.14159
    config.get('mock-config:string-value').should.equal 'Lorem Ipsum'
    (config.get('mock-config:null-value')?).should.not.be.ok
    config.get('mock-config:array-value')[0].should.equal true
    config.get('mock-config:array-value')[1].should.equal 17
    config.get('mock-config:array-value')[2].should.equal 3.14159
    config.get('mock-config:array-value')[3].should.equal 'Lorem Ipsum'
    config.get('mock-config:map-value')['int-value'].should.equal 19
    config.get('mock-config:map-value:int-value').should.equal 19
    done()

  it 'supports default values passed to init', (done)=>
    defaults = {
      "foo":"bar"
      "mock-config": {
        "int-value": -3
        "other-int-value": -5
      }
    }
    process.env.NODE_ENV = 'unit-testing'
    config  = require(path.join(LIB_DIR,'config')).config.init(defaults)
    config.get('mock-config').should.be.ok
    config.get('mock-config:int-value').should.equal 17
    config.get('mock-config:other-int-value').should.equal -5
    config.get('foo').should.equal 'bar'
    done()

  it 'supports override values passed to init', (done)=>
    overrides = {
      "foo":"bar"
      "mock-config": {
        "int-value": -3
        "other-int-value": -5
        "source": "override-passed-to-constructor"
      }
    }
    process.env.NODE_ENV = 'unit-testing'
    config  = require(path.join(LIB_DIR,'config')).config.init(null,overrides)
    config.get('mock-config').should.be.ok
    config.get('mock-config:int-value').should.equal -3
    config.get('mock-config:other-int-value').should.equal -5
    config.get('foo').should.equal 'bar'
    config.get('mock-config:source').should.equal 'override-passed-to-constructor'
    done()

  it 'supports config_dir set in environment variable', (done)=>
    process.env.NODE_ENV = 'mock-config'
    process.env.config_dir = TEST_DIR
    config = require(path.join(LIB_DIR,'config')).config.init()
    config.get('mock-config').should.be.ok
    config.get('mock-config:source').should.equal 'test/mock-config.json'
    done()

  it 'supports config_dir defined in an override', (done)=>
    process.env.NODE_ENV = 'mock-config'
    overrides = { "config_dir": TEST_DIR }
    config = require(path.join(LIB_DIR,'config')).config.init(null,overrides)
    config.get('mock-config').should.be.ok
    config.get('mock-config:source').should.equal 'test/mock-config.json'
    done()

  it 'supports config_file set in environment variable', (done)=>
    process.env.NODE_ENV = 'unit-testing'
    process.env.config_file = path.join(TEST_DIR,'mock-config.json')
    config = require(path.join(LIB_DIR,'config')).config.init()
    config.get('mock-config').should.be.ok
    config.get('mock-config:source').should.equal 'test/mock-config.json'
    done()

  it 'supports config_file defined in an override', (done)=>
    process.env.NODE_ENV = 'unit-testing'
    overrides = { "config_file": path.join(TEST_DIR,'mock-config.json') }
    config = require(path.join(LIB_DIR,'config')).config.init(null,overrides)
    config.get('mock-config').should.be.ok
    config.get('mock-config:source').should.equal 'test/mock-config.json'
    done()
