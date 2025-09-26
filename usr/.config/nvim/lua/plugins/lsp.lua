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

      -- cmp.setup({
      --   sources = {
      --     { name = "buffer" },
      --     {
      --       name = "sly",
      --     },
      --   },
      -- })

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
          { name = "sly" },
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
      -- diagnostic
      vim.diagnostic.config({
        virtual_text = {
          severity = { min = vim.diagnostic.severity.ERROR },
          -- source = "always",
          spacing = 7,
          -- severity_sort = true,
          -- signs = false,
        },
        signs = {
          severity = { min = vim.diagnostic.severity.ERROR },
        },
        underline = {
          severity = { min = vim.diagnostic.severity.ERROR },
        },
        update_in_insert = false,
        severity_sort = true,
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
            cargo = {
              allFeatures = true,
            },
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
