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
                    analysis = {
                        ignore = { '*' },
                    },
                    venvPath = '.venv',
                },
            })

            vim.lsp.config('ruff', {
                settings = {
                    analysis = {
                        autoImportCompletions = true,
                        autoSearchPaths = true,
                        typeCheckingMode = 'standard', -- standard, strict, all, off, basic
                    },
                    venvPath = '.venv',
                },
            })

            vim.api.nvim_create_autocmd({ 'LspAttach' }, {
                desc = 'LspAttach: Disable hover capability from Ruff',
                group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client == nil then
                        return
                    end
                    if client.name == 'ruff' then
                        client.server_capabilities.hoverProvider = false
                    end
                end,
            })

            vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
                desc = 'BufWritePre: organize python imports with Ruff',
                group = vim.api.nvim_create_augroup('buf_write_pre_ruff_organize_imports', { clear = true }),
                callback = function(args)
                    if vim.bo[args.buf].filetype == 'python' then
                        vim.lsp.buf.code_action({
                            context = { only = { 'source.organizeImports' } },
                            apply = true,
                        })
                    end
                end,
            })
        end,
    },
}
