#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_add () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(git ls-files -d -m -o --exclude-standard --full-name )

    if [ -z "$GFZ_ITEMS" ]; then
        gfz_emit_error 7
    fi

    FZF_DEFAULT_OPTS+=" \
        --multi \
        --header 'Stage files' \
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
        | gfz_finder --multi \
        | xargs git add --verbose
}
