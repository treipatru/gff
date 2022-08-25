#!/usr/bin/env bash

gfz_switch () {
    git branch -a \
        | fzf-tmux \
            -p 90%,90% \
        | xargs git switch
}
