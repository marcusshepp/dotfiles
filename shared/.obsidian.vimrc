" Basic settings
" The leader key needs special handling in Obsidian
unmap <Space>

" Exit insert mode with jj
inoremap jj <Esc>

" Clear search highlighting with Escape
nnoremap <Esc> :nohl<CR>

" Enable relative line numbers
set number
set relativenumber

" Quick switcher (search notes) - using Space directly instead of leader
exmap searchByName obcommand switcher:open
nmap <Space>ff :searchByName<CR>

" Follow link under cursor with gd
exmap followLink obcommand editor:follow-link
nmap gd :followLink<CR>

" Insert new lines without entering insert mode
nnoremap <Space>o o<Esc>
nnoremap <Space>O O<Esc>

" Format entire document
nnoremap <Space>= gg=G<C-o>

" Copy/paste entire buffer
nnoremap <Space>p ggVG"+p
nnoremap <Space>y ggVG"+y

" Print current working directory
nnoremap <Space>cwd :echo expand('%:p:h')<CR>
