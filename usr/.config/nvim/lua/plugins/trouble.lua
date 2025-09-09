return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    -- ここに設定を記述します
    modes = {
      float = {
        border = "rounded",

        -- ウィンドウのタイトル
        title = "Trouble",

        -- ウィンドウ内の上下左右の余白
        padding = { 4, 4 },

        -- "cursor", "win", "screen"
        position = "screen",

        -- -- ウィンドウの最大幅と最大高さ
        -- max_width = ,
        -- max_height = ,
        --
        -- -- z-index (他のフローティングウィンドウとの重なり順)
        -- zindex = ,
      },
    },
  },
}
