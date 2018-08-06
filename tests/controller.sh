#!/usr/bin/env bash

set -eu

here="$(unset CDPATH && cd "$(dirname "$BASH_SOURCE")" && echo $PWD)"
cd "$here"
cd ..

P1="/tmp/xc"
P2="/tmp/xc2"
create="misc/create_bashenv_kickstart/create"

syspath="$PATH"

remove_existing () {
    rm -rf "$1" || true
}

verify () {
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
    verify "$P1"

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
    ( test_create_scratch; )
    ( test_create_from_existing; )
}

main $*
