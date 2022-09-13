#!/usr/bin/env bash

gff_open_in_editor () {
    local FILE LINE COLUMN

    FILE=$1
    LINE=$2
    COLUMN=$3

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
            gff_emit_error 9
    esac
}
