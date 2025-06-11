return {
    {
        "vhyrro/luarocks.nvim",
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
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
    -- {
    --     "akinsho/toggleterm.nvim",
    --     version = "*",  -- 最新バージョンを使用
    --     cmd = "ToggleTerm", -- :ToggleTerm コマンドを有効にする
    --     opts = {
    --         size = 80,
    --         open_mapping = [[<c-\>]],
    --         direction = "float",
    --         shade_filetypes = {},
    --         hide_numbers = false,
    --         insert_mappings = true,
    --         terminal_mappings = true,
    --         start_in_insert = true,
    --         close_on_exit = true,
    --         -- フローティングターミナルの外観設定
    --         float_opts = {
    --             border = "curved", -- 角が丸いボーダー
    --             winblend = 5, -- 透明度
    --             height = 30, -- 高さ
    --             width = 80, -- 幅
    --             row = nil, -- 中央配置
    --             col = nil, -- 中央配置
    --         },
    --     },
    --     config = function(_, opts)
    --         require("toggleterm").setup(opts)
    --     end,
    -- },
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

    -- {
    --     "akinsho/toggleterm.nvim",
    --     version = "*",
    --     config = function()
    --         require("toggleterm").setup({
    --             open_mapping = [[<c-\>]], -- Ctrl+\ で開閉
    --             direction = "float",  -- 浮動ウィンドウモードに設定
    --             float_opts = {
    --                 border = "curved", -- 角丸の枠（他に "single", "double", "shadow" など）
    --                 width = 80,
    --                 height = 20,
    --                 winblend = 10,  -- 透明度（0-100の数値で調整）
    --             },
    --             start_in_insert = true, -- 開いたら自動で挿入モードに入る
    --             close_on_exit = true, -- シェル終了時に自動で閉じる
    --         })
    --     end,
    --     keys = {
    --         { "<c-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" },
    --     },
    -- },

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
