return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local lspconfig = require("lspconfig")

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok, blink = pcall(require, "blink.cmp")
            if ok then
                capabilities = blink.get_lsp_capabilities(capabilities)
            end

            -- TypeScript (globally installed via npm)
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
            })

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })

            -- Emmet (install globally: npm i -g @olrtg/emmet-language-server)
            lspconfig.emmet_ls.setup({
                capabilities = capabilities,
            })
        end,
    },
}
