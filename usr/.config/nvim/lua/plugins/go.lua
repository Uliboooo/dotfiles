return {
  "folke/go.nvim",
  ft = "go",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("go").setup({
      lsp_cfg = {
        settings = {
          gopls = {
            cmd = { "/opt/homebrew/opt/gopls/bin/gopls" },
          },
        },
      },
    })
  end,
}