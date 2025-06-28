vim.g.mapleader = "\\"

vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })

