-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_prettier_needs_config = false

-- Set global indentation to 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.list = false
vim.opt.listchars = "eol:$,tab:>-,trail:~,extends:>,precedes:<"

vim.filetype.add({
  extension = {
    mdx = "markdown",
  },
})
