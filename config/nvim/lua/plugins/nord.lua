return {
  'shaunsingh/nord.nvim',
  lazy = false, -- Load this plugin on startup
  priority = 1000, -- Ensure the colorscheme loads before other plugins
  config = function()
    require('nord').set({
      -- Options for Nord theme
      nord_contrast = true,       -- Make sidebars/popups slightly darker
      nord_disable_background = true, -- Set background to transparent by default
      nord_italic = false,
      nord_bold = false,
    })
  end,
}
