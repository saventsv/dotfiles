return {
  'goolord/alpha-nvim',
  event = "VimEnter", 
  config = function ()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')

    -- 1. Set your ASCII Art
    -- dashboard.section.header.val = {
      --   [[                               __                ]],
      --   [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      --   [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      --   [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      --   [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      --   [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
      --   [[                                                 ]],
      --   [[                - NEOVIM EDITOR -                 ]],
      -- }

      dashboard.section.header.val = {
        [[ ░███    ░██ ░██████████   ░██████   ░██    ░██ ░██████░███     ░███ ]],
        [[ ░████   ░██ ░██          ░██   ░██  ░██    ░██   ░██  ░████   ░████ ]],
        [[ ░██░██  ░██ ░██         ░██     ░██ ░██    ░██   ░██  ░██░██ ░██░██ ]],
        [[ ░██ ░██ ░██ ░█████████  ░██     ░██ ░██    ░██   ░██  ░██ ░████ ░██ ]],
        [[ ░██  ░██░██ ░██         ░██     ░██  ░██  ░██    ░██  ░██  ░██  ░██ ]],
        [[ ░██   ░████ ░██          ░██   ░██    ░██░██     ░██  ░██       ░██ ]],
        [[ ░██    ░███ ░██████████   ░██████      ░███    ░██████░██       ░██ ]],
        [[                                                                     ]],
        [[                              - Neovim -                             ]],
      }

      dashboard.section.buttons.val = {}
      dashboard.section.footer.val = {}

      alpha.setup(dashboard.config)
    end, 
  }
