vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "<leader>U", vim.cmd.redu, { desc = "redo" })
vim.keymap.set("n", "f", "<Esc>ggVG", { noremap = true, silent = true })

-- Normal mode: J → 下に10行
vim.keymap.set("n", "J", "10j", { desc = "10j" })

vim.api.nvim_set_keymap("n", "dd", "ddk", { noremap = true, silent = true })

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

vim.keymap.set("n", "<Leader>e", function()
  require("trouble").toggle("diagnostics", {
    mode = "document",
    win = { type = "float", relative = "editor" },
  })
  vim.cmd("wincmd w")
end, { desc = "open trouble" })

-- sbcl
vim.g.slime_target = "tmux"
vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }

-- sbcl keymap
-- vim.keymap.set("v", "<C-c><C-c>", "<Plug>SlimeRegionSend", {})
-- vim.keymap.set("n", "<C-c><C-c>", "<Plug>SlimeParagraphSend", {})

-- localleaderは通常\なので、\eeなどのキーに対応
vim.api.nvim_set_keymap("n", "<Leader>e", "<cmd>ConjureEvalCurrentForm<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<localleader>er", "<cmd>ConjureEvalRootForm<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<localleader>eb", "<cmd>ConjureEvalBuf<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<localleader>ew", "<cmd>ConjureEvalWord<CR>", { noremap = true, silent = true })
