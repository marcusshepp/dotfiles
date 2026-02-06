-- Escape shortcuts
vim.keymap.set("i", "jj", "<esc>")
vim.keymap.set("n", "<esc>", "<cmd>noh<cr>")

-- Diagnostics (defer loading)
vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Prev error" })
vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next error" })
vim.keymap.set("n", "<leader>e", function() vim.diagnostic.open_float() end, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>q", function() vim.diagnostic.setloclist() end, { desc = "Diagnostic list" })

-- LSP (lazy load on first use)
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, { desc = "Go to declaration" })
vim.keymap.set("n", "gI", function() vim.lsp.buf.implementation() end, { desc = "Go to implementation" })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "Hover docs" })
vim.keymap.set("n", "<C-k>", function() vim.lsp.buf.signature_help() end, { desc = "Signature help" })
vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.rename() end, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code action" })
vim.keymap.set("n", "<leader>D", function() vim.lsp.buf.type_definition() end, { desc = "Type definition" })

-- Quick marks
vim.keymap.set("n", "<leader>a", "'A", { desc = "Jump to mark A" })
vim.keymap.set("n", "<leader>s", "'S", { desc = "Jump to mark S" })
vim.keymap.set("n", "<leader>d", "'D", { desc = "Jump to mark D" })

-- Convenience
vim.keymap.set("n", "<leader>o", "o<esc>", { desc = "New line below" })
vim.keymap.set("n", "<leader>O", "O<esc>", { desc = "New line above" })
vim.keymap.set("n", "<leader>p", 'ggVG"+p', { desc = "Paste over buffer" })
vim.keymap.set("n", "<leader>y", 'ggVG"+y', { desc = "Yank buffer" })
