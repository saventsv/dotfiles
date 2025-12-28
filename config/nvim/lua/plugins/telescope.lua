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

    -- >>> MOVE YOUR KEYMAPS HERE <<<
    local builtin = require('telescope.builtin')

    -- Map <C-f> to find files (hides dotfiles by default in the CWD/project folder)
    vim.keymap.set('n', '<C-f>', builtin.find_files, { desc = 'Find files (CWD)' })

    -- Map <Leader>fh (space + f + h) to find files, including hidden dotfiles in the CWD
    vim.keymap.set('n', '<leader>fh', function()
        builtin.find_files({ hidden = true })
    end, { desc = 'Find hidden files (CWD)' })
    
    -- Function to search only your HOME directory (not system root)
    local function find_home_files()
      builtin.find_files({
        -- Set the starting directory to the home directory path (~/home/saven)
        cwd = vim.fn.expand('~'),
        hidden = true, -- Usually helpful to show all files in home search
      })
    end
    
    -- Map <Leader>fh (space + f + h) to the home directory search
    vim.keymap.set('n', '<leader>fh', find_home_files, { desc = 'Find files in Home Dir' })
    -- Note: I changed the keymap here from <leader>ff to <leader>fh to match the description.
    -- If you preferred <leader>ff, change find_home_files line above back to find_all_files.


    -- Optional: Map <C-g> to live_grep
    vim.keymap.set('n', '<C-g>', builtin.live_grep, { desc = 'Live Grep (Telescope)' })
    -- >>> END KEYMAPS <<<

  end
}
