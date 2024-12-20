return {
    {
        "williamboman/mason.nvim",
        opts = { PATH = "append" },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {},
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                "basedpyright",
                "biome",
                "clangd",
                "cmake",
                "eslint",
                "goimports",
                "golangci-lint",
                "golangci_lint_ls",
                "gopls",
                "jsonls",
                "lua_ls",
                "marksman",
                "prettierd",
                "stylua",
                "ts_ls",
            },
        },
    },
}
