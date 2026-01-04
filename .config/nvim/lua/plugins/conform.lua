return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
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
        format_on_save = {
          live_text = true,
          timeout_ms = 500,
          lsp_format = "fallback",
          async = false,
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.rs", "*.go" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },
}
