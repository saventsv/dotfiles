return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local autopairs = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")
		local cond = require("nvim-autopairs.conds")
		autopairs.setup({})
		autopairs.add_rules({
			Rule("<", ">")
				:with_pair(cond.before_regex("[%a%d%.:]", 1))
				:with_pair(cond.not_after_regex("[%a%d]"))
				:with_move(function(opts)
					return opts.char == ">"
				end),
		})
	end,
}
