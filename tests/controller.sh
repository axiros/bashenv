#!/usr/bin/env bash

set -eu

here="$(unset CDPATH && cd "$(dirname "$BASH_SOURCE")" && echo $PWD)"
cd "$here"
cd ..

test_conda_prefix="`pwd`/xc2"
create="misc/create_bashenv_kickstart/create"

remove_existing () {
    rm -rf "$test_conda_prefix" || true
}

test_create_scratch () {
    $create -p "$test_conda_prefix" go
    export PATH="$test_conda_prefix/bin:$PATH"
    which python | grep "$test_conda_prefix" || exit 1
    which hg          | grep "$test_conda_prefix" || exit 1
    which git         | grep "$test_conda_prefix" || exit 1
    which constructor | grep "$test_conda_prefix" || exit 1
    test -e "$test_conda_prefix/.git" || exit 1

}


main () {
    remove_existing
    test_create_scratch
}

main $*
