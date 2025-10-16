-- https://github.com/aznhe21/actions-preview.nvim
-- preview lsp actions

return {
    {
        'aznhe21/actions-preview.nvim',
        opts = {},
        config = function(opts)
            local actions_preview = require('actions-preview')
            actions_preview.setup(opts)

            vim.keymap.set({ 'v', 'n' }, '<leader>A', actions_preview.code_actions)
        end,
    },
}
