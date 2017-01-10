" ==========================================================
"                              ____                         
"               ,---,        ,'  , `.,-.----.     ,----..   
"       ,---.,`--.' |     ,-+-,.' _ |\    /  \   /   /   \  
"      /__./||   :  :  ,-+-. ;   , ||;   :    \ |   :     : 
" ,---.;  ; |:   |  ' ,--.'|'   |  ;||   | .\ : .   |  ;. / 
"/___/ \  | ||   :  ||   |  ,', |  ':.   : |: | .   ; /--`  
"\   ;  \ ' |'   '  ;|   | /  | |  |||   |  \ : ;   | ;     
" \   \  \: ||   |  |'   | :  | :  |,|   : .  / |   : |     
"  ;   \  ' .'   :  ;;   . |  ; |--' ;   | |  \ .   | '___  
"   \   \   '|   |  '|   : |  | ,    |   | ;\  \'   ; : .'| 
"    \   `  ;'   :  ||   : '  |/     :   ' | \.''   | '/  : 
"     :   \ |;   |.' ;   | |`-'      :   : :-'  |   :    /  
"      '---" '---'   |   ;/          |   |.'     \   \ .'   
"                    '---'           `---'        `---`     
"                                                           
"
" Copyright (c) 2017 Taishi Nojima All Rights Reserved
" ==========================================================

" ==========================================================
" Plugin Setup -- NeoBundle 
" ==========================================================
filetype plugin indent off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'scrooloose/nerdtree'         "Explorer
NeoBundle 'Shougo/vinarise.vim'         "Binary
NeoBundle 'Shougo/vimshell'             "Open shell in vim
NeoBundle 'tpope/vim-fugitive'          "showing github branch
NeoBundle 'bronson/vim-trailing-whitespace' "show trailing whitespace
NeoBundle 'scrooloose/syntastic'        "syntax error checking
NeoBundle 'Shougo/unite.vim'

" Colortheme related
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'itchyny/lightline.vim'       "bottom line coloring

call neobundle#end()

filetype plugin indent on

NeoBundleCheck
" ==========================================================

" remap settings
nnoremap <silent><C-e> :NERDTreeToggle<CR>
nnoremap <silent><C-t> :VimShellPop

" double ESC to switch search highlighting
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" syntastic
let g:loaded_syntastic_python_pylint_checker = 0


" ==========================================================
" Display Setup
" ==========================================================

" For 256 color
set t_Co=256

set number         " 行番号を表示する
set cursorline     " カーソル行の背景色を変える
" set cursorcolumn   " カーソル位置のカラムの背景色を変える
set laststatus=2   " ステータス行を常に表示
set cmdheight=1    " メッセージ表示欄を1行確保
set showmatch      " 対応する括弧を強調表示
set helpheight=999 " ヘルプを画面いっぱいに開く
set list           " 不可視文字を表示
" 不可視文字の表示記号指定
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮

" カーソル移動関連の設定

set backspace=indent,eol,start " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,]  " 行頭行末の左右移動で行をまたぐ
set scrolloff=8                " 上下8行の視界を確保
set sidescrolloff=16           " 左右スクロール時の視界を確保
set sidescroll=1               " 左右スクロールは一文字づつ行う

set wrap                       " return long sentence

" ファイル処理関連の設定

set confirm    " 保存されていないファイルがあるときは終了前に保存確認
set hidden     " 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set autoread   " 外部でファイルに変更がされた場合は読みなおす
set nobackup   " ファイル保存時にバックアップファイルを作らない
set noswapfile " ファイル編集中にスワップファイルを作らない

" 検索/置換の設定

set hlsearch   " 検索文字列をハイライトする
set incsearch  " インクリメンタルサーチを行う
set ignorecase " 大文字と小文字を区別しない
set smartcase  " 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
set wrapscan   " 最後尾まで検索を終えたら次の検索で先頭に移る
set gdefault   " 置換の時 g オプションをデフォルトで有効にする

" タブ/インデントの設定

set expandtab     " タブ入力を複数の空白入力に置き換える
set tabstop=2     " 画面上でタブ文字が占める幅
set shiftwidth=2  " 自動インデントでずれる幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent    " 改行時に前の行のインデントを継続する
set smartindent   " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する

" 動作環境との統合関連の設定

" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus
set clipboard+=autoselect   "Vモードで選択したテキストをクリップボードにコピー
set clipboard+=unnamed      "無名レジスタに入るデータを、*レジスタにも入れる
" マウスの入力を受け付ける
set mouse=a
" Windows でもパスの区切り文字を / にする
set shellslash

" コマンドラインの設定

" コマンドラインモードでTABキーによるファイル名補完を有効にする
set wildmenu wildmode=list:longest,full
" コマンドラインの履歴を10000件保存する
set history=10000

" ビープの設定

"ビープ音すべてを無効にする
set visualbell t_vb=
set noerrorbells "エラーメッセージの表示時にビープを鳴らさない

"Disable scratch
set completeopt-=preview


" ==========================================================
" colortheme
" ==========================================================
"
let g:lightline = {
            \ 'colorscheme': 'jellybeans',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component': {
            \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
            \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
            \ },
            \ 'component_visible_condition': {
            \   'readonly': '(&filetype!="help"&& &readonly)',
            \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
            \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
            \ },
            \
    \ }
set noshowmode

filetype plugin indent on     " required!
filetype indent on
syntax enable

try
  colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry

"Indicate 80th column
let &colorcolumn="80,".join(range(120,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27

"===========================
" Assembly Languages

au BufRead,BufNewFile *.asm set filetype=nasm
au BufRead,BufNewFile *.nasm set filetype=nasm

