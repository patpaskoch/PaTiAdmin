-- PaTiTest (devtools/PaTiTest) pure logic. Run via tools/check.sh.
local wow = require("wow_api")

local function load()
    return wow.loadAddonFile("devtools/PaTiTest/Logic.lua", {}, "PaTiTest").Logic
end

describe("PaTiTest Logic.ErrorAddon", function()
    it("finds the PaTi addon in WoW error paths with either slash", function()
        local Logic = load()
        assert.equal("PaTiHeal", Logic.ErrorAddon("Interface/AddOns/PaTiHeal/Logic.lua:12: attempt to index nil"))
        assert.equal("PaTiLead", Logic.ErrorAddon([[Interface\AddOns\PaTiLead\PaTiLead.lua:3: oops]]))
        assert.equal("PaTiAggro", Logic.ErrorAddon("PaTiAggro/PaTiAggro.lua:5: x"))
    end)

    it("returns nil for errors of other addons and non-strings", function()
        local Logic = load()
        assert.is_nil(Logic.ErrorAddon("Interface/AddOns/Details/core.lua:1: x"))
        assert.is_nil(Logic.ErrorAddon(nil))
    end)
end)

describe("PaTiTest Logic.CheckSlash", function()
    local regs = {
        { key = "PATISOCIAL", command = "/psocial" }, { key = "PATISOCIAL", command = "/patisocial" },
        { key = "PATIAGGRO", command = "/pt" }, { key = "OTHERADDON", command = "/PT" },
    }

    it("is ok with the addon's own commands", function()
        assert.same({ "ok", "/patisocial /psocial" }, { load().CheckSlash("PATISOCIAL", true, regs) })
    end)

    it("fails when another addon claims the same command (case-insensitive)", function()
        assert.same({ "fail", "clash", "/pt", "OTHERADDON" }, { load().CheckSlash("PATIAGGRO", true, regs) })
    end)

    it("fails without a handler or without commands", function()
        assert.same({ "fail", "no_handler" }, { load().CheckSlash("PATISOCIAL", false, regs) })
        assert.same({ "fail", "no_command" }, { load().CheckSlash("PATIHEAL", true, regs) })
    end)
end)

describe("PaTiTest Logic.ToggleVerdict", function()
    it("ok when the window switched and came back", function()
        assert.same({ "ok", "shown" }, { load().ToggleVerdict(true, false, true, 0) })
    end)

    it("fail on Lua errors or when the window stays switched", function()
        local Logic = load()
        assert.same({ "fail", "lua_error" }, { Logic.ToggleVerdict(true, false, true, 1) })
        assert.same({ "fail", "not_restored" }, { Logic.ToggleVerdict(true, false, false, 0) })
    end)

    it("warns when switching had no effect (e.g. hidden by the addon's own rule)", function()
        assert.same({ "warn", "no_effect" }, { load().ToggleVerdict(false, false, false, 0) })
    end)
end)

describe("PaTiTest Logic.CheckReload", function()
    local place = { point = "CENTER", relativePoint = "CENTER", x = 10, y = -20.4 }

    it("skips until an earlier session saved positions at logout", function()
        local Logic = load()
        assert.equal("skip", (Logic.CheckReload(nil, "s2", "PaTiHeal", place)))
        assert.equal("skip", (Logic.CheckReload({ session = "s2", windows = { PaTiHeal = place } }, "s2", "PaTiHeal", place)))
        assert.equal("skip", (Logic.CheckReload({ session = "s1", windows = {} }, "s2", "PaTiHeal", place)))
    end)

    it("ok for the same position within a pixel, fail when moved or the anchor changed", function()
        local Logic = load()
        local atLogout = { session = "s1", windows = { PaTiHeal = place } }
        local near = { point = "CENTER", relativePoint = "CENTER", x = 10.6, y = -20 }
        assert.equal("ok", (Logic.CheckReload(atLogout, "s2", "PaTiHeal", near)))
        local moved = { point = "CENTER", relativePoint = "CENTER", x = 40, y = -20 }
        assert.same({ "fail", "moved" }, { Logic.CheckReload(atLogout, "s2", "PaTiHeal", moved) })
        local other = { point = "TOPLEFT", relativePoint = "CENTER", x = 10, y = -20.4 }
        assert.equal("fail", (Logic.CheckReload(atLogout, "s2", "PaTiHeal", other)))
    end)
end)

describe("PaTiTest Logic.AddError", function()
    it("counts repeats once, assigns the addon and stops at MAX_ERRORS", function()
        local Logic = load()
        local list = {}
        Logic.AddError(list, "Interface/AddOns/PaTiHeal/a.lua:1: x", "12:00:00")
        Logic.AddError(list, "Interface/AddOns/PaTiHeal/a.lua:1: x", "12:00:01")
        assert.equal(1, #list)
        assert.equal(2, list[1].count)
        assert.equal(1, #Logic.ErrorsOf(list, "PaTiHeal"))
        for i = 1, Logic.MAX_ERRORS + 5 do Logic.AddError(list, "e" .. i) end
        assert.equal(Logic.MAX_ERRORS, #list)
    end)
end)

describe("PaTiTest Logic.Count", function()
    it("counts results per status", function()
        local counts = load().Count({ { status = "ok" }, { status = "ok" }, { status = "fail" }, { status = "skip" } })
        assert.same({ ok = 2, fail = 1, warn = 0, skip = 1 }, counts)
    end)
end)

-- Whole addon with a stand-in client: /patitest, "/reload" (PLAYER_LOGOUT, files loaded again with the saved table).
describe("PaTiTest /patitest run", function()
    -- The addon prints to chat; keep that out of the runner's own output and always restore print.
    local realPrint = print
    local function quietly(fn)
        return function()
            local ok, err = pcall(fn)
            _G.print = realPrint
            if not ok then error(err, 0) end
        end
    end

    -- Window like PaTiShared's: SetSuiteShown/IsSuiteShown; blocked = the addon's own rule refuses (returns false).
    local function window(x)
        local w = { shown = true, x = x }
        function w:IsShown() return self.shown end
        function w:IsSuiteShown() return self.shown end
        function w:SetSuiteShown(value)
            if self.fail then error("Interface/AddOns/PaTiHeal/PaTiHeal.lua:50: boom") end
            if self.blocked then return false end
            self.shown = value
            return true
        end
        function w:GetPoint() return "CENTER", nil, "CENTER", self.x, 0 end
        return w
    end

    local function boot(saved, state)
        local locale = wow.state.locale
        wow.install()
        wow.state.locale = locale
        _G.print = function() end -- restored by quietly()
        _G.time = function() return state.clock end
        _G.date = function() return "2026-11-08" end
        _G.GetBuildInfo = function() return "1.60.1", "70009", "", 16001 end
        _G.geterrorhandler = function() return function() end end
        _G.seterrorhandler = function(handler) state.handler = handler end
        _G.CreateFrame = function()
            local f = {}
            function f:RegisterEvent() end
            function f:SetScript(_, fn) state.onEvent = fn end
            return f
        end
        _G.C_AddOns = {
            IsAddOnLoaded = function(name) return name == "PaTiHeal" end,
            GetAddOnInfo = function(name)
                return name, name, "", false, name == "PaTiAggro" and "DISABLED" or "MISSING"
            end,
            GetAddOnMetadata = function() return "0.6.0" end,
        }
        _G.SlashCmdList = { PATIHEAL = function() end }
        _G.SLASH_PATIHEAL1, _G.SLASH_PATIHEAL2 = "/patiheal", "/ph"
        _G.PaTiSuiteWindows = { PaTiHeal = state.window }
        _G.PaTiTestDB = saved
        local ns = {}
        for _, file in ipairs({ "Locales/enUS.lua", "Locales/deDE.lua", "Logic.lua", "PaTiTest.lua" }) do
            wow.loadAddonFile("devtools/PaTiTest/" .. file, ns, "PaTiTest")
        end
        state.onEvent(nil, "ADDON_LOADED", "PaTiTest")
    end

    local function reload(state)
        state.onEvent(nil, "PLAYER_LOGOUT")
        state.clock = state.clock + 1
        boot(_G.PaTiTestDB, state)
    end

    local function result(check, name)
        for _, r in ipairs(_G.PaTiTestDB.last.results[name or "PaTiHeal"]) do if r.check == check then return r end end
    end

    it("checks an installed addon and restores its window", quietly(function()
        local state = { clock = 1, window = window(10) }
        boot(nil, state)
        _G.SlashCmdList.PATITEST("")
        assert.equal(true, state.window.shown)
        assert.same({ "ok", "0.6.0" }, { result("loaded").status, result("loaded").detail })
        assert.equal("ok", result("slash").status)
        assert.equal("ok", result("toggle").status)
        assert.equal("skip", result("reload").status)
        assert.equal("skip", result("loaded", "PaTiAggro").status) -- disabled
        assert.equal("skip", result("loaded", "PaTiRota").status) -- not installed
    end))

    it("compares with the position at /reload, not with the first run", quietly(function()
        local state = { clock = 1, window = window(10) }
        boot(nil, state)
        _G.SlashCmdList.PATITEST("")
        state.window.x = 300 -- the player moves the window after the first run; the addon saves it
        reload(state)
        _G.SlashCmdList.PATITEST("")
        assert.equal("ok", result("reload").status)
        _G.SlashCmdList.PATITEST("") -- a second run in the same session keeps the comparison
        assert.equal("ok", result("reload").status)
    end))

    it("fails when the window comes back somewhere else after /reload", quietly(function()
        local state = { clock = 1, window = window(10) }
        boot(nil, state)
        state.onEvent(nil, "PLAYER_LOGOUT")
        state.window.x = 10 + 200 -- the addon did not keep the place
        state.clock = 2
        boot(_G.PaTiTestDB, state)
        _G.SlashCmdList.PATITEST("")
        assert.same({ "fail", "window position changed after /reload" }, { result("reload").status, result("reload").detail })
    end))

    it("a hidden window does not count as moved (visibility is per session by design)", quietly(function()
        local state = { clock = 1, window = window(10) }
        boot(nil, state)
        reload(state)
        state.window.shown = false
        _G.SlashCmdList.PATITEST("")
        assert.equal("ok", result("reload").status)
    end))

    it("notes a window its own rule keeps unchanged", quietly(function()
        local state = { clock = 1, window = window(10) }
        state.window.blocked = true
        boot(nil, state)
        _G.SlashCmdList.PATITEST("")
        assert.same({ "warn", "switching had no effect" }, { result("toggle").status, result("toggle").detail })
    end))

    it("a Lua error while switching fails the toggle and keeps its message", quietly(function()
        local state = { clock = 1, window = window(10) }
        state.window.fail = true
        boot(nil, state)
        _G.SlashCmdList.PATITEST("")
        assert.equal("fail", result("toggle").status)
        assert.matches("boom", _G.PaTiTestDB.last.errors[1].message)
    end))

    it("a repeated known error still fails the toggle", quietly(function()
        local state = { clock = 1, window = window(10) }
        boot(nil, state)
        state.handler("Interface/AddOns/PaTiHeal/PaTiHeal.lua:9: boom")
        state.window.SetSuiteShown = function(self, value)
            state.handler("Interface/AddOns/PaTiHeal/PaTiHeal.lua:9: boom") -- same message as at login
            self.shown = value
        end
        _G.SlashCmdList.PATITEST("")
        assert.equal("fail", result("errors").status)
        assert.equal("fail", result("toggle").status)
    end))

    it("runs on a German client too", quietly(function()
        local state = { clock = 1, window = window(10) }
        wow.state.locale = "deDE"
        boot(nil, state)
        _G.SlashCmdList.PATITEST("")
        assert.equal("ok", result("toggle").status)
        wow.state.locale = "enUS"
    end))

    it("does nothing in combat", quietly(function()
        local state = { clock = 1, window = window(10) }
        boot(nil, state)
        wow.state.inCombat = true
        _G.SlashCmdList.PATITEST("")
        assert.is_nil(_G.PaTiTestDB.last)
    end))
end)
