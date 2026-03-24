return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 20,
      })

      local is_small = true

      -- Toggle terminal
      vim.keymap.set({ "n", "t" }, "<C-\\>", function() vim.cmd("ToggleTerm") end, { noremap = true, silent = true })

      vim.keymap.set({ "n", "t" }, "<C-_>", function()
        if is_small then
          vim.cmd("resize " .. (vim.o.lines - 5))
          is_small = false
        else
          vim.cmd("resize 20")
          is_small = true
        end
      end)
    end,
  },
}
