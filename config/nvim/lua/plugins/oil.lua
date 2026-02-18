return {
	"stevearc/oil.nvim",

	opts = {},
  config = function() 
    require("oil").setup({
      keymaps = {
        ["<A-Enter>"] = false,
        ["<M-Enter>"] = false, 
      },
    })
  end,
	dependencies = { "nvim-tree/nvim-web-devicons" },

	lazy = false,
}
