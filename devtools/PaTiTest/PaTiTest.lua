-- PaTiTest: developer self-check of the installed PaTi addons, started with /patitest (never runs by itself).
-- Dev tool in PaTiAdmin, never released. It only reads what WoW and the approved registry offer (AGENTS.md §3):
-- the addon list, SLASH_* / SlashCmdList, _G.PaTiSuiteWindows; it shows/hides windows through their own
-- SetSuiteShown and switches each back. It never reads or writes another addon's SavedVariables.
-- Results go to PaTiTestDB (written by WoW on /reload or logout); the owner still confirms every in-game test.
local _, ns = ...
local Logic = ns.Logic
-- Client language, English for missing keys. enUS itself gets no fallback (it would look itself up forever).
local L = ns.Locales[GetLocale()] or ns.Locales.enUS
if L ~= ns.Locales.enUS then setmetatable(L, { __index = ns.Locales.enUS }) end

-- One id per game session: data from another session means a /reload or relog happened since.
local session = tostring(time()) .. "-" .. tostring(math.random(1000000))
local errors = {}
local errorTotal = 0 -- every error, also repeats and those beyond Logic.MAX_ERRORS

local function recordError(message)
    errorTotal = errorTotal + 1
    pcall(Logic.AddError, errors, message, date and date("%H:%M:%S"))
end

-- Collect Lua errors from the moment this file loads (after the PaTi addons that load before it, alphabetically:
-- their PLAYER_LOGIN setup is still covered). The previous handler keeps running, so nothing is hidden.
do
    local previous = geterrorhandler and geterrorhandler()
    if seterrorhandler and previous then
        seterrorhandler(function(message, ...)
            recordError(message)
            return previous(message, ...)
        end)
    end
end

local function say(text) print("|cff4fc3f7PaTiTest|r " .. text) end

-- "loaded" | "missing" | "disabled" | "notloaded", plus the client's reason.
local function addonState(name)
    local isLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    if isLoaded and isLoaded(name) then return "loaded" end
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or GetAddOnInfo
    local reason = getInfo and select(6, pcall(getInfo, name)) or nil -- pcall ok, name, title, notes, loadable, reason
    if reason == "MISSING" then return "missing" end
    if reason == "DISABLED" then return "disabled", reason end
    return "notloaded", reason
end

-- Only asked for loaded addons (unknown names are not documented for this client).
local function version(name)
    local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local ok, value = pcall(getMetadata, name, "Version")
    return ok and value or "?"
end

-- Every SLASH_<KEY><n> global, so a command claimed by two addons shows up.
local function slashRegistrations()
    local list = {}
    for globalName, command in pairs(_G) do
        if type(globalName) == "string" and type(command) == "string" then
            local key = globalName:match("^SLASH_(.-)%d+$")
            if key then list[#list + 1] = { key = key, command = command } end
        end
    end
    return list
end

local function shownOf(frame)
    local method = type(frame.IsSuiteShown) == "function" and frame.IsSuiteShown or frame.IsShown
    local ok, shown = pcall(method, frame)
    return ok and shown == true
end

-- A Lua error caught here is recorded like any other, so its message is not lost.
local function setShown(frame, shown)
    local method = type(frame.SetSuiteShown) == "function" and frame.SetSuiteShown or frame.SetShown
    local ok, message = pcall(method, frame, shown)
    if not ok then recordError(message) end
end

local function positionOf(frame)
    local ok, point, _, relativePoint, x, y = pcall(frame.GetPoint, frame)
    if not ok then return nil end
    return { point = point, relativePoint = relativePoint, x = x, y = y }
end

-- Show/hide round trip; errors raised by OnShow/OnHide scripts arrive through the error handler.
local function toggle(frame)
    local before, errorsBefore = shownOf(frame), errorTotal
    setShown(frame, not before)
    local after = shownOf(frame)
    setShown(frame, before)
    local final = shownOf(frame)
    return Logic.ToggleVerdict(before, after, final, errorTotal - errorsBefore)
end

local function slashDetail(status, code, command, other)
    if status == "ok" then return code end
    if code == "clash" then return L.clash:format(command, other) end
    return L[code]
end

local function checkAddon(entry, registry, registrations)
    local results = {}
    local function add(check, status, detail)
        results[#results + 1] = { check = check, status = status, detail = detail }
    end
    local state, reason = addonState(entry.name)
    if state == "missing" then add("loaded", "skip", L.NOT_INSTALLED) return results end
    if state == "disabled" then add("loaded", "skip", L.DISABLED) return results end
    if state ~= "loaded" then add("loaded", "fail", L.NOT_LOADED:format(tostring(reason))) return results end
    add("loaded", "ok", version(entry.name))

    local own = Logic.ErrorsOf(errors, entry.name)
    if #own > 0 then add("errors", "fail", L.ERROR_COUNT:format(#own, own[1].message:sub(1, 160)))
    else add("errors", "ok") end

    local status, code, command, other = Logic.CheckSlash(entry.key, type(SlashCmdList[entry.key]) == "function",
        registrations)
    add("slash", status, slashDetail(status, code, command, other))

    local frame = registry[entry.name]
    if type(frame) ~= "table" or type(frame.GetPoint) ~= "function" then
        add("window", "fail", L.NO_WINDOW)
        return results
    end
    add("window", "ok")
    local toggleStatus, toggleCode = toggle(frame)
    add("toggle", toggleStatus, L[toggleCode] or toggleCode)
    local reloadStatus, reloadCode = Logic.CheckReload(PaTiTestDB.atLogout, session, entry.name, positionOf(frame))
    add("reload", reloadStatus, L[reloadCode] or reloadCode)
    return results
end

local LABELS = { loaded = "CHECK_LOADED", errors = "CHECK_ERRORS", slash = "CHECK_SLASH", window = "CHECK_WINDOW",
    toggle = "CHECK_TOGGLE", reload = "CHECK_RELOAD" }

local function report(name, results)
    local counts = Logic.Count(results)
    local ver = results[1].status == "ok" and results[1].detail or ""
    local problems = counts.fail + counts.warn
    if problems == 0 then
        if counts.ok == 0 then say(("%s: %s"):format(name, tostring(results[1].detail))) return end
        say(L.LINE_OK:format(name, ver, counts.ok))
        return
    end
    say(L.LINE_PROBLEMS:format(name, ver, counts.ok, problems))
    for _, result in ipairs(results) do
        if result.status == "fail" or result.status == "warn" then
            say(("   %s %s: %s"):format(result.status == "fail" and "|cffff5555✗|r" or "|cffffcc00!|r",
                L[LABELS[result.check]], tostring(result.detail or "")))
        end
    end
end

local function run()
    if InCombatLockdown() then say(L.IN_COMBAT) return end
    say(L.START)
    local registry = type(_G.PaTiSuiteWindows) == "table" and _G.PaTiSuiteWindows or {}
    local registrations = slashRegistrations()
    local all, stored, reloadPending = {}, {}, false
    for _, entry in ipairs(Logic.ADDONS) do
        local results = checkAddon(entry, registry, registrations)
        report(entry.name, results)
        stored[entry.name] = results
        for _, result in ipairs(results) do
            all[#all + 1] = result
            if result.check == "reload" and result.status == "skip" then reloadPending = true end
        end
    end
    PaTiTestDB.last = { at = date("%Y-%m-%d %H:%M:%S"), session = session, results = stored, errors = errors,
        build = select(4, GetBuildInfo()) }
    local counts = Logic.Count(all)
    say(L.SUMMARY:format(counts.ok, counts.fail, counts.warn, counts.skip))
    if reloadPending then say(L.RELOAD_HINT) end
end

local function showErrors()
    if #errors == 0 then say(L.ERRORS_NONE) return end
    say(L.ERRORS_HEADER)
    for _, entry in ipairs(errors) do say(("%s ×%d %s"):format(entry.at or "", entry.count, entry.message)) end
end

-- Window positions as the session ends (PLAYER_LOGOUT also fires on /reload): the next session compares with them.
local function saveLogoutPositions()
    local windows = {}
    for name, frame in pairs(type(_G.PaTiSuiteWindows) == "table" and _G.PaTiSuiteWindows or {}) do
        if type(frame) == "table" and type(frame.GetPoint) == "function" then windows[name] = positionOf(frame) end
    end
    PaTiTestDB.atLogout = { session = session, windows = windows }
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGOUT")
events:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == "PaTiTest" then
        if type(PaTiTestDB) ~= "table" then PaTiTestDB = {} end
        PaTiTestDB.snapshot, PaTiTestDB.previous = nil, nil -- replaced by atLogout (first test build)
    elseif event == "PLAYER_LOGOUT" then
        saveLogoutPositions()
        PaTiTestDB.sessionErrors = errors -- errors of the last session, even without a /patitest run
    end
end)

SLASH_PATITEST1 = "/patitest"
SlashCmdList.PATITEST = function(message)
    local command = (message or ""):lower():match("^%s*(%S*)")
    if command == "fehler" or command == "errors" then showErrors()
    elseif command == "help" or command == "hilfe" then say(L.HELP)
    else run() end
end
