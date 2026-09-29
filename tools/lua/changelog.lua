-- CHANGELOG.md helpers for the release workflow. Pure Lua 5.1 (tests/changelog_spec.lua).
local M = {}

-- The body of "## [<version>]" (e.g. "0.7.0" or "Unreleased"), without its heading, trimmed; nil if missing.
-- Headings may carry a date or note: "## [0.7.0] - 2026-10-02", "## [Unreleased] — planned 0.5.0".
function M.section(text, version)
    if not version then return nil end
    text = text:gsub("\r\n", "\n")
    local body, inside = {}, false
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        local heading = line:match("^##%s+%[([^%]]+)%]")
        if heading then
            if inside then break end
            inside = heading == version
        elseif inside then
            body[#body + 1] = line
        end
    end
    if not inside and #body == 0 then return nil end
    local notes = table.concat(body, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
    return notes
end

return M
