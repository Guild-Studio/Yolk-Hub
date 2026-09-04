local SCRIPT_ROOT = "https://raw.githubusercontent.com/Guild-Studio/Yolk-Hub/refs/heads/main/Loader.lua"

local scriptsByPlaceId = {
    -- +1 Drean Water
    [103883942725157] = "Games/+1 Drean Water.lua",

    -- +1 Scape Monkey
    [114697347887839] = "Games/+1 Scape Monkey.lua",

    -- Arsenal
    [136315980548808] = "Games/Deep Pull Dev.lua",
}

local function loadScript(path)
    local url = SCRIPT_ROOT .. path:gsub(" ", "%%20")
    local source, requestError = game:HttpGet(url, true)

    if type(source) ~= "string" or source == "" then
        error("Could not download " .. path .. ": " .. tostring(requestError))
    end

    local scriptFunction, compileError = loadstring(source, "@" .. path)
    if not scriptFunction then
        error("Could not compile " .. path .. ": " .. tostring(compileError))
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

print("Script started: " .. scriptPath)
return result
