set_term_title() {
  __term_title="$*"
  case $TERM in
    sun-cmd) print -n "\e]l$__term_title\e\\"
      ;;
    *xterm*|rxvt|(dt|k|E)term) print -n "\e]2;$__term_title\a"
      ;;
  esac
}

# via 3.6 here: https://zsh.sourceforge.io/FAQ/zshfaq03.html
set_term_title_to_pwd() {
  [[ -t 1 ]] || return
  set_term_title "$(print -P %~)"
}
set_term_title_to_pwd  # run immediately when we're initializing
chpwd_functions+=(set_term_title_to_pwd)

set_term_title_to_cmd() {
  set_term_title "$1"
}
preexec_functions+=(set_term_title_to_cmd)

precmd_functions+=(set_term_title_to_pwd)
