return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      presets = {
        -- Keep `/` and `?` in the same centered popup UI as `:`.
        bottom_search = false,
        -- Place command-line completion directly below the command popup.
        command_palette = true,
      },
      views = {
        cmdline_popup = {
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
    },
  },
}
