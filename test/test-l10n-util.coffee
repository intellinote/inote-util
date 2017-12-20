require 'coffee-errors'
#------------------------------------------------------------------------------#
fs              = require 'fs'
path            = require 'path'
HOME_DIR        = path.join(__dirname, '..')
LIB_COV         = path.join(HOME_DIR, 'lib-cov')
LIB_DIR         = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR, 'lib')
DATA_DIR        = path.join(HOME_DIR, 'test', 'data', 'test-l10n')
#------------------------------------------------------------------------------#
assert          = require 'assert'
#------------------------------------------------------------------------------#
L10nUtil        = require(path.join(LIB_DIR, 'l10n-util')).L10nUtil
DustUtil        = require(path.join(LIB_DIR,'dust-util')).DustUtil.DustUtil
#------------------------------------------------------------------------------#

describe 'L10nUtil', ()->

  ### jshint loopfunc: true ###
  describe 'parse_locale()', ()->
    tests = [
      [ "fr-CH", [ 'fr', 'CH' ] ]
      [ "fr", [ 'fr', null ] ]
      [ null, null ]
      [ '',  null ]
      [ 'en', [ 'en', null ] ]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      ((input, expected)->
        it "#{JSON.stringify(input)} -> #{JSON.stringify(expected)}", (done)->
          found = L10nUtil.parse_locale(input)
          assert.deepEqual found, expected
          done())(input, expected)
  ### jshint loopfunc: false ###

  ### jshint loopfunc: true ###
  describe 'identify_locales()', ()->
    tests = [
      [ "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5", [ ['fr', 'CH'], ['fr', null], ['en', null], ['de', null] ] ]
      [ "fr-CH, fr", [ ['fr', 'CH'], ['fr', null] ] ]
      [ null, null ]
      [ '', null ]
      [ 'en', [ ['en', null] ] ]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      ((input, expected)->
        it "#{JSON.stringify(input)} -> #{JSON.stringify(expected)}", (done)->
          mock_req = { header:()->return input }
          found = L10nUtil.identify_locales(mock_req)
          assert.deepEqual found, expected
          done())(input, expected)
  ### jshint loopfunc: false ###

  ### jshint loopfunc: true ###
  describe 'expand_locales()', ()->
    tests = [
      [ [ ['fr', 'CH'], ['en', null], ['de', null] ],  [ ['fr', 'CH'], ['fr', null], ['en', null], ['de', null] ]]
      [ [ ['fr', 'CH'], ['fr', null], ['en', null], ['de', null] ],  [ ['fr', 'CH'], ['fr', null], ['en', null], ['de', null] ]]
      [ [ ['fr', 'CH'] ],  [ ['fr', 'CH'], ['fr', null] ] ]
      [ [ ['fr', null] ],  [ ['fr', null] ] ]
      [ [ ],  [ ] ]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      ((input, expected)->
        it "#{JSON.stringify(input)} -> #{JSON.stringify(expected)}", (done)->
          found = L10nUtil.expand_locales(input)
          assert.deepEqual found, expected
          done())(input, expected)
  ### jshint loopfunc: false ###

  ### jshint loopfunc: true ###
  describe 'identify_and_expand_locales()', ()->
    tests = [
      [ "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5",  [ ['fr', 'CH'], ['fr', null], ['en', null], ['de', null] ]]
      [ "fr-CH, en;q=0.8, de;q=0.7, *;q=0.5",  [ ['fr', 'CH'], ['fr', null], ['en', null], ['de', null] ]]
      [ "",  null ]
      [ null,  null ]
    ]
    for test in tests
      input = test[0]
      expected = test[1]
      ((input, expected)->
        it "#{JSON.stringify(input)} -> #{JSON.stringify(expected)}", (done)->
          mock_req = { header:()->return input }
          found = L10nUtil.identify_and_expand_locales(mock_req)
          assert.deepEqual found, expected
          done())(input, expected)
  ### jshint loopfunc: false ###

  ### jshint loopfunc: true ###
  describe 'match_locale()', ()->
    tests = [
      [ [ [ ['fr', 'CH'], ['fr', null] ], { "fr-ch": true } ], 'fr-ch' ]
      [ [ [ ['fr', 'CH'], ['fr', null] ], { "fr": true } ], 'fr' ]
      [ [ [ ['fr', 'CH'], ['fr', null] ], { "en": true } ], null ]
      [ [ [ ['fr', 'CH'], ['fr', null] ], { "en": true }, 'en-us' ], 'en-us' ]
    ]
    for test in tests
      accepted = test[0][0]
      available = test[0][1]
      default_val = test[0][2]
      expected = test[1]
      ((accepted, available, default_val, expected)->
        it "#{JSON.stringify([accepted, available, default_val])} -> #{JSON.stringify(expected)}", (done)->
          found = L10nUtil.match_locale(accepted, available, default_val)
          assert.deepEqual found, expected
          done())(accepted, available, default_val, expected)
  ### jshint loopfunc: false ###

  it "load_l10n_files() can read and process localization files from disk", (done)->
    L10nUtil.load_l10n_files DATA_DIR, (err, available)->
      assert.ok not err?, err
      assert.ok available?
      # fr
      assert.ok available["fr"]?
      assert.equal available["fr"].foo, "foo from fr.json"
      assert.equal available["fr"].bar, "bar from fr.json"
      assert.equal available["fr"].another, "another from fr.json"
      assert.equal Object.keys(available["fr"]).length, 3
      # fr-CH
      assert.ok available["fr-ch"]?
      assert.equal available["fr-ch"].foo, "foo from fr.json", "Expected fr-CH locale to inherit undefined keys from fr locale."
      assert.equal available["fr-ch"].bar, "bar from fr-CH.json"
      assert.equal available["fr-ch"].another, "another from fr.json", "Expected fr-CH locale to inherit undefined keys from fr locale."
      assert.equal available["fr-ch"].different, "I am not found in fr.json"
      assert.equal Object.keys(available["fr-ch"]).length, 4
      done()

  it "localize() can render localized strings", (done)->
    templates = {
      "joke": "There are %b kinds of people in the world. Those who understand binary and those that don't. (That's %d in decimal notation :).)"
    }
    found = L10nUtil.localize templates, "joke", 2, 2
    assert.equal found, "There are 10 kinds of people in the world. Those who understand binary and those that don't. (That's 2 in decimal notation :).)"
    #
    found = L10nUtil.localize templates, "joke", [ 2, 2 ]
    assert.equal found, "There are 10 kinds of people in the world. Those who understand binary and those that don't. (That's 2 in decimal notation :).)"
    #
    localizer = L10nUtil.make_localizer templates
    found = localizer "joke", 2, 2
    assert.equal found, "There are 10 kinds of people in the world. Those who understand binary and those that don't. (That's 2 in decimal notation :).)"
    #
    localizer = L10nUtil.make_localizer {"foo":"This string has no parameters."}
    found = localizer "joke", 2, 2
    assert.equal found, null
    found = localizer "foo"
    assert.equal found, "This string has no parameters."
    done()

  it "localize() supports singular and plural variations (singluar/plural case)", (done)->
    templates = {
      "foo": {
        "singular": "There is only one foo."
        "plural": "There are %d foos."
      }
    }
    assert.equal L10nUtil.localize(templates, "foo", 0), "There are 0 foos."
    assert.equal L10nUtil.localize(templates, "foo", 1), "There is only one foo."
    assert.equal L10nUtil.localize(templates, "foo", 2), "There are 2 foos."
    assert.equal L10nUtil.localize(templates, "foo", 10), "There are 10 foos."
    done()

  it "localize() supports singular and plural variations (0/1/2 case)", (done)->
    templates = {
      "foo": {
        "0": "There are no foos."
        "1": "There is only one foo."
        "2": "There are %d foos."
      }
    }
    assert.equal L10nUtil.localize(templates, "foo", 0), "There are no foos."
    assert.equal L10nUtil.localize(templates, "foo", 1), "There is only one foo."
    assert.equal L10nUtil.localize(templates, "foo", 2), "There are 2 foos."
    assert.equal L10nUtil.localize(templates, "foo", 10), "There are 10 foos."
    done()

  it "localize() supports singular and plural variations (none/one/many case)", (done)->
    templates = {
      "foo": {
        "none": "There are no foos."
        "one": "There is only one foo."
        "many": "There are %d foos."
      }
    }
    assert.equal L10nUtil.localize(templates, "foo", 0), "There are no foos."
    assert.equal L10nUtil.localize(templates, "foo", 1), "There is only one foo."
    assert.equal L10nUtil.localize(templates, "foo", 2), "There are 2 foos."
    assert.equal L10nUtil.localize(templates, "foo", 10), "There are 10 foos."
    done()

  it "localize() supports null and not-null variations", (done)->
    templates = {
      "foo": {
        "null": "There don't seem to be any foos yet. Why don't you create one?"
        "0": "There are 0 foos."
        "not-null": "The value of foo is %s."
      }
    }
    assert.equal L10nUtil.localize(templates, "foo", 0), "There are 0 foos."
    assert.equal L10nUtil.localize(templates, "foo", null), "There don't seem to be any foos yet. Why don't you create one?"
    assert.equal L10nUtil.localize(templates, "foo", undefined), "There don't seem to be any foos yet. Why don't you create one?"
    assert.equal L10nUtil.localize(templates, "foo"), "There don't seem to be any foos yet. Why don't you create one?"
    assert.equal L10nUtil.localize(templates, "foo", 10), "The value of foo is 10."
    done()

  it "localize() supports true and false variations", (done)->
    templates = {
      "foo": {
        "true": "You betcha!"
        "false": "Well, actually..."
      }
    }
    assert.equal L10nUtil.localize(templates, "foo", true), "You betcha!"
    assert.equal L10nUtil.localize(templates, "foo", "true"), "You betcha!"
    assert.equal L10nUtil.localize(templates, "foo", false), "Well, actually..."
    assert.equal L10nUtil.localize(templates, "foo", "false"), "Well, actually..."
    done()

  describe "{@l10n} tag", ()->

    it "renders a localized string based on the provided key", (done)->
      du = new DustUtil()
      L10nUtil.add_dust_helpers(du)
      template = '{@l10n key="the-key"/}'
      context = {
        l10n: L10nUtil.make_localizer {"the-key":"The string mapped to the key."}
      }
      du.render_template template, context, (err, output)->
        assert.ok not err?, err
        assert.equal output, "The string mapped to the key."
        done()

    it "can read the key from the tag body", (done)->
      du = new DustUtil()
      L10nUtil.add_dust_helpers(du)
      template = '{@l10n}the-key{/l10n}'
      context = {
        l10n: L10nUtil.make_localizer {"the-key":"The string mapped to the key."}
      }
      du.render_template template, context, (err, output)->
        assert.ok not err?, err
        assert.equal output, "The string mapped to the key."
        done()

    it "renders the :else block if the key is not matched", (done)->
      du = new DustUtil()
      L10nUtil.add_dust_helpers(du)
      template = '{@l10n}not-the-key{:else}Not matched :({/l10n}'
      context = {
        l10n: L10nUtil.make_localizer {"the-key":"The string mapped to the key."}
      }
      du.render_template template, context, (err, output)->
        assert.ok not err?, err
        assert.equal output, "Not matched :("
        template = '{@l10n key="not-the-key"}{:else}Not matched :({/l10n}'
        du.render_template template, context, (err, output)->
          assert.ok not err?, err
          assert.equal output, "Not matched :("
          template = '{@l10n}{:else}Not matched :({/l10n}'
          du.render_template template, context, (err, output)->
            assert.ok not err?, err
            assert.equal output, "Not matched :("
            template = '{@l10n/}'
            du.render_template template, context, (err, output)->
              assert.ok not err?, err
              assert.equal output, ""
              done()

    it "passes parameters as arguments to sprintf (single 'args' param case)", (done)->
      du = new DustUtil()
      L10nUtil.add_dust_helpers(du)
      # IN TEMPLATE
      template = '{@l10n key="the-key" args="1,2,three"/}'
      context = {
        l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
      }
      du.render_template template, context, (err, output)->
        assert.ok not err?, err
        assert.equal output, "First: 1; Second: 10; Third: three."
        # IN CONTEXT (STRING)
        template = '{@l10n key="the-key" args=the_args/}'
        context = {
          the_args: "1,2,three"
          l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
        }
        du.render_template template, context, (err, output)->
          assert.ok not err?, err
          assert.equal output, "First: 1; Second: 10; Third: three."
          # IN CONTEXT (AS DUST STRING)
          template = '{@l10n key="the-key" args="{the_args}"/}'
          context = {
            the_args: "1,2,three"
            l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
          }
          du.render_template template, context, (err, output)->
            assert.ok not err?, err
            assert.equal output, "First: 1; Second: 10; Third: three."
            # IN CONTEXT (ARRAY)
            template = '{@l10n key="the-key" args=the_args/}'
            context = {
              the_args: [1,2,"three"]
              l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
            }
            du.render_template template, context, (err, output)->
              assert.ok not err?, err
              assert.equal output, "First: 1; Second: 10; Third: three."
              done()

    it "passes parameters as arguments to sprintf (multiple 'argN' params case)", (done)->
      du = new DustUtil()
      L10nUtil.add_dust_helpers(du)
      # IN TEMPLATE
      template = '{@l10n key="the-key" arg0="1" arg1="2" arg2="three"/}'
      context = {
        l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
      }
      du.render_template template, context, (err, output)->
        assert.ok not err?, err
        assert.equal output, "First: 1; Second: 10; Third: three."
        # IN TEMPLATE - out of order; numbers skipped
        template = '{@l10n key="the-key" arg4="E" arg0="A" arg2="C"/}'
        context = {
          l10n: L10nUtil.make_localizer {"the-key":"[%s,%s,%s,%s,%s,%s]"}
        }
        du.render_template template, context, (err, output)->
          assert.ok not err?, err
          assert.equal output, "[A,undefined,C,undefined,E,undefined]"
          # AS CONTEXT VARS
          template = '{@l10n key="the-key" arg0=zero arg1="2" arg2=three/}'
          context = {
            zero: 1
            three: "three"
            l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
          }
          du.render_template template, context, (err, output)->
            assert.ok not err?, err
            assert.equal output, "First: 1; Second: 10; Third: three."
            # AS DUST STRINGS
            template = '{@l10n key="the-key" arg0="{zero}" arg1="2" arg2="{three}"/}'
            context = {
              zero: 1
              three: "three"
              l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
            }
            du.render_template template, context, (err, output)->
              assert.ok not err?, err
              assert.equal output, "First: 1; Second: 10; Third: three."
            done()
        # # IN CONTEXT (STRING)
        # template = '{@l10n key="the-key" args=the_args/}'
        # context = {
        #   the_args: "1,2,three"
        #   l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
        # }
        # du.render_template template, context, (err, output)->
        #   assert.ok not err?, err
        #   assert.equal output, "First: 1; Second: 10; Third: three."
        #   # IN CONTEXT (ARRAY
        #   template = '{@l10n key="the-key" args=the_args/}'
        #   context = {
        #     the_args: [1,2,"three"]
        #     l10n: L10nUtil.make_localizer {"the-key":"First: %d; Second: %b; Third: %s."}
        #   }
        #   du.render_template template, context, (err, output)->
        #     assert.ok not err?, err
        #     assert.equal output, "First: 1; Second: 10; Third: three."
        #     done()
