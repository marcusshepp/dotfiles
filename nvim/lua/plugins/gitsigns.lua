return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "-" },
            changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
            delay = 300,
            virt_text_pos = "eol",
        },
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            local map = function(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
            end
            map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle git blame")
            map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, "Full blame popup")
            map("n", "<leader>gd", gs.diffthis, "Diff this file")
            map("n", "]h", gs.next_hunk, "Next hunk")
            map("n", "[h", gs.prev_hunk, "Prev hunk")
        end,
    },
}
