return {
    {
        "williamboman/mason.nvim",
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function ()
        end,
        setup_handlers = function (server_name)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            require("lspconfig")[server_name].setup{
                capabilities = capabilities,
            }
            
        end,
    },
}
