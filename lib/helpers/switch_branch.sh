#!/usr/bin/env bash

gff_switch_branch () {
    local BRANCH
    BRANCH=$1

    # If no input just exit silently
    if [[ -z $BRANCH ]]; then
        exit 0
    fi

    if [[ -z $(git branch --list "${BRANCH}") ]]; then
        git branch "$BRANCH"
        git switch "$BRANCH"
        exit 1
    fi

    git switch "$BRANCH"
}

