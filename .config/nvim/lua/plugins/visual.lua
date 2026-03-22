return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
    config = function()
      require("rose-pine").setup({
        styles = {
          transparency = true,
          bold = true,
          italic = true,
        },
        highlight_groups = {
          Visual = { bg = "#56526e" },
          Search = { bg = "#c4a7e7", fg = "#232136" },
          IncSearch = { bg = "#f6c177", fg = "#232136" },
          PmenuSel = { bg = "#44415a", fg = "#e0def4" },
          MatchParen = { bg = "#44415a", fg = "#e0def4", bold = true },
          LspReferenceText = { bg = "#44415a" },
          LspReferenceRead = { bg = "#44415a" },
          LspReferenceWrite = { bg = "#44415a" },
        },
      })

      vim.cmd.colorscheme("rose-pine-moon")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              path = 1,
            },
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return require("nvim-navic").is_available() end,
            },
          },
          lualine_x = { "filesize", "filetype" },
          lualine_y = { "" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1,
            },
          },

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
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "right_align",
        delay = 50,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
    },
    config = function(_, opts) require("gitsigns").setup(opts) end,
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
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup({
        default_mappings = true,
        builtin_marks = { ".", "<", ">", "^" },
        refresh_interval = 250,
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        excluded_filetypes = {},
        bookmark_0 = {
          sign = "⚑",
          virt_text = "hello world",
          annotate = false,
        },
        mappings = {},
      })
    end,
  },
}
