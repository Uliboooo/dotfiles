-- rust.lua

return {
  {
    "saecki/crates.nvim",
    tag = "stable",
    config = function()
      require("crates").setup()
    end,
  },
  --
  -- {
  --     "williamboman/mason.nvim",
  --     opts = {
  --         ensure_installed = {
  --             "codelldb",
  --         },
  --     },
  -- },

  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { 'rust' },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local buf_map = function(lhs, rhs)
              vim.keymap.set('n', lhs, rhs, { buffer = bufnr })
            end
            buf_map("gd", vim.lsp.buf.definition)
            buf_map("K", vim.lsp.buf.hover)
          end,
        },
      }
    end,
  },
  {
    'cordx56/rustowl',
    version = '*', -- Latest stable version
    build = 'cargo binstall rustowl',
    lazy = false, -- This plugin is already lazy
    opts = {
      auto_enable = true,
      idle_time = 1000,
    },
  }
}
