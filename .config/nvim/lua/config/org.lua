local highlight_group = "OrgItalic"
local emphasis_pattern = [=[\%(^\|\s\|*\|_\|=\|\~\|+\|\$\)\@<=/[^/ \t]\{-1,}/\%(\s\|$\|[[:punct:]]\)\@=]=]

local function apply()
  vim.fn.matchadd(highlight_group, emphasis_pattern, 10)
end

local function set_highlight()
  vim.api.nvim_set_hl(0, highlight_group, { italic = true })
end

set_highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_highlight,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  callback = apply,
})
