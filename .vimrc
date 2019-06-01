set nocompatible

source ~/.vimconfig/core.vim
source ~/.vimconfig/bindings.vim
source ~/.vimrc.local.vim

let os = substitute(system('uname'), "\n", "", "")
if os == "Darwin"
  source ~/.vimconfig/mac.vim
elseif os == "Linux"
  source ~/.vimconfig/linux.vim
endif
