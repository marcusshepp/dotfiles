-- Create an autogroup for prettier formatting
local prettier_group = vim.api.nvim_create_augroup("PrettierFormat", { clear = true })

-- Create the autocmd for formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = prettier_group,
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.scss", "*.json", "*.md", "*.yaml", "*.html" },
    callback = function()
        -- Store the cursor position
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        -- Get the current buffer's directory and traverse up to find .prettierrc
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir = vim.fn.fnamemodify(current_file, ":h")
        
        -- Store the current buffer content as backup
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        
        -- Format command base
        local cmd = "prettier --write"
        
        -- Check if .prettierrc exists in current or parent directories
        local config_file = vim.fn.findfile(".prettierrc", current_dir .. ";")
        if config_file ~= "" then
            cmd = cmd .. " --config " .. vim.fn.shellescape(config_file)
        end
        
        -- Add the current file to the command
        cmd = cmd .. " " .. vim.fn.shellescape(current_file)
        
        -- Execute prettier with timeout
        local timer = vim.loop.new_timer()
        local done = false
        
        timer:start(0, 0, vim.schedule_wrap(function()
            local output = vim.fn.system(cmd)
            done = true
            
            if vim.v.shell_error ~= 0 then
                -- If prettier failed, notify and keep original content
                vim.notify("Prettier error: " .. output, vim.log.levels.ERROR)
                vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            else
                -- Read the formatted file content
                local formatted_lines = vim.fn.readfile(current_file)
                if #formatted_lines == 0 then
                    -- If the file is empty after formatting, restore backup
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                    vim.notify("Prettier produced empty output, restored original content", vim.log.levels.WARN)
                end
            end
            
            -- Restore cursor position
            vim.api.nvim_win_set_cursor(0, cursor_pos)
        end))
        
        -- Add a safety timeout
        vim.defer_fn(function()
            if not done then
                timer:stop()
                vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                vim.notify("Prettier timed out, restored original content", vim.log.levels.WARN)
                vim.api.nvim_win_set_cursor(0, cursor_pos)
            end
        end, 5000) -- 5 second timeout
    end,
})
