-- Just enough WoW API for unit tests of pure logic. Do not grow this into a client emulator:
-- mock only what the code under test calls, and keep UI/secure behaviour for in-game tests.
local M = {}

M.state = { locale = "enUS", inCombat = false }

function M.install()
    M.state.locale, M.state.inCombat = "enUS", false
    _G.GetLocale = function() return M.state.locale end
    _G.InCombatLockdown = function() return M.state.inCombat end
end

-- Loads an addon file the way WoW does: with (addonName, ns) as varargs.
function M.loadAddonFile(path, ns, addonName)
    local chunk = assert(loadfile(path))
    chunk(addonName or "PaTiTest", ns)
    return ns
end

-- Minimal stand-in for a FontString, for code that only calls SetText/GetText.
function M.fontString()
    local text = ""
    return {
        SetText = function(_, value) text = value end,
        GetText = function() return text end,
    }
end

return M
