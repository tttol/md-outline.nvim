local M = {}

local string = require('core.string')

function M.close(outline_win, outline_buf)
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
        vim.api.nvim_win_close(outline_win, true)
    end
    outline_win = nil
    outline_buf = nil

    return outline_win, outline_buf
end

function M.show(outline_win, outline_buf)
    local current_win = vim.api.nvim_get_current_win()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local headings = string.extractHeadings(lines)
    local outlines = string.createOutline(headings)

    outline_buf = vim.api.nvim_create_buf(false, true)

    local footer = "press q to close this window..."
    table.insert(outlines, "")
    table.insert(outlines, footer)

    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, outlines)

    vim.api.nvim_set_option_value('modifiable', false, {buf = outline_buf})
    vim.api.nvim_set_option_value('buftype', 'nofile', {buf = outline_buf})

    vim.cmd('vsplit')
    vim.cmd('wincmd L')
    outline_win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(outline_win, outline_buf)
    vim.api.nvim_win_set_width(outline_win, 40)

    local ns_id = vim.api.nvim_create_namespace('md_outline')
    vim.highlight.range(outline_buf, ns_id, 'Comment', {#outlines - 1, 0}, {#outlines - 1, -1})

    vim.api.nvim_buf_set_keymap(outline_buf, 'n', 'q', ':lua require("md-outline").close()<CR>', {
        noremap = true,
        silent = true
    })

    vim.api.nvim_set_current_win(current_win)

    return outline_win, outline_buf
end

return M
