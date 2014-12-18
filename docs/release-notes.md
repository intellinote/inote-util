# inote-util Release Notes

This file summarizes the changes bundled in each release of `inote-util`.

<!-- toc -->

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
