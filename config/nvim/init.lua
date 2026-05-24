-- Options
vim.opt.number = true
vim.opt.rnu = true
vim.opt.wrap = false
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.swapfile = false
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_keepdir = 1
vim.g.netrw_list_hide = [[^\.[^.].*,^\.$]]
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.iskeyword:remove({ "_", "-", "(", ")", "<", ">" })
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.opt.undofile = true
vim.g.netrw_fastbrowse = 0
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 75 })
  end,
})


require("config.keymaps")
require("config.plugins")
require("config.lsp")
require("config.cmp")
