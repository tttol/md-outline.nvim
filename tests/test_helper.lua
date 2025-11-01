package.path = package.path .. ';./lua/?.lua;./lua/?/init.lua'

local M = {}

function M.reload_module(module_name)
    package.loaded[module_name] = nil
    return require(module_name)
end

return M
