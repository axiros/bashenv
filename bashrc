# vim: filetype=sh

doc="Bashrc for Bashenvs

We are sourced in $CONDA_PREFIX/bin/activate, after conda activate, i.e. at
first activation of conda, i.e. after .bashrc ws sourced.

OR we are sourced from $CONDA_PREFIX/bin/bash --rcfile=<this file>
"

# also suprocesses should know:
export be_dir="$CONDA_PREFIX/bin/app/environ/bash"
# this one we keep, maybe useful for others outside us:
export be_bashenvs_known="${bashenvs_known:-}"

.be_std_bash_activations () {
    for i in "/etc/bash.bashrc" "$HOME/.bashrc"; do
        test -e "$i" && source "$i"
    done
}

.be_make_us_known () {
    we_where_known=true # won't create activation function then
    [[ "$be_bashenvs_known" == *:$CONDA_PREFIX:* ]] && return 0
    bashenvs_known="$be_bashenvs_known:$CONDA_PREFIX:"
    we_where_known=false
}

.be_base_activations () {
    #conda_prefix="$1"
    .be_source_config "$conda_prefix"
    source "$be_dir/functions"
    source "$be_dir/aliases"
}

.be_source_config () {
    set -a
    local cp="$1" # might be set by config with some vars there unknown now
    local fn="$CONDA_PREFIX/be_config"
    test -e "$fn" && source "$fn"
    set +a
}

main () {
    # do what bashrc does:
    .be_std_bash_activations
    .be_make_us_known
    .be_base_activations


}

main


