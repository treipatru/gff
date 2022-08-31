#!/usr/bin/env bash

gfz_emit_error () {
    local ERROR_CODE
    local ERROR_STR
    ERROR_CODE=$1

    case $ERROR_CODE in
        "1")
            ERROR_STR="Git is not installed"
            ;;
        "2")
            ERROR_STR="FZF is not installed"
            ;;
        "3")
            ERROR_STR="Bat is not installed"
            ;;
        "4")
            ERROR_STR="RG is not installed"
            ;;
        "5")
            ERROR_STR="Not in git repo"
            ;;
        "6")
            ERROR_STR="Nothing to commit, staging area empty"
            ;;
        "7")
            ERROR_STR="Nothing to add, working tree clean"
            ;;
        "8")
            ERROR_STR="Nothing to checkout, working tree clean"
            ;;
        "9")
            ERROR_STR="Unknown GFZ editor"
            ;;
        "10")
            ERROR_STR="Neither \$EDITOR not \$GFZ_EDITOR are defined. You need at least one in your environment"
            ;;
        "11")
            ERROR_STR="Delta is not installed"
            ;;
        *)
            ERROR_STR="GFZ encountered an error"
    esac

    echo "» ${ERROR_STR}"
    exit 1
}

gfz_check_environment () {
    # Check for required software
    command -v git >/dev/null 2>&1 || gfz_emit_error 1
    command -v fzf >/dev/null 2>&1 || gfz_emit_error 2
    command -v bat >/dev/null 2>&1 || gfz_emit_error 3
    command -v rg  >/dev/null 2>&1 || gfz_emit_error 4
    command -v delta  >/dev/null 2>&1 || gfz_emit_error 11

    if [[ -z "$EDITOR" && -z "$GFZ_EDITOR" ]]; then
        gfz_emit_error 10
    fi

    # Check for Git repository
    local DIR_CODE
    DIR_CODE=$(git -C . rev-parse 2>/dev/null; echo $?)
    if [ "$DIR_CODE" -eq "128" ]; then
       gfz_emit_error 5
    fi

    # Finally apply some FZF options if the user has none
    if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
        export FZF_DEFAULT_OPTS="
            --bind 'ctrl-n:preview-half-page-down' \
            --bind 'ctrl-p:preview-half-page-up' \
            --no-bold \
            --prompt='░ ' \
            --marker='•' \
            --pointer='▓'
        "
    fi
}

gfz_toggle_staged () {
    local FILE
    local STATUS

    FILE=$1
    STATUS=$(git status -s "${FILE}" | head -c2)

    if [[ ${STATUS:0:2} == "??" ]] ; then
        git add "$FILE"
    fi

    if [[ ${STATUS:0:1} == " " ]] ; then
        git add "$FILE"
    fi

    if [[ ${STATUS:1:2} == " " ]] ; then
        git reset --quiet HEAD "$FILE"
    fi
}

gfz_commit () {
    local STATUS
    STATUS=$(git diff --name-only --cached)

    if [[ -z "$STATUS" ]]; then
       gfz_emit_error 6
    else
        git commit --verbose
    fi
}

has_branch_upstream () {
    git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"
}

gfz_finder () {
    FZF_DEFAULT_OPTS+="\
        --header-first \
        --bind backward-eof:abort \
    "

    fzf-tmux \
        -p 90%,90%
}

gfz_open_in_editor () {
    local FILE
    local LINE
    local COLUMN

    FILE=$1
    LINE=$2
    COLUMN=$3

    case $GFZ_EDITOR in
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
            gfz_emit_error 9
    esac
}

gfz_create_or_switch_branch () {
    local BRANCH
    BRANCH=$1

    if [[ -z $(git branch --list "${BRANCH}") ]]; then
        git branch "$BRANCH"
        git switch "$BRANCH"
        exit 1
    fi

    git switch "$BRANCH"
}

gfz_get_file_status () {
    local GIT_OUTPUT
    local FILE
    local STATUS
    GIT_OUTPUT=$1
    STATUS=${GIT_OUTPUT:0:2}
    FILE=${GIT_OUTPUT:3}
    ICON=" "

    # If file is staged just show an icon
    if [[ ${STATUS:0:1} =~ A|D|M|R && ${STATUS:1:2} == " " ]]; then
        ICON="✓"
    fi

    # If unstaged just show status
    if [[ ${STATUS:0:1} == " "  && ${STATUS:1:2} =~ A|D|M ]]; then
        ICON=${STATUS:1:2}
    fi

    # Special status for untracked
    if [[ ${STATUS:0:2} == "??" ]]; then
        ICON="?"
    fi

    echo "${ICON} ${FILE} ${STATUS}"
}

gfz_get_repo_status () {
    git status -s --untracked-files=all \
        | while IFS= read -r LINE; do
            gfz h_get_file_status "$LINE"
        done
}


gfz_apply () {
    local PATCH_FILES
    # Only files with _CHUNK_ in filename should be staged
    PATCH_FILES=$(echo "$@" | awk '{
        for(i=1;i<=NF;i++) {
            if ($i ~ /[_CHUNK_]/) {
                print $i
            }
        }
    }')

    for PATCH_FILE in $PATCH_FILES; do
        git apply --cached < "$PATCH_FILE"
    done
}

gfz_get_diff_region () {
    local CHUNK_HEADER
    local REMOVED
    local ADDED

    CHUNK_HEADER=$1
    # Remove minus sign from start of string
    REMOVED=$(echo "$CHUNK_HEADER" | awk '{print substr($2,2)}')
    # Remove plus sign from start of string, add number of modified lines to start of added
    ADDED=$(echo "$CHUNK_HEADER" | awk '{print substr($3,2)}' | awk -F "," '{print $1+$2}')

    # Return diff region: "First line" "Last line"
    echo "${REMOVED%%,*} ${ADDED}"
}