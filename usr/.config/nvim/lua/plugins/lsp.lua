return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.filetype("rust", {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    lazy = false,
    config = function()
      vim.diagnostic.config({
        virtual_text = {
          severity = vim.diagnostic.severity.ERROR,
        },
      })
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- 全てのLSPで共通して使うキーマップなどの設定
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      end

      vim.lsp.config("rust_analyzer", {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "rust" },
        settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy",
            },
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      -- C/C++ (clangd)
      vim.lsp.config("clangd", {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "c", "cpp", "objc", "objcpp" },
      })
      vim.lsp.enable("clangd")

      -- OCaml (ocamllsp)
      vim.lsp.config("ocamllsp", {
        on_attach = on_attach,
        capabilities = capabilities,
      })
      vim.lsp.enable("ocamllsp")

      -- Swift (sourcekit)
      vim.lsp.config("sourcekit", {
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "swift" },
      })
      vim.lsp.enable("sourcekit")

      -- zig
      vim.lsp.config("zls", {
        cmd = { "zls" },
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "zig" },
      })
      vim.lsp.enable("zls")
    end,
  },
}
