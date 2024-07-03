vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.guicursor = ''
vim.opt.list = true
vim.opt.mouse = ''
vim.opt.number = true
vim.opt.scrolloff = 10
vim.opt.smartcase = true

-- undo history between sessions
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

vim.api.nvim_create_augroup('userconfig', {})
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  group = 'userconfig',
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})
