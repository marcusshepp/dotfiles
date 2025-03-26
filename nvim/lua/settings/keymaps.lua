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

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- Go to next error (skip warnings)
vim.keymap.set('n', ']e', function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)

-- Go to previous error (skip warnings)
vim.keymap.set('n', '[e', function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Marks
vim.keymap.set('n', '<leader>a', '\'A', { desc = 'Jump to mark A' })
vim.keymap.set('n', '<leader>s', '\'S', { desc = 'Jump to mark S' })
vim.keymap.set('n', '<leader>d', '\'D', { desc = 'Jump to mark D' })
vim.keymap.set('n', '<leader>z', '\'Z', { desc = 'Jump to mark Z' })
vim.keymap.set('n', '<leader>x', '\'X', { desc = 'Jump to mark X' })
vim.keymap.set('n', '<leader>c', '\'C', { desc = 'Jump to mark C' })

-- New Lines
vim.keymap.set('n', '<leader>o', 'o<esc>')
vim.keymap.set('n', '<leader>O', 'O<esc>')

-- Format
vim.keymap.set('n', '<leader>=', 'gg=G<C-o>')

-- Replace entire buffer with content of register
vim.keymap.set('n', '<leader>p', 'ggVG"+p')
vim.keymap.set('n', '<leader>c', 'ggVG"+y')

-- restart lsp
vim.keymap.set('n', '<leader>l',
    '<cmd>lua vim.lsp.stop_client(vim.lsp.get_active_clients())<cr>', { desc = 'Stop LSP' })
vim.keymap.set('n', '<leader>ll',
    '<cmd>lua vim.cmd("edit")<cr>', { desc = 'Reload current buffer' })

-- vim.diagnostic.config({ virtual_text = false })
local pcwd = function()
    print(vim.fn.expand('%:p:h'))
end
vim.keymap.set('n',
    '<leader>cwd',
    pcwd,
    { desc = 'Print current working directory' })




local nmap = function(keys, func, desc)
    if desc then
        desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
end

nmap('<leader>rr', vim.lsp.buf.rename, '[R]e[n]ame')
nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
nmap('gh', vim.lsp.buf.hover, '[G]oto [D]efinition')
nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

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
-- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
--     vim.lsp.buf.format()
-- end, { desc = 'Format current buffer with LSP' })
