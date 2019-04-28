filetype plugin on

let sourceme = $HOME . "/.vim/bundle/vim-setup/sourceme.vim"
execute "source" sourceme

set hidden

syntax enable
set background=dark

" Get true colours in terminal
set t_8f= "\<Esc>[38;2;%lu;%lu;%lum" " set foreground color
set t_8b= "\<Esc>[48;2;%lu;%lu;%lum" " set background color
set t_Co=256                         " Enable 256 colors
set termguicolors                    " Enable GUI colors for the terminal to get truecolor
" colorscheme base16-classic-light

let cs = "deus"
let b16_theme_file = $HOME . "/.local/share/b16_theme/current_theme"
if filereadable(b16_theme_file)
    let cs = readfile(b16_theme_file)[0]
endif
execute "colorscheme" cs

" Show line numbers
set number

" Show rulers
set colorcolumn=80,100
set cuc
set cul

" Highlight search resluts
set hlsearch

" Show normal mode commands as they are typed
set showcmd

" Show where pattern so far matches when searching
set incsearch

" Allow backspacing over anything in insert mode
set backspace=indent,eol,start

" Clear search results with Esc
noremap <silent><esc> :noh<CR>
noremap <esc>[ <esc>[

" Toggle NERDTree
map <C-n> :NERDTreeToggle<CR>

" Stop CtrlP searching for binary files, compilation artefacts, LaTeX junk,
" and in python virtualenvs and conda envs
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.pyc
set wildignore+=*.beam
set wildignore+=*.class
set wildignore+=*.blg,*.bbl,*.out,*.log,*.aux,*.pdf,*.toc,*.bcf,*.run.xml
set wildignore+=*/venv/*
set wildignore+=*/conda/*
let g:ctrlp_custom_ignore = ''

" Always start CtrlP in current directory
let g:ctrlp_working_path_mode = '0'

" HTML tag completion in Markdown files
let g:closetag_filenames = '*.html,*.xhtml,*.md'

" Tab settings
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set autoindent

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/ \+$//e
autocmd BufRead     * setlocal spell spelllang=en_gb

" gvim settings
if has("gui_running")
    " Remove scroll and toolbars
    set guioptions-=L
    set guioptions-=r
    set guioptions-=m
    set guioptions-=T
    " Show confirmations in console instead of GUI box
    set guioptions+=c

    " Have a different font on mac and ubuntu
    if (match(system("uname -s"), "Linux") != -1)
        set guifont=DejaVu\ Sans\ Mono
    else
        set guifont=Monaco:h12
    endif
endif

" Custom mappings

" Scroll window with jk
noremap <C-j> <C-e>
noremap <C-k> <C-y>

" Make Y behave like C, D
noremap Y y$

" I don't see the point in selecting the newline with '$'... make it behave
" like 'g_' instead
noremap $ g_

" Add a new line above/below
map [<Space> O<Esc>j
map ]<Space> o<Esc>k

" Move selection to previous line as a new variable
function! CreateVariable()
    let var_name = input("new variable name: ")
    exe 'normal gv"jc' . var_name

    if &filetype == "python"
        exe 'normal O' . var_name . ' = '
        normal "jp
    elseif &filetype == "sh"
        exe 'normal O' . var_name . '="'
        normal "jpA"
    elseif &filetype == "javascript"
        exe 'normal Ovar ' . var_name . ' = '
        normal "jpA;
    else
        " Note: same as python for now
        exe 'normal O' . var_name . ' = '
        normal "jp
    endif
endfunction

vnoremap A :call CreateVariable()<CR>

" Operator to select whole line
onoremap il :norm ^vg_<cr>

" Search for selection
vnoremap q "jy/<C-r>j<CR>N
" Search for selection and start editing (repeat with n and .)
vmap Q qcgn

noremap :W :w
noremap :Q :q
noremap :BD :bd

" LaTeX editing mappings
" Italics and bold with Ctrl-I and Ctrl-B in visual mode
vmap <C-i> S{i\emph<Esc>f{l
vmap <C-b> S{i\textbf<Esc>f{l
" Add footnote
noremap <Leader>n i\footnotemark{}<Esc>}O<CR>\footnotetext{<CR>}<Esc>O<Tab>

" Don't have spaces inside brackes when using surround plugin
let g:surround_40 = "(\r)"
let g:surround_91 = "[\r]"
let g:surround_123 = "{\r}"

" No point showing whitespace changes in gutter as it makes
" it hard to see actual changes
let g:gitgutter_diff_args = "-w"

" updatetime is used by GitGutter plugin: make short so that it
" is more responsive
set updatetime=200

let g:markdown_enable_mappings = 1

" Settings useful for writing plain text files
function WriteText()
    set textwidth=79
    set colorcolumn=80
endfunction

" Begin a LaTeX environment
function! BeginLatexEnvironment()
    let env_name = input("environment: ")
    exe 'normal i\end{' . env_name . '}'
    exe 'normal O\begin{' . env_name . '}'
    normal ] j
endfunction
noremap <Leader>e :call BeginLatexEnvironment()<CR>

" Compile a LaTeX document
function! CompileLatexDocument()
    let extension = expand("%:e")
    let thisdoc = expand("%")
    write
    if extension == "tex"
        " If 'main.tex' exists, compile that instead of the current file
        if filereadable("main.tex")
            let thisdoc = "main.tex"
        endif

        execute "!pdflatex" thisdoc
    elseif extension == "md"
        let basename = fnamemodify(expand("%:t"), ":r")
        let outlatex = "/tmp/" . basename . ".tex"
        echo outlatex
        execute "!pandoc -s -t latex" thisdoc ">" outlatex "&& cd /tmp && pdflatex" outlatex
    else
        echo "I don't think you want to do that..."
    endif
endfunction
noremap <Leader>c :call CompileLatexDocument()<CR>

" Run bibtex for a document
noremap <Leader>b :execute "!biber" expand("%:r")<CR>

" Word count of a TeX document
noremap <Leader>w :write !detex \| wc -w<CR>

" Format a paragraph
noremap <Leader>f gwap

" Conceals in vim-notes cause lines to wobble when
" you scroll over them...
let g:notes_conceal_italic=0
let g:notes_conceal_bold=0

" Function to create a new tab, lcd to somewhere, and rename the tab (using
" taboo.vim)
function! NewTabFunction(path)
    tabnew
    exe "lcd " .  a:path
    " get tab name as follows:  convert to full path, remove trailing slash,
    " and  get last component
    let name = fnamemodify(a:path, ":p:s?/$??:t")
    exe "TabooRename " . name
endfunction

command! -nargs=1 -complete=file Nt call NewTabFunction("<args>")

" Underline a line
function! Underline()
    let length = col("$") - 1
    let char = nr2char(getchar())
    normal o
    exe "normal " . length . "I" . char
    normal o
endfunction

noremap <Leader>u :call Underline()<CR>
