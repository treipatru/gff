#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_status () {
    local GFZ_ITEMS
    GFZ_ITEMS=$(gfz h_get_repo_status)

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
        --bind 'tab:execute-silent(gfz h_toggle_staged {2})+reload(gfz h_get_repo_status)+down' \
        --with-nth=1,2
    "

    echo "$GFZ_ITEMS" \
        | gfz_finder \
        | xargs gfz h_commit
    # FIX
    # h_commit doesn't need args but we use xargs to wait for fzf to finish
    # binding enter to `:execute-silent(gfz h_commit) causes the tmux popup to bug
}
