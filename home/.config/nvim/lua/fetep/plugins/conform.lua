-- https://github.com/stevearc/conform.nvim
-- auto formatting

return {
    {
        'stevearc/conform.nvim',
        ft = {
            'go',
            'lua',
            'puppet',
            'python',
            'terraform',
        },
        opts = {
            format_on_save = {
                timeout_ms = 1000,
                lsp_format = 'fallback',
            },
            formatters_by_ft = {
                python = {
                    "ruff_format",
                    "ruff_organize_imports",
                },
                puppet = {
                    "puppet-lint",
                },
            },
        },
    },
}
