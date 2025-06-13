if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'mhinz/vim-startify'
call plug#end()
syntax on
set number
set relativenumber
set cursorline
set scrolloff=8
set hidden
set wrap!
set encoding=utf-8
set incsearch
set hlsearch
set ignorecase
set smartcase
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set splitright
set splitbelow
set undofile
set updatetime=300
set signcolumn=yes
if !empty(glob('~/.vim/plugged/catppuccin'))
    colorscheme catppuccin_mocha
    let g:airline_theme = 'catppuccin_mocha'
endif
let g:airline_powerline_fonts = 1
let g:NERDTreeWinPos = "left"
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:startify_custom_header = [
            \ 'Hello, student.',
            \ 'Welcome to Vim - the only editor that is probably installed on your toaster.',
            \ ]
let g:startify_lists = [
            \ { 'type': 'files',     'header': ['   Recent Files'] },
            \ { 'type': 'bookmarks', 'header': ['   Bookmarks']    },
            \ ]
let g:startify_bookmarks = [ ]
let mapleader = " "
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>t :NERDTreeToggle<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>gs :G<CR>
