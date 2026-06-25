-- Options

local opt = vim.opt
local group = vim.g

opt.number = true
opt.rnu = true
opt.wrap = false
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.swapfile = false
group.netrw_banner = 0
group.netrw_browse_split = 0
group.netrw_keepdir = 1
group.netrw_list_hide = [[^\.[^.].*,^\.$]]
opt.expandtab = true
opt.ignorecase = true
opt.iskeyword:remove({ "_", "-", "(", ")", "<", ">" })
opt.formatoptions:remove({ "c", "r", "o" })
opt.undofile = true
group.netrw_fastbrowse = 0
opt.autoindent = true
opt.smartindent = true
opt.smartcase = true
opt.scrolloff = 10
opt.cursorline = true
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignorecase = true
opt.timeout = true
-- opt.timeoutlen = 300
opt.timeoutlen = 250
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.splitright = true
opt.termguicolors = true


-- hilighting when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 75 })
  end,
})

-- lsp config for error messages
vim.diagnostic.config({
  underline = false,

  virtual_text = {
    spacing = 2,
    prefix = "●",
  },

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.INFO] = "»",
      [vim.diagnostic.severity.HINT] = "⚑",
    }
  },

  severity_sort = true,

  float = {
    border = "rounded",
    source = "always",
  },

  update_in_insert = false,
})

-- error when holding cursor over 
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function ()
    vim.diagnostic.open_float(nil, {
      focus = false
    })
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function ()
    vim.lsp.buf.hover({
      focus = false
    })
  end,
})

-- keeping split on terminal close
vim.api.nvim_create_autocmd("TermClose", {
  callback = function()
    vim.cmd("vsplit")
  end,
})


-- note that the order of requires matter so the plugins reqiure should always be first (this is a scoping this)
require("config.plugins")
require("config.lsp")
require("config.cmp")
require("config.keymaps")
