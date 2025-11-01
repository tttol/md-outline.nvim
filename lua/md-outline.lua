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

function M.close()
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
        vim.api.nvim_win_close(outline_win, true)
    end
    outline_win = nil
    outline_buf = nil
end

function M.show()
    local headings = M.extractHeadings()

    outline_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, headings)

    vim.api.nvim_set_option_value('modifiable', false, {buf = outline_buf})
    vim.api.nvim_set_option_value('buftype', 'nofile', {buf = outline_buf})

    local width = 40
    local height = #headings
    outline_win = vim.api.nvim_open_win(outline_buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = vim.o.columns - width,
        row = 0,
        style = 'minimal',
        border = 'single'
    })

    vim.api.nvim_buf_set_keymap(outline_buf, 'n', 'q', ':lua require("md-outline").close()<CR>', {
        noremap = true,
        silent = true
    })
end

function M.main()
    M.show()
end

return M
