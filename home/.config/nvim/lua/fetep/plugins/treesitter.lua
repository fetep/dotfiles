-- https://github.com/nvim-treesitter/nvim-treesitter
-- tree-based highlighting
return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local configs = require('nvim-treesitter.configs')

            configs.setup({
                auto_install = true,
                ensure_installed = {
                    'bash',
                    'c',
                    'lua',
                    'go',
                    'markdown',
                    'markdown_inline',
                    'python',
                    'query',
                    'vim',
                    'vimdoc',
                },
                highlight = { enable = true },
                indent = { enable = true },
                sync_install = false,
            })
        end,
    },
}
