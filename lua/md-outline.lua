local M = {}

local window = require('core.window')

local outline_win = nil

function M.show()
    outline_win = window.show()
end

function M.close()
    outline_win = window.close(outline_win)
end

function M.main()
    M.show()
end

return M
