return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- 1. Initialize Mason
      require("mason").setup()
      
      local servers = { 
        "pyright", -- Python
        "html",    -- HTML
        "cssls",   -- CSS
        "ts_ls"    -- JavaScript
      }

      -- 2. Ensure Mason installs the binaries
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })

      -- 3. Use the 0.11+ native API to enable servers
      -- This avoids the "require('lspconfig') is deprecated" error
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      -- 4. Keybindings via the native LspAttach event
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- Go to Definition
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- Hover documentation
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- Code Actions
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)      -- Refactor Rename
        end,
      })
    end,
  },
}

