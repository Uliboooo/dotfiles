return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = false,
      },
      presets = {
        bottom_search = false,
        -- Place command-line completion directly below the command popup.
        command_palette = true,
      },
    },
  },
}
