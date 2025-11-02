local helper = require('tests.test_helper')

describe("core/string test", function()
    local string

    before_each(function()
        string = helper.reload_module("core.string")
    end)

    describe("extractHeadings", function()
        before_each(function()
            -- Setup vim global mock
            _G.vim = _G.vim or {}
            _G.vim.api = _G.vim.api or {}
        end)

        it("should extract all markdown headings from buffer", function()
            -- Arrange
            local buffer_lines = {
                "# Heading 1",
                "Some text",
                "## Heading 2",
                "More text",
                "### Heading 3",
            }
            vim.api.nvim_buf_get_lines = function() return buffer_lines end

            local expected = {
                "# Heading 1",
                "## Heading 2",
                "### Heading 3",
            }

            -- Act
            local actual = string.extractHeadings()

            -- Assert
            assert.are.same(expected, actual)
        end)

        it("should return empty table when no headings exist", function()
            -- Arrange
            local buffer_lines = {
                "Just some text",
                "No headings here",
                "Still no headings",
            }
            vim.api.nvim_buf_get_lines = function() return buffer_lines end

            local expected = {}

            -- Act
            local actual = string.extractHeadings()

            -- Assert
            assert.are.same(expected, actual)
        end)

        it("should handle various heading levels", function()
            -- Arrange
            local buffer_lines = {
                "# H1",
                "## H2",
                "### H3",
                "#### H4",
                "##### H5",
                "###### H6",
            }
            vim.api.nvim_buf_get_lines = function() return buffer_lines end

            local expected = {
                "# H1",
                "## H2",
                "### H3",
                "#### H4",
                "##### H5",
                "###### H6",
            }

            -- Act
            local actual = string.extractHeadings()

            -- Assert
            assert.are.same(expected, actual)
        end)

        it("should not extract lines with # but no space after", function()
            -- Arrange
            local buffer_lines = {
                "# Valid heading",
                "#Invalid heading",
                "##Also invalid",
                "## Valid heading 2",
            }
            vim.api.nvim_buf_get_lines = function() return buffer_lines end

            local expected = {
                "# Valid heading",
                "## Valid heading 2",
            }

            -- Act
            local actual = string.extractHeadings()

            -- Assert
            assert.are.same(expected, actual)
        end)

        it("should handle empty buffer", function()
            -- Arrange
            local buffer_lines = {}
            vim.api.nvim_buf_get_lines = function() return buffer_lines end

            local expected = {}

            -- Act
            local actual = string.extractHeadings()

            -- Assert
            assert.are.same(expected, actual)
        end)
    end)

    describe("createOutline", function()
        it("should add indentation based on heading level", function()
            -- Arrange
            local headings = {
                "# H1",
                "## H2",
                "### H3",
            }
            local expected = {
                "H1",
                "    H2",
                "        H3",
            }

            -- Act
            local actual = string.createOutline(headings)

            -- Assert
            assert.are.same(expected, actual)
        end)

        it("should handle single heading", function()
            -- Arrange
            local headings = {
                "# Title1",
                "# Title2",
                "# Title3",
            }
            local expected = {"Title1", "Title2", "Title3"}

            -- Act
            local actual = string.createOutline(headings)

            -- Assert
            assert.are.same(expected, actual)
        end)
    end)
end)
