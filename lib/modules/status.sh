#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_status () {
    local FZF_INPUT
    local FZF_OUTPUT

    FZF_INPUT=$(gfz h_get_repo_status)
    if [ -z "$FZF_INPUT" ]; then
        gfz_emit_error 7
    fi

    FZF_OUTPUT=$( echo "$FZF_INPUT" \
        | fzf-tmux \
            -p 90%,90% \
            --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {2})' \
            --bind 'tab:execute-silent(gfz h_toggle_staged {2})+reload(gfz h_get_repo_status)+down' \
            --header-first \
            --header 'Toggle staged (Tab) | Commit (Enter)' \
            --preview 'delta \
                --no-gitconfig \
                --file-style=\"omit\" \
                --hunk-header-style=\"\" \
                --line-numbers \
                <(git show HEAD:{2}) \
                {2} ' \
            --preview-window up,border-bottom,80% \
            --with-nth=1,2
    )


    if [[ -z $FZF_OUTPUT ]]; then
        exit 0
    fi

    gfz h_commit "$FZF_OUTPUT"
}