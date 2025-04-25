" Basic settings
let mapleader = " "
let maplocalleader = "\\"

" Exit insert mode with jj
inoremap jj <Esc>

" Clear search highlighting with Escape
nnoremap <Esc> :nohl<CR>

" Indentation settings
set smartindent
set autoindent
set tabstop=4
set expandtab
set shiftwidth=4

" Insert new lines without entering insert mode
nnoremap <leader>o o<Esc>
nnoremap <leader>O O<Esc>

" Format entire document
nnoremap <leader>= gg=G<C-o>

" Copy/paste entire buffer
nnoremap <leader>p ggVG"+p
nnoremap <leader>c ggVG"+y

" Print current working directory
nnoremap <leader>cwd :echo expand('%:p:h')<CR>

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand app:go-back
nmap <C-o> :back<CR>
exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>

" Quick switcher (search notes)
exmap searchByName obcommand switcher:open
nmap <leader>ff :searchByName<CR>

" Follow link under cursor with gd
exmap followLink obcommand editor:follow-link
nmap gd :followLink<CR>
