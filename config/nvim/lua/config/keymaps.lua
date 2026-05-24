vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<C-m>', ':Ex<CR>')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('i', '<C-Backspace>', '<C-w>', { silent = true })
vim.keymap.set({'n', 'v'}, '<C-y>', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set("i", "<C-v>", "<C-g>u<C-r><C-o>+")
vim.keymap.set('n', '<C-f>', '<cmd>FzfLua files<cr>')


