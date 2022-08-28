#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_rg () {
    local INPUT
    local RG_PREFIX
    INPUT=$1

    RG_PREFIX="rg \
        -g '!package-lock.json' \
        --column \
        --line-number \
        --no-heading \
        --color=always \
        --smart-case "

    FZF_DEFAULT_OPTS+="\
        --ansi \
        --disabled --query \"$INPUT\" \
        --prompt '░RG ' \
        --delimiter : \
        --header-first \
        --header 'Find with RG (ctrl+r) | Filter with FZF (ctrl+f)' \
        --color 'hl:-1:underline,hl+:-1:underline:reverse' \
        --preview 'bat \
            --color=always --style numbers,changes {1} \
            --highlight-line {2}' \
        --preview-window 'up,80%,border-bottom,+{2}+3/3' \
        --bind 'change:reload:sleep 0.1; $RG_PREFIX {q} || true' \
        --bind 'ctrl-f:unbind(change,ctrl-f)+change-prompt(░FZF )+enable-search+clear-query+rebind(ctrl-r)' \
        --bind 'ctrl-r:unbind(ctrl-r)+change-prompt(░RG )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)' \
        --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {1} {2} {3})' \
    "
    FZF_DEFAULT_COMMAND="$RG_PREFIX $(printf %q "$INPUT")"

    gfz_finder \
    | awk -F ":" '{print $1, $2, $3}' \
    | xargs gfz h_open_in_editor
}
