#!/usr/bin/env bash

gff_get_file_status () {
    local GIT_OUTPUT FILE STATUS
    GIT_OUTPUT=$1
    STATUS=${GIT_OUTPUT:0:2}
    FILE=${GIT_OUTPUT:3}
    ICON=" "

    # If file is staged just show an icon
    if [[ ${STATUS:0:1} =~ A|D|M|R && ${STATUS:1:2} == " " ]]; then
        ICON="✓"
    fi

    # If unstaged just show status
    if [[ ${STATUS:0:1} == " "  && ${STATUS:1:2} =~ A|D|M ]]; then
        ICON=${STATUS:1:2}
    fi

    # Special status for untracked
    if [[ ${STATUS:0:2} == "??" ]]; then
        ICON="?"
    fi

    # Special status for modified and unstaged
    # TODO use better icon
    if [[ ${STATUS:0:2} == "MM" ]]; then
        ICON="⍻"
    fi

    echo "${ICON} ${FILE} ${STATUS}"
}
