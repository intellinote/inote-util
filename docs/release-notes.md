# inote-util Release Notes

This file summarizes the changes bundled in each release of `inote-util`.

<!-- toc -->

## Release 0.6.0 - 21 April 2015

### Enhancements

 * Added `ObjectUtil.deep_clone`.
 * `ObjectUtil.shallow_clone` has been extended to clone `Array`s and to handle `String`, `Number` and `Boolean` types.
 
### Deprecated Methods

 * All methods of `MapUtil` have been moved to `ObjectUtil`. The `MapUtil` versions have been marked as deprecated.

## Release 0.5.9 - 21 April 2015

### Bug Fixes

 * Ensure `IOUtil.download_to_buffer` always returns a raw-binary `Buffer` (never a `String`).

## Release 0.5.6 - 21 April 2015

### Enhancements

 * Added `IOUtil` with `pipe_to_buffer`, `pipe_to_file`, `download_to_buffer` and `download_to_file` methods.

## Release 0.5.5 - 1 April 2015

### Enhancements

 * Support multiple files in `FileUtil.rm` and `FileUtil.rmdir`.
 * Add return value to `FileUtil.rm`, `FileUtil.rmdir` and `File.mkdir`.
 * Add `ignore_errors` flag to `FileUtil.load_json_file_sync` and `FileUtil.load_json_stdin_sync`.
 * Ignore `null` values in ObjectUtil.merge

## Release 0.5.4 - 1 April 2015

### Enhancements

 * Check for `null` in `FileUtil.rm`, `FileUtil.rmdir` and `File.mkdir` and do nothing when found.

## Release 0.5.3 - 1 April 2015

### Enhancements

 * Added `FileUtil.rm`, `FileUtil.rmdir`, `File.mkdir`, `File.sanitize_filename` and `File.uniquify_filename`.
 * Added `AsyncUtil.wait`, `AsyncUtil.cancel_wait`, `AsyncUtil.interval`, `AsyncUtil.cancel_interval` and related methods.
 * Added `LogUtil.tlog`, `LogUtil.terr` and related methods.

## Release 0.5.2 - 25 March 2015

### Enhancements

 * Added `DateUtil.format_datetime_long`, `DateUtil.format_date_long` and `DateUtil.format_time_long`.

## Release 0.5.1 - 25 March 2015

`Util` methods divided into distinct categories (`DateUtil`, `StringUtil`, etc.).

(For now) the original `Util` methods still exist, as aliases the equivalent method in the new type.

## Release 0.4.7 - 21 January 2015

This release is identical to Version 0.4.6.  I've updated the release number in an attempt to work around an issue with `npm publish`.

## Release 0.4.6 - 21 January 2015

### Enhancements

 * Added `Util.to_unit` and `Util.duration`.

## Release 0.4.5 - 18 December 2014

### Enhancements

 * Added `Util.smart_join`.

## Release 0.4.4 - 17 December 2014

### Enhancements

 * Added `Util.iso_8601_regexp`.

## Release 0.4.3 - 17 December 2014

### Enhancements

 * Added `Util.read_stdin_sync`,  `Util.load_json_file_sync` and `Util.load_json_stdin_sync`.

## Release 0.4.2 - 12 December 2014

### Enhancements

 * Added `Util.remove_null` and `Util.to_int`.

### Bug Fixes

 * Fixed issue with `Util.is_int(0)` returning `false`.

## Release 0.4.1 - 11 December 2014

### Enhancements

 * `Util.compare` now (a) compares strings using `String.prototype.localeCompare` when available and (b) folds string case together such that `a` sorts before `B` and so on.  (Previously both `['B','a','A','b'].sort()` and `['B','a','A','b'].sort(Util.compare)` yielded `['A','B','a','b']`. Now `['B','a','A','b'].sort(Util.compare)` yields `['A','a','B','b']`.)

## Release 0.4.0 - 14 Novemver 2014

### Enhancements

 * Added `arrays_are_equal`, `uniquify`, `object_array_to_map`, `truthy_string` and `falsey_string` to `Util`..

## Release 0.3.5 - 2 Novemver 2014

### Enhancements

 * Added `Util.remove_falsey`.

 * Added documention.

## Release 0.3.3 - 20 October 2014

### Enhancements

 * Enhanced `Util.blank_to_null` to convert blank object attributes to `null`.

## Release 0.3.2 - 20 October 2014

### Enhancements

 * Added `Util.blank_to_null`.

 * Added option to `Util.handle_error` for throwing an error rather than invoking a callback.

## Release 0.3.1 - 18 October 2014

### Bug Fixes

 * Fixed issue with `Util.is_blank()` not testing for non-alphanumeric characters like `/` or `$`.

### Enhancements

 * Added `Util.hash_password`, `Util.validate_hash_password` and `Util.slow_equals` methods.

## Release 0.2.1 - 15 October 2014

### Enhancements

 * Added `Config` (`config.coffee`).

## Release 0.2.0 - 5 October 2014

### Bug Fixes

 * Various documentation and test updates.

### Enhancements

 * Added `timer.lap()` to `Stopwatch`.

 * Added `Util.escape_for_regexp`.

 * Added "marker" parameter to `Util.truncate`, and tweaked related logic.

## Release 0.1.1 - 30 September 2014

 * *Change log not tracked up to and including this release.*
