-- https://github.com/maxmx03/solarized.nvim
-- solarized theme
return {
    {
        'maxmx03/solarized.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('solarized').setup{
                styles = {
                    comments = { italic = false },
                    functions = { italic = false },
                    variables = { italic = false },
                },
            }

            vim.o.background = 'dark'
            vim.cmd.colorscheme 'solarized'
        end,
    },
}
