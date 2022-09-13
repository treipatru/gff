#!/usr/bin/env bash

gff_emit_error () {
    local ERROR_CODE ERROR_STR
    ERROR_CODE=$1

    case $ERROR_CODE in
        "1")  ERROR_STR="Git is not installed" ;;
        "2")  ERROR_STR="FZF is not installed" ;;
        "3")  ERROR_STR="Bat is not installed" ;;
        "4")  ERROR_STR="RG is not installed" ;;
        "5")  ERROR_STR="Not in git repo" ;;
        "6")  ERROR_STR="Nothing to commit, staging area empty" ;;
        "7")  ERROR_STR="Nothing to add, working tree clean" ;;
        "8")  ERROR_STR="Nothing to checkout, working tree clean" ;;
        "9")  ERROR_STR="Unknown GFF editor" ;;
        "10") ERROR_STR="Neither \$EDITOR nor \$GFF_EDITOR are defined. You need at least one in your environment" ;;
        "11") ERROR_STR="Delta is not installed" ;;
        *)    ERROR_STR="GFF encountered an error"
    esac

    printf "» ${ERROR_STR} %s" ${@:2}
    exit 1
}
