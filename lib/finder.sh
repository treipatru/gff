#!/usr/bin/env bash

gfz_finder () {
    FZF_DEFAULT_OPTS+="\
        --header-first \
    "

    fzf-tmux \
        -p 90%,90%
}
