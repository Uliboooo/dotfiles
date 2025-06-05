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
                    group_wmpty = true,
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
        end
    },


    --     config = function()
    --         require("lsp-hover").setup {
    --             delay = 300,
    --             max_width = 80,
    --             close_events = { "CursorMoved", "InsertEnter" },
    --         }
    --         vim.cmd [[
    --             autocmd CursorHold * lua require("lsp-hover").hover()
    --         ]]
    --     end
    -- },

    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
          require("toggleterm").setup({
            open_mapping = [[<c-\>]],  -- Ctrl+\ で開閉
            direction = "float",       -- 浮動ウィンドウモードに設定
            float_opts = {
              border = "curved",       -- 角丸の枠（他に "single", "double", "shadow" など）
              width = 80,
              height = 20,
              winblend = 10,            -- 透明度（0-100の数値で調整）
            },
            start_in_insert = true,    -- 開いたら自動で挿入モードに入る
            close_on_exit = true,      -- シェル終了時に自動で閉じる
          })
        end,
        keys = {
          { "<c-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" },
        },
    }
}
