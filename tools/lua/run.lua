-- Command line entry for tools/check.sh and tools/package.sh. Runs from inside the repo/addon folder;
-- file lists come from stdin (one relative path per line) because plain Lua 5.1 cannot list directories.
--
--   lua run.lua syntax           < files      compile every listed .lua file
--   lua run.lua toc <Addon> [Interface] < files   validate <Addon>.toc and referenced files
--   lua run.lua locales          < files      validate Locales/, Shared/Locales/, src/Locales/
--   lua run.lua package-list <Addon> < files  print the files a release zip must contain
--   lua run.lua notes <version>              print the CHANGELOG.md section of that version
--   lua run.lua test <mocksDir>  < files      run the listed *_spec.lua files
local here = (arg[0]:gsub("\\", "/"):match("^(.*)/[^/]*$") or ".")
package.path = here .. "/?.lua;" .. package.path

local command = arg[1]

local function readFile(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local text = file:read("*a")
    file:close()
    return text
end

local function stdinFiles()
    local files = {}
    for line in io.lines() do
        line = line:gsub("\r$", ""):gsub("\\", "/"):gsub("^%./", "")
        if line ~= "" then files[#files + 1] = line end
    end
    return files
end

local function report(errors, warnings)
    for _, message in ipairs(warnings or {}) do print("  warning: " .. message) end
    for _, message in ipairs(errors) do print("  ERROR: " .. message) end
    return #errors == 0
end

local ok = true
if command == "syntax" then
    local errors = {}
    for _, path in ipairs(stdinFiles()) do
        if path:match("%.lua$") then
            local _, err = loadfile(path)
            if err then errors[#errors + 1] = err end
        end
    end
    ok = report(errors)

elseif command == "toc" or command == "package-list" then
    local toc = require("toc")
    local addon = arg[2]
    local errors, warnings, referenced = toc.validate(addon, readFile, arg[3])
    if command == "toc" then
        -- A Lua file the client never loads is a forgotten TOC entry (shipped twice before this was an error).
        for _, problem in ipairs(toc.unloadedLua(stdinFiles(), referenced, addon)) do errors[#errors + 1] = problem end
        ok = report(errors, warnings)
    else
        ok = report(errors)
        if ok then
            local list = {}
            for path in pairs(referenced) do list[#list + 1] = path end
            -- Assets are not listed in the TOC; ship Media/ as a whole.
            for _, path in ipairs(stdinFiles()) do
                if path:match("^Media/") and not referenced[path] then list[#list + 1] = path end
            end
            table.sort(list)
            local forbidden = toc.forbiddenFiles(list)
            if #forbidden > 0 then
                ok = report(forbidden)
            else
                for _, path in ipairs(list) do print(path) end
            end
        end
    end

elseif command == "notes" then
    -- Release notes: the CHANGELOG.md section of one version (or [Unreleased]) on stdout.
    local text = readFile("CHANGELOG.md")
    local notes = text and require("changelog").section(text, arg[2])
    if notes then io.write(notes, "\n") else io.stderr:write("CHANGELOG.md has no section for " .. tostring(arg[2]) .. "\n"); ok = false end

elseif command == "locales" then
    local locales = require("locales")
    local files = {}
    for _, path in ipairs(stdinFiles()) do
        if path:match("^Locales/[^/]+%.lua$") or path:match("^Shared/Locales/[^/]+%.lua$") or path:match("^src/Locales/[^/]+%.lua$") then
            files[#files + 1] = { path = path, text = readFile(path) }
        end
    end
    if #files == 0 then
        print("  no locale files")
    else
        local errors, warnings, stats = locales.validate(files)
        local summary = {}
        for code, stat in pairs(stats) do summary[#summary + 1] = ("%s %d"):format(code, stat.keys) end
        table.sort(summary)
        print("  keys: " .. table.concat(summary, ", "))
        ok = report(errors, warnings)
    end

elseif command == "test" then
    package.path = arg[2] .. "/?.lua;" .. package.path
    local passed, failed = require("test").run(stdinFiles())
    print(("  %d passed, %d failed"):format(passed, failed))
    ok = failed == 0

else
    io.stderr:write("usage: see header of tools/lua/run.lua\n")
    ok = false
end

os.exit(ok and 0 or 1)
