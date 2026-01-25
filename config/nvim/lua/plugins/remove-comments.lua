return  {
  'KashifKhn/nvim-remove-comments',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-remove-comments').setup()
  end
}
