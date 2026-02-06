return {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "v0.*",
    opts = {
        keymap = { preset = "default" },
        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "normal",
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
    },
}
