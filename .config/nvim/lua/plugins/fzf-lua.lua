return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {},
  config = function() 
    vim.keymap.set('n', '<leader>ff', ':FzfLua files<CR>')
    vim.keymap.set('n', '<leader>rg', ':FzfLua live_grep<CR><C-g>')
  end,
  ---@diagnostic enable: missing-fields
}
