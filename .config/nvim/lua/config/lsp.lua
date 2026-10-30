local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }

  vim.keymap.set("n", "gd", function ()
    vim.cmd("vsplit")
    vim.lsp.buf.definition()
  end, opts)

  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

vim.diagnostic.config({
  underline = true,

  virtual_text = {
    spacing = 2,
    prefix = "●",
  },

  severity_sort = true,

  float = {
    border = "rounded",
    source = "always",
  },

  update_in_insert = false,
})

vim.lsp.config("gdscript", {
    cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
    filetypes = { "gdscript" },
    root_markers = { "project.godot", ".git" },
})

vim.lsp.enable("gdscript")
