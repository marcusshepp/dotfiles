vim.opt.signcolumn = 'no'
vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])
-- vim.cmd([[colorscheme americano]])
-- require('americano').colorscheme()
vim.cmd [[
      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none
      ]]

require('mason').setup()
local servers = {
    -- gopls = {},
    ts_ls = {},
    emmet_ls = {
        emmet = {
            triggerExpansionOnTab = false,
            triggerExpansionOnEnter = true,
            keyword_length = 5,
        },
    },
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

local blink = require 'blink.cmp'
local lspconfig = require 'lspconfig'
local mason_lspconfig = require 'mason-lspconfig'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = blink.get_lsp_capabilities(capabilities)

-- Ensure the servers above are installed
mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

local on_attach = function(_, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

mason_lspconfig.setup_handlers {
    function(server_name)
        lspconfig[server_name].setup {
            capabilities = capabilities,
            settings = servers[server_name],
            on_attach = on_attach,
        }
    end,
}


blink.setup {
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    opts = {
        keymap = { preset = 'default' },
        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = 'normal',
        },
        signature = { enabled = true },
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
            } 
        }
    },
    opts_extend = { 'sources.default' },
}
