return {
  "bullets-vim/bullets.vim",
  ft = { "markdown" },
  init = function()
    vim.g.bullets_enabled_file_types = { "markdown" }
    vim.g.bullets_set_mappings = 1
  end,
}

