
# Introduction
This repository contains a coherent set of Common Lisp systems.

# Initialization file
The `initialization.lisp` file is an entry point designed to be used both for
interactive development and program execution. For the time being, it is used
to load and configure ASDF.

Using it is as simple as loading it, either in a standalone program or in a
Common Lisp implementation initialization file. For example, for SBCL, if the
`lisp-systems` repository has been cloned to `$HOME/common-lisp`, simply add
the following to `$HOME/.sbclrc`:

```lisp
(load #p"~/common-lisp/lisp-systems/initialize.lisp")
```

## Support
The initialization file has been tested on SBCL, CCL, ECL and CLISP.

# ASDF
The repository bundles a recent version of ASDF for two reasons:
- Implementations provide different versions of ASDF, making it difficult to
  rely on specific features of ASDF or UIOP.
- Some implementations such as ASDF provide old versions of ASDF and refuse to
  update them.

The `asdf` Git submodule points to a recent release of the [official ASDF
repository](https://gitlab.common-lisp.net/asdf/asdf).

After any update, the [ASDF file](asdf/build/asdf.lisp) must be rebuilt by
running `make` in the `asdf` directory.
