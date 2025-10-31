-- This file is a debug file for development. Run `luafile lua/run.lua` when you want to debug this plugin.
vim.opt.runtimepath:append(vim.fn.getcwd())

package.loaded['md-outline'] = nil

local mdOutline = require('md-outline')
mdOutline.main()

