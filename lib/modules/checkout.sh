#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_checkout () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(git ls-files -d -m --full-name)

    if [ -z "$GFZ_ITEMS" ]; then
        gfz_emit_error 8
    fi

    FZF_DEFAULT_OPTS+=" \
        --multi \
        --header 'Checkout modified files' \
        --preview 'bat \
            --diff \
            --diff-context=3 \
            --style numbers,changes \
            --color=always \
            {} \
            | head -500' \
        --preview-window up,border-bottom,80%
        --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {1})' \
    "

    echo "$GFZ_ITEMS" \
        | gfz_finder \
        | xargs git checkout
}