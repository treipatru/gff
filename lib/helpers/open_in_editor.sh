#!/usr/bin/env bash

gff_open_in_editor () {
    local FILE LINE COLUMN

    FILE=$1
    LINE=${2:-1}
    COLUMN=${3:-1}

    if [[ -z "$GFF_EDITOR" ]]; then
        GFF_EDITOR=$(basename "$EDITOR")
    fi

    case $GFF_EDITOR in
        "code")
            code --goto "$FILE":"$LINE":"$COLUMN"
            ;;
        "nvim")
            nvim "$FILE" +"$LINE"
            ;;
        "vim")
            vim +"'call cursor(${LINE},${COLUMN})" "$FILE"
            ;;
        *)
            gff_emit_error 9 $GFF_EDITOR
    esac
}
