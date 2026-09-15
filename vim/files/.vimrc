" ========================================
" Options
" ========================================

set encoding=UTF-8
set spelllang=en_us,de_de,es_es
set nohlsearch " Disable highlight on search
set number " Enable line numbers
set mouse=a " Enable mouse mode
set breakindent " Enable break indent
set undofile " Save undo history
" Without an explicit undodir, undofile scatters hidden .un~ files into
" whatever directory you're editing in - keep them in one place instead.
set undodir=~/.vim/undodir
set ignorecase " Case-insensitive searching unless \C or capital in search
set smartcase " Enable smart case
set incsearch " Highlight search matches as you type the pattern
set signcolumn=no " No sign gutter - no left padding
set updatetime=250 " Decrease update time
set timeoutlen=1000 " Time to wait for a mapped sequence to complete (in milliseconds) - more breathing room after <leader>
set confirm " Ask (naming the file) instead of silently refusing to close on unsaved changes
set nobackup " Don't create a backup file
set nowritebackup " Don't write backup before overwriting
set completeopt=menuone,noselect " Better completion experience
set whichwrap+=<,>,[,],h,l " Allow certain keys to move to the next line
set wrap " Wrap long lines onto the next screen line
set linebreak " Don't break words when wrapping
set scrolloff=8 " Keep 8 lines above/below cursor
set sidescrolloff=8 " Keep 8 columns to the left/right of cursor
set relativenumber " Use relative line numbers
set numberwidth=4 " Number column width
set shiftwidth=4 " Spaces per indentation
set tabstop=4 " Spaces per tab
set softtabstop=4 " Spaces per tab during editing ops
set expandtab " Convert tabs to spaces
set nocursorline " Don't highlight the current line
set splitbelow " Horizontal splits below current window
set splitright " Vertical splits to the right
set noswapfile " Don't use a swap file
set smartindent " Smart indentation
" Buffer-based tabline (VSCode-style: one entry per open file, not per real
" Vim tabpage) via ap/vim-buftabline (~/.vim/pack/plugins/start/), not
" hand-rolled - g:buftabline_show=1 replicates "hidden below 2 real files"
" natively; netrw's buffer is excluded for free since it's never buflisted.
let g:buftabline_show = 1
let g:buftabline_indicators = 1 " show a modified marker per tab
set backspace=indent,eol,start " Configurable backspace behavior
set pumheight=10 " Popup menu height
set conceallevel=0 " Make `` visible in markdown
set fileencoding=utf-8 " File encoding
set cmdheight=1 " Command line height
set autoindent " Auto-indent new lines
set shortmess+=c " Don't show completion menu messages
set iskeyword+=- " Treat hyphenated words as whole words
set showmatch " show the matching part of pairs [] {} and ()
set laststatus=2 " Always show the bottom status bar
set noshowmode " Mode is shown in the custom statusline instead

" Folding - indentation-based (no Treesitter in plain Vim). Single foldmethod
" that works for every filetype purely from indentation depth (python, lua,
" c, sh, ...). Markdown is the one exception: ftplugin/markdown.vim overrides
" foldmethod to its own heading-based expr locally, regardless of this
" global setting, as long as g:markdown_folding is set below.
filetype plugin indent on
let g:markdown_folding = 1 " enable heading folds in ftplugin/markdown.vim
set foldmethod=indent

" Start each buffer fully unfolded, but via `zR` (sets 'foldlevel' to the
" buffer's real deepest fold level) rather than a hardcoded foldlevel=99.
" With foldlevel=99, `zm` (foldlevel -= 1) has to be pressed ~95+ times
" before it reaches actual fold depth and visibly closes anything; zR fixes
" that by landing foldlevel on the true max depth immediately. Gated to
" once per buffer (not every BufWinEnter) so revisiting a buffer/split
" doesn't blow open folds you closed by hand.
function! s:OpenFoldsOnce()
    if !exists('b:fold_zr_done')
        let b:fold_zr_done = 1
        normal! zR
    endif
endfunction
augroup fold_zr_once | au!
    au BufWinEnter * call s:OpenFoldsOnce()
augroup END

" Bottom status bar only: mode, filename, line/total
function! StatuslineMode()
    let l:m = mode()
    let l:names = {
        \ 'n':  'NORMAL',
        \ 'i':  'INSERT',
        \ 'v':  'VISUAL',
        \ 'V':  'V-LINE',
        \ "\<C-v>": 'V-BLOCK',
        \ 'R':  'REPLACE',
        \ 'c':  'COMMAND',
        \ 's':  'SELECT',
        \ 'S':  'S-LINE',
        \ "\<C-s>": 'S-BLOCK',
        \ 't':  'TERMINAL',
        \ }
    return '-- ' . get(l:names, l:m, toupper(l:m)) . ' --'
endfunction

set statusline=%{StatuslineMode()}\ \|\ %f
set statusline+=%= " Switch to the right side
set statusline+=%l " Current line
set statusline+=/ " Separator
set statusline+=%L " Total lines


" ========================================
" Keymaps
" ========================================

" Set leader key
let mapleader = " "
let maplocalleader = " "

" Disable the spacebar key's default behavior in Normal and Visual modes
nnoremap <Space> <Nop>
vnoremap <Space> <Nop>

" Allow moving the cursor through wrapped lines with j, k
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'

" clear highlights
nnoremap <Esc> :noh<CR>

" save file
nnoremap <C-s> :w<CR>

" save file without auto-formatting
nnoremap <leader>sn :noautocmd w<CR>

" quit file - no prompt even if modified, the buffer just goes hidden
" (nothing lost); it's never abandoned for real unless the whole session is
" closing, which is what :qa (below) is for
nnoremap <C-q> :q<CR>

" Smart quit-all: typing :qa still works, but now jumps to whichever file
" has unsaved changes before asking, and if more than one does, offers a
" Skip option (leave that one open, keep asking about the rest) on top of
" Vim's native Yes/No/Save All/Discard All/Cancel per-file cycle.
function! s:FocusBuffer(bufnr) abort
    let l:wins = win_findbuf(a:bufnr)
    if len(l:wins) > 0
        call win_gotoid(l:wins[0])
        return
    endif
    " Not visible anywhere: reuse a non-sidebar window in the current tab
    " rather than opening a new tab (this setup keeps everything in one tab
    " with one shared sidebar - see the BufferTabline note above).
    for l:info in getwininfo()
        if l:info.tabnr == tabpagenr() && getbufvar(l:info.bufnr, '&filetype') !=# 'netrw'
            call win_gotoid(l:info.winid)
            execute 'buffer ' . a:bufnr
            return
        endif
    endfor
    " Only the sidebar is open: split a window for it.
    vsplit
    execute 'buffer ' . a:bufnr
endfunction

function! s:ListModified() abort
    let l:out = []
    for l:buf in getbufinfo({'buflisted': 1})
        if l:buf.changed
            call add(l:out, l:buf.bufnr)
        endif
    endfor
    return l:out
endfunction

function! QuitAllSmart() abort
    let l:modified = s:ListModified()

    if empty(l:modified)
        qa
        return
    endif

    if len(l:modified) == 1
        " Only one file needs a decision: jump to it and let Vim's own
        " 'confirm' dialog (Yes/No/Cancel) handle the rest.
        call s:FocusBuffer(l:modified[0])
        qa
        return
    endif

    let l:i = 0
    while l:i < len(l:modified)
        let l:bufnr = l:modified[l:i]
        if getbufvar(l:bufnr, '&modified')
            call s:FocusBuffer(l:bufnr)
            let l:name = bufname(l:bufnr)
            if l:name ==# ''
                let l:name = '[No Name]'
            endif
            let l:choice = confirm('Save changes to "' . l:name . '"?', "&Yes\n&No\n&Skip\nSave &All\n&Discard All\n&Cancel")
            if l:choice == 1
                execute 'buffer ' . l:bufnr
                write
            elseif l:choice == 2
                call setbufvar(l:bufnr, '&modified', 0)
            elseif l:choice == 3
                " Skip: leave it modified, move on to the next one.
            elseif l:choice == 4
                let l:j = l:i
                while l:j < len(l:modified)
                    let l:b = l:modified[l:j]
                    if getbufvar(l:b, '&modified')
                        execute 'buffer ' . l:b
                        write
                    endif
                    let l:j += 1
                endwhile
                break
            elseif l:choice == 5
                let l:j = l:i
                while l:j < len(l:modified)
                    call setbufvar(l:modified[l:j], '&modified', 0)
                    let l:j += 1
                endwhile
                break
            else
                return " Cancel/Esc: stop here, already-resolved files stay resolved
            endif
        endif
        let l:i += 1
    endwhile

    if empty(s:ListModified())
        qa
    else
        echohl WarningMsg
        echo 'Quit cancelled - some files were skipped and are still unsaved.'
        echohl None
    endif
endfunction

command! QuitAllSmart call QuitAllSmart()
cnoreabbrev <expr> qa (getcmdtype() ==# ':' && getcmdline() ==# 'qa') ? 'QuitAllSmart' : 'qa'

" delete single character without copying into register
nnoremap x "_x

" Vertical scroll and center
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Find and center
nnoremap n nzzzv
nnoremap N Nzzzv

" Resize with arrows (Ctrl held - matches LazyVim's <C-Up/Down/Left/Right>,
" bare arrows freed up for normal cursor movement)
nnoremap <C-Up> :resize -2<CR>
nnoremap <C-Down> :resize +2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" Navigate buffers - H/L, matching LazyVim's <S-h>/<S-l> (this sacrifices
" H/L's default screen-top/bottom jump, same trade LazyVim makes)
nnoremap H :bprevious<CR>
nnoremap L :bnext<CR>
nnoremap <leader>sb :buffers<CR>:buffer<Space>

" increment/decrement numbers
nnoremap <leader>+ <C-a>
nnoremap <leader>- <C-x>

" window management
" Vertical split matches LazyVim's <leader>|; horizontal split stays on
" <leader>h (LazyVim's own <leader>- collides with increment/decrement
" above, kept as-is on purpose - see [[vim-neovim-parity-pass]]).
nnoremap <leader><Bar> <C-w>v
nnoremap <leader>h <C-w>s
nnoremap <leader>se <C-w>=
nnoremap <leader>wd :close<CR>

" Navigate between splits
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-l> :wincmd l<CR>

" Real Vim tabpages (separate window layouts - rarely needed now that files
" use the buffer-based tabline instead, see BufferTabline above), under
" LazyVim's <leader><tab> prefix instead of the old <leader>to/tx/tn/tp
nnoremap <leader><tab><tab> :tabnew<CR>
nnoremap <leader><tab>d :tabclose<CR>
nnoremap <leader><tab>] :tabnext<CR>
nnoremap <leader><tab>[ :tabprevious<CR>
nnoremap <leader><tab>f :tabfirst<CR>
nnoremap <leader><tab>l :tablast<CR>

" Close this file's buffer without closing its window - plain :bdelete
" closes the window itself when another window exists (confirmed even with
" zero sidebar involved), which collapsed the file window and left netrw
" filling the screen. vim-bbye's :Bdelete preserves window layout instead.
" Key matches LazyVim's native <leader>bd (mini.bufremove does the same job
" there); new-buffer moved to <leader>bn to avoid clashing with it.
nnoremap <leader>bd :Bdelete<CR>
nnoremap <leader>bn :enew<CR>

" toggle line wrapping - matches LazyVim's <leader>uw
nnoremap <leader>uw :set wrap!<CR>

" Toggle comment (Ctrl+/), via tpope/vim-commentary's gcc/gc - plain Vim has
" no built-in equivalent to Neovim's core gcc/gc (that's Neovim-only, added
" in 0.10). <C-_> is included too since many terminals send that in place
" of <C-/> - both are bound to the same thing so whichever arrives works.
nmap <C-/> gcc
nmap <C-_> gcc
vmap <C-/> gc
vmap <C-_> gc

" Stay in indent mode
" vnoremap < <gv
" vnoremap > >gv

" Keep last yanked when pasting
vnoremap p "_dP

" Yank via OSC52: lands in your LOCAL machine's clipboard even over a plain
" SSH session with no X/Wayland forwarding (kitty understands OSC52 both
" locally and over SSH), unlike plain "+y which only reaches whatever
" clipboard exists on the box vim is actually running on.
nmap <leader>y <Plug>OSCYankOperator
vmap <leader>y <Plug>OSCYankVisual
nmap <leader>Y <leader>y$

" Open file explorer
noremap <silent> <leader>e :Lex<CR>


" ========================================
" Other
" ========================================

" Syntax highlighting
syntax on

" No colorscheme set on purpose - inherit the terminal's own theme/palette
" instead of an explicit Vim colorscheme with its own hardcoded colors.
hi Normal ctermbg=NONE guibg=NONE
hi NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE
hi VertSplit guibg=NONE guifg=NONE ctermbg=NONE ctermfg=NONE

" Statusline: a colored accent bar using the terminal's numbered ANSI slots
" (0-15) rather than fixed hex colors, so it re-themes automatically with
" whatever the terminal's colorscheme defines for cyan/black/gray.
hi StatusLine   ctermfg=0  ctermbg=6 cterm=bold
hi StatusLineNC ctermfg=15 ctermbg=8 cterm=NONE

" Sync clipboard with OS
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" Use a line cursor within insert mode and a block cursor everywhere else.
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
" Use 'l' instead of <CR> to open files
augroup netrw_setup | au!
    au FileType netrw nmap <buffer> l <CR>
augroup END
