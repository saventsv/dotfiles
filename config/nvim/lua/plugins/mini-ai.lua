return {
	"echasnovski/mini.ai",
	version = "*",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	config = function()
		local ai = require("mini.ai")
		ai.setup({
			n_lines = 500,
			custom_textobjects = {

				f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
				c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),

				a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),

				o = ai.gen_spec.treesitter({
					a = { "@conditional.outer", "@loop.outer" },
					i = { "@conditional.inner", "@loop.inner" },
				}),
			},
		})
	end,
}
