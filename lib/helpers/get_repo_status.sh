#!/usr/bin/env bash

gff_get_repo_status () {
    git status -s --untracked-files=all \
        | while IFS= read -r LINE; do
            gff h_get_file_status "$LINE"
        done
}
