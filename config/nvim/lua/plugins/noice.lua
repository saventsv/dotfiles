return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lsp = {
      hover = { enabled = false },
      signature = { enabled = false },
    },
    popupmenu = { enabled = false },
  },
  config = function(_, opts)
    require("noice").setup(opts)

    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#88C0D0", bold = true })
  end,
}
