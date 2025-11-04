-- line numvers
vim.opt.relativenumber = true
vim.opt.number = true
-- show white chars
vim.opt.list = true
vim.opt.listchars = {
  tab = "»-",
  trail = "~",
  nbsp = "␣",
}
-- soft wrap
vim.opt.wrap = true
vim.opt.linebreak = true
-- clipboard
vim.opt.clipboard = "unnamedplus"
-- search highlight
vim.opt.hlsearch = true
vim.opt.tabstop = 4
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.updatetime = 1000
vim.opt.cursorline = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"

vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "100"

vim.keymap.set("n", "<C-b>", "<Nop>", { noremap = true })
-- vim.api.nvim_create_user_command("W", "wa", {
--   force = true,
-- })
--
-- vim.api.nvim_create_user_command("Wa", "wa", {
--   force = true,
-- })
--
-- vim.api.nvim_create_user_command("Wq", "wq", {
--   force = true,
-- })

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

vim.opt.autoread = true

-- autocmd FocusGained,BufEnter * checktime
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})
-- manage tranpa
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
