return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    config = function()
      vim.keymap.set("n", "<leader>tt", "<cmd>Markview toggle<cr>")
    end,

    -- Completion for `blink.cmp`
    -- dependencies = { "saghen/blink.cmp" },
};
