-- show white chars
vim.opt.listchars = {
  tab = "»-",
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
-- noremap <ScrollWheelUp> <C-Y>
-- noremap <ScrollWheelDown> <C-E>

-- vim.o.mouse = "" -- disable all mouse features
-- vim.keymap.set("n", "<ScrollWheelUp>", "<C-Y>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<ScrollWheelDown>", "<C-E>", { noremap = true, silent = true })

vim.o.signcolumn = "yes"
vim.opt.colorcolumn = "100"

-- vim.g.rustaceanvim = {
--   server = {
--     cmd = function()
--       return { "rust-analyzer" }
--     end,
--   },
-- }

-- vim.diagnostic.config({
--   virtual_text = false,
--   virtual_lines = { current_line = true },
-- })

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

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- ピッカー本体の背景を透明に
    vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none", nocombine = true })
    -- ピッカーの枠の背景も透明に
    vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#316c71", bg = "none", nocombine = true })
    -- 標準の浮動ウィンドウの背景も透明に
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", nocombine = true })
  end,
})

-- vim.diagnostic.config({
--   virtual_text = false,
--   virtual_lines = { only_current_line = true }, -- 行下に表示
--   underline = true,
-- })

-- vim.diagnostic.config({
--   virtual_text = false, -- 横に常時表示はしない
--   virtual_lines = { only_current_line = true }, -- カーソル行だけ行下に表示
--   underline = true,
--   signs = true,
--   update_in_insert = false,
--   severity_sort = true,
-- })

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = {
    only_current_line = true,
    format = function(diagnostic)
      local msg = diagnostic.message
      -- アクティブウィンドウの幅を取得
      local width = math.max(vim.api.nvim_win_get_width(0) - 10, 20)

      local lines = {}
      local start = 1
      while start <= #msg do
        table.insert(lines, msg:sub(start, start + width - 1))
        start = start + width
      end
      return table.concat(lines, "\n")
    end,
  },
  underline = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})
