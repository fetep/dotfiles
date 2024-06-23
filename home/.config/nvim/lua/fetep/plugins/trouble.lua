-- https://github.com/folke/trouble.nvim
-- LSP diagnostics helper
return {
    {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        keys = {
            {
                '<leader>D',
                '<cmd>Trouble diagnostics toggle<cr>',
                desc = 'Trouble - toggle diagnostics',
            }
        },
        opts = {},
    },
}
