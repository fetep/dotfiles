-- https://github.com/neovim/nvim-lspconfig
-- configs for neovim LSP client

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'mason-org/mason.nvim',
        },
        config = function(opts)
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
            -- no need to call vim.lsp.enable() here, mason-lspconfig takes care of that
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.HINT] = "",
                        [vim.diagnostic.severity.INFO] = "",
                    },
                    numhl = {
                        [vim.diagnostic.severity.WARN] = "WarningMsg",
                        [vim.diagnostic.severity.ERROR] = "ErrorMsg",
                        [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
                        [vim.diagnostic.severity.HINT] = "DiagnosticHint",
                    },
                },
            })

            -- pass capabilities to every lsp for nvim-cmp completions
            vim.lsp.config('*', {
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })

            -- python lsp setup
            -- ruff: linting, formatting, and organizing imports
            -- basedpyright: the rest
            vim.lsp.config('basedpyright', {
                settings = {
                    basedpyright = {
                        analysis = {
                            inlayHints = {
                                callArgumentNames = false,
                                functionReturnTypes = false,
                                genericTypes = false,
                                variableTypes = false,
                            },
                        },
                    },
                },
            })

            vim.lsp.config('ruff', {})
        end,
    },
}
