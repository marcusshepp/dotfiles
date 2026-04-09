return {
    -- LSP server installer
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Bridges mason <-> nvim LSP (auto-installs servers)
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "emmet_language_server",
            },
            automatic_installation = true,
        },
    },

    -- Wire up servers using native nvim 0.11 LSP API (no lspconfig needed)
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok, blink = pcall(require, "blink.cmp")
            if ok then
                capabilities = blink.get_lsp_capabilities(capabilities)
            end

            vim.lsp.config("ts_ls", {
                capabilities = capabilities,
            })

            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })

            vim.lsp.config("emmet_language_server", {
                capabilities = capabilities,
            })

            vim.lsp.enable({ "ts_ls", "lua_ls", "emmet_language_server" })
        end,
    },
}
