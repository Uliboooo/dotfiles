vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { desc = "lsp code action" })
vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename, { desc = "lsp rename" })
vim.keymap.set("n", "<Leader>n", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "U", "<C-r>", { noremap = true, desc = "Redo" })
vim.keymap.set("n", "<C-b>", "<Nop>", { noremap = true })
-- vim.keymap.set(
--   { "n", "i", "v", "x", "s" },
--   "<C-c>",
--   function() require("Comment.api").toggle.linewise.current() end,
--   { desc = "toggle cooment for ", noremap = true }
-- )
-- vim.keymap.set(
--   { "n", "v", "x", "s" },
--   "<Leader>gc",
--   function() require("Comment.api").toggle.linewise.current() end,
--   { desc = "toggle cooment for ", noremap = true }
-- )
vim.keymap.set(
  "n",
  "eh",
  ":lua vim.lsp.inlay_hint.enable(true, { bufnr = 0}) <CR>",
  { desc = "enable lsp inlay hint" }
)
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save buffer" })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })

vim.keymap.set("n", "dc", function()
  local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  local cmap = {
    [1] = "Error",
    [2] = "Warn",
    [3] = "Info",
    [4] = "Hint",
  }

  if #diags > 0 then
    local d = diags[1]
    local ebuf = string.format(
      "%s: %s, %s, by %s at %d:%d-%d:%d",
      cmap[d.severity],
      d.message,
      d.code,
      d.source,
      d.lnum,
      d.col,
      d.end_lnum,
      d.end_col
    )
    -- print(ebuf)
    vim.fn.setreg("+", ebuf)
    vim.notify("Diagnostic copied!", vim.log.levels.INFO)
  end
end, { desc = "Copy diagnostic message" })

vim.keymap.set("n", "<C-p>", ":Gitsigns preview_hunk_inline<CR>")
