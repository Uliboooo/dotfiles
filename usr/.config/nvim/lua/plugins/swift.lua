-- swift.lua

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "swift" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.sourcekit.setup({
        capabilities = capabilities,
        filetypes = { "swift" },
        root_dir = lspconfig.util.root_pattern("Package.swift", ".git"),
      })
    end,
  },
}
