local SCRIPT_ROOT = "https://raw.githubusercontent.com/Guild-Studio/Yolk-Hub/refs/heads/main/"

local scriptsByPlaceId = {
    -- +1 Scape Monkey
    [114697347887839] = "Games/+1 Scape Monkey.lua",

    [72858062353423] = "Games/+1 Scape Monkey.lua",

    --World1 -  +1 Monkey Evolution
    [91701030914075] = "Games/+1 Monkey Evolution.lua",
}

local function encodeUrlPath(path)
    return (path:gsub(" ", "%%20"):gsub("%+", "%%2B"))
end

local customLoadstring = loadstring or load

local function loadScript(path)
    if not customLoadstring then
        error("Your executor does not support loadstring or load.")
    end

    local url = SCRIPT_ROOT .. encodeUrlPath(path)
    
    local httpSuccess, source = pcall(function()
        return game:HttpGet(url .. "?t=" .. tostring(os.time()))
    end)

    if not httpSuccess or type(source) ~= "string" or source == "" then
        httpSuccess, source = pcall(function()
            return game:HttpGet(url)
        end)
    end

    if not httpSuccess or type(source) ~= "string" or source == "" then
        error("Could not download " .. path .. ": " .. tostring(source))
    end

    if source:find("404: Not Found") or source:sub(1, 14) == "404: Not Found" then
        error("GitHub 404 Not Found for URL: " .. url)
    end

    local scriptFunction, compileError = customLoadstring(source)
    if not scriptFunction then
        error("Could not compile " .. path .. ": " .. tostring(compileError))
    end

    if setfenv and typeof(setfenv) == "function" then
        local env = (getgenv and getgenv()) or getfenv(0) or _G
        pcall(setfenv, scriptFunction, env)
    end

    return scriptFunction()
end

local placeId = game.PlaceId
local scriptPath = scriptsByPlaceId[placeId]

if not scriptPath then
    warn(string.format("No script configured for PlaceId %d.", placeId))
    return
end

local success, result = pcall(loadScript, scriptPath)
if not success then
    warn("The loader could not start " .. scriptPath .. ": " .. tostring(result))
    return
end

print("Script started successfully: " .. scriptPath)
return result
