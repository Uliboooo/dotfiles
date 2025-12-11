vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { desc = "lsp code action" })
vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename, { desc = "lsp rename" })
vim.keymap.set("n", "<Leader>n", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<leader>U", vim.cmd.redo, { desc = "redo" })
vim.keymap.set("n", "<C-b>", "<Nop>", { noremap = true })
vim.keymap.set({ "n", "i", "v", "x", "s" }, "<C-c>", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "toggle cooment for ", noremap = true })
vim.keymap.set({ "n", "v", "x", "s" }, "<Leader>gc", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "toggle cooment for ", noremap = true })

-- telescope keymap
-- local btin = require("telescope.builtin")
-- vim.keymap.set("n", "<Leader>f", btin.find_files, { desc = "telescope find files" })
-- vim.keymap.set("n", "<Leader>/", btin.live_grep, { desc = "telescope live grep" })
-- vim.keymap.set("n", "<Leader>b", btin.buffers, { desc = "telescope buffers" })
-- vim.keymap.set("n", "<Leader>q", btin.quickfix, { desc = "telescope quickfix" })
-- vim.keymap.set("n", "<Leader>s", btin.lsp_document_symbols, { desc = "telescope lsp doc symbols" })
-- vim.keymap.set("n", "<Leader>d", btin.diagnostics, { desc = "telescope diagnostics" })
-- vim.keymap.set("n", "<Leader>P", btin.commands, { desc = "telescope vim cmd list" })

-- vim.keymap.set("n", "gr", btin.lsp_references, { desc = "telescope lsp referense" })
-- vim.keymap.set("n", "gd", btin.lsp_definitions, { desc = "telescope lsp definitions" })
-- vim.keymap.set("n", "gt", btin.lsp_type_definitions, { desc = "telescope lsp type def" })
