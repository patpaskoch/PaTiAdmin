-- Minimal test runner with a busted-compatible subset (describe / it / before_each / assert.*),
-- so specs can later run under busted unchanged. Used because busted needs C modules that are
-- not installable on the Windows dev machine.
local M = {}

local function show(value)
    if type(value) == "string" then return ("%q"):format(value) end
    return tostring(value)
end

local function deepEqual(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    for key, value in pairs(a) do if not deepEqual(value, b[key]) then return false end end
    for key in pairs(b) do if a[key] == nil then return false end end
    return true
end

local function fail(message, level) error(message, (level or 1) + 2) end

local checks = {}
function checks.equal(expected, actual, message)
    if expected ~= actual then fail((message or "values differ") .. ": expected " .. show(expected) .. ", got " .. show(actual)) end
end
checks.equals = checks.equal
function checks.same(expected, actual, message)
    if not deepEqual(expected, actual) then fail((message or "tables differ") .. ": expected " .. show(expected) .. ", got " .. show(actual)) end
end
function checks.is_true(value, message) if value ~= true then fail(message or ("expected true, got " .. show(value))) end end
function checks.is_false(value, message) if value ~= false then fail(message or ("expected false, got " .. show(value))) end end
function checks.is_nil(value, message) if value ~= nil then fail(message or ("expected nil, got " .. show(value))) end end
function checks.truthy(value, message) if not value then fail(message or ("expected truthy, got " .. show(value))) end end
function checks.falsy(value, message) if value then fail(message or ("expected falsy, got " .. show(value))) end end
function checks.matches(pattern, text, message)
    if type(text) ~= "string" or not text:find(pattern) then fail((message or "no match") .. ": " .. show(text) .. " !~ " .. show(pattern)) end
end
function checks.has_error(fn, message)
    if pcall(fn) then fail(message or "expected an error") end
end

local luaAssert = assert
local assertion = setmetatable(checks, { __call = function(_, ...) return luaAssert(...) end })
checks.are, checks.is = checks, checks

-- Runs spec files; returns passed, failed.
function M.run(files)
    local passed, failed = 0, 0
    local stack, hooks = {}, {}
    local env = setmetatable({
        assert = assertion,
        describe = function(name, fn)
            stack[#stack + 1] = name
            hooks[#stack] = {}
            fn()
            hooks[#stack] = nil
            stack[#stack] = nil
        end,
        before_each = function(fn) table.insert(hooks[#stack], fn) end,
        it = function(name, fn)
            local ok, err = pcall(function()
                for level = 1, #stack do for _, hook in ipairs(hooks[level]) do hook() end end
                fn()
            end)
            local title = table.concat(stack, " > ") .. " > " .. name
            if ok then passed = passed + 1 else
                failed = failed + 1
                print("  FAIL " .. title .. "\n       " .. tostring(err))
            end
        end,
    }, { __index = _G, __newindex = _G })
    for _, file in ipairs(files) do
        local chunk, err = loadfile(file)
        if not chunk then
            failed = failed + 1
            print("  FAIL " .. file .. " does not load: " .. err)
        else
            setfenv(chunk, env)
            local ok, runErr = pcall(chunk)
            if not ok then
                failed = failed + 1
                print("  FAIL " .. file .. ": " .. tostring(runErr))
            end
        end
    end
    return passed, failed
end

return M
