
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
" Stop CtrlP searching for unwanted files
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.pyc
set wildignore+=*.beam
set wildignore+=*.class
set wildignore+=*.blg,*.bbl,*.out,*.log,*.aux,*.pdf,*.toc,*.bcf,*.run.xml,*.lof
set wildignore+=*/venv/*
set wildignore+=*/conda/*
set wildignore+=*.hi,*.o
set wildignore+=*/_build/*
let g:ctrlp_custom_ignore = ''

" Show normal mode commands as they are typed
set showcmd

" Allow backspacing over anything in insert mode
set backspace=indent,eol,start

" Clear search results with Esc
noremap <silent><esc> :noh<CR>
noremap <esc>[ <esc>[

" Toggle NERDTree
map <C-n> :NERDTreeToggle<CR>

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

noremap :W :w
noremap :Q :q
noremap :BD :bd
" for :call
noremap :C :c
" for :set
noremap :S :s

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

let g:markdown_enable_mappings = 1

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
    normal ] j
endfunction

" Compile a LaTeX document
function! CompileLatexDocument(prog)
    let extension = expand("%:e")
    let thisdoc = expand("%")
    let basename = expand("%:r")
    write
    if extension == "tex"
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

" Conceals in vim-notes cause lines to wobble when
" you scroll over them...
let g:notes_conceal_italic=0
let g:notes_conceal_bold=0

function! JumpOkular()
    let thisfile = expand("%")
    let pdfname = expand("%:r")
    let line = line(".")

    " If 'main.tex' exists, jump to 'main.pdf' instead
    if filereadable("main.tex")
        let pdfname = "main"
    endif

    execute "! okular --unique '" . pdfname . ".pdf\\#src:" . line . " " . thisfile . "'"
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
    if line =~ "^\* \\d\\d:\\d\\d - \?:.*"
        exe "normal 0f?cl" . time
    else
        exe "normal o* " . time . " - ?:"
    endif
endfunction

function! SwitchToBuffer(name, line, column)
    let n = bufnr(a:name)
    if n != -1
        exec "buffer" n
        exec a:line
        exec "normal " . a:column . "|"
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

" Abbreviations
abbreviate definit def __init__(self,<Space>)
abbreviate ifnmain if __name__ == "__main__":<CR>  <Space>
abbreviate aximo axiom
abbreviate aximos axioms

" Leader mappings

noremap <Leader>b :call CompileLatexDocument("bibtex")<CR>
noremap <Leader>c :call CompileLatexDocument("pdflatex")<CR>
noremap <Leader>e :call BeginLatexEnvironment()<CR>
noremap <Leader>f gwap
noremap <Leader>j :call JumpOkular()<CR>
noremap <Leader>l :call StartEndLog()<CR>
noremap <Leader>m :call Make()<CR>
noremap <Leader>n i\footnotemark{}<Esc>}O<CR>\footnotetext{<CR>}<Esc>O<Tab>
noremap <Leader>s :call SetColourScheme()<CR>
noremap <Leader>u :call Underline()<CR>
noremap <Leader>v :call CompileLatexDocument("xelatex")<CR>
noremap <Leader>w :write !detex \| wc -w<CR>
noremap <Leader>x :s/./&̶/g<CR>:noh<CR>
