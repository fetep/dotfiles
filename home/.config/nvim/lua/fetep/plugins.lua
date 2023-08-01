vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'nvim-treesitter/nvim-treesitter', tags = 'v0.9.0',
    }

    use 'maxmx03/solarized.nvim'

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons' },
    }


    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = { 'nvim-lua/plenary.nvim' },
    }

    use 'mbbill/undotree'

    use 'tpope/vim-fugitive'

    -- respects editorconfig
    use 'NMAC427/guess-indent.nvim'

    use 'ntpeters/vim-better-whitespace'

    use 'numToStr/Comment.nvim'

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'L3MON4D3/LuaSnip'},
        }
    }

    use 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim'

    -- use 'folke/trouble.nvim'
end)
