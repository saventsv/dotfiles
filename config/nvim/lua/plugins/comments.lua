return {
  "numToStr/Comment.nvim",
  opts = {},
  keys = {
    {
      "<C-/>",
      function()
        require("Comment.api").toggle.linewise.current()

        vim.api.nvim_feedkeys("A ", "n", true)
      end,
      desc = "Comment line and add space",
    },

    {
      "<C-_>",
      function()
        require("Comment.api").toggle.linewise.current()
        vim.api.nvim_feedkeys("A ", "n", true)
      end,
    },
  },
}
