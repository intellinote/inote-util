# inote-util [![Build Status](https://travis-ci.org/intellinote/inote-util.svg?branch=master)](https://travis-ci.org/intellinote/inote-util) [![Dependencies](https://david-dm.org/intellinote/inote-util.svg)](https://npmjs.org/package/inote-util) [![NPM version](https://badge.fury.io/js/inote-util.svg)](http://badge.fury.io/js/inote-util)


A collection of utility functions and classes for Node.js.

## Features (incomplete)

* **LogUtil.tlog(...)** - writes to stdout (`console.log`), pre-pending a timestamp.
* **LogUtil.terr(...)** - writes to stderr (`console.error`), pre-pending a timestamp.
* **DateUtil.start_time** - timestamp at which `inote-util` was loaded (hence approximately the time the application was started in most circumstances).
* **DateUtil.duration([now = Date.now(),]since)** - returns an object that breaks-down the time between `now` and `since` in several ways (see code for details).
* **DateUtil.iso_8601_regexp()** - returns a regular expression that can be used to validate an ISO 8601 formatted date.
* **StringUtil.trim(str)** - equivalent to `String.trim()` save that `str` can be `null`.
* **StringUtil.is_blank(str)** - `true` whenever `str` is empty, composed entirely of whitespace, `null` or `undefined`.
* **StringUtil.isnt_blank(str)** - opposite of `is_blank()`
* **StringUtil.blank_to_null(str)** - given a "blank" string, returns `null`. Given an object (map), removes any *top-level* "blank" attributes.
* **StringUtil.truncate(str,width[,marker='…']** - a minimally "smart" truncation that attempts to truncate a string at a word boundaries. The specified `marker` will be added if and only if the string was actually truncated.
* **StringUtil.escape_for_json(str)** - escapes a (possibly `null`) string for use as literal characters in a JSON string.
* **StringUtil.escape_for_regexp(str)** - escapes a (possibly `null`) string for use as literal characters in a regular expression.
* **StringUtil.truthy_string(str)** - `true` if the given string is `t`, `true`, `y`, `yes`, `on`, `1`, etc.
* **StringUtil.falsey_string(str)** - `true` if the given string is `f`, `false`, `no`, `off`, `0`, etc.
* **StringUtil.lpad(value,width,pad)** - adds `pad` characters to the beginning of `value` until `value` is `width` characters long. (Also accepts arrays, see `ArrayUtil.lpad`, which is an identical method.)
* **StringUtil.rpad(value,width,pad)** - adds `pad` characters to the end of `value` until `value` is `width` characters long. (Also accepts arrays, see `ArrayUtil.rpad`, which is an identical method.)
* **ArrayUtil.lpad(value,width,pad)** - adds `pad` elements to the beginning of `value` until `value` is `width` elements long. (Also accepts strings, see `StringUtil.lpad`, which is identical.)
* **ArrayUtil.rpad(value,width,pad)** - adds `pad` elements to the end of `value` until `value` is `width` elements long. (Also accepts strings, see `StringUtil.rpad`, which is identical.)
* **ArrayUtil.smart_join(array,delim,last_delim)** - identical to `Array.join`, except the specified `last_delim` is used between the last two elements (if any). E.g., `smart_join(["Tom","Dick","Harry"],", "," and ")` yields `Tom, Dick and Harry`.
* **ArrayUtil.trim_trailing_null(array)** - returns a copy of `array` with trailing `null` elements removed
* **ArrayUtil.right_shift_args(...)** - returns an array the same length as the given arguments, but any trailing `null` values are converted to leading `null` values. (Most useful in the CoffeeScript idiom `[a,b,c,d] = right_shift_args(a,b,c,d)`.)
* **ArrayUtil.paginate_list(list[,offset=0[,limit=20]])** - returns the specified section of the given array.
* **ArrayUtil.subset_of(a,b) / ArrayUtil.is_subset_of(a,b)** - returns `true` if every element of array a is also an element of b.
* **ArrayUtil.strict_subset_of(a,b) / ArrayUtil.is_strict_subset_of(a,b)** - returns `true` if every element of array a appears exacty the same number of times in array b as it does in array a. (E.g., `['a','a','b']` is subset of but not a *strict* subset of `['a','b','c']`, according to this definition).
* **ArrayUtil.sets_are_equal(a,b)** - compares arrays as if they were sets.
* **ArrayUtil.arrays_are_equal(a,b)** - `true` if and only if array a and array b contain the exact same elements in the exact same order.
* **ArrayUtil.uniquify(array[,key])** - returns a clone of `array` with duplicate values removed. When the array contains objects (maps) and a `key` is provided, two elements will be considered duplicates if they have the same value for the attribute `key`.
* **NumberUtil.round_decimal(value[,digits=0])** - round a number to the specified number of digits to the right of the decimal point.
* **NumberUtil.is_int(val)** - returns `true` if and only if `val` is a simple integer (matching `/^-?[0-9]+$/).
* **NumberUtil.to_int(val)** - returns `parseInt(val)` when `val` is a simple integer (matching `/^-?[0-9]+$/), `null` otherwise. (Compare with the default behavior of `parseInt`, which returns `17` for `parseInt("17.93 meters")`).
* **ColorUtil.hex_to_rgb_triplet(hex)** - converts a hex-based `#rrggbb` string to decimal `[r,g,b]` values.
* **ColorUtil.hex_to_rgb_string(hex)** - converts a hex-based `#rrggbb` string to a string of the form `rgb(r,g,b)`.
* **ColorUtil.rgb_string_to_triplet(rgb)** - converts a string of the form `rgb(r,g,b)` to decimal `[r,g,b]` values.
* **ColorUtil.rgb_triplet_to_string(r,g,b)** - convert an array or sequence of r, g, b values to a string of the form `rgb(r,g,b)`.
* **RandomUtil.random_bytes([count=32[,encoding='hex']])** - returns `count` random bytes in the specified `encoding`.
* **RandomUtil.seed_rng(seed)** - returns a new `random()` function with the specified `seed` value.
* **RandomUtil.set_rn([rng = Math.random])** - sets the `random()` function used by the `RandomUtil` methods.
* **RandomUtil.random_hex([count=32[,rng]])** - returns `count` random hexadecimal digits (`[a-f0-9]`) (using the given random number generator if provided).
* **RandomUtil.random_alphanumeric([count=32[,rng]])** - returns `count` random digits from the set `[a-z0-9]` (using the given random number generator if provided).
* **RandomUtil.random_alpha([count=32[,rng]])** - returns `count` random digits from the set `[a-z]` (using the given random number generator if provided).
* **RandomUtil.random_numeric([count=32[,rng]])** - returns `count` random digits from the set `[0-9]` (using the given random number generator if provided).
* **RandomUtil.random_Alpha([count=32[,rng]])** - returns `count` random digits from the set `[a-zA-Z]` (using the given random number generator if provided).
* **RandomUtil.random_ALPHA([count=32[,rng]])** - returns `count` random digits from the set `[A-Z]` (using the given random number generator if provided).
* **RandomUtil.random_element(collection[,rng])** - returns a random element from an array, or `[key,value]` pair given a map (using the given random number generator if provided).
* **Util.slow_equals(a,b)** - constant-time comparison of two buffers for equality.
* **Util.compare(a,b)** - a minimally-smart comparision function (allows `null`, uses `localeCompare` when available, folds case so that both `A` and `a` appear before `B`, etc.).
* **Util.field_comparator(field\[,use_locale_compare=false])** - returns a comparator (`function(a,b)`) that compares two maps on the `field` attribute.
* **Util.path_comparator(path\[,use_locale_compare=false])** - like `field_comparator`, but `path` may be an array of fields that will be interpreted as nested-attributes. (E.g., `["foo","bar"]` compares `a.foo.bar` with `b.foo.bar`.)
* **Util.descending_comparator(comparator) / desc_comparator(comparator)** - reverses the order of the given `comparator`.
* **Util.composite_comparator(list)** - generates a comparator that first compares elements by `list[0]` then (if equal) `list[1]` and so on, until a non-equal comparison is found or we run out of comparators.
* **FileUtil.sanitize_filename(filename)** - removes invalid characters from and truncates extremely long filenames; only operates on the (last segement of) the given filename.
* **FileUtil.uniquify_filename(dir,basename[,ext=''[,minpadwidth=3\[,maxpadwidth=5]])** - attempts to generate a unique filename in `dir` based on `basename`.
* **FileUtil.mkdir(dir)** - `mkdir -p dir`
* **FileUtil.touch(file)** - `touch file`
* **FileUtil.rm(files...)** - remove one or more files, ignoring errors. (Returns `true` if any errors are encountered, `false` otherwise).
* **FileUtil.rmdir(dirs...)** - recursively remove one or more diretctories or files, ignoring errors. (Returns `true` if any errors are encountered, `false` otherwise).
* **FileUtil.read_stdin_sync([end_byte="\x04"\[,buffer_size=512]])** - synchronously read all of stdin (up to `end_byte`), returning the resulting buffer
* **FileUtil.load_json_file_sync(file\[,ignore_errors=false])** - synchronously read and parse a JSON file. When `ignore_errors` is true, returns `null` rather than throwing an exception when the file is not found or does not contain value JSON.
* **FileUtil.load_json_stdin_sync([end_byte="\x04"[,buffer_size=512\[,ignore_errors=false]]])** - synchronously read and parse JSON object from stdin. When `ignore_errors` is true, returns `null` rather than throwing an exception.
* **WebUtil.remote_ip(req,name,default_value)** - attempts to discover the proper "client IP" for the given request using various approaches.
* **WebUtil.param(req)** - replaces the now deprecated `req.param(name,default_value)` found in Express.js
* **Util.handle_error(err[,callback\[,throw_when_no_callback=true]])** - if `err` is not `null`, invokes `callback(err)` or `throw err` as appropriate. Returns `true` if an error was encountered, `false` otherwise. (`function my_callback(err,other,stuff) { if(!handle_error(err,callback)) { /* keep going */ } }`)
* **Util.uuid(val\[,generate=false])** - normalize `val` to all a lower-case, no-dash version of a UUID. If `generate` is `true`, generate an new UUID when given a null `val`, otherwise returns `null` in that scenario.
* **Util.pad_uuid(val\[,generate=false])** - normalize `val` to all a lower-case, with-dashes version of a UUID. If `generate` is `true`, generate an new UUID when given a null `val`, otherwise returns `null` in that scenario.
* **Util.b64e(buf\[,encoding='utf8']) / Base64.encode(buf\[,encoding='utf8'])** - Base64 encode the given buffer.
* **Util.b64d(buf\[,encoding='utf8']) / Base64.decode(buf\[,encoding='utf8'])** - Base64 *decode* the given buffer.
* **AsyncUtil.wait(delay,callback) / AsyncUtil.set_timeout(delay,callback) / AsyncUtil.setTimeout(delay,callback)** - just like `setTimeout(callback,delay)` but with a more CoffeeScript-friendly parameter order.
* **AsyncUtil.cancel_wait(id) / AsyncUtil.clear_timeout(id) / AsyncUtil.clearTimeout(id)** - alias for `window.clearTimeout(id)`.
* **AsyncUtil.interval(delay,callback) / AsyncUtil.set_intreval(delay,callback) / AsyncUtil.setInterval(delay,callback)** - just like `setInterval(callback,delay)` but with a more CoffeeScript-friendly parameter order.
* **AsyncUtil.cancel_interval(id) / AsyncUtil.cancelInterval(id) / AsyncUtil.clear_interval(id) / AsyncUtil.clearlInterval(id)** - alias for `window.clearInterval(id)`.
* **AsyncUtil.for_async(initialize,condition,action,increment,whendone)** - executes an asynchronous `for` loop. Accepts 5 function-valued parameters:
  * `initialize` - an initialization function (no arguments passed, no return value is expected);
  * `condition` - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned);
  * `action` - the action to take (a single callback function is passed and should be invoked at the end of the action, no return value is expected);
  * `increment` - called at the end of every `action`, prior to `condition` (no arguments passed, no return value is expected);
  * `whendone` - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected).
* **AsyncUtil.for_each_async(list,action,whendone)** - executes an asynchronous `forEach` loop. Accepts 3 parameters:
  * `list` - the array to iterate over;
  * `action` - a function with the signature `(value,index,list,next)` indicating the action to take for each element (*must* call `next` for processing to continue);
  * `whendone` - called at the end of the loop.
* **AsyncUtil.fork(methods, args_for_methods, callback)** - runs the given array of methods "simaltaneously" (asynchronously), invoking `callback` when they are *all* complete.
* **AsyncUtil.throttled_fork(max_parallel, methods, args_for_methods, callback)** - just like `fork`, but never running more than `max_parallel` functions at the same time.
* **AsyncUtil.procedure()** - generates a `Sequencer` object, as described below

## Installing

The source code and documentation for inote-util is available on GitHub at [intellinote/inote-util](https://github.com/intellinote/inote-util).  You can clone the repository via:

```bash
git clone git@github.com:intellinote/inote-util
```

inote-util is deployed as an [npm module](https://npmjs.org/) under the name [`inote-util`](https://npmjs.org/package/inote-util). Hence you can install a pre-packaged version with the command:

```bash
npm install inote-util
```

and you can add it to your project as a dependency by adding a line like:

```javascript
"inote-util": "latest"
```

to the `dependencies` or `devDependencies` part of your `package.json` file.

## Licensing

The inote-util library and related documentation are made available
under an [MIT License](http://opensource.org/licenses/MIT).  For details, please see the file [LICENSE.txt](LICENSE.txt) in the root directory of the repository.

## How to contribute

Your contributions, [bug reports](https://github.com/intellinote/inote-util/issues) and [pull-requests](https://github.com/intellinote/inote-util/pulls) are greatly appreciated.

We're happy to accept any help you can offer, but the following
guidelines can help streamline the process for everyone.

 * You can report any bugs at
   [github.com/intellinote/inote-util/issues](https://github.com/intellinote/inote-util/issues).

    - We'll be able to address the issue more easily if you can
      provide an demonstration of the problem you are
      encountering. The best format for this demonstration is a
      failing unit test (like those found in
      [./test/](https://github.com/intellinote/inote-util/tree/master/test)), but
      your report is welcome with or without that.

 * Our preferred channel for contributions or changes to the
   source code and documentation is as a Git "patch" or "pull-request".

    - If you've never submitted a pull-request, here's one way to go
      about it:

        1. Fork or clone the repository.
        2. Create a local branch to contain your changes (`git
           checkout -b my-new-branch`).
        3. Make your changes and commit them to your local repository.
        4. Create a pull request [as described here](
           https://help.github.com/articles/creating-a-pull-request).

    - If you'd rather use a private (or just non-GitHub) repository,
      you might find
      [these generic instructions on creating a "patch" with Git](https://ariejan.net/2009/10/26/how-to-create-and-apply-a-patch-with-git/)
      helpful.

 * If you are making changes to the code please ensure that the
   [unit test suite](./test) still passes.

 * If you are making changes to the code to address a bug or introduce
   new features, we'd *greatly* appreciate it if you can provide one
   or more [unit tests](./test) that demonstrate the bug or
   exercise the new feature.

**Please Note:** We'd rather have a contribution that doesn't follow
these guidelines than no contribution at all.  If you are confused
or put-off by any of the above, your contribution is still welcome.
Feel free to contribute or comment in whatever channel works for you.

---

[![Intellinote](https://www.intellinote.net/wp-content/themes/intellinote/images/logo@2x.png)](https://www.intellinote.net/)

## About Intellinote

Intellinote is a multi-platform (web, mobile, and tablet) software
application that helps businesses of all sizes capture, collaborate
and complete work, quickly and easily.

Users can start with capturing any type of data into a note, turn it
into a task, assign it to others, start a discussion around it, add a
file and share – with colleagues, managers, team members, customers,
suppliers, vendors and even classmates. Since all of this is done in
the context of private and public workspaces, users retain end-to-end
control, visibility and security.

For more information about Intellinote, visit
<https://www.intellinote.net/>.

### Work with Us

Interested in working for Intellinote?  Visit
[the careers section of our website](https://www.intellinote.net/careers/)
to see our latest technical (and non-technical) openings.

---
