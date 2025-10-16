vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- control line numbers
vim.keymap.set('n', '<leader>1', function()
    vim.opt.number = not (vim.opt.number:get())
end)
vim.keymap.set('n', '<leader>2', function()
    vim.opt.relativenumber = not (vim.opt.relativenumber:get())
end)

-- remove highlights
vim.keymap.set('n', '<leader>m', vim.cmd.noh)

-- toggle paste mode
vim.keymap.set('n', '<leader>p', function()
    vim.opt.paste = not (vim.opt.paste:get())
end)

-- enable diagnostics
vim.diagnostic.enable(true)
vim.opt.numberwidth = 3
vim.opt.signcolumn = 'yes:1'
vim.opt.statuscolumn = '%l%s'
--vim.api.nvim_set_option_value('signcolumn', 'yes', {})

function Toggle_diagnostic_virtual_text(enabled)
    vim.g.diagnostics_virtual_text = enabled
    vim.diagnostic.config({
        virtual_text = vim.g.diagnostics_virtual_text,
    })
    print(string.format('diagnostics_virtual_text=%s', vim.g.diagnostics_virtual_text))
end

vim.keymap.set('n', '<leader>d', function()
    Toggle_diagnostic_virtual_text(not vim.g.diagnostics_virtual_text)
end)
vim.keymap.set('n', '<leader>i', function()
    print(vim.inspect(vim.diagnostic.config()))
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
