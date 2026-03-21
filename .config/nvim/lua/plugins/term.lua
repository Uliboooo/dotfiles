return {
  {
    "ruicsh/termite.nvim",
    opts = {
      width = 0.6,
      heiht = 0.6,
      position = "bottom",
      border = "light",
      shell = nil,
      start_insert = true,
      winbar = true,

      keymaps = {
        toggle = "<C-\\>",
        create = "<C-t>",
        next = "<C-n>",
        prev = "<C-p>",
        focus_editor = "<C-e>",
        maximize = "<C-f>",
        close = "<C-q>",
      },
    },
  },
}
