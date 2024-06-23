-- https://github.com/nvimtools/none-ls.nvim
-- lsp interface for local commands
return {
    {
        'nvimtools/none-ls.nvim',
        config = function()
            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
            local null_ls = require('null-ls')

            null_ls.setup{
                -- auto-format on save
                on_attach = function(client, bufnr)
                    if client.supports_method('textDocument/formatting') then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ async = false })
                            end,
                        })
                    end
                end,
                sources = {
                    null_ls.builtins.diagnostics.puppet_lint,
                    null_ls.builtins.formatting.puppet_lint,
                }
            }
        end,
    },
}
