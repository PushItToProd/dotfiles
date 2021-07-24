# via 3.6 here: https://zsh.sourceforge.io/FAQ/zshfaq03.html
set_term_title_to_pwd() {
  [[ -t 1 ]] || return
  case $TERM in
    sun-cmd) print -Pn "\e]l%~\e\\"
      ;;
    *xterm*|rxvt|(dt|k|E)term) print -Pn "\e]2;%~\a"
      ;;
  esac
}
set_term_title_to_pwd  # run immediately when we're initializing
chpwd_functions+=(set_term_title_to_pwd)
