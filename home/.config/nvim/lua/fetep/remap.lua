vim.g.mapleader = ','

-- control line numbers
vim.keymap.set('n', '<leader>1', function()
    vim.opt.number = not(vim.opt.number:get())
end)
vim.keymap.set('n', '<leader>2', function()
    vim.opt.relativenumber = not(vim.opt.relativenumber:get())
end)

-- file navigation
vim.keymap.set('n', '<leader>ls', vim.cmd.Ex)

-- remove highlights
vim.keymap.set('n', '<leader>m', vim.cmd.noh)

-- toggle paste mode
vim.keymap.set('n', '<leader>p', function()
    vim.opt.paste = not(vim.opt.paste:get())
end)

-- toggle diagnostics, default to off
vim.g.diagnostics_enabled = false
vim.diagnostic.hide()
vim.keymap.set('n', '<leader>d', function()
    if vim.g.diagnostics_enabled then
        vim.g.diagnostics_enabled = false
        vim.diagnostic.hide()
    else
        vim.g.diagnostics_enabled = true
        vim.diagnostic.show()
    end
    print(string.format('diagnostics_enabled=%s', vim.g.diagnostics_enabled))
end)

-- toggle line 100 column highlight
function _G.toggle_colorcolumn()
    local value = vim.api.nvim_get_option_value('colorcolumn', {})
    if value == '' then
        vim.opt.colorcolumn = '100'
    else
        vim.opt.colorcolumn = ''
    end
end

vim.keymap.set('n', '<leader>|', ':call v:lua.toggle_colorcolumn()<CR>')
