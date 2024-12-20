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

-- Current buffer fuzzy find
vim.keymap.set('n',
    '<leader>fz',
    telescope.current_buffer_fuzzy_find,
    { desc = 'Current Buffer fuzzy find' })

-- [f]ind [m]arks
vim.keymap.set('n',
    '<leader>fm',
    telescope.marks,
    { desc = '[f]ind [m]arks' })

-- find [k]ey [m]ap
vim.keymap.set('n',
    '<leader>km',
    telescope.keymaps,
    { desc = 'find [k]ey [m]ap ' })

-- [f]ind [t]ags
vim.keymap.set('n',
    '<leader>ft',
    telescope.tagstack,
    { desc = '[f]ind [t]ags' })

local nmap = function(keys, func, desc)
    if desc then
        desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
end

nmap('gr',
    require('telescope.builtin').lsp_references,
    '[G]oto [R]eferences')

nmap('<leader>ds',
    require('telescope.builtin').lsp_document_symbols,
    '[D]ocument [S]ymbols')

nmap('<leader>ws',
    require('telescope.builtin').lsp_dynamic_workspace_symbols,
    '[W]orkspace [S]ymbols')

