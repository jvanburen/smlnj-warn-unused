# SML/NJ Unused Binding Patch

This downloads, modifies, and builds the SML/NJ compiler with a check for unused bindings.

## Building SML/NJ

#### via curl

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jvanburen/smlnj-warn-unused/110.82/install.sh)"
```

#### via wget

```shell
bash -c "$(wget https://raw.githubusercontent.com/jvanburen/smlnj-warn-unused/110.82/install.sh -O -)"
```

## Installing the modified compiler

Move the created directory into the appropriate location on your computer (`/usr/local/smlnj/` on macOS at least). Either add the `bin` folder to your PATH variable, or add a symlink to it the `smlnj-110.82/bin/sml` executable in `/usr/local/bin`.

## Using the compiler
By default, the compiler will warn when it detects an unused binding. This can be turned off by specifying `-Celab.unused-binding-warn=false` as a command line flag to sml. Additionally this can be controlled in the REPL by setting `Control.Elab.unusedBindingWarn := false` (or `true`)

