return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
        { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume" },
        { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Marks" },
        { "<leader>km", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
        { "gr", "<cmd>Telescope lsp_references<cr>", desc = "LSP references" },
        { "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        defaults = {
            layout_config = { width = 0.9, height = 0.9 },
            file_ignore_patterns = { "node_modules", ".git", ".cache", "__pycache__" },
        },
        pickers = {
            find_files = { theme = "ivy" },
            live_grep = { theme = "ivy" },
            buffers = { theme = "ivy" },
        },
    },
}
