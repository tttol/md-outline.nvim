if vim.g.loaded_md_outline then
  return
end
vim.g.loaded_md_outline = true

vim.api.nvim_create_user_command('MdoOpen', function()
  require('md-outline').show()
end, {})

vim.api.nvim_create_user_command('MdoClose', function()
  require('md-outline').close()
end, {})
