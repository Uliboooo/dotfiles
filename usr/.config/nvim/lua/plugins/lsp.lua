return {
  -- nvim-cmpの設定 (これは変更なし)
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
    end,
  },

  -- nvim-lspconfigの設定 (ここを修正・統合)
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy", -- Neovim起動直後ではなく、少し遅れて読み込む
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 全てのLSPで共通して使うキーマップなどの設定
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- keymap.luaで設定しているものは、ここで上書きしないように注意
        -- vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, opts)
        -- vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
      end

      -- C/C++ (clangd)
      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "c", "cpp", "objc", "objcpp" },
      })

      -- OCaml (ocamllsp)
      lspconfig.ocamllsp.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Swift (sourcekit)
      lspconfig.sourcekit.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "swift" },
      })
    end,
  },
}
