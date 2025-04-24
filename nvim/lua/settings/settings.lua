-- Editor UI settings
vim.opt.signcolumn = 'no'
vim.opt.background = "dark"  -- Changed from vim.o for consistency
vim.opt.termguicolors = true

-- Folding configuration
vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 6  -- Higher value keeps more folds open by default

-- Colorscheme settings
vim.cmd([[colorscheme gruvbox]])

-- Transparent background settings
vim.cmd([[
    highlight Normal guibg=none
    highlight NonText guibg=none
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none
]])

-- LSP and completion setup
local safe_require = function(module)
    local ok, result = pcall(require, module)
    if not ok then
        vim.notify("Failed to load " .. module, vim.log.levels.WARN)
        return nil
    end
    return result
end

-- Initialize Mason for LSP server management
local mason = safe_require('mason')
if mason then
    mason.setup()
end

-- Language server configurations
local servers = {
    -- gopls = {},  -- Golang server (currently disabled)
    ts_ls = {},     -- TypeScript server
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

-- Set up LSP and completions
local blink = safe_require('blink.cmp')
local lspconfig = safe_require('lspconfig')
local mason_lspconfig = safe_require('mason-lspconfig')

if blink and lspconfig and mason_lspconfig then
    -- Configure capabilities for LSP
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = blink.get_lsp_capabilities(capabilities)

    -- Ensure required LSP servers are installed
    mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
    }

    -- Define LSP attachment behavior
    local on_attach = function(_, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
    end

    -- Setup each language server
    mason_lspconfig.setup_handlers {
        function(server_name)
            lspconfig[server_name].setup {
                capabilities = capabilities,
                settings = servers[server_name],
                on_attach = on_attach,
            }
        end,
    }

    -- Configure completion with Blink
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
end

