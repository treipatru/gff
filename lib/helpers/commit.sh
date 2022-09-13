#!/usr/bin/env bash

gff_commit () {
    local STATUS
    STATUS=$(git diff --name-only --cached)

    if [[ -z "$STATUS" ]]; then
       gff_emit_error 6
    else
        git commit --verbose
    fi
}
