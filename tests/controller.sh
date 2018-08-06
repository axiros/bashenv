#!/usr/bin/env bash

set -xeu

test_conda_prefix="`pwd`/xc2"
create="misc/create_bashenv_kickstart/create"

remove_existing () {
    rm -rf "$test_conda_prefix" || true
}

test_create_scratch () {
    $create -p "$test_conda_prefix" go
    which python | grep "$test_conda_prefix"
}


main () {
    remove_existing
    test_create_scratch
}

main $*
