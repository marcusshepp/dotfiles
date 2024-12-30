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
            },
        })
    end
}
