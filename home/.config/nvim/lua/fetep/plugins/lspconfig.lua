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
            'puppet',
            'python',
            'rust',
            'terraform',
            'yaml',
        },
        config = function()

            local capabilities = require('cmp_nvim_lsp').default_capabilities();
            local lspconfig = require('lspconfig')

            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            lspconfig.bashls.setup{
                capabilities = capabilities,
            }
            lspconfig.gopls.setup{
                capabilities = capabilities,
            }
            lspconfig.lua_ls.setup{
                capabilities = capabilities,
            }
            lspconfig.puppet.setup{
                capabilities = capabilities,
            }
            lspconfig.pylsp.setup{
                capabilities = capabilities,
                settings = {
                    pylsp = {
                        plugins = {
                            autopep8 = {
                                enabled = false,
                            },
                            flake8 = {
                                enabled = true,
                                indentSize = 4,
                                maxLineLength = 100,
                            },
                            pydocstyle = {
                                enabled = true,
                                ignore = "D100",
                            },
                            pyflakes = {
                                enabled = false,
                            },
                            yapf = {
                                enabled = false,
                            },
                        },
                    },
                },
            }
            lspconfig.rust_analyzer.setup{
                capabilities = capabilities,
            }
            lspconfig.terraformls.setup{
                capabilities = capabilities,
            }
            lspconfig.yamlls.setup{
                capabilities = capabilities,
            }


        end,
    },
}
