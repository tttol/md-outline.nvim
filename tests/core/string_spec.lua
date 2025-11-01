local helper = require('tests.test_helper')

describe("core/string test", function()
    local string

    before_each(function()
        string = helper.reload_module("core.string")
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
