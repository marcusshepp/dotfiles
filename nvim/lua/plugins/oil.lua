return {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
        { "<leader>-", "<cmd>Oil<cr>", desc = "Oil file explorer" },
    },
    opts = {
        default_file_explorer = true,
        view_options = { show_hidden = true },
    },
}
