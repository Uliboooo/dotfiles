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
          Visual = { bg = "iris", blend = 20 },
          Search = { bg = "foam", fg = "base" },
          IncSearch = { bg = "gold", fg = "base" },
          PmenuSel = { bg = "overlay", fg = "text", bold = true },
          MatchParen = { bg = "pine", fg = "text", bold = true },
          LspReferenceText = { bg = "highlight_med" },
          LspReferenceRead = { bg = "highlight_med" },
          LspReferenceWrite = { bg = "highlight_med" },
          -- Snacks picker highlights
          SnacksPickerCursor = { bg = "overlay", fg = "text", bold = true },
          SnacksPickerCursorLine = { bg = "overlay" },
          SnacksPickerSelect = { bg = "surface", fg = "iris", bold = true },
        },
      })

      -- Function to set colorscheme based on background
      local function set_colorscheme()
        if vim.o.background == "light" then
          vim.cmd.colorscheme("rose-pine-dawn")
        else
          vim.cmd.colorscheme("rose-pine-moon")
        end
      end

      -- Function to toggle between dark and light modes
      local function toggle_background()
        if vim.o.background == "dark" then
          vim.o.background = "light"
        else
          vim.o.background = "dark"
        end
        set_colorscheme()
      end

      -- Create user command for toggling
      vim.api.nvim_create_user_command("ToggleBackground", toggle_background, {})

      -- Set keymap for toggling (Leader + tb = toggle background)
      vim.keymap.set("n", "<leader>tb", toggle_background, { desc = "Toggle dark/light mode" })

      -- Auto-detect terminal background and set initial theme
      -- If TERM_BACKGROUND env var is set, use it; otherwise default to dark
      if vim.env.TERM_BACKGROUND == "light" then
        vim.o.background = "light"
      else
        vim.o.background = "dark"
      end

      set_colorscheme()
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
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      sign_priority = 6,
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
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      provider_selector = function() return { "treesitter", "indent" } end,
    },
  },
}
