#!/usr/bin/env bash

. "${GFF_FOLDER}/helpers.sh"

gfz_remove () {
    local FZF_INPUT FZF_OUTPUT

    FZF_INPUT=$(git ls-tree --full-tree -r --name-only HEAD)

    FZF_OUTPUT=$(echo "$FZF_INPUT" \
        | fzf-tmux \
            -p 90%,90% \
            --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {1})' \
            --header-first \
            --header 'Git rm files' \
            --multi \
            --preview 'bat \
                --style numbers,changes \
                --color=always \
                {1} \
                | head -500' \
            --preview-window up,border-bottom,80%
    )


    if [[ -z $FZF_OUTPUT ]]; then
        exit 0
    fi

    echo "$FZF_OUTPUT" | xargs git rm
}