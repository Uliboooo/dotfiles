return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			ensure_installed = { "moonbit", "lua", "vim", "vimdoc", "query" },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		},
		config = function(_, opts)
			-- 1. nvim-treesitter.parsers の取得
			local status, parsers = pcall(require, "nvim-treesitter.parsers")
			if status then
				-- get_parser_configs が関数として存在するか確認し、なければ直接参照
				local parser_config
				if type(parsers.get_parser_configs) == "function" then
					parser_config = parsers.get_parser_configs()
				else
					parser_config = parsers
				end

				-- MoonBit の設定を注入
				parser_config.moonbit = {
					install_info = {
						url = "https://github.com/moonbitlang/tree-sitter-moonbit",
						files = { "src/parser.c", "src/scanner.c" },
						branch = "main",
					},
					filetype = "moonbit",
				}
			end

			-- 2. 設定の実行
			local config_status, configs = pcall(require, "nvim-treesitter.configs")
			if config_status then
				configs.setup(opts)
			else
				-- もし module not found が出る場合は、標準の setup 関数を手動で試みる
				vim.cmd([[runtime! plugin/nvim-treesitter.lua]])
			end
		end,
	},
}
