return {
  -- {
  --   "catppuccin/nvim",
  --   lazy = false,
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("catppuccin-macchiato")
  --     vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
  --     vim.cmd([[
  --       hi DiagnosticUnderlineError gui=undercurl guisp=Red
  --       hi DiagnosticUnderlineWarn  gui=undercurl guisp=Yellow
  --     ]])
  --
  --     vim.api.nvim_create_autocmd("ColorScheme", {
  --       pattern = "*",
  --       callback = function()
  --         vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none", nocombine = true })
  --         vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none", nocombine = true })
  --         vim.api.nvim_set_hl(0, "NeoTreeFloatNormal", { bg = "none", nocombine = true })
  --         vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { bg = "none", nocombine = true })
  --         vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none", nocombine = true })
  --       end,
  --     })
  --   end,
  -- },
  -- {
  --   "everviolet/nvim",
  --   name = "evergarden",
  --   priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
  --   lazy = false,
  --   opts = {
  --     theme = {
  --       variant = "winter", -- 'winter'|'fall'|'spring'|'summer'
  --       accent = "green",
  --     },
  --     editor = {
  --       transparent_background = true,
  --       sign = { color = "none" },
  --       float = {
  --         color = "mantle",
  --         solid_border = false,
  --       },
  --       completion = {
  --         color = "surface0",
  --       },
  --     },
  --     style = {
  --       tabline = { "reverse" },
  --       search = { "italic", "reverse" },
  --       incsearch = { "italic", "reverse" },
  --       types = { "italic" },
  --       keyword = { "italic" },
  --       comment = { "italic" },
  --     },
  --     overrides = {},
  --     color_overrides = {},
  --   },
  --   -- config = function()
  --   --   vim.cmd.colorscheme("evergarden")
  --   -- end,
  -- },
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   opts = {
  --     variant = "moon",
  --     styles = {
  --       bold = true,
  --       italic = true,
  --       transparency = false,
  --     },
  --   },
  --   config = function()
  --     vim.cmd.colorscheme("rose-pine")
  --   end,
  -- },
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
              function()
                return require("nvim-navic").get_location()
              end,
              cond = function()
                return require("nvim-navic").is_available()
              end,
            },
          },
          lualine_x = { "filesize", "filetype" },
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
      current_line_blame = false,
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
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
