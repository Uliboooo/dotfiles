return {
    {
        "saecki/crates.nvim",
        tag = "stable",
        config = function()
            require("crates").setup()
        end,
    },

    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        lazy = false,
        ft = {"rust"},
        config = function ()
            local cap = require("cmp_nvim_lsp").default_capabilities()
            vim.g.rustaceanvim = {
                server = {
                    settings = {
                        ["rust-analyzer"] = {
                            check = {
                                command = "clippy"
                            },
                            checkOnSave = true,
                            inlayHints = {
                                -- enable = true,
                                typeHints = true,
                                changingHints = true,
                                parameterHints = true,
                                closureReturnTypeHints = "always",
                                -- enable = true,
                            },
                            parameterHints = {
                                enable = true,
                            }
                        },
                    },
                },
                -- on_attach = function (client, bufnr)
                --     if client.server_capabilities.inlayHintProvider then
                --         vim.lsp.inlay_hint.enable(bufnr, true)
                --     end
                -- end,
                dap = {
                    adapters = {
                        {
                            type = "executable",
                            name = "lldb",
                            command = "rust-debug-adapter",
                        },
                    },
                },
            }
        end
    },
}
