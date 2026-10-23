-- modules/loader.lua
-- MorningDrift UI Library: Module Loader
-- Loads all split modules and mounts their functions onto Library and Window.
-- Call this once from inside Library:CreateWindow, after the Window table is set up.
--
-- Usage (inside CreateWindow, after `local Window = { ... }`):
--
--   local LoadModules = require("modules/loader")   -- if using Rojo / Argon
--   -- OR via GitHub:
--   local LoadModules = loadstring(game:HttpGet(BASE_URL .. "modules/loader.lua"))()
--   LoadModules(Library, Window)

local BASE_URL = "https://raw.githubusercontent.com/rilorfakesilly/scripts/refs/heads/main/"

local function fetch(path)
    local ok, src = pcall(function()
        return game:HttpGet(BASE_URL .. path)
    end)
    if not ok or type(src) ~= "string" or src == "" then
        warn("[MDuiLib loader] Failed to fetch: " .. tostring(path))
        return nil
    end
    local fn, err = loadstring(src)
    if not fn then
        warn("[MDuiLib loader] Parse error in " .. tostring(path) .. ": " .. tostring(err))
        return nil
    end
    return fn()
end

return function(Library, Window)
    local modules = {
        "modules/config_system.lua",
        "modules/credits.lua",
        "modules/localization.lua",
        "modules/notifications.lua",
        "modules/mobile_controls.lua",
        "modules/theme_manager.lua",
    }

    for _, path in ipairs(modules) do
        local mod = fetch(path)
        if mod then
            local ok, err = pcall(mod, Library, Window)
            if not ok then
                warn("[MDuiLib loader] Error in " .. path .. ": " .. tostring(err))
            end
        end
    end
end
