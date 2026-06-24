return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      picker = {
        enabled = true,
        ui_select = true,
        hidden = true,
        ignored = false,
        sources = {
          files = {
            cmd = "fd",
            args = {
              "--hidden",
              "--exclude",
              ".git",
              "--exclude",
              "node_modules",
              "--exclude",
              "target",
              "--exclude",
              ".mooncakes",
            },
            win = {
              input = {
                keys = {
                  ["<CR>"] = { "edit_tab", mode = { "n", "i" } },
                },
              },
            },
          },
          grep = {
            hidden = true,
            cmd = "rg",
            regex = true,
          },
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = false },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = true },
      terminal = {
        enabled = true,
      },
    },
    keys = {
      {
        "<Leader>f",
        function() Snacks.picker.files() end,
        desc = "find files",
      },
      {
        "<Leader>/",
        function() Snacks.picker.grep() end,
        desc = "grep",
      },
      {
        "<Leader>m",
        function() Snacks.picker.marks() end,
        desc = "Marks",
      },
      {
        "<Leader>u",
        function() Snacks.picker.undo() end,
        desc = "Undo History",
      },
      {
        "<Leader>d",
        function() Snacks.picker.diagnostics() end,
        desc = "Diagnostics",
      },
      {
        "<Leader>s",
        function() Snacks.picker.lsp_symbols() end,
        desc = "LSP Symbols",
      },
      {
        "<Leader>S",
        function() Snacks.picker.lsp_workspace_symbols() end,
        desc = "LSP Workspace Symbols",
      },
      {
        "gr",
        function() Snacks.picker.lsp_references() end,
        nowait = true,
        desc = "References",
      },
      {
        "<Leader>l",
        function() Snacks.lazygit() end,
        desc = "lazygit",
      },
    },
  },
  -- file tree toggle sidebar
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v3.x",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --
  --   config = function()
  --     require("neo-tree").setup({
  --       close_if_last_window = true,
  --
  --       filesystem = {
  --         follow_current_file = {
  --           enabled = true,
  --         },
  --
  --         filtered_items = {
  --           visible = true,
  --           hide_dotfiles = false,
  --           hide_gitignored = false,
  --         },
  --       },
  --
  --       window = {
  --         width = 25,
  --       },
  --     })
  --
  --     vim.keymap.set("n", "<Leader>e", function()
  --       vim.cmd("Neotree toggle left")
  --     end, { desc = "NeoTree Toggle" })
  --   end,
  --
  -- }
}
