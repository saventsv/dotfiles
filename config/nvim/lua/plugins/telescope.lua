return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = { 
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } 
  },
  config = function()
    require('telescope').setup({}) 
    require('telescope').load_extension('fzf')

    local builtin = require('telescope.builtin')

    vim.keymap.set('n', '<C-f>', builtin.find_files, { desc = 'Find files (CWD)' })

    vim.keymap.set('n', '<leader>fh', function()
        builtin.find_files({ hidden = true })
    end, { desc = 'Find hidden files (CWD)' })
    
    local function find_home_files()
      builtin.find_files({
        cwd = vim.fn.expand('~'),
        hidden = true,
      })
    end
    
    vim.keymap.set('n', '<leader>fh', find_home_files, { desc = 'Find files in Home Dir' })


    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep (Telescope)' })

  end
}
