-- https://github.com/nvim-telescope/telescope.nvim
-- fuzzy finder UI for selecting from lists and helpful builtins
return {
    {
        'https://github.com/nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            {
                '<leader>b',
                function()
                    require('telescope.builtin').buffers()
                end,
                desc = 'list buffers',
            },
            {
                '<leader>ff',
                function()
                    require('telescope.builtin').find_files()
                end,
                desc = 'find files',
            },
            {
                '<leader>fg',
                function()
                    require('telescope.builtin').find_git_files()
                end,
                desc = 'find git files',
            },
            {
                '<leader>g',
                function()
                    require('telescope.builtin').grep_string({
                        search = vim.fn.input('% grep ')
                    })
                end,
                desc = 'grep',
            },
        },
        opts = {
            defaults = {
                -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
                mappings = {
                    i = {
                        ['<esc>'] = 'close',
                        ['<C-j>'] = 'move_selection_next',
                        ['<C-k>'] = 'move_selection_previous',
                        ['<C-h>'] = 'which_key',
                    }
                }
            }
        },
    },
}
