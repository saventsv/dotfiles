--[[ return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").setup({})
    require("telescope").load_extension("fzf")

    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<C-f>", builtin.find_files, { desc = "Find files (CWD)" })

    vim.keymap.set("n", "<C-h>", function()
      require("telescope.builtin").find_files({
        prompt_title = "CWD Dotfiles (Safe)",
        cwd = vim.fn.getcwd(),
        hidden = true,
        no_ignore = true,
        search_file = ".*",
      })
    end, { desc = "Search only dotfiles in CWD" })

    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep (Telescope)" })
  end,
}

--]]

return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})
    
    telescope.load_extension("fzf")

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', "<C-f>", builtin.find_files)
  end,
}
