return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<M-g>",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
    },
  },
}
