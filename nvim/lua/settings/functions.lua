-- Create an autogroup for prettier formatting
local prettier_group = vim.api.nvim_create_augroup("PrettierFormat", { clear = true })

-- Helper function to get parser based on file extension
local function get_parser_for_file(file)
    local ext = vim.fn.fnamemodify(file, ":e")
    local parser_map = {
        js = "babel",
        jsx = "babel",
        ts = "typescript",
        tsx = "typescript",
        css = "css",
        scss = "scss",
        json = "json",
        md = "markdown",
        yaml = "yaml",
        html = "html"
    }
    return parser_map[ext] or ""
end

-- Create the autocmd for formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = prettier_group,
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.scss", "*.json", "*.md", "*.yaml", "*.html" },
    callback = function()
        -- Store the cursor position
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        
        -- Get the current buffer's directory and file path
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir = vim.fn.fnamemodify(current_file, ":h")
        
        -- Get buffer content
        local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
        
        -- Get parser for current file
        local parser = get_parser_for_file(current_file)
        if parser == "" then
            vim.notify("No parser available for this file type", vim.log.levels.WARN)
            return
        end
        
        -- Build prettier command
        local cmd = "prettier --parser=" .. parser
        
        -- Check if .prettierrc exists in current or parent directories
        local config_file = vim.fn.findfile(".prettierrc", current_dir .. ";")
        if config_file ~= "" then
            cmd = cmd .. " --config " .. vim.fn.shellescape(config_file)
        end
        
        -- Create temporary file for the content
        local temp_file = vim.fn.tempname() .. "." .. vim.fn.fnamemodify(current_file, ":e")
        local file = io.open(temp_file, "w")
        if file then
            file:write(content)
            file:close()
            
            -- Create a temporary file for stderr
            local stderr_file = vim.fn.tempname()
            
            -- Format the content using prettier, redirecting stderr to a file
            local formatted = vim.fn.system(cmd .. " " .. vim.fn.shellescape(temp_file) .. " 2> " .. vim.fn.shellescape(stderr_file))
            
            -- Read any error output
            local stderr_handle = io.open(stderr_file, "r")
            local stderr_output = ""
            if stderr_handle then
                stderr_output = stderr_handle:read("*a")
                stderr_handle:close()
            end
            
            -- Clean up temporary files
            os.remove(temp_file)
            os.remove(stderr_file)
            
            if vim.v.shell_error ~= 0 then
                -- If prettier failed, show error
                vim.notify("Prettier error: " .. stderr_output, vim.log.levels.ERROR)
                return
            end
            
            -- Show warnings if any, but continue with formatting
            if stderr_output ~= "" then
                vim.notify(stderr_output, vim.log.levels.WARN)
            end
            
            -- Check if output is not empty
            if formatted ~= "" then
                -- Convert the formatted content back to a table of lines
                local formatted_lines = vim.split(formatted, "\n", { plain = true })
                -- Remove the last empty line that prettier adds
                if formatted_lines[#formatted_lines] == "" then
                    table.remove(formatted_lines)
                end
                
                -- Set the formatted content
                vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_lines)
                
                -- Restore cursor position
                vim.api.nvim_win_set_cursor(0, cursor_pos)
            else
                vim.notify("Prettier produced empty output", vim.log.levels.WARN)
            end
        else
            vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
        end
    end,
})
