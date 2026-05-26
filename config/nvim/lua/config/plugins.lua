-- plugins
vim.pack.add({

  -- misc 
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-lua/plenary.nvim", -- dependancy for harpoon
  {
    src = "https://github.com/ThePrimeagen/harpoon",
    version = "harpoon2",
  },

  -- markdown
  "https://github.com/bullets-vim/bullets.vim",
  "https://github.com/OXY2DEV/markview.nvim",

  -- theme
  "https://github.com/shaunsingh/nord.nvim",

  -- dependancy for fzflua?
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- lsp stuff
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/neovim/nvim-lspconfig", -- dependancy for lsp

  -- file picker
  "https://github.com/ibhagwan/fzf-lua",


})

-- Harpoon
-- local ok, harpoon = pcall(require, "harpoon")
--
-- if not ok then
--   print("Harpoon failed to load")
--   return
-- end
--
-- local set = vim.keymap.set
-- harpoon:setup()
--
-- set('n', '<leader>ha', function() harpoon:list():add() end)
-- set('n', '<leader>he', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
--
-- set('n', '<A-1>', function() harpoon:list():select(1) end)
-- set('n', '<A-2>', function() harpoon:list():select(2) end)
-- set('n', '<A-3>', function() harpoon:list():select(3) end)
-- set('n', '<A-4>', function() harpoon:list():select(4) end)
-- set('n', '<A-5>', function() harpoon:list():select(5) end)


vim.opt.rtp:append("/home/saven/Programming/back-end/mark-it.nvim")

-- config

require("fzf-lua").setup({})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local ok, ts = pcall(require, "nvim-treesitter.configs")
    if not ok then return end
    ts.setup({
      highlight = { enable = true },
      ensure_installed = {
        "lua",
        "go",
        "javascript",
        "typescript",
        "c",
        "cpp",
        "java",
      },
      auto_install = true,
    })
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    local autopairs = require("nvim-autopairs")
    autopairs.setup({})
  end,
})

require("markview").setup({})


-- theming
vim.cmd.colorscheme("nord")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd.colorscheme("nord")
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

    -- vim.cmd.colorscheme("nord-custom")
  end,
})

