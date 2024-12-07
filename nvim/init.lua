local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Marks
vim.keymap.set('n', '<leader>a', '\'A')
vim.keymap.set('n', '<leader>s', '\'S')
vim.keymap.set('n', '<leader>d', '\'D')
vim.keymap.set('n', '<leader>z', '\'Z')
vim.keymap.set('n', '<leader>x', '\'X')
vim.keymap.set('n', '<leader>c', '\'C')

-- New Lines
vim.keymap.set('n', '<leader>o', 'o<esc>')
vim.keymap.set('n', '<leader>O', 'O<esc>')

-- Format
vim.keymap.set('n', '<leader>=', 'gg=G<C-o>')

-- Replace entire buffer with content of register
vim.keymap.set('n', '<leader>p', 'ggVG"*p')

require('lazy').setup({
    'nvim-lualine/lualine.nvim', -- Fancier statusline
    'nvim-telescope/telescope.nvim',
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "nvim-lua/plenary.nvim",
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
        },
    },

    "pmizio/typescript-tools.nvim",
    { -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
    },
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function ()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = { "c", "lua", "vim", "javascript", "html" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    {
        "github/copilot.vim",
        enabled = not vim.g.vscode,
    },
     
    { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},

    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy", -- Or `LspAttach`
        priority = 2000, -- needs to be loaded in first
        config = function()
            require('tiny-inline-diagnostic').setup()
        end
    },

    {
        "sphamba/smear-cursor.nvim",
        opts = {},
    },

    {
        "f-person/git-blame.nvim",
        -- load the plugin at startup
        event = "VeryLazy",
        -- Because of the keys part, you will be lazy loading this plugin.
        -- The plugin wil only load once one of the keys is used.
        -- If you want to load the plugin at startup, add something like event = "VeryLazy",
        -- or lazy = false. One of both options will work.
        opts = {
            -- your configuration comes here
            -- for example
            enabled = true,  -- if you want to enable the plugin
            message_template = "<author> | <summary> • <date>", -- template for the blame message, check the Message template section for more options
            date_format = "%m-%d-%Y %H:%M", -- template for the date, check Date format section for more options
            virtual_text_column = 1,  -- virtual text start column, check Start virtual text at column section for more options
        },

    },

    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<leader>-",
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file",
            },
            {
                "<leader>cw",
                "<cmd>Yazi cwd<cr>",
                desc = "Open the file manager in nvim's working directory" ,
            },
        },
        opts = {
            open_for_directories = false,
            keymaps = {
                show_help = '<f1>',
            },
        },
    }

}, {})

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set('i', 'jj', '<esc>')
vim.keymap.set('n', '<esc>', '<cmd>noh<cr>')


vim.wo.number = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.o.termguicolors = true
vim.opt["tabstop"] = 4
vim.opt["shiftwidth"] = 4
vim.opt.relativenumber = true

-- vim.diagnostic.config({ virtual_text = false })

-- TELESCOPE
local telescope = require('telescope.builtin')
vim.keymap.set('n',
    '<leader>ff',
    telescope.find_files,
    { desc = 'telescope [f]ind [f]iles' })
-- this requires ripgrep
-- https://github.com/burntsushi/ripgrep
vim.keymap.set('n',
    '<leader>fg',
    telescope.live_grep,
    { desc = 'telescope [f]ind symbols using [g]rep' })
-- [f]ind currently open [b]uffers
vim.keymap.set('n',
    '<leader>fb',
    telescope.buffers,
    { desc = 'telescope [f]ind [b]uffers' })


if vim.g.vscode then
    local vsc = require('vscode')
    vsc.notify('Let\'s get shit done\'')

    vim.keymap.set({ 'n' }, '<leader>rr',
        function()
            vim.fn.VSCodeNotify('editor.action.rename')
        end,
        { desc = 'vscode: rename symbol' })

    vim.keymap.set({ 'n' }, 'gr',
        function()
            vim.fn.VSCodeNotify('editor.action.referenceSearch.trigger')
        end, 
        { desc = 'vscode: find references' })

    vim.keymap.set({ 'n' }, '<leader>ff',
        function()
            vim.fn.VSCodeNotify('workbench.action.quickOpen')
        end,
        { desc = 'vscode: fzf' })

else

    -- NEOVIM SPECIFIC ##############################

    vim.opt.signcolumn = 'no'
    vim.o.background = "dark"
    -- vim.cmd.colorscheme = "gruvbox"
    vim.cmd([[colorscheme gruvbox]])
    -- surround
    vim.keymap.set('i', '{', '{}<esc>i')
    vim.keymap.set('i', '(', '()<esc>i')
    vim.keymap.set('i', '[', '[]<esc>i')
    vim.keymap.set('i', '\'', '\'\'<esc>i')
    vim.keymap.set('i', '"', '""<esc>i')


    -- LSP settings.
    --  This function gets run when an LSP connects to a particular buffer.
    local on_attach = function(_, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
            if desc then
                desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rr', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
        nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
    end

    local servers = {
        -- gopls = {},
        pyright = {},
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
    require("lspconfig").lua_ls.setup({settings = {diagnostics = {globals = { "vim"}}}})

    -- Setup neovim lua configuration
    require('neodev').setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- Setup mason so it can manage external tooling
    require('mason').setup()

    -- Ensure the servers above are installed
    local mason_lspconfig = require 'mason-lspconfig'

    mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
    }

    mason_lspconfig.setup_handlers {
        function(server_name)
            require('lspconfig')[server_name].setup {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = servers[server_name],
            }
        end,
    }

    -- nvim-cmp setup
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    luasnip.config.setup {}

    cmp.setup {
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete {},
            ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            },
        },
        sources = {
            { name = 'nvim_lsp', keyword_length = 4 },
            { name = 'luasnip' },
        },
    }
end


-- Set statusbar
require('lualine').setup {
    options = {
        icons_enabled = false,
        component_separators = '|',
        section_separators = '',
    },
}
