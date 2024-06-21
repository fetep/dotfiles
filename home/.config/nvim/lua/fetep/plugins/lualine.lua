-- https://github.com/nvim-lualine/lualine.nvim
-- enhanced status line
return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
                disabled_filetypes = {
                    'NvimTree',
                },
                icons_enabled = false,
                theme = 'solarized',
            },
            sections = {
                lualine_a = {
                    'mode',
                },
                lualine_b = {
                    'branch',
                    'diff',
                },
                lualine_c = {
                    {
                        'filename',
                        path = 1,
                    },
                    'diagnostics',
                },
                lualine_x = {
                    'filetype',
                    function()
                        if not vim.bo.expandtab then
                            return 'tabs'
                        end
                        return string.format('ts=%d',    vim.bo.tabstop)
                    end,
                    'fileformat',
                },
                lualine_y = {
                    'progress',
                },
                lualine_z = {
                    'location',
                },
            },
        },
    },
}
