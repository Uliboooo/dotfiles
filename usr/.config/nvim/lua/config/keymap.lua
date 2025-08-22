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

vim.keymap.set("n", "<leader>f", function()
  require("snacks").picker.files({ cwd = vim.loop.cwd() })
end, { desc = "プロジェクトルートでファイル検索" })
