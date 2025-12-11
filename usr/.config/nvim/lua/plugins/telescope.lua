return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local btin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          hidden = false,
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
            theme = "dropdown",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case",
          },
        },
      })

      require("telescope").load_extension("fzf")

      -- Keymaps
      vim.keymap.set("n", "<Leader>f", btin.find_files, { desc = "telescope find files" })
      vim.keymap.set("n", "<Leader>/", btin.live_grep, { desc = "telescope live grep" })
      vim.keymap.set("n", "<Leader>b", btin.buffers, { desc = "telescope buffers" })
      vim.keymap.set("n", "<Leader>q", btin.quickfix, { desc = "telescope quickfix" })
      vim.keymap.set("n", "<Leader>s", btin.lsp_document_symbols, { desc = "telescope lsp doc symbols" })
      vim.keymap.set("n", "<Leader>d", btin.diagnostics, { desc = "telescope diagnostics" })
      vim.keymap.set("n", "<Leader>P", btin.commands, { desc = "telescope vim cmd list" })

      vim.keymap.set("n", "gr", btin.lsp_references, { desc = "telescope lsp references" })
      vim.keymap.set("n", "gd", btin.lsp_definitions, { desc = "telescope lsp definitions" })
      vim.keymap.set("n", "gt", btin.lsp_type_definitions, { desc = "telescope lsp type def" })

      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
    end,
  },
}
