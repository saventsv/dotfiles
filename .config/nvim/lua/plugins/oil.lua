return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  config = function() 
    require("oil").setup({
      skip_confirm_for_simple_edits = true,
      delete_to_trash = false,
      view_options = {
        show_hidden = true,
        natural_order = true,
        case_insentsitive = true,
      },
    })

    vim.keymap.set('n', '<leader>fe', ':Oil<CR>')
  end,
  lazy = false,
}
