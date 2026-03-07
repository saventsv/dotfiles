-------------------------------------------------------------------------------
-- 1. GLOBALS & OPTIONS
-------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1


local opt = vim.opt
opt.number = true
opt.rnu = true
opt.cursorline = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.scrolloff = 10
opt.hlsearch = false
opt.expandtab = true
opt.wrap = false
opt.ignorecase = true
opt.termguicolors = true
opt.swapfile = false
opt.autoread = true
opt.showcmd = true
opt.updatetime = 300 
opt.iskeyword:remove({ "_", "-", "(", ")" })
opt.formatoptions:remove({ "c", "r", "o" })
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
vim.opt.showtabline = 0
vim.opt.winbar = nil
vim.opt.undofile = true
vim.opt.timeoutlen = 300

-------------------------------------------------------------------------------
-- 2. AUTOCMDS (Automation)
-------------------------------------------------------------------------------

-- Auto-reload files when they change on disk
local autoreload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then vim.cmd("checktime") end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.INFO)
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 75 })
  end,
})

-- Language Specifics: Rust
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})


-- Language Specifics: Markdown (Merged & Cleaned)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.suffixesadd:append(".md")
    vim.keymap.set("n", "<BS>", "<C-o>", { buffer = true, desc = "Go back" })

    vim.keymap.set("n", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      if line:find("https?://") or line:find("www%.") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gx", true, false, true), "m", true)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gf", true, false, true), "m", true)
      end
    end, { buffer = true, desc = "Follow Link (URL or File)" })
  end,
})

-------------------------------------------------------------------------------
-- 3. KEYMAPPINGS
-------------------------------------------------------------------------------
local set = vim.keymap.set

-- General
set("n", "<C-m>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
set("n", "<leader>q", "<CMD>wq<CR>")
set("n", "<leader>w", "<CMD>w<CR>")
set("n", "<C-s>", "<CMD>w<CR>")
set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")
set("i", "<C-e>", "<C-o>$")
set("i", "<C-Backspace>", "<C-W>", { silent = true })
set("i", "<C-v>", "<C-g>u<C-r><C-o>+", { desc = "Paste from clipboard (no auto-indent)" })  
set("i", "<C-p>", function()
  local text = vim.fn.getreg('"')
  local clean_text = text:gsub("[\n\r]+", " "):gsub("^%s*(.-)%s*$", "%1")
  vim.api.nvim_put({clean_text}, "c", false, true)
end
)

-- UI/Tooling
set("n", "<C-l>", "<CMD>LivePreview start<CR>")
set("n", "<leader>l", "<CMD>LivePreview close<CR>")
set("n", "<leader>rc", ":RemoveComments<CR>", { desc = 'Remove comments', silent = true })
set("n", "<leader>t", "<cmd>Markview toggle<CR>", { desc = "Toggle Markview" })
set("n", "<leader>mc", ":delmarks! | delmarks A-Z0-9<CR>", { desc = "Clear all marks" })
set({'n', 'v'}, '<C-y>', '"+y', { desc = 'Copy to system clipboard' })
set('n', '<leader>Y', '<cmd>%y+<cr>', { desc = 'Copy entire file to clipboard' })
set("n", "<leader>i", "mzgg=G`z", { desc = "Auto-indent entire file" })
set("n", "<leader>e", "$")
set("n", "<leader>s", "^")
set("n", "<leader>z", "zz")

-- Centering Mark jumps (Combined loops)
for _, i in ipairs({ {97, 122}, {65, 90} }) do
  for j = i[1], i[2] do
    local char = string.char(j)
    set("n", "'" .. char, "'" .. char .. "zz")
    set("n", "`" .. char, "`" .. char .. "zz")
  end
end

-------------------------------------------------------------------------------
-- 4. PLUGIN MANAGER (Lazy.nvim)
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

require("terminal")
require("oil").setup({ skip_confirm_for_simple_edits = true })

-- LSP Mappings
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    set('n', 'gd', vim.lsp.buf.definition, opts)
    set('n', 'K', vim.lsp.buf.hover, opts)
    set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3B4252" }) 

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bold = true })
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' }) -- Re-apply transparency
  end,
})




