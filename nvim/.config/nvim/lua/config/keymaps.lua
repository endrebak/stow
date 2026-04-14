-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("t", "<A-s>", [[<C-\><C-n><Cmd>lua require("flash").jump()<CR>]], { desc = "Flash from terminal" })
