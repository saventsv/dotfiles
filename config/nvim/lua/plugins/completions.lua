return {
  {
    'Saghen/blink.cmp',
    version = '*', -- Use latest stable release
    dependencies = 'rafamadriz/friendly-snippets',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- Change preset to 'enter' to use the Return key for accepting
      -- This also keeps C-y working as a fallback
      keymap = { 
        preset = 'enter',
      },

      completion = {
        list = {
          selection = {
            -- Set to 'manual' if you don't want the first item auto-selected
            -- Set to 'preselect' (default) if you want Enter to immediately 
            -- accept the top suggestion without hitting arrow keys first
            preselect = true, 
          }
        },
        -- Enable signature help for Python/JS parameter hints
        menu = { auto_show = true },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

    },
  },
}

