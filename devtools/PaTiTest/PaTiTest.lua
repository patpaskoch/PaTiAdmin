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

-- One id per game session: a snapshot from another session means a /reload or relog happened since.
local session = tostring(time()) .. "-" .. tostring(math.random(1000000))
local errors = {}

-- Collect Lua errors from the moment this file loads (after the PaTi addons that load before it, alphabetically:
-- their PLAYER_LOGIN setup is still covered). The previous handler keeps running, so nothing is hidden.
do
    local previous = geterrorhandler and geterrorhandler()
    if seterrorhandler and previous then
        seterrorhandler(function(message, ...)
            pcall(Logic.AddError, errors, message, date and date("%H:%M:%S"))
            return previous(message, ...)
        end)
    end
end

local function say(text) print("|cff4fc3f7PaTiTest|r " .. text) end

local function addonState(name)
    local isLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    if isLoaded and isLoaded(name) then return "loaded" end
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or GetAddOnInfo
    local reason = getInfo and select(5, getInfo(name))
    if reason == "MISSING" then return "missing" end
    return "notloaded", reason
end

local function version(name)
    local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return getMetadata and getMetadata(name, "Version") or "?"
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

local function setShown(frame, shown)
    if type(frame.SetSuiteShown) == "function" then return pcall(frame.SetSuiteShown, frame, shown) end
    return pcall(frame.SetShown, frame, shown)
end

local function placeOf(frame)
    local point, _, relativePoint, x, y = frame:GetPoint()
    return { point = point, relativePoint = relativePoint, x = x, y = y, shown = shownOf(frame) }
end

-- Show/hide round trip; errors raised by OnShow/OnHide scripts arrive through the error handler, so count those too.
local function toggle(frame)
    local before, errorsBefore = shownOf(frame), #errors
    local okSet = setShown(frame, not before)
    local after = shownOf(frame)
    local okBack = setShown(frame, before)
    local final = shownOf(frame)
    local newErrors = #errors - errorsBefore + ((okSet and okBack) and 0 or 1)
    return Logic.ToggleVerdict(before, after, final, newErrors)
end

local function checkAddon(entry, registry, registrations, snapshot, windows)
    local results = {}
    local function add(check, status, detail) results[#results + 1] = { check = check, status = status, detail = detail } end
    local state, reason = addonState(entry.name)
    if state == "missing" then add("loaded", "skip", L.NOT_INSTALLED) return results end
    if state ~= "loaded" then add("loaded", "fail", L.NOT_LOADED:format(tostring(reason))) return results end
    add("loaded", "ok", version(entry.name))

    local own = Logic.ErrorsOf(errors, entry.name)
    if #own > 0 then add("errors", "fail", L.ERROR_COUNT:format(#own, own[1].message:sub(1, 160)))
    else add("errors", "ok") end

    add("slash", Logic.CheckSlash(entry.key, type(SlashCmdList[entry.key]) == "function", registrations))

    local frame = registry[entry.name]
    if type(frame) ~= "table" or type(frame.GetPoint) ~= "function" then add("window", "fail", L.NO_WINDOW) return results end
    add("window", "ok")
    local status, code = toggle(frame)
    add("toggle", status, L[code] or code)
    windows[entry.name] = placeOf(frame)
    local reloadStatus, reloadCode = Logic.CheckReload(snapshot, session, entry.name, windows[entry.name])
    add("reload", reloadStatus, L[reloadCode] or reloadCode)
    return results
end

local LABELS = { loaded = "CHECK_LOADED", errors = "CHECK_ERRORS", slash = "CHECK_SLASH", window = "CHECK_WINDOW",
    toggle = "CHECK_TOGGLE", reload = "CHECK_RELOAD" }

local function report(name, ver, results)
    local counts = Logic.Count(results)
    local problems = counts.fail + counts.warn
    if problems == 0 then say(L.LINE_OK:format(name, ver, counts.ok)) return end
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
    -- A snapshot from an earlier session becomes the base for the "after /reload" check (also on later runs).
    if type(PaTiTestDB.snapshot) == "table" and PaTiTestDB.snapshot.session ~= session then
        PaTiTestDB.previous, PaTiTestDB.snapshot = PaTiTestDB.snapshot, nil
    end
    local snapshot, windows, all, reloadPending = PaTiTestDB.previous, {}, {}, false
    local stored = {}
    for _, entry in ipairs(Logic.ADDONS) do
        local results = checkAddon(entry, registry, registrations, snapshot, windows)
        report(entry.name, version(entry.name), results)
        stored[entry.name] = results
        for _, result in ipairs(results) do
            all[#all + 1] = result
            if result.check == "reload" and result.status == "skip" then reloadPending = true end
        end
    end
    -- Keep the first snapshot of a session: the next session compares against it.
    if PaTiTestDB.snapshot == nil then PaTiTestDB.snapshot = { session = session, windows = windows } end
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

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGOUT")
events:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == "PaTiTest" then
        if type(PaTiTestDB) ~= "table" then PaTiTestDB = {} end
    elseif event == "PLAYER_LOGOUT" then
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
