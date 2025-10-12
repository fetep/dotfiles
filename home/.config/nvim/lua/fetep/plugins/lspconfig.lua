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
            local capabilities = require('cmp_nvim_lsp').default_capabilities();

            vim.lsp.config('bashls', {
               capabilities = capabilities,
            })

            vim.lsp.config('basedpyright', {
                capabilities = capabilities,
                settings = {
                    venvPath = '.venv'
                },
            })

            vim.lsp.config('gopls', {
                capabilities = capabilities,
            })

            vim.lsp.config('lua_ls', {
                capabilities = capabilities,
            })

            vim.lsp.config('rust_analyzer', {
                capabilities = capabilities,
            })

            vim.lsp.config('terraformls', {
                capabilities = capabilities,
            })

            vim.lsp.config('yamlls', {
                capabilities = capabilities,
            })

            --vim.api.nvim_create_autocmd({"BufWritePre"}, {
                --pattern = {"*.tf", "*.tfvars"},
                --callback = function()
                    --vim.lsp.buf.format()
                --end,
            --})
        end,
    },
}
