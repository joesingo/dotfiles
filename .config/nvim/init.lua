-- vim bindings etc
vim.cmd([[
    source ~/.vimrc
]])

-- plugin configuration, using packer
require("plugins")

-- -- telescope bindings and configuration
require("telescope").setup{
    defaults = {
        preview = false,
        mappings = {
            i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<Esc>"] = "close",
            }
        }
    }
}
local tel = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", tel.find_files, {})
vim.keymap.set("n", "<C-x>", tel.lsp_dynamic_workspace_symbols, {})

-- clipboard configuration
vim.g.clipboard = {
    name = 'wsl',
    copy = {
        ["+"] = {'clip.exe'}
    },
    paste = {
        ["+"] = {'powershell.exe', '-c', 'Get-Clipboard'}
    }
}

-- LSP configuration. the following is adapted from the nvim-lspconfig README
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  vim.keymap.set('n', '<space>s', vim.lsp.buf.document_symbol, bufopts)
  vim.keymap.set('n', '<space>h', function() vim.api.nvim_command(":ClangdSwitchSourceHeader") end, bufopts)
end

-- python LSP
local lspconfig = require 'lspconfig'
-- lspconfig.pylsp.setup{
--     on_attach = on_attach
-- }
lspconfig.pyright.setup{
    on_attach = on_attach,
    root_dir = lspconfig.util.find_git_ancestor
}

-- ruff (python formatter)
lspconfig.ruff_lsp.setup{
    on_attach = on_attach
}

-- javascript LSP
lspconfig.tsserver.setup{
    on_attach = on_attach
}

-- c++ (clangd)
lspconfig.clangd.setup{
    cmd = { "clangd-18" },
    on_attach = on_attach
}

-- rust-analyzer
lspconfig.rust_analyzer.setup{
    cmd = { "rust-analyzer" },
    on_attach = on_attach
}

-- debug adapters
local dap = require 'dap'
dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = '/home/js/misc/vscode-cpptools/debugAdapters/bin/OpenDebugAD7',
}

dap.configurations.cpp = {
  {
    name = "(gdb) Launch debug",
    type = "cppdbg",
    request = "launch",
    program = "/home/js/code/redacted/redacted/build/output/gcc/x86_64/tests/redacted",
    args = {
        "--gtest_filter=\"*\"",
        "-v",
        "4"
    },
    stopAtEntry = false,
    cwd = "${fileDirname}",
    environment = {},
    externalConsole = false,
    MIMode = "gdb",
    setupCommands = {
        {
            description = "Enable pretty-printing for gdb",
            text = "-enable-pretty-printing",
            ignoreFailures = true
        },
        {
            description = "Set Disassembly Flavor to Intel",
            text = "-gdb-set disassembly-flavor intel",
            ignoreFailures = true
        }
    },
    preLaunchTask = "make debug"
  },
}
dap.configurations.c = dap.configurations.cpp
