return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate | TSInstall go",
    opts = {
      ensure_installed = { "lua", "ocaml", "c", "cpp", "markdown", "markdown_inline", "go" },
      sync_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },

  {
    "Olical/conjure",
  },
}
