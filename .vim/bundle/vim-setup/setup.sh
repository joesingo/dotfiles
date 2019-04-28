#!/bin/bash

source_script=~/.vim/bundle/vim-setup/sourceme.vim
plugin_dir=~/.vim/bundle

repos=("https://github.com/airblade/vim-gitgutter"
"https://github.com/ajmwagar/vim-deus"
"https://github.com/nightsense/office"
"https://github.com/ctrlpvim/ctrlp.vim"
"https://github.com/scrooloose/nerdtree"
"https://github.com/tpope/vim-commentary"
"https://github.com/tommcdo/vim-exchange"
"https://github.com/alvan/vim-closetag"
"https://github.com/tpope/vim-repeat"
"https://github.com/gcmt/taboo.vim"
"https://github.com/tpope/vim-surround"
"https://github.com/chriskempson/base16-vim"
"https://github.com/Nequo/vim-allomancer"
"https://github.com/tomasr/molokai"
"https://github.com/itchyny/calendar.vim")

echo "" > "$source_script"
mkdir -p "$plugin_dir"
cd "$plugin_dir"

for repo in ${repos[@]}; do
    repo_name=`basename "$repo"`
    if [[ -d "$repo_name" ]]; then
        echo "'$repo_name' already exists - skipping"
    else
        echo "Cloning '$repo'"
        git clone "$repo"
    fi

    echo "set runtimepath+=$plugin_dir/$repo_name" >> "$source_script"
done

# Build help pages for plugins
s=
for doc_dir in $plugin_dir/*/doc; do
    s=":helptags $doc_dir | $s"
done

vim -c "$s :q" > /dev/null 2>&1
