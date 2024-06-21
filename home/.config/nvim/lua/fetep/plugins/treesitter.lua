-- https://github.com/nvim-treesitter/nvim-treesitter
-- tree-based highlighting
return {
    {
        'nvim-treesitter/nvim-treesitter',
        opts = {
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
        },
    },
}
