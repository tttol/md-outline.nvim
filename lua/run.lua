-- This file is a debug file for development. Run `luafile lua/run.lua` when you want to debug this plugin.
vim.opt.runtimepath:append(vim.fn.getcwd())

local lua_path = vim.fn.getcwd() .. '/lua/?.lua;' .. vim.fn.getcwd() .. '/lua/?/init.lua'
package.path = package.path .. ';' .. lua_path

package.loaded['md-outline'] = nil
package.loaded['core.window'] = nil
package.loaded['core.string'] = nil

local mdOutline = require('md-outline')
mdOutline.main()

