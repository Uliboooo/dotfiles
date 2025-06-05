vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.updatetime = 1000
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldcolumn = '1'


vim.opt.listchars = {
    tab = "▸ ",
    trail = "·",
    nbsp = "␣",
}
vim.g.mapleader = "\\"

vim.keymap.set("n", "<leader>ft", function()
    vim.fn.system("cargo fmt")
end, { desc = "cargo format"})
vim.keymap.set("n", "<leader>f", ":NvimTreeFocus<CR>", { noremap = true, silent = true})
vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {desc = "LSP Rename"})
vim.keymap.set("n", "<Leader>rh", function()
    vim.lsp.buf.inlay_hint(0, nil)
end, { desc = "Toggle inlay hints" })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "rust_analyzer" then
        vim.lsp.buf.inlay_hint(args.buf, true)
    end
end,})

