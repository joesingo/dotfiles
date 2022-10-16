export PS1="\[\e[1;91m\]\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w\[\e[0m\]$ "
export LESS="-iR"
export PATH="~/bin:~/.elan/bin:/usr/local/go/bin:/home/joe/.nimble/bin:/usr/local/texlive/2022/bin/x86_64-linux:${PATH}"
export EDITOR="~/coding/apps/nvim/nvim.appimage"

alias ll="ls -l"
alias la="ls -a"
alias grep="grep --color=auto -I"
alias lspdf="ls -lt *.pdf"
alias rm_swp="find ~/.local/share/nvim/swap -name '*.swp' -delete"
alias tping="ping 8.8.8.8"
alias findall="grep -I -inrC 5 --color=always --exclude-dir=venv --exclude-dir=".git" --exclude="*.pyc" -- "
alias diff="colordiff"
alias httpd="python3 -m http.server"
alias arduino-upload="sudo arduino --port /dev/ttyACM* --upload"
alias notes_iwatch="cd ~/notes/content && iwatch -r -c '~/coding/mdss/venv/bin/mdss /tmp/w' ."
alias vim="$EDITOR"
alias screenrecord="ffmpeg -f pulse -ac 2 -i default -f x11grab -framerate 30 -video_size 1920x1080 -i :0.0+0,0"
alias nfcserver="~/coding/nfc_handler/venv/bin/python ~/coding/nfc_handler/server.py"
alias gpom="git push origin master"
alias vlc="vlc -V x11"

# Tab-completions for kitty terminal
source <(kitty + complete setup bash)

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

# Usage: message MSG [MINS]
message() {
    msg="$1"
    mins="${2:-5}"
    (
        sleep "${mins}m"
        zenity --info --text="$1" 2>&1 >/dev/null
    ) &
}

# Usage: coffee [MINS]
coffee() {
    message "Coffee is ready!" $1
}

# Usage: pcrop PDF
pcrop() {
    file="$1"
    tmpdir=$(mktemp -d)
    tmpdest="${tmpdir}/$(basename "$file")"
    mv "$file" "$tmpdest"
    echo "made backup at $tmpdest"
    pdfcrop --margins 30 "$tmpdest" "$file"
}

# Usage: <cmd> themepack output_dir
unpack_windows_wallpaper_theme() {
    themepack=$(realpath "$1")
    output_dir=$(realpath "$2")
    tmp=$(mktemp -d)
    mkdir -p "$output_dir"

    cab_name="archive.cab"
    ln -s "$themepack" "$tmp/$cab_name"
    pushd "$tmp" > /dev/null
    7z x "$cab_name" > /dev/null

    imgs_dir="DesktopBackground"
    if [[ ! -d $imgs_dir ]]; then
        echo "did not find '$imgs_dir' directory" >&2
        popd > /dev/null
        return 1
    fi
    mv "$imgs_dir"/* "$output_dir"
    popd > /dev/null
    rm -r "$tmp"
}

# Change colour scheme for st and recompile. Uses base16-st colour schemes
# Usage:  <cmd> [--list] <name>
# If no name is given, use fzf to do a fuzzy search for themes
st_colorscheme() {
    st_source="/home/joe/coding/apps/st"
    colours_dir="/home/joe/coding/apps/base16-st/build"

    # List schemes
    if [[ $1 == "--list" || $1 == "-l" ]]; then
        pushd "$colours_dir" > /dev/null
        find . -type f -name "*.h"
        popd > /dev/null
        return
    fi

    name="$1"
    if [[ -z $name ]]; then
        pushd "$colours_dir" > /dev/null
        name=$(fzf)
        popd > /dev/null
    fi

    colour_scheme="$colours_dir/$name"
    if [[ ! -f $colour_scheme ]]; then
        echo "colour scheme not found at '$colour_scheme'" >&2
        return 1
    fi

    pushd "$st_source" > /dev/null
    ln -fs "$colour_scheme" "colourscheme.h" && sudo make clean install
    popd > /dev/null

    # Write name of current theme to a file, so that vimrc can load the
    # corresponding vim theme
    state_dir="$HOME/.local/share/b16_theme"
    mkdir -p "$state_dir"
    echo "$name" | sed 's,\./,,; s,\-theme\.h$,,' > "$state_dir/current_theme"
}

# usage:  <cmd>
# Same idea as st_colorscheme above, but for kitty. In this case fzf is always
# used
kitty_colorscheme() {
    config_dir="/home/joe/.config/kitty"
    colourschemes="${config_dir}/base16-kitty/colors"
    include_file="${config_dir}/colourscheme.conf"

    # Prompt for colour scheme with fzf
    pushd "$colourschemes" > /dev/null
    name=$(find . -type f -name "*.conf" -not -name "*-256.conf" | fzf)
    popd > /dev/null

    if [[ -z $name ]]; then
        return 0
    fi

    colour_scheme="$colourschemes/$name"
    if [[ ! -f $colour_scheme ]]; then
        echo "colour scheme not found at '$colour_scheme'" >&2
        return 1
    fi

    # Make included file a symlink to selected scheme
    ln -fs "$colour_scheme" "$include_file"

    # Write name of current theme to a file, so that vimrc can load the
    # corresponding vim theme
    state_dir="$HOME/.local/share/b16_theme"
    mkdir -p "$state_dir"
    # Remove './' prefix and '.conf' suffix
    theme_name=$(echo "$name" | sed 's,^\./,,; s,\.conf$,,')
    echo "$theme_name" > "$state_dir/current_theme"

    # Edit helix config
    helix_config=~/.config/helix/config.toml
    if [[ -f $helix_config ]]; then
        sed -i 's/^theme = ".*$/theme = "'"$theme_name"'"/' 
    fi

}
[ -f "/home/joe/.ghcup/env" ] && source "/home/joe/.ghcup/env" # ghcup-env
. "$HOME/.cargo/env"
