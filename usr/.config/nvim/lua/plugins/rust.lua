-- rust.lua

return {
    {
        "saecki/crates.nvim",
        tag = "stable",
        config = function()
            require("crates").setup()
        end,
    },
    --
    -- {
    --     "williamboman/mason.nvim",
    --     opts = {
    --         ensure_installed = {
    --             "codelldb",
    --         },
    --     },
    -- },

    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        lazy = false,
        ft = { 'rust' },
    },

    {
      'cordx56/rustowl',
      version = '*', -- Latest stable version
      build = 'cargo binstall rustowl',
      lazy = false, -- This plugin is already lazy
      opts = {},
    },
}
