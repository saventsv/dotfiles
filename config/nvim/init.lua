vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<CR>", "<cmd>Browse<cr>", { buffer = true, desc = "gx.nvim: Open link" })
  end,
})




vim.opt.number = true
vim.opt.rnu = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.scrolloff = 10
vim.opt.hlsearch = false
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.termguicolors = true
vim.opt.iskeyword:remove({ "_", "-" })


vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch', 
      timeout = 75,        
    })
  end,
})


vim.keymap.set("n", "<C-m>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>q", "<CMD>wq<CR>")
vim.keymap.set("n", "<leader>w", "<CMD>w<CR>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-s>", "<CMD>w<CR>")
vim.keymap.set("i", "<C-e>", "<C-o>$")
vim.keymap.set("n", "<C-l>", "<CMD>LivePreview start<CR>")
vim.keymap.set("n", "<leader>l", "<CMD>LivePreview close<CR>")
vim.keymap.set({ "n", "v" }, "<C-y>", '"+y')
vim.keymap.set({ "n", "v" }, "<C-v>", '"+p')
vim.keymap.set("i", "<C-v>", "<C-r>+")
vim.keymap.set('n', '<leader>rc', ':RemoveComments<CR>', { 
      desc = 'Remove all comments from buffer', 
      silent = true 
})



local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--url=github.com",
    "--branch=stable", 
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<CR>", "gf", { buffer = true, desc = "Follow file link" })
    vim.opt_local.suffixesadd:append(".md")
  end,
})

require("terminal")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.suffixesadd:append(".md")
    vim.keymap.set("n", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      if line:find("https?://") or line:find("www%.") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gx", true, false, true), "m", true)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gf", true, false, true), "m", true)
      end
    end, { buffer = true, desc = "Follow Link (URL or File)" })
    vim.keymap.set("n", "<BS>", "<C-o>", { buffer = true, desc = "Go back to previous file" })
  end,
})

vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3B4252" }) 


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})


require("oil").setup ({
  skip_confirm_for_simple_edits = true
})

