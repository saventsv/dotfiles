-- plugins
vim.pack.add({
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/bullets-vim/bullets.vim",
	"https://github.com/OXY2DEV/markview.nvim",
	"https://github.com/shaunsingh/nord.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/ibhagwan/fzf-lua",
})

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
  end,
})
