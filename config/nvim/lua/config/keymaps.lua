vim.g.mapleader = " "
vim.g.maplocalleader = " "

local set = vim.keymap.set

-- general
set('n', '<C-d>', '<C-d>zz')
set('n', '<C-u>', '<C-u>zz')
set('i', '<C-Backspace>', '<C-w>', { silent = true })
set({'n', 'v'}, '<C-y>', '"+y', { desc = 'Copy to system clipboard' })
set('i', '<C-v>', '<C-g>u<C-r><C-o>+')
set('n', '<leader>e', vim.diagnostic.open_float)
set('n', 'ge', '$')
set('n', 'gs', '^')
set('n', 'gh', ':nohl<CR>')
set('v', '<leader>r', ':s/')
set('n', '<leader>r', ':%s/')

-- FzfLua
set('n', '<leader>ff', ':FzfLua files<CR>')
set('n', '<leader>fg', ':FzfLua lgrep_curbuf<CR><C-g>')
set('n', '<leader>fG', ':FzfLua live_grep<CR><C-g>')
set('n', '<leader>fw', ':FzfLua grep_cword<CR>')
set('n', '<leader>fh', ':FzfLua help_tags<CR>')
set('n', '<leader>fk', ':FzfLua keymaps<CR>')
set('n', '<leader>fd', ':FzfLua diagnostics_document<CR>')
set('n', '<leader>fD', ':FzfLua diagnostics_workspace<CR>')

-- file explorers
set('n', '<leader>fe', ':Ex<CR>')

-- temporary diable (or permanent idk)
-- set('n', '<C-m>', ':Ex<CR>')
-- set('n', '<C-f>', '<cmd>FzfLua files<cr>')

-- buffers
set('n', '<Tab>', ':bnext<CR>')
set('n', '<S-Tab>', ':bprev<CR>')

set('n', '<C-h>', '<C-w>h')
set('n', '<C-j>', '<C-w>j')
set('n', '<C-k>', '<C-w>k')
set('n', '<C-l>', '<C-w>l')

set('n', '<leader>v', ':vsplit<CR>')
set('n', '<leader>h', ':split<CR>')

set('n', '<leader>c', ':close<CR>')


-- terminal
set('t', '<C-w>', function()
    if vim.bo.buftype == 'terminal' then
        vim.cmd('bd!')
    end
end)

set('n', '<leader>s', ':!')

-- file specific
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    set('i', '<Tab>', '<C-o>:Promote<CR>', { buffer = true })
    set('i', '<S-Tab>', '<C-o>:Demote<CR>', { buffer = true })
  end
})



set('n', '<leader>N', function ()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.cmd.colorscheme('nord')
end)

