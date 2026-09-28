local locales = require("locales")

local function file(path, body)
    local code = path:match("([^/]+)%.lua$")
    return { path = path, text = "local _, ns = ...\nns.Locales = ns.Locales or {}\nlocal L = ns.Locales." .. code
        .. " or {}\nns.Locales." .. code .. " = L\n" .. body }
end

describe("locales.validate", function()
    it("accepts complete translations", function()
        local errors, warnings = locales.validate({
            file("Locales/enUS.lua", 'L.CLOSE = "Close"\n'),
            file("Locales/deDE.lua", 'L.CLOSE = "Schließen"\n'),
        })
        assert.same({}, errors)
        assert.same({}, warnings)
    end)

    it("only warns about missing translations (English fallback)", function()
        local errors, warnings = locales.validate({
            file("Locales/enUS.lua", 'L.CLOSE = "Close"\nL.OPEN = "Open"\n'),
            file("Locales/zhTW.lua", ""),
        })
        assert.same({}, errors)
        assert.matches("zhTW: 2 of 2 keys untranslated", warnings[1])
    end)

    it("rejects keys that enUS does not define", function()
        local errors = locales.validate({
            file("Locales/enUS.lua", 'L.CLOSE = "Close"\n'),
            file("Locales/deDE.lua", 'L.CLSOE = "Schließen"\n'),
        })
        assert.matches("CLSOE does not exist in enUS", errors[1])
    end)

    it("rejects duplicate keys, also between Shared and addon files", function()
        local errors = locales.validate({
            file("Shared/Locales/enUS.lua", 'L.CLOSE = "Close"\n'),
            file("Locales/enUS.lua", 'L["CLOSE"] = "Close window"\n'),
        })
        assert.matches("duplicate key CLOSE", errors[1])
    end)

    it("rejects unknown locale files and non-string values", function()
        local errors = locales.validate({
            file("Locales/enUS.lua", "L.COUNT = 3\n"),
            file("Locales/frFR.lua", ""),
        })
        assert.equal(2, #errors)
    end)

    it("requires enUS as the source", function()
        local errors = locales.validate({ file("Locales/deDE.lua", 'L.CLOSE = "Schließen"\n') })
        assert.matches("enUS locale missing", errors[1])
    end)
end)
