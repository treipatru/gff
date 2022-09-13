#!/usr/bin/env bash

. "${GFF_FOLDER}/helpers/emit_error.sh"

gff_check_environment () {
    # Check for required software
    command -v git >/dev/null 2>&1 || gff_emit_error 1
    command -v fzf >/dev/null 2>&1 || gff_emit_error 2
    command -v bat >/dev/null 2>&1 || gff_emit_error 3
    command -v rg  >/dev/null 2>&1 || gff_emit_error 4
    command -v delta  >/dev/null 2>&1 || gff_emit_error 11

    if [[ -z "$EDITOR" && -z "$GFF_EDITOR" ]]; then
        gff_emit_error 10
    fi

    # Check for Git repository
    local DIR_CODE
    DIR_CODE=$(git -C . rev-parse 2>/dev/null; echo $?)
    if [ "$DIR_CODE" -eq "128" ]; then
       gff_emit_error 5
    fi
}
