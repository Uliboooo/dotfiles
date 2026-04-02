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
    -- 該当箇所のテキストを取得（複数行に対応するため concat する）
    local lines = vim.api.nvim_buf_get_text(0, d.lnum, d.col, d.end_lnum, d.end_col, {})
    local target_text = table.concat(lines, "\n")

    local ebuf = string.format(
      "%s: %s [%s] (Source: %s) at %d:%d-%d:%d\n%s",
      cmap[d.severity] or "Unknown",
      d.message,
      tostring(d.code or "N/A"),
      d.source or "N/A",
      d.lnum + 1,
      d.col + 1,
      d.end_lnum + 1,
      d.end_col + 1,
      target_text
    )

    vim.fn.setreg("+", ebuf)
    vim.notify("Diagnostic copied to clipboard!", vim.log.levels.INFO)
  else
    vim.notify("No diagnostics found on current line.", vim.log.levels.WARN)
  end
end, { desc = "Copy diagnostic message to clipboard" })

-- Gitsigns 設定
vim.keymap.set(
  "n",
  "<C-p>",
  ":Gitsigns preview_hunk_inline<CR>",
  { desc = "Preview git hunk inline" }
)

vim.keymap.set("n", "<C-p>", ":Gitsigns preview_hunk_inline<CR>")
