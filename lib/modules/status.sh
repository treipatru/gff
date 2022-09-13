#!/usr/bin/env bash

. "${GFF_FOLDER}/helpers/emit_error.sh"

gff_status () {
    local FZF_INPUT FZF_OUTPUT

    FZF_INPUT=$(gff h_get_repo_status)
    if [ -z "$FZF_INPUT" ]; then
        gff_emit_error 7
    fi

    FZF_OUTPUT=$( echo "$FZF_INPUT" \
        | fzf-tmux \
            -p 90%,90% \
            --bind 'ctrl-o:execute-silent(gff h_open_in_editor {2})' \
            --bind 'tab:execute-silent(gff h_toggle_staged {2})+reload(gff h_get_repo_status)+down' \
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

    gff h_commit "$FZF_OUTPUT"
}
