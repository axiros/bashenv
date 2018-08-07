# bashenv - Environment Setup

[![Build Status](https://travis-ci.org/axiros/bashenv.svg?branch=master)](https://travis-ci.org/axiros/bashenv)

This sets up enviroments with some bash helper features plus [conda](https://anaconda.org/) package management.

From any Unix environment with only wget or curl you can define the tools you
need in a config file, then start an installer producing the intended environment...

- in a shell sourceable way, w/o even leaving your current process.

- contained within one (arbitrary) directory (binaries are patched accordingly)

- with a [command][constructor] at hand to create one installer file,
  for (again relocatable) installs in airtight production environments.


The tool is designed to work well with static package download facilities, like pip servers and conda channels but also with DVCS servers.

Note: When you do not have a DVCS tool like git or hg on your target (but Internet or a static server with a base environment), then just download a snapshot of this repo to anywhere in your filesystem and run the [installer](misc/create_bashenv/create).




## Included Tools

In the base package the minimum conda tools are

- git
- hg
- [constructor][constructor]
- pip

but that list can be extended via the config.

## Example Config

```bash
development_chroot root@ip-10-34-2-19:/# cat /root/bashenv/misc/be_configs/reactive_python2.7
#!/usr/bin/env bash

conda_prefix="/xc.$(basename $be_config_file)"

packages="-c conda-forge jq httpie
"

pips="structlog rx gevent"

tests='
http --version
jq --version
'
# adds all sys.paths into $PYTHONPATH based on this file:
local_pypath_from_sys_path_in="/opt/server/bin/paster"
# note: that will make any constructed installer package only work
# like expected when these external deps are present on the target
# as well.


tests_python='import rx, structlog; print(structlog, rx)'
```


# Usage

tbd - see [tests](tests/controller.sh) for the moment.

## OSX / Other Platforms

Download the [Anaconda installer](https://conda.io/miniconda.html) for those manually and provide their location via `-C` when running the `create` tool.
The rest is identical. Should be clear that you cannot change the architecture of an already created bashenv on the fly, you have to start from scratch or from an existing bashenv in your architecture.


# Name
Why "bashenv" and not "shellenv", "condaenv", "linuxenv", "fastenv"... ?
- I like the `$be_<key>` env vars
- It is not just for humans (would have taken zsh if so) but also for processes and bash covers both quite well
- Conda is at the time being way sufficient for our needs but container filesystems as part of solutions are also planned.

So its bashenv mainly for the fact that you need nothing else then bash to start flying ;-)


[constructor]: https://tech.zegami.com/conda-constructor-tutorial-make-your-python-code-easy-to-install-cross-platform-f0c1f3096ae4 
