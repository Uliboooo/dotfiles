return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "lua", "ocaml", "c", "cpp" },
    sync_install = true,
  },
}
