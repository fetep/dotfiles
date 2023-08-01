local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(_, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
    vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
end)

lsp.setup()

-- lsp servers
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {
        'bashls',
        'clangd',
        'dockerls',
        'gopls',
        'jsonls',
        'lua_ls',
        'nil_ls@2023-05-09', -- nix
        'pylsp',
        'terraformls',
        'yamlls',
    },
})

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
require('lspconfig').nil_ls.setup({
})
require('lspconfig').pylsp.setup({
    settings = {
        pylsp = {
            plugins = {
                autopep8 = {
                    enabled = false,
                },
                flake8 = {
                    enabled = true,
                    executable = "/home/petef/.local/bin/flake8",
                    indentSize = 4,
                    ignore = "",
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
})

-- autocompletion
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
    mapping = lsp.defaults.cmp_mappings({
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

    })
})

-- toggle diagnostics, default to off
vim.diagnostic.disable()
vim.g.diagnostics_visible = false

function _G.toggle_diagnostics()
    if vim.g.diagnostics_visible then
        vim.g.diagnostics_visible = false
        vim.diagnostic.disable()
    else
        vim.g.diagnostics_visible = true
        vim.diagnostic.enable()
    end
end

vim.keymap.set('n', '<leader>d', ':call v:lua.toggle_diagnostics()<CR>')
