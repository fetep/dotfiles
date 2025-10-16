-- https://github.com/nvim-lualine/lualine.nvim
-- enhanced status line

local function get_lsp(msg)
    msg = msg or "<no lsp>"
    local buf_clients = vim.lsp.get_clients()
    if next(buf_clients) == nil then
        if type(msg) == "boolean" or #msg == 0 then
            return "<no lsp>"
        end
        return msg
    end
    local buf_client_names = {}

    for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" then
            table.insert(buf_client_names, client.name)
        end
    end

    return table.concat(buf_client_names, ", ")
end

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
                    function()
                        return require('nvim-lightbulb').get_status_text()
                    end
                },
                lualine_x = {
                    'filetype',
                    function()
                        if not vim.bo.expandtab then
                            return 'tabs'
                        end
                        return string.format('ts=%d', vim.bo.tabstop)
                    end,
                    'fileformat',
                    get_lsp,
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
