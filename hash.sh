#!/bin/bash

function debecho () { [[ ! -z "${DEBUG}" ]] && printf '%s\n' "${1}" >&2 ; }

function hash_create () {   ## hashname
[[ ! 1 -eq $# ]] && { debecho "assertion failed at: ${LINENO}" ; exit 99 ; }

local keys_name="${1}_keys"                                 # generate name for keys array
local values_name="${1}_values"                             # generate name for values array

eval $keys_name=\(\)                                        # generate empty keys array
eval $values_name=\(\)                                      # generate empty values array
}

function hash_add () {  ## hashname, key, value
[[ ! 3 -eq $# ]] && { debecho "assertion failed at: ${LINENO}" ; exit 99 ; }

local keys_name="${1}_keys"                                 # generate name for keys array
local values_name="${1}_values"                             # generate name for values array

eval $keys_name+=\( \"${2}\" \)                             # add item to the array
eval $values_name+=\( \"${3}\" \)
}

function hash_get_value () {    ## hashname, key
[[ ! 2 -eq $# ]] && { debecho "assertion failed at: ${LINENO}" ; exit 99 ; }

local keys_name="${1}_keys"                                 # generate name for keys array
local values_name="${1}_values"                             # generate name for values array

eval keys=\( \"\${$keys_name[@]}\" \)                       # generate array with items from input array
eval values=\( \"\${$values_name[@]}\" \)                   # generate array with items from input array

for i in ${!keys[*]} ; do
    if [[ "${keys[$i]}" == "${2}" ]] ; then
        printf '%s' "${values[$i]}"
        break
    fi
done
}

function hash_write () {    ## hashname, filename 
[[ ! 2 -eq $# ]] && { debecho "assertion failed at: ${LINENO}" ; exit 99 ; }

touch "${2}" ; [[ ! ( -f "${2}" && -w "${2}" ) ]] && { printf 'invalid filename %s\n' "${2}" ; return 1 ; }

local keys_name="${1}_keys"                                 # generate name for keys array
local values_name="${1}_values"                             # generate name for values array

eval keys=\( \"\${$keys_name[@]}\" \)                       # generate array with items from input array
eval values=\( \"\${$values_name[@]}\" \)                   # generate array with items from input array

IFS=',' ; printf '%s\n' "${keys[*]}" > "${2}"               # write array items separated by comma (,)
IFS=',' ; printf '%s\n' "${values[*]}" >> "${2}"            # write array items separated by comma (,)
}

function hash_read () { ## hashname, filename
[[ ! 2 -eq $# ]] && { debecho "assertion failed at: ${LINENO}" ; exit 99 ; }

[[ ! ( -f "${2}" && -r "${2}" ) ]] && { printf 'invalid filename %s\n' "${2}" ; return 1 ; }

IFS=',' ; head -n 1 "${2}" | read -a keys
IFS=',' ; tail -n 1 "${2}" | read -a values

local keys_name="${1}_keys"                                 # generate name for keys array
local values_name="${1}_values"                             # generate name for values array

eval $keys_name=\( \"\${keys[@]}\" \)                       # generate array with items from input array
eval $values_name=\( \"\${values[@]}\" \)                   # generate array with items from input array
}

DEBUG=on

hash_create foo
hash_add foo k v
hash_add foo strange\ key 1999
hash_add foo 1 "one"
hash_add foo 2 "number two"
hash_add foo key value\ with\ spaces 
hash_add foo mykey myvalue

echo $(hash_get_value foo mykey)
echo $(hash_get_value foo key)
echo $(hash_get_value foo 2)
echo $(hash_get_value foo "strange key")

hash_write foo myfile


hash_read bar myfile

echo $(hash_get_value bar mykey)
echo $(hash_get_value bar key)
echo $(hash_get_value bar 2)
echo $(hash_get_value bar "strange key")
