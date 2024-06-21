-- https://github.com/ntpeters/vim-better-whitespace
-- highlight trailing whitespace
return {
    {
        'ntpeters/vim-better-whitespace',
        config = function()
            vim.g.current_line_whitespace_disabled_soft = true
        end,
    },
}
