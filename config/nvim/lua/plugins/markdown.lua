return {
    "OXY2DEV/markview.nvim",
    lazy = false, -- Recommended by the author to avoid slow loading
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons" -- For icons
    },
    config = function()
        require("markview").setup()
    end
}

