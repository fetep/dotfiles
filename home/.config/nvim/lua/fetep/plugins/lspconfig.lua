-- https://github.com/neovim/nvim-lspconfig
-- configs for neovim LSP client

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
        ft = {
            -- install LSPs in mason-lspconfig.lua & configure below
            'bash',
            'go',
            'lua',
            'pyright',
            'rust',
            'terraform',
            --'yaml',
        },
        config = function()

            local capabilities = require('cmp_nvim_lsp').default_capabilities();
            local lspconfig = require('lspconfig')

            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            vim.lsp.config('bashls', {
                capabilities = capabilities,
            })

            vim.lsp.config('clangd', {
                capabilities = capabilities,
            })

            vim.lsp.config('gopls', {
                capabilities = capabilities,
            })

            vim.lsp.config('lua_ls', {
                capabilities = capabilities,
            })

            --vim.lsp.config('pyright', {
            --    capabilities = capabilities,
            --})

            vim.lsp.config('pylsp', {
                capabilities = capabilities,
                settings = {
                    configurationSources = {'flake8'},
                    pylsp = {
                        plugins = {
                            autopep8 = {
                                enabled = false,
                            },
                            flake8 = {
                                enabled = true,
                                maxLineLength = 120,
                            },
                            mccabe = {
                                enabled = false,
                            },
                            pycodestyle = {
                                enabled = false,
                            },
                            pydocstyle = {
                                enabled = false,
                            },
                            pyflakes = {
                                enabled = false,
                            },
                            rope_autoimport = {
                                enabled = false,
                            },
                        },
                    },
                },
            })

            vim.lsp.config('rust_analyzer', {
                capabilities = capabilities,
            })

            vim.lsp.config('terraformls', {
                capabilities = capabilities,
            })

            vim.api.nvim_create_autocmd({"BufWritePre"}, {
                pattern = {"*.tf", "*.tfvars"},
                callback = function()
                    vim.lsp.buf.format()
                end,
            })
        end,
    },
}
