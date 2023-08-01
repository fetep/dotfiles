vim.o.background = 'dark'

require('solarized').setup({
    styles = {
        comments = {
            italic = false,
        },
        functions = {
            italic = false,
        },
        parameters = {
            italic = false,
        },
        variables = {
            italic = false,
        },
    },
    transparent = true,
})
vim.cmd.colorscheme = 'solarized'
