local M = {}
local outline_win = nil
local outline_buf = nil

function M.extractHeadings()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local headings = {}

    for _, line in ipairs(lines) do
        if line:match("^#+%s+") then
            table.insert(headings, line)
        end
    end

    return headings
end

function M.createOutline(headings)
    local outlines = {}
    for _, h in ipairs(headings) do
        local sharp_count = 0
        for _, char in h:gmatch('.') do
            if char == '#' then
                sharp_count = sharp_count + 1
            else
                break
            end
        end
        local indent = string.rep("    ", sharp_count)
        local outline = indent .. h
        table.insert(outlines, outline)
    end
end

function M.close()
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
        vim.api.nvim_win_close(outline_win, true)
    end
    outline_win = nil
    outline_buf = nil
end

function M.show()
    local current_win = vim.api.nvim_get_current_win()
    local headings = M.extractHeadings()

    outline_buf = vim.api.nvim_create_buf(false, true)

    local footer = "press q to close this window..."
    table.insert(headings, "")
    table.insert(headings, footer)

    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, headings)

    vim.api.nvim_set_option_value('modifiable', false, {buf = outline_buf})
    vim.api.nvim_set_option_value('buftype', 'nofile', {buf = outline_buf})

    vim.cmd('vsplit')
    vim.cmd('wincmd L')
    outline_win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(outline_win, outline_buf)
    vim.api.nvim_win_set_width(outline_win, 40)

    local ns_id = vim.api.nvim_create_namespace('md_outline')
    vim.highlight.range(outline_buf, ns_id, 'Comment', {#headings - 1, 0}, {#headings - 1, -1})

    vim.api.nvim_buf_set_keymap(outline_buf, 'n', 'q', ':lua require("md-outline").close()<CR>', {
        noremap = true,
        silent = true
    })

    vim.api.nvim_set_current_win(current_win)
end

function M.main()
    M.show()
end

return M
