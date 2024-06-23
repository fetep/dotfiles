-- https://github.com/williamboman/mason.nvim
-- package manager for LSP servers, DAP servers, linters, and formatters
return {
    {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        keys = {
            {
                '<leader>M',
                '<cmd>Mason<cr>',
                desc = 'Open Mason (package manager)',
            },
        },
        config = true,
    },
}
