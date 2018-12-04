#!/usr/bin/env bash

set -eu

here="$(unset CDPATH && builtin cd "$(dirname "${BASH_SOURCE[0]}")/.." && builtin pwd)"

I="\e[1;38;5;46m"; O="\e[0m"
test_num="1"; tests_completed=
finish () {
    echo -e "$I\nTests completed: \n$tests_completed"
}
trap finish EXIT

# prefixes we'll be creating:
P1="/tmp/xc"
P2="/tmp/xc2"
P3="/tmp/xc3"

# the installer script:
fn_create_rel="misc/create_bashenv/create"
fn_create="$here/$fn_create_rel"

# constructor created installers will land here:
d_inst="/tmp/installers"
# created at second test:

export be_force_colors=true
orig_path="$PATH"

# Example config with additional tools.
# does contain tests and python_tests:
test_config1="$here/misc/be_configs/reactive_python2.7"


# ----------------------------------------------------------------------- Tools
run () {
    # we have too much output, need to really find the tests;-)
    echo -e "$I"
    echo -e "___________________________________________"
    echo -e "___________________________________________"
    echo -e "___________________________________________"
    echo
    echo TEST Nr $test_num: "$1"
    echo -e "___________________________________________"
    echo -e "___________________________________________"
    echo -e "___________________________________________"
    echo -e "$O"
    # all in subshells to not pollute runner namespace e.g. by sourcing stuff:
    ( $1 )
    tests_completed="$tests_completed\n- $test_num $1"
    test_num=$((test_num + 1))
}

act_verify () {
    # verify the basic working of a new bashenv:
    echo "------------------------"
    echo "activation run $*"
    echo "------------------------"
    local prefix="${1:-xx}"
    source "$prefix/bin/app/environ/bash/be_active" true foo_func
    verify $*
}

verify () {
    local prefix="${1:-xx}"
    echo "------------------------"
    echo "verification run $*"
    echo "------------------------"
    conda info -a
    which python      | grep "$prefix" || exit 1
    which pip         | grep "$prefix" || exit 1
    which hg          | grep "$prefix" || exit 1
    which git         | grep "$prefix" || exit 1
    which constructor | grep "$prefix" || exit 1
    echo "Testing .git presence"
    test -e "$prefix/.git" || exit 1
    return 0
    # only this allows to remove directly after git -A:
    # otherwise the gc process conflicts with rm:
    # can't do, tests are also on non travis:
    # -> Polling in del function instead... :-/
    #git config --global gc.auto 0
}

del () {
    # because of git's stupid gc which I can't turn off w/o git...
    for i in 1 2 3 4 5; do
        echo "trying delete $1..."
        /bin/rm -rf "$1" && return 0
        echo "could not delete... trying again in 2"
        sleep 2
    done
    exit 1
}



# ----------------------------------------------------------------------- Tests
test_create_scratch () {
    echo "Creating a bashenv from scratch, with only wget available."
    echo "(that requires internet to pull conda stuff)"
    del "$P1"
    local fn_register_file="/tmp/be_test_bashrc"
    $fn_create -p "$P1" -G -F "$fn_register_file" go
    # we did change .bashrc (no -N):
    (
       set +eu
       set -x
       origflags="$-"
       cat "$fn_register_file" | grep "$P1" || exit 1
       set +x
       source "$fn_register_file"
       set -x
       # flags should be in orig state after sourcing the be_active:
       test "$-" == "$origflags" || exit 1
       set +x
       be_xc_tmp
       verify "$P1"
    ) || exit 1
    # now we have git and hg and pip:
    act_verify "$P1"
}

test_construct_relocatable_conda_installer_with_packages () {
    echo "we create a single file installer for offline installs"
    del "$d_inst"
    # still there from first test:
    # we need that for the constructor command:
    act_verify "$P1"
    mkdir -p "$d_inst"
    constructor --output-dir="$d_inst" "$here/misc/constructions/base"
    echo "constructed: `ls -lta $d_inst`"
    ls "$d_inst" |grep Linux-x86_64 || exit 1
}

test_bootstrap_from_constructed () {
    echo "From the single file installer we can create a full bashenv - "
    echo "(at an arbitrary location)"
    del "$P2"
    local base_installer="$d_inst/`/bin/ls $d_inst | grep base_`"

    "$fn_create" -Nb -G -C "$base_installer" -p "$P2" go

    act_verify "$P2"

    # reusing this one, for future installs:
    echo "copying base installer to cache"

    # read the installer package cache variable - we are in a subshell, all
    # forgotten in next test:
    source "$fn_create"
    cp "$base_installer" "$cached_installer"
}


test_create_from_existing_with_packages () {
    echo "From the single file installer we now create a richer environment:"
    cat "$test_config1"
    echo "(Note that the config file contains also a few basic tests for those new tools)"
    del "$P3"
    act_verify "$P1"
    "$P1/bin/app/environ/bash/$fn_create_rel" -NG -b -p "$P3" -c "$test_config1" go
    act_verify "$P3"
    return 0
}



main () {
     run test_create_scratch
     run test_construct_relocatable_conda_installer_with_packages
     run test_bootstrap_from_constructed
     run test_create_from_existing_with_packages
}
main $*
