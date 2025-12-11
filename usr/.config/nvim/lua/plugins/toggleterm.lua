return {
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
}
