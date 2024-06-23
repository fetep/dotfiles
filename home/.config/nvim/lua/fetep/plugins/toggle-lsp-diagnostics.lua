-- https://github.com/WhoIsSethDaniel/toggle-lsp-diagnostics.nvim
-- toggle LSP diagnostics
return {
    {
        'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim',
        keys = {
            {
                '<leader>d',
                '<Plug>(toggle-lsp-diag)',
                desc = 'toggle diagnostics',
            },
        },
        config = function()
            require('toggle_lsp_diagnostics').init(vim.diagnostic.config())
        end,
    },
}
