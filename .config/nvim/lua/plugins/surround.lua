return {
  {
    "nvim-mini/mini.surround",
    version = "*",
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = "ga",
          delete = "gd",
          replace = "gr",

          suffix_last = "l",
          suffix_next = "n",
        },
        custom_surroundings = {
          ["("] = { output = { left = "(", right = ")" } },
          [")"] = { output = { left = "( ", right = " )" } },

          ["<"] = { output = { left = "<", right = ">" } },
          [">"] = { output = { left = "< ", right = " >" } },

          ["["] = { output = { left = "[", right = "]" } },
          ["]"] = { output = { left = "[ ", right = " ]" } },

          ["{"] = { output = { left = "{", right = "}" } },
          ["}"] = { output = { left = "{ ", right = " }" } },
        },
      })
    end,
  },
}

