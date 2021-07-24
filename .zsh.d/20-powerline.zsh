# -*- mode: sh -*-
[[ "$DEBUG" == "1" ]] && echo "Configuring powerline"

function powerline_precmd() {
    # Hack required for ~/bin/powerline_segments/wrap.py to properly wrap text.
    read TERM_ROWS TERM_COLUMNS < <(stty size)
    export TERM_ROWS TERM_COLUMNS
    PS1="$(powerline-shell --shell zsh $?)"
}

function install_powerline_precmd() {
    for s in "${precmd_functions[@]}"; do
        if [ "$s" = "powerline_precmd" ]; then
            return
        fi
    done
    precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
    install_powerline_precmd
fi
