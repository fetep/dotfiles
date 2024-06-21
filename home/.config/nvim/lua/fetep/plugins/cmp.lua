-- https://github.com/hrsh7th/nvim-cmp
-- auto-completion

return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
        ft = {
            -- install LSPs in mason-lspconfig.lua & configure below
            'bash',
            'go',
            'lua',
            'python',
            'rust',
            'terraform',
            'yaml',
        },
        config = function()
            local cmp = require('cmp')
            local cmp_select = {
                behavior = cmp.SelectBehavior.Select
            }

            cmp.setup {
                mapping = cmp.mapping.preset.insert({
                    ['<C-space>'] = cmp.mapping.complete(),
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-c>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                            else
                                fallback()
                            end
                        end,
                        s = cmp.mapping.confirm({ select = true }),
                        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                    }),
                }),
                sources = {
                    { name = 'nvim_lsp' }
                }
            }
        end,
    },
}
