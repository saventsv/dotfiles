return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<M-f>",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
    },
  },
}
