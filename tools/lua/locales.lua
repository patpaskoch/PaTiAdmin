-- Locale file validation. Format (docs/LOCALIZATION.md): Locales/<code>.lua with one `L.KEY = "Text"` per line.
local M = {}

M.CODES = { enUS = true, deDE = true, zhCN = true, zhTW = true, koKR = true }

-- Keys assigned in a locale file, in order, with line numbers.
function M.keys(text)
    local keys = {}
    local number = 0
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        number = number + 1
        local key = line:match("^%s*L%.([%a_][%w_]*)%s*=") or line:match("^%s*L%[%s*[\"']([^\"']+)[\"']%s*%]%s*=")
        if key then keys[#keys + 1] = { key = key, line = number } end
    end
    return keys
end

-- Runs a locale file the way WoW would (no globals) and returns ns.Locales or an error message.
function M.execute(text, name, ns)
    local chunk, err = loadstring(text, "=" .. name)
    if not chunk then return nil, err end
    setfenv(chunk, {})
    local ok, runErr = pcall(chunk, "PaTiTest", ns)
    if not ok then return nil, runErr end
    return ns.Locales
end

-- files: list of { path = "Shared/Locales/deDE.lua", text = "..." } belonging to ONE addon
-- (its own Locales/ plus embedded Shared/Locales/, which share one table per language).
-- Returns errors, warnings, stats { [code] = { keys = n, missing = n } }.
function M.validate(files)
    local errors, warnings, stats = {}, {}, {}
    local byCode, seen = {}, {}
    local ns = {}
    for _, file in ipairs(files) do
        local code = file.path:match("([^/]+)%.lua$")
        if not M.CODES[code] then
            errors[#errors + 1] = file.path .. ": unknown locale (allowed: enUS, deDE, zhCN, zhTW, koKR)"
        else
            byCode[code] = byCode[code] or {}
            seen[code] = seen[code] or {}
            for _, entry in ipairs(M.keys(file.text)) do
                local previous = seen[code][entry.key]
                if previous then
                    errors[#errors + 1] = ("%s:%d: duplicate key %s (already set in %s)"):format(file.path, entry.line, entry.key, previous)
                else
                    seen[code][entry.key] = file.path .. ":" .. entry.line
                    byCode[code][#byCode[code] + 1] = entry.key
                end
            end
            local locales, err = M.execute(file.text, file.path, ns)
            if not locales then
                errors[#errors + 1] = file.path .. ": does not load: " .. tostring(err)
            else
                for key, value in pairs(locales[code] or {}) do
                    if type(value) ~= "string" then
                        errors[#errors + 1] = ("%s: %s is a %s, not a string"):format(file.path, tostring(key), type(value))
                    end
                end
            end
        end
    end
    if next(byCode) == nil then return errors, warnings, stats end
    if not byCode.enUS then
        errors[#errors + 1] = "enUS locale missing (English is the source and fallback)"
        return errors, warnings, stats
    end
    local source = seen.enUS
    for code, keys in pairs(byCode) do
        local missing = 0
        if code ~= "enUS" then
            for _, key in ipairs(keys) do
                if not source[key] then
                    errors[#errors + 1] = ("%s: key %s does not exist in enUS"):format(seen[code][key], key)
                end
            end
            for key in pairs(source) do
                if not seen[code][key] then missing = missing + 1 end
            end
            if missing > 0 then
                warnings[#warnings + 1] = ("%s: %d of %d keys untranslated (English fallback)"):format(code, missing, #byCode.enUS)
            end
        end
        stats[code] = { keys = #keys, missing = missing }
    end
    return errors, warnings, stats
end

return M
