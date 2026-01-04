return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>gg",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
    },
  },
}
