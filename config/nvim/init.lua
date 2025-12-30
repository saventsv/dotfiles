vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.rnu = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = false

vim.keymap.set("n", "<leader>f", vim.cmd.Ex, { desc = "Open netrw explorer" })
vim.keymap.set("n", "<CR>", function()
  local url = vim.fn.expand("<cfile>")

  if url:match("https?://") then
    vim.fn.jobstart({"zen-browser", url}, { detach = true })
  else
    local key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
  end
end, { silent = true })

-- Enable syntax highlighting (it's on by default, but this is explicit)

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--url=github.com",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins defined in the lua/plugins directory
require("lazy").setup("plugins")



-- Source the keymaps file

-- ... (rest of your init.lua file content) ...

-- Make sure the main background and floating windows are transparent
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<CR>", "gf", { buffer = true, desc = "Follow file link" })
    vim.opt_local.suffixesadd:append(".md")
  end,
})

vim.keymap.set("n", "<bs>", ":edit #<cr>", { 
  silent = true, 
  desc = "Markdown: Go back to previous file" 
})

