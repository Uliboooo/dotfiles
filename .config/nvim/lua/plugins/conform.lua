return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          cpp = { "clang-format" },
          c = { "clang-format" },
          rust = { "rustfmt", lsp_format = "fallback" },
          go = { "gofmt" },
          lua = { "stylua" },
          json = { "biome" },
          jsonc = { "biome" },
          sh = { "shfmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      })
    end,
  },
}
