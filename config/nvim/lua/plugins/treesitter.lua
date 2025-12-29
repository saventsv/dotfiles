return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate', -- automatically run :TSUpdate after installation
  event = 'BufReadPost',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { "c", "lua", "vim", "javascript", "python", "html", "css", "markdown", "markdown_inline"}, -- Parsers you installed
      highlight = {
        enable = true, -- <--- This line enables Treesitter highlighting
      },
      indent = {
        enable = true, -- Enable auto indentation
      },
    })
  end
}
