local M = {}

local string = require('core.string')

local ns_id = vim.api.nvim_create_namespace('md_outline')

-- Find the index of the heading that contains the cursor position
-- @param cursor_line number: Current cursor line number
-- @param positions table: Array of heading positions with line numbers
-- @return number|nil: Index of the current heading, or nil if not found
local function find_current_heading(cursor_line, positions)
    local current_heading_idx = nil
    for i, pos in ipairs(positions) do
        if pos.line <= cursor_line then
            current_heading_idx = i
        else
            break
        end
    end
    return current_heading_idx
end

-- Update the highlight in the outline buffer based on cursor position in source buffer
-- @param outline_buf_local number: Buffer number of the outline window
-- @param source_buf_local number: Buffer number of the source markdown file
local function update_highlight(outline_buf_local, source_buf_local)
    if not outline_buf_local or not vim.api.nvim_buf_is_valid(outline_buf_local) then
        return
    end

    if not source_buf_local or not vim.api.nvim_buf_is_valid(source_buf_local) then
        return
    end

    local heading_positions = vim.b[source_buf_local].md_outline_positions or {}
    local prev_highlight = vim.b[outline_buf_local].md_outline_highlight_line

    if prev_highlight then
        vim.api.nvim_buf_clear_namespace(outline_buf_local, ns_id, prev_highlight, prev_highlight + 1)
    end

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor_pos[1]

    local heading_idx = find_current_heading(cursor_line, heading_positions)
    if heading_idx then
        local highlight_line = heading_idx - 1
        vim.highlight.range(outline_buf_local, ns_id, 'Visual', {highlight_line, 0}, {highlight_line, -1})
        vim.b[outline_buf_local].md_outline_highlight_line = highlight_line
    end
end

local function create_buffer_contents(lines, buf)
     -- enable to modify buffer temporary
    vim.api.nvim_set_option_value('modifiable', true, {buf = buf})

    local headings = string.extractHeadings(lines)
    local outlines = string.createOutline(headings)
    local footer = "press q to close this window..."
    table.insert(outlines, "")
    table.insert(outlines, footer)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, outlines)
    vim.highlight.range(buf, ns_id, 'Comment', {#outlines - 1, 0}, {#outlines - 1, -1})

    vim.api.nvim_set_option_value('modifiable', false, {buf = buf})
    return buf
end

-- Close the outline window and clean up autocmds
-- @param outline_win number: Window number of the outline window
-- @return nil, nil: Returns nil for outline_win
function M.close(outline_win)
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
        vim.api.nvim_win_close(outline_win, true)
    end

    vim.api.nvim_clear_autocmds({
        group = 'MdOutlineHighlight'
    })
    vim.api.nvim_clear_autocmds({
        group = 'MdOutlineContents'
    })

    return nil
end

-- Create and configure the outline window with buffer
-- @param lines table: Array of lines from the source markdown file
-- @return number, number: Returns outline_win and outline_buf
function M.createOutlineBuffer(lines)
    local new_outline_buf = vim.api.nvim_create_buf(false, true)
    new_outline_buf = create_buffer_contents(lines, new_outline_buf)

    vim.api.nvim_set_option_value('modifiable', false, {buf = new_outline_buf})
    vim.api.nvim_set_option_value('buftype', 'nofile', {buf = new_outline_buf})

    vim.cmd('vsplit')
    vim.cmd('wincmd L')
    local new_outline_win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(new_outline_win, new_outline_buf)
    vim.api.nvim_win_set_width(new_outline_win, 40)

    vim.api.nvim_buf_set_keymap(new_outline_buf, 'n', 'q', ':lua require("md-outline").close()<CR>', {
        noremap = true,
        silent = true
    })

    return new_outline_win, new_outline_buf
end

-- Show the markdown outline in a split window
-- @return number: Returns outline_win
function M.show()
    local current_win = vim.api.nvim_get_current_win()
    local source_buf_local = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local heading_positions = {}
    for i, line in ipairs(lines) do
        if line:match("^#+%s+") then
            table.insert(heading_positions, {line = i, text = line})
        end
    end

    vim.b[source_buf_local].md_outline_positions = heading_positions
    local new_outline_win, new_outline_buf = M.createOutlineBuffer(lines)

    vim.api.nvim_set_current_win(current_win)
    vim.api.nvim_create_augroup('MdOutlineHighlight', {clear = true})
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        group = 'MdOutlineHighlight',
        buffer = source_buf_local,
        callback = function()
            update_highlight(new_outline_buf, source_buf_local)
        end,
    })

    vim.api.nvim_create_augroup('MdOutlineContents', {clear = true})
    vim.api.nvim_create_autocmd('TextChangedI', {
        group = 'MdOutlineContents',
        buffer = source_buf_local,
        callback = function()
            create_buffer_contents(vim.api.nvim_buf_get_lines(0, 0, -1, false), new_outline_buf)
        end
    })

    update_highlight(new_outline_buf, source_buf_local)

    return new_outline_win
end

return M
