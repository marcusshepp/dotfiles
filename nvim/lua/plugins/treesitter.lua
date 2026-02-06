return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()
        require("nvim-treesitter").install({
            "lua", "javascript", "typescript", "tsx", "html", "css", "json", "markdown"
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "lua", "javascript", "typescript", "typescriptreact", "html", "css", "json", "markdown" },
            callback = function()
                vim.treesitter.start()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
