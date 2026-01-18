return {
  'shaunsingh/nord.nvim',
  lazy = false, 
  priority = 1000, 
  config = function()
    vim.g.nord_contrast= false
    vim.g.nord_disable_background = false
    vim.cmd([[colorscheme nord]])
  end,
}

