local on_attach = function(_, bufnr)
	local opts = { buffer = bufnr }

	vim.keymap.set("n", "gd", function ()
    vim.cmd("vsplit")
    vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function setup(server, config)
	vim.lsp.config(server, vim.tbl_deep_extend("force", {
		on_attach = on_attach,
		capabilities = capabilities,
	}, config or {}))
end

setup("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})


-- TODO fix this
vim.lsp.config("gdscript", {
    cmd = { "nc", "127.0.0.1", "6005" },
    filetypes = { "gd", "gdscript" },
    root_markers = { "project.godot" },
})

vim.lsp.enable("gdscript")


setup("gopls")
-- setup("bashls")
setup("ts_ls")
setup("clangd")
setup("jdtls")
setup("nixd")

vim.lsp.enable({
	"gopls",
	"lua_ls",
  "ts_ls",
  "nixd",
	-- "bashls",
	"clangd",
	"jdtls",
})

