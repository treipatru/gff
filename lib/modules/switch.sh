#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_switch () {
    FZF_DEFAULT_OPTS+="\
        --header 'Switch Git branch'\
    "

    git branch -a \
        | gfz_finder \
        | xargs git switch
}
