return {
  -- {
  --     'AmberLehmann/candyland.nvim',
  --     priority = 1000,
  -- },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      git = {
        enable = true,
        ignore = false,
        timeout = 400,
      },
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
        signcolumn = "yes",
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        highlight_opened_files = "icon",
        indent_markers = {
          enable = true,
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
        -- git_ignore = false,
      },
    },
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()

      vim.keymap.set("n", "gc", function()
        require("Comment.api").toggle.linewise.current()
      end, { desc = "toggle cooment for ", noremap = true })
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
        winblend = 5,
        width = function()
          return math.ceil(vim.o.columns * 0.9)
        end,
        height = function()
          return math.ceil(vim.o.lines * 0.95)
        end,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
    end,
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").rustowl.setup({
        cmd = { "rustowl-lsp" }, -- Replace with the actual command if different
        filetypes = { "rust" },
        -- You can add more settings here if rustowl supports them
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto", -- 'auto', 'powerline_dark', 'nord', など好きなテーマを選択
          component_separators = { left = "", right = "" }, -- アイコンを使用する場合
          section_separators = { left = "", right = "" }, -- アイコンを使用する場合
          -- その他のオプション
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "filesize", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = {},
      })
    end,
  },
  -- plugins.lua or lazy setup
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim", -- UI framework required by noice
  --     "rcarriga/nvim-notify", -- optional: better notifications
  --   },
  --   config = function()
  --     require("noice").setup({
  --       -- enable inline LSP signature help and more
  --       -- lsp = {
  --       --   signature = {
  --       --     enabled = true,
  --       --   },
  --       --   hover = {
  --       --     enabled = true,
  --       --   },
  --       -- },
  --       views = {
  --         cmdline_popup = {
  --           position = {
  --             row = 5,
  --             col = "50%",
  --           },
  --           size = {
  --             width = 60,
  --             height = "auto",
  --           },
  --         },
  --       },
  --     })
  --
  --     -- Optional: set as default notification backend
  --     vim.notify = require("notify")
  --   end,
  -- },
  --
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { hl = "GitGutterAdd", text = "+", numhl = "GitGutterAddNr", linehl = "GitGutterAddLn" },
        change = {
          hl = "GitGutterChange",
          text = "~",
          numhl = "GitGutterChangeNr",
          linehl = "GitGutterChangeLn",
        },
        delete = {
          hl = "GitGutterDelete",
          text = "_",
          numhl = "GitGutterDeleteNr",
          linehl = "GitGutterDeleteLn",
        },
        topdelete = {
          hl = "GitGutterDelete",
          text = "‾",
          numhl = "GitGutterDeleteNr",
          linehl = "GitGutterDeleteLn",
        },
        changedelete = {
          hl = "GitGutterChange",
          text = "~",
          numhl = "GitGutterChangeNr",
          linehl = "GitGutterChangeLn",
        },
      },
      -- オプションで自動で有効化
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      current_line_blame = false,
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- 既定のフォーマット
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
  },
  {
    "nvimtools/none-ls.nvim", -- null-ls の後継
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
  },
  {
    "simrat39/symbols-outline.nvim",
    cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    keys = {
      { "<leader>so", "<cmd>SymbolsOutline<CR>", desc = "Toggle Symbols Outline" },
    },
    event = "VeryLazy",
    config = function()
      require("symbols-outline").setup()
    end,
  },
  {
    "ojroques/vim-oscyank",
    event = "VeryLazy",
    config = function()
      -- tmux 環境で OSC52 経由にする
      vim.g.oscyank_term = "tmux"

      -- yank 後に自動で OSCYank を実行
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" then
            vim.cmd('OSCYankRegister "')
          end
        end,
      })
    end,
  },
  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  },
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   tag = "0.1.8",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  -- },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { width = 0.9, height = 0.9 },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },
}
