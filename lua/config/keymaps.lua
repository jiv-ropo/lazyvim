-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>rr", function()
  local file = vim.fn.expand("%:p")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.6),
    row = math.floor(vim.o.lines * 0.2),
    col = math.floor(vim.o.columns * 0.1),
    border = "rounded",
  })
  vim.cmd.term(file)
  vim.cmd("startinsert")
end, { desc = "Run current script" })

vim.keymap.set("v", "u", "<esc>:Gdiff<cr>gv:diffget<cr><c-w><c-w>ZZ", { silent = true })

vim.keymap.set("n", "ö", "[", { desc = "Previous motion prefix", remap = true })
vim.keymap.set("n", "ä", "]", { desc = "Next motion prefix", remap = true })

vim.keymap.set("n", "U", "<C-o>:UndotreeToggle<CR><C-w>h", { desc = "Undotree" })

vim.keymap.set("n", "<leader>gc", ":Git commit -v<CR>", { desc = "Git commit verbose" })
vim.keymap.set("n", "<leader>gcn", ":Git commit --no-verify -v<CR>", { desc = "Git commit no-verify verbose" })
vim.keymap.set("n", "<leader>gp", ":Git push --no-verify -v<CR>", { desc = "Git push no-verify verbose" })

vim.keymap.set("n", "<leader>fh", ":set list!<CR>", { desc = "Toggle hidden characters" })

vim.keymap.set({ "n", "i", "v" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

vim.keymap.set({ "n" }, "<M-w>", "<cmd>bd<cr><esc>", { desc = "Delete buffer / Close tab" })
