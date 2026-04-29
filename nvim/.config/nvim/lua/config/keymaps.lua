-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("t", "<A-s>", [[<C-\><C-n><Cmd>lua require("flash").jump()<CR>]], {
  desc = "Flash from terminal",
})

vim.keymap.set(
  "t",
  "<A-l>",
  [[<C-\><C-n><Cmd>lua require("flash").jump({
  search = { mode = "search", max_length = 0 },
  label = { after = { 0, 0 } },
  pattern = "^",
})<CR>]],
  {
    desc = "Flash lines from terminal",
  }
)

vim.keymap.set("t", "<PageUp>", [[<C-\><C-n><C-b>]], {
  desc = "Exit terminal and scroll up",
})
