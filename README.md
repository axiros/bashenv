# bashenv - Environment Setup

[![Build Status](https://travis-ci.org/axiros/bashenv.svg?branch=master)](https://travis-ci.org/axiros/bashenv)

This sets up enviroments with some bash helper features plus [conda](https://anaconda.org/)
based package management.

From any Unix environment with only wget or curl you can define the tools you
need in a config file, then start an installer producing the intended environment

- in a shell sourceable way, w/o even leaving your current process.

- contained within one (arbitrary) directory (binaries are patched accordingly)

- with a [command][constructor] at hand to create one installer file,
  for (again relocatable) installs in airtight production environments.


## Included Tools

In the base package the minimum conda tools are

- git
- hg
- [constructor][constructor]
- pip

but that list can be extended.


# Usage

tbd - see [tests](tests/controller.sh) for the moment.





[constructor]: https://tech.zegami.com/conda-constructor-tutorial-make-your-python-code-easy-to-install-cross-platform-f0c1f3096ae4 
