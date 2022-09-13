#!/usr/bin/env bash

. "${GFF_FOLDER}/helpers.sh"

gff_switch () {
    local FZF_OUTPUT CMD_PARAM CURRENT_BRANCH

    CMD_PARAM=$1
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    FZF_INPUT=$(git for-each-ref --format='%(refname:short)' refs/heads | rg -v "$CURRENT_BRANCH")

    if [[ $CMD_PARAM == "-" ]];then
        git switch -
        exit 0
    fi

    FZF_OUTPUT=$(echo "$FZF_INPUT" \
        | fzf-tmux \
            -p 90%,90% \
            --bind "enter:replace-query+print-query" \
            --header-first \
            --header "On ${CURRENT_BRANCH} | Switch to... " \
            --query="${CMD_PARAM}" \
    )

    gff h_create_or_switch_branch "$FZF_OUTPUT"
}
