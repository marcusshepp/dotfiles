return {
    "https://github.com/neovim/nvim-lspconfig",
    dependencies = {
        {
            "https://github.com/folke/neoconf.nvim",
            opts = {},
        },
    },
    config = function()
        local lsp = require('lspconfig')
        lsp.pyright.setup {}
        lsp.ts_ls.setup {}
        lsp.lua_ls.setup({ settings = { diagnostics = { globals = { "vim" } } } })
        lsp.gopls.setup {}
        lsp.csharp_ls.setup {}
        local nodePath = "C:/Program Files/nodejs/node_modules"
        local alsGlobalPath = nodePath .. "/@angular/language-server"
        local tsGlobalPath = nodePath .. "/typescript"

        local tsProjectPath = vim.fn.getcwd() .. "/node_modules/typescript"

        lsp.angularls.setup({
            cmd = { "node", alsGlobalPath, "--stdio" },
            on_new_config = function(new_config, new_root_dir)
                new_config.cmd = {
                    "node", alsGlobalPath,
                    "--stdio",
                    "--tsProbeLocations", tsProjectPath or tsGlobalPath,
                    "--ngProbeLocations", new_root_dir
                }
            end,
            on_attach = function(client, _)
                print("Language server attached: " .. client.name)
            end,
        })
    end,
}
