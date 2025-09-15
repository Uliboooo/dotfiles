return {
  {
    "vlime/vlime",
    ft = { "lisp" },
    config = function()
      -- .lisp ファイルを開いたとき自動で接続
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.lisp",
        callback = function()
          vim.cmd("VlimeConnect")
        end,
      })
    end,
  },
  -- {
  --   "sheerun/vim-polyglot",
  --   ft = { "lisp", "scheme", "clojure" },
  -- },
  -- nvim-cmp 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- vlime 用補完プラグインがあればここに追加
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "buffer" },
          -- { name = "vlime" }, -- 必要に応じて有効化
        }),
      })
    end,
  },

  -- Parinfer + sexp 操作
  -- {
  --   "guns/vim-sexp",
  --   ft = { "lisp", "scheme", "clojure" },
  -- },
  -- {
  --   "eraserhd/parinfer-rust",
  --   ft = { "lisp", "scheme", "clojure" },
  --   config = function()
  --     vim.api.nvim_create_autocmd("FileType", {
  --       pattern = { "lisp", "scheme", "clojure" },
  --       callback = function()
  --         vim.cmd("ParinferOn")
  --       end,
  --     })
  --   end,
  -- },
}
