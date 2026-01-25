return {
  'brianhuster/live-preview.nvim',
  dependencies = { 
    'nvim-telescope/telescope.nvim', 
  },
  opts = {
    port = 5500,
    browser = "zen-browser", 
  },
}
