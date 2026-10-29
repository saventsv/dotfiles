vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set({"n"; "v"}, "<leader>y", "\"+y")
vim.keymap.set("n", "gh", ":nohlsearch<CR>")
vim.keymap.set("n", "<leader>tw", ":set wrap!<CR>")
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("v", "<leader>rs", ":s//g<Left><Left>")

-- Buffers
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")

vim.keymap.set("n", "<leader>vs", ":vsplit<CR>")
vim.keymap.set("n", "<leader>hs", ":split<CR>")

vim.keymap.set("n", "<leader>cb", ":close<CR>")
