return {
  "chrishrb/gx.nvim",
  keys = { { "<gx>", "<cmd>Browse<cr>", mode = { "n", "x" } } },
  cmd = { "Browse" },
  init = function ()
    vim.g.netrw_nogx = 1 -- Kill the broken wget behavior
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    open_browser_app = "zen-browser", -- Directly tell it to use Zen
    handlers = {
      plugin = true, -- handles github plugins
    }
  }
}
