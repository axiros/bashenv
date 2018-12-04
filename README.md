# bashenv - Environment Setup

[![Build Status](https://travis-ci.org/axiros/bashenv.svg?branch=master)](https://travis-ci.org/axiros/bashenv)

This sets up enviroments with some bash helper features plus [conda](https://anaconda.org/) package management.

From any Unix environment with only wget or curl you can define the tools you
need in a simple config file, then start an installer producing the intended environment...

- in a shell sourceable way, w/o even leaving your current process.

- contained within one (arbitrary) directory (binaries are patched accordingly)

- with a [command][constructor] at hand to create one installer file,
  for (again relocatable) installs in airtight production environments...

- ...which you can also use as a basis for configurations with additional features


The tool is designed to work well with static package download facilities, like pip servers and conda channels but also with DVCS servers.

Note: When you do not have a DVCS tool like git or hg on your target (but Internet or a static server with a base environment),
 then just download a snapshot of this repo to anywhere in your filesystem and run the [installer](misc/create_bashenv/create).



## Included Tools

In the base package the minimum conda tools are

- git
- hg
- [constructor][constructor]
- pip

but that list can be extended via the config. As mentioned, the installs can be
based on previously constructed, more feature rich base installers as well.

## Example Config

```bash
development_chroot root@ip-10-34-2-19:/# cat /root/bashenv/misc/be_configs/reactive_python2.7
#!/usr/bin/env bash

# The one the autor suggests - can be changed via -p <prefix dir>
default_prefix="/xc.reactive_python_2.7"

# one line per conda install statement.
# These are binary packages for your architecture already, installed within the prefix:
packages="-c conda-forge jq httpie uwsgi
nginx
"

pips="structlog rx gevent"

# adds all sys.paths into $PYTHONPATH based on this file:
local_pypath_from_sys_path_in="/opt/server/bin/paster"
# note: that will make any constructed installer package only work
# like expected when these external deps are present on the target
# as well.

tests='
http --version
jq --version
'
tests_python='import rx, structlog; print(structlog, rx)'
```


# Usage

tbd - see [tests](tests/runner.sh) for the moment.


## OSX / Other Platforms

Download the [Anaconda installer](https://conda.io/miniconda.html) for those manually and provide their location via `-C` when running the `create` tool.
The rest is identical. Should be clear that you cannot change the architecture of an already created bashenv on the fly, you have to start from scratch or from an existing bashenv in your architecture.


# Name
Why "bashenv" and not "shellenv", "condaenv", "linuxenv", "simpleenv", "pp (portable packages)"... ?

## General
- I like the `$be_<key>` env vars (`be_verbose=true`) and shell function calls like `be reactive`, `be verbose`
- It is not a packaging tool, just re-uses other binary packaging tools, mainly Conda
- Conda is at the time being way sufficient for our needs but container filesystems as part of solutions are also planned.

## `bash...`
- You need nothing else then bash to start flying and bash is everywhere. 
- It is not just for humans (then it would be zshenv) but also for processes and bash covers both quite well
- [shellenv](https://github.com/aspiers/shell-env) was taken, not just [once](https://www.google.de/search?q=github+shellenv).

## `...env`
- Because you do not leave your current process environment when activating it - but get it enriched.
=> You could activate it on demand, e.g. within a pipeline...





[constructor]: https://tech.zegami.com/conda-constructor-tutorial-make-your-python-code-easy-to-install-cross-platform-f0c1f3096ae4 
