#!/usr/bin/env bash

# Set some FZF default config if the user has none
if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
    export FZF_DEFAULT_OPTS="
        --bind 'ctrl-n:preview-half-page-down' \
        --bind 'ctrl-p:preview-half-page-up' \
        --no-bold \
        --prompt='░ ' \
        --marker='•' \
        --pointer='▓'
    "
fi
