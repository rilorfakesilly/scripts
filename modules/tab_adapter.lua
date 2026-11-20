-- modules/tab_adapter.lua
-- Declarative layout and tab constructor for the MDuiLib window

local TabAdapter = {}

TabAdapter.tabDefinitions = {
    { id = "Main",       title = "Main",       order = 1,  icon = "home" },
    { id = "Autofarm",   title = "Autofarm",   order = 3,  icon = "coins" },
    { id = "Player",     title = "Player",     order = 5,  icon = "user" },
    { id = "Murderer",   title = "Murderer",   order = 7,  icon = "skull" },
    { id = "Sheriff",    title = "Sheriff",    order = 9,  icon = "shield" },
    { id = "Sounds",     title = "Sounds",     order = 11, icon = "volume-2" },
    { id = "Visuals",    title = "Visuals",    order = 13, icon = "eye" },
    { id = "Animations", title = "Animations", order = 15, icon = "activity" },
    { id = "World",      title = "World",      order = 17, icon = "globe" },
    { id = "Camera",     title = "Camera",     order = 19, icon = "camera" },
    { id = "Webhook",    title = "Webhook",    order = 21, icon = "send" },
}

TabAdapter.dividerLayout = {
    big = { 2, 12 },
    small = { 4, 6, 8, 10, 14, 16, 18, 20 },
}

TabAdapter.settingsOrder = 999
TabAdapter.settingsIcon = "settings"

local function warnf(fmt, ...)
    warn(("[TabAdapter] " .. fmt):format(...))
end

-- Returns a sorted copy of the definitions, skipping invalid or duplicate entries.
local function normalizeDefinitions(defs)
    local seen, out = {}, {}
    for i, def in ipairs(defs) do
        if type(def) ~= "table" or type(def.id) ~= "string" or def.id == "" then
            warnf("definition #%d skipped: missing string 'id'", i)
        elseif seen[def.id] then
            warnf("definition '%s' skipped: duplicate id", def.id)
        elseif def.id == "Settings" then
            warnf("definition 'Settings' skipped: the Settings tab is created separately")
        else
            seen[def.id] = true
            out[#out + 1] = {
                id = def.id,
                title = def.title or def.id,
                order = tonumber(def.order) or (i * 2 - 1),
                icon = def.icon,
            }
        end
    end
    table.sort(out, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.id < b.id
    end)
    return out
end

local function resolveSettingsTab(window)
    if window.GetSettingsTab then
        local ok, tab = pcall(window.GetSettingsTab, window)
        if ok and tab then return tab end
    end
    if window.SettingsTab then return window.SettingsTab end
    return window:CreateTab("Settings", TabAdapter.settingsOrder, TabAdapter.settingsIcon)
end

local function addDividers(window, orders, method, tabOrders, label)
    local fn = window[method]
    if type(fn) ~= "function" then return end

    local placed = {}
    for _, order in ipairs(orders or {}) do
        if type(order) ~= "number" then
            warnf("%s divider skipped: order '%s' is not a number", label, tostring(order))
        elseif placed[order] then
            warnf("%s divider at %s skipped: duplicate", label, tostring(order))
        else
            placed[order] = true
            if tabOrders[order] then
                warnf("%s divider at %s shares an order with tab '%s'", label, tostring(order), tabOrders[order])
            end
            local ok, err = pcall(fn, window, order)
            if not ok then warnf("%s divider at %s failed: %s", label, tostring(order), tostring(err)) end
        end
    end
end

-- Builds every tab on `window`.
-- Optional config: { definitions = {...}, dividers = { big = {...}, small = {...} } }
-- Returns: tabs (keyed by id, includes Settings), ordered (array of ids in sidebar order)
function TabAdapter.createTabs(window, config)
    assert(type(window) == "table" and window.CreateTab, "TabAdapter.createTabs: window with CreateTab required")
    config = config or {}

    local definitions = normalizeDefinitions(config.definitions or TabAdapter.tabDefinitions)
    local dividers = config.dividers or TabAdapter.dividerLayout

    local tabs, ordered, tabOrders = {}, {}, {}
    for _, def in ipairs(definitions) do
        local ok, tab = pcall(window.CreateTab, window, def.title, def.order, def.icon)
        if ok and tab then
            tabs[def.id] = tab
            ordered[#ordered + 1] = def.id
            tabOrders[def.order] = def.id
        else
            warnf("failed to create tab '%s': %s", def.id, tostring(tab))
        end
    end

    local ok, settings = pcall(resolveSettingsTab, window)
    if ok and settings then
        tabs.Settings = settings
        ordered[#ordered + 1] = "Settings"
    else
        warnf("failed to resolve Settings tab: %s", tostring(settings))
    end

    addDividers(window, dividers.big, "AddSidebarBigDivider", tabOrders, "big")
    addDividers(window, dividers.small, "AddSidebarSmallDivider", tabOrders, "small")

    return tabs, ordered
end

return TabAdapter
