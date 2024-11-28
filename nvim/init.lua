local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)



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
                ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "c_sharp" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        "seblj/roslyn.nvim",
        ft = "cs",
        opts = {
            -- your configuration comes here; leave empty for default settings
        }
    },
    {
        "github/copilot.vim"
    },
    { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...}
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
--
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

    local comment = {
        selected = function()
            vim.fn.VSCodeNotifyRange("editor.action.commentLine", vim.fn.line("v"), vim.fn.line("."), 1)
        end
    }

    local file = {
        new = function()
            vim.fn.VSCodeNotify("workbench.explorer.fileView.focus")
            vim.fn.VSCodeNotify("explorer.newFile")
        end,

        save = function()
            vim.fn.VSCodeNotify("workbench.action.files.save")
        end,

        saveAll = function()
            vim.fn.VSCodeNotify("workbench.action.files.saveAll")
        end,

        format = function()
            vim.fn.VSCodeNotify("editor.action.formatDocument")
        end,

        showInExplorer = function()
            vim.fn.VSCodeNotify("workbench.files.action.showActiveFileInExplorer")
        end,

        rename = function()
            vim.fn.VSCodeNotify("workbench.files.action.showActiveFileInExplorer")
            vim.fn.VSCodeNotify("renameFile")
        end
    }

    local symbol = {
        rename = function()
            vim.fn.VSCodeNotify("editor.action.rename")
        end,
    }

    local search = {
        referenceTrigger = function()
            vim.fn.VSCodeNotify("editor.action.referenceSearch.trigger")
        end,
        referenceInSideBar = function()
            vim.fn.VSCodeNotify("references-view.find")
        end,
        project = function()
            vim.fn.VSCodeNotify("editor.action.addSelectionToNextFindMatch")
            vim.fn.VSCodeNotify("workbench.action.findInFiles")
        end,
        text = function()
            vim.fn.VSCodeNotify("workbench.action.findInFiles")
        end,
    }

    local project = {
        fuzzyFindFile = function()
            vim.fn.VSCodeNotify("workbench.action.quickOpen")
        end,
        explorer = function()
            vim.fn.VSCodeNotify("workbench.view.explorer")
        end,
    }

    --#region keymap
    vim.keymap.set({ 'n', 'v' }, "<leader>/", comment.selected)
    -- no highlight
    vim.keymap.set({ 'n' }, "<leader>n", "<cmd>noh<cr>")

    -- project
    vim.keymap.set({ 'n' }, "<leader>p", project.fuzzyFindFile)
    vim.keymap.set({ 'n' }, "<leader>a", project.explorer)

    -- file
    vim.keymap.set({ 'n', 'v' }, "<space>w", file.save)
    vim.keymap.set({ 'n', 'v' }, "<space>wa", file.saveAll)
    vim.keymap.set({ 'n', 'v' }, "<space>fs", file.save)
    vim.keymap.set({ 'n', 'v' }, "<space>fS", file.saveAll)
    vim.keymap.set({ 'n' }, "<space>ff", file.format)
    vim.keymap.set({ 'n' }, "<space>fn", file.new)
    vim.keymap.set({ 'n' }, "<space>ft", file.showInExplorer)
    vim.keymap.set({ 'n' }, "<space>fr", file.rename)
    vim.keymap.set({ 'n' }, "<leader>rr", symbol.rename)

    vim.keymap.set({ 'n' }, "gr", search.referenceTrigger)
    vim.keymap.set({ 'n' }, "<leader>sR", search.referenceInSideBar)
    vim.keymap.set({ 'n' }, "<leader>sp", search.project)

    vim.keymap.set({ 'n' }, '<leader>ff', project.fuzzyFindFile)
else

    -- NEOVIM SPECIFIC ##############################

    vim.opt.signcolumn = 'no'
    -- require("zbirenbaum/copilot.lua").setup()
    -- require('zbirenbaum/copilot.lua').load()
    -- require('github/copilot.vim').setup({})
    -- require('github/copilot.vim').load()
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

    -- surround
    vim.keymap.set('i', '{', '{}<esc>i')
    vim.keymap.set('i', '(', '()<esc>i')
    vim.keymap.set('i', '[', '[]<esc>i')
    vim.keymap.set('i', '\'', '\'\'<esc>i')
    vim.keymap.set('i', '"', '""<esc>i')

    -- Diagnostic keymaps
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)



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

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
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

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. They will be passed to
    --  the `settings` field of the server config. You must look up that documentation yourself.
    local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- tsserver = {},

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
            -- ['<Tab>'] = cmp.mapping(function(fallback)
            --     if cmp.visible() then
            --         cmp.select_next_item()
            --     elseif luasnip.expand_or_jumpable() then
            --         luasnip.expand_or_jump()
            --     else
            --         fallback()
            --     end
            -- end, { 'i', 's' }),
            -- ['<S-Tab>'] = cmp.mapping(function(fallback)
            --     if cmp.visible() then
            --         cmp.select_prev_item()
            --     elseif luasnip.jumpable(-1) then
            --         luasnip.jump(-1)
            --     else
            --         fallback()
            --     end
            -- end, { 'i', 's' }),
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
