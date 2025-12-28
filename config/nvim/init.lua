vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.rnu = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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



