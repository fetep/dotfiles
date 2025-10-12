-- https://github.com/mason-org/mason.nvim
-- package manager for LSP servers, DAP servers, linters, and formatters
return {
    {
        'mason-org/mason.nvim',
        keys = {
            {
                '<leader>M',
                '<cmd>Mason<cr>',
                desc = 'Open Mason (package manager)',
            },
        },
        opts = {},
    },
}
