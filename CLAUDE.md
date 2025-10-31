# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a NeoVim plugin that displays the outline of markdown files in Neovim. The plugin is written in Lua and follows standard Neovim plugin architecture.

## Architecture
- **Main Module** (`lua/md-outline.lua`): Entry point module that exports the plugin's public API
- **Debug/Development Module** (`lua/md-outline/run.lua`): Development helper that reloads the module for testing. Run `:luafile lua/md-outline/run.lua` in Neovim to reload and test changes without restarting Neovim

## Development Workflow
### Testing During Development
Since this is a Neovim plugin, testing requires running code inside Neovim:
1. Open Neovim in the plugin directory
2. Run `:luafile lua/md-outline/run.lua` to reload the module and test changes
3. The `run.lua` file uses `package.loaded['md-outline'] = nil` to force module reload, avoiding Neovim restart

### Plugin Structure
The plugin follows standard Lua module pattern:
- Modules use `local M = {}` pattern and `return M`
- Public functions are attached to the module table
- Submodules are organized under `lua/md-outline/` directory

## Code Style
- Use Lua module pattern with local table and return statement
- No trailing spaces or empty lines at end of files
- Follow DRY and KISS principles
- Prefer standard library over external dependencies
