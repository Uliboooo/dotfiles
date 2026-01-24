return {
  {
    "stevearc/conform.nvim",
    -- event = "BufWritePre" ではなく、読み込みタイミングを制御
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
        },
        -- setup内の format_on_save を有効にするだけで自動整形は機能します
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      })
    end,
  },
}
