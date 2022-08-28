#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_switch () {
    local BRANCHES
    local CURRENT_BRANCH
    local PARAM
    PARAM=$1
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/heads | rg -v "$CURRENT_BRANCH")

    if [[ $PARAM == "-" ]];then
        git switch -
        exit 0
    fi

    FZF_DEFAULT_OPTS+="\
        --bind 'enter:replace-query+print-query' \
        --header 'On ${CURRENT_BRANCH} | Switch to... ' \
        --query=${PARAM} \
    "

    echo "$BRANCHES" \
        | gfz_finder \
        | xargs gfz h_create_or_switch_branch
}
