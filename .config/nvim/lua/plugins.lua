return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    use "RRethy/nvim-base16"
    use "airblade/vim-gitgutter"
    use "scrooloose/nerdtree"
    use "tpope/vim-commentary"
    use "tommcdo/vim-exchange"
    use "tpope/vim-repeat"
    use "gcmt/taboo.vim"
    use "tpope/vim-surround"
    use "justinmk/vim-sneak"
    use "neovim/nvim-lspconfig"
    use {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.0",
        requires = { {"nvim-lua/plenary.nvim" } }
    }
end)
