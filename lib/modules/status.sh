#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_status () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(git status -s)

    if [ -z "$GFZ_ITEMS" ]; then
        gfz_emit_error 7
    fi

    FZF_DEFAULT_OPTS+="\
        --header 'Toggle staged (TAB) | Commit (Enter)' \
        --preview 'delta \
            --no-gitconfig \
            --file-style=\"omit\" \
            --hunk-header-style=\"\" \
            --line-numbers \
            <(git show HEAD:{2}) \
            {2} ' \
        --preview-window up,border-bottom,80%
        --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {2})' \
        --bind 'tab:execute-silent(gfz h_toggle_staged {2})+reload(git status -s)+down' \
    "

    echo "$GFZ_ITEMS" \
        | gfz_finder \
        | xargs gfz h_commit
    # h_commit doesn't need args but we use xargs to wait for fzf to finish
    # binding enter to `:execute-silent(gfz h_commit) causes the tmux popup to bug
}
