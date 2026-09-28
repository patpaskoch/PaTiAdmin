local toc = require("toc")

local function reader(files)
    return function(path) return files[path] end
end

local VALID = table.concat({
    "## Interface: 16001",
    "## Title: PaTiDemo",
    "## Version: 0.1.0",
    "## SavedVariablesPerCharacter: PaTiDemoDB",
    "",
    "Shared\\Shared.xml",
    "PaTiDemo.lua",
}, "\r\n")

describe("toc.parse", function()
    it("reads metadata and file entries with CRLF line endings", function()
        local parsed = toc.parse(VALID)
        assert.equal("16001", parsed.meta.Interface)
        assert.equal("0.1.0", parsed.meta.Version)
        assert.equal("Shared/Shared.xml", parsed.files[1].path)
        assert.equal("PaTiDemo.lua", parsed.files[2].path)
        assert.equal(0, #parsed.problems)
    end)

    it("rejects the literal `r`n that broke three addons (regression)", function()
        local parsed = toc.parse("## Interface: 16001\nPaTiSharedPanel.lua`r`nPaTiTank.lua\n")
        assert.equal(1, #parsed.problems)
        assert.matches("invalid characters", parsed.problems[1])
    end)
end)

describe("toc.validate", function()
    local files
    before_each(function()
        files = {
            ["PaTiDemo.toc"] = VALID,
            ["PaTiDemo.lua"] = "-- code",
            ["Shared/Shared.xml"] = '<Ui><Script file="Version.lua"/><Script file="Locales\\enUS.lua"/></Ui>',
            ["Shared/Version.lua"] = "",
            ["Shared/Locales/enUS.lua"] = "",
        }
    end)

    it("accepts a valid addon and follows XML includes", function()
        local errors, warnings, referenced = toc.validate("PaTiDemo", reader(files), "16001")
        assert.same({}, errors)
        assert.same({}, warnings)
        assert.is_true(referenced["Shared/Locales/enUS.lua"])
    end)

    it("reports missing files referenced from XML", function()
        files["Shared/Version.lua"] = nil
        local errors = toc.validate("PaTiDemo", reader(files))
        assert.equal(1, #errors)
        assert.matches("Shared/Version.lua does not exist", errors[1])
    end)

    it("requires a MAJOR.MINOR.PATCH version", function()
        files["PaTiDemo.toc"] = VALID:gsub("0%.1%.0", "0.1")
        local errors = toc.validate("PaTiDemo", reader(files))
        assert.matches("Version", errors[1])
    end)

    it("warns about an Interface different from the suite", function()
        local _, warnings = toc.validate("PaTiDemo", reader(files), "11507")
        assert.matches("differs", warnings[1])
    end)

    it("ships Bindings.xml, which WoW loads without a TOC entry", function()
        files["Bindings.xml"] = "<Bindings/>"
        local _, _, referenced = toc.validate("PaTiDemo", reader(files))
        assert.is_true(referenced["Bindings.xml"])
    end)
end)
