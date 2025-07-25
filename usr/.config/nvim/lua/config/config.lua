vim.opt.listchars = {
    tab = "»-",
    space = "·",
    trail = "~",
    nbsp = "␣",
}
vim.g.mapleader = "\\"

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
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldcolumn = '1'
vim.o.mouse = "a"
vim.opt.signcolumn = "yes"

vim.g.rustaceanvim = {
    server = {
        cmd = function()
            return {'rust-analyzer'}
        end
    },
}

vim.keymap.set('n', '<C-b>', '<Nop>', { noremap = trye })
vim.keymap.set("n", "<leader>p", ":NvimTreeFocus<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set('n', "<leader>n", ':nohlsearch<CR>', { silent = true})

vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = false })<CR>', { noremap = true, silent = true })

vim.api.nvim_create_user_command(
  "W",
  "wa",
  {
    force = true
  }
)

vim.api.nvim_create_user_command(
  "Wa",
  "wa",
  {
    force = true
  }
)


vim.api.nvim_exec([[
  syntax match DangerousChars /[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]/
  highlight DangerousChars ctermbg=red guibg=red
]], false)

-- vim.opt.spell = true
-- vim.opt.spelllang = "en_us"
-- -- スペル機能時のキー割り当て
-- vim.keymap.set("n", "]s", "]s", { desc = "Next misspelled word" })
-- vim.keymap.set("n", "[s", "[s", { desc = "Previous misspelled word" })
-- vim.keymap.set("n", "z=", "z=", { desc = "Spelling suggestions" })
-- vim.keymap.set("n", "zg", "zg", { desc = "Add good word" })

if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 0 })
end

-- vim.diagnostic.config({
--   virtual_text = {
--     spacing = 4,
--     prefix = "",
--     severity = vim.diagnostic.severity.WARN,
--   },
--   signs = true,
--   underline = true,
-- })
