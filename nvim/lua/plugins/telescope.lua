local function filename_first(_, path)
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then
		return tail
	end
	return string.format("%s\t\t%s", tail, parent)
end

return {
    'nvim-telescope/telescope.nvim',
    config = function() 
        local ts = require('telescope')
        ts.setup({
            defaults = {
                path_display = filename_first,
                layout_config = {
                    width = 0.9,
                    height = 0.9,
                },
                file_ignore_patterns = {
                    "node_modules",
                    ".git",
                    ".cache",
                    ".vscode",
                    ".idea",
                    ".DS_Store",
                    ".venv",
                    ".pytest_cache",
                    "__pycache__",
                    ".mypy_cache",
                    ".tox",
                    ".gitignore",
                    ".gitmodules",
                    ".gitattributes",
                    ".gitkeep",
                    ".gitlab-ci.yml",
                    ".gitlab-ci.yml.example",
                },
            },
            pickers = {
                find_files = {
                    theme = "ivy",
                },
                git_files = {
                    theme = "ivy",
                },
                buffers = {
                    theme = "ivy",
                },
                live_grep = {
                    theme = "ivy",
                },
                oldfiles = {
                    theme = "ivy",
                },
                help_tags = {
                    theme = "ivy",
                },
            },
        })
    end
}
