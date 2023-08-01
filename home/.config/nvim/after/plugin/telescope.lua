local builtin = require('telescope.builtin')

require('telescope').setup({
    defaults = {
        -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
        mappings = {
            i = {
                ['<esc>'] = 'close',
                ['<C-j>'] = 'move_selection_next',
                ['<C-k>'] = 'move_selection_previous',
                ['<C-h>'] = 'which_key',
            },
        },
    },
})

vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>g', function()
    builtin.grep_string({ search = vim.fn.input('% grep ') });
end)
