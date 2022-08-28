#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_remove () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(git ls-tree --full-tree -r --name-only HEAD)

    FZF_DEFAULT_OPTS+="\
        --multi
        --header 'Git rm files' \
        --preview 'bat \
            --style numbers,changes \
            --color=always \
            {1} \
            | head -500' \
        --preview-window up,border-bottom,80%
        --bind 'ctrl-o:execute-silent(code --goto {1})' \
    "

    echo "$GFZ_ITEMS" \
        | gfz_finder \
        | xargs git rm
}
