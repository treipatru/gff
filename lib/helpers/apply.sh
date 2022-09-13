#!/usr/bin/env bash

gff_apply () {
    local PATCH_FILES
    # Only files with _CHUNK_ in filename should be staged
    # TODO This should use the .patch extension
    PATCH_FILES=$(echo "$@" | awk '{
        for(i=1;i<=NF;i++) {
            if ($i ~ /\.patch$/) {
                print $i
            }
        }
    }')

    for PATCH_FILE in $PATCH_FILES; do
        git apply --cached < "$PATCH_FILE"
    done
}
