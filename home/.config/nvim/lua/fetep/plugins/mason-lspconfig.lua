-- https://github.com/mason-org/mason-lspconfig.nvim
-- LSP config helper, integrating lspconfig + mason
return {
    {
        'mason-org/mason-lspconfig.nvim',
        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
        },
        event = 'BufReadPost',
        opts = {
            -- configs in lspconfig.lua
            ensure_installed = {
                'bashls',
                'basedpyright',
                'gopls',
                'lua_ls',
                'rust_analyzer',
                'terraformls',
                'yamlls',
            },
            automatic_installation = true,
        },
    },
}
