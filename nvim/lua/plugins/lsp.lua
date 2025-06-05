return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "saadparwaiz1/cmp_luasnip",
          "L3MON4D3/LuaSnip", -- snip engine
        },
        config = function ()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function (args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- `select = true`
                }),
                sources = cmp.config.sources({
                  { name = "nvim_lsp" }, -- LSPからの補完 (rust-analyzer)
                  { name = "luasnip" },  -- スニペット補完
                  { name = "buffer" },   -- 現在のバッファからの補完
                  { name = "path" },     -- ファイルパス補完
                }),
            })
        end,
    },
    {
      "neovim/nvim-lspconfig", -- LSPクライアントの一般的な設定
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
      },
      config = function()
        -- rust-analyzer の設定は rust.lua で行うため、ここでは一般的な設定のみ
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- ここで直接 rust-analyzer を設定することも可能ですが、rustaceanvim がそれを管理するため、
        -- rustaceanvim 経由で capabilities を渡すことになります。
        -- 参考: rustaceanvim の opts.server.capabilities に capabilities を渡す
      end,
    },
}

