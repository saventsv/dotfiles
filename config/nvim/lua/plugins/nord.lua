return {
  'shaunsingh/nord.nvim',
  lazy = false, -- Load this during startup
  priority = 1000, -- Load this before all other plugins
  config = function()
    -- Set the colorscheme
    vim.cmd([[colorscheme nord]])
  end,
}

