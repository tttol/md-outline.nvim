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

local augroup = vim.api.nvim_create_augroup('MdOutline', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = '*.md',
  callback = function()
    local md_outline = require('md-outline')
    if md_outline.config.auto_open then
      vim.schedule(function()
        md_outline.show()
      end)
    end
  end,
})
