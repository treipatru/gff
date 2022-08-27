#!/usr/bin/env bash

. "${GFZ_FOLDER}/finder.sh"

gfz_checkout () {
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
        --bind 'ctrl-o:execute-silent(code --goto {1})' \
    "

    git ls-files -d -m --full-name \
        | gfz_finder \
        | xargs git checkout
}