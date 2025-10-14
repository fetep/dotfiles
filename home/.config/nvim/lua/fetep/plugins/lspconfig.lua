-- https://github.com/neovim/nvim-lspconfig
-- configs for neovim LSP client

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'mason-org/mason.nvim',
        },
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
        config = function()
            -- no need to call vim.lsp.enable() here, mason-lspconfig takes care of that

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
