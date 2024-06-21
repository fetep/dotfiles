-- https://github.com/tpope/vim-fugitive
-- git plugin
return {
    {
        'tpope/vim-fugitive',
        keys = {
            {
                '<leader>gd',
                '<cmd>Git diff<cr>',
                desc = 'git diff',
            },
            {
                '<leader>gs',
                '<cmd>Git status<cr>',
                desc = 'git status',
            },
        },
    },
}
