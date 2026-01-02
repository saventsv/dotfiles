vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Maps <CR> (Enter) to the gx action specifically in markdown buffers
    vim.keymap.set("n", "<CR>", "<cmd>Browse<cr>", { buffer = true, desc = "gx.nvim: Open link" })
  end,
})

vim.opt.number = true
vim.opt.rnu = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartindent = true

vim.keymap.set("n", "<leader>f", vim.cmd.Ex, { desc = "Open netrw explorer" })
vim.keymap.set("n", "<leader>+", vim.cmd.noh, { desc = "removes hilighting" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })


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

vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3B4252" }) -- Dark Nord grey

