-- https://github.com/WhoIsSethDaniel/toggle-lsp-diagnostics.nvim
-- toggle LSP diagnostics
return {
    {
        'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim',
        config = function()
            require('toggle_lsp_diagnostics').init()
        end,
    },
}
