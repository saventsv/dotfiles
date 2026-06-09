vim.g.mapleader = " "
vim.g.maplocalleader = " "

local set = vim.keymap.set

-- General
set('n', '<C-d>', '<C-d>zz')
set('n', '<C-u>', '<C-u>zz')
set('i', '<C-Backspace>', '<C-w>', { silent = true })
-- set({'n', 'v'}, '<C-y>', '"+y', { desc = 'Copy to system clipboard' })
set({'n'; 'v'}, '<leader>cc', '"+y', { desc = 'Copy to system clipboard' })
set('i', '<C-v>', '<C-g>u<C-r><C-o>+')
set('n', '<leader>e', vim.diagnostic.open_float)
set('n', 'ge', '$')
set('n', 'gs', '^')
set('n', 'gh', ':nohl<CR>')
set('v', '<leader>rs', ':s/')
set('n', '<leader>rf', ':%s/')
set('n', '<leader>rl', ':s/')
set('n', '<leader>rw', [[:s/\<<C-r><C-w>\>//g<Left><Left>]])
set('n', '<leader>in', '<C-a>')
set('n', '<leader>hs', ':split<CR>')
set('n', '<leader>vs', ':vsplit<CR>')
set('n', '<leader>cl', 'gcc', {remap = true})


-- mini surround
require("mini.surround").setup({
  mappings = {
    add = "ga",
    delete = "gd",
    replace = "gr",
    find = "gf",
    find_left = "gF",
    -- highlight = "gh",
    update_n_lines = "gn",

    suffix_last = "l",
    suffix_next = "n",
  },
  custom_surroundings = {
    ["("] = { output = { left = "(", right = ")" } },
    [")"] = { output = { left = "( ", right = " )" } },

    ["<"] = { output = { left = "<", right = ">" } },
    [">"] = { output = { left = "< ", right = " >" } },

    ["["] = { output = { left = "[", right = "]" } },
    ["]"] = { output = { left = "[ ", right = " ]" } },

    ["{"] = { output = { left = "{", right = "}" } },
    ["}"] = { output = { left = "{ ", right = " }" } },
  },
})

-- Harpoon
local harpoon = require("harpoon")

harpoon:setup()

set('n', '<leader>ha', function() harpoon:list():add() end)
set('n', '<leader>he', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

set('n', '<A-1>', function() harpoon:list():select(1) end)
set('n', '<A-2>', function() harpoon:list():select(2) end)
set('n', '<A-3>', function() harpoon:list():select(3) end)
set('n', '<A-4>', function() harpoon:list():select(4) end)
set('n', '<A-5>', function() harpoon:list():select(5) end)


-- FzfLua
set('n', '<leader>ff', ':FzfLua files<CR>')
set('n', '<leader>fg', ':FzfLua lgrep_curbuf<CR><C-g>')
set('n', '<leader>fG', ':FzfLua live_grep<CR><C-g>')
set('n', '<leader>fw', ':FzfLua grep_cWORD<CR>')
set('n', '<leader>fh', ':FzfLua help_tags<CR>')
set('n', '<leader>fk', ':FzfLua keymaps<CR>')
set('n', '<leader>fd', ':FzfLua diagnostics_document<CR>')
set('n', '<leader>fD', ':FzfLua diagnostics_workspace<CR>')
set('n', '<leader>fb', ':FzfLua buffers<CR>')

-- file explorers
-- set('n', '<leader>fe', ':Ex<CR>')
set('n', '<leader>fe', ':Oil<CR>')

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

-- terminal
set('t', '<C-h>', [[<C-\><C-N><C-w>h]])
set('t', '<C-j>', [[<C-\><C-N><C-w>j]])
set('t', '<C-k>', [[<C-\><C-N><C-w>k]])
set('t', '<C-l>', [[<C-\><C-N><C-w>l]])

set('n', '<leader>vs', ':vsplit<CR>')
set('n', '<leader>hs', ':split<CR>')

set('n', '<leader>cb', ':close<CR>')


-- terminal
set('t', '<C-w>', function()
  if vim.bo.buftype == 'terminal' then
    vim.cmd('bd!')
  end
end)

set('n', '<leader>sh', ':!')
set('n', '<leader>ss', ':silent!!')

-- quickfix list
set('n', '<leader>ca', ':silent! grepadd ')
set('n', '<leader>co', ':copen<CR>')
-- set('n', '<leader>cc', ':cclose<CR>')
set('n', '<leader>cd', ':cexpr []<CR>')

-- file specific
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- set('i', '<Tab>', '<C-o>:Promote<CR>', { buffer = true })
    -- set('i', '<S-Tab>', '<C-o>:Demote<CR>', { buffer = true })
    set('n', '<leader>tt', ':Markview<CR>', { buffer = true })
  end
})

