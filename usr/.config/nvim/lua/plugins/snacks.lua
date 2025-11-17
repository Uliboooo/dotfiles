return {
  "folke/snacks.nvim",
  priority = 500,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          hidden = true,
          layout = {
            layout = {
              width = 25,
            },
          },
        },
        files = {
          hidden = true,
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    lsp = {
      references = {
        method = "float",
      },
      document_symbol = {
        method = "float",
      },
      workspace_symbol = {
        method = "float",
      },
    },
  },
}
