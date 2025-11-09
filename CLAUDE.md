# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a NeoVim plugin that displays the outline of markdown files in Neovim. The plugin is written in Lua and follows standard Neovim plugin architecture.

## Architecture
- **Main Module** (`lua/md-outline.lua`): Entry point module that exports the plugin's public API (`show()`, `close()`, `setup()`) and manages plugin configuration
- **Core Modules**:
  - `lua/core/window.lua`: Window and buffer management for creating, updating, and closing the outline split window. Handles automatic outline management on buffer switch via autocmds
  - `lua/core/string.lua`: String operations for extracting headings and creating indented outlines
- **Plugin Commands** (`plugin/commands.lua`): User command definitions (`:MdoOpen`, `:MdoClose`) and auto-open functionality via BufEnter autocmd
- **Debug/Development Module** (`lua/run.lua`): Development helper that reloads modules for testing. Run `:luafile lua/run.lua` in Neovim to reload and test changes without restarting Neovim

## Development Workflow
### Testing During Development
Since this is a Neovim plugin, testing requires running code inside Neovim:
1. Open Neovim in the plugin directory
2. Run `:luafile lua/run.lua` to reload the module and test changes
3. The `run.lua` file uses `package.loaded` to force module reload, avoiding Neovim restart
4. Module search paths are configured in `run.lua` to properly resolve `core.*` modules

### Unit Testing
The project uses Busted for unit testing:
- Test files are located in `tests/` directory
- Test helper (`tests/test_helper.lua`) configures module paths for test environment
- Run tests locally: `busted tests/`
- GitHub Actions automatically runs tests on push and pull requests

### Plugin Structure
The plugin follows standard Lua module pattern:
- Modules use `local M = {}` pattern and `return M`
- Public functions are attached to the module table
- Core modules are organized under `lua/core/` directory
- Test files use `*_spec.lua` naming convention

## Code Style
- Use Lua module pattern with local table and return statement
- No trailing spaces or empty lines at end of files
- Follow DRY and KISS principles
- Prefer standard library over external dependencies
- Write pure functions where possible (accept parameters instead of reading global state)
- Follow AAA pattern for tests: Arrange, Act, Assert

### Documentation Comments
All functions should have documentation comments in the following format:
```lua
-- Brief description of what the function does
-- @param param_name type: Description of the parameter
-- @return type: Description of the return value
local function function_name(param_name)
  -- implementation
end
```
Example:
```lua
-- Check if the buffer name matches the outline buffer pattern
-- @param buf_name string: Buffer name to check
-- @return boolean: True if buffer is an outline buffer, false otherwise
local function is_outline_buffer(buf_name)
  return buf_name:match('md%-outline$') ~= nil
end
```

## Features
### Automatic Outline Management
- **Auto-open on markdown files**: When `auto_open` is enabled (default), the outline automatically opens when entering a markdown file
- **Auto-update on buffer switch**: When switching between markdown files, the outline content automatically updates to match the current file
- **Auto-close on non-markdown files**: When switching from a markdown file to a non-markdown file, the outline automatically closes
- **Real-time content updates**: The outline updates in real-time as you edit the markdown file (on TextChanged/TextChangedI events)
- **Real-time heading highlight**: The current heading is highlighted in the outline as you move the cursor (on CursorMoved/CursorMovedI events)

### Configuration
Use the `setup()` function to configure the plugin:
```lua
require('md-outline').setup({
  auto_open = true  -- Enable/disable automatic outline opening (default: true)
})
```

## User Commands
- `:MdoOpen` - Manually open the markdown outline in a split window on the right
- `:MdoClose` - Close the outline window

## Implementation Details
### Autocmd Groups
The plugin uses several autocmd groups for different features:
- `MdOutline` (in `plugin/commands.lua`): Handles auto-open on BufEnter for `*.md` files
- `MdOutlineHighlight` (in `lua/core/window.lua`): Updates heading highlight on cursor movement
- `MdOutlineContents` (in `lua/core/window.lua`): Updates outline content on text changes
- `MdOutlineAutoClose` (in `lua/core/window.lua`): Manages outline on buffer switch (update/create/close based on buffer type)
