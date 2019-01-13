export PS1="\[$(tput bold)\]\[\033[01;32m\]\u@\h\[$(tput sgr0)\]:\[\033[01;34m\]\w\[$(tput sgr0)\]$ "
export LESS="-iR"
export PATH="~/bin:${PATH}"
export EDITOR="/usr/bin/vim"

if [[ -n $DISPLAY && ! $TERM = *256color ]]; then
    export TERM=${TERM}-256color
fi

recipes_dir="$HOME/coding/recipes"
export RECIPE_CONTENT="$HOME/coding/recipe_content"

alias ll="ls -l"
alias la="ls -a"
alias lspdf="ls -lt *.pdf"
alias rm_swp="find . -name "*.swp" -delete"
alias tping="ping 8.8.8.8"
alias findall="grep -inrC 5 --color=always --exclude-dir=venv --exclude-dir=".git" --exclude="*.pyc" -- "
alias md="python -m markdown"
alias diff="colordiff"
alias httpd="python3 -m http.server"
alias arduino-upload="sudo arduino --port /dev/ttyACM* --upload"
alias notes_iwatch="cd ~/notes/content && iwatch -r -c '~/coding/mdss/venv/bin/mdss /tmp/w' ."
alias recipes_es="sudo docker run -d -p 9200:9200 -e discovery.type=single-node docker.elastic.co/elasticsearch/elasticsearch:6.1.1"
alias recipes_site="$recipes_dir/venv/bin/python $recipes_dir/run_site.py"

av() {
    source "$1/venv/bin/activate"
}

bf_minify() {
    <"$1" tr -cd '.,+\-[]<>'
    echo ""
}

bf() {
    brainfuck <(bf_minify "$1")
}
