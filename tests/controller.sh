#!/usr/bin/env bash

set -eu

here="$(unset CDPATH && cd "$(dirname "$BASH_SOURCE")" && echo $PWD)"
cd "$here"
cd ..
here="`pwd`"

P1="/tmp/xc"
P2="/tmp/xc2"
P3="/tmp/xc3"
create="$here/misc/create_bashenv_kickstart/create"
d_inst="/tmp/installers"
# created at second test:
base_installer=

syspath="$PATH"

remove_existing () {
    rm -rf "$1" || true
}
run () {
    echo
    echo '*******************************************'
    echo "$1"
    echo '*******************************************'
    echo
    $1
}

del () {
    echo "erasing $1"
    rm -rf "$1"
}

act_verify () {
    export PATH="$1/bin:$syspath"
    which python | grep "$1" || exit 1
    which hg          | grep "$1" || exit 1
    which git         | grep "$1" || exit 1
    which constructor | grep "$1" || exit 1
    test -e "$1/.git" || exit 1
}

test_create_scratch () {
    remove_existing "$P1"
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
    remove_existing "$P3"
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
    remove_existing "$P2"
    p="$PATH"
    source "$P1/bin/app/environ/bash/be_active"
    nfo "have it"
    "$P1/bin/app/environ/bash/$create" -bp "$P2" go
    verify "$P2"
}




main () {
    ( run test_create_scratch                 )
    ( run test_construct_base_conda_installer )
    ( run test_bootstrap_from_constructed     )
    ( run test_create_from_existing           )
}

main $*
