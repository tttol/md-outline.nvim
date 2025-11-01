local M = {}

local window = require('core.window')

local outline_win = nil
local outline_buf = nil

function M.show()
    outline_win, outline_buf = window.show(outline_win, outline_buf)
end

function M.close()
    outline_win, outline_buf = window.close(outline_win, outline_buf)
end

function M.main()
    M.show()
end

return M
