#!/usr/bin/env bash

. "${GFF_FOLDER}/helpers/emit_error.sh"

gff_check_git_repo () {
    local DIR_CODE
    DIR_CODE=$(git -C . rev-parse 2>/dev/null; echo $?)

    if [ "$DIR_CODE" -eq "128" ]; then
       gff_emit_error 5
    fi
}
