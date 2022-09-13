#!/usr/bin/env bash

gff_toggle_staged () {
    local FILE STATUS

    FILE=$1
    STATUS=$(git status -s "${FILE}" | head -c2)

    if [[ ${STATUS:0:2} == "??" ]] ; then
        git add "$FILE"
    fi

    if [[ ${STATUS:0:1} == " " ]] ; then
        git add "$FILE"
    fi

    if [[ ${STATUS:1:2} == " " ]] ; then
        git reset --quiet HEAD "$FILE"
    fi
}
