-- ~/.config/nvim/lua/plugins/vlime.lua
eturn({
  {
    "l04m33/vlime",
    ft = { "lisp", "scheme", "clojure" },
    lazy = false, -- 起動時に常にロード
    config = function()
      vim.g.vlime_lisp = "sbcl"
      vim.g.vlime_host = "127.0.0.1"
      vim.g.vlime_port = 4005

      -- キーバインド
      vim.api.nvim_set_keymap(
        "v",
        "<Leader>le",
        ":lua if vim.fn.exists(':VlimeEvalRegion') == 2 then vim.cmd('VlimeEvalRegion') end<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>ll",
        ":lua if vim.fn.exists(':VlimeEvalLine') == 2 then vim.cmd('VlimeEvalLine') end<CR>",
        { noremap = true, silent = true }
      )

      -- 自動接続
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = { "*.lisp", "*.cl", "*.scm" },
        callback = function()
          if vim.fn.exists(":VlimeConnect") == 2 then
            vim.cmd("VlimeConnect")
          end
        end,
      })
    end,
  },
})
