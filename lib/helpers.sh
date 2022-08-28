#!/usr/bin/env bash

gfz_emit_error () {
    local ERROR_CODE
    local ERROR_STR
    ERROR_CODE=$1

    case $ERROR_CODE in
        "1")
            ERROR_STR="Git is not installed"
            ;;
        "2")
            ERROR_STR="FZF is not installed"
            ;;
        "3")
            ERROR_STR="Bat is not installed"
            ;;
        "4")
            ERROR_STR="RG is not installed"
            ;;
        "5")
            ERROR_STR="Not in git repo"
            ;;
        "6")
            ERROR_STR="Nothing to commit, staging area empty"
            ;;
        "7")
            ERROR_STR="Nothing to add, working tree clean"
            ;;
        *)
            ERROR_STR="GFZ encountered an error"
    esac

    echo "» ${ERROR_STR}"
    exit 1
}

gfz_check_environment () {
    # Check for required software
    command -v git >/dev/null 2>&1 || gfz_emit_error 1
    command -v fzf >/dev/null 2>&1 || gfz_emit_error 2
    command -v bat >/dev/null 2>&1 || gfz_emit_error 3
    command -v rg  >/dev/null 2>&1 || gfz_emit_error 4

    # Check for Git repository
    local DIR_CODE
    DIR_CODE=$(git -C . rev-parse 2>/dev/null; echo $?)
    if [ "$DIR_CODE" -eq "128" ]; then
       gfz_emit_error 5
    fi

    # Finally apply some FZF options if the user has none
    if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
        export FZF_DEFAULT_OPTS="
            --bind 'ctrl-n:preview-half-page-down' \
            --bind 'ctrl-p:preview-half-page-up' \
            --no-bold \
            --prompt='░ ' \
            --marker='•' \
            --pointer='▓'
        "
    fi
}

gfz_toggle_staged () {
    local FILE
    local STATUS

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

gfz_commit () {
    local STATUS
    STATUS=$(git diff --name-only --cached)

    if [[ -z "$STATUS" ]]; then
       gfz_emit_error 6
    else
        git commit --verbose
    fi
}

has_branch_upstream () {
    git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"
}