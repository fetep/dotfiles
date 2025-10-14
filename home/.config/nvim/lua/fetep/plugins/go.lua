-- https://github.com/ray-x/go.nvim
-- go enhancements

return {
    'ray-x/go.nvim',
    dependencies = {
        'ray-x/guihua.lua',
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
    },
    build = ':lua require("go.install").update_all_sync()',
    event = { 'CmdlineEnter' },
    ft = {
        'go',
        'gomod',
    },
    opts = {
        diagnostic = false, -- don't change diagnostic settings
    },
}
