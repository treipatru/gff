#!/usr/bin/env bash

gfz_checkout () {
    git ls-files -d -m --full-name \
        | fzf-tmux \
            -p 90%,90% \
            --multi \
            --preview 'bat \
                --diff \
                --diff-context=2 \
                --style numbers,changes \
                --color=always {} \
                | head -500' \
            --preview-window up,border-bottom,80% \
        | xargs git checkout
}

