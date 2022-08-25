#!/usr/bin/env bash

gfz_add () {
    git ls-files -d -m -o --exclude-standard --full-name \
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
        | xargs git add --verbose
}
