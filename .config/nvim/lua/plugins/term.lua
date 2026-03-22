return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 20,
      })

      local term_state = 0

      vim.keymap.set({ "n", "t" }, [[<C-\>]], function()
        if term_state == 0 then
          vim.cmd("ToggleTerm")
          vim.cmd("resize 20")
          term_state = 1
        elseif term_state == 1 then
          vim.cmd("resize " .. (vim.o.lines - 5))
          term_state = 2
        else
          vim.cmd("ToggleTerm")
          term_state = 0
        end
      end)

      -- Esc Esc で強制 off
      vim.keymap.set("t", "<Esc><Esc>", function()
        vim.cmd("ToggleTerm")
        term_state = 0
      end)

      -- 手動で閉じた場合もリセット
      vim.api.nvim_create_autocmd("TermClose", {
        callback = function() term_state = 0 end,
      })
    end,
  },
}
