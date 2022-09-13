#!/usr/bin/env bash

. "${GFF_FOLDER}/helpers.sh"

gff_chunk () {
    local ROOT_DIFF_FOLDER GIT_FILES FZF_ITEMS_FILE FZF_SELECTION
    GIT_FILES=$(git diff --name-only --diff-filter=MA)
    ROOT_DIFF_FOLDER="/tmp/gff_diff"
    FZF_ITEMS_FILE="${ROOT_DIFF_FOLDER}/FZF_ITEMS"

    if [ -z "$GIT_FILES" ]; then
        gff_emit_error 7
    fi

    rm -rf $ROOT_DIFF_FOLDER
    mkdir $ROOT_DIFF_FOLDER
    touch $FZF_ITEMS_FILE

    echo "$GIT_FILES" | while IFS= read -r GIT_FILE; do
        local DIFF_FILE
        DIFF_FILE="${ROOT_DIFF_FOLDER}/${GIT_FILE//[\/\. ]}/${GIT_FILE##*/}"

        # Make directory for each GIT_FILE and generate a main diff
        mkdir "${DIFF_FILE%\/*}"
        git diff-files --patch --diff-algorithm=minimal --output="$DIFF_FILE" "$GIT_FILE"

        # Generate patch files for each patch
        rg '^@@.*@@' --line-number "$DIFF_FILE" | while IFS= read -r CHUNK_HEADER; do
            local CHUNK_FILE NEXT_LINE CHUNK_INFO

            # Generate a unique file identifier from chunk data
            CHUNK_FILE="${DIFF_FILE}_${CHUNK_HEADER//[^0-9]}.patch"

            # Get first line of chunk content by adding 1 to the rg line
            NEXT_LINE=$((${CHUNK_HEADER%%:*} + 1))

            # Write patch file header. Git header and chunk data
            head -4 "$DIFF_FILE" > "$CHUNK_FILE"
            echo "${CHUNK_HEADER#*:}" >> "$CHUNK_FILE"

            # Then the rest before next diff header
            tail -n +"$NEXT_LINE" "$DIFF_FILE" | while IFS= read -r LINE3; do
                if [[  "$LINE3" == *@@ || $LINE3 ==  @@* ]]; then
                    break
                else
                    echo "$LINE3" >> "$CHUNK_FILE"
                fi
            done

            # Make chunk available to FZF search
            CHUNK_INFO=${CHUNK_HEADER#*@@}
            CHUNK_INFO=${CHUNK_INFO%%@@*}
            echo "${GIT_FILE} ${CHUNK_FILE} ${CHUNK_INFO}" >> $FZF_ITEMS_FILE
        done
    done

    FZF_SELECTION=$(cat $FZF_ITEMS_FILE \
        | fzf-tmux \
            -p 90%,90% \
            --bind 'ctrl-o:execute-silent(gff h_open_in_editor {1})' \
            --bind backward-eof:abort \
            --header 'Stage chunks' \
            --header-first \
            --multi \
            --preview 'bat \
                --style changes \
                --color=always \
                {2} \
                | head -500' \
            --preview-window up,border-bottom,80% \
            --with-nth=1,3,4 \
        )

    if [[ -z $FZF_SELECTION ]]; then
        exit 0
    fi

    echo "$FZF_SELECTION" \
        | xargs gff h_apply \
        && gff h_commit
}
