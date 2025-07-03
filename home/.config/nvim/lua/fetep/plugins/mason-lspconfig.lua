-- https://github.com/mason-org/mason.nvim
-- LSP config helper, integrating lspconfig + mason
return {
    {
        'mason-org/mason-lspconfig.nvim',
        dependencies = {
            { 'mason-org/mason.nvim', opts = {} },
            'neovim/nvim-lspconfig',
        },
        opts = {
            -- configs in lspconfig.lua
            ensure_installed = {
                --'bashls',
                'clangd',
                'gopls',
                'lua_ls',
                'pyright',
                'rust_analyzer',
                'terraformls',
                --'yamlls',
            }
        },
    },
}
