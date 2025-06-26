vim.opt.listchars = {
    tab = "»-",
    space = "·",
    traild = "~",
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

vim.keymap.set("n", "<leader>p", ":NvimTreeFocus<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })

vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = false })<CR>', { noremap = true, silent = true })

vim.api.nvim_create_user_command(
  "W",           -- コマンド名
  "wa",          -- 実行するコマンド
  {              -- オプション
    force = true -- 既存のコマンド名を上書きする場合に必要
  }
)

vim.api.nvim_exec([[
  syntax match DangerousChars /[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]/
  highlight DangerousChars ctermbg=red guibg=red
]], false)

if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 0 })
end
