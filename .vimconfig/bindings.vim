" custom mappings
let mapleader = " "

" open vimrc
nnoremap <leader>ev :tabe $MYVIMRC<cr>
" source vimrc
nnoremap <leader>sv :source $MYVIMRC<cr>

" close HTML tags
inoremap <C-Space> <C-X><C-O>

" disable arrow keys
" inoremap <up> <nop>
" inoremap <down> <nop>
" inoremap <left> <nop>
" inoremap <right> <nop>
" noremap <up> <nop>
" noremap <down> <nop>
" noremap <left> <nop>
" noremap <right> <nop>

" easier navigation to start and end of line
noremap HH 0
noremap H ^
noremap L $
noremap J <C-D>
noremap K <C-U>

" force using nicer shortcuts
" nnoremap $ <nop>
" nnoremap ^ <nop>

" easier way to leave edit mode
inoremap jk <esc>
" inoremap <esc> <nop>
vnoremap jk <esc>

" jump to end of file without caps
noremap gh G
" noremap G <nop>

" easily open file
nnoremap <Leader>o :tabe<Space>

" write and quit more easily
nnoremap <Leader>q :q<cr>
nnoremap <Leader>wq :wq<cr>
nnoremap <Leader>w :w<cr>
nnoremap <Leader>Q :q!<cr>

nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" tab switching
nnoremap <Leader>a gT
nnoremap <Leader>d gt

" easier pane switching
nnoremap <Leader>m <C-w>

" quick navigation between tabs
nnoremap <Leader><Leader>h gT
nnoremap <Leader><Leader>l gt

" quick vertical navigation between viewports
nnoremap <Leader><Leader>j <C-w>j
nnoremap <Leader><Leader>k <C-w>k

command Wq wq
