#!/usr/bin/env bash

# Switch between Ripgrep launcher mode (CTRL-R) and fzf filtering mode (CTRL-F)
RG_PREFIX="rg -g '!package-lock.json' --column --line-number --no-heading --color=always --smart-case "
# Accept a command parameter or null
INITIAL_QUERY="${*:-}"
# Read the results of FZF into an array
IFS=: read -ra FILES < <(
  FZF_DEFAULT_COMMAND="$RG_PREFIX $(printf %q "$INITIAL_QUERY")" \
  fzf-tmux --ansi \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --disabled --query "$INITIAL_QUERY" \
          --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
          --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(FZF> )+enable-search+clear-query+rebind(ctrl-r)" \
          --bind "ctrl-r:unbind(ctrl-r)+change-prompt(RG> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)" \
          --prompt 'RG> ' \
          --delimiter : \
          --header '╱ CTRL-R (Ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'up,80%,border-bottom,+{2}+3/3,~3' \
          -p 90%,90%
)

[ -n "${FILES[0]}" ] && code --goto "${FILES[0]}:${FILES[1]}:${FILES[2]}"
# --bind "enter:execute-silent(code '${FILES[0]}' {+})+down" \
