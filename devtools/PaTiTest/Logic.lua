-- PaTiTest logic: pure functions on plain tables (no WoW calls), unit-tested in PaTiAdmin/tests/patitest_spec.lua.
local _, ns = ...
local Logic = {}
ns.Logic = Logic

-- The addons the self-check knows, in suite order, with their slash command key (SlashCmdList[key]).
Logic.ADDONS = {
    { name = "PaTiHeal", key = "PATIHEAL" },
    { name = "PaTiAggro", key = "PATIAGGRO" },
    { name = "PaTiRota", key = "PATIROTA" },
    { name = "PaTiGroup", key = "PATIGROUP" },
    { name = "PaTiLead", key = "PATILEAD" },
    { name = "PaTiQuest", key = "PATIQUEST" },
    { name = "PaTiDungeon", key = "PATIDUNGEON" },
    { name = "PaTiAuras", key = "PATIAURAS" },
    { name = "PaTiAlerts", key = "PATIALERTS" },
    { name = "PaTiSocial", key = "PATISOCIAL" },
    { name = "PaTiChronicle", key = "PATICHRONICLE" },
    { name = "PaTiSuite", key = "PATISUITE" },
}

Logic.MAX_ERRORS = 50 -- stored Lua errors per session; enough to see a pattern without growing the save file

-- Which PaTi addon a Lua error message comes from ("Interface/AddOns/PaTiHeal/Logic.lua:12: …"); nil if none.
function Logic.ErrorAddon(message)
    if type(message) ~= "string" then return nil end
    return message:match("AddOns[\\/](PaTi%w+)[\\/]") or message:match("^(PaTi%w+)[\\/]")
end

-- Commands of one slash key and whether another key claims one of them.
-- registrations: list of { key = "PATIHEAL", command = "/ph" } as found in the SLASH_<KEY><n> globals.
-- Returns status ("ok" | "fail"), detail.
function Logic.CheckSlash(key, handlerIsFunction, registrations)
    if not handlerIsFunction then return "fail", "no SlashCmdList." .. key end
    local own, owners = {}, {}
    for _, entry in ipairs(registrations) do
        local command = type(entry.command) == "string" and entry.command:lower() or nil
        if command then
            owners[command] = owners[command] or {}
            owners[command][entry.key] = true
            if entry.key == key then own[#own + 1] = command end
        end
    end
    if #own == 0 then return "fail", "no SLASH_" .. key .. " command" end
    table.sort(own)
    for _, command in ipairs(own) do
        for other in pairs(owners[command]) do
            if other ~= key then return "fail", command .. " also used by " .. other end
        end
    end
    return "ok", table.concat(own, " ")
end

-- Verdict of the show/hide round trip. before/after/final: shown states; errors: Lua errors during the round trip.
function Logic.ToggleVerdict(before, after, final, errors)
    if errors > 0 then return "fail", "lua_error" end
    if final ~= before then return "fail", "not_restored" end
    if after == before then return "warn", "no_effect" end
    return "ok", before and "shown" or "hidden"
end

local POSITION_TOLERANCE = 1 -- pixels; WoW may round saved offsets

-- Same window placement? a, b: { point, relativePoint, x, y, shown } or nil.
function Logic.SamePlace(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    if a.point ~= b.point or a.relativePoint ~= b.relativePoint or a.shown ~= b.shown then return false end
    if type(a.x) ~= "number" or type(b.x) ~= "number" or type(a.y) ~= "number" or type(b.y) ~= "number" then
        return a.x == b.x and a.y == b.y
    end
    return math.abs(a.x - b.x) <= POSITION_TOLERANCE and math.abs(a.y - b.y) <= POSITION_TOLERANCE
end

-- Placement after /reload compared with the snapshot of an earlier session.
-- Returns status, detail ("skip" while no earlier session exists).
function Logic.CheckReload(snapshot, session, name, now)
    if type(snapshot) ~= "table" or snapshot.session == session or type(snapshot.windows) ~= "table" then
        return "skip", "reload_pending"
    end
    local before = snapshot.windows[name]
    if before == nil then return "skip", "reload_pending" end
    if Logic.SamePlace(before, now) then return "ok", "same" end
    return "fail", "moved"
end

-- Counts per status: { ok = n, fail = n, warn = n, skip = n }.
function Logic.Count(results)
    local counts = { ok = 0, fail = 0, warn = 0, skip = 0 }
    for _, result in ipairs(results) do counts[result.status] = (counts[result.status] or 0) + 1 end
    return counts
end

-- Stores an error once per distinct message (with a count), at most Logic.MAX_ERRORS entries.
function Logic.AddError(list, message, at)
    message = tostring(message)
    for _, entry in ipairs(list) do
        if entry.message == message then
            entry.count = entry.count + 1
            return entry
        end
    end
    if #list >= Logic.MAX_ERRORS then return nil end
    local entry = { message = message, addon = Logic.ErrorAddon(message), count = 1, at = at }
    list[#list + 1] = entry
    return entry
end

-- Errors of one addon.
function Logic.ErrorsOf(list, name)
    local found = {}
    for _, entry in ipairs(list) do
        if entry.addon == name then found[#found + 1] = entry end
    end
    return found
end
