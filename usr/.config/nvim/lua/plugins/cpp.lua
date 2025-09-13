return {
  -- LSP, Formatter, Linter
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "stevearc/conform.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- C/C++ (clangd)
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = { "/usr/bin/clangd" },
      })

      -- Formatter (conform.nvim)
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          c = { "clang-format" },
          cpp = { "clang-format" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- -- Debugger
  -- {
  --   "mfussenegger/nvim-dap",
  --   config = function()
  --     local dap = require("dap")
  --     -- C/C++ Debug Adapter
  --     dap.adapters.cppdbg = {
  --       id = "cppdbg",
  --       type = "executable",
  --       command = "cpp-debug-adapter",
  --     }
  --
  --     dap.configurations.cpp = {
  --       {
  --         name = "Launch file",
  --         type = "cppdbg",
  --         request = "launch",
  --         program = function()
  --           return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  --         end,
  --         cwd = "${workspaceFolder}",
  --         stopAtEntry = false,
  --       },
  --     }
  --     dap.configurations.c = dap.configurations.cpp
  --   end,
  -- },
  -- {
  --   "rcarriga/nvim-dap-ui",
  --   dependencies = { "mfussenegger/nvim-dap" },
  --   config = function()
  --     local dap = require("dap")
  --     local dapui = require("dapui")
  --
  --     dapui.setup()
  --
  --     dap.listeners.after.event_initialized["dapui_config"] = function()
  --       dapui.open()
  --     end
  --     dap.listeners.before.event_terminated["dapui_config"] = function()
  --       dapui.close()
  --     end
  --     dap.listeners.before.event_exited["dapui_config"] = function()
  --       dapui.close()
  --     end
  --   end,
  -- },
}
