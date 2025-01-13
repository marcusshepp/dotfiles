-- Create an autogroup for prettier formatting
local prettier_group = vim.api.nvim_create_augroup("PrettierFormat", { clear = true })

-- Create the autocmd for formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = prettier_group,
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.scss", "*.json", "*.md", "*.yaml", "*.html" },
    callback = function()
        -- Get the current buffer's directory and traverse up to find .prettierrc
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir = vim.fn.fnamemodify(current_file, ":h")

        -- Format command base
        local cmd = "prettier --write"

        -- Check if .prettierrc exists in current or parent directories
        local config_file = vim.fn.findfile(".prettierrc", current_dir .. ";")
        if config_file ~= "" then
            cmd = cmd .. " --config " .. vim.fn.shellescape(config_file)
        end

        -- Add the current file to the command
        cmd = cmd .. " " .. vim.fn.shellescape(current_file)

        -- Execute prettier
        local output = vim.fn.system(cmd)

        -- Check if there was an error
        if vim.v.shell_error ~= 0 then
            vim.notify("Prettier error: " .. output, vim.log.levels.ERROR)
        else
            -- Reload the buffer to show changes
            vim.cmd("e!")
        end
    end,
})
