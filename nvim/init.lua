require("config.lazy")


vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.g.vscode then
    local vsc = require('vscode')
    vsc.notify('Welcome, Marcus.')
    print("foo")

    local whichkey = {
        show = function()
            vim.fn.VSCodeNotify("whichkey.show")
        end
    }

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

    local error = {
        list = function()
            vim.fn.VSCodeNotify("workbench.actions.view.problems")
        end,
        next = function()
            vim.fn.VSCodeNotify("editor.action.marker.next")
        end,
        previous = function()
            vim.fn.VSCodeNotify("editor.action.marker.prev")
        end,
    }

    local editor = {
        closeActive = function()
            vim.fn.VSCodeNotify("workbench.action.closeActiveEditor")
        end,

        closeOther = function()
            vim.fn.VSCodeNotify("workbench.action.closeOtherEditors")
        end,

        organizeImport = function()
            vim.fn.VSCodeNotify("editor.action.organizeImports")
        end
    }

    local workbench = {
        showCommands = function()
            vim.fn.VSCodeNotify("workbench.action.showCommands")
        end,
        previousEditor = function()
            vim.fn.VSCodeNotify("workbench.action.previousEditor")
        end,
        nextEditor = function()
            vim.fn.VSCodeNotify("workbench.action.nextEditor")
        end,
        openSnippets = function()
            vim.fn.VSCodeNotify("workbench.action.openSnippets")
        end,
    }

    local toggle = {
        toggleActivityBar = function()
            vim.fn.VSCodeNotify("workbench.action.toggleActivityBarVisibility")
        end,
        toggleSideBarVisibility = function()
            vim.fn.VSCodeNotify("workbench.action.toggleSidebarVisibility")
        end,
        toggleZenMode = function()
            vim.fn.VSCodeNotify("workbench.action.toggleZenMode")
        end,
        theme = function()
            vim.fn.VSCodeNotify("workbench.action.selectTheme")
        end,
    }

    local symbol = {
        rename = function()
            vim.fn.VSCodeNotify("editor.action.rename")
        end,
    }

    -- if bookmark extension is used
    local bookmark = {
        toggle = function()
            vim.fn.VSCodeNotify("bookmarks.toggle")
        end,
        list = function()
            vim.fn.VSCodeNotify("bookmarks.list")
        end,
        previous = function()
            vim.fn.VSCodeNotify("bookmarks.jumpToPrevious")
        end,
        next = function()
            vim.fn.VSCodeNotify("bookmarks.jumpToNext")
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

    local git = {
        init = function()
            vim.fn.VSCodeNotify("git.init")
        end,
        status = function()
            vim.fn.VSCodeNotify("workbench.view.scm")
        end,
        switch = function()
            vim.fn.VSCodeNotify("git.checkout")
        end,
        deleteBranch = function()
            vim.fn.VSCodeNotify("git.deleteBranch")
        end,
        push = function()
            vim.fn.VSCodeNotify("git.push")
        end,
        pull = function()
            vim.fn.VSCodeNotify("git.pull")
        end,
        fetch = function()
            vim.fn.VSCodeNotify("git.fetch")
        end,
        commit = function()
            vim.fn.VSCodeNotify("git.commit")
        end,
        publish = function()
            vim.fn.VSCodeNotify("git.publish")
        end,

        -- if gitlens installed
        graph = function()
            vim.fn.VSCodeNotify("gitlens.showGraphPage")
        end,
    }

    local fold = {
        toggle = function()
            vim.fn.VSCodeNotify("editor.toggleFold")
        end,

        all = function()
            vim.fn.VSCodeNotify("editor.foldAll")
        end,
        openAll = function()
            vim.fn.VSCodeNotify("editor.unfoldAll")
        end,

        close = function()
            vim.fn.VSCodeNotify("editor.fold")
        end,
        open = function()
            vim.fn.VSCodeNotify("editor.unfold")
        end,
        openRecursive = function()
            vim.fn.VSCodeNotify("editor.unfoldRecursively")
        end,

        blockComment = function()
            vim.fn.VSCodeNotify("editor.foldAllBlockComments")
        end,

        allMarkerRegion = function()
            vim.fn.VSCodeNotify("editor.foldAllMarkerRegions")
        end,
        openAllMarkerRegion = function()
            vim.fn.VSCodeNotify("editor.unfoldAllMarkerRegions")
        end,
    }

    local vscode = {
        focusEditor = function()
            vim.fn.VSCodeNotify("workbench.action.focusActiveEditorGroup")
        end,
        moveSideBarRight = function()
            vim.fn.VSCodeNotify("workbench.action.moveSideBarRight")
        end,
        moveSideBarLeft = function()
            vim.fn.VSCodeNotify("workbench.action.moveSideBarLeft")
        end,
    }

    local refactor = {
        showMenu = function()
            vim.fn.VSCodeNotify("editor.action.refactor")
        end,
    }

    --#region keymap
    vim.g.mapleader = " "
    
    vim.keymap.del({'n'}, {"gr"})

    -- vim.api.nvim_set_keymap('v', 's', '}', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('n', 's', '}', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('v', 'S', '{', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('n', 'S', '{', { noremap = true, silent = true })

    -- vim.api.nvim_set_keymap('v', '<leader>h', '^', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('v', '<leader>l', '$', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('v', '<leader>a', '%', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('n', '<leader>h', '^', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('n', '<leader>l', '$', { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap('n', '<leader>a', '%', { noremap = true, silent = true })

    vim.keymap.set({ 'n', 'v' }, "<leader>/", comment.selected)

    vim.keymap.set({ 'n' }, "<leader>i", editor.organizeImport)

    -- no highlight
    vim.keymap.set({ 'n' }, "<leader>n", "<cmd>noh<cr>")

    vim.keymap.set({ 'n', 'v' }, "<leader> ", workbench.showCommands)

    -- workbench
    vim.keymap.set({ 'n', 'v' }, "H", workbench.previousEditor)
    vim.keymap.set({ 'n', 'v' }, "L", workbench.nextEditor)
    
    -- snippets
    vim.keymap.set({ 'n', 'v' }, "<leader>st", workbench.openSnippets)

    -- error
    vim.keymap.set({ 'n' }, "<leader>el", error.list)
    vim.keymap.set({ 'n' }, "<leader>en", error.next)
    vim.keymap.set({ 'n' }, "<leader>ep", error.previous)

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

    -- buffer/editor
    vim.keymap.set({ 'n', 'v' }, "<space>c", editor.closeActive)
    vim.keymap.set({ 'n', 'v' }, "<space>bc", editor.closeActive)
    vim.keymap.set({ 'n', 'v' }, "<space>k", editor.closeOther)
    vim.keymap.set({ 'n', 'v' }, "<space>bk", editor.closeOther)

    -- toggle
    vim.keymap.set({ 'n', 'v' }, "<leader>ta", toggle.toggleActivityBar)
    vim.keymap.set({ 'n', 'v' }, "<leader>tz", toggle.toggleZenMode)
    vim.keymap.set({ 'n', 'v' }, "<leader>ts", toggle.toggleSideBarVisibility)
    vim.keymap.set({ 'n', 'v' }, "<leader>tt", toggle.theme)

    -- refactor
    vim.keymap.set({ 'v' }, "<leader>r", refactor.showMenu)
    vim.keymap.set({ 'n' }, "<leader>rr", symbol.rename)
    vim.api.nvim_set_keymap('n', '<leader>rd', 'V%d', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader>rv', 'V%', { silent = true })

    -- bookmark
    -- vim.keymap.set({ 'n' }, "<leader>m", bookmark.toggle)
    -- vim.keymap.set({ 'n' }, "<leader>mt", bookmark.toggle)
    -- vim.keymap.set({ 'n' }, "<leader>ml", bookmark.list)
    -- vim.keymap.set({ 'n' }, "<leader>mn", bookmark.next)
    -- vim.keymap.set({ 'n' }, "<leader>mp", bookmark.previous)

    vim.keymap.set({ 'n' }, "gr", search.referenceTrigger)
    vim.keymap.set({ 'n' }, "<leader>sR", search.referenceInSideBar)
    vim.keymap.set({ 'n' }, "<leader>sp", search.project)

    -- vscode
    vim.keymap.set({ 'n' }, "<leader>ve", vscode.focusEditor)
    vim.keymap.set({ 'n' }, "<leader>vl", vscode.moveSideBarLeft)
    vim.keymap.set({ 'n' }, "<leader>vr", vscode.moveSideBarRight)

    --folding
    vim.keymap.set({ 'n' }, "<leader>zr", fold.openAll)
    vim.keymap.set({ 'n' }, "<leader>zO", fold.openRecursive)
    vim.keymap.set({ 'n' }, "<leader>zo", fold.open)
    vim.keymap.set({ 'n' }, "<leader>zm", fold.all)
    vim.keymap.set({ 'n' }, "<leader>zb", fold.blockComment)
    vim.keymap.set({ 'n' }, "<leader>zc", fold.close)
    vim.keymap.set({ 'n' }, "<leader>zg", fold.allMarkerRegion)
    vim.keymap.set({ 'n' }, "<leader>zG", fold.openAllMarkerRegion)
    vim.keymap.set({ 'n' }, "<leader>za", fold.toggle)

    vim.keymap.set({ 'n' }, "zr", fold.openAll)
    vim.keymap.set({ 'n' }, "zO", fold.openRecursive)
    vim.keymap.set({ 'n' }, "zo", fold.open)
    vim.keymap.set({ 'n' }, "zm", fold.all)
    vim.keymap.set({ 'n' }, "zb", fold.blockComment)
    vim.keymap.set({ 'n' }, "zc", fold.close)
    vim.keymap.set({ 'n' }, "zg", fold.allMarkerRegion)
    vim.keymap.set({ 'n' }, "zG", fold.openAllMarkerRegion)
    vim.keymap.set({ 'n' }, "za", fold.toggle)
    --#endregion keymap
else
end
