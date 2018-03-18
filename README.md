# Mini-C compiler
3/2018
Amaury Camus
Grégoire Roussel

## Description

This is the main project of the **INF564 - Compilation** course.

The objective is to design a compiler for `mini-c`, a small but functional subset of C.

## Special features

In addition to compiling correctly, the compiler has the following *incredible* assets:
- sums & substractions with constant terms are translated to `add $$, reg`, `incq` or `decq`
- sums, substractions, mutiplications & divisions(except by 0) involving 2 constants terms are computed at compilation time instead ot run time.

## Tests 

The Makefile provides rules for all intermediate and final tests. For example:
```sh
# Tests the whole compilation chain
make t_final
```

It is also possible to provide a `test.c` and run `make`.

## Documentation 

`make doc` creates the documentation of the project, which will accessible in `doc/index.html`.

