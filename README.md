Intro
=====

This repository is where I am keeping tests for assignment 2 for CS 453. There is also a test harness. To get started, just clone this repo:

    git clone https://github.com/srawlins/cs453-assignment2-tests

How it Works
============

To run the tests, cd into this test directory, and run:

    rspec

Different Start Symbols
-----------------------

Some tests expect `Prog` to be your start symbol, but there are also many intermediate steps that require a different token to be your start symbol. By default, rspec will not test any examples tagged with `expr_only`, `assg_only`, `stmt_only`, or `func_only`:

```
srawlins@lectura:~/cs453/assignment2/test$ rspec
PRNG's seed: 74010550369428865394943786560301933993
Run options: exclude {:expr_only=>true, :assg_only=>true, :stmt_only=>true, :func_only=>true}
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
................................................................................................
........................................................................

Finished in 8.57 seconds
1512 examples, 0 failures
```

These defaults are specified in `.rspec`.

If you want to test a different start symbol, then you can compile your `compile` program to
have, for example, `Expr` as your start symbol, then run rspec against just tests tagged with
`expr_only`:

```
rspec --tag expr_only
```

Randomize Tests
---------------

The `expr_only`, `assg_only`, and `stmt_only` tests all build on some basic `Expr` tests, so they number in the thousands. To run a random subset of the tests, set `$RANDOM_THRESHOLD`:

```
RANDOM_THRESHOLD=20 rspec --tag stmt_only
```

That example will run approximately 20% of the `stmt_only` tests.

Generated Tests
---------------

If you are writing your own tests, you can run them individually, or at a minimum, not run the generated tests:

```
rspec --tag ~generated
```

Contributing
============

