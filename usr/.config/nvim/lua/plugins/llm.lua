return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      -- "olimorris/cmp-ai", -- codecompanion.nvim と連携してAI補完を提供
      "olimorris/codecompanion.nvim", -- cmp-ai のバックエンドとして必要
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    event = "InsertEnter",

    config = function()
      require("cmp").setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        -- その他の cmp 設定
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- <CR>で選択中のアイテムを確定
        }),
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
      })

      require("codecompanion").setup({
        strategies = {
          chat = { adapter = "gemini" },
          inline = { adapter = "gemini" },
          agent = { adapter = "gemini" },
        },

        -- 警告の原因となる `adapters.opts` は使わず、
        -- 個別のアダプター定義を関数内で行います。
        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = os.getenv("GEMINI_API_KEY"),
              },
              schema = {
                model = {
                  default = "gemini-2.5-flash",
                },
              },
            })
          end,
        },
      })
    end,
  },
}
