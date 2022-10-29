function SetColourScheme()
    let cs = "deus"
    let b16_theme_file = $HOME . "/.local/share/b16_theme/current_theme"
    if filereadable(b16_theme_file)
        let cs = readfile(b16_theme_file)[0]
    endif
    execute "colorscheme" cs
endfunction

call SetColourScheme()

" Show line numbers
set number

" Show rulers
set colorcolumn=80,100
set cuc
set cul

" Search settings
set hlsearch
set ignorecase
set incsearch

" TODO: remove if no longer using CtrlP
" " Stop CtrlP searching for unwanted files
" set wildignore+=*.png,*.jpg,*.gif
" set wildignore+=*.pyc
" set wildignore+=*.beam
" set wildignore+=*.class
" set wildignore+=*.olean
" set wildignore+=*.blg,*.bbl,*.out,*.log,*.aux,*.pdf,*.toc,*.bcf,*.run.xml,*.lof
" set wildignore+=*.snm,*.nav,*.synctex.gz
" set wildignore+=*/venv/*
" set wildignore+=*/conda/*
" set wildignore+=*/node_modules/*
" set wildignore+=*/lean/_target/*
" set wildignore+=*.hi,*.o,*.dyn_hi,*.dyn_o
" set wildignore+=*/_build/*
" let g:ctrlp_custom_ignore = ''

" " Always start CtrlP in current directory
" let g:ctrlp_working_path_mode = '0'

" Toggle NERDTree
map <C-n> :NERDTreeToggle<CR>

" Tab settings
set expandtab
set tabstop=4
set shiftwidth=0    " use same value as tabstop
set softtabstop=-1  " ditto
set autoindent

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/ \+$//e
"
" Spell check
autocmd BufRead     * setlocal spell spelllang=en_gb

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
        exe 'normal Olet ' . var_name . ' = '
        normal "jpA;
    elseif &filetype == "erlang"
        exe 'normal O' . var_name . ' = '
        normal "jpA,
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

" Typo avoidance
noremap :W :w
noremap :Q :q
noremap :BD :bd

" LaTeX editing mappings
" Italics and bold with Ctrl-I and Ctrl-B in visual and insert mode
vmap <C-l> :call SurroundLaTeXCmd()<CR>
vmap <C-i> :call SurroundLaTeXCmd("emph")<CR>
vmap <C-b> :call SurroundLaTeXCmd("textbf")<CR>
vmap ` :call SurroundLaTeXCmd("texttt")<CR>
inoremap <C-b> \textbf{

function! SurroundLaTeXCmd(...)
    if a:0 == 1
        let cmd = a:1
    else
        let cmd = input("enter tag:")
    endif
    execute "normal `<ys`>{f}xpF{i\\" . cmd
endfunction

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

" Functions

" Settings useful for writing plain text files
function WriteText()
    set textwidth=79
    set colorcolumn=80
    set nocul
    set formatoptions+=n

    if &filetype == "tex" || &filetype == "plaintex"
        let &formatlistpat = "^\\s*.item\\s"
    else
        let &formatlistpat = "^\\s*[\\-\\*#]\\.\\?\\s"
    endif
endfunction

" Begin a LaTeX environment
function! BeginLatexEnvironment()
    let env_name = input("environment: ")
    exe 'normal i\end{' . env_name . '}'
    exe 'normal O\begin{' . env_name . '}'
endfunction

" Compile a LaTeX document
function! CompileLatexDocument(prog)
    let extension = expand("%:e")
    let thisdoc = expand("%")
    let basename = expand("%:r")
    let fullpath = expand("%:p")
    write
    if fullpath =~ "/home/joe/p/mypapers/thesis/.*"
        " temporary exception for thesis: get me in the habit of calling make
        " instead of pdflatex directly...
        echo "You fool: use Make"
    elseif extension == "tex"
        " If 'main.tex' exists and this file does not have an associated PDF,
        " compile that instead of the current file
        if filereadable("main.tex") && !filereadable(basename . ".pdf")
            let thisdoc = "main.tex"
        endif

        execute "!" a:prog "--synctex=1" thisdoc
    elseif extension == "md"
        let basename = fnamemodify(expand("%:t"), ":r")
        let outlatex = "/tmp/" . basename . ".tex"
        echo outlatex
        execute "!pandoc -s -t latex" thisdoc ">" outlatex "&& cd /tmp && pdflatex" outlatex
    else
        echo "I don't think you want to do that..."
    endif
endfunction

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
endfunction

function! LogEntry()
    exe "norm ] j"
    read !date '+\%d-\%m-\%Y'
    norm yypv$r-
endfunction

function! StartEndLog()
    let line = getline(".")
    let time = substitute(system("date '+\%H:\%M'"), "\\n", "", "")
    if line =~ "^\- \\d\\d:\\d\\d - \?:.*"
        exe "normal 0f?cl" . time
    else
        exe "normal o- " . time . " - ?:"
    endif
endfunction

function! Make()
    let f = expand("%:p")
    write
    if f =~ "/home/joe/p/notes/site/.*"
        !make html
    elseif f =~ "/home/joe/p/uniwebsite/.*"
        !make html
    else
        !make
    endif
endfunction

" Leader mappings

" noremap <Leader>b :call CompileLatexDocument("bibtex")<CR>
noremap <Leader>c :call CompileLatexDocument("pdflatex")<CR>
noremap <Leader>b :w<CR>:!make bib<CR>
noremap <Leader>e :call BeginLatexEnvironment()<CR>
noremap <Leader>f gwap
noremap <Leader>l :call StartEndLog()<CR>
noremap <Leader>m :call Make()<CR>
noremap <Leader>s :call SetColourScheme()<CR>
noremap <Leader>u :call Underline()<CR>
" Strikethough a like
noremap <Leader>x :s/./&̶/g<CR>:noh<CR>
