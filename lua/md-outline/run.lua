-- This file is a debug file for development. Run `luafile lua/md-outline/run.lua` when you want to debug this plugin.
vim.opt.runtimepath:append(vim.fn.getcwd())

package.loaded['md-outline'] = nil

local md_outline = require('md-outline')
md_outline.main()
