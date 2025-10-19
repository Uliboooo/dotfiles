return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "lua", "ocaml", "c", "cpp", "markdown", "markdown_inline" },
    sync_install = true,
  },
}
