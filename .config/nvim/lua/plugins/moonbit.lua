-- plugins/moonbit.lua
return {
  "moonbit-community/moonbit.nvim",
  ft = { "moonbit" },
  opts = {
    lsp = {
      on_attach = function(client, bufnr)
        -- keymaps等をここに
      end,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
    },
    treesitter = {
      enabled = true,
      auto_install = true,
    },
  },
}
