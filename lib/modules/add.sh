#!/usr/bin/env bash

. "${GFZ_FOLDER}/finder.sh"

gfz_add () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(git ls-files -d -m -o --exclude-standard --full-name )

    if [ -z "$GFZ_ITEMS" ]; then
       echo "Nothing to add, working tree clean";
       exit
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
        --bind 'ctrl-o:execute-silent(code --goto {1})' \
    "

    echo "$GFZ_ITEMS" \
        | gfz_finder --multi \
        | xargs git add --verbose
}
