local M = {}

local string = require('core.string')

local ns_id = vim.api.nvim_create_namespace('md_outline')

local OUTLINE_WINDOW_WIDTH = 40

-- Check if the buffer name matches the outline buffer pattern
-- @param buf_name string: Buffer name to check
-- @return boolean: True if buffer is an outline buffer, false otherwise
local function is_outline_buffer(buf_name)
    return buf_name:match('md%-outline$') ~= nil
end

-- Check if the file name is a markdown file
-- @param file_name string: File name to check
-- @return boolean: True if file is a markdown file (*.md), false otherwise
local function is_markdown_file(file_name)
    return file_name:match('%.md$') ~= nil
end

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

-- Update outline buffer contents with formatted headings from markdown lines
-- @param lines table: Array of lines from the markdown file
-- @param buf number: Buffer number of the outline window
-- @return number|nil: Buffer number on success, nil if buffer is invalid
local function write_buffer_contents(lines, buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return nil
    end

    -- enable to modify buffer temporary
    vim.api.nvim_set_option_value('modifiable', true, {buf = buf})

    local headings = string.extractHeadings(lines)
    local outlines = string.createOutline(headings)
    table.insert(outlines, "")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, outlines)
    vim.highlight.range(buf, ns_id, 'Comment', {#outlines - 1, 0}, {#outlines - 1, -1})

    -- disable to modify buffer
    vim.api.nvim_set_option_value('modifiable', false, {buf = buf})
    return buf
end

-- Close the outline window and clean up autocmds
-- @param outline_win number: Window number of the outline window
-- @return nil, nil: Returns nil for outline_win
function M.close(outline_win)
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
        local buf = vim.api.nvim_win_get_buf(outline_win)
        vim.api.nvim_win_close(outline_win, true)
        if buf and vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
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
local function create_outline_buffer(lines)
    -- delete previous outline buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if is_outline_buffer(buf_name) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end

    local new_outline_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(new_outline_buf, 'md-outline')
    new_outline_buf = write_buffer_contents(lines, new_outline_buf)

    vim.api.nvim_set_option_value('modifiable', false, {buf = new_outline_buf})
    vim.api.nvim_set_option_value('buftype', 'nofile', {buf = new_outline_buf})

    vim.cmd('vsplit')
    vim.cmd('wincmd L')
    local new_outline_win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(new_outline_win, new_outline_buf)
    vim.api.nvim_win_set_width(new_outline_win, OUTLINE_WINDOW_WIDTH)

    return new_outline_win, new_outline_buf
end

-- Show the markdown outline in a split window
-- @return number: Returns outline_win
function M.show()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_is_valid(buf) then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if is_outline_buffer(buf_name) then
                write_buffer_contents(vim.api.nvim_buf_get_lines(0, 0, -1, false), buf)
                vim.notify('Outline updated for current buffer')
                return win
            end
        end
    end

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
    local new_outline_win, new_outline_buf = create_outline_buffer(lines)

    if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
    end

    -- autocmd for highlight on cursor meved
    vim.api.nvim_create_augroup('MdOutlineHighlight', {clear = true})
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        group = 'MdOutlineHighlight',
        buffer = source_buf_local,
        callback = function()
            if vim.api.nvim_buf_is_valid(new_outline_buf) and vim.api.nvim_buf_is_valid(source_buf_local) then
                update_highlight(new_outline_buf, source_buf_local)
            end
        end,
    })

    -- autocmd for updating a buffer on text changed
    vim.api.nvim_create_augroup('MdOutlineContents', {clear = true})
    vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
        group = 'MdOutlineContents',
        buffer = source_buf_local,
        callback = function()
            if vim.api.nvim_buf_is_valid(new_outline_buf) then
                write_buffer_contents(vim.api.nvim_buf_get_lines(0, 0, -1, false), new_outline_buf)
            end
        end
    })

    -- autocmd for automatically creating/updating/closing buffer on buffer switch(=BufEnter)
    vim.api.nvim_create_augroup('MdOutlineAutoClose', {clear = true})
    vim.api.nvim_create_autocmd('BufEnter', {
        group = 'MdOutlineAutoClose',
        callback = function()
            local current_buf_name = vim.api.nvim_buf_get_name(0)

            if is_outline_buffer(current_buf_name) then
                return
            end

            if is_markdown_file(current_buf_name) then
                -- current buffer is *.md
                local outline_exists = false
                local outline_buf = nil
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.api.nvim_buf_is_valid(buf) then
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if is_outline_buffer(buf_name) then
                            outline_exists = true
                            outline_buf = buf
                            break
                        end
                    end
                end

                if outline_exists and outline_buf then

                    if vim.api.nvim_buf_is_valid(outline_buf) then
                        local current_buf = vim.api.nvim_get_current_buf()
                        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                        write_buffer_contents(lines, outline_buf)

                        local heading_positions = {}
                        for i, line in ipairs(lines) do
                            if line:match("^#+%s+") then
                                table.insert(heading_positions, {line = i, text = line})
                            end
                        end
                        vim.b[current_buf].md_outline_positions = heading_positions

                        vim.api.nvim_create_augroup('MdOutlineHighlight', {clear = true})
                        vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
                            group = 'MdOutlineHighlight',
                            buffer = current_buf,
                            callback = function()
                        if vim.api.nvim_buf_is_valid(outline_buf) and vim.api.nvim_buf_is_valid(current_buf) then
                                    update_highlight(outline_buf, current_buf)
                                end
                            end,
                        })

                        vim.api.nvim_create_augroup('MdOutlineContents', {clear = true})
                        vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
                            group = 'MdOutlineContents',
                            buffer = current_buf,
                            callback = function()
                                if vim.api.nvim_buf_is_valid(outline_buf) then
                                    write_buffer_contents(vim.api.nvim_buf_get_lines(0, 0, -1, false), outline_buf)
                                end
                            end
                        })

                        update_highlight(outline_buf, current_buf)
                    end
                else
                    vim.schedule(function()
                        M.show()
                    end)
                end
            else
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.api.nvim_buf_is_valid(buf) then
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if is_outline_buffer(buf_name) then
                            M.close(win)
                            vim.notify('Outline closed')
                            return
                        end
                    end
                end
            end
        end
    })

    update_highlight(new_outline_buf, source_buf_local)

    return new_outline_win
end

return M
