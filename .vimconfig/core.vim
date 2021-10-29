filetype on
filetype plugin on
syntax on
set noexrc  " disable per-directory .vimrc
set modeline
set modelines=5
set visualbell t_vb = " disable visual bell
set timeoutlen=300
set wrap linebreak
set ignorecase smartcase
set showcmd
set laststatus=2
set nohlsearch
set nofoldenable
set scrolloff=5
set number
set background=dark
colorscheme darkblue

set colorcolumn=80

" highlight the line where the cursor is in grey
" hi CursorLine cterm=NONE ctermbg=DarkBlue guibg=DarkBlue
set cursorline

" highlight trailing whitespace
hi ExtraWhitespace ctermbg=darkgreen guibg=lightgreen
match ExtraWhitespace /\s\+\%#\@<!$/

set backspace=indent,eol,start
set history=50
set ruler
set showcmd
set incsearch

" indent with 2 spaces
set expandtab
set shiftwidth=2
set softtabstop=2

" enable mouse support
if has('mouse')
  set mouse=a
endif

"" file browser config
let g:netrw_liststyle = 3 " show list in tree view
let g:netrw_banner = 0 " no useless banner
" let g:netrw_browse_split = 4 " open files in a new tab
let g:netrw_winsize = 25
let g:netrw_list_hide= '.*\.swp$,.*\.pyc,.env,.git'

" auto open browser
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END
"
" augroup netrw_close
"   autocmd!
"   autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "netrw"|q|endif
" augroup END
"
"
autocmd FileType markdown setlocal ts=4 sts=4 sw=4 expandtab
