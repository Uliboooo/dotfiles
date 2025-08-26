-- show white chars
vim.opt.listchars = {
  tab = "»-",
  -- space = "·",
  trail = "~",
  nbsp = "␣",
}
-- line numvers
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.opt.termguicolors = true
vim.o.updatetime = 1000
vim.opt.cursorline = true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldcolumn = "1"
vim.o.mouse = "a"
vim.o.signcolumn = "yes"

vim.g.rustaceanvim = {
  server = {
    cmd = function()
      return { "rust-analyzer" }
    end,
  },
}

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = { current_line = true },
})

vim.keymap.set("n", "<C-b>", "<Nop>", { noremap = true })
-- vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
-- vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })

-- format buffer
-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>f",
--   "<cmd>lua vim.lsp.buf.format({ async = false })<CR>",
--   { noremap = true, silent = true }
-- )

vim.api.nvim_create_user_command("W", "wa", {
  force = true,
})

vim.api.nvim_create_user_command("Wa", "wa", {
  force = true,
})

vim.api.nvim_create_user_command("Wq", "wq", {
  force = true,
})

vim.api.nvim_exec(
  [[ 
  syntax match DangerousChars /[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]/
  highlight DangerousChars ctermbg=red guibg=red
]],
  false
)

if vim.lsp.inlay_hint then
  vim.lsp.inlay_hint.enable(true, { 0 })
end

-- enable autoread
vim.opt.autoread = true

-- autocmd FocusGained,BufEnter * checktime
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})
