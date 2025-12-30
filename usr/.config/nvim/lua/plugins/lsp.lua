return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        }),

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    event = { "BufReadPre", "BufNewFile" },
    lazy = false,
    config = function()
      vim.diagnostic.config({
        virtual_text = false,
        update_in_insert = false,
        -- float = {
        --   border = "rounded",
        --   source = "always",
        -- },
      })

      -- Make diagnostic float transparent
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Defined as no-op to satisfy existing references in vim.lsp.config calls below
      local on_attach = function(client, bufnr) end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

          vim.api.nvim_create_autocmd("BufEnter", {
            callback = function(args)
              if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
              end
            end,
          })

          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = function()
              vim.diagnostic.open_float(nil, {
                focusable = false,
                close_events = { "CursorMoved", "CursorMovedI", "BufLeave" },
                border = "rounded",
                source = "always",
                prefix = " ",
                scope = "cursor",
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
