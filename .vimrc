" Vimの基本設定
set expandtab                  " タブをスペースで表示
set tabstop=2                  " タブ幅を2に設定
set autoindent                 " 自動インデントを有効にする
set shiftwidth=2               " シフト幅を2に設定

" インデントガイドを有効にする
let g:indent_guides_enable_on_vim_startup = 1

" インサートモードでjjを押すとノーマルモードに移行する
inoremap <silent> jj <ESC>

" タグファイルの設定
au BufNewFile,BufRead *.ruby set tags+=$HOME/ruby.tags

" 単語候補を自動で表示する
set completeopt=menuone
for k in split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", '\zs')
  exec "imap <expr> " . k . " pumvisible() ? '" . k . "' : '" . k . "\<C-X>\<C-P>\<C-N>'"
endfor

" コマンドラインモードでの補完を有効にする
set wildmenu

" 行番号を表示する
set number

" 検索時に大文字小文字を区別しない
set ignorecase
set smartcase

" ステータスラインにファイルの相対パスを表示
set title
set titlestring=%-2(%{fugitive#statusline()}%)\ %F

" ハイライト検索結果を表示
set hlsearch

" 行末の空白を可視化
set list listchars=trail:·

" コードの折りたたみをサポート
set foldmethod=indent
set foldlevel=99

" クリップボードを有効にする
set clipboard=unnamedplus

" 検索時に入力するたびにオートコンプリート
set incsearch

" ターミナルモードでのカーソル形状を変更
if has("nvim")
  let &t_ti.="\e[1 q"
  let &t_SI.="\e[5 q"
  let &t_EI.="\e[1 q"
  let &t_te.="\e[0 q"
endif