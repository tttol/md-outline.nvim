# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a NeoVim plugin that displays the outline of markdown files in Neovim. The plugin is written in Lua and follows standard Neovim plugin architecture.

## Architecture
- **Main Module** (`lua/md-outline.lua`): Entry point module that exports the plugin's public API (`show()`, `close()`, `main()`)
- **Core Modules**:
  - `lua/core/window.lua`: Window management for creating and closing the outline split window
  - `lua/core/string.lua`: String operations for extracting headings and creating indented outlines
- **Plugin Commands** (`plugin/commands.lua`): User command definitions (`:MdoOpen`, `:MdoClose`)
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

## User Commands
- `:MdoOpen` - Open the markdown outline in a split window on the right
- `:MdoClose` - Close the outline window
- `q` key (in outline window) - Close the outline window
