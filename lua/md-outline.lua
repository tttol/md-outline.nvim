local M = {}

local window = require('core.window')

local outline_win = nil

M.config = {
  auto_open = true
}

function M.show()
    outline_win = window.show()
end

function M.close()
    outline_win = window.close(outline_win)
end

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})
end

function M.main()
    M.show()
    vim.notify('md-outline\'s buffer is opened')
end

return M
