vim.opt.listchars = {
    tab = "▸ ",
    trail = "·",
    nbsp = "␣",
}
vim.g.mapleader = "\\"

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.opt.termguicolors = true
vim.o.updatetime = 1000
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

vim.api.nvim_create_user_command(
  "W",           -- コマンド名
  "wa",          -- 実行するコマンド
  {              -- オプション
    force = true -- 既存のコマンド名を上書きする場合に必要
  }
)

if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 0 })
end
