-- trouble.nvim: LSPの診断結果（エラーや警告）を見やすく表示するプラグイン
return {
  "folke/trouble.nvim",
  -- アイコン表示のために nvim-web-devicons を依存関係に追加します
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- <leader>e で trouble の表示/非表示を切り替えるキーマップを設定します
    -- デフォルトではワークスペース全体のエラーが表示され
    vim.keymap.set("n", "<leader>e", function()
      require("trouble").toggle("diagnostics")
    end, {
      desc = "エラーリストを開く (Trouble)",
    })
  end,
}
