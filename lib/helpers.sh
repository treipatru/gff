#!/usr/bin/env bash

gfz_check_environment () {
    # Check for required software
    command -v git >/dev/null 2>&1 || { echo >&2 "» Git is not installed. Aborting."; exit 1; }
    command -v fzf >/dev/null 2>&1 || { echo >&2 "» FZF is not installed. Aborting."; exit 1; }
    command -v bat >/dev/null 2>&1 || { echo >&2 "» Bat is not installed. Aborting."; exit 1; }
    command -v rg  >/dev/null 2>&1 || { echo >&2 "» RG is not installed. Aborting."; exit 1; }

    # Check for Git repository
    local DIR_CODE
    DIR_CODE=$(git -C . rev-parse 2>/dev/null; echo $?)
    if [ "$DIR_CODE" -eq "128" ]; then
       echo " » Not in git repo";
       exit 1;
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
        echo "» No changes staged. Aborting."
        exit
    else
        git commit --verbose
    fi
}

has_branch_upstream () {
    git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"
}