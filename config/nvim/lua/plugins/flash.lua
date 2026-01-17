return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<C-g>",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
    },
  },
}
