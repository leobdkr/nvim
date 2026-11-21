-- ~/.config/nvim/after/ftplugin/markdown.lua

-- Soft-wrap prose instead of the global nowrap
vim.opt_local.wrap = true
vim.opt_local.linebreak = true   -- break at word boundaries
vim.opt_local.breakindent = true -- keep list indentation on wrapped lines
vim.opt_local.colorcolumn = ""

vim.opt_local.spell = true

-- Move by screen line over wrapped lines, unless a count is given (5j)
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true })
