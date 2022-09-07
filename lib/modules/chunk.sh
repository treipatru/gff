#!/usr/bin/env bash

. "${GFZ_FOLDER}/helpers.sh"

gfz_chunk () {
    local GFZ_DIFF_FOLDER GFZ_ITEMS FZF_ITEMS_FILE FZF_SELECTION
    GFZ_ITEMS=$(git diff --name-only --diff-filter=MA)
    GFZ_DIFF_FOLDER="/tmp/gfz_diff"
    FZF_ITEMS_FILE="${GFZ_DIFF_FOLDER}/FZF_ITEMS"

    if [ -z "$GFZ_ITEMS" ]; then
        gfz_emit_error 7
    fi

    # 1 create a diff folder if it doesn't exist
    if [ ! -d $GFZ_DIFF_FOLDER ]; then
        mkdir $GFZ_DIFF_FOLDER
    else
        rm -rf $GFZ_DIFF_FOLDER
        mkdir $GFZ_DIFF_FOLDER
    fi
    touch $FZF_ITEMS_FILE

    # 2 iterate through status items and
    echo "$GFZ_ITEMS" | while IFS= read -r LINE; do
        local FOLDER FILE
        FOLDER="${GFZ_DIFF_FOLDER}/$(echo "$LINE" | sed -r 's/[/. ]+/-/g')"
        FILE=$(basename "$LINE")

        # Generate a folder for each file
        mkdir "$FOLDER"
        # Generate a main diff file for each file
        git diff-files --patch --diff-algorithm=minimal --output="$FOLDER"/"$FILE" "$LINE"
        # Generate patch files for each patch

        rg '^@@.*@@' --line-number "$FOLDER"/"$FILE" | while IFS= read -r LINE2; do
            local CHUNK_FILE CHUNK_LINE NEXT_LINE DIFF_REGION
            # Generate a unique file identifier from chunk meta and append that to $FILE
            # 5:@@ -1,20 +1,50 @@ > 120150
            CHUNK_FILE="${FOLDER}/${FILE}_CHUNK_$(echo "$LINE2" | awk '{print $2,$3}' | sed 's/[+, -]//g')"
            # Get chunk start line
            CHUNK_LINE=${LINE2%%:*}
            # Get first line of chunk content
            NEXT_LINE=$(($CHUNK_LINE + 1))

            echo "${LINE} ${CHUNK_FILE} ${LINE2}" >> $FZF_ITEMS_FILE

            # Write file header
            # Git output is always 4 lines
            head -4 "$FOLDER"/"$FILE" > "$CHUNK_FILE"

            # Write the diff header first
            echo "${LINE2#*:}" >> "$CHUNK_FILE"
            # Then the rest before next diff header
            tail -n +"$NEXT_LINE" "$FOLDER"/"$FILE" | while IFS= read -r LINE3; do
                if [[  "$LINE3" == *@@ || $LINE3 ==  @@* ]]; then
                    break
                else
                    echo "$LINE3" >> "$CHUNK_FILE"
                fi
            done
        done
    done

    FZF_SELECTION=$(cat $FZF_ITEMS_FILE \
        | fzf-tmux \
            -p 90%,90% \
            --bind 'ctrl-o:execute-silent(gfz h_open_in_editor {1})' \
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
            --with-nth=1,3 \
        )

    if [[ -z $FZF_SELECTION ]]; then
        exit 0
    fi

    echo "$FZF_SELECTION" \
        | xargs gfz h_apply \
        && gfz h_commit
}
