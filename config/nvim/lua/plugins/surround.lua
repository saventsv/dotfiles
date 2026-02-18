return {
	"echasnovski/mini.surround",
	version = false,
	config = function()
		require("mini.surround").setup({

			mappings = {
				add = "ga",
				delete = "gd",
				find = "gf",
				find_left = "gF",
				highlight = "gh",
				replace = "gr",
				update_n_lines = "gn",
			},
		})

		vim.keymap.set("x", "gs", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
	end,
}
