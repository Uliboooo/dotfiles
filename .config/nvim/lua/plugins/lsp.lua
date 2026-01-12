return {
	{
		"saghen/blink.cmp",
		lazy = false,
		dependencies = "rafamadriz/friendly-snippets",
		version = "*",
		opts = {
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "mooncake", "lsp", "path", "snippets", "buffer" },
				providers = {
					mooncake = {
						name = "Mooncakes",
						module = "moonbit.mooncakes.completion.blink",
						opts = { max_items = 100 },
					},
				},
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
			{
				"SmiteshP/nvim-navic",
				opts = {
					lsp = {
						auto_attach = true,
					},
				},
			},
		},
		event = { "BufReadPre", "BufNewFile" },
		lazy = false,
		config = function()
			vim.diagnostic.config({
				virtual_text = false,
				update_in_insert = false,
				float = {
					border = "rounded",
					source = "always",
				},
			})

			-- Make diagnostic float transparent
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })

			local lspconfig = require("lspconfig")
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local navic = require("nvim-navic")

			navic.setup({
				lsp = {
					auto_attach = true,
				},
			})

			-- Defined as no-op to satisfy existing references in vim.lsp.config calls below
			local on_attach = function(client, bufnr) end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local bufnr = args.buf

					if client.server_capabilities.documentSymbolProvider then
						navic.attach(client, bufnr)
					end

					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end

					local opts = { buffer = bufnr, silent = true }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

					vim.api.nvim_create_autocmd("CursorHold", {
						buffer = bufnr,
						callback = function()
							vim.diagnostic.open_float(nil, {
								focusable = false,
								close_events = { "CursorMoved", "CursorMovedI", "BufLeave" },
								border = "rounded",
								source = "always",
								prefix = " ",
								scope = "line",
								header = "",
								winhighlight = "Normal:NormalFloat",
							})
						end,
					})
				end,
			})

			vim.lsp.config("rust_analyzer", {
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "rust" },
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
						check = {
							command = "clippy",
						},
						inlayHints = {
							enable = true,
							typeHints = true,
							parameterHints = true,
							chainingHints = true,
							lifetimeElisionHints = true,
							expressionAdjustmentHints = true,
							closureCaptureHints = true,
						},
					},
				},
			})
			vim.lsp.enable("rust_analyzer")

			vim.lsp.config("clangd", {
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "c", "cpp", "objc", "objcpp" },
			})
			vim.lsp.enable("clangd")

			vim.lsp.config("gopls", {
				cmd = { "gopls" },
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				settings = {
					gopls = {
						hints = {
							parameterNames = true,
							assignVariableTypes = true,
						},
						analyses = { unusedparams = true, shadow = true },
						staticcheck = true,
						gofumpt = true,
					},
				},
			})
			vim.lsp.enable("gopls")

			vim.lsp.config("emmet_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = {
					"html",
					"css",
					"scss",
					"sass",
					"less",
					"javascript",
					"javascriptreact",
					"typescriptreact",
				},
				init_options = {
					html = {
						options = {
							["bem.enabled"] = true,
						},
					},
				},
			})
			vim.lsp.enable("emmet_ls")

			vim.lsp.config("zls", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = {
					"zig",
				},
			})
			vim.lsp.enable("zls")

			vim.lsp.config("html", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "html" },
			})
			vim.lsp.enable("html")

			vim.lsp.config("cssls", {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "css", "scss", "less" },
			})
			vim.lsp.enable("cssls")
		end,
	},
}
