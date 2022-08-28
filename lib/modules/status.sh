#!/usr/bin/env bash

. "${GFZ_FOLDER}/finder.sh"

gfz_status () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(git status -s)

    if [ -z "$GFZ_ITEMS" ]; then
       echo "nothing to commit, working tree clean";
       exit
    fi

    FZF_DEFAULT_OPTS+="\
        --header 'Toggle staged (TAB) | Commit (Enter)' \
        --preview 'bat \
            --style numbers,changes \
            --color=always \
            {2} \
            | head -500' \
        --preview-window up,border-bottom,80%
        --bind 'ctrl-o:execute-silent(code --goto {2})' \
        --bind 'enter:execute(gfz h_commit)+abort' \
        --bind 'tab:execute-silent(gfz h_toggle_staged {2})+reload(git status -s)+down' \
    "

    echo "$GFZ_ITEMS" \
        | gfz_finder
}
