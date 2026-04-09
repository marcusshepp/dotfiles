return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            install = { compilers = { "gcc", "clang" } },
            auto_install = true,
            ensure_installed = {
                "lua",
                "javascript",
                "typescript",
                "tsx",
                "html",
                "css",
                "json",
                "markdown",
                "markdown_inline",
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "lua", "javascript", "typescript", "typescriptreact", "html", "css", "json", "markdown" },
            callback = function()
                pcall(vim.treesitter.start)
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
