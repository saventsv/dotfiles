return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      { "folke/lazydev.nvim", ft = "lua", opts = {} }, 
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {"html", "cssls", "ts_ls", "lua_ls", "clangd" },
      })

      local blink = require('blink.cmp')

      vim.lsp.config('*', {
        capabilities = blink.get_lsp_capabilities()
      })
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
          }
        }
      })
      vim.lsp.enable({"html", "cssls", "ts_ls", "lua_ls", "clangd"})

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },
}
