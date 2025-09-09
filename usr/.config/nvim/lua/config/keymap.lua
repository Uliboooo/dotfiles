vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<leader>U", vim.cmd.redu, { desc = "redo" })

vim.keymap.set({ "n", "i", "v", "x", "s" }, "<C-c>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "toggle cooment for ", noremap = true })

vim.keymap.set({ "n", "v", "x", "s" }, "<Leader>gc", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "toggle cooment for ", noremap = true })

local path = vim.fn.argv(0)
if path == nil or path == "" then
  path = vim.fn.getcwd()
end

-- file picker
vim.keymap.set("n", "<Leader>f", function()
  local path = vim.fn.argv(0)
  if path == nil or path == "" then
    path = vim.fn.getcwd()
  end

  require("snacks").picker.files({ cwd = vim.fn.argv(0) })
end, { desc = "file picker in project root" })

-- global search
vim.keymap.set("n", "<leader>/", function()
  require("fzf-lua").live_grep()
end, { desc = "Global search (fzf-lua)" })

-- undo hist
vim.keymap.set("n", "<Leader>u", function()
  require("snacks").picker.undo()
end, { desc = "list undo" })

-- symbols picker
vim.keymap.set("n", "<Leader>s", function()
  require("snacks").picker.lsp_symbols()
end, { desc = "symbol search" })

-- show lsp references
vim.keymap.set("n", "gr", function()
  require("snacks").picker.lsp_references()
end, { desc = "lsp_references" })
