# Initialize completions

# The following lines were added by compinstall
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' substitute 1
zstyle :compinstall filename "$HOME/.zshrc"

# load deno completions - commented out because it adds unreasonable lag to
# shell startup
#fpath=(~/.zsh/completions $fpath)

__linuxbrew_site_funcs=/home/linuxbrew/.linuxbrew/share/zsh/site-functions
if [[ -d "$__linuxbrew_site_funcs" ]] && ! (( $fpath[(Ie)$__linuxbrew_site_funcs] )); then
  fpath=("$__linuxbrew_site_funcs" $fpath)
fi

autoload -Uz compinit
compinit -u
# End of lines added by compinstall
