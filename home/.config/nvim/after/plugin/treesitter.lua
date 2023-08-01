require('nvim-treesitter.configs').setup({
    auto_install = false,
    ensure_installed = {
        'bash',
        'c',
        'lua',
        'go',
        'python',
        'query',
        'vim',
        'vimdoc',
    },
    indent = { enable = true },
})
