return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- colorscheme を適用
      vim.cmd.colorscheme("catppuccin-macchiato")

      -- 背景を透過にする
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
      vim.cmd([[
        hi DiagnosticUnderlineError gui=undercurl guisp=Red
        hi DiagnosticUnderlineWarn  gui=undercurl guisp=Yellow
      ]])
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()

      vim.keymap.set("n", "<C-c>", function()
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
      shade_terminals = false,
      highlight = {
        Normal = { guibg = "NONE", ctermbg = "NONE" },
      },
      float_opts = {
        border = "curved",
        winblend = 0,
        highlight = {
          border = "Normal",
          background = "Normal",
        },
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
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto", -- 'auto', 'powerline_dark', 'nord', など好きなテーマを選択
          component_separators = { left = "", right = "" }, -- アイコンを使用する場合
          section_separators = { left = "", right = "" }, -- アイコンを使用する場合
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
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        -- ポップアップUIの全体的な設定
        winopts = {
          width = 0.8,
          height = 0.8,
          row = 0.5,
          col = 0.5,
          border = "rounded",
        },
        live_grep = {
          args = { "--hidden", "--no-ignore-vcs", "--smart-case" },
        },
      })
    end,
  },

  {
    "saecki/crates.nvim",
    tag = "stable",
    config = function()
      require("crates").setup()
    end,
  },

  {
    "karb94/neoscroll.nvim",
    opts = {},
  },
}
