return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    config = function ()
        local y = require('yazi')
        y.setup({
            keys = {
                {
                    "<leader>-",
                    "<cmd>Yazi<cr>",
                    desc = "Open yazi at the current file",
                },
                {
                    "<leader>cw",
                    "<cmd>Yazi cwd<cr>",
                    desc = "Open the file manager in nvim's working directory",
                },
            },
            opts = {
                open_for_directories = false,
                keymaps = {
                    show_help = '<f1>',
                },
            },
        })

    end
}
