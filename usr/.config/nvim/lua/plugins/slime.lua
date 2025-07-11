return {
    {
        "jpalardy/vim-slime",
        config = function()
            vim.g.slime_target = "neovim"
            vim.g.slime_paste_file = vim.fn.stdpath("cache") .. "/slime_paste"

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "lisp",
                callback = function()
                    vim.keymap.set("v", "<C-c><C-c>", "<Plug>SlimeRegionSend", { desc = "Slime: Send Region" })
                    vim.keymap.set("n", "<C-c><C-c>", "<Plug>SlimeParagraphSend", { desc = "Slime: Send Paragrap" })
                end,
            })
        end,
    },
}
