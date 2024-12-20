return {
    "ellisonleao/gruvbox.nvim", 
    lazy = true,
    config = function() 
        local gb = require('gruvbox')
        gb.setup({
            priority = 1000, config = true
        })
    end
}
