require('settings.keymaps')

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {})

require('settings.plugin-keymaps')
require('settings.settings')

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
    -- require("lspconfig").lua_ls.setup({ settings = { diagnostics = { globals = { "vim" } } } })
end


