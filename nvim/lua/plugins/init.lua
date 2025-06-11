return {
    {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true,
    },

    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "catppuccin-macchiato"
        end
    },

    {
        "mason-org/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        cmd = "Mason",
        opts = {}
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "marksman", "clangd" },
                automatic_installation = true,
            })
        end,
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
    {
        "nvim-tree/nvim-tree.lua",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })
        end
    },
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require('Comment').setup()

            vim.keymap.set("n", "gc", function()
                require("Comment.api").toggle.linewise.current()
            end, {desc = "toggle cooment for ", noremap = true})

            vim.keymap.set("x", "gc", function ()
                require("Comment.api").toggle.linewise(vim.fn.visualmode())
            end, {desc = "toggle comment fort v-mode", noremap = true })
        end,
    },

    {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = {
        { "<c-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" },
    },
    opts = {
        size = 80,
        open_mapping = [[<c-\>]],
        direction = "float",
        shade_filetypes = {},
        hide_numbers = false,
        insert_mappings = true,
        terminal_mappings = true,
        start_in_insert = true,
        close_on_exit = true,
        float_opts = {
            border = "curved",
            winblend = 10,  -- ←ここだけ後の設定を優先
            height = 30,    -- ←ここも前の設定を優先
            width = 80,
            row = nil,
            col = nil,
        },
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)
    end,
},

    {
      'HiPhish/rainbow-delimiters.nvim',
      config = function()
        local rainbow_delimiters = require 'rainbow-delimiters'
        vim.g.rainbow_delimiters = {
          strategy = {
            [''] = rainbow_delimiters.strategy['global'],
          },
          query = {
            [''] = 'rainbow-delimiters',
          },
          highlight = {
            'RainbowDelimiterRed',
            'RainbowDelimiterYellow',
            'RainbowDelimiterBlue',
            'RainbowDelimiterOrange',
            'RainbowDelimiterGreen',
            'RainbowDelimiterViolet',
            'RainbowDelimiterCyan',
          },
        }
      end
    },
}
