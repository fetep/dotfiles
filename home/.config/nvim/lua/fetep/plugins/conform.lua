-- https://github.com/stevearc/conform.nvim
-- auto formatting

return {
    {
        'stevearc/conform.nvim',
        ft = {
            'go',
            'lua',
            'python',
            'terraform',
        },
        opts = {
            format_on_save = {
                timeout_ms = 1000,
                lsp_format = 'fallback',
            }
        },
    },
}
