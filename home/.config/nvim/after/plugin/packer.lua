local packer = require('packer')
vim.keymap.set('n', '<leader>pc', packer.clean, {})
vim.keymap.set('n', '<leader>ps', packer.sync, {})
vim.keymap.set('n', '<leader>pS', packer.status, {})
