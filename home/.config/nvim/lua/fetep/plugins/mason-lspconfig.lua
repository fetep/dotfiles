-- https://github.com/williamboman/mason.nvim
-- LSP config helper, integrating lspconfig + mason
return {
    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
            'williamboman/mason.nvim',
        },
        opts = {
            -- configs in lspconfig.lua
            ensure_installed = {
                'bashls',
                'gopls',
                'lua_ls',
                'pylsp',
                'rust_analyzer',
                'terraformls',
                'yamlls',
            }
        },
    },
}
