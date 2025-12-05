return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate | TSInstall go",
    opts = {
      ensure_installed = {
        "lua",
        "ocaml",
        "c",
        "cpp",
        "markdown",
        "markdown_inline",
        "go",
        "javascript",
        "typescript",
        "commonlisp",
      },
      sync_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      config = function(_, opts)
        require("nvim-treesitter.config").setup(opts)
      end,
    },
  },

  {
    "Olical/conjure",
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
