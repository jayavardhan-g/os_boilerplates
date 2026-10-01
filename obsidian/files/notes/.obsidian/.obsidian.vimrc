" Mirrors ~/.config/nvim (LazyVim + custom keymaps.lua) wherever Obsidian has
" an equivalent action. Leader = Space, same as nvim.

" Have j and k navigate visual lines rather than logical ones (LazyVim does
" the same for j/k without a count)
nmap j gj
nmap k gk

" Esc clears search highlights, like LazyVim. Any ex command clears them in
" this vim engine, so :nohl is enough. , stays native (repeat f/t backward).
nmap <Esc> :nohl<CR>
nmap <F9> :nohl<CR>

" Plain y/p use the system clipboard - same as nvim locally (LazyVim's
" clipboard=unnamedplus). <Space>y / <Space>Y kept too for muscle memory.
set clipboard=unnamed

" x deletes a character without yanking it (nvim keymaps.lua: x -> "_x)
nnoremap x "_x

" Go back and forward with Ctrl+O and Ctrl+I
" (requires clearing Obsidian's default Quick switcher / Toggle italic
" hotkeys from Ctrl+O / Ctrl+I in Settings -> Hotkeys first)
exmap back obcommand app:go-back
nmap <C-o> :back<CR>
exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>

" --- FLASH (s) ---
" nvim has flash.nvim on s. Closest Obsidian match is the Jump to link
" plugin's Lightspeed jump: type 2 chars, then the label shown on the match.
" Normal mode only - visual s stays native (substitute selection).
exmap flash obcommand mrj-jump-to-link:activate-lightspeed-jump
nunmap s
nmap s :flash<CR>

" --- SURROUND (gsa, like nvim's mini.surround) ---
" Wraps the selection, or the word under the cursor. Add-only: the plugin's
" surround can't delete/replace, so there's no gsd/gsr.
exmap surround_math surround $ $
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
exmap surround_italic surround * *
exmap surround_bold surround ** **

" NOTE: must use 'map' and not 'nmap'
" [[ and ]] deliberately left as the plugin's own defaults (jump to
" previous/next heading) -- wiki-link-wrap lives on gsaw instead.
map gsa" :surround_double_quotes<CR>
map gsa' :surround_single_quotes<CR>
map gsa` :surround_backticks<CR>
map gsa( :surround_brackets<CR>
map gsa[ :surround_square_brackets<CR>
map gsa{ :surround_curly_brackets<CR>
map gsam :surround_math<CR>
map gsai :surround_italic<CR>
map gsab :surround_bold<CR>
map gsaw :surround_wiki<CR>

" --- APP ACTIONS (matches browser / VSCode muscle memory) ---
exmap newtab obcommand workspace:new-tab
nmap <C-t> :newtab<CR>

exmap nexttab obcommand workspace:next-tab
nmap <C-Tab> :nexttab<CR>
exmap prevtab obcommand workspace:previous-tab
nmap <C-S-Tab> :prevtab<CR>

exmap close obcommand workspace:close
nunmap <C-w>
nmap <C-w> :close<CR>
imap <C-w> <Esc>:close<CR>

exmap cmdpalette obcommand command-palette:open
nmap <C-S-p> :cmdpalette<CR>

exmap quickswitch obcommand switcher:open
nmap <C-p> :quickswitch<CR>

exmap toggleleftsidebar obcommand app:toggle-left-sidebar
nmap <C-b> :toggleleftsidebar<CR>
exmap togglerightsidebar obcommand app:toggle-right-sidebar
nmap <C-S-b> :togglerightsidebar<CR>

exmap search obcommand global-search:open
nmap <C-S-f> :search<CR>

exmap movefile obcommand file-explorer:move-file
nmap <C-S-m> :movefile<CR>
" <Space>m restored from the original pre-2026-09-20 leader block (mapped
" below, after unmap <Space>)

" --- LEADER (Space) - same keys as LazyVim ---
" Bare <Space> already has a built-in full match (Space -> l, move right,
" real vim behavior) -- the dispatcher fires a full match immediately and
" never checks for a longer partial match once one exists, so bare Space
" must be unmapped first (same reason 's' gets unmapped above) or these
" longer sequences can never complete.
unmap <Space>

" Splits: Space then - (below) or | (right)
exmap vsplit obcommand workspace:split-vertical
nmap <Space>| :vsplit<CR>
exmap hsplit obcommand workspace:split-horizontal
nmap <Space>- :hsplit<CR>
" (also Ctrl+- / Ctrl+| as Obsidian hotkeys in hotkeys.json - Ctrl+| can't be
" expressed in a vimrc map)

" Move note to another folder
nmap <Space>m :movefile<CR>

" Find files / recent -> quick switcher (it lists recent notes first)
nmap <Space><Space> :quickswitch<CR>
nmap <Space>ff :quickswitch<CR>
nmap <Space>fr :quickswitch<CR>
exmap newfile obcommand file-explorer:new-file
nmap <Space>fn :newfile<CR>

" Grep -> Omnisearch picker (vault / this note)
exmap grep obcommand omnisearch:show-modal
nmap <Space>/ :grep<CR>
nmap <Space>sg :grep<CR>
exmap grepbuffer obcommand omnisearch:show-modal-infile
nmap <Space>sb :grepbuffer<CR>

" Explorer (left) / other sidebar (right: backlinks, outline, tags, git) -
" e/E pair like nvim's two explorer keys
nmap <Space>e :toggleleftsidebar<CR>
nmap <Space>E :togglerightsidebar<CR>

" Buffers / windows -> tabs / panes
nmap <Space>bd :close<CR>
nmap <Space>wd :close<CR>
exmap closeothers obcommand workspace:close-others
nmap <Space>bo :closeothers<CR>

" Yank to system clipboard (nvim: "+y)
nmap <Space>y "+y
vmap <Space>y "+y
nmap <Space>Y "+y$

" Rename note (nvim: <leader>cr = LSP rename)
exmap rename obcommand workspace:edit-file-title
nmap <Space>cr :rename<CR>

" Toggles
exmap togglelinenumbers obcommand editor:toggle-line-numbers
nmap <Space>ul :togglelinenumbers<CR>

" Git (obsidian-git): lazygit view, blame, hunks
exmap gitview obcommand obsidian-git:open-git-view
nmap <Space>gg :gitview<CR>
exmap gitblame obcommand obsidian-git:toggle-line-author-info
nmap <Space>gb :gitblame<CR>
exmap nexthunk obcommand obsidian-git:next-hunk
nmap ]h :nexthunk<CR>
exmap prevhunk obcommand obsidian-git:prev-hunk
nmap [h :prevhunk<CR>

" --- LINKS ---
" gd / gx follow the link under the cursor (nvim: go to definition / open URI)
exmap followlink obcommand editor:follow-link
nmap gd :followlink<CR>
nmap gx :followlink<CR>

" --- WINDOW FOCUS (Ctrl+hjkl, like LazyVim) ---
" Requires Obsidian's default Ctrl+H (search & replace), Ctrl+K (insert
" link) and Ctrl+L (toggle checklist) hotkeys to be cleared - Obsidian
" hotkeys fire before vimrc maps.
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusTop obcommand editor:focus-top
exmap focusBottom obcommand editor:focus-bottom
nmap <C-h> :focusLeft<CR>
nmap <C-l> :focusRight<CR>
nmap <C-k> :focusTop<CR>
nmap <C-j> :focusBottom<CR>

" --- MOVE LINES (Alt+j/k, like LazyVim) ---
exmap linedown obcommand editor:swap-line-down
exmap lineup obcommand editor:swap-line-up
nmap <A-j> :linedown<CR>
nmap <A-k> :lineup<CR>

" --- FOLDING ---
exmap togglefold obcommand editor:toggle-fold
nmap zo :togglefold<CR>
nmap zc :togglefold<CR>

exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall<CR>

exmap foldall obcommand editor:fold-all
nmap zM :foldall<CR>

" --- TAB NAVIGATION (H/L and [b/]b like LazyVim's buffers, plus gt/gT) ---
exmap tabnext obcommand workspace:next-tab
exmap tabprev obcommand workspace:previous-tab
nmap H :tabprev<CR>
nmap L :tabnext<CR>
nmap [b :tabprev<CR>
nmap ]b :tabnext<CR>
nmap gt :tabnext<CR>
nmap gT :tabprev<CR>

" --- HYPERLINKS ---
" Paste clipboard URL over selected text / word under cursor
map <A-p> :pasteinto<CR>
