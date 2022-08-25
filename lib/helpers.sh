#!/usr/bin/env bash

# User vars
GFZ_EDITOR="code"
GFZ_PREVIEW="bat --diff --diff-context=2 --style numbers,changes --color=always {} | head -500"

gfz_is_in_git_dir () {
    local DIR_CODE=$(git -C . rev-parse 2>/dev/null; echo $?)

    if [ "$DIR_CODE" -eq "128" ]; then
       echo "not in git repo";
       exit;
    fi
}

has_branch_upstream () {
    git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"
}

