#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_checkout () {
    local FZF_INPUT FZF_OUTPUT

    FZF_INPUT=$(git ls-files -d -m --full-name | uniq)

    if [ -z "$FZF_INPUT" ]; then
        gfz_emit_error 8
    fi

    FZF_OUTPUT=$(echo "$FZF_INPUT" \
        | fzf-tmux \
            -p 90%,90% \
            --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {1})' \
            --header-first \
            --header 'Checkout modified files' \
            --multi \
            --preview 'bat \
                --diff \
                --diff-context=3 \
                --style numbers,changes \
                --color=always \
                {} \
                | head -500' \
            --preview-window up,border-bottom,80%
    )


    if [[ -z $FZF_OUTPUT ]]; then
        exit 0
    fi

    echo "$FZF_OUTPUT" | xargs git checkout
}
