vim.g.mapleader = ','

vim.keymap.set('n', '<leader>1', function()
    vim.opt.number = not(vim.opt.number:get())
end)
vim.keymap.set('n', '<leader>2', function()
    vim.opt.relativenumber = not(vim.opt.relativenumber:get())
end)

vim.keymap.set('n', '<leader>ls', vim.cmd.Ex)
vim.keymap.set('n', '<leader>m', vim.cmd.noh)
vim.keymap.set('n', '<leader>p', function()
    vim.opt.paste = not(vim.opt.paste:get())
end)

function _G.toggle_colorcolumn()
    local value = vim.api.nvim_get_option_value('colorcolumn', {})
    if value == '' then
        vim.opt.colorcolumn = '100'
    else
        vim.opt.colorcolumn = ''
    end
end

vim.keymap.set('n', '<leader>|', ':call v:lua.toggle_colorcolumn()<CR>')
