-- https://github.com/NMAC427/guess-indent.nvim
-- guess indentation, respect .editorconfig
return {
    {
        'NMAC427/guess-indent.nvim',
        config = function()
            require('guess-indent').setup({
                auto_cmd = false,
            })

            local use_tabs = {
                go = true,
                make = true,
            }

            local indent = {
                _default = 4,
                toml = 2,
                yaml = 2,
            }

            local function set_bo_indent(value)
                vim.bo.shiftwidth = value
                vim.bo.softtabstop = value
                vim.bo.tabstop = value
                vim.bo.expandtab = true
            end

            vim.opt.cindent = true

            vim.api.nvim_create_augroup('GuessIndent', {
                clear = true,
            })

            vim.api.nvim_create_autocmd({
                'BufNewFile',
                'BufReadPost',
                'BufWritePost',
            }, {
                group = 'GuessIndent',
                desc = 'Guess indentation when loading a file',
                callback = function(args)
                    -- set defaults before we try to discover the current file settings
                    if indent[vim.bo.filetype] then
                        set_bo_indent(indent[vim.bo.filetype])
                    else
                        set_bo_indent(indent._default)
                    end

                    if use_tabs[vim.bo.filetype] then
                        vim.bo.expandtab = false
                    end

                    require('guess-indent').set_from_buffer(args.buf, true, true)

                    -- tabs are allowed in some filetypes
                    vim.opt.listchars = { tab = '>-' }
                    if not vim.bo.expandtab and use_tabs[vim.bo.filetype] then
                        vim.opt.listchars = {tab = '  ' }
                    end
                end,
            })
        end,
    },
}
