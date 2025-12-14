vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "»-",
  trail = "~",
  nbsp = "␣",
}
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
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
vim.opt.autoread = true

vim.api.nvim_exec(
  [[
  syntax match DangerousChars /[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]/
  highlight DangerousChars ctermbg=red guibg=red
]],
  false
)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- Lo-fi Aesthetic風のカスタムハイライト設定
-- WaybarのLo-fi Aestheticテーマ (style.css) を参考に、既存のcatppuccin-macchiatoテーマの上にカスタムハイライトを重ねてLo-fi Aesthetic風のブロック感のある配色を実現します。
local lofi = {
  base = "#232136", -- Deep dark purple base (Waybar window#waybar)
  mantle = "#2a273f", -- Lighter block background (Waybar #workspaces)
  text = "#e0def4", -- Text color (Waybar *)
  border = "#44415a", -- Retro border (Waybar border-bottom, #workspaces button)
  rose = "#ea9a97", -- Soft Rose (Waybar #workspaces button.focused)
  love_red = "#eb6f92", -- Love Red (Waybar #cpu, #battery.critical)
  cyan = "#3e8fb0", -- Muted Cyan (Waybar #clock)
}

-- UIのボーダーと背景のブロック感を強調
vim.api.nvim_set_hl(0, "ColorColumn", { fg = lofi.border, bg = "none" })
-- カーソル行の背景をWaybarのブロック背景色に設定
vim.api.nvim_set_hl(0, "CursorLine", { bg = lofi.mantle, underline = false })
-- カーソル行の行番号をWaybarのアクティブな強調色に設定
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = lofi.rose, bg = lofi.mantle, bold = true })
-- 通常の行番号をWaybarのボーダー色に設定（Lo-fiの「グリッド」感）
vim.api.nvim_set_hl(0, "LineNr", { fg = lofi.border, bg = "none" })
-- 折りたたみカラムやサインカラムも統一
vim.api.nvim_set_hl(0, "FoldColumn", { fg = lofi.border, bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { fg = lofi.border, bg = "none" })

-- ポップアップメニュー（Lo-fiのブロック感と強調色）
vim.api.nvim_set_hl(0, "Pmenu", { fg = lofi.text, bg = lofi.mantle })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = lofi.base, bg = lofi.rose })

-- 選択範囲をWaybarのボーダー色に設定
vim.api.nvim_set_hl(0, "Visual", { bg = lofi.border })

-- 検索ハイライトをWaybarの強調色に
vim.api.nvim_set_hl(0, "Search", { fg = lofi.base, bg = lofi.cyan, bold = true })
vim.api.nvim_set_hl(0, "IncSearch", { fg = lofi.base, bg = lofi.love_red, bold = true })
