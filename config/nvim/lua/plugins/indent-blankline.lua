return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl", -- Required for v3+
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    indent = {
      char = "▎",
    },
    scope = { -- Added the '=' here
      enabled = true,
      show_start = false,
    },
    exclude = {
      filetypes = { "help", "dashboard", "neo-tree", "lazy" },
    },
  },
}

