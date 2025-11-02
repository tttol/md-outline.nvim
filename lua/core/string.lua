local M = {}

function M.extractHeadings(lines)
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
        for char in h:gmatch('.') do
            if char == '#' then
                sharp_count = sharp_count + 1
            else
                break
            end
        end
        local indent = string.rep("    ", sharp_count - 1)
        local text = h:gsub("^#+%s*", "")
        table.insert(outlines, indent .. text)
    end

    return outlines
end

return M
