local M = {}
local term_buf = nil
local term_win = nil
vim.cmd([[highlight CustomTermNormal guibg=#3b4252]])

function M.toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
    return
  end

  if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  vim.cmd("botright sbuffer " .. term_buf)
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_height(term_win, 15)

  if vim.bo[term_buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell)
  end

  vim.wo[term_win].winhl = "Normal:CustomTermNormal"

  vim.cmd("startinsert")
end


local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<M-t>', M.toggle_terminal, opts)
vim.keymap.set('t', '<M-t>', [[<C-\><C-n><cmd>lua require('terminal').toggle_terminal()<CR>]], opts)

return M 
