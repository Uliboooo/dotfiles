return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "query" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    },
    config = function(_, opts)
      -- 1. parsersモジュールを安全に読み込む
      local status, parsers = pcall(require, "nvim-treesitter.parsers")

      if status and parsers then
        -- get_parser_configs が関数なら呼ぶ、なければ parsers 自体をテーブルとして使う
        local parser_config = (type(parsers.get_parser_configs) == "function" and parsers.get_parser_configs())
          or parsers

        -- parser_config がテーブルである場合のみ MoonBit を追加
        if type(parser_config) == "table" then
          parser_config.moonbit = {
            install_info = {
              url = "https://github.com/moonbitlang/tree-sitter-moonbit",
              files = { "src/parser.c", "src/scanner.c" },
              branch = "main",
            },
            filetype = "moonbit",
          }
        end
      end

      -- 2. 設定の実行
      -- ここも念のため pcall で包んでエラー落ちを防ぐ
      local setup_status, configs = pcall(require, "nvim-treesitter.configs")
      if setup_status then
        configs.setup(opts)
      end
    end,
  },
}
