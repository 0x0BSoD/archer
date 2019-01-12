#!/bin/bash
OPTIND=1
config_file=""
verbose=0

show_help () {
    echo "-f config file for silent install"
}

while getopts "h?f:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    f)  config_file=$OPTARG
        if [[ -r ${config_file} ]]
            then
                export SILENT=1
                export CONFIG_FILE=${config_file}
            else
                echo "Config not found"
                exit 1
            fi
        ;;
    *)
        echo "Interactive run"
        ;;
    esac
done
shift $((OPTIND-1))
[[ "${1:-}" = "--" ]] && shift

if [[ ${verbose} == 1 ]]
then
    export VERBOSE_INST=1
fi