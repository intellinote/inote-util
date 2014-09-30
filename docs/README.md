# inote-util documentation

This directory contains the raw-source for (and, when published,
HTML rendered from) inote-util documentation and related
meta-information.

# Contents

Once generated, this directory should contain:

 * Complete [annotated source code](./docco/index.html).

 * A [test coverage report](./coverage.html).

# Generating

You can use the [`Makefile`](../Makefile) targets to generate the
"published" contents of this directory.

Specifically

  - `make markdown` will generate HTML documents from various Markdown
    files found in this directory (and elsewhere).

  - `make docco` will generate an HTML rendering of the annotated
    source code (using the documentation generating tool
    [docco](http://jashkenas.github.io/docco/)).

  - `make coverage` will instrument the module's source code (using
    [coffee-coverage](https://github.com/benbria/coffee-coverage)) and
    run [the unit test suite](../test) to generate a test coverage
    report.

  - `make docs` is equivalent to `make markdown docco`, hence you can
    run `make docs coverage` to generate all of the above.
