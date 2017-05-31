# inote-util Release Notes

This file summarizes the changes bundled in each release of `inote-util`.

<!-- toc -->

- [inote-util Release Notes](#inote-util-release-notes)
	- [Release 1.8.6 (31 May 2017)](#release-186-31-may-2017)
	- [Release 1.8.5 (31 May 2017)](#release-185-31-may-2017)
	- [Release 1.8.4 (28 May 2017)](#release-184-28-may-2017)
	- [Release 1.8.3 (28 May 2017)](#release-183-28-may-2017)
	- [Release 1.8.2](#release-182)
	- [Release 1.8.1 (20 March 2017)](#release-181-20-march-2017)
	- [Release 1.8.0](#release-180)
	- [Release 1.7.2 (13 July 2016)](#release-172-13-july-2016)
	- [Release 1.7.1 (8 June 2016)](#release-171-8-june-2016)
	- [Release 1.7.0 (25 May 2016)](#release-170-25-may-2016)
	- [Release 1.6.3 (23 May 2016)](#release-163-23-may-2016)
	- [Release 1.6.2 (20 May 2016)](#release-162-20-may-2016)
	- [Release 1.6.1 (20 May 2016)](#release-161-20-may-2016)
	- [Release 1.6 (19 May 2016)](#release-16-19-may-2016)
	- [Release 1.5.2 (17 May 2016)](#release-152-17-may-2016)
	- [Release 1.5.1 (16 May 2016)](#release-151-16-may-2016)
	- [Release 1.5.0 (16 May 2016)](#release-150-16-may-2016)
	- [Release 1.4.1 (15 May 2016)](#release-141-15-may-2016)
	- [Release 1.4.0 (14 May 2016)](#release-140-14-may-2016)
	- [Release 1.3.0 (13 May 2016)](#release-130-13-may-2016)
	- [Release 1.2.0 (13 May 2016)](#release-120-13-may-2016)
	- [Release 1.1.0 (9 May 2016)](#release-110-9-may-2016)
	- [Release 1.0.1 (8 May 2016)](#release-101-8-may-2016)
	- [Release 1.0.0 (7 May 2016)](#release-100-7-may-2016)
	- [Release 0.9.0 (20 January 2016)](#release-090-20-january-2016)
	- [Release 0.8.0 (24 July 2015)](#release-080-24-july-2015)
	- [Release 0.7.0 (16 July 2015)](#release-070-16-july-2015)
	- [Release 0.6.1 (20 April 2015)](#release-061-20-april-2015)
	- [Release 0.6.0 - 21 April 2015](#release-060-21-april-2015)
	- [Release 0.5.9 (21 April 2015)](#release-059-21-april-2015)
	- [Release 0.5.6 (21 April 2015)](#release-056-21-april-2015)
	- [Release 0.5.5 (1 April 2015)](#release-055-1-april-2015)
	- [Release 0.5.4 (1 April 2015)](#release-054-1-april-2015)
	- [Release 0.5.3 (1 April 2015)](#release-053-1-april-2015)
	- [Release 0.5.2 (25 March 2015)](#release-052-25-march-2015)
	- [Release 0.5.1 (25 March 2015)](#release-051-25-march-2015)
	- [Release 0.4.7 (21 January 2015)](#release-047-21-january-2015)
	- [Release 0.4.6 (21 January 2015)](#release-046-21-january-2015)
	- [Release 0.4.5 (18 December 2014)](#release-045-18-december-2014)
	- [Release 0.4.4 (17 December 2014)](#release-044-17-december-2014)
	- [Release 0.4.3 (17 December 2014)](#release-043-17-december-2014)
	- [Release 0.4.2 (12 December 2014)](#release-042-12-december-2014)
	- [Release 0.4.1 (11 December 2014)](#release-041-11-december-2014)
	- [Release 0.4.0 (14 November 2014)](#release-040-14-november-2014)
	- [Release 0.3.5 (2 November 2014)](#release-035-2-november-2014)
	- [Release 0.3.3 (20 October 2014)](#release-033-20-october-2014)
	- [Release 0.3.2 (20 October 2014)](#release-032-20-october-2014)
	- [Release 0.3.1 (18 October 2014)](#release-031-18-october-2014)
	- [Release 0.2.1 (15 October 2014)](#release-021-15-october-2014)
	- [Release 0.2.0 (5 October 2014)](#release-020-5-october-2014)
	- [Release 0.1.1 (30 September 2014)](#release-011-30-september-2014)

<!-- tocstop -->

## Release 1.8.6 (31 May 2017)

  * Bug fixes to the just-added `AsyncUtil.fork_for_each_async` and `AsyncUtil.throttled_fork_for_each_async` methods.  (Oops :)

## Release 1.8.5 (31 May 2017)

  * Added `AsyncUtil.fork_for_each_async` and `AsyncUtil.throttled_fork_for_each_async`.

## Release 1.8.4 (28 May 2017)

  * `request` dependency upgraded to v2.81+ to address a [remote memory exposure](https://nodesecurity.io/advisories/request_remote-memory-exposure) vulnerability.

## Release 1.8.3 (28 May 2017)

  * When called with zero arguments, `uuid()` now generates a UUID value (while `uuid(null)` still returns `null` and `uuid(null,true)` still generates a UUID value).

  * New method `ObjectUtil.deep_merge` added, which recursively merges maps.

## Release 1.8.1 (20 March 2017)

  * `__` is now supported as a delimiter for environment-variable based configuration parameters. (E.g., `foo__bar=X` sets the configuration parameter that can be accessed as `config.get("foo:bar")`)
  * `uuid(value,generated=false)` is deprecated. The default value for `generated` will change to `true` in the next major release.  
    * To retain the current behavior, use `normalize_uuid`.
    * To switch to the new behavior now, use `make_uuid()`, `make_uuid_v1()` or `make_uuid_v4()`.
  * The following methods were added to `StringUtil`:
    * `sanitize_for_html`
		* `sanitize_for_sql_like`
		* `json_or_null`
  * `NetUtil.normalize_url` was added.

## Release 1.8.0

*TODO: release notes missing*

## Release 1.7.2 (13 July 2016)

### Enhancements

 * `IOUtil.download_to_data_uri` method added.

## Release 1.7.1 (8 June 2016)

### Bug Fixes

 * Fixed an issue in `package.son` that would cause `npm prune` to remove the `semver` package (even though it was listed in the package’s dependencies).

## Release 1.7.0 (25 May 2016)

### Enhancements

 * Added:
   * a file-extension-to-MIME-type mapping (`FileUtil.get_mime_for_extension`),
   * a MIME-type-to-file-extension-mapping (`FileUtil.get_extension_for_mime`)
   * a default collection of more than 1000 MIME/file-extension pairs.
   * various methods for changing or controlling the mappings (`FileUtil.get_extension_to_mime_map`, `FileUtil.get_mime_to_extenion_map`, `FileUtil.set_extension_to_mime_map`, `FileUtil.set_mime_to_extension_map`, `FileUtil.add_to_extension_to_mime_map`, `FileUtil.add_to_mime_to_extension_map`)
 * Several aliases were created for new and existing `FileUtil` methods:
   * `get_mime` = `get_mime_type` = `get_file_mime_type`
   * `get_mime_via_magic` = `get_mime_type_via_magic` = `get_file_mime_type_via_magic`
   * `get_mime_for_extension` = `get_mime_for_ext`
   * `get_extension_for_mime` = `get_ext_for_mime`
   * `get_extension_to_mime_map` = `get_ext_to_mime_map`
   * `get_mime_to_extension_map` = `get_mime_to_ext_map`
   * `set_extension_to_mime_map` = `set_ext_to_mime_map`
   * `set_mime_to_extension_map` = `set_mime_to_ext_map`
   * `add_to_extension_to_mime_map` = `add_to_ext_to_mime_map`
   * `add_to_mime_to_extension_map` = `add_to_mime_to_ext_map`
   * etc.

### Changes

 * The existing `FileUtil.get_extension(filename)` method now accepts a file extension (e.g., `.pdf` or `pdf`) in addition to a filename (`foobar.pdf`).
 * The existing  `FileUtil.get_file_mime_type` has been extended to test the file-extension if the "magic number"-based approach fails to obtain a specific MIME type.
   * The newly added `get_file_mime_type_via_magic` method can be used to avoid this extension-based lookup and only rely upon the contents of the file.
   * The newly added `get_mime_for_extension` can be used to avoid the magic-number-based lookup and only rely upon the file name itself.



## Release 1.6.3 (23 May 2016)

### Enhancements

 * Added `Util.version_satisfies`.

### Changes

 * Introduced a dependency on [`semver`](https://github.com/npm/node-semver).

## Release 1.6.2 (20 May 2016)

### Enhancements

 * Added `FileUtil.file_age_sync` and `FileUtil.file_mtime_sync`.

## Release 1.6.1 (20 May 2016)

### Enhancements

 * Added `AsyncUtil.wait_until`.

## Release 1.6 (19 May 2016)

### Enhancements

 * Added `get_extension` (an alias for `path.extname`), `get_file_mime_type`, `is_mime`/`file_is_mime` and `is_pdf`/`file_is_pdf` to `FileUtil`

### Changes

 * Introduced a dependency on [`mmmagic`](https://github.com/mscdex/mmmagic).
 * Changed `priorityqueuejs` dependency to version `^1.0` (was `latest`.)

## Release 1.5.2 (17 May 2016)

### Enhancements

 * Added `LogUtil.tperr` and `LogUtil.tplog`.

## Release 1.5.1 (16 May 2016)

### Changes

 * `-o` option added to `ZipUtil.unzip`. Note that this will cause `unzip` to overwrite existing files (without prompting).

## Release 1.5.0 (16 May 2016)

### Enhancements

 * Added `ZipUtil` with `zip`, `unzip` and `contents` methods.
 * Added `StringUtil.escape_for_bash` (also aliased as `escape_for_shell`).
 * Added `FileUtil.replace_extension` and `FileUtil.strip_extension`.

## Release 1.4.1 (15 May 2016)

### Bug Fixes

 * Export `WorkQueue` so it is actually available. ¯\\\_(ツ)\_/¯

## Release 1.4.0 (14 May 2016)

### Enhancements

 * Added `WorkQueue` utility.

### Changes

 * In support of `WorkQueue` a new dependency on [`priorityqueuejs`](https://github.com/janogonzalez/priorityqueuejs) was added.

## Release 1.3.0 (13 May 2016)

### Enhancements

 * Added `file_age` and `file_mtime` methods to `FileUtil`.
 * Added `NetUtil` with methods `is_port_in_use` and `get_unused_port`.

### Changes

 * In support of `NetUtil` a new dependency on [`shelljs`](https://github.com/shelljs/shelljs) was added.

## Release 1.2.0 (13 May 2016)

### Enhancements

 * Added `is_dir`, `is_file`, `ls`, `copy_file` and `move_file` methods to `FileUtil`.

## Release 1.1.0 (9 May 2016)

### Enhancements

 * Added `is_float` and `to_float` methods to `Util` and `NumberUtil`.
 * Added additional detail to README.md method documentation.

### Changes

 * The unit `milli` is now expressed as `millisecond` in `DateUtil.duration`.

### Bug Fixes

 * Fixed a minor bug in which `DateUtil.duration`'s `min.no_millis.*` fields actually contained milliseconds.

## Release 1.0.1 (8 May 2016)

### Changes

 * Update `node-uuid` version to `^1.4.7`.

## Release 1.0.0 (7 May 2016)

### Enhancements

 * Now fully compatible with Node versions 0.10 thru 6.1.  (See the [Travis build status here](https://travis-ci.org/intellinote/inote-util).)
 * Clarified second argument of `Util.field_comparator` and `Util.path_comparator` as "use locale compare".  (When `true` string-valued arguments are compared using `localeCompare`.)

### Changes

 * Minimal Node version (the `engine` value in `package.json`) upgraded to Node v0.10.45 to include fixes for an OpenSSL security vulnerability, as described [here](https://nodejs.org/en/blog/vulnerability/openssl-may-2016/).
 * Deprecated `Util.case_insensitive_compare`, since it was always equivalent to `Util.compare`.
 * Note that in Node version 0.12, the behavior of the default `String.localeCompare` changed.  In v0.10, `"A".compare("a")` returns `-32`, yielding an sort-order like `A B C a b c`.  In v0.12 and later, `"A".compare("a")` returns `1`, yielding an sort-order like `a b c A B C`. inote-util makes no effort to "correct" for that, hence the order of strings returned by `Util.compare` will be different when run under Node v0.10 and under Node v0.12 and later.

## Release 0.9.0 (20 January 2016)

### Enhancements

 * Added `RandomUtil.random_element`, `RandomUtil.random_alpha`, `RandomUtil.random_ALPHA`, `RandomUtil.random_Alpha` and , `RandomUtil.random_numeric`.

### Bug Fixes

 * Adding missing `October` from date formatting methods.


## Release 0.8.0 (24 July 2015)

### Enhancements

 * Added `AsyncUtil.fork` and `AsyncUtil.throttled_fork`.


## Release 0.7.0 (16 July 2015)

### Enhancements

 * Added `RandomUtil.seed_rng` and `RandomUtil.set_rng`.
 * Added (optional) `rng` parameter to `RandomUtil.random_hex` and `RandomUtil.random_alphanumeric`.
 * Exposed (exported) `RandomUtil.random_digits`.

### Other

 * Added coffeelint configuration defaults; addressed several coffeelint-reported issues.
 * Changed package.json to refer to explicit versions of dependencies, rather than just `latest`.


## Release 0.6.1 (20 April 2015)

### Enhancements

 * Added `WebUtil.param`.
 * Added `FileUtil.touch`

## Release 0.6.0 - 21 April 2015

### Enhancements

 * Added `ObjectUtil.deep_clone`.
 * `ObjectUtil.shallow_clone` has been extended to clone `Array`s and to handle `String`, `Number` and `Boolean` types.

### Deprecated Methods

 * All methods of `MapUtil` have been moved to `ObjectUtil`. The `MapUtil` versions have been marked as deprecated.

## Release 0.5.9 (21 April 2015)

### Bug Fixes

 * Ensure `IOUtil.download_to_buffer` always returns a raw-binary `Buffer` (never a `String`).

## Release 0.5.6 (21 April 2015)

### Enhancements

 * Added `IOUtil` with `pipe_to_buffer`, `pipe_to_file`, `download_to_buffer` and `download_to_file` methods.

## Release 0.5.5 (1 April 2015)

### Enhancements

 * Support multiple files in `FileUtil.rm` and `FileUtil.rmdir`.
 * Add return value to `FileUtil.rm`, `FileUtil.rmdir` and `File.mkdir`.
 * Add `ignore_errors` flag to `FileUtil.load_json_file_sync` and `FileUtil.load_json_stdin_sync`.
 * Ignore `null` values in ObjectUtil.merge

## Release 0.5.4 (1 April 2015)

### Enhancements

 * Check for `null` in `FileUtil.rm`, `FileUtil.rmdir` and `File.mkdir` and do nothing when found.

## Release 0.5.3 (1 April 2015)

### Enhancements

 * Added `FileUtil.rm`, `FileUtil.rmdir`, `File.mkdir`, `File.sanitize_filename` and `File.uniquify_filename`.
 * Added `AsyncUtil.wait`, `AsyncUtil.cancel_wait`, `AsyncUtil.interval`, `AsyncUtil.cancel_interval` and related methods.
 * Added `LogUtil.tlog`, `LogUtil.terr` and related methods.

## Release 0.5.2 (25 March 2015)

### Enhancements

 * Added `DateUtil.format_datetime_long`, `DateUtil.format_date_long` and `DateUtil.format_time_long`.

## Release 0.5.1 (25 March 2015)

`Util` methods divided into distinct categories (`DateUtil`, `StringUtil`, etc.).

(For now) the original `Util` methods still exist, as aliases the equivalent method in the new type.

## Release 0.4.7 (21 January 2015)

This release is identical to Version 0.4.6.  I've updated the release number in an attempt to work around an issue with `npm publish`.

## Release 0.4.6 (21 January 2015)

### Enhancements

 * Added `Util.to_unit` and `Util.duration`.

## Release 0.4.5 (18 December 2014)

### Enhancements

 * Added `Util.smart_join`.

## Release 0.4.4 (17 December 2014)

### Enhancements

 * Added `Util.iso_8601_regexp`.

## Release 0.4.3 (17 December 2014)

### Enhancements

 * Added `Util.read_stdin_sync`,  `Util.load_json_file_sync` and `Util.load_json_stdin_sync`.

## Release 0.4.2 (12 December 2014)

### Enhancements

 * Added `Util.remove_null` and `Util.to_int`.

### Bug Fixes

 * Fixed issue with `Util.is_int(0)` returning `false`.

## Release 0.4.1 (11 December 2014)

### Enhancements

 * `Util.compare` now (a) compares strings using `String.prototype.localeCompare` when available and (b) folds string case together such that `a` sorts before `B` and so on.  (Previously both `['B','a','A','b'].sort()` and `['B','a','A','b'].sort(Util.compare)` yielded `['A','B','a','b']`. Now `['B','a','A','b'].sort(Util.compare)` yields `['A','a','B','b']`.)

## Release 0.4.0 (14 November 2014)

### Enhancements

 * Added `arrays_are_equal`, `uniquify`, `object_array_to_map`, `truthy_string` and `falsey_string` to `Util`.

## Release 0.3.5 (2 November 2014)

### Enhancements

 * Added `Util.remove_falsey`.

 * Added documention.

## Release 0.3.3 (20 October 2014)

### Enhancements

 * Enhanced `Util.blank_to_null` to convert blank object attributes to `null`.

## Release 0.3.2 (20 October 2014)

### Enhancements

 * Added `Util.blank_to_null`.

 * Added option to `Util.handle_error` for throwing an error rather than invoking a callback.

## Release 0.3.1 (18 October 2014)

### Bug Fixes

 * Fixed issue with `Util.is_blank()` not testing for non-alphanumeric characters like `/` or `$`.

### Enhancements

 * Added `Util.hash_password`, `Util.validate_hash_password` and `Util.slow_equals` methods.

## Release 0.2.1 (15 October 2014)

### Enhancements

 * Added `Config` (`config.coffee`).

## Release 0.2.0 (5 October 2014)

### Bug Fixes

 * Various documentation and test updates.

### Enhancements

 * Added `timer.lap()` to `Stopwatch`.

 * Added `Util.escape_for_regexp`.

 * Added "marker" parameter to `Util.truncate`, and tweaked related logic.

## Release 0.1.1 (30 September 2014)

 * *Change log not tracked up to and including this release.*
