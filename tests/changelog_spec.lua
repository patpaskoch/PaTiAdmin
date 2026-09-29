local changelog = require("changelog")

local TEXT = table.concat({
    "# Changelog", "", "## [Unreleased] — planned 0.5.0", "### Added", "- New thing", "",
    "## [0.4.0] - 2026-09-01", "### Fixed", "- Old bug", "",
}, "\r\n")

describe("changelog.section", function()
    it("returns the body of a version or of [Unreleased], without the heading", function()
        assert.equal("### Fixed\n- Old bug", changelog.section(TEXT, "0.4.0"))
        assert.equal("### Added\n- New thing", changelog.section(TEXT, "Unreleased"))
    end)

    it("returns nil for a version without a section", function()
        assert.is_nil(changelog.section(TEXT, "0.7.0"))
        assert.is_nil(changelog.section(TEXT, nil))
    end)
end)
