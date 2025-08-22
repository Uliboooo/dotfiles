vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })

vim.keymap.set("n", "<C-c>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "toggle cooment for ", noremap = true })

vim.keymap.set("n", "<Leader>gc", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "toggle cooment for ", noremap = true })

-- vim.keymap.set("n", "<leader>f", function()
--   require("snacks").picker.files({ cwd = vim.fn.getcwd() })
-- end, { desc = "プロジェクトルートでファイル検索" })

vim.keymap.set("n", "<Leader>f", function()
  -- require("snacks").picker.buffers()
  local path = vim.fn.argv(0)

  if path == nil or path == "" then
    path = vim.fn.getcwd()
  end
  require("snacks").picker.files({ cwd = vim.fn.argv(0) })
  -- require("snacks").picker.files({ cwd = require("snacks").project_root() })
end, { desc = "file picker in project root" })

vim.keymap.set("n", "<leader>/", function()
  require("fzf-lua").live_grep()
end, { desc = "Global search (fzf-lua)" })

vim.keymap.set("n", "<Leader>u", function()
  require("snacks").picker.undo()
end, { desc = "list undo" })

vim.keymap.set("n", "gr", function()
  require("snacks").picker.lsp_references()
end, { desc = "lsp_references" })
