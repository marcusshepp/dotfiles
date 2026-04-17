return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        heading = {
            sign = false,
            width = "block",
            left_pad = 1,
            right_pad = 2,
            above = " ",
            below = " ",
            backgrounds = {},
        },
        indent = {
            enabled = true,
            per_level = 2,
            skip_level = 1,
        },
        code = {
            sign = false,
            width = "block",
            border = "thin",
            left_pad = 2,
            right_pad = 2,
            disable_background = true,
        },
        pipe_table = {
            preset = "round",
            style = "full",
            cell = "padded",
        },
        checkbox = { enabled = true },
    },
}
