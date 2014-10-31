# Overview of inote-util methods

(incomplete)

## Util

`Util` collects assorted utility functions.

### Usage:

```javascript
var U = require('inote-util').Util;
str = U.trim(str);
```

### Methods

  * **Util.trim** - removes leading and trailing whitespace from a (possibly `null`) string.
  * **Util.isnt_blank** - returns `true` iff the given string is not `null` and contains at least one non-whitespace character.
  * **Util.is_blank** - returns `true` iff the given string is `null`, empty or only contains whitespace characters.
  * **Util.blank_to_null** - converts blank strings or attribute values to `null`.
  * **Util.truncate** - a minimally "smart" truncation that attempts to truncate a string at a word boundary.
  * **Util.escape_for_json** - escapes a string for use as literal characters in a JSON string.
  * **Util.escape_for_regexp** - escapes a string for use as literal characters in regular expression.
  * **Util.lpad** - left-pad a string or array.
  * **Util.rpad** - right-pad a string or array.
  * **Util.round_decimal** - round a number to the specified precision
  * **Util.is_int** - check if the given object is an (optionally signed) simple integer value
  * **Util.trim_trailing_null** - remove trailing `null` values from an array
  * **Util.right_shift_args** - convert trailing `null` values to leading `null` values
  * **Util.paginate_list** - extract a sub-array based on offset and limit
  * **Util.remove_falsey** - `delete` any attribute whose value evaluates to false
  * **Util.merge** - merge multiple maps into a new, combined map
  * **Util.shallow_clone** - create a "shallow" copy of an object
  * **Util.subset_of** - check whether on array contains another arrays as if they are sets
  * **Util.is_subset_of** - an alias for `subset_of`
  * **Util.strict_subset_of** - check whether on array strictly contains another arrays as if they are sets
  * **Util.sets_are_equal** - compare two arrays as if they were sets
  * **Util.hex_to_rgb_triplet** - convert a hex-based `#rrggbb` string to decimal `[r,g,b]` values
  * **Util.hex_to_rgb_strng** - convert a hex-based `#rrggbb` string to a decimal-based `rgb(r,g,b)` string
  * **Util.rgb_string_to_triplet** - extract the `[r,g,b]` values from an `rgb(r,g,b)` string
  * **Util.rgb_to_hex** - convert `r`, `g` and `b` components or an `rgb(r,g,b`) string to a hex-based `#rrggbb` string
  * **Util.random_bytes** - generate a string of random bytes
  * **Util.random_hex** - generate a string of random hexadecimal characters
  * **Util.random_alphanumeric** - generate a string of random numbers and letters
  * **Util.slow_equals** - constant-time comparison of two buffers for equality
  * **Util.validate_hashed_password** - compare the `expected_digest` with the hash computed from the remaining parameters.
  * **Util.hash_password**
  * **Util.compare** - a basic comparator function
  * **Util.case_insensitive_compare** - a case-insensitive comparator function
  * **Util.field_comparator** - compares objects based on an attribute
  * **Util.path_operator** - compares objects based on (optionally nested) attributes
  * **Util.desc_comparator** - reverses another comparison function.
  * **Util.descending_comparator** - an alias for `desc_comparator`
  * **Util.composite_comparator** - chains several comparison functions into one
  * **Util.remote_ip** - identifies the "client IP" for the given request in various circumstances
  * **Util.handle_error** - invoke a callback on error
  * **Util.uuid** - normalize or generate a UUID value
  * **Util.pad_uuid** - normalize or generate a padded UUID value
  * **Util.b64e** - Base64 encodes a Buffer
  * **Util.b64d** - decodes a Base64-encoded string
  * **Util.for_async** - executes an asynchronous `for` loop.
  * **Util.for_each_async** - executes an asynchronous `forEach` loop.
  * **Util.procedure** - generates a new `Sequencer` object
