# inote-util <!-- [![Build Status](https://travis-ci.org/intellinote/inote-util.svg?branch=master)](https://travis-ci.org/intellinote/inote-util) --> [![Dependencies](https://david-dm.org/intellinote/inote-util.svg)](https://david-dm.org/intellinote/inote-util) [![NPM version](https://badge.fury.io/js/inote-util.svg)](http://badge.fury.io/js/inote-util)

<!--
> *Regarding the "build error" badge above: For some reason [travis-ci](https://travis-ci.org/intellinote/inote-util) is having problems installing (compiling) [mmmagic](https://github.com/mscdex/mmmagic) on some (but not all) versions of Node. As far as we can tell this is a Travis-specific issue.  We regularly compile and run the mmmagic package on those versions of Node on both OSX and Linux without any problem.*
>
> *Any suggestions about how to make Travis successfully build mmmagic on under all node.js versions are welcome.*
--!>

A collection of utility functions and classes for Node.js.

### Contents

 * [Features](#features) - method-by-method description of the utilities.
 * [Installing](#installing) - how to install from npm or source.
 * [Licensing](#licensing) - `inote-util` is made available under an MIT License.
 * [How to Contribute](#how-to-contribute) - tips on reporting issues, creating pull-requests for or just generally hacking `inote-util`.
 * [About Intellinote](#about-intellinote) - a little background on [Intellinote](https://www.intellinote.net/), a collaboration platform for teams.

## Using

`note-util` exports a number of objects, each containing several utility functions.

Hence, `require(‘note-util’)` will return a map with several sub-objects (`ArrayUtil`, `AsyncUtil`, etc.)

There are two common idioms for handling this.

**Idiom 1:** Keep a handle to this “parent” object:

```js
var IU = require(“note-util”);

IU.LogUtil.tlog(“Here is a random string:”, IU.RandomUtil.random_alphanumeric());
```


**Idiom 2:** Keep a handle to the individual utilities:

```js
var LogUtil = require(“note-util”).LogUtil;
var RandomUtil = require(“note-util”).RandomUtil;

LogUtil.tlog(“Here is a random string:”, RandomUtil.random_alphanumeric());
```

Personally, the author prefers the second approach, but the difference is almost entirely cosmetic. In particular, note that in Node.js `require`-ing the same module multiple times DOES NOT reload or reparse the files in the module.  The file is only load once.

The following section lists methods under the associated object.  E.g., under `NetUtil` you’ll find `get_unused_port()`.  This means that the `get_unused_port` method is exported within the top-level object named “NetUtil” and could be accessed via:

```js
var gup = require(“note-util”).NetUtil.get_unused_port;
```

## Features

### Feature Index

[ArrayUtil](#arerayutil) |
[AsyncUtil](#asyncutil) |
[ColorUtil](#colorutil) |
[Config](#config) |
[DateUtil](#dateutil) |
[FileUtil](#fileutil) |
[FileUtil MIME](#fileutil---mime-and-file-extension-related) |
[IOUtil](#ioutil) |
[LogUtil](#logutil) |
[NetUtil](#netutil) |
[NumberUtil](#numberutil) |
[ObjectUtil](#objectutil) |
[RandomUtil](#randomutil) |
[Stopwatch](#stopwatch) |
[StringUtil](#stringutil) |
[Util](#util) |
[WebUtil](#webutil) |
[WorkQueue](#workqueue) |
[ZipUtil](#ziputil)

### ArrayUtil
* **lpad(value,width,pad)** - adds `pad` elements to the beginning of `value` until `value` is `width` elements long. (Also accepts strings, see `StringUtil.lpad`, which is identical.)
* **rpad(value,width,pad)** - adds `pad` elements to the end of `value` until `value` is `width` elements long. (Also accepts strings, see `StringUtil.rpad`, which is identical.)
* **smart_join(array,delim,last_delim)** - identical to `Array.join`, except the specified `last_delim` is used between the last two elements (if any). E.g., `smart_join(["Tom","Dick","Harry"],", "," and ")` yields `Tom, Dick and Harry`.
* **trim_trailing_null(array)** - returns a copy of `array` with trailing `null` elements removed
* **right_shift_args(...)** - returns an array the same length as the given arguments, but any trailing `null` values are converted to leading `null` values. (Most useful in the CoffeeScript idiom `[a,b,c,d] = right_shift_args(a,b,c,d)`.)
* **paginate_list(list[,offset=0[,limit=20]])** - returns the specified section of the given array.
* **subset_of(a,b) / ArrayUtil.is_subset_of(a,b)** - returns `true` if every element of array a is also an element of b.
* **strict_subset_of(a,b) / ArrayUtil.is_strict_subset_of(a,b)** - returns `true` if every element of array a appears exacty the same number of times in array b as it does in array a. (E.g., `['a','a','b']` is subset of but not a *strict* subset of `['a','b','c']`, according to this definition).
* **sets_are_equal(a,b)** - compares arrays as if they were sets.
* **arrays_are_equal(a,b)** - `true` if and only if array a and array b contain the exact same elements in the exact same order.
* **uniquify(array[,key])** - returns a clone of `array` with duplicate values removed. When the array contains objects (maps) and a `key` is provided, two elements will be considered duplicates if they have the same value for the attribute `key`.

*[Back to Index](#feature-index)*

### AsyncUtil
* **wait_until(predicate\[,interval],callback)** / **wait_for(predicate\[,interval],callback)** - polls `predicate()` every `interval` milliseconds until it returns `true` (or throws an exception). Callback signature is `(err,complete)` where `complete` is `true` if and only if `predicate()` returned `true`. `interval` defaults to `100`.
* **wait(delay,callback)** / **set_timeout(delay,callback)** / **setTimeout(delay,callback)** - just like `setTimeout(callback,delay)` but with a more CoffeeScript-friendly parameter order.
* **cancel_wait(id)** / **clear_timeout(id)** / **clearTimeout(id)** - alias for `window.clearTimeout(id)`.
* **interval(delay,callback)** / **set_interval(delay,callback)** / **setInterval(delay,callback)** - just like `setInterval(callback,delay)` but with a more CoffeeScript-friendly parameter order.
* **cancel_interval(id)** / **cancelInterval(id)** / **clear_interval(id)** / **clearlInterval(id)** - alias for `window.clearInterval(id)`.
* **for_async(initialize,condition,action,increment,whendone)** - executes an asynchronous `for` loop. Accepts 5 function-valued parameters:
  * `initialize` - an initialization function (no arguments passed, no return value is expected);
  * `condition` - a predicate that indicates whether we should continue looping (no arguments passed, a boolean value is expected to be returned);
  * `action` - the action to take (a single callback function is passed and should be invoked at the end of the action, no return value is expected);
  * `increment` - called at the end of every `action`, prior to `condition` (no arguments passed, no return value is expected);
  * `whendone` - called at the end of the loop (when `condition` returns `false`), (no arguments passed, no return value is expected).
* **for_each_async(list,action,whendone)** - executes an asynchronous `forEach` loop. Accepts 3 parameters:
  * `list` - the array to iterate over;
  * `action` - a function with the signature `(value,index,list,next)` indicating the action to take for each element (*must* call `next` for processing to continue);
  * `whendone` - called at the end of the loop.
* **fork(methods, args_for_methods, callback)** - runs the given array of methods "simaltaneously" (asynchronously), invoking `callback` when they are *all* complete.
* **throttled_fork(max_parallel, methods, args_for_methods, callback)** - just like `fork`, but never running more than `max_parallel` functions at the same time.
* **procedure()** - generates a `Sequencer` object, as described below

#### The Sequencer

The methods `Util.procedure()`, `AsyncUtil.procedure()`, and `new Sequencer()` will create a new "sequencer" object that provides a simple way to "flatten" long chains of nested asynchronous methods.

For example, rather than writing:

```javascript
method_one( function(e,a,b) {
  method_two(a, b, function() {
    method_three( function(e,c,d) {
      and_so_on();
    });
  });
});
```

We can flatten the calls out like this:

```javascript
var procedure = AsyncUtil.procedure();
procedure.first( method_one );
procedure.then( method_two );
procedure.then( method_three );
procedure.then( and_so_on );
procedure.run();
```

Each call to `then` appends the given callback method to the chain.

Each callback method is passed a `next_step` function that *must* be called to trigger the next step in the processing.

Note that any arguments passed to `next_step()` will be passed to the next method in the sequence (with the `next` function appended). For example, given a method in the sequence such as:

```javascript
procedure.next(function(next_step) {
  next_step(1,"A",[]);
});
```
The following method in the procedure will be invoked with the following signature:

```javascript
the_next_method_in_the_sequence(1,"A",[],next_step);
```

Hence the typical use of the class looks something like this:

```javascript
var s = new Sequencer()
s.first( function(done) {
  // do something, then invoke the callback
  done();
});

s.next( function(done) {
  // do something, then invoke the callback
  done();
});
s.next( function(done) {
  // do something, then invoke the callback
  done();
});

s.run();
```

When `run` is invoked, each asynchronous  method is executed in sequence.

The `first` method is optional (you can just use `next` instead), but when invoked `first` will remove any methods previously added to the chain.

You `last` methods is an optional short-hand for adding one final method to the chain and then running it.  E.g., the last two lines of our example:

```javascript
procedure.then( and_so_on )
procedure.run()
```

Could be re-written:

```javascript
procedure.last( and_so_on )
```

Note that the sequence is not cleared when `run` is invoked, so one may invoke `run` more than once to execute the sequence again.

*[Back to Index](#feature-index)*

### ColorUtil
* **hex_to_rgb_triplet(hex)** - converts a hex-based `#rrggbb` string to decimal `[r,g,b]` values.
* **hex_to_rgb_string(hex)** - converts a hex-based `#rrggbb` string to a string of the form `rgb(r,g,b)`.
* **rgb_string_to_triplet(rgb)** - converts a string of the form `rgb(r,g,b)` to decimal `[r,g,b]` values.
* **rgb_triplet_to_string(r,g,b)** - convert an array or sequence of r, g, b values to a string of the form `rgb(r,g,b)`.

*[Back to Index](#feature-index)*

### Config
A thin wrapper around [`nconf`](https://github.com/flatiron/nconf) providing a consistent way to load configuration data from files or the environment.

#### Example of use

```javascript
var config = require('inote-util').config.init();
var prop = config.get('my:property');
```

`Config` will load the configuration from several sources.

In order of precedence:

1. "Override" values passed to the `init` function.

2. Command line parameters (`--name value`).

3. A JSON-format configuration file (from a location deterimined by
  `NODE_ENV`, `config_dir` or `config_file`).

4. Environment variables.

5. A "default" JSON-format configuration file at `${config_dir}/config.json`.

6. "Default" values passed to the `init` function.

To discover a configuration file (as used in step 3 above), `Config` will:

  1. Look for `NODE_ENV`, `config_dir` or `config_file` environment variables.

  2. If `config_dir` is set, the value will be used as the "parent" directory
  of the configuration files.  (If `config_dir` is not set, it defaults to
  the directory `config` within the working directory from which the current
  Node.js process was launched.)

  3. If `NODE_ENV` is set and a file named `${NODE_ENV}.json` exists within
  the `config_dir`, that file will be used.

  4. If `config_file` is set, that file will be used.

*[Back to Index](#feature-index)*

### DateUtil
* **start_time** - timestamp at which `inote-util` was loaded (hence approximately the time the application was started in most circumstances).
* **duration(end_time,begin_time)** - returns an object that breaks-down the time between `begin_time` and `end_time` in several ways (as described below).  When missing, `end_time` defaults to `Date.now()` and `begin_time` defaults to `start_time`.
* **iso_8601_regexp()** - returns a regular expression that can be used to validate an ISO 8601 formatted date.

Here is an example of the object returned by the `DateUtil.duration`, with brief annotations.

```js
{
  "begin":1462806430444,
  "end":1462851730757,
  "delta":45300313,
  "in_millis":{                     // MILLISECOND VALUE OF EACH "PART" OF THE DURATION
    "millis":313,                   // <= delta % (1000)
    "seconds":313,                // <= delta % (1000 * 60)
    "minutes":2100313,              // <= delta % (1000 * 60 * 60)
    "hours":45300313,               // <= delta % (1000 * 60 * 60 * 24)
    "days":45300313,                // <= delta % (1000 * 60 * 60 * 24 * 7
    "weeks":45300313,               // <= delta % (1000 * 60 * 60 * 24 * 7 * 52
    "years":45300313                // <= delta
  },
  "raw":{                           // ELEMENTS FROM `IN_MILLIS`, CONVERTED TO RELEVANT UNIT
    "millis":313,                   // <= in_millis.millis
    "seconds":0.313,                // <= in_millis.seconds / (1000)
    "minutes":35.00521666666667,    // <= in_millis.minutes / (1000 * 60)
    "hours":12.583420277777778,     // <= in_millis.hours   / (1000 * 60 * 60)
    "days":0.5243091782407407,      // <= in_millis.days    / (1000 * 60 * 60 * 24)
    "weeks":0.07490131117724867,    // <= in_millis.weeks   / (1000 * 60 * 60 * 24 * 7)
    "years":0.00020520907171848953   // <= in_millis.years   / (1000 * 60 * 60 * 24 * 7 * 365)
  },
  "whole":{                         // RAW VALUES ROUNDED DOWN TO NEAREST INTEGER
    "millis":313,
    "seconds":0,
    "minutes":35,
    "hours":12,
    "days":0,
    "weeks":0,
    "years":0
  },
  "array":{                         // SET OF DURATION ELEMENTS IN ARRAYS
    "full":{                        // FULL = ALL UNITS, EVEN WHEN 0
      "values":[0,0,0,12,35,0,313],
      "short":["0y","0w","0d","12h","35m","0s","313m"],
      "long":["0 years","0 weeks","0 days","12 hours","35 minutes","0 seconds","313 milliseconds"],
      "no_millis":{                 // SAME AS PARENT BUT IGNORING MILLISECONDS
        "values":[0,0,0,12,35,0],
        "short":["0y","0w","0d","12h","35m","0s"],
        "long":["0 years","0 weeks","0 days","12 hours","35 minutes","0 seconds"]
      }
    },
    "brief":{                       // BRIEF = SKIP TO LARGEST NON-ZERO UNIT, THEN INCLUDE ALL
      "values":[12,35,0,313],
      "short":["12h","35m","0s","313m"],
      "long":["12 hours","35 minutes","0 seconds","313 millis"],
      "no_millis":{
        "values":[12,35,0],
        "short":["12h","35m","0s"],
        "long":["12 hours","35 minutes","0 seconds"]
      }
    },
    "min":{                        // MIN = ONLY THE NON-ZERO VALUES

      "units":["hour","minute","millisecond"],
      "short":["12h","35m","313m"],
      "long":["12 hours","35 minutes","313 milliseconds"],
      "no_millis":{
        "units":["hour","minute"],
        "short":["12h","35m"],
        "long":["12 hours","35 minutes"]
      }
    }
  },
  "string":{                       // SIMILAR TO "ARRAY" BUT WITH STRINGS
    "full":{
      "micro":"0y0w0d12h35m0s313m",
      "short":"0y 0w 0d 12h 35m 0s 313m",
      "long":"0 years 0 weeks 0 days 12 hours 35 minutes 0 seconds 313 milliseconds",
      "verbose":"0 years, 0 weeks, 0 days, 12 hours, 35 minutes, 0 seconds and 313 milliseconds",
      "no_millis":{
        "micro":"0y0w0d12h35m0s",
        "short":"0y 0w 0d 12h 35m 0s",
        "long":"0 years 0 weeks 0 days 12 hours 35 minutes 0 seconds",
        "verbose":"0 years, 0 weeks, 0 days, 12 hours, 35 minutes and 0 seconds"
      }
    },
    "brief":{
      "micro":"12h35m0s313m",
      "short":"12h 35m 0s 313m",
      "long":"12 hours 35 minutes 0 seconds 313 millis",
      "verbose":"12 hours, 35 minutes, 0 seconds and 313 millis",
      "no_millis":{
        "micro":"12h35m0s",
        "short":"12h 35m 0s",
        "long":"12 hours 35 minutes 0 seconds",
        "verbose":"12 hours, 35 minutes and 0 seconds"
      }
    },
    "min":{
      "micro":"12h35m313m",
      "short":"12h 35m 313m",
      "long":"12 hours 35 minutes 313 milliseconds",
      "verbose":"12 hours, 35 minutes and 313 milliseconds",
      "no_millis":{
        "micro":"12h35m",
        "short":"12h 35m",
        "long":"12 hours 35 minutes",
        "verbose":"12 hours, 35 minutes and 48 seconds"
      }
    }
  }
}
```

*[Back to Index](#feature-index)*

### FileUtil
* **file_age(file,callback)** / **file_age_sync(file)** - obtain the age of a file  (time since last modfied) in milliseconds
* **file_mtime(file,callback)** / **file_mtime_sync(file)**- obtain the Unix epoch timestamp at which a file was last modified
* **ls(dir\[,options\],callback)** - list the files in a directory; options:
  * `recurse` - when `true`, perform the operation recursively
  * `pattern` - when a non-`null` RegExp, only list files matching the specified pattern
  * `types` - an array or string containing `file` or `directory`
* **is_dir(filename,callback)**   - test if the specified filename is a directory
* **is_file(filename,callback)** - test if the specified filename is a plain file (not a directory).
* **sanitize_filename(filename)** - removes invalid characters from and truncates extremely long filenames; only operates on the last segement of the given path. That is, if `filename` is `/foo/bar/xyz`, only the `xyz` part of the string will be modified.
* **uniquify_filename(dir,basename[,ext=''[,minpadwidth=3\[,maxpadwidth=5]])** - attempts to generate a unique filename in `dir` based on `basename`.
* **mkdir(dir)** - `mkdir -p dir`
* **touch(file)** - `touch file`
* **rm(files...)** - remove one or more files, ignoring errors. (Returns `true` if any errors are encountered, `false` otherwise).
* **rmdir(dirs...)** - recursively remove one or more directories or files, ignoring errors. (Returns `true` if any errors are encountered, `false` otherwise).
* **read_stdin_sync([end_byte="\x04"\[,buffer_size=512]])** - synchronously read all of stdin (up to `end_byte`), returning the resulting buffer
* **load_json_file_sync(file\[,ignore_errors=false])** - synchronously read and parse a JSON file. When `ignore_errors` is true, returns `null` rather than throwing an exception when the file is not found or does not contain value JSON.
* **load_json_stdin_sync([end_byte="\x04"[,buffer_size=512\[,ignore_errors=false]]])** - synchronously read and parse JSON object from stdin. When `ignore_errors` is true, returns `null` rather than throwing an exception.
* **copy_file(src,dest,callback)** - copy a file from `src` to `dest`; works across filesystems.
* **move_file(src,dest,callback)** - move (rename) a file from `src` to `dest`; works across filesystems.

*[Back to Index](#feature-index)*

### FileUtil - MIME and File-Extension related

* **get_ext(fname)**  / **get_extension(fname)** - equivalent to `path.extname`, save that `fname` can be the extension itself.  (E.g., both `path.extname('.foo')` and `path.extname('foo')` return `''` while `FileUtil.get_ext('.foo')` and `FileUtil.get_ext('foo')` return `'foo'`).  Specifically, returns the part of `fname` following the final dot (`.`), _unless_ `fname` contains *no* dot, in which case the entire `fname` value is returned.
* **strip_ext(fname)**  / **strip_extension(fname)** - returns a version of `fname` with the file extension removed.
* **replace_ext(fname,ext)**  / **replace_extension(fname,ext)** - returns a version of `fname` with the file extension changed to `ext`.
* **get_mime_for_ext(ext)** / **get_mime_for_extension(ext)**  - returns the "standard" MIME type based on the extension found in `ext`.  (`ext` may be a full filename or just the extension).
* **get_ext_for_mime(mime)** / **get_extension_for_mime(mime)**  - returns the "standard" file extension for the given MIME type.
* **get_mime_via_magic(file,callback)** / **get_mime_type_via_magic(file,callback)** / **get_file_mime_type_via_magic(file,callback)** - determines MIME type of `file` by magic number (ignoring the file extension if any).
* **get_mime(file,callback)** / **get_mime_type(file,callback)** / **get_file_mime_type(file,callback)** - determines MIME type of `file` by magic number or extension. Given a choice, the specific type is selected (e.g., `application/json` vs. `text/plain`).  The magic-number-based MIME type is used if the two MIME types seem equally specific.
* **file_is_mime(file,pattern,callback)** - calls-back with `null, true` when the MIME type of `file` matches `pattern.`
* **file_is_pdf(file,callback)** - calls-back with `null, true` when the MIME type of `file` is `application/pdf`.
* **get_mime_to_ext_map()** / **get_mime_to_extension_map()** - returns the MIME-type to "standard" file-extension mapping used for the other methods.
* **get_ext_to_mime_map()** / **get_extension_to_mime_map()** - returns the file-extension to "standard" MIME-type mapping used for the other methods.
* **set_mime_to_ext_map(map)** / **set_mime_to_extension_map(map)** - sets the MIME-type to "standard" file-extension mapping used for the other methods. Extensions should NOT contain a leading dot (`.`). Set to `null` to restore the default mapping.
* **set_ext_to_mime_map(map)** / **set_extension_to_mime_map(map)** - sets the file-extension to "standard" MIME-type mapping used for the other methods. Extensions should NOT contain a leading dot (`.`). Set to `null` to restore the default mapping.
* **add_to_mime_to_ext_map(map | mime, ext)** / **add_to_mime_to_ext_map(map | mime, ext)** - adds a collection or a single instance of a mime-to-file-extension mapping to the currently active set.
* **add_to_ext_to_mime_map(map | ext, mime)** / **add_to_extension_to_mime_map(map | ext, mime)** - adds a collection or a single instance of a file-extension-to-mime-type mapping to the currently active set.

Note that it is not necessarily the case that `get_ext_for_mime(get_mime_for_ext( EXT )) == EXT` and vice-versa.  See the `data` directory for the default mappings.

*[Back to Index](#feature-index)*

### IOUtil
* **pipe_to_file(readable_stream,dest,options,callback)** - write a stream to a file. (`callback(err,file)`).
* **pipe_to_buffer(readable_stream,callback)** - write a stream to a buffer. (`callback(err,buffer)`).
* **download_to_file(url,dest,options,callback)** - write the contents of a URL to a file. (`callback(err,file)`).
* **download_to_buffer(url,callback)** - write the contents of a URL to a buffer.  (`callback(err,buffer)`).
* **download_to_data_uri(url,callback)** - convert the contents of a URL to a data-uri. (`callback(err,uri)`).

*[Back to Index](#feature-index)*

### LogUtil
* **tlog(...)** - writes to stdout (`console.log`), pre-pending a timestamp (E.g., `[2015-05-17T22:03:58.569Z] Hello World!`)
* **terr(...)** - writes to stderr (`console.error`), pre-pending a timestamp.  (E.g., `[2015-05-17T22:03:58.569Z] Hello World!`)
* **tplog(...)** - writes to stdout (`console.log`), pre-pending a timestamp and process ID (E.g., `[2015-05-17T22:03:58.569Z] [p:123] Hello World!`)
* **tperr(...)** - writes to stderr (`console.error`), pre-pending a timestamp and process ID.  (E.g., `[2015-05-17T22:03:58.569Z] [p:123] Hello World!`)

*[Back to Index](#feature-index)*

### NetUtil
* **is_port_in_use(port,callback)** - attempt to determine whether or not a port is currently in use
* **get_unused_port(callback)** - attempt to obtain an unused port

*[Back to Index](#feature-index)*

### NumberUtil
* **round_decimal(value[,digits=0])** - round a number to the specified number of digits to the right of the decimal point.
* **is_int(val)** - returns `true` if and only if `val` is a simple integer (matching `/^-?((0)|([1-9][0-9]*))$/`).
* **to_int(val)** - returns `parseInt(val)` when `val` is a simple integer (matching `is_int`), `null` otherwise. (Compare with the default behavior of `parseInt`, which returns `17` for `parseInt("17.93 meters")`).
* **is_float(val)** - returns `true` if and only if `val` is a simple decimal value (matching `/^-?((((0)|([1-9][0-9]*))(\.[0-9]+)?)|(\.[0-9]+))$/`).
* **to_float(val)** - returns `parseFloat(val)` when `val` is a simple decimal value (matching `is_float`), `null` otherwise.

*[Back to Index](#feature-index)*

### ObjectUtil
* **remove_null(map)** - generates a (shallow) *clone* of the map, with `null` entries removed.
* **remove_falsey(map)** - generates a (shallow) *clone* of the map, with "falsey" entries removed (see `falsey_string`).
* **merge(maps...)** - given two or more maps `a` and `b`, creates new new map containing the union of elements from each. If `a` and `b` share a key, the value in `b` will overwrite the value in `a`.
* **shallow_clone(obj)** - create a shallow clone of the given map or array.
* **deep_clone(obj)** - recursively copy the elements `obj` into a new map (or array)
* **object_array_to_map(array,key_field[,options={})])** - Given a list of objects, creates a map from `elt[key_field]` to `elt` for each `elt` in the array.
  * `options.transform` - an optional function used to transform the value of `elt[key_field]` before using it as the map key.
  * `options.duplicates` - a string indicating how to handle duplicate keys:
    * `"overwrite"` - replace the old value with the new value (the default)
    * `"stack"` - create an array containing both values (in sequence)
    * `"merge"` - merge the objects using `Util.merge(old,new)`
    * `"skip"` - keep the old value and ignore the new one

*[Back to Index](#feature-index)*

### RandomUtil
* **random_bytes([count=32[,encoding='hex']])** - returns `count` random bytes in the specified `encoding`.
* **seed_rng(seed)** - returns a new `random()` function with the specified `seed` value.
* **set_rn([rng = Math.random])** - sets the `random()` function used by the `RandomUtil` methods.
* **random_hex([count=32[,rng]])** - returns `count` random hexadecimal digits (`[a-f0-9]`) (using the given random number generator if provided).
* **random_alphanumeric([count=32[,rng]])** - returns `count` random digits from the set `[a-z0-9]` (using the given random number generator if provided).
* **random_alpha([count=32[,rng]])** - returns `count` random digits from the set `[a-z]` (using the given random number generator if provided).
* **random_numeric([count=32[,rng]])** - returns `count` random digits from the set `[0-9]` (using the given random number generator if provided).
* **random_Alpha([count=32[,rng]])** - returns `count` random digits from the set `[a-zA-Z]` (using the given random number generator if provided).
* **random_ALPHA([count=32[,rng]])** - returns `count` random digits from the set `[A-Z]` (using the given random number generator if provided).
* **random_element(collection[,rng])** - returns a random element from an array, or `[key,value]` pair given a map (using the given random number generator if provided).

*[Back to Index](#feature-index)*

### Stopwatch
A simple utility that can be used to track and report the time it takes to do some thing in your JavaScript code.

#### Basic Use

```javascript
var SW = require('inote-util').Stopwatch;
var timer = SW.start();
// ...do something...
timer.stop();
console.log("Start Time:  ",timer.start_time);
console.log("Finish Time: ",timer.finish_time);
console.log("Elapsed Time:",timer.elapsed_time);
```

#### Wrapped (Synchronous)

```javascript
timer = SW.time( some_method );
console.log("some_method took",timer.elapsed_time,"millis to complete.");
```

#### "Cookies"

The `start` and `time` methods accept an optional map of attributes that will be bundled with the returned timer.  For example:

```javascript
timer = SW.start({label:"foo"});
// ...do something...
timer.stop();
console.log(timer.label," Start Time:  ",timer.start_time);
console.log(timer.label,"Finish Time: ",timer.finish_time);
console.log(timer.label,"Elapsed Time:",timer.elapsed_time);
```

*[Back to Index](#index)*

### StringUtil
* **trim(str)** - equivalent to `String.trim()` save that `str` can be `null`.
* **is_blank(str)** - `true` whenever `str` is empty, composed entirely of whitespace, `null` or `undefined`.
* **isnt_blank(str)** - opposite of `is_blank()`
* **blank_to_null(str)** - given a "blank" string, returns `null`. Given an object (map), removes any *top-level* "blank" attributes.
* **truncate(str,width[,marker='…'])** - a minimally "smart" truncation that attempts to truncate a string at a word boundaries. The specified `marker` will be added if and only if the string was actually truncated.
* **escape_for_json(str)** - escapes a (possibly `null`) string for use as literal characters in a JSON string.
* **escape_for_regexp(str)** - escapes a (possibly `null`) string for use as literal characters in a regular expression.
* **escape_for_bash(param,esc_specials=false)** - escapes a (possibly `null`) string for use as command-line parameter. When `esc_specials` is `false` (the default) parameters such as `<`, `>`, `&&`, etc. are not escaped.
* **truthy_string(str)** - `true` if the given string is `t`, `true`, `y`, `yes`, `on`, `1`, etc.
* **falsey_string(str)** - `true` if the given string is `f`, `false`, `no`, `off`, `0`, etc.
* **lpad(value,width,pad)** - adds `pad` characters to the beginning of `value` until `value` is `width` characters long. (Also accepts arrays, see `ArrayUtil.lpad`, which is an identical method.)
* **rpad(value,width,pad)** - adds `pad` characters to the end of `value` until `value` is `width` characters long. (Also accepts arrays, see `ArrayUtil.rpad`, which is an identical method.)

*[Back to Index](#feature-index)*

### Util
* **version_satisfies(\[version_string,\]range_string)** - returns `true` if the given `version_string` satisfies the [semver criteria](https://www.npmjs.com/package/semver) specified in `range_string`.  When `version_string` is omitted, the Node version (the value of `process.version`) is used.  E.g., `if(!Util.version_satisifes(">=0.12.3")) { console.error("Expected version 0.12.3 or later."); }`.
* **slow_equals(a,b)** - constant-time comparison of two buffers for equality.
* **compare(a,b)** - a minimally-smart comparision function (allows `null`, uses `localeCompare` when available, folds case so that both `A` and `a` appear before `B`, etc.).
* **field_comparator(field\[,use_locale_compare=false])** - returns a comparator (`function(a,b)`) that compares two maps on the `field` attribute.
* **path_comparator(path\[,use_locale_compare=false])** - like `field_comparator`, but `path` may be an array of fields that will be interpreted as nested-attributes. (E.g., `["foo","bar"]` compares `a.foo.bar` with `b.foo.bar`.)
* **descending_comparator(comparator) / desc_comparator(comparator)** - reverses the order of the given `comparator`.
* **composite_comparator(list)** - generates a comparator that first compares elements by `list[0]` then (if equal) `list[1]` and so on, until a non-equal comparison is found or we run out of comparators.
* **handle_error(err[,callback\[,throw_when_no_callback=true]])** - if `err` is not `null`, invokes `callback(err)` or `throw err` as appropriate. Returns `true` if an error was encountered, `false` otherwise. (`function my_callback(err,other,stuff) { if(!handle_error(err,callback)) { /* keep going */ } }`)
* **uuid(val\[,generate=false])** - normalize `val` to all a lower-case, no-dash version of a UUID. If `generate` is `true`, generate an new UUID when given a null `val`, otherwise returns `null` in that scenario.
* **pad_uuid(val\[,generate=false])** - normalize `val` to all a lower-case, with-dashes version of a UUID. If `generate` is `true`, generate an new UUID when given a null `val`, otherwise returns `null` in that scenario.
* **b64e(buf\[,encoding='utf8']) / Base64.encode(buf\[,encoding='utf8'])** - Base64 encode the given buffer.
* **b64d(buf\[,encoding='utf8']) / Base64.decode(buf\[,encoding='utf8'])** - Base64 *decode* the given buffer.


*[Back to Index](#feature-index)*

### WebUtil
* **remote_ip(req,name,default_value)** - attempts to discover the proper "client IP" for the given request using various approaches.
* **param(req)** - replaces the now deprecated `req.param(name,default_value)` found in Express.js

*[Back to Index](#feature-index)*

### WorkQueue

`WorkQueue` implements a basic priority queue for asynchronous tasks.

Users may add "tasks" to the work queue, which will be asynchronously executed according to priority order.

Each task consists of:

 * a function
 * optionally, an array of arguments to the function
 * optionally, a priority for the task
 * optionally, a callback function to invoke when the task is complete

The final parameter to the task-function will *always* be the WorkQueue's `done` function.  Users **must** call this function to indicate that the task is complete (or, optionally throw an exception).

Any arguments passed to the `done` function will in turn be passed to the callback function registered with the task (if any).

#### Example

```javascript
var WorkQueue = require("inote-util").WorkQueue;
var wq = new WorkQueue();

// A task
function taskOne(a,b,cb) {
  console.log("taskOne is executing. a=",a,"b=",b);
  cb(1,false,a);
}
var argsOne = [ "A", "B" ];

// Another task
function taskTwo(cb) {
  console.log("taskTwo is executing.");
  cb(2,true,null);
}

// A callback that will be invoked after each task
function afterTask(num, exit, a) {
  console.log("Task number",num,"is completed. a=",a);
  if (exit) {
    wq.stop_working();
  }
}

wq.enqueue_task(taskOne, argsOne, afterTask);
wq.enqueue_task(taskTwo, afterTask);

wq.start_working();
```

When run, that script generates the following output:

```
taskOne is executing. a= A b= B
Task number 1 is completed. a= A
taskTwo is executing.
Task number 2 is completed. a= null
```

#### Events

The WorkQueue is also an `EventEmitter`, with the following events:

 * **work-beginning** - called when the queue starts processing. Arguments: the WorkQueue instance.

 * **task-enqueued** - called when a task is added to the queue. Arguments: the WorkQueue instance and the task (`{priority,method,args,callback}`).

 * **task-dequeued** - called when a task is selected for processing. Arguments: the WorkQueue instance and the task (`{priority,method,args,callback}`).

 * **task-completed** - called when a task is done (and didn't throw an uncaught exception.) Arguments: the WorkQueue instance, the task and an array of arguments passed to the `done` function..

 * **error** - called when an uncaught exception is encountered while processing the task. Arguments: the WorkQueue instance, the task and the error.

 * **busy** - called when a task is deferred because the maximum number of tasks are currently active. Arguments: the WorkQueue instance.

 * **work-ending** - called when the queue stops processing.  Arguments: the WorkQueue instance.

#### Methods

* **new WorkQueue(\[options\])** - create a new WorkQueue instance.  Options:
  * `priority` - the default priority for tasks in the queue (when none is specified when the task is added). Defaults to 5.  Larger numbers are executed before smaller numbers.
  * `interval` - the time (in milliseconds) between "polling" the queue for new tasks to execute.  Defaults to `200`.
  * `fuzz` - a floating point value that will be used to "fuzz" the interval between polling runs.  When `fuzz` is a non-zero float, a random value between `-1 × fuzz × interval` and `fuzz × interval` will be added to the interval.  This is used to avoid synchronization when several WorkQueues are launched with the same configuration.  (E.g., when a node app that uses the WorkQueue is launched in a cluster.)  Defaults to `0.1`.
  * `workers` - the maximum number of tasks that can be active at one time.  Defaults to `1`.

* **pending_task_count()** - returns the number of tasks in the queue waiting to be executed.

* **active_task_count()** - returns the number of tasks from the queue currently being executed.

* **enqueue_task:(method\[,args\]\[,priority\]\[,callback\])** - add a task the the queue.

* **start_working(\[options\])** - start queue processing.  The `options` parameter may contain `interval` or `fuzz` attributes, which will override those provided in the construction for the duration of this processing.

* **stop_working()** - stop queue processing.  Note that if a queue is started but not stopped, a function will be called roughly every `interval` milliseconds via JavaScript's `setInterval` method.

*[Back to Index](#feature-index)*

### ZipUtil
* **zip(\[wd\],zipfile,inputs,callback)** - creates (or appends to) `zipfile`, adding the file or array of files in `inputs`.  When `wd` is specified the action will take place relative to that directory.
* **unzip(\[wd\],zipfile,dest,callback)** - unzips `zipfile` into the specified `dest`.
* **contents(zipfile,callback)** - obtains a list of files within `zipfile`.

*[Back to Index](#feature-index)*

*[Up to ToC](#contents)*


## Installing

### From Source

The source code and documentation for inote-util is available on GitHub at [intellinote/inote-util](https://github.com/intellinote/inote-util).  You can clone the repository via:

```bash
git clone git@github.com:intellinote/inote-util
```

Assuming you have node installed, you can then install the remaining dependencies by running `npm install` from the root repository directory.

A `Makefile` is provided.  Run `make install` to install. Run `make test` to run the unit test suite.  Run `make help` for a list of other useful Make targets.

### From npm

inote-util is deployed as an [npm module](https://npmjs.org/) under the name [`inote-util`](https://npmjs.org/package/inote-util). Hence you can install a pre-packaged version with the command:

```bash
npm install inote-util
```

and you can add it to your project as a dependency by adding a line like:

```javascript
"inote-util": "latest"
```

to the `dependencies` or `devDependencies` part of your `package.json` file.

*[Up to ToC](#contents)*

## Licensing

The inote-util library and related documentation are made available
under an [MIT License](http://opensource.org/licenses/MIT).  For details, please see the file [LICENSE.txt](LICENSE.txt) in the root directory of the repository.

*[Up to ToC](#contents)*

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

 * This repository follows the ["git flow"](http://nvie.com/posts/a-successful-git-branching-model/) branching convention.  The `master` branch contains snapshots of each stable release.  New development occurs within the `develop` branch.  We'd prefer most pull-requests to be based off the `develop` branch.

**Please Note:** We'd rather have a contribution that doesn't follow
these guidelines than no contribution at all.  If you are confused
or put-off by any of the above, your contribution is still welcome.
Feel free to contribute or comment in whatever channel works for you.

*[Up to ToC](#contents)*

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

*[Up to ToC](#contents)*
