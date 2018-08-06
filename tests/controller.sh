#!/usr/bin/env bash

set -eu

here="$(unset CDPATH && cd "$(dirname "$BASH_SOURCE")" && echo $PWD)"
cd "$here"
cd ..
here="`pwd`"

P1="/tmp/xc"
P2="/tmp/xc2"
P3="/tmp/xc3"
create_rel="misc/create_bashenv_kickstart/create"
create="$here/$create_rel"
d_inst="/tmp/installers"
# created at second test:
base_installer=
export be_force_colors=true
syspath="$PATH"

run () {
    echo
    echo '*******************************************'
    echo TEST: "$1"
    echo '*******************************************'
    echo
    $1
}

del () {
    for i in 1 2 3 4 5 6 7 8 9; do
        /bin/rm -rf "$1" && return 0 || true
        # because of git's stupid gc which I can't turn off w/o git...
        echo "could not delete... trying again in 2"
        sleep 2
    done
}

act_verify () {
    export PATH="$1/bin:$syspath"
    which python | grep "$1" || exit 1
    which hg          | grep "$1" || exit 1
    which git         | grep "$1" || exit 1
    which constructor | grep "$1" || exit 1
    test -e "$1/.git" || exit 1
    # only this allows to remove directly after git -A:
    # otherwise the gc process conflicts with rm:
    # can't do, tests are also on non travis:
    # looping in del instead... :-/
    #git config --global gc.auto 0
}

test_create_scratch () {
    del "$P1"
    $create -p "$P1" go
    act_verify "$P1"
}

test_construct_base_conda_installer () {
    del "$d_inst"
    act_verify "$P1"
    mkdir -p "$d_inst"
    constructor --output-dir="$d_inst" "$here/misc/constructions/base"
    echo "constructed: `ls -lta $d_inst`"
    #del "$P1"
}

test_bootstrap_from_constructed () {
    del "$P3"
    base_installer="$d_inst/`/bin/ls $d_inst | grep base_`"
    "$create" -b -C "$base_installer" -p "$P3" go
    act_verify "$P3"
    del "$P3"
    # reusing for future installs:
    echo "copying base installer to cache"

    source "$create"
    cp "$base_installer" "$cached_installer"
}


test_create_from_existing () {
    del "$P2"
    p="$PATH"
    source "$P1/bin/app/environ/bash/be_active"
    nfo "have it"
    "$P1/bin/app/environ/bash/$create_rel" -bp "$P2" go
    act_verify "$P2"
    del "$P2"
}



main () {
    ( run test_create_scratch                 )
    ( run test_construct_base_conda_installer )
    ( run test_bootstrap_from_constructed     )
    ( run test_create_from_existing           )
}

main $*
