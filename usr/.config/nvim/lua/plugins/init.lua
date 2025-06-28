return {
  {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    priority = 1000,
    config = function()
        vim.cmd.colorscheme 'catppuccin-macchiato'
    end
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
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
                width = 20,
                signcolumn = "yes",
            },
            renderer = {
                group_empty = true,
                highlight_git = true,
                highlight_opened_files = "icon",
                indent_markers = {
                  enable = true,             -- インデントのガイド線を表示
                icons = {
                  corner = "└",
                  edge = "│",
                  item = "│",
                  none = " ",
                },
              },
            },
            filters = {
                dotfiles = false,
                git_ignore = false,
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
        size = 100,
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
            -- -- height = 80,    -- ←ここも前の設定を優先
            -- -- width = 140,
            -- row = 100,
            -- col = 100,
            width = function()
                return math.ceil(vim.o.columns * 0.8) -- 画面の総列数の80%
            end,
            height = function()
                return math.ceil(vim.o.lines * 0.7) -- 画面の総行数の70%
            end,
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
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
      "neovim/nvim-lspconfig",
      config = function()
        require("lspconfig").rustowl.setup{
          cmd = { "rustowl-lsp" }, -- Replace with the actual command if different
          filetypes = { "rust" },
          -- You can add more settings here if rustowl supports them
        }
      end,
    },
}
