-- ~/.config/nvim/lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        cpp = { "clang-format" }, -- clangd ではなく clang-format 推奨
        c = { "clang-format" },
        rs = { "rustfmt" },
      },
    })

    -- 保存時に自動フォーマット
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.rs", "*.go" },
      callback = function(args)
        require("conform").format({ bufnr = args.buf })
      end,
    })
  end,
}
