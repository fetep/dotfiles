-- https://github.com/hrsh7th/nvim-cmp
-- auto-completion

return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            --'hrsh7th/cmp-nvim-lsp-document-symbol',
            'mason-org/mason.nvim',
            'mason-org/mason-lspconfig.nvim',
        },
        opts = {
        },
        config = function()
            local cmp = require('cmp')

            cmp.setup({
                enabled = function()
                    local disabled = false
                    disabled = disabled or (vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt')
                    disabled = disabled or require('cmp.config.context').in_treesitter_capture('comment')
                    return not disabled
                end,
                mapping = {
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                },
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                sources = {
                    { name = 'nvim_lsp' },
                },
            })
        end
    },
}
