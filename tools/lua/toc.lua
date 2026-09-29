-- TOC parsing and validation for PaTi addons. Pure Lua 5.1; file access is injected so tests need no disk.
local M = {}

M.SEMVER = "^%d+%.%d+%.%d+$"

local function lines(text)
    local result = {}
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do result[#result + 1] = (line:gsub("\r$", "")) end
    if result[#result] == "" then result[#result] = nil end
    return result
end

local function normalize(path)
    return (path:gsub("\\", "/"))
end

local function dirname(path)
    return path:match("^(.*)/[^/]*$") or ""
end

local function join(dir, path)
    if dir == "" then return path end
    return dir .. "/" .. path
end

-- Returns { meta = { Interface = "16001", ... }, files = { { path, line } }, problems = { "line 8: ..." } }
function M.parse(text)
    local toc = { meta = {}, files = {}, problems = {} }
    for number, line in ipairs(lines(text)) do
        local key, value = line:match("^##%s*([^:]+):%s*(.-)%s*$")
        if key then
            toc.meta[key] = value
        elseif not (line:match("^#") or line:match("^%s*$")) then
            local path = line:match("^%s*(.-)%s*$")
            -- Catches e.g. a literal "`r`n" written by a PowerShell script (TOC shipped broken on 2026-09-28).
            if path:find("[%c`\"']") then
                toc.problems[#toc.problems + 1] = ("line %d: invalid characters in file entry %q"):format(number, path)
            end
            toc.files[#toc.files + 1] = { path = normalize(path), line = number }
        end
    end
    return toc
end

-- Script/Include references of a WoW XML file, relative to that file.
function M.xmlReferences(xmlPath, text)
    local refs = {}
    local base = dirname(xmlPath)
    for tag, file in text:gmatch("<%s*(%a+)[^>]-file%s*=%s*\"([^\"]+)\"") do
        if tag == "Script" or tag == "Include" then refs[#refs + 1] = join(base, normalize(file)) end
    end
    return refs
end

-- addonName: folder name. readFile(relativePath) -> text or nil.
-- Returns errors, warnings, referenced (set of relative paths the client loads).
function M.validate(addonName, readFile, expectedInterface)
    local errors, warnings, referenced = {}, {}, {}
    local tocName = addonName .. ".toc"
    local text = readFile(tocName)
    if not text then return { tocName .. " missing" }, warnings, referenced end
    referenced[tocName] = true

    local toc = M.parse(text)
    for _, problem in ipairs(toc.problems) do errors[#errors + 1] = tocName .. " " .. problem end

    local meta = toc.meta
    if not (meta.Interface and meta.Interface:match("^%d+[%d, ]*$")) then
        errors[#errors + 1] = tocName .. ": ## Interface missing or not numeric"
    elseif expectedInterface and meta.Interface ~= expectedInterface then
        warnings[#warnings + 1] = ("%s: Interface %s differs from the suite's %s"):format(tocName, meta.Interface, expectedInterface)
    end
    if not meta.Title then errors[#errors + 1] = tocName .. ": ## Title missing" end
    for _, key in ipairs({ "Notes", "Author" }) do
        if not meta[key] then warnings[#warnings + 1] = ("%s: ## %s missing (shown in the AddOns list)"):format(tocName, key) end
    end
    -- Independence (AGENTS.md §3): no addon may require or optionally load another PaTi addon.
    for key, value in pairs(meta) do
        if key:match("Deps$") or key == "Dependencies" then
            for dep in value:gmatch("[^,%s]+") do
                if dep:match("^PaTi") then
                    errors[#errors + 1] = ("%s: ## %s names %s — PaTi addons must stay independent"):format(tocName, key, dep)
                end
            end
        end
    end
    if not (meta.Version and meta.Version:match(M.SEMVER)) then
        errors[#errors + 1] = tocName .. ": ## Version missing or not MAJOR.MINOR.PATCH (" .. tostring(meta.Version) .. ")"
    end
    for _, key in ipairs({ "SavedVariables", "SavedVariablesPerCharacter" }) do
        for name in (meta[key] or ""):gmatch("[^,%s]+") do
            if not name:match("^[%a_][%w_]*$") then
                errors[#errors + 1] = ("%s: %s entry %q is not a valid Lua name"):format(tocName, key, name)
            elseif name:sub(1, #addonName) ~= addonName then
                warnings[#warnings + 1] = ("%s: SavedVariable %s should start with %s"):format(tocName, name, addonName)
            end
        end
    end

    local function visit(path, from)
        if referenced[path] then return end
        local content = readFile(path)
        if not content then
            errors[#errors + 1] = ("%s: referenced file %s does not exist"):format(from, path)
            return
        end
        referenced[path] = true
        if path:lower():match("%.xml$") then
            for _, ref in ipairs(M.xmlReferences(path, content)) do visit(ref, path) end
        end
    end
    for _, entry in ipairs(toc.files) do visit(entry.path, tocName .. " line " .. entry.line) end
    -- AddOns list icon: must be a texture inside this addon (Interface\AddOns\<Addon>\path, extension optional).
    if meta.IconTexture then
        local prefix = "interface/addons/" .. addonName:lower() .. "/"
        local path = normalize(meta.IconTexture)
        if path:lower():sub(1, #prefix) ~= prefix then
            errors[#errors + 1] = ("%s: ## IconTexture %s is not inside %s"):format(tocName, meta.IconTexture, addonName)
        else
            local file, found = path:sub(#prefix + 1), nil
            for _, candidate in ipairs({ file, file .. ".tga", file .. ".blp", file .. ".png" }) do
                if readFile(candidate) then found = candidate break end
            end
            if found then referenced[found] = true
            else errors[#errors + 1] = ("%s: ## IconTexture %s: texture file not found"):format(tocName, meta.IconTexture) end
        end
    end
    -- Loaded by WoW by name, without a TOC entry.
    if readFile("Bindings.xml") then referenced["Bindings.xml"] = true end
    return errors, warnings, referenced
end

-- Files that must never reach a player's AddOns folder, even if a TOC referenced them by mistake.
-- assets/ = platform/marketing images (GitHub, CurseForge, Wago); the client only needs Media/.
local FORBIDDEN = { "^tests/", "^%.github/", "^%.git/", "^tools/", "^scripts/", "^assets/", "%.md$", "%.sh$", "%.zip$",
    "^LICENSE", "^Shared/%.manifest$" }

-- Release problems of a file list (paths relative to the addon folder): forbidden development files.
function M.forbiddenFiles(paths)
    local problems = {}
    for _, path in ipairs(paths) do
        for _, pattern in ipairs(FORBIDDEN) do
            if path:match(pattern) then
                problems[#problems + 1] = path .. " is a development file and must not be packaged"
                break
            end
        end
    end
    return problems
end

-- Lua files the client never loads (a forgotten TOC entry ships an addon without that code). tests/ is exempt.
function M.unloadedLua(paths, referenced, addonName)
    local problems = {}
    for _, path in ipairs(paths) do
        if path:match("%.lua$") and not referenced[path] and not path:match("^tests/") then
            problems[#problems + 1] = path .. " is not loaded by " .. addonName .. ".toc"
        end
    end
    return problems
end

return M
