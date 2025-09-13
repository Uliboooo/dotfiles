return {
  -- Markdown syntax & folding
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
    ft = { "markdown" },
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
    end,
  },

  -- Table formatting
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    cmd = { "TableModeToggle" },
  },

  -- Preview in browser
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   build = "cd app && npm install",
  --   ft = { "markdown" },
  --   cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
  --   init = function()
  --     vim.g.mkdp_auto_start = 0 -- 自動プレビューしない
  --   end,
  -- },

  -- Writing focus
  {
    "junegunn/goyo.vim",
    cmd = { "Goyo" },
  },
  {
    "junegunn/limelight.vim",
    cmd = { "Limelight" },
  },

  -- Better wrapping for prose
  {
    "preservim/vim-pencil",
    ft = { "markdown" },
    config = function()
      vim.cmd("PencilSoft")
    end,
  },
}
