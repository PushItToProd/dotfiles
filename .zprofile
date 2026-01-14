# prevent duplicate path entries
typeset -U path

# Allow pasting code with comments into the prompt without annoying errors.
setopt interactive_comments

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
HOMEBREW_NO_ENV_HINTS=1

# nvm
if ! command -v nvm &>/dev/null; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# history settings
HISTFILE=~/.zsh_history
HISTSIZE=9999999
SAVEHIST=9999999
setopt appendhistory
setopt incappendhistory

# zsh-newuser-install
setopt extendedglob
unsetopt beep
bindkey -e

# via https://postgresqlstan.github.io/cli/zsh-run-help/
unalias run-help 2>/dev/null       # don't display err if already done
autoload -Uz run-help              # load the function
alias help=run-help                # optionally alias run-help to help
HELPDIR="/usr/share/zsh/$ZSH_VERSION/help"

# override pager. man defaults to 'less -sR'. I've added --ignore-case to make
# search nicer
export PAGER='less --squeeze-blank-lines --RAW-CONTROL-CHARS --ignore-case'

# cd settings
cdpath=($HOME $HOME/Code/projects)
setopt auto_cd

# bindings
bindkey "\e\eOD" backward-word
bindkey "\e\eOC" forward-word

# fix WORDCHARS to remove '/' so it doesn't break word splitting
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# location for my personal utilities
path+=("$HOME/bin")

path+=("$HOME/.local/bin")

# Go
path+=("$HOME/go/bin")

# aliases
alias python=python3
alias vlc='open -b org.videolan.vlc'

alias g=git
alias gc='git c'
alias gca='git ca'
alias gd='git d'
alias gd.='git d .'
alias gds='git ds'
alias gds.='git ds .'
alias gs='git s'
alias gs.='git s .'
alias gca='git ca'
alias gap='git ap'
alias gap.='git ap .'
alias glg='git lg'
alias glg.='git lg .'

alias printl='print -l'

__grep_flags='-I --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=venv'
alias grep="grep $__grep_flags"
alias fgrep="fgrep $__grep_flags"
alias egrep="egrep $__grep_flags"

export TWEEGO_PATH="$HOME/Code/scratch/twine/storyformats"

# Added by Toolbox App
export PATH="$PATH:/Users/joe/Library/Application Support/JetBrains/Toolbox/scripts"

# Python virtualenv
source "$HOME/dotfiles/.zsh.d/50-python-venv.zsh"
