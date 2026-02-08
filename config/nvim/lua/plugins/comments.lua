return {
	"numToStr/Comment.nvim",
	opts = {},
	keys = {
		{
			"<C-/>",
			function()
				require("Comment.api").toggle.linewise.current()

				vim.api.nvim_feedkeys("A ", "n", true)
			end,
			desc = "Comment line and add space",
		},

		{
			"<C-_>",
			function()
				require("Comment.api").toggle.linewise.current()

				vim.api.nvim_feedkeys("A ", "n", true)
			end,
			mode = "n",
		},

		{
			"<C-/>",
			function()
				require("Comment.api").toggle.linewise.current()

				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>A ", true, false, true), "n", true)
			end,
			mode = "i",
		},
	},
}
