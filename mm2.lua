-- mm2
--
-- how the file is organized:
--   - header, single-instance lifecycle cleanup, and state storage
--   - color and ui math utilities
--   - mduilib initialization and tab adapter wrappers
--   - core game trackers (roles, weapons, round flow)
--   - combat algorithms (silent aim, prediction, kill aura, fling)
--   - movement and autofarm systems (coin paths, anti-void, flight)
--   - cosmetics and visual pipelines (ground aura, wings, china hat, trails)
--   - inventory and trading value calculation overlays
--   - tab and ui components construction
--   - main loop hooks, input event bindings, and configuration autoload
--
-- where to add a new feature:
--   - declare default state properties in the state table near top
--   - implement runtime logic in the matching functional domain
--   - expose controls via adapter methods inside _buildScriptUI()
--   - add instance reset and connection teardown inside doCleanup()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local ContentProvider = game:GetService("ContentProvider")
local LightingService = game:GetService("Lighting")
math.randomseed(math.random(1000, 9999) + tick())
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = Workspace.CurrentCamera

local rainbowHue = 0
_G.rainbowHue = 0

-- forward declare state so early helpers like getColor capture it as an upvalue
local state

-- interpolate palette shifts for visuals

local function getColor(mode, c1, c2, tOverride)
    if mode == "Rainbow" then
        local speed = state and state.colorShiftSpeed or 3
        local hue = (tick() * (speed * 0.15)) % 1.0
        return Color3.fromHSV(hue, 1, 1)
    elseif mode == "Gradient" or mode == "Shift" then
        local speed = state and state.colorShiftSpeed or 3
        local t = tOverride or ((math.sin(tick() * speed) + 1) / 2)
        return (c1 or Color3.new(1,1,1)):Lerp(c2 or Color3.new(0, 170, 255), t)
    else
        return c1 or Color3.new(1,1,1)
    end
end

-- tear down previous session before mounting 
if getgenv and getgenv().MD_MM2_CLEANUP then
    pcall(getgenv().MD_MM2_CLEANUP)
end

for _, child in ipairs(game:GetChildren()) do
    if child:IsA("BindableEvent") and child.Name:find("^__MD_Cleanup") then
        pcall(function() child:Fire() end)
        task.wait(0.05)
        pcall(function() child:Destroy() end)
    end
end


local cleanupSignal = Instance.new("BindableEvent")
cleanupSignal.Name = "__MD_Cleanup__"
cleanupSignal.Parent = game

local myUniqueId = HttpService:GenerateGUID(false)
game:SetAttribute("__MD_ActiveID__", myUniqueId)

-- persist runtime toggles and session values 
state = {
    unloaded = false,
    
    -- track match progression and weapon holders
    roundActive = false,
    roundStartTime = 0,
    deadPlayers = {},
    knifeHolder = nil,
    gunHolder = nil,
    noRoundStartTime = tick(),
    
    -- configure coin and round automation settings
    autofarmEnabled = false,
    autofarmMode = "Coin",
    autofarmTweenSpeed = 22,
    afterFarmAction = "Farm exp",
    roundEndFling = false,
    autoTakeGun = false,
    autoTakeGunMethod = "Touch interest",
    webhookEnabled = false,
    webhookUrl = "",
    webhookIntervalStr = "5m",
    webhookIntervalSec = 300,
    hasTeleportedToLobby = false,
    
    -- record session earnings for telemetry
    startTime = tick(),
    totalCoinsFarmed = 0,
    roundsPassed = 0,
    lastWebhookSent = tick(),
    currentTaskStatus = "Idle",
    taskLoggerEnabled = true,
    tweenRoundTeleported = false,
    
    -- tune movement physics and weapon targeting
    speedEnabled = false,
    speedValue = 16,
    
    flightEnabled = false,
    flightSpeed = 50,
    
    aimbotEnabled = false,
    autoAimEnabled = false,
    autoAimWallbang = false,
    antiFlingEnabled = false,
    chinaHatEnabled = false,
    spinbotEnabled = false,
    spinbotSpeed = 30,
    
    -- highlight characters and carried items
    espEnabled = false,
    espMaxDistance = 1000,
    chamsEnabled = true,
    chamsMode = "Highlight",
    chamsMurdererColor = Color3.fromRGB(255, 70, 70),
    chamsSheriffColor = Color3.fromRGB(90, 120, 255),
    chamsInnocentColor = Color3.fromRGB(50, 230, 110),
    boxEspEnabled = false,
    nameEspEnabled = true,
    roleEspEnabled = true,
    gunEspEnabled = true,
    
    -- select targets for physics flinging
    targetUsername = "",
    flingForwardOffset = 3.0,

    -- automate role-specific interactions
    killAuraEnabled = false,
    killAuraRange = 15,
    killAuraVisible = true,
    killAuraParticleSize = 15.0,
    killAuraParticlePreset = "Fade circle",
    killAuraParticleCustomId = "",
    killAuraParticleEnabled = false,
    killAuraParticleColor = Color3.fromRGB(255, 255, 255),
    killAuraParticleTransparency = 0.2,
    killAuraParticleGlow = 1.0,
    killAuraType = "Stab",
    killAuraParticleCount = 1,
    killAuraDegreeOffset = 0,
    killAuraHeightOffset = 0,
    killAuraParticleSpawnDelay = 0,
    killAuraParticleMinSpin = 0,
    killAuraParticleMaxSpin = 0,
    killAuraParticleColorMode = "Normal",
    killAuraParticleColor2 = Color3.fromRGB(255, 0, 128),

    emoteStopOnMove = false,
    selectedEmote = "Sit",
    customEmotes = {},
    valueCalculatorEnabled = true,
    isFlinging = false,

    -- override jump height limits
    jumpPowerEnabled = false,
    jumpPowerValue = 50,

    -- attach view to focused player
    spectateTarget = false,

    -- track match timestamps for discord logs
    webhookCoinsPerHour = true,
    webhookCurrentCoins = true,

    -- queue automated box purchases
    autoOpenCratesEnabled = false,
    selectedCrateType = "MysteryBox1",
    colorShiftSpeed = 3,
    configFileName = "MM2_MD_CONFIG.json",

    -- render touch shortcuts on touch screens
    mobileButtonsEnabled = false,
    lockMobileButtons = false,
    mobileBtnFlightEnabled = true,
    mobileBtnLockEnabled = true,
    mobileBtnFlingMurdEnabled = true,
    mobileBtnFlingSheriffEnabled = true,
    mobileBtnShootEnabled = true,
}

-- retain active instances for graceful teardown
local Window
local camlockConn
local noclipConn
local flyConn
local spinbotConn
local mobileFlyBtn, mobileCamlockBtn, mobileShootBtn, mobileFlingMurdBtn, mobileFlingSheriffBtn
local removeESP
local espPlayers
local currentCustomSky
local defaultLighting
local worldState
local stretchSettings
local camlockSettings = {
    isLockedOn = false,
    targetPlayer = nil,
    aimLockEnabled = false,
    smoothingFactor = 0.2,
    predictionFactor = 0.2,
    horizontalPrediction = 0.2,
    verticalPrediction = 0.2,
    bodyPartSelected = "Head"
}
local isCoinBagVisible

local function formatCustomAssetId(raw)
    if not raw or raw == "" then return "" end
    local str = tostring(raw):gsub("%s+", "")
    local digits = str:match("%d+")
    return digits and ("rbxassetid://" .. digits) or str
end

local killAuraParticlePresets = {
    ["Fade circle"]           = "112096280571499",
    ["Telemon's fire circle"] = "58889937",
    ["Dashed circle"]         = "10131954007",
    ["Magic circle"]          = "7452563698",
    ["Custom"]                = "",
}

local connections = {}
local threads = {}
local playerConnections = {}
local playerCharConnections = {}

local function trackConnection(conn)
    table.insert(connections, conn)
    return conn
end

local function trackPlayerConnection(plr, conn)
    if not playerConnections[plr] then
        playerConnections[plr] = {}
    end
    table.insert(playerConnections[plr], conn)
    return conn
end

local function clearPlayerConnections(plr)
    if playerConnections[plr] then
        for _, conn in ipairs(playerConnections[plr]) do
            pcall(function() conn:Disconnect() end)
        end
        playerConnections[plr] = nil
    end
end

local function trackThread(thr)
    table.insert(threads, thr)
    return thr
end

local function restoreCharacterCollision(char)
    char = char or LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = (p.Name == "HumanoidRootPart")
        end
    end
end

local function stopAllMovement()
    if state and state.flightEnabled then return end
    if state and state.isFlinging then return end
    pcall(function()
        if noclipConn then
            pcall(function() noclipConn:Disconnect() end)
            noclipConn = nil
        end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj.Name == "SafePlate" or obj:IsA("BodyVelocity") then
                        pcall(function() obj:Destroy() end)
                    end
                end
                pcall(function()
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            restoreCharacterCollision(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end
    end)
end

-- restore default game state on unload 
local cleanupHooks = {}
local function registerCleanupHook(fn)
    table.insert(cleanupHooks, fn)
end

local function doCleanup()
    state.unloaded = true
    state.autofarmEnabled = false
    state.espEnabled = false
    state.aimbotEnabled = false
    state.autoAimEnabled = false
    state.autoAimWallbang = false
    state.flightEnabled = false
    state.isFlinging = false

    if camlockConn then pcall(function() camlockConn:Disconnect() end) camlockConn = nil end
    if currentCustomSky then
        pcall(function() currentCustomSky:Destroy() end)
        currentCustomSky = nil
    end
    if defaultLighting then
        pcall(function()
            LightingService.ClockTime = defaultLighting.ClockTime
            LightingService.Brightness = defaultLighting.Brightness
            LightingService.FogEnd = defaultLighting.FogEnd
            LightingService.FogColor = defaultLighting.FogColor
        end)
    end
    pcall(function()
        RunService:UnbindFromRenderStep("CameraPipeline")
        CurrentCamera.FieldOfView = 70
    end)
    pcall(function() if Window then Window:Destroy() end end)

    for _, fn in ipairs(cleanupHooks) do
        pcall(fn)
    end
    table.clear(cleanupHooks)

    pcall(function()
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if spinbotConn then pcall(function() spinbotConn:Disconnect() end) spinbotConn = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or obj:IsA("BodyPosition") or obj:IsA("BodyMover")
                    or obj.Name == "SafePlate" then
                    pcall(function() obj:Destroy() end)
                end
            end
            pcall(function() hrp.Anchored = false end)
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function()
                        p.Anchored = false
                        p.CanCollide = (p.Name == "HumanoidRootPart")
                    end)
                end
            end
        end
    end)

    pcall(function()
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end)

    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, obj in ipairs(plr.Character:GetChildren()) do
                    if obj.Name == "ChamsHighlight" then pcall(function() obj:Destroy() end) end
                end
            end
        end
    end)

    pcall(function()
        if game:GetAttribute("__MD_ActiveID__") == myUniqueId then
            game:SetAttribute("__MD_ActiveID__", nil)
        end
    end)

    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    for plr, conns in pairs(playerConnections) do
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    end
    table.clear(playerConnections)
    for plr, conn in pairs(playerCharConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(playerCharConnections)
    for _, t in ipairs(threads) do pcall(function() task.cancel(t) end) end
    table.clear(threads)

    pcall(function()
        if stopChinaHat then stopChinaHat() end
        if stopWings then stopWings() end
        if removeOrb then removeOrb() end
        if removeCrosshair then removeCrosshair() end
        if translucentBodyConfig then translucentBodyConfig.enabled = false end
        if applyTranslucentBody then pcall(applyTranslucentBody) end
        if bodyParticlesConfig then bodyParticlesConfig.enabled = false end
        if removeBodyParticles then pcall(removeBodyParticles) end
        if removeBodyContainerPart then pcall(removeBodyContainerPart) end
        if silentAimConfig then silentAimConfig.enabled = false end
        if removeFOVCircle then pcall(removeFOVCircle) end
        if fovCircleDrawing then pcall(function() fovCircleDrawing:Remove() end) fovCircleDrawing = nil end
        if fovCircleGui then pcall(function() fovCircleGui:Destroy() end) fovCircleGui = nil end
        
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr.Character then
                for _, child in ipairs(plr.Character:GetChildren()) do
                    if child.Name == "ChinaHat" or child.Name == "LeftWing" or child.Name == "RightWing" or child.Name == "_LeftWing" or child.Name == "_RightWing" or child.Name == "BodyParticleContainerPart" then
                        pcall(function() child:Destroy() end)
                    end
                end
            end
        end
    end)

    local okCoreGui, coreGui = pcall(function() return game:GetService("CoreGui") end)
    local targetGuiParents = {
        PlayerGui,
        (gethui and gethui() or nil),
        (okCoreGui and coreGui or nil)
    }

    for _, guiName in ipairs({
        "PizdatyUI", "ESPGui",
        "MobileButtonsGui",
        "CrosshairGui", "FOVCircleGui"
    }) do
        for _, parent in ipairs(targetGuiParents) do
            if parent then
                local found = parent:FindFirstChild(guiName)
                if found then pcall(function() found:Destroy() end) end
            end
        end
    end

    pcall(stopAllMovement)
    pcall(function() cleanupSignal:Destroy() end)
    pcall(function()
        local plate = Workspace:FindFirstChild("AntiVoidPlate")
        if plate then plate:Destroy() end
    end)
end

cleanupSignal.Event:Connect(doCleanup)
if getgenv then
    getgenv().MD_MM2_CLEANUP = doCleanup
end




-- live mm2values.com online scraper and item value cache
local MM2Values = {}
local MM2ValuesNormalized = {}
local MM2ValuesByRarity = {}
local MM2ValuesNormalizedByRarity = {}
local MM2ValueDisplays = {}
local isFetchingMM2Values = false
local hasFetchedMM2Values = false

local function fetchMM2ValuesFromWeb()
    if isFetchingMM2Values or hasFetchedMM2Values then return end
    isFetchingMM2Values = true
    task.spawn(function()
        local categories = {
            {slug = 'ancient',  rName = 'Ancient'},
            {slug = 'unique',   rName = 'Unique'},
            {slug = 'chroma',   rName = 'Chroma'},
            {slug = 'godly',    rName = 'Godly'},
            {slug = 'legend',   rName = 'Legendary'},
            {slug = 'rare',     rName = 'Rare'},
            {slug = 'uncommon', rName = 'Uncommon'},
            {slug = 'common',   rName = 'Common'},
            {slug = 'vintage',  rName = 'Vintage'},
            {slug = 'pets',     rName = 'Pets'},
            {slug = 'misc',     rName = 'Misc'},
        }
        local httpReq = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        for _, cat in ipairs(categories) do
            local slug = cat.slug
            local rName = cat.rName
            local html = nil
            pcall(function()
                local url = 'https://www.mm2values.com/?p=' .. slug
                if httpReq then
                    local res = httpReq({Url = url, Method = 'GET', Headers = {['User-Agent'] = 'Roblox/WinInet'}})
                    if res and res.Body then html = res.Body end
                elseif game and game.HttpGet then
                    html = game:HttpGet(url)
                end
            end)
            if html and #html > 0 then
                if not MM2ValuesByRarity[rName] then
                    MM2ValuesByRarity[rName] = {}
                end
                if not MM2ValuesNormalizedByRarity[rName] then
                    MM2ValuesNormalizedByRarity[rName] = {}
                end
                local sPos = 1
                while true do
                    local fStart, fEnd = html:find('<div class=[%w"\']*stackable[%w"\']*>', sPos)
                    if not fStart then break end
                    local nStart = html:find('<div class=[%w"\']*stackable[%w"\']*>', fEnd + 1)
                    local block
                    if nStart then
                        block = html:sub(fEnd + 1, nStart - 1)
                    else
                        block = html:sub(fEnd + 1, fEnd + 4000)
                    end
                    sPos = fEnd + 1

                    local bTag = block:match('<b>(.-)</b>')
                    if bTag then
                        local cleanName = bTag:gsub('<.->', ''):gsub('^%s+', ''):gsub('%s+$', '')
                        -- check calculator numeric value first (e.g. .22 for Pier, .23 for Space, .42 for Bubbles)
                        local calcValStr = block:match('runCalc%s*%(%s*[^,]+%s*,%s*[\'"]([^\'"]+)[\'"]')
                                        or block:match('stackValue%s*%(%s*[^,]+%s*,%s*[\'"]([^\'"]+)[\'"]')
                        -- extract raw display string for tooltip/display (e.g. 2 X (T1) Uncommon or 250)
                        local vDisplay = block:match('Value:%s*([^\r\n<]+)')
                        if vDisplay then
                            vDisplay = vDisplay:gsub('^%s+', ''):gsub('%s+$', '')
                        end

                        local numVal = nil
                        if calcValStr then
                            calcValStr = calcValStr:gsub(',', ''):gsub('%s+', '')
                            numVal = tonumber(calcValStr)
                        end
                        if not numVal and vDisplay then
                            local numPart = vDisplay:match('^([%d%.,]+)')
                            if numPart then
                                numVal = tonumber((numPart:gsub(',', '')))
                            end
                        end

                        if cleanName ~= '' and numVal then
                            local normKey = cleanName:lower():gsub('[^%w]', '')
                            MM2Values[cleanName] = numVal
                            MM2ValuesNormalized[normKey] = numVal
                            MM2ValuesByRarity[rName][cleanName] = numVal
                            MM2ValuesNormalizedByRarity[rName][normKey] = numVal

                            if vDisplay and vDisplay ~= '' then
                                MM2ValueDisplays[cleanName] = vDisplay
                            end

                            -- index base name without brackets or tool suffixes
                            local baseName = cleanName:gsub('%s*%(.-%)', ''):gsub('^%s+', ''):gsub('%s+$', '')
                            if baseName ~= '' then
                                local baseNorm = baseName:lower():gsub('[^%w]', '')
                                if not MM2Values[baseName] then MM2Values[baseName] = numVal end
                                if not MM2ValuesNormalized[baseNorm] then MM2ValuesNormalized[baseNorm] = numVal end
                                if not MM2ValuesByRarity[rName][baseName] then MM2ValuesByRarity[rName][baseName] = numVal end
                                if not MM2ValuesNormalizedByRarity[rName][baseNorm] then MM2ValuesNormalizedByRarity[rName][baseNorm] = numVal end

                                local noSuf = baseName:gsub('%s+[Kk]nife$', ''):gsub('%s+[Gg]un$', ''):gsub('%s+[Aa]xe$', ''):gsub('%s+[Ss]cythe$', '')
                                if noSuf ~= '' then
                                    local noSufNorm = noSuf:lower():gsub('[^%w]', '')
                                    if not MM2Values[noSuf] then MM2Values[noSuf] = numVal end
                                    if not MM2ValuesNormalized[noSufNorm] then MM2ValuesNormalized[noSufNorm] = numVal end
                                    if not MM2ValuesByRarity[rName][noSuf] then MM2ValuesByRarity[rName][noSuf] = numVal end
                                    if not MM2ValuesNormalizedByRarity[rName][noSufNorm] then MM2ValuesNormalizedByRarity[rName][noSufNorm] = numVal end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
        hasFetchedMM2Values = true
        isFetchingMM2Values = false
    end)
end

-- trigger live values scrape from mm2values.com
pcall(fetchMM2ValuesFromWeb)

local function detectRarityFromColor(guiObj)
    if not guiObj then return nil end
    local candidates = {}

    local function addColor(col)
        if not col then return end
        local r = math.round(col.R * 255)
        local g = math.round(col.G * 255)
        local b = math.round(col.B * 255)
        -- ignore neutral text and background shades
        if (r > 240 and g > 240 and b > 240) or (r < 20 and g < 20 and b < 20) then
            return
        end
        table.insert(candidates, {r = r, g = g, b = b})
    end

    -- inspect root container color
    if (guiObj:IsA("ImageLabel") or guiObj:IsA("ImageButton")) and guiObj.ImageColor3 then
        addColor(guiObj.ImageColor3)
    end
    if guiObj:IsA("GuiObject") and guiObj.BackgroundColor3 then
        addColor(guiObj.BackgroundColor3)
    end

    -- inspect direct children colors
    for _, ch in ipairs(guiObj:GetChildren()) do
        if (ch:IsA("ImageLabel") or ch:IsA("ImageButton")) and ch.ImageColor3 then
            addColor(ch.ImageColor3)
        end
        if ch:IsA("GuiObject") and ch.BackgroundColor3 then
            addColor(ch.BackgroundColor3)
        end
    end

    -- inspect nested children colors
    for _, ch in ipairs(guiObj:GetDescendants()) do
        if (ch:IsA("ImageLabel") or ch:IsA("ImageButton")) and ch.ImageColor3 then
            addColor(ch.ImageColor3)
        end
        if ch:IsA("GuiObject") and ch.BackgroundColor3 then
            addColor(ch.BackgroundColor3)
        end
    end

    -- inspect parent card color
    local par = guiObj.Parent
    if par and par:IsA("GuiObject") then
        if (par:IsA("ImageLabel") or par:IsA("ImageButton")) and par.ImageColor3 then
            addColor(par.ImageColor3)
        end
        if par.BackgroundColor3 then
            addColor(par.BackgroundColor3)
        end
    end

    local bestRarity = nil
    local globalMinDist = 999999

    for _, c in ipairs(candidates) do
        local r, g, b = c.r, c.g, c.b

        -- match ui accent colors to item rarity tiers (mm2 inventory card border color constants)
        local dCommon    = math.abs(r - 106) + math.abs(g - 106) + math.abs(b - 106)
        local dUncommon  = math.abs(r - 0)   + math.abs(g - 255) + math.abs(b - 255)
        local dRare      = math.abs(r - 0)   + math.abs(g - 200) + math.abs(b - 0)
        local dLegendary = math.abs(r - 220) + math.abs(g - 0)   + math.abs(b - 5)
        local dGodly     = math.abs(r - 255) + math.abs(g - 0)   + math.abs(b - 179)
        local dVintage   = math.abs(r - 240) + math.abs(g - 130) + math.abs(b - 20)
        local dAncient   = math.abs(r - 110) + math.abs(g - 0)   + math.abs(b - 140)

        local best = "Common"
        local minDist = dCommon
        if dUncommon < minDist then minDist = dUncommon; best = "Uncommon" end
        if dRare < minDist then minDist = dRare; best = "Rare" end
        if dLegendary < minDist then minDist = dLegendary; best = "Legendary" end
        if dGodly < minDist then minDist = dGodly; best = "Godly" end
        if dVintage < minDist then minDist = dVintage; best = "Vintage" end
        if dAncient < minDist then minDist = dAncient; best = "Ancient" end

        if minDist < globalMinDist then
            globalMinDist = minDist
            bestRarity = best
        end
    end

    if globalMinDist <= 80 then
        return bestRarity
    end
    return nil
end

local function getMM2ItemValue(rawName, rarity)
    if not rawName or rawName == "" then return 0 end
    local clean = rawName:gsub("^%s+", ""):gsub("%s+$", "")
    if clean:lower():find("default") then return 0 end

    local normKey = clean:lower():gsub("[^%w]", "")
    local normNoSuf = clean:lower():gsub("%s+knife$", ""):gsub("%s+gun$", ""):gsub("%s+axe$", ""):gsub("%s+scythe$", ""):gsub("[^%w]", "")

    local tierDefaults = {
        ["Legendary"] = 0.32,
        ["Rare"] = 0.22,
        ["Uncommon"] = 0.13,
        ["Common"] = 0.11,
        ["Godly"] = 2.0,
        ["Chroma"] = 20.0,
        ["Vintage"] = 3.0,
        ["Ancient"] = 15.0,
        ["Unique"] = 325.0,
    }

    -- 1. check rarity table if rarity is detected
    if rarity and MM2ValuesByRarity and MM2ValuesByRarity[rarity] then
        local rTab = MM2ValuesByRarity[rarity]
        if rTab[clean] and rTab[clean] > 0 then return rTab[clean] end
        if MM2ValuesNormalizedByRarity and MM2ValuesNormalizedByRarity[rarity] then
            local rNorm = MM2ValuesNormalizedByRarity[rarity]
            if rNorm[normKey] and rNorm[normKey] > 0 then return rNorm[normKey] end
            if rNorm[normNoSuf] and rNorm[normNoSuf] > 0 then return rNorm[normNoSuf] end
        end
    end

    -- 2. check global tables directly
    if MM2Values and MM2Values[clean] and MM2Values[clean] > 0 then
        return MM2Values[clean]
    end
    if MM2ValuesNormalized then
        if MM2ValuesNormalized[normKey] and MM2ValuesNormalized[normKey] > 0 then
            return MM2ValuesNormalized[normKey]
        end
        if MM2ValuesNormalized[normNoSuf] and MM2ValuesNormalized[normNoSuf] > 0 then
            return MM2ValuesNormalized[normNoSuf]
        end
    end

    -- 3. check all other rarities
    if MM2ValuesNormalizedByRarity then
        for _, checkR in ipairs({"Common", "Uncommon", "Rare", "Legendary", "Vintage", "Ancient", "Unique", "Godly", "Chroma"}) do
            local rNorm = MM2ValuesNormalizedByRarity[checkR]
            if rNorm then
                if rNorm[normKey] and rNorm[normKey] > 0 then return rNorm[normKey] end
                if rNorm[normNoSuf] and rNorm[normNoSuf] > 0 then return rNorm[normNoSuf] end
            end
        end
    end

    -- 4. fallback to tier default if detected, otherwise 0
    if rarity and tierDefaults[rarity] then
        return tierDefaults[rarity]
    end

    return 0
end

local function getMM2ItemDisplay(rawName)
    if not rawName or rawName == "" then return nil end
    local clean = rawName:gsub("^%s+", ""):gsub("%s+$", "")
    if MM2ValueDisplays and MM2ValueDisplays[clean] then
        return MM2ValueDisplays[clean]
    end
    local lower = clean:lower()
    if MM2ValueDisplays then
        for name, disp in pairs(MM2ValueDisplays) do
            if name:lower() == lower then return disp end
        end
    end
    return nil
end

local function formatValue(val)
    val = tonumber(val) or 0
    if val >= 1000000 then
        return string.format("%.1fM", val / 1000000):gsub("%.0M", "M")
    elseif val >= 10000 then
        return string.format("%.1fk", val / 1000):gsub("%.0k", "k")
    elseif val >= 1 then
        if math.abs(val - math.floor(val)) > 0.01 then
            local formatted = string.format("%.2f", val):gsub("%.?0+$", "")
            return formatted
        else
            local formatted = tostring(math.floor(val))
            while true do
                local k
                formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
                if k == 0 then break end
            end
            return formatted
        end
    elseif val > 0 then
        local formatted = string.format("%.2f", val):gsub("%.?0+$", "")
        return formatted
    else
        return "0"
    end
end

-- load ui library directly from github
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rilorfakesilly/scripts/refs/heads/main/MDuiLib.lua"))()

Window = Library:CreateWindow({
    Title = "MorningDrift MM2",
    ScriptName = "MorningDrift MM2",
    Discord = "discord.gg/48jdqB8rAw"
})

-- leverage library layout rows for element grouping

-- sync palette updates to active elements
local _origApplyTheme = Window.ApplyTheme
function Window:ApplyTheme(themeKey)
    local res = _origApplyTheme(self, themeKey)
    local currentTheme = Window.CurrentTheme or (Library.ThemePresets and Library.ThemePresets[themeKey])
    if currentTheme then
        if Window.RegisteredMDButtons then
            for _, btnData in ipairs(Window.RegisteredMDButtons) do
                if btnData and btnData.Frame and btnData.Frame.Parent then
                    btnData.Frame.BackgroundColor3 = currentTheme.ButtonBG
                    if btnData.TextLabel then btnData.TextLabel.TextColor3 = currentTheme.Text end
                end
            end
        end
        if Window.RegisteredSections then
            for _, sec in ipairs(Window.RegisteredSections) do
                if sec and sec.RefreshTheme then
                    pcall(function() sec:RefreshTheme(currentTheme, false) end)
                end
            end
        end
    end
    return res
end

local _origApplyCustomTheme = Window.ApplyCustomTheme
function Window:ApplyCustomTheme(baseColor)
    local res = _origApplyCustomTheme(self, baseColor)
    local currentTheme = Window.CurrentTheme
    if currentTheme then
        if Window.RegisteredMDButtons then
            for _, btnData in ipairs(Window.RegisteredMDButtons) do
                if btnData and btnData.Frame and btnData.Frame.Parent then
                    btnData.Frame.BackgroundColor3 = currentTheme.ButtonBG
                    if btnData.TextLabel then btnData.TextLabel.TextColor3 = currentTheme.Text end
                end
            end
        end
        if Window.RegisteredSections then
            for _, sec in ipairs(Window.RegisteredSections) do
                if sec and sec.RefreshTheme then
                    pcall(function() sec:RefreshTheme(currentTheme, false) end)
                end
            end
        end
    end
    return res
end

local Options = {}

local function log(msg)
    pcall(function()
        if Window and Window.Notify then
            Window:Notify("MD MM2", tostring(msg), 3)
        end
    end)
end

-- control atmosphere and ambient contrast

local skyboxPresets = {
    ["Default"] = nil,
    ["Space Skybox"] = "136402262",
    ["Fog on the water"] = "15876671760",
    ["Red sky"] = "136055162054954",
    ["Midnight"] = "179809386",
    ["Tattletail"] = "75818364502492"
}

worldState = {
    skyboxPreset = "Default",
    customTime = 14,
    timeEnabled = false,
    customBrightness = 2,
    brightnessEnabled = false,
    customFog = false,
    fogEndDistance = 2000,
    fogColor = Color3.fromRGB(180, 200, 220),
}

defaultLighting = {
    ClockTime = LightingService.ClockTime,
    Brightness = LightingService.Brightness,
    FogEnd = LightingService.FogEnd,
    FogColor = LightingService.FogColor
}

local activeSkyboxAssetId = nil

local function applySkybox(assetId)
    activeSkyboxAssetId = (assetId and assetId ~= "") and assetId or nil

    if currentCustomSky then
        pcall(function() currentCustomSky:Destroy() end)
        currentCustomSky = nil
    end

    if not assetId or assetId == "" then return end

    local cleanId = tostring(assetId):match("%d+")
    if not cleanId then return end

    for _, child in ipairs(LightingService:GetChildren()) do
        if child:IsA("Sky") and child.Name ~= "CustomSkybox" then
            pcall(function() child:Destroy() end)
        end
    end

    local loaded = false
    pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. cleanId)
        if objects and #objects > 0 then
            local skyObj = nil
            for _, obj in ipairs(objects) do
                if obj:IsA("Sky") then
                    skyObj = obj
                    break
                elseif obj:FindFirstChildOfClass("Sky") then
                    skyObj = obj:FindFirstChildOfClass("Sky")
                    break
                end
            end
            if skyObj then
                skyObj.Name = "CustomSkybox"
                skyObj.Parent = LightingService
                currentCustomSky = skyObj
                loaded = true
            end
        end
    end)

    if not loaded then
        local sky = Instance.new("Sky")
        sky.Name = "CustomSkybox"
        local formatted = "rbxassetid://" .. cleanId
        sky.SkyboxBk = formatted
        sky.SkyboxDn = formatted
        sky.SkyboxFt = formatted
        sky.SkyboxLf = formatted
        sky.SkyboxRt = formatted
        sky.SkyboxUp = formatted
        sky.CelestialBodiesShown = true
        sky.Parent = LightingService
        currentCustomSky = sky
    end
end

-- keep custom skybox across round map reloads
task.spawn(function()
    while not (state and state.unloaded) do
        task.wait(1.5)
        if state and state.unloaded then break end
        if activeSkyboxAssetId and activeSkyboxAssetId ~= "" then
            local needsRefresh = false
            if not currentCustomSky or currentCustomSky.Parent ~= LightingService then
                needsRefresh = true
            else
                for _, child in ipairs(LightingService:GetChildren()) do
                    if child:IsA("Sky") and child ~= currentCustomSky then
                        pcall(function() child:Destroy() end)
                        needsRefresh = true
                    end
                end
            end
            if needsRefresh then
                applySkybox(activeSkyboxAssetId)
            end
        end
    end
end)

local function updateLighting()
    if not worldState then return end
    if worldState.timeEnabled then
        LightingService.ClockTime = worldState.customTime
    end
    if worldState.brightnessEnabled then
        LightingService.Brightness = worldState.customBrightness
    end
    if worldState.customFog then
        local atmos = LightingService:FindFirstChildOfClass("Atmosphere")
        if atmos then
            atmos.Density = math.clamp(1 - (worldState.fogEndDistance / 5000), 0.1, 0.95)
            atmos.Color = worldState.fogColor
            atmos.Decay = worldState.fogColor
        end
        LightingService.FogStart = 0
        LightingService.FogEnd = worldState.fogEndDistance
        LightingService.FogColor = worldState.fogColor
    end
end

trackThread(task.spawn(function()
    while not (state and state.unloaded) do
        updateLighting()
        task.wait(1.5)
    end
end))

-- widen field of view and stretch aspect ratio
stretchSettings = {
    enabled = false,
    horizontalScale = 0.53,
    verticalScale = 0.74,
    customFov = 70,
    fovModifierEnabled = false
}

local function onCameraStep()
    if state and state.unloaded then return end

    -- scale camera fov dynamically
    if stretchSettings.fovModifierEnabled then
        CurrentCamera.FieldOfView = stretchSettings.customFov
    end

    -- adjust viewport aspect scale
    if stretchSettings.enabled then
        local cf = CurrentCamera.CFrame
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
        local sx = stretchSettings.horizontalScale
        local sy = stretchSettings.verticalScale

        CurrentCamera.CFrame = CFrame.new(
            x, y, z,
            r00 * sx, r01 * sy, r02,
            r10 * sx, r11 * sy, r12,
            r20 * sx, r21 * sy, r22
        )
    end
end

pcall(function()
    RunService:BindToRenderStep("CameraPipeline", Enum.RenderPriority.Camera.Value + 1, onCameraStep)
end)


-- detect active murderer and sheriff gear 
local function isKnifeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool.Name == "Knife" then return true end
    if tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("Stab") or tool:FindFirstChild("KnifeHost") or tool:FindFirstChild("Throw") or tool:FindFirstChild("Knife") or tool:FindFirstChild("KnifeClient") then
        return true
    end
    return false
end

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool.Name == "Gun" or tool.Name == "Revolver" then return true end
    if tool:FindFirstChild("GunServer") or tool:FindFirstChild("Shoot") or tool:FindFirstChild("GunHost") or tool:FindFirstChild("ShootScript") or tool:FindFirstChild("GunClient") then
        return true
    end
    return false
end

local function getPlayerTool(plr, toolType)
    if not plr then return nil end
    local containers = {}
    if plr.Character then table.insert(containers, plr.Character) end
    local bp = plr:FindFirstChild("Backpack")
    if bp then table.insert(containers, bp) end

    for _, container in ipairs(containers) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                if toolType == "Knife" and isKnifeTool(item) then
                    return item
                elseif toolType == "Gun" and isGunTool(item) then
                    return item
                elseif item.Name == toolType then
                    return item
                end
            end
        end
    end
    return nil
end

local function hasTool(plr, toolType)
    return getPlayerTool(plr, toolType) ~= nil
end

local function isPlayerAlive(plr)
    if not plr or not plr.Parent then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    if hum.Health <= 0 then return false end
    return true
end

local function getPlayerData()
    local rs = game:GetService("ReplicatedStorage")
    local pd = rs:FindFirstChild("GetPlayerData", true) or rs:FindFirstChild("PlayerData", true)
    if pd then
        local success, data
        if pd:IsA("BindableFunction") then
            success, data = pcall(function() return pd:Invoke() end)
        elseif pd:IsA("RemoteFunction") then
            success, data = pcall(function() return pd:InvokeServer() end)
        end
        if success and type(data) == "table" then
            return data
        end
    end
    return nil
end

local _lastRolesCache = { murderer = nil, sheriff = nil, lastCheck = 0 }

local function getGameRoles()
    if tick() - _lastRolesCache.lastCheck < 0.25 then
        return _lastRolesCache.murderer, _lastRolesCache.sheriff
    end
    _lastRolesCache.lastCheck = tick()
    local murderer, sheriff = nil, nil

    -- check replicated state first to avoid backpack scan
    local playerData = getPlayerData()
    if playerData then
        for player, data in pairs(playerData) do
            if type(data) == "table" and data.Role then
                local targetPlr = nil
                if typeof(player) == "Instance" and player:IsA("Player") then
                    targetPlr = player
                elseif type(player) == "string" then
                    targetPlr = Players:FindFirstChild(player)
                end
                if targetPlr and isPlayerAlive(targetPlr) then
                    local r = data.Role
                    if r == "Murderer" or r == "Murder" then
                        murderer = targetPlr
                    elseif r == "Sheriff" or r == "Hero" then
                        sheriff = targetPlr
                    end
                end
            end
        end
    end

    -- scan tool instances when replicated data is missing
    if not murderer then
        if state.knifeHolder and isPlayerAlive(state.knifeHolder) then
            murderer = state.knifeHolder
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if isPlayerAlive(p) and hasTool(p, "Knife") then
                    murderer = p
                    break
                end
            end
        end
    end

    if not sheriff then
        if state.gunHolder and isPlayerAlive(state.gunHolder) then
            sheriff = state.gunHolder
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if isPlayerAlive(p) and hasTool(p, "Gun") then
                    sheriff = p
                    break
                end
            end
        end
    end

    _lastRolesCache.murderer = murderer
    _lastRolesCache.sheriff = sheriff
    return murderer, sheriff
end

local function getMurd()
    local murderer, _ = getGameRoles()
    return murderer
end
local function getSheriff()
    local _, sheriff = getGameRoles()
    return sheriff
end

local function getPlayerRole(plr)
    if not plr then return "Innocent" end
    local m, s = getGameRoles()
    if m and m == plr and isPlayerAlive(plr) then return "Murderer" end
    if s and s == plr and isPlayerAlive(plr) then return "Sheriff" end
    return "Innocent"
end

-- configure projectile aim-assist bounds
local silentAimConfig = {
    enabled = false,
    hitChance = 100,
    targetPart = "Head",
    randomOffset = false,
    wallCheck = false,
    aliveCheck = true,
    wallbang = false,
    predictionFactor = 0.2,
    horizontalPrediction = 0.2,
    verticalPrediction = 0.2,

    fovRadius = 125,
    fovVisible = true,
    fovType = "Normal",
    spin = false,
    spinSpeed = 60,
    colorMode = "Normal",
    color1 = Color3.fromRGB(255, 60, 60),
    color2 = Color3.fromRGB(0, 170, 255),
    transparency = 0,
    shadow = false,
    shadowTransparency = 0.5,
    filled = false,
}

local customSoundPresets = {
    Gunshot = {
        ["Minecraft"]    = "123925235254965",
        ["Laser"]        = "1898322396",
        ["CS:GO Deagle"] = "82286818216627",
        ["Custom"]       = ""
    },
    Coin = {
        ["Ultrakill coinflip"] = "138571475125488",
        ["Coin click"]         = "133570405319995",
        ["Coin click 2"]       = "10066947742",
        ["Custom"]             = ""
    },
    Reload = {
        ["Laser pistol"] = "1898332552",
        ["Custom"]       = ""
    },
    GunKill = {
        ["Fortnite knocked"] = "118171751820277",
        ["CS:GO headshot"]   = "118849595584555",
        ["Fatality"]         = "115982072912004",
        ["Rust headshot"]    = "138750331387064",
        ["Tom scream"]       = "139694892021582",
        ["Old church bell"]  = "139726388352120",
        ["Ouch"]             = "137171473068941",
        ["Minecraft"]        = "135478009117226",
        ["Death note"]       = "140695149439373",
        ["Victory"]          = "124793974135748",
        ["Stariy bog"]       = "117940360151688",
        ["Stariy bog yaica"] = "120335972389688",
        ["Custom"]           = ""
    },
    KnifeKill = {
        ["Golden pan"]   = "135260359985455",
        ["Orange water"] = "94072167050534",
        ["Bye bye"]      = "111254351722884",
        ["Katana"]       = "109880603489484",
        ["Knife slice"]  = "133096341705333",
        ["Custom"]       = ""
    }
}

local customSoundConfigs = {
    Gunshot = {
        Enabled = false,
        Target = "Own",
        Preset = "Minecraft",
        CustomId = "",
        SoundId = "123925235254965",
        Volume = 1.0,
    },
    Coin = {
        Enabled = false,
        Target = "Own",
        Preset = "Ultrakill coinflip",
        CustomId = "",
        SoundId = "138571475125488",
        Volume = 1.0,
    },
    Reload = {
        Enabled = false,
        Target = "Own",
        Preset = "Laser pistol",
        CustomId = "",
        SoundId = "1898332552",
        Volume = 1.0,
    },
    GunKill = {
        Enabled = false,
        Target = "Own",
        Preset = "Fortnite knocked",
        CustomId = "",
        SoundId = "118171751820277",
        Volume = 1.0,
    },
    KnifeKill = {
        Enabled = false,
        Target = "Own",
        Preset = "Golden pan",
        CustomId = "",
        SoundId = "135260359985455",
        Volume = 1.0,
    }
}

local function getActiveCustomSoundId(cat)
    local cfg = customSoundConfigs[cat]
    if not cfg then return "" end
    local preset = cfg.Preset
    if preset == "Custom" then
        return cfg.CustomId or ""
    end
    local presets = customSoundPresets[cat]
    return (presets and presets[preset]) or cfg.CustomId or cfg.SoundId or ""
end

local refreshCustomSounds = function() end

local fovCircleDrawing = nil
local fovDotDrawings = {}
local fovLineDrawings = {}
local fovCircleGuiFrame = nil
local fovCircleGui = nil

local function removeFOVCircle()
    if fovCircleDrawing then
        pcall(function() fovCircleDrawing.Visible = false end)
        pcall(function() fovCircleDrawing:Remove() end)
        fovCircleDrawing = nil
    end
    for _, dot in ipairs(fovDotDrawings) do
        pcall(function() dot.Visible = false end)
        pcall(function() dot:Remove() end)
    end
    table.clear(fovDotDrawings)
    for _, line in ipairs(fovLineDrawings) do
        pcall(function() line.Visible = false end)
        pcall(function() line:Remove() end)
    end
    table.clear(fovLineDrawings)
    if fovCircleGui then
        pcall(function() fovCircleGui:Destroy() end)
        fovCircleGui = nil
        fovCircleGuiFrame = nil
    end
end

local _fovGradientAngle = 0
local _canCreateUIShadow = true
local fovElementsContainer = nil

local function updateFOVCircle()
    if not silentAimConfig.enabled or not silentAimConfig.fovVisible or (state and state.unloaded) then
        removeFOVCircle()
        return
    end

    -- avoid orphaned overlays across mode switches
    if fovCircleDrawing then pcall(function() fovCircleDrawing.Visible = false end) end
    for _, d in ipairs(fovDotDrawings) do pcall(function() d.Visible = false end) end
    for _, l in ipairs(fovLineDrawings) do pcall(function() l.Visible = false end) end

    local mouseLoc = UserInputService:GetMouseLocation()
    local colorMode = silentAimConfig.colorMode or "Normal"
    local fovType = silentAimConfig.fovType or "Normal"
    local r = silentAimConfig.fovRadius or 100
    local c1 = silentAimConfig.color1 or Color3.fromRGB(255, 0, 0)
    local c2 = silentAimConfig.color2 or Color3.fromRGB(0, 170, 255)
    local trans = silentAimConfig.transparency or 0

    if not fovCircleGuiFrame then
        local parentGui = gethui and gethui() or (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or PlayerGui)
        local sg = Instance.new("ScreenGui")
        sg.Name = "FOVCircleGui"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local f = Instance.new("Frame")
        f.Name = "FOVCircle"
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BackgroundTransparency = 1
        f.Parent = sg

        local c = Instance.new("UICorner", f)
        c.CornerRadius = UDim.new(1, 0)

        local s = Instance.new("UIStroke", f)
        s.Thickness = 2
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        sg.Parent = parentGui
        fovCircleGui = sg
        fovCircleGuiFrame = f
    end

    local diam = r * 2
    fovCircleGuiFrame.Size = UDim2.fromOffset(diam, diam)
    fovCircleGuiFrame.Position = UDim2.fromOffset(mouseLoc.X, mouseLoc.Y)
    fovCircleGuiFrame.BackgroundTransparency = silentAimConfig.filled and trans or 1
    fovCircleGuiFrame.BackgroundColor3 = c1

    local uiShadow = fovCircleGuiFrame:FindFirstChildOfClass("UIShadow")
    if silentAimConfig.shadow then
        if not uiShadow and _canCreateUIShadow then
            local ok, s = pcall(function() return Instance.new("UIShadow") end)
            if ok and s then
                s.BlurRadius = UDim.new(0, 15)
                s.Color = Color3.new(0, 0, 0)
                s.Offset = UDim2.new(0, 2, 0, 2)
                s.Parent = fovCircleGuiFrame
                uiShadow = s
            else
                _canCreateUIShadow = false
            end
        end
        if uiShadow then
            pcall(function()
                uiShadow.Transparency = silentAimConfig.shadowTransparency or 0.5
                uiShadow.Color = Color3.new(0, 0, 0)
                uiShadow.Enabled = true
            end)
        end
    else
        if uiShadow then
            pcall(function() uiShadow.Enabled = false end)
        end
    end

    local rotOffset = (silentAimConfig.spin and (tick() * (silentAimConfig.spinSpeed or 60) * (math.pi / 180))) or 0
    if silentAimConfig.spin then
        fovCircleGuiFrame.Rotation = (fovCircleGuiFrame.Rotation + (silentAimConfig.spinSpeed or 60) * 0.016) % 360
    else
        fovCircleGuiFrame.Rotation = 0
    end

    local stroke = fovCircleGuiFrame:FindFirstChildOfClass("UIStroke")

    -- group procedural indicator segments
    if fovType == "Dots" or fovType == "Stripes" or fovType == "Dots out of dots" then
        if stroke then stroke.Enabled = false end
        fovCircleGuiFrame.BackgroundTransparency = 1

        if not fovElementsContainer or fovElementsContainer.Parent ~= fovCircleGui then
            if fovElementsContainer then pcall(function() fovElementsContainer:Destroy() end) end
            local container = Instance.new("Frame")
            container.Name = "FOVElementsContainer"
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, 0, 1, 0)
            container.Parent = fovCircleGui
            fovElementsContainer = container
        end
        fovElementsContainer.Visible = true

        local isDots = (fovType == "Dots")
        local isDotsOut = (fovType == "Dots out of dots")
        local isStripes = (fovType == "Stripes")

        local count = 12
        local assetId = "rbxassetid://187012669"

        if isDots then
            count = math.clamp(math.floor(r / 5), 16, 48)
            assetId = "rbxassetid://187012669"
        elseif isDotsOut then
            count = math.clamp(math.floor(r / 6), 12, 36)
            assetId = "rbxassetid://76727753077449"
        elseif isStripes then
            count = 12 -- space ring segments evenly around circumference
            assetId = "rbxassetid://125191624584912"
        end

        local shiftSpeed = state and state.colorShiftSpeed or 3
        local animPhase = (tick() * (shiftSpeed * 0.15)) % 1.0

        for i = 1, count do
            local childName = "Elem_" .. i
            local imgLabel = fovElementsContainer:FindFirstChild(childName)
            if not imgLabel then
                imgLabel = Instance.new("ImageLabel")
                imgLabel.Name = childName
                imgLabel.BackgroundTransparency = 1
                imgLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                imgLabel.Parent = fovElementsContainer
            end

            local angle = (i / count) * math.pi * 2 + rotOffset
            local pos = mouseLoc + Vector2.new(math.cos(angle) * r, math.sin(angle) * r)
            imgLabel.Position = UDim2.fromOffset(pos.X, pos.Y)
            imgLabel.Image = assetId
            imgLabel.ImageTransparency = trans

            if isDots then
                imgLabel.Size = UDim2.fromOffset(10, 10)
                imgLabel.Rotation = 0
            elseif isDotsOut then
                imgLabel.Size = UDim2.fromOffset(14, 14)
                imgLabel.Rotation = 0
            elseif isStripes then
                imgLabel.Size = UDim2.fromOffset(24, 8)
                -- orient indicator notches toward center
                local dirX = mouseLoc.X - pos.X
                local dirY = mouseLoc.Y - pos.Y
                local centerAngleDeg = math.deg(math.atan2(dirY, dirX))
                imgLabel.Rotation = centerAngleDeg
            end

            -- apply directional color gradients across perimeter
            local elemColor = c1
            if colorMode == "2 colors" then
                local tVal = (math.sin(tick() * shiftSpeed) + 1) / 2
                elemColor = c1:Lerp(c2, tVal)
            elseif colorMode == "Shift" then
                -- animate gradient waves across screen x axis
                local screenX = (mouseLoc + Vector2.new(math.cos(angle) * r, math.sin(angle) * r)).X
                local normX = math.clamp(screenX / (workspace.CurrentCamera.ViewportSize.X or 1920), 0, 1)
                local tVal = (math.sin((normX + animPhase) * math.pi * 2) + 1) * 0.5
                elemColor = c1:Lerp(c2, tVal)
            elseif colorMode == "Gradient" or colorMode == "Gradient 2" then
                local tVal = (math.sin((angle / (math.pi * 2) + animPhase) * math.pi * 2) + 1) * 0.5
                elemColor = c1:Lerp(c2, tVal)
            elseif colorMode == "Rainbow" then
                local hue = ((angle / (math.pi * 2)) + animPhase) % 1.0
                elemColor = Color3.fromHSV(hue, 1, 1)
            elseif colorMode == "Rainbow 2" then
                -- align hue spectrum with screen space
                local screenX = (mouseLoc + Vector2.new(math.cos(angle) * r, math.sin(angle) * r)).X
                local normX = math.clamp(screenX / (workspace.CurrentCamera.ViewportSize.X or 1920), 0, 1)
                local hue = (normX + animPhase) % 1.0
                elemColor = Color3.fromHSV(hue, 1, 1)
            end
            imgLabel.ImageColor3 = elemColor
            imgLabel.Visible = true
        end

        -- avoid rendering inactive ring styles
        for _, child in ipairs(fovElementsContainer:GetChildren()) do
            local idx = tonumber(child.Name:match("^Elem_(%d+)$"))
            if idx and idx > count then
                child.Visible = false
            end
        end
    else
        if stroke then stroke.Enabled = true end
        if fovElementsContainer then fovElementsContainer.Visible = false end

        local white = Color3.new(1, 1, 1)

        -- update vector drawing circle attributes
        if colorMode == "Normal" then
            local oldGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if oldGrad then oldGrad:Destroy() end
            fovCircleGuiFrame.BackgroundColor3 = c1
            if stroke then
                local oldStrokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if oldStrokeGrad then oldStrokeGrad:Destroy() end
                stroke.Color = c1
            end
        elseif colorMode == "2 colors" then
            local oldGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if oldGrad then oldGrad:Destroy() end
            local shiftSpeed = state and state.colorShiftSpeed or 3
            local tVal = (math.sin(tick() * shiftSpeed) + 1) / 2
            local cycledCol = c1:Lerp(c2, tVal)
            fovCircleGuiFrame.BackgroundColor3 = cycledCol
            if stroke then
                local oldStrokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if oldStrokeGrad then oldStrokeGrad:Destroy() end
                stroke.Color = cycledCol
            end
        elseif colorMode == "Shift" then
            fovCircleGuiFrame.BackgroundColor3 = white
            if stroke then stroke.Color = white end

            local shiftSpeed = state and state.colorShiftSpeed or 3
            local phase = (tick() * (shiftSpeed * 0.15)) % 1.0
            -- pulse color cycle smoothly over time
            local function shiftCol(off)
                local tVal = (math.sin((phase + off) * math.pi * 2) + 1) * 0.5
                return c1:Lerp(c2, tVal)
            end
            local shiftSeq = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    shiftCol(0)),
                ColorSequenceKeypoint.new(0.25, shiftCol(0.25)),
                ColorSequenceKeypoint.new(0.5,  shiftCol(0.5)),
                ColorSequenceKeypoint.new(0.75, shiftCol(0.75)),
                ColorSequenceKeypoint.new(1,    shiftCol(1))
            })

            local frameGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if not frameGrad then
                frameGrad = Instance.new("UIGradient")
                frameGrad.Parent = fovCircleGuiFrame
            end
            frameGrad.Color = shiftSeq
            frameGrad.Rotation = 0

            if stroke then
                local strokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if not strokeGrad then
                    strokeGrad = Instance.new("UIGradient")
                    strokeGrad.Parent = stroke
                end
                strokeGrad.Color = shiftSeq
                strokeGrad.Rotation = 0
            end
        elseif colorMode == "Gradient" then
            fovCircleGuiFrame.BackgroundColor3 = white
            if stroke then stroke.Color = white end

            local speed = silentAimConfig.spinSpeed or 60
            _fovGradientAngle = (_fovGradientAngle + speed * 0.016) % 360

            local frameGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if not frameGrad then
                frameGrad = Instance.new("UIGradient")
                frameGrad.Parent = fovCircleGuiFrame
            end
            frameGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, c1),
                ColorSequenceKeypoint.new(0.5, c2),
                ColorSequenceKeypoint.new(1, c1)
            })
            frameGrad.Rotation = _fovGradientAngle

            if stroke then
                local strokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if not strokeGrad then
                    strokeGrad = Instance.new("UIGradient")
                    strokeGrad.Parent = stroke
                end
                strokeGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c1),
                    ColorSequenceKeypoint.new(0.5, c2),
                    ColorSequenceKeypoint.new(1, c1)
                })
                strokeGrad.Rotation = _fovGradientAngle
            end
        elseif colorMode == "Gradient 2" then
            fovCircleGuiFrame.BackgroundColor3 = white
            if stroke then stroke.Color = white end

            local shiftSpeed = state and state.colorShiftSpeed or 3
            local phase = (tick() * (shiftSpeed * 0.15)) % 1.0
            local function getSmoothCol(off)
                local tVal = (math.sin((phase + off) * math.pi * 2) + 1) * 0.5
                return c1:Lerp(c2, tVal)
            end
            local animSeq = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    getSmoothCol(0)),
                ColorSequenceKeypoint.new(0.25, getSmoothCol(0.25)),
                ColorSequenceKeypoint.new(0.5,  getSmoothCol(0.5)),
                ColorSequenceKeypoint.new(0.75, getSmoothCol(0.75)),
                ColorSequenceKeypoint.new(1,    getSmoothCol(1))
            })

            local frameGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if not frameGrad then
                frameGrad = Instance.new("UIGradient")
                frameGrad.Parent = fovCircleGuiFrame
            end
            frameGrad.Color = animSeq
            frameGrad.Rotation = 0

            if stroke then
                local strokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if not strokeGrad then
                    strokeGrad = Instance.new("UIGradient")
                    strokeGrad.Parent = stroke
                end
                strokeGrad.Color = animSeq
                strokeGrad.Rotation = 0
            end
        elseif colorMode == "Rainbow" then
            fovCircleGuiFrame.BackgroundColor3 = white
            if stroke then stroke.Color = white end

            local speed = silentAimConfig.spinSpeed or 60
            _fovGradientAngle = (_fovGradientAngle + speed * 0.016) % 360

            local rainbowSeq = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0.00, 1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1))
            })

            local frameGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if not frameGrad then
                frameGrad = Instance.new("UIGradient")
                frameGrad.Parent = fovCircleGuiFrame
            end
            frameGrad.Color = rainbowSeq
            frameGrad.Rotation = _fovGradientAngle

            if stroke then
                local strokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if not strokeGrad then
                    strokeGrad = Instance.new("UIGradient")
                    strokeGrad.Parent = stroke
                end
                strokeGrad.Color = rainbowSeq
                strokeGrad.Rotation = _fovGradientAngle
            end
        elseif colorMode == "Rainbow 2" then
            fovCircleGuiFrame.BackgroundColor3 = white
            if stroke then stroke.Color = white end

            local shiftSpeed = state and state.colorShiftSpeed or 3
            local phase = (tick() * (shiftSpeed * 0.15)) % 1.0

            local rainbowSeq2 = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV((0.00 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV((0.17 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV((0.33 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV((0.50 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV((0.67 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV((0.83 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1.00, Color3.fromHSV((1.00 + phase) % 1, 1, 1))
            })

            local frameGrad = fovCircleGuiFrame:FindFirstChildOfClass("UIGradient")
            if not frameGrad then
                frameGrad = Instance.new("UIGradient")
                frameGrad.Parent = fovCircleGuiFrame
            end
            frameGrad.Color = rainbowSeq2
            frameGrad.Rotation = 0

            if stroke then
                local strokeGrad = stroke:FindFirstChildOfClass("UIGradient")
                if not strokeGrad then
                    strokeGrad = Instance.new("UIGradient")
                    strokeGrad.Parent = stroke
                end
                strokeGrad.Color = rainbowSeq2
                strokeGrad.Rotation = 0
            end
        end
    end

    fovCircleGuiFrame.Visible = true
end

-- block targeting through solid obstructions
local function isPartVisible(part, character)
    if not part then return false end
    local origin = CurrentCamera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ignoreList = { CurrentCamera }
    if LocalPlayer.Character then
        table.insert(ignoreList, LocalPlayer.Character)
    end
    params.FilterDescendantsInstances = ignoreList

    local result = Workspace:Raycast(origin, direction, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(character)
end


local function getAutoAimTarget()
    if state and state.unloaded then return nil, nil end
    local targetPlayer = nil
    local targetPart = nil

    local murderer = state and state.knifeHolder or getMurd()
    if murderer and isPlayerAlive(murderer) and murderer ~= LocalPlayer then
        targetPlayer = murderer
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isPlayerAlive(p) and hasTool(p, "Knife") then
                targetPlayer = p
                break
            end
        end
    end

    if not targetPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isPlayerAlive(p) then
                targetPlayer = p
                break
            end
        end
    end

    if targetPlayer and targetPlayer.Character then
        local char = targetPlayer.Character
        if silentAimConfig.targetPart == "Random" then
            local partsList = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"}
            local available = {}
            for _, pName in ipairs(partsList) do
                local pt = char:FindFirstChild(pName)
                if pt and pt:IsA("BasePart") then
                    table.insert(available, pt)
                end
            end
            if #available > 0 then
                targetPart = available[math.random(1, #available)]
            end
        elseif silentAimConfig.targetPart and silentAimConfig.targetPart ~= "" then
            targetPart = char:FindFirstChild(silentAimConfig.targetPart)
        end

        if not targetPart then
            targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        end
    end

    return targetPlayer, targetPart
end

local function calculateAimPosition(rawPos, part, predH, predV)
    if not part then return rawPos end

    local vel = Vector3.zero
    pcall(function()
        vel = part.AssemblyLinearVelocity or part.Velocity or Vector3.zero
    end)

    local hFactor = tonumber(predH) or 0
    local vFactor = tonumber(predV) or 0
    if hFactor < 0 then hFactor = 0 end
    if vFactor < 0 then vFactor = 0 end

    local offsetX = vel.X * hFactor
    local offsetZ = vel.Z * hFactor
    local offsetY = 0

    if vFactor > 0.001 then
        local char = part.Parent
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local isGrounded = false
        if hum then
            local floorMat = hum.FloorMaterial
            if floorMat and floorMat ~= Enum.Material.Air then
                isGrounded = true
            end
        end

        if not isGrounded and math.abs(vel.Y) > 1 then
            local grav = 196.2
            pcall(function()
                if Workspace.Gravity and Workspace.Gravity > 0 then
                    grav = Workspace.Gravity
                end
            end)
            local ballistic = (vel.Y * vFactor) - (0.5 * grav * (vFactor * vFactor))
            offsetY = math.clamp(ballistic, -15, 15)
        end
    end

    return rawPos + Vector3.new(offsetX, offsetY, offsetZ)
end

local function getSilentAimPred()
    local predH = 0.2
    local predV = 0.2
    if silentAimConfig then
        if silentAimConfig.horizontalPrediction ~= nil then
            predH = tonumber(silentAimConfig.horizontalPrediction) or 0
        elseif silentAimConfig.predictionFactor ~= nil then
            predH = tonumber(silentAimConfig.predictionFactor) or 0
        end
        if silentAimConfig.verticalPrediction ~= nil then
            predV = tonumber(silentAimConfig.verticalPrediction) or 0
        else
            predV = 0
        end
    end
    return predH, predV
end

local function getCamlockPred()
    local predH = 0.2
    local predV = 0.2
    if camlockSettings then
        if camlockSettings.horizontalPrediction ~= nil then
            predH = tonumber(camlockSettings.horizontalPrediction) or 0
        elseif camlockSettings.predictionFactor ~= nil then
            predH = tonumber(camlockSettings.predictionFactor) or 0
        end
        if camlockSettings.verticalPrediction ~= nil then
            predV = tonumber(camlockSettings.verticalPrediction) or 0
        else
            predV = 0
        end
    end
    return predH, predV
end

local function getSilentAimTarget()
    if not silentAimConfig.enabled or (state and state.unloaded) then return nil, nil, nil end
    local shortestDist = silentAimConfig.fovRadius or 125
    local targetPlayer = nil
    local targetPart = nil
    local targetPos = nil
    local mouseLoc = UserInputService:GetMouseLocation()

    local murderer = state and state.knifeHolder or getMurd()
    local sheriff  = state and state.gunHolder or getSheriff()
    local hasGun   = hasTool(LocalPlayer, "Gun")
    local hasKnife = hasTool(LocalPlayer, "Knife")

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not silentAimConfig.aliveCheck or isPlayerAlive(p)) then
            local isValidTarget = false
            if hasGun then
                isValidTarget = (p == murderer or (not murderer and p ~= LocalPlayer))
            elseif hasKnife then
                isValidTarget = true
            else
                isValidTarget = (p == murderer or p == sheriff or true)
            end

            if isValidTarget and p.Character then
                local char = p.Character
                local part = nil
                if silentAimConfig.wallbang then
                    part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
                elseif silentAimConfig.targetPart == "Random" then
                    local partsList = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"}
                    local available = {}
                    for _, pName in ipairs(partsList) do
                        local pt = char:FindFirstChild(pName)
                        if pt and pt:IsA("BasePart") then
                            table.insert(available, pt)
                        end
                    end
                    if #available > 0 then
                        part = available[math.random(1, #available)]
                    end
                elseif silentAimConfig.targetPart and silentAimConfig.targetPart ~= "" then
                    part = char:FindFirstChild(silentAimConfig.targetPart)
                end

                if not part then
                    part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                end

                if part and (silentAimConfig.wallbang or not silentAimConfig.wallCheck or isPartVisible(part, char)) then
                    local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                        if dist <= shortestDist then
                            local rawPos = part.Position
                            local predH, predV = getSilentAimPred()
                            local predicted = calculateAimPosition(rawPos, part, predH, predV)

                            shortestDist = dist
                            targetPlayer = p
                            targetPart = part
                            targetPos = predicted
                        end
                    end
                end
            end
        end
    end
    return targetPlayer, targetPart, targetPos
end

local function getOwnGunHandle()
    local charModel = Workspace:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character
    if charModel then
        local gun = charModel:FindFirstChild("Gun") or charModel:FindFirstChild("Revolver")
        if gun then
            local handle = gun:FindFirstChild("Handle")
            if handle then return handle end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and isGunTool(item) then
                local h = item:FindFirstChild("Handle")
                if h then return h end
            end
        end
    end
    return nil
end

trackConnection(RunService.RenderStepped:Connect(function()
    if silentAimConfig.enabled then
        pcall(updateFOVCircle)
    else
        if fovCircleDrawing and fovCircleDrawing.Visible then pcall(function() fovCircleDrawing.Visible = false end) end
        if fovCircleGuiFrame and fovCircleGuiFrame.Visible then fovCircleGuiFrame.Visible = false end
    end
end))

-- redirect gun fire remotes directly to target
local rawNamecall = nil
if hookmetamethod then
    rawNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "FireServer" or method == "fireServer") then
            local sName = self and self.Name
            -- preserve standard gameplay actions for non-gun tools
            if sName == "Shoot" and not (state and state.unloaded) then
                -- snap aim to target without fov limits
                if state and state.autoAimEnabled then
                    local target, tPart = getAutoAimTarget()
                    if target and isPlayerAlive(target) and tPart then
                        local args = { ... }
                        local targetChar = target.Character
                        local isWallbang = (state and state.autoAimWallbang) or (silentAimConfig and silentAimConfig.wallbang)

                        local shootPart = tPart
                        if isWallbang and targetChar then
                            shootPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("LowerTorso") or tPart
                        end

                        local rawPos = shootPart.Position
                        local predH, predV = getSilentAimPred()
                        local targetPos = calculateAimPosition(rawPos, shootPart, predH, predV)

                        local originPos = nil
                        if isWallbang and targetChar then
                            local head = targetChar:FindFirstChild("Head")
                            originPos = head and head.Position or (rawPos + Vector3.new(0, 1.5, 0))
                        else
                            local originCF = args[1]
                            local handle = getOwnGunHandle()
                            local char = LocalPlayer.Character
                            local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                            originPos = (typeof(originCF) == "CFrame" and originCF.Position)
                                or (handle and (handle.CFrame * CFrame.new(0, 0.5, -1)).Position)
                                or (myHrp and myHrp.Position)
                                or targetPos
                        end

                        args[1] = CFrame.new(originPos, targetPos)
                        args[2] = CFrame.new(targetPos)

                        return rawNamecall(self, unpack(args))
                    end
                -- constrain trajectory assist to fov radius
                elseif silentAimConfig and silentAimConfig.enabled then
                    local target, tPart, targetPos = getSilentAimTarget()
                    if target and isPlayerAlive(target) and targetPos then
                        local hitChance = silentAimConfig.hitChance or 100
                        if hitChance >= 100 or math.random(1, 100) <= hitChance then
                            local args = { ... }
                            local originPos = nil
                            local isWallbang = silentAimConfig.wallbang
                            local targetChar = target.Character
                            if isWallbang and targetChar then
                                local head = targetChar:FindFirstChild("Head")
                                originPos = head and head.Position or (targetPos + Vector3.new(0, 1.5, 0))
                            else
                                local originCF = args[1]
                                local handle = getOwnGunHandle()
                                local char = LocalPlayer.Character
                                local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                                originPos = (typeof(originCF) == "CFrame" and originCF.Position)
                                    or (handle and (handle.CFrame * CFrame.new(0, 0.5, -1)).Position)
                                    or (myHrp and myHrp.Position)
                                    or targetPos
                            end

                            args[1] = CFrame.new(originPos, targetPos)
                            args[2] = CFrame.new(targetPos)

                            return rawNamecall(self, unpack(args))
                        end
                    end
                end
            end
        end
        return rawNamecall(self, ...)
    end))
end

-- lock camera orient toward target head

local function getCamlockTarget()
    local shortest = math.huge
    local result = nil
    local mouseLoc = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isPlayerAlive(p) then
            local char = p.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                local part = char:FindFirstChild(camlockSettings.bodyPartSelected) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, onScreen = CurrentCamera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(sp.X, sp.Y) - mouseLoc).Magnitude
                        if dist < shortest then
                            shortest = dist
                            result = p
                        end
                    end
                end
            end
        end
    end
    return result
end

local function updateCamlock()
    if not camlockSettings.aimLockEnabled then return end
    
    local tp = camlockSettings.targetPlayer
    local char = tp and tp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")

    -- prevent locking onto despawned characters
    if not tp or not isPlayerAlive(tp) or not char or not hum or hum.Health <= 0 then
        camlockSettings.targetPlayer = getCamlockTarget()
        tp = camlockSettings.targetPlayer
        char = tp and tp.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
    end

    if tp and char and hum and hum.Health > 0 then
        local part = char:FindFirstChild(camlockSettings.bodyPartSelected) or char:FindFirstChild("HumanoidRootPart")
        if part then
            local rawPos = part.Position
            local predH, predV = getCamlockPred()
            local predicted = calculateAimPosition(rawPos, part, predH, predV)
            local goalCF    = CFrame.new(CurrentCamera.CFrame.Position, predicted)
            local alpha     = math.clamp(1 - camlockSettings.smoothingFactor, 0.05, 1)
            CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(goalCF, alpha)
        end
    end
end

local function toggleCamlockConnection(enabled)
    if camlockConn then
        pcall(function() camlockConn:Disconnect() end)
        camlockConn = nil
    end
    if enabled and not state.unloaded then
        camlockConn = RunService.RenderStepped:Connect(updateCamlock)
    end
end

-- locate active play area and network endpoints 
local _cachedMap = nil

local function _isMapChild(child)
    if not child or not (child:IsA("Model") or child:IsA("Folder")) then return false end
    local name = child.Name
    if name == "Lobby" or name == "Terrain" or name == "Camera" or name == LocalPlayer.Name or Players:FindFirstChild(name) then
        return false
    end
    if name == "Workplace" or name == "Normal" or name == "Map" or name == "CurrentMap" then
        return true
    end
    if child:FindFirstChild("CoinContainer") or child:FindFirstChild("CoinArea") or child:FindFirstChild("Coins")
        or child:FindFirstChild("Spawns") or child:FindFirstChild("GunDrop")
        or child:FindFirstChild("Knife") or child:FindFirstChild("Gun")
        or child:FindFirstChild("Geometry") or child:FindFirstChild("Interactive") then
        return true
    end
    return false
end

for _, child in ipairs(Workspace:GetChildren()) do
    if _isMapChild(child) then _cachedMap = child break end
end

trackConnection(Workspace.ChildAdded:Connect(function(child)
    if _isMapChild(child) then _cachedMap = child end
end))
trackConnection(Workspace.ChildRemoved:Connect(function(child)
    if _cachedMap == child then _cachedMap = nil end
end))

local function getActiveMap()
    if _cachedMap and _cachedMap.Parent == Workspace then
        return _cachedMap
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if _isMapChild(child) then _cachedMap = child; return child end
    end
    return nil
end

-- mm2 stores knife hit and throw remotes under Knife.Events; update path if game moves them
local function getKnifeEvents()
    local plrModel = Workspace:FindFirstChild(LocalPlayer.Name)
    if plrModel then
        local knife = plrModel:FindFirstChild("Knife")
        if knife and knife:FindFirstChild("Events") then
            return knife.Events
        end
    end
    local map = getActiveMap()
    if map then
        local knife = map:FindFirstChild("Knife")
        if knife then
            local ev = knife:FindFirstChild("Events")
            if ev then return ev end
        end
    end
    return nil
end

-- mm2 gun tools fire bullet raycasts via Shoot remote event; update if game renames gun remotes
local function getGunShootEvent()
    -- search character first for equipped items
    local char = LocalPlayer.Character or Workspace:FindFirstChild(LocalPlayer.Name)
    if char then
        local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")
        if gun and gun:FindFirstChild("Shoot") then
            return gun.Shoot
        end
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and isGunTool(item) then
                local shoot = item:FindFirstChild("Shoot")
                if shoot and shoot:IsA("RemoteEvent") then return shoot end
            end
        end
    end
    -- inspect unequipped items in inventory
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local gun = bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")
        if gun and gun:FindFirstChild("Shoot") then
            return gun.Shoot
        end
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and isGunTool(item) then
                local shoot = item:FindFirstChild("Shoot")
                if shoot and shoot:IsA("RemoteEvent") then return shoot end
            end
        end
    end
    -- search active map geometry for dropped tools
    local map = getActiveMap()
    if map then
        local gun = map:FindFirstChild("Gun") or map:FindFirstChild("Revolver")
        if gun then
            local shoot = gun:FindFirstChild("Shoot")
            if shoot and shoot:IsA("RemoteEvent") then return shoot end
        end
    end
    -- retrieve orphaned instances outside workspace
    if getnilinstances then
        local success, result = pcall(function()
            for _, obj in ipairs(getnilinstances()) do
                if obj:IsA("RemoteEvent") and obj.Name == "Shoot" then
                    return obj
                end
            end
            return nil
        end)
        if success and result then return result end
    end
    return nil
end

local function getDroppedGunPart()
    local function extractPart(obj)
        if not obj then return nil end
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Model") then
            if obj.PrimaryPart then return obj.PrimaryPart end
            return obj:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end
    local map = getActiveMap()
    if map then
        local drop = map:FindFirstChild("GunDrop")
        if drop then
            local p = extractPart(drop)
            if p then return p end
        end
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name ~= "Lobby" then
            local drop = child:FindFirstChild("GunDrop")
            if drop then
                local p = extractPart(drop)
                if p then return p end
            end
        end
    end
    return nil
end

local function getDroppedGun()
    local map = getActiveMap()
    if map then
        local drop = map:FindFirstChild("GunDrop")
        if drop then return drop end
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name ~= "Lobby" then
            local drop = child:FindFirstChild("GunDrop")
            if drop then return drop end
        end
    end
    return nil
end

local function isInLobby()
    local ok, roundUI = pcall(function()
        return isRoundActiveUI and isRoundActiveUI()
    end)
    if ok and roundUI then return false end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    local lobby = Workspace:FindFirstChild("Lobby")
    local lobbySpawns = lobby and lobby:FindFirstChild("Spawns")
    if lobbySpawns then
        for _, s in ipairs(lobbySpawns:GetChildren()) do
            if s:IsA("BasePart") then
                local dist = (hrp.Position - s.Position).Magnitude
                if dist < 150 then
                    return true
                end
            end
        end
    end
    return false
end

local function isMurdererAlive(plr)
    if not plr or not isPlayerAlive(plr) then return false end
    if state.deadPlayers[plr] == true then return false end
    return hasTool(plr, "Knife")
end

-- deliver match statistics to remote endpoint 
local function parseInterval(str)
    if not str or str == "" then return 300 end
    local num, unit = str:match("(%d+)%s*([smh]?)")
    if not num then return 300 end
    local n = tonumber(num)
    if unit == "s" then return n end
    if unit == "h" then return n * 3600 end
    return n * 60
end

local function getCurrentCoinsText()
    local ok, val = pcall(function()
        return LocalPlayer.PlayerGui.CrossPlatform.Shop.Medium.Title.Coins.Container.Amount.Text
    end)
    if ok and val then return tostring(val) end
    return "0"
end

local function getCoinsPerHourNum()
    local elapsedHrs = (tick() - state.startTime) / 3600
    if elapsedHrs <= 0 then return 0 end
    local farmed = state.totalCoinsFarmed or 0
    return math.floor(farmed / elapsedHrs)
end

local function sendDiscordWebhook(isTest)
    if not state.webhookUrl or state.webhookUrl == "" then return end
    if not isTest and not state.webhookEnabled then return end
    
    local elapsedSec = math.floor(tick() - state.startTime)
    local hrs = math.floor(elapsedSec / 3600)
    local mins = math.floor((elapsedSec % 3600) / 60)
    local secs = elapsedSec % 60
    local timeStr = string.format("%02d:%02d:%02d", hrs, mins, secs)
    
    local lines = {
        "```yaml",
        isTest and "MM2 MD Status (Test)" or "MM2 MD Status",
        "",
        string.format("Username     : %s", LocalPlayer.Name),
        string.format("Time passed  : %s", timeStr),
        string.format("Rounds passed: %d", state.roundsPassed),
        string.format("Status       : %s", isTest and "Test notification" or (state.currentTaskStatus or "Idle"))
    }

    if state.webhookCurrentCoins then
        table.insert(lines, string.format("Current coins: %s", getCurrentCoinsText()))
    end
    if state.webhookCoinsPerHour then
        table.insert(lines, string.format("Coins / hour : %d", getCoinsPerHourNum()))
    end

    table.insert(lines, "```")
    local reportText = table.concat(lines, "\n")
    
    local payload = HttpService:JSONEncode({
        content = reportText,
        username = "MorningDrift Jr."
    })
    
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        pcall(function()
            req({
                Url = state.webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
    else
        pcall(function()
            HttpService:PostAsync(state.webhookUrl, payload, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

-- fetch public servers list and teleport to another instance
local function serverHop()
    log("Server hopping...")
    local placeId = game.PlaceId
    local servers = {}
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"
    
    if req then
        local res = req({Url = url, Method = "GET"})
        if res and res.Body then
            local data = HttpService:JSONDecode(res.Body)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        table.insert(servers, s.id)
                    end
                end
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
    else
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

-- hover and pass through collision geometry 
local function setNoclip(enabled)
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
    if enabled then
        if not (state.autofarmEnabled or state.flightEnabled or state.isFlinging or state.autoTakeGun) then
            return
        end
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "OrbitingOrb" then
                            p.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            restoreCharacterCollision(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end
    end
end

local function startFloating()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    if hrp then
        local bv = hrp:FindFirstChild("SafePlate")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name     = "SafePlate"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent   = hrp
        end
    end
    setNoclip(true)
end

-- catch character above kill plane to prevent deaths 
local function getVoidY()
    -- roblox destroys parts below FallenPartsDestroyHeight; defaults to -500 if unset
    local fallenY = Workspace.FallenPartsDestroyHeight
    if not fallenY or fallenY > -50 then
        fallenY = -500
    end
    return fallenY
end

local function getAntiVoidPlateY()
    -- keep platform 150 studs above void limit (minimum -250) to catch flings early
    return math.max(getVoidY() + 150, -250)
end

local function getMinAllowedY()
    return getAntiVoidPlateY() + 50
end

local function makeAntiVoidPlate()
    local plate = Workspace:FindFirstChild("AntiVoidPlate")
    if not plate then
        plate = Instance.new("Part")
        plate.Name = "AntiVoidPlate"
        -- 100k studs wide to cover entire map boundary during extreme physics flings
        plate.Size = Vector3.new(100000, 100, 100000)
        plate.Anchored = true
        plate.CanCollide = true
        plate.Transparency = 0.6
        plate.Color = Color3.fromRGB(0, 170, 255)
        plate.Material = Enum.Material.ForceField
        plate.Parent = Workspace
    end

    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local posX = hrp and hrp.Position.X or 0
    local posZ = hrp and hrp.Position.Z or 0

    plate.Position = Vector3.new(posX, getAntiVoidPlateY(), posZ)
    return plate
end

trackThread(task.spawn(function()
    while not state.unloaded do
        if state.autofarmEnabled or state.flightEnabled or state.isFlinging then
            pcall(function()
                local plate = Workspace:FindFirstChild("AntiVoidPlate")
                if not plate then plate = makeAntiVoidPlate() end
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and plate then
                    plate.Position = Vector3.new(hrp.Position.X, getAntiVoidPlateY(), hrp.Position.Z)
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.5)
        end
    end
end))

-- reset forces and recover character physics 
local function stopTween()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj.Name == "SafePlate"
                or obj:IsA("BodyVelocity") or obj:IsA("BodyPosition")
                or obj.Name == "FarmOrientation" then
                pcall(function() obj:Destroy() end)
            end
        end
        pcall(function()
            hrp.Anchored = false
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    setNoclip(false)
end

local SAFEZONE_POS = Vector3.new(390.562195, -41.5624847, 110.499878)

local function tpToSafeSpawn(anchor)
    if state then
        state.tweenRoundTeleported = false
    end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(SAFEZONE_POS)
    pcall(function()
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    if anchor ~= false then
        pcall(function() hrp.Anchored = true end)
    else
        pcall(function() hrp.Anchored = false end)
    end
end

-- push target away with extreme momentum 
local lastFlingTick = tick()
local function flingTarget(targetPlr, isManual, customDuration)
    if (tick() - state.startTime) < 2.0 then
        log("Fling blocked: script initializing")
        return
    end
    if not isManual and (tick() - lastFlingTick < 6) then return end
    if not targetPlr or not isPlayerAlive(targetPlr) then return end
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetChar = targetPlr.Character
    local targetHrp  = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end

    makeAntiVoidPlate()
    local minAllowedY = getMinAllowedY()

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    
    state.isFlinging = true
    pcall(function() hrp.Anchored = false end)
    setNoclip(true)

    local camera = Workspace.CurrentCamera
    local originalSubject = camera and camera.CameraSubject
    local startTime = tick()
    local flingMaxDuration = customDuration or 4.0

    pcall(function()
        while (isManual or state.autofarmEnabled) and isPlayerAlive(targetPlr) and isPlayerAlive(LocalPlayer)
              and (tick() - startTime < flingMaxDuration) and not state.unloaded do

            targetChar = targetPlr.Character
            targetHrp  = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHrp then break end

            pcall(function()
                if camera then
                    local tHum = targetChar:FindFirstChildOfClass("Humanoid")
                    if tHum and camera.CameraSubject ~= tHum then
                        camera.CameraSubject = tHum
                    end
                end
            end)

            pcall(function()
                local plate = Workspace:FindFirstChild("AntiVoidPlate")
                if plate then
                    plate.Position = Vector3.new(hrp.Position.X, getAntiVoidPlateY(), hrp.Position.Z)
                end
            end)

            local targetPos = targetHrp.Position
            if targetPos.Y < minAllowedY then
                targetPos = Vector3.new(targetPos.X, minAllowedY, targetPos.Z)
            end

            local t = tick()
            local targetLook = targetHrp.CFrame.LookVector
            local baseOffset = state.flingForwardOffset or 3.0
            local fwdOffset  = math.sin(t * 30) * baseOffset
            local upOffset   = math.cos(t * 25) * 0.8

            local flingPos = targetPos + (targetLook * fwdOffset) + Vector3.new(0, upOffset, 0)

            pcall(function()
                hrp.Anchored = false
                hrp.CFrame = CFrame.new(flingPos) * CFrame.Angles(math.rad(90), 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(10000000, 10000000, 10000000)
                local dirToTarget = (targetPos - hrp.Position).Unit
                hrp.AssemblyLinearVelocity = (dirToTarget * 4000) + Vector3.new(0, math.sin(t * 40) * 2000, 0)
            end)

            RunService.Heartbeat:Wait()
        end
    end)

    state.isFlinging = false
    lastFlingTick = tick()

    pcall(function()
        local myChar = LocalPlayer.Character
        local myHrp  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")

        if myHrp then
            myHrp.CFrame = CFrame.new(myHrp.Position)
            myHrp.AssemblyLinearVelocity  = Vector3.zero
            myHrp.AssemblyAngularVelocity = Vector3.zero
        end

        stopAllMovement()

        if myHum then
            myHum.PlatformStand = false
            myHum.Sit = false
            myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        RunService.Heartbeat:Wait()
        if myHum then
            myHum:ChangeState(Enum.HumanoidStateType.Running)
        end
        if myHrp then
            myHrp.AssemblyLinearVelocity  = Vector3.zero
            myHrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    pcall(function()
        local camera = Workspace.CurrentCamera
        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if camera then
            camera.CameraSubject = myHum or originalSubject
        end
    end)

    if state.autofarmEnabled then
        tpToSafeSpawn(true)
    end
end

-- resolve player name from partial input 
local function findPlayer(queryStr)
    if not queryStr or type(queryStr) ~= "string" or queryStr:gsub("%s+", "") == "" then
        return nil, "enter username"
    end

    local cleanQuery = queryStr:lower():gsub("%s+", "")
    local exactMatches = {}
    local prefixMatches = {}
    local containsMatches = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pName = plr.Name:lower()
            local pDisp = plr.DisplayName:lower()

            if pName == cleanQuery or pDisp == cleanQuery then
                table.insert(exactMatches, plr)
            elseif pName:sub(1, #cleanQuery) == cleanQuery or pDisp:sub(1, #cleanQuery) == cleanQuery then
                table.insert(prefixMatches, plr)
            elseif pName:find(cleanQuery, 1, true) or pDisp:find(cleanQuery, 1, true) then
                table.insert(containsMatches, plr)
            end
        end
    end

    local candidateList = #exactMatches > 0 and exactMatches or (#prefixMatches > 0 and prefixMatches or containsMatches)

    if #candidateList == 1 then
        return candidateList[1], nil
    elseif #candidateList > 1 then
        local names = {}
        for _, p in ipairs(candidateList) do
            table.insert(names, p.Name)
        end
        return nil, "Ambiguous: " .. #candidateList .. " players found (" .. table.concat(names, ", ") .. ")"
    else
        return nil, "no player matching '" .. queryStr .. "'"
    end
end

-- mm2 hud displays MainGUI.Game.CoinBags only while a round is active; update if game renames hud frame
function isCoinBagVisible()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return false end
        local gameFrame = gui:FindFirstChild("Game")
        if not gameFrame then return false end
        local coinBags = gameFrame:FindFirstChild("CoinBags")
        if not coinBags or not coinBags.Visible then return false end

        local container = coinBags:FindFirstChild("Container")
        if container and container.Visible then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then return true end
            end
        end
        local coin = coinBags:FindFirstChild("Coin")
        if coin and coin:IsA("GuiObject") and coin.Visible then return true end
        for _, child in ipairs(coinBags:GetChildren()) do
            if child.Name ~= "Container" and child:IsA("GuiObject") and child.Visible then return true end
        end
        return false
    end)
    return ok and res == true
end

-- dispatch attack action to eliminate target 
local function killTarget()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local role = getPlayerRole(LocalPlayer)

    if role == "Murderer" then
        local knifeTool = getPlayerTool(LocalPlayer, "Knife")
        if knifeTool then
            hum:EquipTool(knifeTool)
            task.wait(0.1)
            local events = getKnifeEvents()
            if events then
                pcall(function() events.KnifeStabbed:FireServer() end)
                task.wait(0.02)
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and isPlayerAlive(target) then
                        local tChar = target.Character
                        local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                        if tChar and tHrp then
                            local handle = nil
                            for _, acc in ipairs(tChar:GetChildren()) do
                                if acc:IsA("Accessory") then
                                    local h = acc:FindFirstChild("Handle")
                                    if h then handle = h; break end
                                end
                            end
                            handle = handle or tHrp

                            pcall(function() events.HandleTouched:FireServer(handle) end)
                            local tKnifeLook = tHrp.CFrame.LookVector
                            local tKnifeStart = Vector3.new(tHrp.Position.X - tKnifeLook.X * 0.1, tHrp.Position.Y, tHrp.Position.Z - tKnifeLook.Z * 0.1)
                            pcall(function() events.KnifeThrown:FireServer(CFrame.new(tKnifeStart, tHrp.Position), CFrame.new(tHrp.Position)) end)
                            task.wait(0.02)
                        end
                    end
                end
            end
        end

    elseif role == "Sheriff" or hasTool(LocalPlayer, "Gun") then
        local gunTool = getPlayerTool(LocalPlayer, "Gun")
        local murderer = state.knifeHolder
        if murderer and not hasTool(murderer, "Knife") then murderer = nil end
        if gunTool and murderer and isPlayerAlive(murderer) then
            hum:EquipTool(gunTool)
            task.wait(0.1)
            local shootEvent = getGunShootEvent()
            local mChar = murderer.Character
            local mHead = mChar and mChar:FindFirstChild("Head")
            local mTorso = mChar and (mChar:FindFirstChild("UpperTorso") or mChar:FindFirstChild("Torso") or mChar:FindFirstChild("LowerTorso") or mChar:FindFirstChild("HumanoidRootPart"))
            if shootEvent and mTorso then
                local rawPos = mTorso.Position
                local predH, predV = getSilentAimPred()
                local targetPos = calculateAimPosition(rawPos, mTorso, predH, predV)
                local startPos = mHead and mHead.Position or (rawPos + Vector3.new(0, 1.5, 0))
                local startCF  = CFrame.new(startPos, targetPos)
                local targetCF = CFrame.new(targetPos)
                pcall(function()
                    shootEvent:FireServer(startCF, targetCF)
                end)
            end
        end

    else
        local gunShot = false
        if state.autoTakeGun and isCoinBagVisible() and isPlayerAlive(LocalPlayer) then
            local droppedGun = getDroppedGun()
            if droppedGun then
                local returnCFrame = hrp.CFrame
                hrp.CFrame = droppedGun.CFrame
                task.wait(0.2)
                local gunTool = getPlayerTool(LocalPlayer, "Gun")
                local murderer = state.knifeHolder
                if gunTool and murderer and isPlayerAlive(murderer) then
                    hum:EquipTool(gunTool)
                    task.wait(0.1)
                    local shootEvent = getGunShootEvent()
                    local mChar = murderer.Character
                    local mHead = mChar and mChar:FindFirstChild("Head")
                    local mTorso = mChar and (mChar:FindFirstChild("UpperTorso") or mChar:FindFirstChild("Torso") or mChar:FindFirstChild("LowerTorso") or mChar:FindFirstChild("HumanoidRootPart"))
                    if shootEvent and mTorso then
                        local rawPos = mTorso.Position
                        local predH, predV = getSilentAimPred()
                        local targetPos = calculateAimPosition(rawPos, mTorso, predH, predV)
                        local startPos = mHead and mHead.Position or (rawPos + Vector3.new(0, 1.5, 0))
                        local startCF  = CFrame.new(startPos, targetPos)
                        local targetCF = CFrame.new(targetPos)
                        pcall(function()
                            shootEvent:FireServer(startCF, targetCF)
                        end)
                        gunShot = true
                    end
                end
                task.wait(0.02)
                pcall(function() hrp.CFrame = returnCFrame end)
            end
        end

        if not gunShot and state.knifeHolder and isPlayerAlive(state.knifeHolder) and state.knifeHolder ~= LocalPlayer then
            flingTarget(state.knifeHolder)
        end
    end
end


-- detect coin cap and round state from player gui 

local function getMapModel()
    local m = getActiveMap and getActiveMap()
    if m and m.Parent == Workspace then return m end
    for _, child in ipairs(Workspace:GetChildren()) do
        if _isMapChild and _isMapChild(child) then return child end
    end
    return nil
end

local function getCoinTouchInterest(part)
    if not part or not part.Parent then return nil end
    local ti = part:FindFirstChild("TouchInterest")
        or part:FindFirstChildOfClass("TouchTransmitter")
        or part:FindFirstChildWhichIsA("TouchTransmitter")
    if ti and ti.Parent then return ti end
    if part.Parent and part.Parent ~= Workspace then
        ti = part.Parent:FindFirstChild("TouchInterest")
            or part.Parent:FindFirstChildOfClass("TouchTransmitter")
            or part.Parent:FindFirstChildWhichIsA("TouchTransmitter")
        if ti and ti.Parent then return ti end
    end
    return nil
end

local lastFallbackCoinScan = 0

local function scanAllCoins()
    local coins = {}
    local seen  = {}

    local function tryAdd(item, part)
        -- locate physics collider holding pickup trigger
        if not part or not part:IsA("BasePart") then return end
        if seen[part] then return end
        if not part.Parent then return end

        -- ignore coins picked up by other players
        if item then
            local visual = item:FindFirstChild("CoinVisual")
            if visual and visual:IsA("BasePart") and visual.Transparency >= 1 then return end
        end
        if part.Transparency >= 1 then return end

        local ti = getCoinTouchInterest(part)
        if not ti then return end  -- ignore static decoration coins

        seen[part] = true
        table.insert(coins, {
            Part          = part,
            TouchInterest = ti,
            Position      = part.Position,
        })
    end

    -- pull coin folder from active map first
    local map = getMapModel()
    if map then
        local cc = map:FindFirstChild("CoinContainer")
              or map:FindFirstChild("Coins")
              or map:FindFirstChild("CoinArea")
        if cc then
            for _, item in ipairs(cc:GetChildren()) do
                local cs = item:FindFirstChild("Coin_Server")
                if cs and cs:IsA("BasePart") then
                    tryAdd(item, cs)
                elseif item:IsA("BasePart") then
                    tryAdd(nil, item)
                else
                    tryAdd(item, item:FindFirstChildWhichIsA("BasePart", true))
                end
            end
        end
    end

    -- fall back to common map container names
    for _, parentName in ipairs({"Workplace", "Normal", "Map", "CurrentMap"}) do
        local p = Workspace:FindFirstChild(parentName)
        if p and p ~= map then
            local cc = p:FindFirstChild("CoinContainer") or p:FindFirstChild("Coins") or p:FindFirstChild("CoinArea")
            if cc then
                for _, item in ipairs(cc:GetChildren()) do
                    local cs = item:FindFirstChild("Coin_Server")
                    if cs and cs:IsA("BasePart") then
                        tryAdd(item, cs)
                    elseif item:IsA("BasePart") then
                        tryAdd(nil, item)
                    else
                        tryAdd(item, item:FindFirstChildWhichIsA("BasePart", true))
                    end
                end
            end
        end
    end

    -- scan workspace if map hierarchy differs
    local now = tick()
    if #coins == 0 and (now - lastFallbackCoinScan >= 5) then
        lastFallbackCoinScan = now
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name == "Coin_Server" then
                tryAdd(desc.Parent, desc)
            end
        end
    end

    return coins
end

local function getBagIconState()
    local ok, active, full = pcall(function()
        if not isCoinBagVisible() then return false, false end
        local gui      = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        local game_    = gui and gui:FindFirstChild("Game")
        local coinBags = game_ and game_:FindFirstChild("CoinBags")
        if not coinBags then return true, false end

        -- check both fullbagicon visibility and parsed cur/max text because mm2 variations represent capacity differently across updates
        local function checkFull(obj)
            if not obj then return false end
            local fi = obj:FindFirstChild("FullBagIcon")
            if fi and fi.Visible then return true end
            local lbl = obj:FindFirstChild("Amount") or obj:FindFirstChild("CoinCount")
                     or obj:FindFirstChildWhichIsA("TextLabel", true)
            if lbl and lbl:IsA("TextLabel") then
                local cur, max_ = lbl.Text:match("(%d+)%s*/%s*(%d+)")
                if cur and max_ and tonumber(max_) > 0 and tonumber(cur) >= tonumber(max_) then
                    return true
                end
            end
            return false
        end

        local container = coinBags:FindFirstChild("Container")
        if container then
            for _, c in ipairs(container:GetChildren()) do
                if c:IsA("GuiObject") and c.Visible and checkFull(c) then return true, true end
            end
        end
        for _, c in ipairs(coinBags:GetChildren()) do
            if c.Name ~= "Container" and c:IsA("GuiObject") and c.Visible and checkFull(c) then return true, true end
        end
        return true, false
    end)
    if not ok then return false, false end
    return active == true, full == true
end

local function isBagFull()
    local _, full = getBagIconState()
    return full
end

local function isRoundActiveUI()
    return isPlayerAlive(LocalPlayer) and isCoinBagVisible()
end

local function isIntermission()
    return not isCoinBagVisible()
end

local function canFarmCoins()
    if not state or state.unloaded or not state.autofarmEnabled then return false end
    if not isPlayerAlive(LocalPlayer)  then return false end
    if not isCoinBagVisible()          then return false end
    if isBagFull()                     then return false end
    return true
end

-- verify match status before dispatching actions 
local cachedKnifeHolder = nil
local cachedGunHolder   = nil

local function endRound()
    if not state.roundActive then return end
    state.roundActive  = false
    state.tweenRoundTeleported = false
    state.knifeHolder  = nil
    state.gunHolder    = nil
    cachedKnifeHolder  = nil
    cachedGunHolder    = nil
    state.roundsPassed = state.roundsPassed + 1
    state.noRoundStartTime = tick()
    if state.deadPlayers then
        table.clear(state.deadPlayers)
    end
    if state.webhookEnabled and tick() - state.lastWebhookSent >= state.webhookIntervalSec then
        state.lastWebhookSent = tick()
        task.spawn(sendDiscordWebhook)
    end
end

local function hookCharacterDeath(plr, char)
    local hum = char:FindFirstChildOfClass("Humanoid")
        or char:WaitForChild("Humanoid", 3)
    if not hum then return end
    trackPlayerConnection(plr, hum.Died:Connect(function()
        state.deadPlayers[plr] = true
        if plr == state.knifeHolder or plr == cachedKnifeHolder then
            task.delay(0.5, function()
                if not state.unloaded and not hasTool(plr, "Knife") and not isRoundActiveUI() then
                    endRound()
                end
            end)
        end
        if plr == LocalPlayer then
            if state.flightEnabled then
                state.flightEnabled = false
                if flyConn then pcall(function() flyConn:Disconnect() end); flyConn = nil end
                stopAllMovement()
                pcall(function() if Options.FlightEnabled then Options.FlightEnabled:SetValue(false) end end)
            else
                setNoclip(false)
            end
        end
    end))
end

local function hookPlayer(plr)
    if not plr then return end
    clearPlayerConnections(plr)
    if plr.Character then
        hookCharacterDeath(plr, plr.Character)
    end
    if playerCharConnections[plr] then
        pcall(function() playerCharConnections[plr]:Disconnect() end)
    end
    playerCharConnections[plr] = plr.CharacterAdded:Connect(function(char)
        clearPlayerConnections(plr)
        task.wait(0.1)
        hookCharacterDeath(plr, char)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    hookPlayer(plr)
end

trackConnection(Players.PlayerAdded:Connect(function(plr)
    hookPlayer(plr)
end))

trackConnection(Players.PlayerRemoving:Connect(function(plr)
    clearPlayerConnections(plr)
    if playerCharConnections[plr] then
        pcall(function() playerCharConnections[plr]:Disconnect() end)
        playerCharConnections[plr] = nil
    end
    if state and state.deadPlayers then
        state.deadPlayers[plr] = nil
    end
end))

trackThread(task.spawn(function()
    local knifeMissingStartTime = 0

    while not state.unloaded do
        local newKnifeHolder = nil
        local newGunHolder   = nil

        for _, plr in ipairs(Players:GetPlayers()) do
            if isPlayerAlive(plr) then
                if hasTool(plr, "Knife") then
                    newKnifeHolder = plr
                end
                if hasTool(plr, "Gun") then
                    newGunHolder = plr
                end
            end
        end

        if not newKnifeHolder then
            local rsMurderer = getMurd()
            if rsMurderer and isPlayerAlive(rsMurderer) then
                newKnifeHolder = rsMurderer
            end
        end
        if not newGunHolder then
            local rsSheriff = getSheriff()
            if rsSheriff and isPlayerAlive(rsSheriff) then
                newGunHolder = rsSheriff
            end
        end

        local knifeInGame = (newKnifeHolder ~= nil)

        if (knifeInGame or isRoundActiveUI()) and not state.roundActive then
            state.roundActive          = true
            state.roundStartTime       = tick()
            state.noRoundStartTime     = tick()
            state.knifeHolder          = newKnifeHolder
            state.gunHolder            = newGunHolder
            cachedKnifeHolder          = newKnifeHolder
            cachedGunHolder            = newGunHolder
            knifeMissingStartTime      = 0
            state.tweenRoundTeleported = false
            table.clear(state.deadPlayers)

        elseif state.roundActive then
            if newKnifeHolder then
                state.knifeHolder = newKnifeHolder
                cachedKnifeHolder = newKnifeHolder
            end
            if newGunHolder then
                state.gunHolder = newGunHolder
                cachedGunHolder = newGunHolder
            end

            state.noRoundStartTime = tick()

            if not knifeInGame and isIntermission() then
                if knifeMissingStartTime == 0 then
                    knifeMissingStartTime = tick()
                end
                if tick() - knifeMissingStartTime >= 2.0 then
                    endRound()
                    knifeMissingStartTime = 0
                end
            elseif knifeInGame or isRoundActiveUI() then
                knifeMissingStartTime = 0
            end

        else
            state.knifeHolder = newKnifeHolder
            state.gunHolder   = newGunHolder
            knifeMissingStartTime = 0

            if state.autofarmEnabled and tick() - state.noRoundStartTime > 240 then
                serverHop()
            end
        end

        task.wait(0.1)
    end
end))

-- deliver match statistics to remote endpoint loop 
trackThread(task.spawn(function()
    while not state.unloaded do
        task.wait(10)
        if state.webhookEnabled and tick() - state.lastWebhookSent >= state.webhookIntervalSec then
            state.lastWebhookSent = tick()
            task.spawn(sendDiscordWebhook)
        end
    end
end))

-- project procedural circular rings under character
local auraLayers = {}
local particleAnchorPart = nil
local auraSurfaceGui = nil
-- snap visual plane to floor surface under feet
local function getGroundCFrame(character, rootPart)
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -8, 0)

    local raycastParams = RaycastParams.new()
    local ignoreList = { character }
    for _, layer in ipairs(auraLayers) do
        if layer.part then
            table.insert(ignoreList, layer.part)
        end
    end
    if particleAnchorPart then
        table.insert(ignoreList, particleAnchorPart)
    end
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    -- ignore non-solid geometry during floor cast
    for _ = 1, 4 do
        local hit = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if not hit then break end

        if hit.Instance and hit.Instance.CanCollide then
            -- elevate slightly to prevent floor z-fighting
            return CFrame.new(rootPart.Position.X, hit.Position.Y + 0.04, rootPart.Position.Z)
        end

        table.insert(ignoreList, hit.Instance)
        raycastParams.FilterDescendantsInstances = ignoreList
    end

    -- default to hip height when hovering over void
    return CFrame.new(rootPart.Position.X, rootPart.Position.Y - 2.35, rootPart.Position.Z)
end

-- resolve decal asset from preset choice
local function getParticleTextureId()
    local preset = state.killAuraParticlePreset
    local rawId = (preset == "Custom") and state.killAuraParticleCustomId or killAuraParticlePresets[preset]
    local formatted = formatCustomAssetId(rawId)
    if not formatted or formatted == "" then
        return "rbxassetid://112096280571499"
    end
    return formatted
end

-- vary layer spin rates for natural parallax
local function getRandomSpinSpeed()
    local minS = math.min(state.killAuraParticleMinSpin, state.killAuraParticleMaxSpin)
    local maxS = math.max(state.killAuraParticleMinSpin, state.killAuraParticleMaxSpin)
    if minS == maxS then
        return minS
    end
    return minS + math.random() * (maxS - minS)
end

-- refresh rotation speeds across active rings
local function randomizeLayerSpeeds()
    for _, layer in ipairs(auraLayers) do
        layer.spinSpeed = getRandomSpinSpeed()
    end
end

-- update layer positions and color transitions
local function updateAuraVisuals(dt)
    if #auraLayers == 0 then return end

    local color1 = state.killAuraParticleColor
    local color2 = state.killAuraParticleColor2
    local mode = state.killAuraParticleColorMode
    local speed = state and state.colorShiftSpeed or 3
    local phase = (tick() * (speed * 0.15)) % 1.0

    local degreeOffset = state.killAuraDegreeOffset or state.killAuraParticleSpawnDelay or 0
    for idx, layer in ipairs(auraLayers) do
        local img = layer.imageLabel
        local uiGrad = layer.gradient
        local offsetAngle = (idx - 1) * degreeOffset

        -- advance layer angle by individual spin speed
        if dt and dt > 0 and layer.spinSpeed and layer.spinSpeed ~= 0 then
            layer.rotationAngle = ((layer.rotationAngle or 0) + dt * layer.spinSpeed) % 360
        end
        img.Rotation = ((layer.rotationAngle or 0) + offsetAngle) % 360

        if mode == "Gradient" or mode == "Gradient 2" then
            uiGrad.Enabled = true
            uiGrad.Rotation = 0
            local function getSmoothCol(off)
                local tVal = (math.sin((phase - off) * math.pi * 2) + 1) * 0.5
                return color1:Lerp(color2, tVal)
            end
            uiGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    getSmoothCol(0)),
                ColorSequenceKeypoint.new(0.25, getSmoothCol(0.25)),
                ColorSequenceKeypoint.new(0.5,  getSmoothCol(0.5)),
                ColorSequenceKeypoint.new(0.75, getSmoothCol(0.75)),
                ColorSequenceKeypoint.new(1,    getSmoothCol(1))
            })
            img.ImageColor3 = Color3.new(1, 1, 1)
        elseif mode == "Rainbow" or mode == "Rainbow 2" or mode == "Rainbow 1" then
            uiGrad.Enabled = true
            uiGrad.Rotation = 0
            local function getRainbowCol(off)
                return Color3.fromHSV((phase - off) % 1, 1, 1)
            end
            uiGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    getRainbowCol(0)),
                ColorSequenceKeypoint.new(0.17, getRainbowCol(0.17)),
                ColorSequenceKeypoint.new(0.33, getRainbowCol(0.33)),
                ColorSequenceKeypoint.new(0.50, getRainbowCol(0.50)),
                ColorSequenceKeypoint.new(0.67, getRainbowCol(0.67)),
                ColorSequenceKeypoint.new(0.83, getRainbowCol(0.83)),
                ColorSequenceKeypoint.new(1.00, getRainbowCol(1))
            })
            img.ImageColor3 = Color3.new(1, 1, 1)
        elseif mode == "Shift" then
            uiGrad.Enabled = false
            local shiftFactor = (math.sin(tick() * 3) + 1) * 0.5
            img.ImageColor3 = color1:Lerp(color2, shiftFactor)
        else
            uiGrad.Enabled = false
            img.ImageColor3 = color1
        end
    end
end

-- clean up aura visual instances
local function cleanupParticleAura()
    for _, layer in ipairs(auraLayers) do
        if layer.part then
            pcall(function() layer.part:Destroy() end)
        end
    end
    table.clear(auraLayers)
    particleAnchorPart = nil
    auraSurfaceGui = nil
end

-- construct multi-layered circle rings
local function rebuildParticleAura()
    if not state.killAuraParticleEnabled or not isPlayerAlive(LocalPlayer) then
        cleanupParticleAura()
        return
    end

    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        cleanupParticleAura()
        return
    end

    cleanupParticleAura()

    local size = state.killAuraParticleSize
    local groundCFrame = getGroundCFrame(char, hrp)
    local count = math.clamp(state.killAuraParticleCount, 1, 10)
    local textureId = getParticleTextureId()
    local heightDiff = state.killAuraHeightOffset or 0
    local brightness = 1 + (state.killAuraParticleGlow * 2)

    for i = 1, count do
        local layerYOffset = (i - 1) * heightDiff + (i - 1) * 0.001
        local partCFrame = groundCFrame + Vector3.new(0, layerYOffset, 0)

        local part = Instance.new("Part")
        part.Name = "AuraAnchor_" .. i
        part.Transparency = 1
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Anchored = true
        part.Size = Vector3.new(size, 0.05, size)
        part.CFrame = partCFrame
        part.Parent = workspace

        local sg = Instance.new("SurfaceGui")
        sg.Name = "AuraSurfaceGui_" .. i
        sg.Face = Enum.NormalId.Top
        sg.LightInfluence = 0
        sg.AlwaysOnTop = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
        sg.CanvasSize = Vector2.new(1024, 1024)
        sg.Brightness = brightness
        sg.Adornee = part
        sg.Parent = part

        local img = Instance.new("ImageLabel")
        img.Name = "AuraImage_" .. i
        img.Size = UDim2.fromScale(1, 1)
        img.Position = UDim2.fromScale(0.5, 0.5)
        img.AnchorPoint = Vector2.new(0.5, 0.5)
        img.BackgroundTransparency = 1
        img.Image = textureId
        img.ImageTransparency = state.killAuraParticleTransparency
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = i
        img.Parent = sg

        local uiAspect = Instance.new("UIAspectRatioConstraint")
        uiAspect.AspectRatio = 1
        uiAspect.DominantAxis = Enum.DominantAxis.Width
        uiAspect.AspectType = Enum.AspectType.FitWithinMaxSize
        uiAspect.Parent = img

        local uiGrad = Instance.new("UIGradient")
        uiGrad.Name = "AuraGradient"
        uiGrad.Parent = img

        table.insert(auraLayers, {
            part = part,
            surfaceGui = sg,
            imageLabel = img,
            gradient = uiGrad,
            spinSpeed = getRandomSpinSpeed(),
            rotationAngle = 0
        })
    end

    particleAnchorPart = auraLayers[1] and auraLayers[1].part or nil
    auraSurfaceGui = auraLayers[1] and auraLayers[1].surfaceGui or nil

    updateAuraVisuals(0)
end

-- reattach aura when character respawns
trackConnection(LocalPlayer.CharacterAdded:Connect(function(newChar)
    if state.killAuraParticleEnabled then
        task.spawn(function()
            local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
            if hrp and state.killAuraParticleEnabled then
                task.wait(0.2)
                rebuildParticleAura()
            end
        end)
    end
end))

-- track ground position each frame
trackConnection(RunService.RenderStepped:Connect(function(dt)
    if state.killAuraParticleEnabled and isPlayerAlive(LocalPlayer) then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and #auraLayers > 0 then
            local groundCF = getGroundCFrame(char, hrp)
            local heightDiff = state.killAuraHeightOffset or 0
            for i, layer in ipairs(auraLayers) do
                if layer.part and layer.part.Parent == workspace then
                    local yOff = (i - 1) * heightDiff + (i - 1) * 0.001
                    layer.part.CFrame = groundCF + Vector3.new(0, yOff, 0)
                end
            end
            updateAuraVisuals(dt)
        end
    end
end))

-- recreate destroyed aura parts automatically
trackThread(task.spawn(function()
    while not state.unloaded do
        if state.killAuraParticleEnabled and isPlayerAlive(LocalPlayer) then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local needsRebuild = (#auraLayers == 0)
                for _, layer in ipairs(auraLayers) do
                    if not layer.part or layer.part.Parent ~= workspace
                        or not layer.surfaceGui or layer.surfaceGui.Parent ~= layer.part then
                        needsRebuild = true
                        break
                    end
                end
                if needsRebuild then
                    rebuildParticleAura()
                end
            else
                cleanupParticleAura()
            end
        else
            cleanupParticleAura()
        end
        task.wait(0.5)
    end
end))

-- attack enemies within knife reach automatically
local knifeKillAuraZonePart = nil
local knifeAttackDebounce = false

trackThread(task.spawn(function()
    while not state.unloaded do
        if state.killAuraEnabled and isPlayerAlive(LocalPlayer) then
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local range = math.clamp(state.killAuraRange, 5, 40)

                if not knifeKillAuraZonePart or knifeKillAuraZonePart.Parent ~= char then
                    if knifeKillAuraZonePart then pcall(function() knifeKillAuraZonePart:Destroy() end) end
                    knifeKillAuraZonePart = Instance.new("Part")
                    knifeKillAuraZonePart.Name = "KillAuraZone"
                    knifeKillAuraZonePart.Shape = Enum.PartType.Cylinder
                    knifeKillAuraZonePart.Material = Enum.Material.Neon
                    knifeKillAuraZonePart.Color = Color3.fromRGB(160, 5, 15)
                    knifeKillAuraZonePart.Transparency = 0.8
                    knifeKillAuraZonePart.Anchored = true
                    knifeKillAuraZonePart.CanCollide = false
                    knifeKillAuraZonePart.CanQuery   = false
                    knifeKillAuraZonePart.CanTouch   = false
                    knifeKillAuraZonePart.CastShadow = false
                    knifeKillAuraZonePart.Parent = char
                end

                knifeKillAuraZonePart.Size = Vector3.new(0.08, range * 2, range * 2)
                knifeKillAuraZonePart.CFrame = (hrp.CFrame * CFrame.new(0, -2.75, 0)) * CFrame.Angles(0, 0, math.rad(90))
                knifeKillAuraZonePart.Transparency = (state.killAuraVisible == false) and 1 or 0.8

                local knifeTool = getPlayerTool(LocalPlayer, "Knife")
                if knifeTool and not knifeAttackDebounce then
                    local targetsInRange = {}
                    for _, target in ipairs(Players:GetPlayers()) do
                        if target ~= LocalPlayer and isPlayerAlive(target) then
                            local tChar = target.Character
                            local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                            if tHrp then
                                local dist = (tHrp.Position - hrp.Position).Magnitude
                                if dist <= range then
                                    table.insert(targetsInRange, { player = target, char = tChar, hrp = tHrp })
                                end
                            end
                        end
                    end

                    if #targetsInRange > 0 then
                        knifeAttackDebounce = true
                        if knifeTool.Parent ~= char then
                            hum:EquipTool(knifeTool)
                        end
                        task.wait(0.1)

                        if isPlayerAlive(LocalPlayer) and hum and hum.Health > 0 then
                            local events = getKnifeEvents()
                            if events then
                                if state.killAuraType == "Throw" then
                                    for _, tData in ipairs(targetsInRange) do
                                        if isPlayerAlive(tData.player) then
                                            local tChar = tData.char
                                            local tHrp  = tData.hrp
                                            local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso") or tHrp
                                            local torsoPos = torso.Position
                                            local knifeOrigin = hrp.Position + Vector3.new(0, 1.5, 0)
                                            pcall(function() events.KnifeThrown:FireServer(CFrame.new(knifeOrigin, torsoPos), CFrame.new(torsoPos)) end)
                                        end
                                    end
                                else
                                    pcall(function() events.KnifeStabbed:FireServer() end)
                                    for _, tData in ipairs(targetsInRange) do
                                        if isPlayerAlive(tData.player) then
                                            local tChar = tData.char
                                            local tHrp  = tData.hrp
                                            local handle = nil
                                            for _, acc in ipairs(tChar:GetChildren()) do
                                                if acc:IsA("Accessory") then
                                                    local h = acc:FindFirstChild("Handle")
                                                    if h then handle = h; break end
                                                end
                                            end
                                            handle = handle or tHrp
                                            pcall(function() events.KnifeStabbed:FireServer() end)
                                            pcall(function() events.HandleTouched:FireServer(handle) end)
                                        end
                                    end
                                end
                            end
                        end

                        task.delay(0.1, function()
                            pcall(function() hum:UnequipTools() end)
                            task.delay(0.05, function()
                                knifeAttackDebounce = false
                            end)
                        end)
                    end
                end
            else
                -- remove reach indicator when inactive
                if knifeKillAuraZonePart then
                    pcall(function() knifeKillAuraZonePart:Destroy() end)
                    knifeKillAuraZonePart = nil
                end
            end
        else
            -- remove reach indicator when inactive
            if knifeKillAuraZonePart then
                pcall(function() knifeKillAuraZonePart:Destroy() end)
                knifeKillAuraZonePart = nil
            end
        end
        task.wait(0.01)
    end
end))

registerCleanupHook(function()
    cleanupParticleAura()
    if knifeKillAuraZonePart then
        pcall(function() knifeKillAuraZonePart:Destroy() end)
        knifeKillAuraZonePart = nil
    end
end)

-- avoid slowing down in water volumes 
trackThread(task.spawn(function()
    while not state.unloaded do
        if state.autofarmEnabled then
            pcall(function()
                local pier = Workspace:FindFirstChild("Pier")
                if pier then
                    local respawn = pier:FindFirstChild("Respawn")
                    if respawn then
                        local wc = respawn:FindFirstChild("WaterClient")
                        if wc then pcall(function() wc:Destroy() end) end
                    end
                end

                local yacht = Workspace:FindFirstChild("Yacht")
                if yacht then
                    local int = yacht:FindFirstChild("Intereactive") or yacht:FindFirstChild("Interactive")
                    if int then
                        local waterFolder = int:FindFirstChild("Water")
                        if waterFolder then
                            local wcWater = waterFolder:FindFirstChild("WaterClient")
                            if wcWater then pcall(function() wcWater:Destroy() end) end
                        end
                        local wcDirect = int:FindFirstChild("WaterClient")
                        if wcDirect then pcall(function() wcDirect:Destroy() end) end
                    end
                end

                local wcMap = _cachedMap
                if wcMap and wcMap.Parent == Workspace then
                    for _, child in ipairs(wcMap:GetChildren()) do
                        if child.Name == "WaterClient" then
                            pcall(function() child:Destroy() end)
                        elseif child:IsA("Folder") or child:IsA("Model") then
                            local wcSub = child:FindFirstChild("WaterClient")
                            if wcSub then
                                pcall(function() wcSub:Destroy() end)
                            end
                        end
                    end
                end
            end)
            task.wait(1.5)
        else
            task.wait(4.0)
        end
    end
end))


-- trigger character emote animations
local currentEmoteTrack = nil

local standardEmotes = {
    ["Take The L"]       = "rbxassetid://75460729737525",
    ["neck roller"]      = "rbxassetid://110855869390004",
    ["WISH NLE"]         = "rbxassetid://82501710348206",
    ["Zero Two Dance"]   = "rbxassetid://82682811348660",
    ["Gangnam Style"]    = "rbxassetid://129764254213842",
}

local function stopEmote()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() end)
        currentEmoteTrack = nil
    end
    local pe = ReplicatedStorage:FindFirstChild("PlayEmote")
    if pe then
        if pe:IsA("BindableFunction") then
            pcall(function() pe:Invoke("") end)
        elseif pe:IsA("RemoteFunction") then
            pcall(function() pe:InvokeServer("") end)
        elseif pe:IsA("RemoteEvent") then
            pcall(function() pe:FireServer("") end)
        end
    end
end

local function playEmote(emoteNameOrId)
    stopEmote()
    if not emoteNameOrId or emoteNameOrId == "" then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or hum

    local rawStr = tostring(emoteNameOrId)
    local animAsset = nil
    if state.customEmotes and state.customEmotes[rawStr] then
        animAsset = state.customEmotes[rawStr]
    elseif standardEmotes[rawStr] then
        animAsset = standardEmotes[rawStr]
    end

    if not animAsset then
        local num = rawStr:match("%d+")
        if num and (#num >= 6 or rawStr:find("rbxassetid")) then
            animAsset = "rbxassetid://" .. num
        end
    end

    if animAsset then
        local digits = tostring(animAsset):match("%d+")
        if digits then animAsset = "rbxassetid://" .. digits end
        local anim = Instance.new("Animation")
        anim.AnimationId = animAsset
        local track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action
        track.Looped = true
        track:Play()
        currentEmoteTrack = track
    else
        local lowerName = string.lower(rawStr)
        local pe = ReplicatedStorage:FindFirstChild("PlayEmote")
        if pe then
            if pe:IsA("BindableFunction") then
                pcall(function() pe:Invoke(lowerName) end)
            elseif pe:IsA("RemoteFunction") then
                pcall(function() pe:InvokeServer(lowerName) end)
            elseif pe:IsA("RemoteEvent") then
                pcall(function() pe:FireServer(lowerName) end)
            end
        end
    end
end

trackConnection(RunService.Heartbeat:Connect(function()
    if state.emoteStopOnMove and currentEmoteTrack and currentEmoteTrack.IsPlaying then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0.05 then
            stopEmote()
        end
    end
end))
registerCleanupHook(stopEmote)

-- display item values directly over inventory slots
local function applyRedGradient(label)
    if not label then return end
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    local grad = label:FindFirstChild("RedGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Name = "RedGradient"
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 10))
        })
        grad.Rotation = 90
        grad.Parent = label
    else
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 10))
        })
    end
end

local function isSlotFilled(slot)
    if not slot or not slot.Visible then return false end
    local itemCont = slot:FindFirstChild("Container")
    if not itemCont or not itemCont.Visible then return false end
    local nameObj = slot:FindFirstChild("ItemName")
    if not nameObj or not nameObj.Visible then return false end
    local label = nameObj:FindFirstChild("Label")
    if not label or not label:IsA("TextLabel") then return false end
    local txt = label.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if txt == "" or txt == "Item Name" or txt == "Label" or txt == "Default" then return false end
    return true, txt, nameObj, itemCont
end

local function updateTradeValues()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local tradeGui = playerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return end
    local container = tradeGui:FindFirstChild("Container")
    local trade = container and container:FindFirstChild("Trade")
    if not trade then return end

    local isTradeOpen = trade.Visible and state.valueCalculatorEnabled

    local function processOffer(offerFrame)
        if not offerFrame then return end
        local slotContainer = offerFrame:FindFirstChild("Container")
        local itemBg = offerFrame:FindFirstChild("ItemBackground")
        local totalOfferVal = 0

        -- clear previous summary labels before redraw
        if itemBg then
            local oldLbl = itemBg:FindFirstChild("TotalValueLabel")
            if oldLbl then oldLbl:Destroy() end
        end

        if slotContainer then
            -- mm2 trade slots are indexed NewItem1 through NewItem4 under trade offer containers
            for i = 1, 4 do
                local slot = slotContainer:FindFirstChild("NewItem" .. i)
                if slot then
                    -- remove old value tag before updating item slot
                    local oldSlotVal = slot:FindFirstChild("ValueLabel")
                    if oldSlotVal then oldSlotVal:Destroy() end

                    local isFilled, rawName, nameObj, itemCont = isSlotFilled(slot)
                    local valLabel = itemCont and itemCont:FindFirstChild("ValueLabel")

                    if isFilled and isTradeOpen then
                        local amount = 1
                        local amountObj = itemCont:FindFirstChild("Amount")
                        if amountObj and amountObj.Visible and amountObj.Text ~= "" then
                            local n = amountObj.Text:match("%d+")
                            if n then amount = tonumber(n) or 1 end
                        end

                        local rarity = detectRarityFromColor(nameObj)
                        local unitVal = getMM2ItemValue(rawName, rarity)
                        local slotVal = unitVal * amount
                        totalOfferVal = totalOfferVal + slotVal

                        if not valLabel then
                            valLabel = Instance.new("TextLabel")
                            valLabel.Name = "ValueLabel"
                            valLabel.BackgroundTransparency = 1
                            valLabel.BorderSizePixel = 0
                            valLabel.Size = UDim2.new(1, -4, 0, 20)
                            valLabel.Position = UDim2.new(0, 0, 0, 2)
                            valLabel.AnchorPoint = Vector2.new(0, 0)
                            valLabel.ZIndex = (itemCont.ZIndex or 1) + 20
                            valLabel.Font = Enum.Font.GothamBold
                            valLabel.TextSize = 15
                            valLabel.TextXAlignment = Enum.TextXAlignment.Right
                            valLabel.Parent = itemCont
                        end
                        valLabel.Visible = true
                        valLabel.BackgroundTransparency = 1
                        valLabel.TextSize = 15
                        valLabel.Text = "Value: " .. formatValue(slotVal)
                        applyRedGradient(valLabel)
                    else
                        if valLabel then
                            valLabel.Visible = false
                            valLabel.Text = ""
                        end
                    end
                end
            end
        end

        -- show aggregate offer worth for fair trading
        local totalLabel = offerFrame:FindFirstChild("TotalValueLabel")
        if isTradeOpen then
            if not totalLabel then
                totalLabel = Instance.new("TextLabel")
                totalLabel.Name = "TotalValueLabel"
                totalLabel.BackgroundTransparency = 1
                totalLabel.BorderSizePixel = 0
                totalLabel.Size = UDim2.new(0, 260, 0, 28)
                totalLabel.AnchorPoint = Vector2.new(0.5, 0)
                totalLabel.Position = UDim2.new(0.5, 0, 0, 4)
                totalLabel.ZIndex = (offerFrame.ZIndex or 1) + 20
                totalLabel.Font = Enum.Font.GothamBold
                totalLabel.TextSize = 18
                totalLabel.TextXAlignment = Enum.TextXAlignment.Center
                totalLabel.Parent = offerFrame
            end
            totalLabel.Visible = true
            totalLabel.BackgroundTransparency = 1
            totalLabel.TextSize = 18
            totalLabel.Text = "Total Value: " .. formatValue(totalOfferVal)
            applyRedGradient(totalLabel)
        elseif totalLabel then
            totalLabel.Visible = false
        end
    end

    processOffer(trade:FindFirstChild("YourOffer"))
    processOffer(trade:FindFirstChild("TheirOffer"))
end

local function updateInventoryValues()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local mainGui = playerGui:FindFirstChild("MainGUI")
    if not mainGui then return end
    local gameFrame = mainGui:FindFirstChild("Game")
    local inv = gameFrame and gameFrame:FindFirstChild("Inventory")
    if not inv or not inv.Visible then return end

    local mainFrame = inv:FindFirstChild("Main")
    local weapons = mainFrame and mainFrame:FindFirstChild("Weapons")
    local items = weapons and weapons:FindFirstChild("Items")
    if not items or not items.Visible then return end

    -- mm2 inventory gui hierarchy stores active weapon grid cards under Weapons.Items.Container
    local containerRoot = items:FindFirstChild("Container")
    if not containerRoot then return end

    local grandTotal = 0

    local function scanCardContainer(parentCont)
        if not parentCont then return end
        for _, card in ipairs(parentCont:GetChildren()) do
            if card:IsA("GuiObject") and card.Name ~= "UIListLayout" and card.Name ~= "UIGridLayout" and card.Name ~= "UIPadding" then
                local nameObj = card:FindFirstChild("ItemName")
                local label = nameObj and nameObj:FindFirstChild("Label")
                if label and label:IsA("TextLabel") and label.Text ~= "" and label.Text ~= "Item Name" and label.Text ~= "Label" then
                    local skinName = label.Text:gsub("^%s+", ""):gsub("%s+$", "")
                    local amount = 1
                    local cont = card:FindFirstChild("Container")
                    local amountObj = cont and cont:FindFirstChild("Amount")
                    if amountObj and amountObj.Visible and amountObj.Text ~= "" then
                        local n = amountObj.Text:match("%d+")
                        if n then amount = tonumber(n) or 1 end
                    end

                    local rarity = detectRarityFromColor(nameObj)
                    local unitVal = getMM2ItemValue(skinName, rarity)
                    local itemTotal = unitVal * amount
                    grandTotal = grandTotal + itemTotal

                    local badge = card:FindFirstChild("ItemValueLabel")
                    if state.valueCalculatorEnabled then
                        if not badge then
                            badge = Instance.new("TextLabel")
                            badge.Name = "ItemValueLabel"
                            badge.BackgroundTransparency = 1
                            badge.BorderSizePixel = 0
                            badge.Size = UDim2.new(0, 75, 0, 20)
                            badge.Position = UDim2.new(1, -77, 0, 2)
                            badge.ZIndex = (card.ZIndex or 1) + 20
                            badge.Font = Enum.Font.GothamBold
                            badge.TextSize = 14
                            badge.TextXAlignment = Enum.TextXAlignment.Right
                            badge.Parent = card
                        end
                        badge.Visible = true
                        badge.BackgroundTransparency = 1
                        badge.TextSize = 14
                        badge.Text = formatValue(itemTotal)
                        applyRedGradient(badge)
                    elseif badge then
                        badge.Visible = false
                    end
                end
            end
        end
    end

    local classic = containerRoot:FindFirstChild("Classic")
    if classic then scanCardContainer(classic:FindFirstChild("Container")) end

    local current = containerRoot:FindFirstChild("Current")
    if current then scanCardContainer(current:FindFirstChild("Container")) end

    local holiday = containerRoot:FindFirstChild("Holiday")
    local holidayCont = holiday and holiday:FindFirstChild("Container")
    if holidayCont then
        local xmas = holidayCont:FindFirstChild("Christmas")
        if xmas then scanCardContainer(xmas:FindFirstChild("Container")) end
        local hall = holidayCont:FindFirstChild("Halloween")
        if hall then scanCardContainer(hall:FindFirstChild("Container")) end
    end

    -- remove old total label before re-anchoring
    local oldInsideItems = items:FindFirstChild("TotalInventoryValueLabel")
    if oldInsideItems then oldInsideItems:Destroy() end

    -- attach total inventory worth to main frame
    local totalParent = mainFrame or inv
    local totalInvLabel = totalParent:FindFirstChild("TotalInventoryValueLabel")
    if state.valueCalculatorEnabled and items.Visible and inv.Visible then
        if weapons then weapons.ClipsDescendants = false end
        if mainFrame then mainFrame.ClipsDescendants = false end

        if not totalInvLabel then
            totalInvLabel = Instance.new("TextLabel")
            totalInvLabel.Name = "TotalInventoryValueLabel"
            totalInvLabel.BackgroundTransparency = 1
            totalInvLabel.BorderSizePixel = 0
            totalInvLabel.Size = UDim2.new(0, 320, 0, 28)
            totalInvLabel.ZIndex = 100
            totalInvLabel.Font = Enum.Font.GothamBold
            totalInvLabel.TextSize = 18
            totalInvLabel.TextXAlignment = Enum.TextXAlignment.Left
            totalInvLabel.Parent = totalParent
        end

        pcall(function()
            local posX = items.AbsolutePosition.X - totalParent.AbsolutePosition.X
            local posY = items.AbsolutePosition.Y - totalParent.AbsolutePosition.Y + items.AbsoluteSize.Y + 4
            totalInvLabel.Position = UDim2.new(0, math.max(10, posX), 0, posY)
        end)

        totalInvLabel.Visible = true
        totalInvLabel.BackgroundTransparency = 1
        totalInvLabel.TextSize = 18
        totalInvLabel.Text = "Total Value: " .. formatValue(grandTotal)
        applyRedGradient(totalInvLabel)
    elseif totalInvLabel then
        totalInvLabel.Visible = false
    end
end

trackThread(task.spawn(function()
    while not state.unloaded do
        if state.valueCalculatorEnabled then
            pcall(updateTradeValues)
            pcall(updateInventoryValues)
            task.wait(0.25)
        else
            task.wait(1.5)
        end
    end
end))


local function toKeyCode(k)
    if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then
        return k
    elseif type(k) == "string" then
        local name = k:gsub("^Enum%.KeyCode%.", ""):gsub("%s+", "")
        local ok, res = pcall(function() return Enum.KeyCode[name] end)
        if ok and typeof(res) == "EnumItem" then return res end
    end
    return nil
end






local function _buildScriptUI()

    -- load external tab adapter module from github to decouple layout structure
    local mdTabs
    pcall(function()
        local url = "https://raw.githubusercontent.com/rilorfakesilly/scripts/refs/heads/main/modules/tab_adapter.lua"
        local ok, raw = pcall(function() return game:HttpGet(url) end)
        if not ok or not raw or raw:find("404: Not Found") then
            url = "https://raw.githubusercontent.com/rilorfakesilly/scripts/refs/heads/main/tab_adapter.lua"
            raw = game:HttpGet(url)
        end
        local adapter = loadstring(raw)()
        if type(adapter) == "table" and type(adapter.createTabs) == "function" then
            mdTabs = adapter.createTabs(Window)
        end
    end)

    if not mdTabs then
        mdTabs = {
            Main       = Window:CreateTab("Main", 1, "home"),
            Autofarm   = Window:CreateTab("Autofarm", 3, "coins"),
            Player     = Window:CreateTab("Player", 5, "user"),
            Murderer   = Window:CreateTab("Murderer", 7, "skull"),
            Sheriff    = Window:CreateTab("Sheriff", 9, "shield"),
            Sounds     = Window:CreateTab("Sounds", 11, "volume-2"),
            Visuals    = Window:CreateTab("Visuals", 13, "eye"),
            Animations = Window:CreateTab("Animations", 15, "activity"),
            World      = Window:CreateTab("World", 17, "globe"),
            Camera     = Window:CreateTab("Camera", 19, "camera"),
            Webhook    = Window:CreateTab("Webhook", 21, "send"),
            Settings   = (Window.GetSettingsTab and Window:GetSettingsTab()) or Window.SettingsTab or Window:CreateTab("Settings", 999, "settings"),
        }

        Window:AddSidebarBigDivider(2)

        Window:AddSidebarSmallDivider(4)
        Window:AddSidebarSmallDivider(6)
        Window:AddSidebarSmallDivider(8)
        Window:AddSidebarSmallDivider(10)

        Window:AddSidebarBigDivider(12)

        Window:AddSidebarSmallDivider(14)
        Window:AddSidebarSmallDivider(16)
        Window:AddSidebarSmallDivider(18)
        Window:AddSidebarSmallDivider(20)
    end

    -- construct main overview controls
    mdTabs.Main:AddWelcomeHeader()

    mdTabs.Main:AddButtonRow({
        { Text = "Rejoin server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end },
        { Text = "Server hop",    Callback = function() serverHop() end },
        { Text = "Kill character",Callback = function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end }
    }, 31)

    local function createTabAdapter(rawTab)
        local adapter = {
            RawTab = rawTab,
            AddSection = function(self, title, isFullWidth)
                if rawTab and rawTab.AddSection then
                    local sec = rawTab:AddSection(title, isFullWidth)
                    self._currentSection = sec
                    self._sectionContainer = sec and sec.Container or nil
                    return sec
                elseif rawTab and rawTab.AddLabel then
                    return rawTab:AddLabel(title)
                end
                return self
            end,
            AddLabel = function(self, textOrConfig, options)
                if rawTab and rawTab.AddLabel then
                    return rawTab:AddLabel(textOrConfig, options)
                end
                return self
            end,
            AddDivider = function(self, options)
                if rawTab and rawTab.AddDivider then
                    return rawTab:AddDivider(options)
                end
                return self
            end,
            AddToggle = function(self, id, cfg)
                local title = cfg.Title or id
                local defaultVal = (cfg.Default ~= nil) and cfg.Default or false
                local cb = cfg.Callback
                local bindVal = cfg.Bind or cfg.DefaultBind

                local sliderCfg = nil
                if cfg.Slider and type(cfg.Slider) == "table" then
                    sliderCfg = {}
                    for k, v in pairs(cfg.Slider) do sliderCfg[k] = v end
                    local slId = sliderCfg.Id or sliderCfg.id or sliderCfg.SaveKey or sliderCfg.saveKey or (id .. "Volume") or (id .. "_Slider") or sliderCfg.Title
                    sliderCfg.Id = slId
                    sliderCfg.SaveKey = slId
                    sliderCfg.Identifier = slId
                end

                local toggleObj = rawTab:AddToggle({
                    Name = title,
                    Title = title,
                    SaveKey = cfg.SaveKey or cfg.Id or id,
                    Identifier = cfg.Identifier or id,
                    Id = cfg.Id or id,
                    Default = defaultVal,
                    DefaultBind = bindVal,
                    Connect = cfg.Connect,
                    Slider = sliderCfg,
                    Parent = self._sectionContainer or self._currentSection,
                    Callback = function(v)
                        if Options[id] then
                            Options[id].Value = v
                            if Options[id]._callback then
                                Options[id]._callback(v)
                            end
                        elseif cb then
                            cb(v)
                        end
                    end
                })
                if Window and Window.SearchableItems and #Window.SearchableItems > 0 then
                    local lastItem = Window.SearchableItems[#Window.SearchableItems]
                    if lastItem and (lastItem.Type == "Toggle" or lastItem.Instance == (toggleObj and toggleObj.Frame)) then
                        lastItem.Name = title
                        lastItem.Id = id
                    end
                end

                local wrapper = {
                    Value = defaultVal,
                    Element = toggleObj,
                    _callback = cb,
                    SetValue = function(s, v, trigger)
                        s.Value = v
                        pcall(function()
                            if toggleObj and toggleObj.SetState then
                                toggleObj.SetState(v, trigger ~= false)
                            end
                        end)
                    end,
                    GetValue = function(s)
                        return (toggleObj and toggleObj.GetState) and toggleObj.GetState() or s.Value
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper

                if sliderCfg and toggleObj and toggleObj.ConnectedSlider then
                    local slId = sliderCfg.Id
                    local slElem = toggleObj.ConnectedSlider
                    local slWrapper = {
                        Value = (slElem.GetValue and slElem:GetValue()) or sliderCfg.Default,
                        Element = slElem,
                        SetValue = function(s, v, trigger)
                            s.Value = v
                            pcall(function()
                                if slElem and slElem.SetValue then
                                    slElem:SetValue(v, trigger ~= false)
                                end
                            end)
                        end,
                        GetValue = function(s)
                            return (slElem and slElem.GetValue) and slElem:GetValue() or s.Value
                        end,
                        OnChanged = function(s, callback)
                            s._callback = callback
                            return s
                        end
                    }
                    if slId then Options[slId] = slWrapper end
                    Options[id .. "Volume"] = slWrapper
                    Options[id .. "_Slider"] = slWrapper
                end

                return wrapper
            end,
            AddCheckbox = function(self, id, cfg)
                local title = cfg.Title or id
                local defaultVal = (cfg.Default ~= nil) and cfg.Default or false
                local cb = cfg.Callback

                local checkboxObj = rawTab:AddCheckbox({
                    Name = title,
                    Title = title,
                    SaveKey = cfg.SaveKey or cfg.Id or id,
                    Identifier = cfg.Identifier or id,
                    Id = cfg.Id or id,
                    Default = defaultVal,
                    Parent = self._sectionContainer or self._currentSection,
                    Callback = function(v)
                        if Options[id] then
                            Options[id].Value = v
                            if Options[id]._callback then
                                Options[id]._callback(v)
                            end
                        elseif cb then
                            cb(v)
                        end
                    end
                })
                if Window and Window.SearchableItems and #Window.SearchableItems > 0 then
                    local lastItem = Window.SearchableItems[#Window.SearchableItems]
                    if lastItem and (lastItem.Type == "Checkbox" or lastItem.Instance == (checkboxObj and checkboxObj.Frame)) then
                        lastItem.Name = title
                        lastItem.Id = id
                    end
                end

                local wrapper = {
                    Value = defaultVal,
                    Element = checkboxObj,
                    _callback = cb,
                    SetValue = function(s, v, trigger)
                        s.Value = v
                        pcall(function()
                            if checkboxObj and checkboxObj.SetState then
                                checkboxObj:SetState(v, trigger ~= false)
                            end
                        end)
                    end,
                    GetValue = function(s)
                        return (checkboxObj and checkboxObj.GetState) and checkboxObj:GetState() or s.Value
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper
                return wrapper
            end,
            AddSlider = function(self, id, cfg)
                local title = cfg.Title or id
                local minVal = cfg.Min or 0
                local maxVal = cfg.Max or 100
                local defVal = (cfg.Default ~= nil) and cfg.Default or minVal
                local cb = cfg.Callback

                local sliderCfg = {}
                for k, v in pairs(cfg) do
                    sliderCfg[k] = v
                end
                sliderCfg.Title = title
                sliderCfg.Min = minVal
                sliderCfg.Max = maxVal
                sliderCfg.Default = defVal
                sliderCfg.SaveKey = cfg.SaveKey or cfg.Id or id
                sliderCfg.Identifier = cfg.Identifier or id
                sliderCfg.Id = cfg.Id or id
                sliderCfg.Parent = self._sectionContainer or self._currentSection
                sliderCfg.Callback = function(v, pct)
                    if Options[id] then
                        Options[id].Value = v
                        if Options[id]._callback then
                            Options[id]._callback(v, pct)
                        end
                    elseif cb then
                        cb(v, pct)
                    end
                end

                local sliderObj = rawTab:AddSlider(sliderCfg, self._sectionContainer or self._currentSection)
                if Window and Window.SearchableItems and #Window.SearchableItems > 0 then
                    local lastItem = Window.SearchableItems[#Window.SearchableItems]
                    if lastItem and (lastItem.Type == "Slider" or (sliderObj and (lastItem.Instance == sliderObj.CardFrame or lastItem.Instance == sliderObj.Track))) then
                        lastItem.Name = title
                        lastItem.Id = id
                    end
                end

                local wrapper = {
                    Value = defVal,
                    Element = sliderObj,
                    _callback = cb,
                    SetValue = function(s, v, trigger)
                        s.Value = v
                        pcall(function()
                            if sliderObj and sliderObj.SetValue then
                                sliderObj.SetValue(v, trigger ~= false)
                            end
                        end)
                    end,
                    GetValue = function(s)
                        return (sliderObj and sliderObj.GetValue) and sliderObj.GetValue() or s.Value
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper
                return wrapper
            end,
            AddDropdown = function(self, id, cfg)
                local title = cfg.Title or id
                local optionsList = cfg.Values or cfg.Options or {}
                local defVal = cfg.Default or (optionsList[1] or "")
                local cb = cfg.Callback

                local dropCfg = {
                    Title = title,
                    Options = optionsList,
                    Values = optionsList,
                    Default = defVal,
                    SaveKey = cfg.SaveKey or cfg.Id or id,
                    Identifier = cfg.Identifier or id,
                    Id = cfg.Id or id,
                    Parent = self._sectionContainer or self._currentSection,
                    Callback = function(selected)
                        if Options[id] then
                            Options[id].Value = selected
                            if Options[id]._callback then
                                Options[id]._callback(selected)
                            end
                        elseif cb then
                            cb(selected)
                        end
                    end
                }

                local dropObj = rawTab:AddDropdown(dropCfg, optionsList, defVal, dropCfg.Callback, self._sectionContainer or self._currentSection, nil, nil, dropCfg)
                if Window and Window.SearchableItems and #Window.SearchableItems > 0 then
                    local lastItem = Window.SearchableItems[#Window.SearchableItems]
                    if lastItem and (lastItem.Type == "Dropdown" or lastItem.Instance == (dropObj and dropObj.Frame)) then
                        lastItem.Name = title
                        lastItem.Id = id
                    end
                end

                local wrapper = {
                    Value = defVal,
                    Options = optionsList,
                    Element = dropObj,
                    _callback = cb,
                    SetValue = function(s, v, trigger)
                        s.Value = v
                        pcall(function()
                            if dropObj and dropObj.SetSelected then
                                dropObj.SetSelected(v, trigger ~= false)
                            end
                        end)
                    end,
                    SetValues = function(s, newOpts)
                        s.Options = newOpts
                        pcall(function()
                            if dropObj and dropObj.RefreshOptions then
                                dropObj.RefreshOptions(newOpts)
                            end
                        end)
                    end,
                    RefreshOptions = function(s, newOpts)
                        s.Options = newOpts
                        pcall(function()
                            if dropObj and dropObj.RefreshOptions then
                                dropObj.RefreshOptions(newOpts)
                            end
                        end)
                    end,
                    GetValue = function(s)
                        return (dropObj and dropObj.GetSelected) and dropObj.GetSelected() or s.Value
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper
                return wrapper
            end,
            AddInput = function(self, id, cfg)
                local title = cfg.Title or id
                local placeholder = cfg.Placeholder or ""
                local defVal = (cfg.Default ~= nil) and tostring(cfg.Default) or ""
                local cb = cfg.Callback

                local boxCfg = {
                    Title = title,
                    Placeholder = placeholder,
                    Default = defVal,
                    SaveKey = cfg.SaveKey or cfg.Id or id,
                    Identifier = cfg.Identifier or id,
                    Id = cfg.Id or id,
                    Parent = self._sectionContainer or self._currentSection,
                    Callback = function(text, enter)
                        if Options[id] then
                            Options[id].Value = text
                            if Options[id]._callback then
                                Options[id]._callback(text, enter)
                            end
                        elseif cb then
                            cb(text, enter)
                        end
                    end
                }

                local boxObj = rawTab:AddTextbox(boxCfg, placeholder, defVal, boxCfg.Callback, self._sectionContainer or self._currentSection, nil, nil, boxCfg)
                if Window and Window.SearchableItems and #Window.SearchableItems > 0 then
                    local lastItem = Window.SearchableItems[#Window.SearchableItems]
                    if lastItem and (lastItem.Type == "Textbox" or lastItem.Instance == (boxObj and boxObj.Frame)) then
                        lastItem.Name = title
                        lastItem.Id = id
                    end
                end

                local wrapper = {
                    Value = defVal,
                    Element = boxObj,
                    _callback = cb,
                    SetValue = function(s, v)
                        s.Value = tostring(v or "")
                        pcall(function()
                            if boxObj and boxObj.SetText then
                                boxObj.SetText(s.Value)
                            end
                        end)
                    end,
                    SetText = function(s, v)
                        s.Value = tostring(v or "")
                        pcall(function()
                            if boxObj and boxObj.SetText then
                                boxObj.SetText(s.Value)
                            end
                        end)
                    end,
                    GetValue = function(s)
                        return (boxObj and boxObj.GetText) and boxObj.GetText() or s.Value
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper
                return wrapper
            end,
            AddTextInput = function(self, id, cfg)
                if type(id) == "table" and cfg == nil then
                    cfg = id
                    id = cfg.Title or cfg.Name or "Input"
                end
                return self:AddInput(id, cfg)
            end,
            AddTextbox = function(self, id, cfg)
                if type(id) == "table" and cfg == nil then
                    cfg = id
                    id = cfg.Title or cfg.Name or "Input"
                end
                return self:AddInput(id, cfg)
            end,
            AddColorpicker = function(self, id, cfg)
                local title = cfg.Title or id
                local defVal = cfg.Default or Color3.fromRGB(255, 255, 255)
                local cb = cfg.Callback

                local cpCfg = {
                    Title = title,
                    Default = defVal,
                    SaveKey = cfg.SaveKey or cfg.Id or id,
                    Identifier = cfg.Identifier or id,
                    Id = cfg.Id or id,
                    Parent = self._sectionContainer or self._currentSection,
                    Callback = function(newCol)
                        if Options[id] then
                            Options[id].Value = newCol
                            if Options[id]._callback then
                                Options[id]._callback(newCol)
                            end
                        elseif cb then
                            cb(newCol)
                        end
                    end
                }

                local cpObj = rawTab:AddColorPicker(cpCfg, defVal, cpCfg.Callback, self._sectionContainer or self._currentSection, nil, nil, id)
                if Window and Window.SearchableItems and #Window.SearchableItems > 0 then
                    local lastItem = Window.SearchableItems[#Window.SearchableItems]
                    if lastItem and (lastItem.Type == "Color picker" or lastItem.Instance == (cpObj and cpObj.Frame)) then
                        lastItem.Name = title
                        lastItem.Id = id
                    end
                end

                local wrapper = {
                    Value = defVal,
                    Element = cpObj,
                    _callback = cb,
                    SetValue = function(s, v, trigger)
                        s.Value = v
                        pcall(function()
                            if cpObj and cpObj.SetColor then
                                cpObj.SetColor(v, trigger ~= false)
                            end
                        end)
                    end,
                    SetColor = function(s, v, trigger)
                        s.Value = v
                        pcall(function()
                            if cpObj and cpObj.SetColor then
                                cpObj.SetColor(v, trigger ~= false)
                            end
                        end)
                    end,
                    GetValue = function(s)
                        return (cpObj and cpObj.GetColor) and cpObj.GetColor() or s.Value
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper
                return wrapper
            end,
            AddColorPicker = function(self, id, cfg, ...)
                if type(id) == "string" and type(cfg) == "table" then
                    return self:AddColorpicker(id, cfg)
                elseif rawTab and rawTab.AddColorPicker then
                    return rawTab:AddColorPicker(id, cfg, ...)
                end
                return self:AddColorpicker(id, cfg)
            end,
            AddButton = function(self, cfg)
                local title = cfg.Title or cfg.Text or "Button"
                local cb = cfg.Callback
                local target = self._sectionContainer or self._currentSection

                local btnObj = rawTab:AddLongButton(title, function()
                    if cb then cb() end
                end, 1.0, target)
                return btnObj
            end,
            AddButtonRow = function(self, buttonList, height, parentRow)
                if not rawTab or not rawTab.AddButtonRow then return end
                local target = parentRow or self._sectionContainer or self._currentSection
                return rawTab:AddButtonRow(buttonList, height or 24, target)
            end,
            AddRow = function(self, height, padding, parentRow)
                if not rawTab or not rawTab.AddRow then return end
                local target = parentRow or self._sectionContainer or self._currentSection
                return rawTab:AddRow(height, padding, target)
            end,
            AddKeybind = function(self, id, cfg)
                local title = cfg.Title or id
                local defVal = cfg.Default or Enum.KeyCode.Unknown
                local cb = cfg.Callback

                local wrapper = {
                    Value = defVal,
                    _callback = cb,
                    SetValue = function(s, v)
                        s.Value = v
                        if s._callback then s._callback(v) end
                    end,
                    OnChanged = function(s, callback)
                        s._callback = callback
                        return s
                    end
                }
                Options[id] = wrapper
                return wrapper
            end,
            AddGroup = function(self, itemList, direction)
                if not rawTab or not rawTab.AddGroup then return {} end
                local dir = direction or "Vertical"
                local isHoriz = (dir == "Horizontal" or dir == "horizontal" or dir == "H" or dir == "h")
                local wrappedList = {}
                local origCallbacks = {}
                for i, item in ipairs(itemList) do
                    local it = {}
                    for k, v in pairs(item) do it[k] = v end
                    if not isHoriz and it.Fraction == nil and it.Size == nil then
                        it.Fraction = 1.0
                    end
                    local opts = it.Values or it.values or it.Options or it.options
                    if opts and not it.Options then
                        it.Options = opts
                    end
                    local id = it.Id or it.id or it.Identifier or it.identifier or it.SaveKey or it.saveKey or it.Title or it.Name
                    if id then
                        it.Id = id
                        it.SaveKey = it.SaveKey or id
                        it.Identifier = it.Identifier or id
                    end
                    if type(it.Slider) == "table" then
                        local sl = {}
                        for sk, sv in pairs(it.Slider) do sl[sk] = sv end
                        local slId = sl.Id or sl.id or sl.SaveKey or sl.saveKey or sl.Identifier or sl.identifier or (id and (id .. "Volume")) or (id and (id .. "_Slider")) or sl.Title
                        if slId then
                            sl.Id = slId
                            sl.SaveKey = sl.SaveKey or slId
                            sl.Identifier = sl.Identifier or slId
                        end
                        it.Slider = sl
                    end
                    local origCb = it.Callback or it.callback or it.OnChanged or it.OnSelect
                    origCallbacks[i] = origCb
                    if id then
                        it.Callback = function(...)
                            local arg1 = ...
                            if Options[id] then
                                Options[id].Value = arg1
                                if Options[id]._callback then
                                    Options[id]._callback(...)
                                end
                            elseif origCb then
                                origCb(...)
                            end
                        end
                    end
                    table.insert(wrappedList, it)
                end

                local results = rawTab:AddGroup(wrappedList, dir, self._sectionContainer or self._currentSection)
                for i, item in ipairs(wrappedList) do
                    local id = item.Id or item.id or item.Title or item.Name
                    if id and results[i] then
                        local elem = results[i]
                        local itemOpts = item.Values or item.values or item.Options or item.options
                        local defVal = (item.Default ~= nil) and item.Default or (itemOpts and itemOpts[1]) or false
                        local origCb = origCallbacks[i]
                        local wrapper = {
                            Value = defVal,
                            Options = itemOpts or {},
                            Element = elem,
                            _callback = origCb,
                            SetValue = function(s, v, trigger)
                                s.Value = v
                                pcall(function()
                                    if elem.SetState then elem:SetState(v, trigger ~= false)
                                    elseif elem.SetValue then elem:SetValue(v, trigger ~= false)
                                    elseif elem.SetSelected then elem:SetSelected(v, trigger ~= false)
                                    elseif elem.SetColor then elem:SetColor(v, trigger ~= false)
                                    elseif elem.SetText then elem:SetText(v) end
                                end)
                            end,
                            GetValue = function(s)
                                if elem.GetState then return elem:GetState()
                                elseif elem.GetValue then return elem:GetValue()
                                elseif elem.GetSelected then return elem:GetSelected()
                                elseif elem.GetColor then return elem:GetColor()
                                elseif elem.GetText then return elem:GetText() end
                                return s.Value
                            end,
                            SetValues = function(s, newOpts)
                                s.Options = newOpts
                                pcall(function()
                                    if elem.SetOptions then elem:SetOptions(newOpts)
                                    elseif elem.SetValues then elem:SetValues(newOpts)
                                    elseif elem.RefreshOptions then elem.RefreshOptions(newOpts) end
                                end)
                            end,
                            RefreshOptions = function(s, newOpts)
                                s.Options = newOpts
                                pcall(function()
                                    if elem.SetOptions then elem:SetOptions(newOpts)
                                    elseif elem.SetValues then elem:SetValues(newOpts)
                                    elseif elem.RefreshOptions then elem.RefreshOptions(newOpts) end
                                end)
                            end,
                            OnChanged = function(s, callback)
                                s._callback = callback
                                return s
                            end
                        }
                        Options[id] = wrapper
                        if item.Id then Options[item.Id] = wrapper end
                        if item.SaveKey then Options[item.SaveKey] = wrapper end

                        local slElem = elem.ConnectedSlider or (elem.Element and elem.Element.ConnectedSlider)
                        if slElem or (item.Slider and type(item.Slider) == "table") then
                            local slCfg = type(item.Slider) == "table" and item.Slider or {}
                            local slId = slCfg.Id or slCfg.SaveKey or (id .. "Volume")
                            local slDef = slCfg.Default or (slElem and slElem.GetValue and slElem:GetValue()) or 100
                            local slCb = slCfg.Callback or slCfg.callback or slCfg.OnChanged
                            local slWrapper = {
                                Value = slDef,
                                Element = slElem,
                                _callback = slCb,
                                SetValue = function(s, v, trigger)
                                    s.Value = v
                                    pcall(function()
                                        if slElem and slElem.SetValue then
                                            slElem:SetValue(v, trigger ~= false)
                                        end
                                    end)
                                end,
                                GetValue = function(s)
                                    return (slElem and slElem.GetValue) and slElem:GetValue() or s.Value
                                end,
                                OnChanged = function(s, callback)
                                    s._callback = callback
                                    return s
                                end
                            }
                            if slId then Options[slId] = slWrapper end
                            Options[id .. "Volume"] = slWrapper
                            Options[id .. "_Slider"] = slWrapper
                            if slCfg.Title then Options[slCfg.Title] = slWrapper end
                        end
                    end
                end
                return results
            end,
            AddToggleGroup = function(self, toggleList)
                if not rawTab or not rawTab.AddToggleGroup then return {} end
                local wrappedList = {}
                local origCallbacks = {}
                for i, item in ipairs(toggleList) do
                    local it = {}
                    for k, v in pairs(item) do it[k] = v end
                    local id = it.Id or it.id or it.Identifier or it.identifier or it.SaveKey or it.saveKey or it.Title or it.Name
                    if id then
                        it.Id = id
                        it.SaveKey = it.SaveKey or id
                        it.Identifier = it.Identifier or id
                    end
                    if type(it.Slider) == "table" then
                        local sl = {}
                        for sk, sv in pairs(it.Slider) do sl[sk] = sv end
                        local slId = sl.Id or sl.id or sl.SaveKey or sl.saveKey or sl.Identifier or sl.identifier or (id and (id .. "Volume")) or (id and (id .. "_Slider")) or sl.Title
                        if slId then
                            sl.Id = slId
                            sl.SaveKey = sl.SaveKey or slId
                            sl.Identifier = sl.Identifier or slId
                        end
                        it.Slider = sl
                    end
                    local origCb = it.Callback or it.callback
                    origCallbacks[i] = origCb
                    if id then
                        it.Callback = function(...)
                            local arg1 = ...
                            if Options[id] then
                                Options[id].Value = arg1
                                if Options[id]._callback then
                                    Options[id]._callback(...)
                                end
                            elseif origCb then
                                origCb(...)
                            end
                        end
                    end
                    table.insert(wrappedList, it)
                end

                local results = rawTab:AddToggleGroup(wrappedList, self._sectionContainer or self._currentSection)
                for i, item in ipairs(wrappedList) do
                    local id = item.Id or item.id or item.Title or item.Name
                    if id and results[i] then
                        local elem = results[i]
                        local defVal = (item.Default ~= nil) and item.Default or false
                        local origCb = origCallbacks[i]
                        local wrapper = {
                            Value = defVal,
                            Element = elem,
                            _callback = origCb,
                            SetValue = function(s, v, trigger)
                                s.Value = v
                                pcall(function()
                                    if elem.SetState then elem:SetState(v, trigger ~= false) end
                                end)
                            end,
                            GetValue = function(s)
                                if elem.GetState then return elem:GetState() end
                                return s.Value
                            end,
                            OnChanged = function(s, callback)
                                s._callback = callback
                                return s
                            end
                        }
                        Options[id] = wrapper
                        if item.Id then Options[item.Id] = wrapper end
                        if item.SaveKey then Options[item.SaveKey] = wrapper end

                        local slElem = elem.ConnectedSlider or (elem.Element and elem.Element.ConnectedSlider)
                        if slElem or (item.Slider and type(item.Slider) == "table") then
                            local slCfg = type(item.Slider) == "table" and item.Slider or {}
                            local slId = slCfg.Id or slCfg.SaveKey or (id .. "Volume")
                            local slDef = slCfg.Default or (slElem and slElem.GetValue and slElem:GetValue()) or 100
                            local slCb = slCfg.Callback or slCfg.callback or slCfg.OnChanged
                            local slWrapper = {
                                Value = slDef,
                                Element = slElem,
                                _callback = slCb,
                                SetValue = function(s, v, trigger)
                                    s.Value = v
                                    pcall(function()
                                        if slElem and slElem.SetValue then
                                            slElem:SetValue(v, trigger ~= false)
                                        end
                                    end)
                                end,
                                GetValue = function(s)
                                    return (slElem and slElem.GetValue) and slElem:GetValue() or s.Value
                                end,
                                OnChanged = function(s, callback)
                                    s._callback = callback
                                    return s
                                end
                            }
                            if slId then Options[slId] = slWrapper end
                            Options[id .. "Volume"] = slWrapper
                            Options[id .. "_Slider"] = slWrapper
                            if slCfg.Title then Options[slCfg.Title] = slWrapper end
                        end
                    end
                end
                return results
            end
        }
        setmetatable(adapter, {
            __index = function(t, k)
                if rawTab and rawTab[k] then
                    return function(self, ...)
                        return rawTab[k](rawTab, ...)
                    end
                end
                return nil
            end
        })
        return adapter
    end

    local Tabs = {
        Main     = createTabAdapter(mdTabs.Main),
        Autofarm = createTabAdapter(mdTabs.Autofarm),
        Player   = createTabAdapter(mdTabs.Player),
        Murderer = createTabAdapter(mdTabs.Murderer),
        Sheriff  = createTabAdapter(mdTabs.Sheriff),
        Sounds   = createTabAdapter(mdTabs.Sounds),
        Visuals  = createTabAdapter(mdTabs.Visuals),
        Animations = createTabAdapter(mdTabs.Animations),
        World    = createTabAdapter(mdTabs.World),
        Camera   = createTabAdapter(mdTabs.Camera),
        Webhook  = createTabAdapter(mdTabs.Webhook),
        Settings = createTabAdapter(mdTabs.Settings),
    }

    -- construct automated farming controls
    Tabs.Autofarm:AddSection("Farm")

    Tabs.Autofarm:AddToggle("AutofarmEnabled", {
        Title = "Autofarm",
        Default = false,
        Slider = {
            Title = "Tween speed",
            Min = 5,
            Max = 25,
            Default = 22,
            Increment = 0.5,
            Rounding = 1,
            Suffix = " studs/s",
            Callback = function(val)
                state.autofarmTweenSpeed = val
            end
        },
        Callback = function(v)
            state.autofarmEnabled = v
            if v then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    state.autofarmSavedCFrame = hrp.CFrame
                end

                state.tweenRoundTeleported = false
                state.hasTeleportedToLobby = false
                state.roundsPassed = 0
                state.totalCoinsFarmed = 0
                state.startTime = tick()
                state.lastWebhookSent = tick()
                state.currentTaskStatus = "Starting..."
                log("Autofarm Started (" .. state.autofarmMode .. ")")

            else
                state.currentTaskStatus = "Stopped"
                log("Autofarm Stopped")
                stopAllMovement()
                stopTween()
                -- restore player position after disabling farm
                if state.autofarmSavedCFrame then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pcall(function()
                            hrp.Anchored = false
                            hrp.CFrame = state.autofarmSavedCFrame
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                    end
                    state.autofarmSavedCFrame = nil
                end
            end
        end
    })

    Tabs.Autofarm:AddDropdown("AutofarmMode", {
        Title = "Autofarm mode",
        Values = {"Coin", "Wins", "Teleport (unreliable)"},
        Default = "Coin",
        Callback = function(v)
            state.autofarmMode = v
            log("Autofarm mode set to: " .. v)
        end
    })

    Tabs.Autofarm:AddDropdown("AfterFarmAction", {
        Title = "After farm",
        Values = {"Farm exp", "End round", "Reset"},
        Default = "Farm exp",
        Callback = function(val)
            state.afterFarmAction = val
            state.roundEndFling = (val == "End round")
            log("After farm action: " .. val)
        end
    })

    Tabs.Autofarm:AddSection("Auto open crates")
    Tabs.Autofarm:AddToggle("AutoOpenCratesEnabled", {
        Title = "Auto open crates",
        Default = false,
        Callback = function(v)
            state.autoOpenCratesEnabled = v
            log("Auto open crates: " .. (v and "Enabled" or "Disabled"))
        end
    })

    Tabs.Autofarm:AddDropdown("SelectedCrateType", {
        Title = "Crate box type",
        Values = {"MysteryBox1", "MysteryBox2", "KnifeBox1", "KnifeBox2", "KnifeBox3", "KnifeBox4", "KnifeBox5", "GunBox1", "GunBox2", "GunBox3"},
        Default = "MysteryBox1",
        Callback = function(v)
            state.selectedCrateType = v
        end
    })



    -- construct decorative china hat geometry 
    local chinaHatConfig = {
        enabled = false,
        colorMode = "Normal",
        color1 = Color3.fromRGB(255, 0, 100),
        color2 = Color3.fromRGB(0, 200, 255),
        color = Color3.fromRGB(255, 0, 100),
        transparency = 0.3,
        alwaysOnTop = false,
        selfOnly = true,
        height = 0.6,
        radius = 1.2,
        heightOffset = 2.0
    }

    local chinaHatAdornments = {}
    local chinaHatConnections = {}
    local chinaHatPlayerAddedConn = nil
    local chinaHatPlayerRemovingConn = nil

    local function getHatColor()
        local color = getColor(chinaHatConfig.colorMode, chinaHatConfig.color1, chinaHatConfig.color2)
        if color.R <= 0.005 and color.G <= 0.005 and color.B <= 0.005 then
            return Color3.fromRGB(1, 1, 1)
        end
        return color
    end

    local function removeHat(player, char)
        chinaHatAdornments[player] = nil
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local adornment = hrp:FindFirstChild("ChinaHat")
            if adornment then pcall(function() adornment:Destroy() end) end
        end
    end

    local function applyHat(player, char)
        if not chinaHatConfig.enabled then return end
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
    
        local existing = hrp:FindFirstChild("ChinaHat")
        if existing then pcall(function() existing:Destroy() end) end
    
        if not chinaHatConfig.enabled then return end

        local adornment = Instance.new("ConeHandleAdornment")
        adornment.Name = "ChinaHat"
        adornment.Height = chinaHatConfig.height
        adornment.Radius = chinaHatConfig.radius
        adornment.Transparency = chinaHatConfig.transparency
        adornment.AlwaysOnTop = chinaHatConfig.alwaysOnTop
        adornment.Adornee = hrp
        adornment.CFrame = CFrame.new(0, chinaHatConfig.heightOffset, 0) * CFrame.Angles(math.rad(90), 0, 0)
        adornment.Parent = hrp
        adornment.Color3 = getHatColor()

        chinaHatAdornments[player] = adornment
    end

    local function setupHatForPlayer(player)
        if chinaHatConnections[player] then
            pcall(function() chinaHatConnections[player]:Disconnect() end)
            chinaHatConnections[player] = nil
        end
        local function onCharAdded(char)
            if chinaHatConfig.enabled then
                if player == LocalPlayer or not chinaHatConfig.selfOnly then
                    applyHat(player, char)
                end
            else
                removeHat(player, char)
            end
        end
        if player.Character and chinaHatConfig.enabled then
            if player == LocalPlayer or not chinaHatConfig.selfOnly then
                applyHat(player, player.Character)
            end
        end
        chinaHatConnections[player] = player.CharacterAdded:Connect(onCharAdded)
    end

    local function removeHatForPlayer(player)
        if chinaHatConnections[player] then
            pcall(function() chinaHatConnections[player]:Disconnect() end)
            chinaHatConnections[player] = nil
        end
        chinaHatAdornments[player] = nil
        if player.Character then
            removeHat(player, player.Character)
        end
    end

    local function updateHatColors()
        if not chinaHatConfig.enabled then return end
        local mainColor = getHatColor()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hat = hrp:FindFirstChild("ChinaHat")
                    if hat then hat.Color3 = mainColor end
                end
            end
        end
    end

    local function updateHatProps()
        if not chinaHatConfig.enabled then return end
        local color = getHatColor()
        local function applyProps(player, char)
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local adornment = hrp and hrp:FindFirstChild("ChinaHat")
            if adornment then
                adornment.Color3 = color
                adornment.Transparency = chinaHatConfig.transparency
                adornment.AlwaysOnTop = chinaHatConfig.alwaysOnTop
                adornment.Height = chinaHatConfig.height
                adornment.Radius = chinaHatConfig.radius
                adornment.CFrame = CFrame.new(0, chinaHatConfig.heightOffset, 0) * CFrame.Angles(math.rad(90), 0, 0)
            end
        end
    
        if LocalPlayer.Character then applyProps(LocalPlayer, LocalPlayer.Character) end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not chinaHatConfig.selfOnly then
                    applyProps(p, p.Character)
                else
                    removeHat(p, p.Character)
                end
            end
        end
    end

    local function stopChinaHat()
        chinaHatConfig.enabled = false
        if chinaHatPlayerAddedConn then
            pcall(function() chinaHatPlayerAddedConn:Disconnect() end)
            chinaHatPlayerAddedConn = nil
        end
        if chinaHatPlayerRemovingConn then
            pcall(function() chinaHatPlayerRemovingConn:Disconnect() end)
            chinaHatPlayerRemovingConn = nil
        end
        for p, conn in pairs(chinaHatConnections) do
            if conn then pcall(function() conn:Disconnect() end) end
            if p and p.Character then removeHat(p, p.Character) end
        end
        chinaHatConnections = {}
        chinaHatAdornments = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then removeHat(p, p.Character) end
        end
    end

    local function startChinaHat()
        stopChinaHat()
        chinaHatConfig.enabled = true
        if chinaHatConfig.selfOnly then
            setupHatForPlayer(LocalPlayer)
            if LocalPlayer.Character then applyHat(LocalPlayer, LocalPlayer.Character) end
        else
            for _, p in pairs(Players:GetPlayers()) do
                setupHatForPlayer(p)
                if p.Character then applyHat(p, p.Character) end
            end
            chinaHatPlayerAddedConn = Players.PlayerAdded:Connect(setupHatForPlayer)
            chinaHatPlayerRemovingConn = Players.PlayerRemoving:Connect(removeHatForPlayer)
        end
    end

    trackConnection(Players.PlayerRemoving:Connect(function(plr)
        removeHatForPlayer(plr)
    end))

    registerCleanupHook(function()
        stopChinaHat()
    end)

    -- construct cosmetic wing meshes 
    local wingsConfig = {
        enabled = false,
        colorMode = "Normal",
        color1 = Color3.fromRGB(0, 255, 170),
        color2 = Color3.fromRGB(170, 0, 255),
        color = Color3.fromRGB(0, 255, 170),
        transparency = 0.55,
        speed = 3.5,
        size = 0.59,
        posX = 1.41,
        posY = 2.12,
        posZ = 1.41,
        selfOnly = true
    }

    local wingsParts = {}
    local wingsConnections = {}
    local wingsPlayerAddedConn = nil
    local wingsPlayerRemovingConn = nil

    local function removeWings(player, char)
        if wingsParts[player] then
            local w = wingsParts[player]
            if w.left then pcall(function() w.left:Destroy() end) end
            if w.right then pcall(function() w.right:Destroy() end) end
            wingsParts[player] = nil
        end
        if char then
            local lw = char:FindFirstChild("_LeftWing") or char:FindFirstChild("LeftWing")
            if lw then pcall(function() lw:Destroy() end) end
            local rw = char:FindFirstChild("_RightWing") or char:FindFirstChild("RightWing")
            if rw then pcall(function() rw:Destroy() end) end
        end
    end

    local function applyWings(player, char)
        if not wingsConfig.enabled then return end
        if not char then return end
        local root = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        removeWings(player, char)

        if not wingsConfig.enabled then return end

        local curColor = getColor(wingsConfig.colorMode, wingsConfig.color1, wingsConfig.color2)

        local leftPart = Instance.new("Part")
        leftPart.Name = "LeftWing"
        leftPart.Size = Vector3.new(1, 1, 1)
        leftPart.CanCollide = false
        leftPart.CanQuery = false
        leftPart.CanTouch = false
        leftPart.Anchored = true
        leftPart.Material = Enum.Material.Neon
        leftPart.Color = curColor
        leftPart.Transparency = wingsConfig.transparency
        leftPart.Parent = char

        local leftMesh = Instance.new("SpecialMesh")
        leftMesh.MeshType = Enum.MeshType.FileMesh
        leftMesh.MeshId = "rbxassetid://125496490342257"
        leftMesh.TextureId = ""
        leftMesh.Scale = Vector3.new(wingsConfig.size, wingsConfig.size, wingsConfig.size)
        leftMesh.Parent = leftPart

        local lightL = Instance.new("PointLight")
        lightL.Name = "WingLight"
        lightL.Color = curColor
        lightL.Range = 8
        lightL.Brightness = 2.14
        lightL.Parent = leftPart

        local rightPart = Instance.new("Part")
        rightPart.Name = "RightWing"
        rightPart.Size = Vector3.new(1, 1, 1)
        rightPart.CanCollide = false
        rightPart.CanQuery = false
        rightPart.CanTouch = false
        rightPart.Anchored = true
        rightPart.Material = Enum.Material.Neon
        rightPart.Color = curColor
        rightPart.Transparency = wingsConfig.transparency
        rightPart.Parent = char

        local rightMesh = Instance.new("SpecialMesh")
        rightMesh.MeshType = Enum.MeshType.FileMesh
        rightMesh.MeshId = "rbxassetid://127905516694871"
        rightMesh.TextureId = ""
        rightMesh.Scale = Vector3.new(wingsConfig.size, wingsConfig.size, wingsConfig.size)
        rightMesh.Parent = rightPart

        local lightR = Instance.new("PointLight")
        lightR.Name = "WingLight"
        lightR.Color = curColor
        lightR.Range = 8
        lightR.Brightness = 2.14
        lightR.Parent = rightPart

        local function createFeatherEmitter(parentPart)
            local pe = Instance.new("ParticleEmitter")
            pe.Name = "FeatherEmitter"
            pe.Texture = "http://www.roblox.com/asset/?id=87991277160964"
            pe.Rate = 1.2
            pe.Speed = NumberRange.new(0.3, 0.75)
            pe.VelocityInheritance = 0.05
            pe.Acceleration = Vector3.new(0, -0.75, 0)
            pe.Drag = 1.2
            pe.Lifetime = NumberRange.new(5.0, 7.0)
            pe.Rotation = NumberRange.new(0, 360)
            pe.RotSpeed = NumberRange.new(-70, 70)
            pe.LightEmission = 0.71
            pe.LightInfluence = 0.0
            pe.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(0.8, 0.4),
                NumberSequenceKeypoint.new(1, 0)
            })
            pe.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(0.8, 0.3),
                NumberSequenceKeypoint.new(1, 1)
            })
            pe.Color = ColorSequence.new(curColor)
            pe.Parent = parentPart
            return pe
        end

        local emitterL = createFeatherEmitter(leftPart)
        local emitterR = createFeatherEmitter(rightPart)

        wingsParts[player] = {
            left = leftPart,
            right = rightPart,
            emitterL = emitterL,
            emitterR = emitterR,
            lightL = lightL,
            lightR = lightR
        }
    end

    local function setupWingsForPlayer(player)
        if wingsConnections[player] then
            pcall(function() wingsConnections[player]:Disconnect() end)
            wingsConnections[player] = nil
        end
        local function onCharAdded(char)
            if wingsConfig.enabled then
                if player == LocalPlayer or not wingsConfig.selfOnly then
                    applyWings(player, char)
                end
            else
                removeWings(player, char)
            end
        end
        if player.Character and wingsConfig.enabled then
            if player == LocalPlayer or not wingsConfig.selfOnly then
                applyWings(player, player.Character)
            end
        end
        wingsConnections[player] = player.CharacterAdded:Connect(onCharAdded)
    end

    local function removeWingsForPlayer(player)
        if wingsConnections[player] then
            pcall(function() wingsConnections[player]:Disconnect() end)
            wingsConnections[player] = nil
        end
        if wingsParts[player] then
            local w = wingsParts[player]
            if w.left then pcall(function() w.left:Destroy() end) end
            if w.right then pcall(function() w.right:Destroy() end) end
            wingsParts[player] = nil
        end
        if player.Character then
            removeWings(player, player.Character)
        end
    end

    local function stopWings()
        wingsConfig.enabled = false
        if wingsPlayerAddedConn then
            pcall(function() wingsPlayerAddedConn:Disconnect() end)
            wingsPlayerAddedConn = nil
        end
        if wingsPlayerRemovingConn then
            pcall(function() wingsPlayerRemovingConn:Disconnect() end)
            wingsPlayerRemovingConn = nil
        end
        for p, conn in pairs(wingsConnections) do
            if conn then pcall(function() conn:Disconnect() end) end
            if p and p.Character then removeWings(p, p.Character) end
        end
        wingsConnections = {}
        wingsParts = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then removeWings(p, p.Character) end
        end
    end

    local function startWings()
        stopWings()
        wingsConfig.enabled = true
        if wingsConfig.selfOnly then
            setupWingsForPlayer(LocalPlayer)
            if LocalPlayer.Character then applyWings(LocalPlayer, LocalPlayer.Character) end
        else
            for _, p in pairs(Players:GetPlayers()) do
                setupWingsForPlayer(p)
                if p.Character then applyWings(p, p.Character) end
            end
            wingsPlayerAddedConn = Players.PlayerAdded:Connect(setupWingsForPlayer)
            wingsPlayerRemovingConn = Players.PlayerRemoving:Connect(removeWingsForPlayer)
        end
    end

    local function updateWings()
        if not wingsConfig.enabled then return end
        local curColor = getColor(wingsConfig.colorMode, wingsConfig.color1, wingsConfig.color2)
        for player, w in pairs(wingsParts) do
            if w.left and w.left.Parent then
                w.left.Color = curColor
                w.left.Transparency = wingsConfig.transparency
                if w.emitterL then w.emitterL.Color = ColorSequence.new(curColor) end
                if w.lightL then w.lightL.Color = curColor end
            end
            if w.right and w.right.Parent then
                w.right.Color = curColor
                w.right.Transparency = wingsConfig.transparency
                if w.emitterR then w.emitterR.Color = ColorSequence.new(curColor) end
                if w.lightR then w.lightR.Color = curColor end
            end
        end
    end

    trackConnection(Players.PlayerRemoving:Connect(function(plr)
        removeWingsForPlayer(plr)
    end))

    registerCleanupHook(function()
        stopWings()
    end)

    -- rotate character to disrupt incoming aim 
    spinbotConn = nil
    local function stopSpinbot()
        if spinbotConn then
            spinbotConn:Disconnect()
            spinbotConn = nil
        end
    end
    local function startSpinbot()
        stopSpinbot()
        spinbotConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(state.spinbotSpeed or 30), 0)
            end)
        end)
    end

    local spinbotMonitorThread = task.spawn(function()
        while not state.unloaded do
            if state.spinbotEnabled and not spinbotConn then
                startSpinbot()
            elseif not state.spinbotEnabled and spinbotConn then
                stopSpinbot()
            end
            task.wait(0.5)
        end
    end)
    trackThread(spinbotMonitorThread)

    -- override default character movement animations
    local customAnimationConfig = {
        enabled = false,
        preset = "Mage",
        customPackId = "",
    }

    local animIdCache = {}

    local function extractTrueAnimationId(rawAssetId)
        local numId = tostring(rawAssetId or ""):match("%d+")
        if not numId or numId == "" then return rawAssetId end
        if animIdCache[numId] then
            return animIdCache[numId]
        end

        local foundId = nil
        local ok1, objs = pcall(function()
            return game:GetObjects("rbxassetid://" .. numId)
        end)
        if ok1 and objs and #objs > 0 then
            for _, rootObj in ipairs(objs) do
                for _, desc in ipairs(rootObj:GetDescendants()) do
                    if desc:IsA("Animation") and desc.AnimationId and desc.AnimationId ~= "" then
                        foundId = desc.AnimationId
                        break
                    end
                end
                if not foundId and rootObj:IsA("Animation") and rootObj.AnimationId ~= "" then
                    foundId = rootObj.AnimationId
                end
                if foundId then break end
            end
            for _, rootObj in ipairs(objs) do
                pcall(function() rootObj:Destroy() end)
            end
        end

        if not foundId then
            local ok2, model = pcall(function()
                return game:GetService("InsertService"):LoadAsset(tonumber(numId))
            end)
            if ok2 and model then
                for _, desc in ipairs(model:GetDescendants()) do
                    if desc:IsA("Animation") and desc.AnimationId and desc.AnimationId ~= "" then
                        foundId = desc.AnimationId
                        break
                    end
                end
                if not foundId and model:IsA("Animation") and model.AnimationId ~= "" then
                    foundId = model.AnimationId
                end
                pcall(function() model:Destroy() end)
            end
        end

        if foundId and foundId ~= "" then
            animIdCache[numId] = foundId
            return foundId
        end

        animIdCache[numId] = "rbxassetid://" .. numId
        return "rbxassetid://" .. numId
    end

    local presetAnimationPacks = {
        ["Mage"] = {
            id = "63",
            anims = {
                idle = "rbxassetid://10921144709",
                walk = "rbxassetid://10921152678",
                run = "rbxassetid://10921148209",
                jump = "rbxassetid://10921149743",
                fall = "rbxassetid://10921148939",
                climb = "rbxassetid://10921143404",
                swim = "rbxassetid://10921150788",
            }
        },
        ["Vampire"] = {
            id = "33",
            anims = {
                idle = "rbxassetid://10921315373",
                walk = "rbxassetid://10921326949",
                run = "rbxassetid://10921320299",
                jump = "rbxassetid://10921322186",
                fall = "rbxassetid://10921321317",
                climb = "rbxassetid://10921314188",
                swim = "rbxassetid://10921324408",
            }
        },
        ["Zombie"] = {
            id = "80",
            anims = {
                idle = "rbxassetid://10921344533",
                walk = "rbxassetid://10921355261",
                run = "rbxassetid://616163682",
                jump = "rbxassetid://10921351278",
                fall = "rbxassetid://10921350320",
                climb = "rbxassetid://10921343576",
                swim = "rbxassetid://10921352344",
            }
        },
        ["Adidas"] = {
            id = "427999",
            anims = {
                idle = "rbxassetid://18537376492",
                walk = "rbxassetid://18537392113",
                run = "rbxassetid://18537384940",
                jump = "rbxassetid://18537380791",
                fall = "rbxassetid://18537367238",
                climb = "rbxassetid://18537363391",
                swim = "rbxassetid://18537389531",
            }
        },
        ["Elder"] = {
            id = "48",
            anims = {
                idle = "rbxassetid://10921101664",
                walk = "rbxassetid://10921111375",
                run = "rbxassetid://10921104374",
                jump = "rbxassetid://10921107367",
                fall = "rbxassetid://10921105765",
                climb = "rbxassetid://10921100400",
                swim = "rbxassetid://10921108971",
            }
        },
        ["Dumb Dumb"] = {
            id = "3290671274997",
            containerIds = {
                idle = "105004614594851",
                walk = "82802187852670",
                run = "94065959215233",
                jump = "95678097589635",
                fall = "139471194330271",
                climb = "74141666174470",
                swim = "128952343229653",
            }
        }
    }

    local presetPacksById = {
        ["63"] = presetAnimationPacks["Mage"],
        ["33"] = presetAnimationPacks["Vampire"],
        ["80"] = presetAnimationPacks["Zombie"],
        ["427999"] = presetAnimationPacks["Adidas"],
        ["48"] = presetAnimationPacks["Elder"],
        ["3290671274997"] = presetAnimationPacks["Dumb Dumb"],
    }

    local dynamicPackCache = {}

    local function resolveAnimationPack(packId)
        local rawId = tostring(packId or ""):match("%d+")
        if not rawId or rawId == "" then return nil end

        if presetPacksById[rawId] then
            local pack = presetPacksById[rawId]
            if pack.anims then return pack.anims end
            if pack.containerIds then
                local animMap = {}
                for action, cId in pairs(pack.containerIds) do
                    animMap[action] = extractTrueAnimationId(cId)
                end
                pack.anims = animMap
                return animMap
            end
        end
        if dynamicPackCache[rawId] then
            return dynamicPackCache[rawId]
        end

        local AssetService = game:GetService("AssetService")
        local success, details = pcall(function()
            return AssetService:GetBundleDetailsAsync(tonumber(rawId))
        end)

        local animMap = {}
        if success and details and details.Items then
            for _, item in ipairs(details.Items) do
                if item.Type == "Asset" then
                    local itemName = string.lower(item.Name or "")
                    local assetId = item.Id
                    local animId = extractTrueAnimationId(assetId)

                    if itemName:find("idle") then
                        animMap.idle = animId
                    elseif itemName:find("walk") then
                        animMap.walk = animId
                    elseif itemName:find("run") then
                        animMap.run = animId
                    elseif itemName:find("jump") then
                        animMap.jump = animId
                    elseif itemName:find("fall") then
                        animMap.fall = animId
                    elseif itemName:find("climb") then
                        animMap.climb = animId
                    elseif itemName:find("swim") then
                        animMap.swim = animId
                    end
                end
            end
        end

        if not next(animMap) then
            pcall(function()
                local objs = game:GetObjects("rbxassetid://" .. rawId)
                if objs and #objs > 0 then
                    for _, desc in ipairs(objs[1]:GetDescendants()) do
                        if desc:IsA("Animation") and desc.AnimationId and desc.AnimationId ~= "" then
                            local n = string.lower(desc.Name)
                            for _, action in ipairs({"idle", "walk", "run", "jump", "fall", "climb", "swim"}) do
                                if n:find(action) and not animMap[action] then
                                    animMap[action] = desc.AnimationId
                                end
                            end
                        end
                    end
                end
            end)
        end

        if next(animMap) then
            dynamicPackCache[rawId] = animMap
            return animMap
        end
        return nil
    end

    local originalAnimations = {}
    local isCustomAnimActive = false

    local function storeOriginalAnimations(animateScript)
        if not animateScript then return end
        originalAnimations = {}
        for _, action in ipairs({"idle", "walk", "run", "jump", "fall", "climb", "swim"}) do
            local folder = animateScript:FindFirstChild(action)
            if folder then
                originalAnimations[action] = {}
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Animation") then
                        table.insert(originalAnimations[action], {
                            Name = child.Name,
                            Id = child.AnimationId
                        })
                    end
                end
            end
        end
    end

    local function applyCustomAnimations()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        if not customAnimationConfig.enabled then
            if isCustomAnimActive and next(originalAnimations) then
                for action, animList in pairs(originalAnimations) do
                    local folder = animate:FindFirstChild(action)
                    if folder then
                        for _, data in ipairs(animList) do
                            local existing = folder:FindFirstChild(data.Name)
                            if existing and existing:IsA("Animation") then
                                existing.AnimationId = data.Id
                            end
                        end
                    end
                end
                if hum then
                    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                        pcall(function() track:Stop(0) end)
                    end
                end
                isCustomAnimActive = false
            end
            return
        end

        if not isCustomAnimActive and not next(originalAnimations) then
            storeOriginalAnimations(animate)
        end

        local animMap = nil
        local sel = customAnimationConfig.preset or "Mage"
        if sel ~= "Custom" then
            local pack = presetAnimationPacks[sel]
            if not pack then
                for name, data in pairs(presetAnimationPacks) do
                    if sel:find(name, 1, true) or sel:find(data.id, 1, true) then
                        pack = data
                        break
                    end
                end
            end
            if pack then
                if pack.anims then
                    animMap = pack.anims
                elseif pack.containerIds then
                    animMap = {}
                    for action, cId in pairs(pack.containerIds) do
                        animMap[action] = extractTrueAnimationId(cId)
                    end
                    pack.anims = animMap
                end
            end
        else
            animMap = resolveAnimationPack(customAnimationConfig.customPackId)
        end

        if not animMap then return end

        for action, animId in pairs(animMap) do
            local folder = animate:FindFirstChild(action)
            if folder then
                local found = false
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Animation") then
                        child.AnimationId = animId
                        found = true
                    end
                end
                if not found then
                    local a = Instance.new("Animation")
                    a.Name = action .. "Anim"
                    a.AnimationId = animId
                    a.Parent = folder
                end
            end
        end

        isCustomAnimActive = true
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
    end

    trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        originalAnimations = {}
        isCustomAnimActive = false
        if customAnimationConfig.enabled then
            task.spawn(function()
                local animate = char:WaitForChild("Animate", 6)
                if animate then
                    task.wait(0.2)
                    applyCustomAnimations()
                end
            end)
        end
    end))

    -- mitigate aggressive physics impulses from other players
    local antiFlingConn = nil
    local antiFlingHeartbeatConn = nil
    local activeNoCollisionConstraints = {}

    -- cache player parts and lists to avoid allocation overhead
    local antiFlingPartCache = {}
    local antiFlingPlayers = {}
    local antiFlingHbTick = 0

    local function rebuildPlayerList()
        table.clear(antiFlingPlayers)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(antiFlingPlayers, plr)
            end
        end
    end

    local function cachePlayerParts(plr)
        local char = plr.Character
        if not char then antiFlingPartCache[plr] = nil; return end
        local parts = {}
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                parts[#parts + 1] = d
            end
        end
        antiFlingPartCache[plr] = parts
    end

    local function clearNoCollisionConstraints()
        for _, c in ipairs(activeNoCollisionConstraints) do
            pcall(function() c:Destroy() end)
        end
        table.clear(activeNoCollisionConstraints)
    end

    local function pruneNoCollisionConstraints()
        local valid = {}
        for _, c in ipairs(activeNoCollisionConstraints) do
            if c and c.Parent and c.Part0 and c.Part1 and c.Part0.Parent and c.Part1.Parent then
                valid[#valid + 1] = c
            else
                if c then pcall(function() c:Destroy() end) end
            end
        end
        activeNoCollisionConstraints = valid
    end

    local function resetCollisions()
        clearNoCollisionConstraints()
        for _, plr in ipairs(antiFlingPlayers) do
            local parts = antiFlingPartCache[plr]
            if parts then
                for _, part in ipairs(parts) do
                    if part and part.Parent then
                        part.CanCollide = true
                    end
                end
            end
        end
    end

    local function updateAntiFling()
        if antiFlingConn then
            pcall(function() antiFlingConn:Disconnect() end)
            antiFlingConn = nil
        end
        if antiFlingHeartbeatConn then
            pcall(function() antiFlingHeartbeatConn:Disconnect() end)
            antiFlingHeartbeatConn = nil
        end

        if state.antiFlingEnabled and not state.unloaded then
            -- refresh player caches when anti-fling turns on
            rebuildPlayerList()
            for _, plr in ipairs(antiFlingPlayers) do
                cachePlayerParts(plr)
            end

            local lastWasFlinging = false

            -- disable part collisions and attach constraints using cached lists
            antiFlingConn = RunService.Stepped:Connect(function()
                if state.unloaded or not state.antiFlingEnabled then
                    antiFlingConn:Disconnect(); antiFlingConn = nil
                    resetCollisions(); return
                end

                local isFlinging = state.isFlinging == true
                if isFlinging then
                    if not lastWasFlinging then
                        lastWasFlinging = true
                        resetCollisions()
                    end
                    return
                end
                lastWasFlinging = false

                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

                -- disable collision on local character limbs
                if myChar then
                    for _, part in ipairs(myChar:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = false
                        end
                    end
                end

                -- disable collision on adjacent player parts
                for _, plr in ipairs(antiFlingPlayers) do
                    local char = plr.Character
                    if not char then continue end

                    local parts = antiFlingPartCache[plr]
                    if parts then
                        for _, part in ipairs(parts) do
                            if part and part.Parent then
                                part.CanCollide = false
                            end
                        end
                    end

                    -- attach pairwise no-collision constraints
                    local oHrp = char:FindFirstChild("HumanoidRootPart")
                    if myHrp and oHrp then
                        local existing = oHrp:FindFirstChild("AntiFlingConstraint")
                        if existing and existing.Part0 == myHrp then
                            -- retain established constraint without recreating
                        else
                            if existing then existing:Destroy() end
                            local constraint = Instance.new("NoCollisionConstraint")
                            constraint.Name = "AntiFlingConstraint"
                            constraint.Part0 = myHrp
                            constraint.Part1 = oHrp
                            constraint.Parent = oHrp
                            activeNoCollisionConstraints[#activeNoCollisionConstraints + 1] = constraint
                        end
                    end
                end

                if #activeNoCollisionConstraints > 40 then
                    pruneNoCollisionConstraints()
                end
            end)

            -- throttle physics dampening to reduce cpu load
            antiFlingHeartbeatConn = RunService.Heartbeat:Connect(function()
                if state.unloaded or not state.antiFlingEnabled then
                    antiFlingHeartbeatConn:Disconnect(); antiFlingHeartbeatConn = nil
                    return
                end
                if state.isFlinging then return end

                antiFlingHbTick = antiFlingHbTick + 1

                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

                -- cancel abnormal external velocity on local root
                if myHrp and not state.flightEnabled then
                    local lv = myHrp.AssemblyLinearVelocity
                    local av = myHrp.AssemblyAngularVelocity
                    if lv.Magnitude > 65 then
                        myHrp.AssemblyLinearVelocity = Vector3.new(
                            math.clamp(lv.X, -25, 25),
                            math.clamp(lv.Y, -35, 35),
                            math.clamp(lv.Z, -25, 25)
                        )
                    end
                    if av.Magnitude > 25 then
                        myHrp.AssemblyAngularVelocity = Vector3.zero
                    end
                end

                -- keep character upright and prevent knockdown
                if myHum and myHum.Health > 0 then
                    local s = myHum:GetState()
                    if s == Enum.HumanoidStateType.FallingDown
                    or s == Enum.HumanoidStateType.Ragdoll
                    or s == Enum.HumanoidStateType.PlatformStanding then
                        myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        myHum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end

                -- damp erratic physics spikes on adjacent characters
                if antiFlingHbTick % 3 ~= 0 then return end
                if not myHrp then return end
                local myPos = myHrp.Position
                for _, plr in ipairs(antiFlingPlayers) do
                    if plr.Character then
                        local oHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - myPos).Magnitude < 35 then
                            local lv = oHrp.AssemblyLinearVelocity
                            local av = oHrp.AssemblyAngularVelocity
                            if lv.Magnitude > 30 or av.Magnitude > 20 then
                                pcall(function()
                                    oHrp.AssemblyLinearVelocity = Vector3.zero
                                    oHrp.AssemblyAngularVelocity = Vector3.zero
                                end)
                            end
                        end
                    end
                end
            end)
        else
            resetCollisions()
        end
    end

    registerCleanupHook(function()
        if antiFlingConn then
            pcall(function() antiFlingConn:Disconnect() end)
            antiFlingConn = nil
        end
        if antiFlingHeartbeatConn then
            pcall(function() antiFlingHeartbeatConn:Disconnect() end)
            antiFlingHeartbeatConn = nil
        end
        resetCollisions()
        table.clear(antiFlingPartCache)
        table.clear(antiFlingPlayers)
    end)

    -- keep player cache in sync with lobby changes
    trackConnection(Players.PlayerAdded:Connect(function(plr)
        rebuildPlayerList()
        trackPlayerConnection(plr, plr.CharacterAdded:Connect(function()
            task.wait(0.1)
            cachePlayerParts(plr)
        end))
    end))
    trackConnection(Players.PlayerRemoving:Connect(function(plr)
        antiFlingPartCache[plr] = nil
        rebuildPlayerList()
    end))
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            trackPlayerConnection(plr, plr.CharacterAdded:Connect(function()
                task.wait(0.1)
                cachePlayerParts(plr)
            end))
        end
    end

    trackConnection(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.3)
        updateAntiFling()
    end))

    -- run primary farming lifecycle 
    local collectedCoinsDebounce = {}
    local autofarmLoopThread = task.spawn(function()
        local wasFarmingLastTick = false
        while not state.unloaded do
            if state.autofarmEnabled then
                wasFarmingLastTick = true
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
            
                if hrp and hum and hum.Health > 0 then
                    -- collect coins via direct position updates
                    if state.autofarmMode == "Teleport (unreliable)" or state.autofarmMode == "Tp Coin Farm (unreliable)" then
                        state.hasTeleportedToLobby = false
                        makeAntiVoidPlate()

                        if not canFarmCoins() then
                            stopTween()
                            state.currentTaskStatus = "waiting in lobby"
                            tpToSafeSpawn(true)
                            task.wait(0.5)
                        else
                            setNoclip(true)

                            local _genv     = getgenv and getgenv() or {}
                            local touchFire = _genv.firetouchinterest
                                           or rawget(_G, "firetouchinterest")
                                           or (syn and syn.firetouchinterest)
                                           or firetouchinterest

                            local coins = scanAllCoins()
                            if #coins == 0 then
                                state.currentTaskStatus = "Farming coins"
                                task.wait(0.1)
                            else
                                -- teleport to random coin on round start before beginning route
                                if not state.tweenRoundTeleported or (hrp.Position - SAFEZONE_POS).Magnitude < 100 then
                                    local rndCoin = coins[math.random(1, #coins)]
                                    if rndCoin and rndCoin.Position then
                                        pcall(function()
                                            hrp.Anchored = false
                                            hrp.CFrame = CFrame.new(rndCoin.Position.X, rndCoin.Position.Y - 1.5, rndCoin.Position.Z)
                                            hrp.AssemblyLinearVelocity = Vector3.zero
                                            hrp.AssemblyAngularVelocity = Vector3.zero
                                        end)
                                        task.wait(0.05)
                                    end
                                    state.tweenRoundTeleported = true
                                    char = LocalPlayer.Character
                                    hrp  = char and char:FindFirstChild("HumanoidRootPart")
                                    if not hrp then return end
                                end

                                -- route path to nearest available coin
                                table.sort(coins, function(a, b)
                                    return (a.Position - hrp.Position).Magnitude
                                         < (b.Position - hrp.Position).Magnitude
                                end)
                                local coin    = coins[1]
                                local part    = coin.Part
                                local coinPos = coin.Position
                                -- position root part 1.5 studs below coin to touch hitbox
                                local tgtPos  = Vector3.new(coinPos.X, coinPos.Y - 1.5, coinPos.Z)
                                local targetCF = CFrame.new(tgtPos) * CFrame.Angles(math.rad(90), 0, 0)

                                state.currentTaskStatus = "Farming coins"

                                -- face upward to align pickup interaction
                                pcall(function()
                                    hrp.CFrame = targetCF
                                    hrp.Anchored = true
                                    hrp.AssemblyLinearVelocity  = Vector3.zero
                                    hrp.AssemblyAngularVelocity = Vector3.zero
                                end)

                                -- pulse interaction until server confirms collection
                                local deadline = tick() + 1.5
                                while tick() < deadline do
                                    if not canFarmCoins() then break end
                                    if not part.Parent then break end

                                    local ti = getCoinTouchInterest(part)
                                    -- advance immediately once coin disappears
                                    if not ti or not ti.Parent then
                                        break
                                    end

                                    if touchFire then
                                        local touchTarget = (ti and ti.Parent and ti.Parent:IsA("BasePart") and ti.Parent) or part
                                        pcall(function() touchFire(hrp, touchTarget, 0) end)
                                        pcall(function() touchFire(hrp, touchTarget, 1) end)
                                    end

                                    pcall(function()
                                        hrp.CFrame = targetCF
                                        hrp.Anchored = true
                                        hrp.AssemblyLinearVelocity  = Vector3.zero
                                        hrp.AssemblyAngularVelocity = Vector3.zero
                                    end)
                                    task.wait(0.05)
                                end

                                -- proceed without delay to maintain high collection rates
                                state.totalCoinsFarmed = state.totalCoinsFarmed + 1
                            end
                        end

                    -- collect coins via smooth tween movement
                    elseif state.autofarmMode == "Coin" then
                        state.hasTeleportedToLobby = false
                        makeAntiVoidPlate()

                        local function handleMurdererAction()
                            if not state.roundEndFling then return end
                            if not isPlayerAlive(LocalPlayer) then return end
                            local murderer = state.knifeHolder
                            if not murderer or not isMurdererAlive(murderer) then
                                murderer = getMurd()
                                if murderer and isMurdererAlive(murderer) then
                                    state.knifeHolder = murderer
                                end
                            end
                            local localRole = getPlayerRole(LocalPlayer)
                            local hasGun    = hasTool(LocalPlayer, "Gun")
                            local hasKnife  = (localRole == "Murderer") or hasTool(LocalPlayer, "Knife")
                            if hasKnife or hasGun or localRole == "Sheriff" then
                                killTarget()
                            else
                                while state.autofarmEnabled and isPlayerAlive(LocalPlayer) and isCoinBagVisible() do
                                    local m = state.knifeHolder
                                    if not m or not isMurdererAlive(m) then m = getMurd() end
                                    if not m or not isMurdererAlive(m) or m == LocalPlayer then break end
                                    state.currentTaskStatus = "Flinging murd"
                                    flingTarget(m, true, 4.0)
                                    if isMurdererAlive(m) then
                                        state.currentTaskStatus = "retrying fling..."
                                        task.wait(0.5)
                                    else
                                        break
                                    end
                                end
                            end
                        end

                        if not canFarmCoins() then
                            stopTween()
                            if isBagFull() then
                                if state.afterFarmAction == "End round" then
                                    tpToSafeSpawn(true)
                                    handleMurdererAction()
                                elseif state.afterFarmAction == "Reset" and isPlayerAlive(LocalPlayer) then
                                    state.currentTaskStatus = "resetting"
                                    tpToSafeSpawn(true)
                                    pcall(function()
                                        local c = LocalPlayer.Character
                                        local h = c and c:FindFirstChildOfClass("Humanoid")
                                        if h then h.Health = 0 end
                                    end)
                                else
                                    tpToSafeSpawn(true)
                                    state.currentTaskStatus = "bag full"
                                end
                            else
                                tpToSafeSpawn(true)
                                state.currentTaskStatus = "waiting in lobby"
                            end
                            task.wait(0.5)

                        elseif not isPlayerAlive(LocalPlayer) then
                            state.currentTaskStatus = "waiting for respawn"
                            task.wait(0.5)

                        else
                            local _genv     = getgenv and getgenv() or {}
                            local touchFire = _genv.firetouchinterest
                                           or rawget(_G, "firetouchinterest")
                                           or (syn and syn.firetouchinterest)
                                           or firetouchinterest
                            local minY = getMinAllowedY()
                            local COIN_FARM_SPEED = state.autofarmTweenSpeed or 22

                            pcall(function()
                                hrp.Anchored = false
                            end)

                            local function markCoinCollected(part)
                                if part and not collectedCoinsDebounce[part] then
                                    collectedCoinsDebounce[part] = true
                                    state.totalCoinsFarmed = state.totalCoinsFarmed + 1
                                end
                            end

                            local function getCoinContainer()
                                -- locate coin container within active map
                                local map = getActiveMap()
                                if map then
                                    local container = map:FindFirstChild("CoinContainer")
                                    if container then
                                        return container
                                    end
                                    for _, child in ipairs(map:GetChildren()) do
                                        local nestedContainer = child:FindFirstChild("CoinContainer")
                                        if nestedContainer then
                                            return nestedContainer
                                        end
                                    end
                                end

                                -- search workspace if map hierarchy differs
                                for _, child in ipairs(Workspace:GetChildren()) do
                                    if child:IsA("Model") or child:IsA("Folder") then
                                        local container = child:FindFirstChild("CoinContainer")
                                        if container and #container:GetChildren() > 0 then
                                            return container
                                        end
                                    end
                                end

                                return nil
                            end

                            local function scanCoins()
                                local coins = {}
                                local container = getCoinContainer()

                                if not container then
                                    return coins
                                end

                                for _, item in ipairs(container:GetChildren()) do
                                    local visual = item:FindFirstChild("CoinVisual")
                                    local coinServer = item:FindFirstChild("Coin_Server")
                                    local part = coinServer or (item:IsA("BasePart") and item) or item:FindFirstChildWhichIsA("BasePart")

                                    if part then
                                        local hasTouch = getCoinTouchInterest(part)
                                        local inDebounce = collectedCoinsDebounce[part]
                                        local yCheck = part.Position.Y >= minY

                                        local isNotCollected = true

                                        if visual and visual:IsA("BasePart") then
                                            isNotCollected = visual.Transparency >= 1
                                        elseif part.Transparency ~= 1 then
                                            isNotCollected = false
                                        end

                                        if part and yCheck and not inDebounce and hasTouch and isNotCollected then
                                            table.insert(coins, part)
                                        end
                                    end
                                end

                                return coins
                            end

                            local cachedCoins = {}
                            local nextCoinScan = 0
                            local function refreshCoinCache(force)
                                if not force and tick() < nextCoinScan then return false end
                                cachedCoins = scanCoins()
                                nextCoinScan = tick() + 0.5
                                return true
                            end

                            refreshCoinCache(true)

                            if #cachedCoins == 0 then
                                state.currentTaskStatus = "Farming coins (no coins found)"
                                task.wait(0.5)
                            else
                                if not state.tweenRoundTeleported then
                                    state.tweenRoundTeleported = true
                                    table.clear(collectedCoinsDebounce)
                                    refreshCoinCache(true)

                                    local firstCoin = cachedCoins[math.random(1, #cachedCoins)]
                                    if firstCoin then
                                        local firstPosition = Vector3.new(firstCoin.Position.X, firstCoin.Position.Y - 2.6, firstCoin.Position.Z)
                                        pcall(function()
                                            hrp.CFrame = CFrame.new(firstPosition) * CFrame.Angles(math.rad(90), 0, 0)
                                            hrp.AssemblyLinearVelocity = Vector3.zero
                                            hrp.AssemblyAngularVelocity = Vector3.zero
                                        end)
                                        task.wait(0.2)
                                    end
                                end

                                char = LocalPlayer.Character
                                hrp = char and char:FindFirstChild("HumanoidRootPart")
                                hum = char and char:FindFirstChildOfClass("Humanoid")
                                if hrp and hum then
                                    pcall(function()
                                        hum.PlatformStand = true
                                        hum:ChangeState(Enum.HumanoidStateType.PlatformStanding)
                                    end)
                                    setNoclip(true)

                                    local bodyVelocity = hrp:FindFirstChild("SafePlate")
                                    if not bodyVelocity then
                                        bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.Name = "SafePlate"
                                        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                                        bodyVelocity.Velocity = Vector3.zero
                                        bodyVelocity.Parent = hrp
                                    end

                                    state.currentTaskStatus = "Farming coins"
                                    while state.autofarmEnabled and canFarmCoins() do
                                        char = LocalPlayer.Character
                                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        local hum2 = char and char:FindFirstChildOfClass("Humanoid")
                                        if not hrp or not hum2 or hum2.Health <= 0 then break end

                                        refreshCoinCache()
                                        if #cachedCoins == 0 then
                                            task.wait(0.5)
                                            continue
                                        end

                                        table.sort(cachedCoins, function(a, b)
                                            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                                        end)

                                        local coinPart = cachedCoins[1]
                                        local targetPos = Vector3.new(coinPart.Position.X, coinPart.Position.Y - 2.6, coinPart.Position.Z)
                                        local flyDuration = (hrp.Position - targetPos).Magnitude / math.max(COIN_FARM_SPEED, 1)
                                        local flyStart = tick()
                                        local startPos = hrp.Position
                                        local touched = false
                                        local retarget = false

                                        while tick() - flyStart < flyDuration do
                                            if not state.autofarmEnabled or not canFarmCoins() then break end
                                            if not coinPart.Parent or not getCoinTouchInterest(coinPart) then
                                                retarget = true
                                                break
                                            end

                                            if refreshCoinCache() then
                                                local targetDistance = (coinPart.Position - hrp.Position).Magnitude
                                                for _, candidate in ipairs(cachedCoins) do
                                                    if candidate ~= coinPart
                                                        and candidate.Parent
                                                        and getCoinTouchInterest(candidate)
                                                        and (candidate.Position - hrp.Position).Magnitude + 0.5 < targetDistance then
                                                        retarget = true
                                                        break
                                                    end
                                                end
                                                if retarget then break end
                                            end

                                            local alpha = math.clamp((tick() - flyStart) / math.max(flyDuration, 0.001), 0, 1)
                                            local currentPos = startPos:Lerp(targetPos, alpha)
                                            pcall(function()
                                                hrp.CFrame = CFrame.new(currentPos) * CFrame.Angles(math.rad(90), 0, 0)
                                                hrp.AssemblyLinearVelocity = Vector3.zero
                                                hrp.AssemblyAngularVelocity = Vector3.zero
                                            end)

                                            if not touched and (hrp.Position - coinPart.Position).Magnitude <= 3.5 then
                                                touched = true
                                                if touchFire and coinPart.Parent and getCoinTouchInterest(coinPart) then
                                                    pcall(function() touchFire(hrp, coinPart, 0) end)
                                                    pcall(function() touchFire(hrp, coinPart, 1) end)
                                                    markCoinCollected(coinPart)
                                                end
                                            end
                                            task.wait()
                                        end

                                        if touched then
                                            refreshCoinCache(true)
                                        end

                                        if retarget then
                                            refreshCoinCache(true)
                                            task.wait()
                                        elseif not touched and coinPart.Parent and getCoinTouchInterest(coinPart) and touchFire then
                                            pcall(function() touchFire(hrp, coinPart, 0) end)
                                            pcall(function() touchFire(hrp, coinPart, 1) end)
                                            markCoinCollected(coinPart)
                                            refreshCoinCache(true)
                                        end
                                    end
                                end
                            end

                            -- reset tween forces on cycle completion
                            stopTween()
                            if isBagFull() then
                                if state.afterFarmAction == "End round" then
                                    tpToSafeSpawn(true)
                                    handleMurdererAction()
                                elseif state.afterFarmAction == "Reset" and isPlayerAlive(LocalPlayer) then
                                    state.currentTaskStatus = "resetting"
                                    tpToSafeSpawn(true)
                                    pcall(function()
                                        local c = LocalPlayer.Character
                                        local h = c and c:FindFirstChildOfClass("Humanoid")
                                        if h then h.Health = 0 end
                                    end)
                                else
                                    tpToSafeSpawn(true)
                                    state.currentTaskStatus = "bag full"
                                end
                            elseif not isCoinBagVisible() then
                                tpToSafeSpawn(true)
                                state.currentTaskStatus = "waiting in lobby"
                            end
                        end

                    -- auto-eliminate targets to secure match victory
                    elseif state.autofarmMode == "Wins" then
                        state.hasTeleportedToLobby = false
                        if state.roundActive then
                            state.currentTaskStatus = "Killing murd"
                            killTarget()
                            task.wait(0.5)
                        else
                            state.currentTaskStatus = "Idle"
                            tpToSafeSpawn()
                            task.wait(1)
                        end
                    end
                end
            else
                if wasFarmingLastTick then
                    wasFarmingLastTick = false
                    pcall(stopTween)
                    pcall(stopAllMovement)
                end
            end
            task.wait(0.1)
        end
    end)

    trackThread(autofarmLoopThread)

        -- clear map hazards that kill farming characters
    local killbrickThread = task.spawn(function()
        while not state.unloaded do
            pcall(function()
                local man2 = Workspace:FindFirstChild("Mansion2")
                if man2 then
                    local base = man2:FindFirstChild("Base")
                    if base then
                        local gp = base:FindFirstChild("GlitchProof")
                        if gp then
                            local killbr = gp:FindFirstChild("KillBrick")
                            if killbr then
                                pcall(function() killbr.CanTouch = false end)
                                for _, child in ipairs(killbr:GetChildren()) do
                                    if child:IsA("Script") or child:IsA("LocalScript") then
                                        pcall(function()
                                            child.Disabled = true
                                            child:Destroy()
                                        end)
                                    end
                                end
                                pcall(function() killbr:Destroy() end)
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
    trackThread(killbrickThread)

-- retrieve dropped sheriff gun to defend 
    local autoTakeGunThread = task.spawn(function()
        local lastAttemptedGunPart = nil  -- remember attempted drops to avoid position spam
        local lastAttemptTime = 0         -- space out pickup attempts to bypass anticheat checks

        while not state.unloaded do
            if state.autoTakeGun and isCoinBagVisible() and isPlayerAlive(LocalPlayer) then
                local localRole = getPlayerRole(LocalPlayer)
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                local aliveInMap = isPlayerAlive(LocalPlayer) and not isInLobby() and isCoinBagVisible()

                -- constrain gun retrieval to safe match conditions
                local isRemoteMethod = (state.autoTakeGunMethod == "Touch interest" or state.autoTakeGunMethod == "Remote")
                local shouldTakeGun = false
                if not state.autofarmEnabled then
                    shouldTakeGun = true
                elseif state.autofarmEnabled and (isRemoteMethod or (state.afterFarmAction == "End round" and localRole == "Innocent")) then
                    shouldTakeGun = true
                end

                local busyCoinFarming = state.autofarmEnabled and state.autofarmMode == "Coin" and not isBagFull() and not isRemoteMethod
                local alreadyHasGun = hasTool(LocalPlayer, "Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
                local alreadyHasKnife = hasTool(LocalPlayer, "Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))

                -- clear drop history once gun enters inventory
                if alreadyHasGun then
                    lastAttemptedGunPart = nil
                    lastAttemptTime = 0
                end

                if aliveInMap
                    and shouldTakeGun
                    and not busyCoinFarming
                    and localRole ~= "Murderer"
                    and not alreadyHasGun
                    and not alreadyHasKnife then

                    local gunPart = getDroppedGunPart()

                    -- bypass already attempted weapons
                    local now = tick()
                    local isNewGun = gunPart and gunPart ~= lastAttemptedGunPart
                    local cooldownExpired = (now - lastAttemptTime) >= 2.0

                    if gunPart and hrp and hum and (isNewGun or cooldownExpired) then
                        -- flag weapon as processed
                        lastAttemptedGunPart = gunPart
                        lastAttemptTime = now

                        if state.autoTakeGunMethod == "Touch interest" or state.autoTakeGunMethod == "Remote" then
                            -- fire touch interest directly when supported
                            local _genv2 = getgenv and getgenv() or {}
                            local touchFire = _genv2.firetouchinterest or firetouchinterest or (syn and syn.firetouchinterest)
                            if touchFire then
                                pcall(function() touchFire(hrp, gunPart, 0) end)
                                pcall(function() touchFire(hrp, gunPart, 1) end)

                                local ti = gunPart:FindFirstChildWhichIsA("TouchTransmitter", true) or gunPart:FindFirstChild("TouchInterest", true)
                                if ti then
                                    pcall(function() touchFire(hrp, ti.Parent, 0) end)
                                    pcall(function() touchFire(hrp, ti.Parent, 1) end)
                                end
                            end
                        else
                            -- teleport directly to gun dropped position
                            local originalCF = hrp.CFrame
                            local gunPos = Vector3.new(gunPart.Position.X, gunPart.Position.Y - 2, gunPart.Position.Z)

                            setNoclip(true)

                            pcall(function()
                                hrp.CFrame = CFrame.new(gunPos) * CFrame.Angles(math.rad(90), 0, 0)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                            end)

                            local _genv2 = getgenv and getgenv() or {}
                            local touchFire = _genv2.firetouchinterest or firetouchinterest or (syn and syn.firetouchinterest)
                            if touchFire then
                                pcall(function() touchFire(hrp, gunPart, 0) end)
                                pcall(function() touchFire(hrp, gunPart, 1) end)
                                local ti = gunPart:FindFirstChildWhichIsA("TouchTransmitter", true) or gunPart:FindFirstChild("TouchInterest", true)
                                if ti then
                                    pcall(function() touchFire(hrp, ti.Parent, 0) end)
                                    pcall(function() touchFire(hrp, ti.Parent, 1) end)
                                end
                            end

                            task.wait(0.15)

                            local gunTool = getPlayerTool(LocalPlayer, "Gun")
                            if gunTool then
                                pcall(function() hum:EquipTool(gunTool) end)
                                task.wait(0.05)
                            end

                            task.wait(0.1)

                            pcall(function()
                                hrp.CFrame = originalCF
                                hrp.AssemblyLinearVelocity  = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                            end)
                            task.wait(0.05)
                            setNoclip(false)
                            restoreCharacterCollision()
                        end
                    end
                end
            end
            task.wait(0.25)
        end
    end)
    trackThread(autoTakeGunThread)

    -- purchase and unlock mystery crates automatically 
    local autoOpenCratesThread = task.spawn(function()
        while not state.unloaded do
            if state.autoOpenCratesEnabled then
                local crate = state.selectedCrateType or "MysteryBox1"
                local keyType = (crate == "Summer2026Box") and "SummerKey2026" or "Coins"
                pcall(function()
                    local rs = game:GetService("ReplicatedStorage")
                    local remotes = rs:FindFirstChild("Remotes")
                    local shopRemotes = remotes and remotes:FindFirstChild("Shop")
                    local openRemote = shopRemotes and shopRemotes:FindFirstChild("OpenCrate")
                    if openRemote and openRemote:IsA("RemoteFunction") then
                        openRemote:InvokeServer(crate, "MysteryBox", keyType)
                    end
                end)
            end
            task.wait(1)
        end
    end)
    trackThread(autoOpenCratesThread)

    -- construct character physics and movement controls
    Tabs.Player:AddSection("Movement")

    -- bind speed toggle to slider value
    Tabs.Player:AddToggle("SpeedEnabled", {
        Title = "Walk speed",
        Default = false,
        DefaultBind = Enum.KeyCode.V,
        Slider = {
            Title = "Walk speed",
            Min = 16,
            Max = 250,
            Default = 16,
            Suffix = " studs/s",
            Callback = function(v)
                state.speedValue = v
                if state.speedEnabled then
                    local char = LocalPlayer.Character
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = v end
                end
            end
        },
        Callback = function(v)
            state.speedEnabled = v
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v and state.speedValue or 16
            end
        end
    })
    
    local flyHoverPos, flyHoverLook
    local function updateFly(dt)
        if not state.flightEnabled then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local moving = false
        local moveDir = Vector3.zero

        -- read wasd input for horizontal flight velocity
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + CurrentCamera.CFrame.LookVector; moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - CurrentCamera.CFrame.LookVector; moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - CurrentCamera.CFrame.RightVector; moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + CurrentCamera.CFrame.RightVector; moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0); moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0); moving = true end

        -- fallback to virtual thumbstick on mobile
        if not moving then
            local md = hum.MoveDirection
            if md.Magnitude > 0.1 then
                local look = CurrentCamera.CFrame.LookVector
                local right = CurrentCamera.CFrame.RightVector
                local flatLookV = Vector3.new(look.X, 0, look.Z)
                local flatRightV = Vector3.new(right.X, 0, right.Z)
                if flatLookV.Magnitude > 0 then flatLookV = flatLookV.Unit end
                if flatRightV.Magnitude > 0 then flatRightV = flatRightV.Unit end
                moveDir = (flatLookV * -md.Z) + (flatRightV * md.X)
                moving = true
            end
        end
        if state.flyUpPressed then moveDir = moveDir + Vector3.new(0, 1, 0); moving = true end
        if state.flyDownPressed then moveDir = moveDir - Vector3.new(0, 1, 0); moving = true end

        local look = CurrentCamera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude == 0 then flatLook = Vector3.new(0, 0, -1) else flatLook = flatLook.Unit end

        local bv = hrp:FindFirstChild("SafePlate")
        local speed = state.flightSpeed

        if moving then
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            local vel = moveDir * speed
            flyHoverPos  = hrp.Position + moveDir * (speed * dt)
            flyHoverLook = flatLook
            if bv then bv.Velocity = vel else hrp.AssemblyLinearVelocity = vel end
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
        else
            if bv then
                bv.Velocity = Vector3.zero
            else
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            end
            if flyHoverPos then
                hrp.CFrame = CFrame.new(flyHoverPos, flyHoverPos + (flyHoverLook or flatLook))
            else
                flyHoverPos = hrp.Position; flyHoverLook = flatLook
            end
        end
    end

    flyConn = nil
    local function toggleFlyConnection(active)
        if flyConn then pcall(function() flyConn:Disconnect() end); flyConn = nil end
        if active then
            flyHoverPos = nil; flyHoverLook = nil
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then flyHoverPos = hrp.Position; flyHoverLook = CurrentCamera.CFrame.LookVector end
            startFloating()
            flyConn = RunService.Heartbeat:Connect(updateFly)
        else
            stopAllMovement()
        end
    end

    -- fly character along camera look direction
    Tabs.Player:AddToggle("FlightEnabled", {
        Title = "Flight",
        Default = false,
        DefaultBind = Enum.KeyCode.C,
        Slider = {
            Title = "Flight speed",
            Min = 10,
            Max = 2000,
            Default = 50,
            Suffix = " studs/s",
            Callback = function(v)
                state.flightSpeed = v
            end
        },
        Callback = function(v)
            state.flightEnabled = v
            toggleFlyConnection(v)
            if mobileFlyBtn and mobileFlyBtn.GetState and mobileFlyBtn:GetState() ~= v then
                mobileFlyBtn:SetState(v, false)
            end
        end
    })
    
    -- override character jump impulse
    Tabs.Player:AddToggle("JumpPowerEnabled", {
        Title = "Jump power",
        Default = false,
        Slider = {
            Title = "Jump power",
            Min = 50,
            Max = 400,
            Default = 50,
            Suffix = " power",
            Callback = function(v)
                state.jumpPowerValue = v
                if state.jumpPowerEnabled then
                    local char = LocalPlayer.Character
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.UseJumpPower = true
                        hum.JumpPower = v
                    end
                end
            end
        },
        Callback = function(v)
            state.jumpPowerEnabled = v
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = v and state.jumpPowerValue or 50
            end
        end
    })
    
    Tabs.Player:AddSection("Utility")
    Tabs.Player:AddGroup({
        {
            Id = "AutoTakeGun",
            Type = "Toggle",
            Title = "Auto take dropped gun",
            Default = false,
            Callback = function(v)
                state.autoTakeGun = v
                log("Auto take gun: " .. (v and "Enabled" or "Disabled"))
            end
        },
        {
            Id = "GunPickupMethod",
            Type = "Dropdown",
            Title = "Gun pickup method",
            Values = {"Touch interest", "Teleport"},
            Default = "Touch interest",
            Callback = function(selected)
                state.autoTakeGunMethod = selected
                log("Gun pickup method: " .. selected)
            end
        },
        {
            Id = "AntiFlingEnabled",
            Type = "Toggle",
            Title = "Anti fling",
            Default = false,
            Callback = function(v)
                state.antiFlingEnabled = v
                updateAntiFling()
                log("Anti fling: " .. (v and "Enabled" or "Disabled"))
            end
        }
    })

    Tabs.Player:AddSection("Camlock")
    Tabs.Player:AddGroup({
        {
            Id = "CamlockEnabled",
            Type = "Toggle",
            Title = "Camlock",
            Default = false,
            DefaultBind = Enum.KeyCode.Q,
            Slider = {
                Title = "Camlock smoothness",
                Min = 0,
                Max = 100,
                Default = 20,
                Suffix = "%",
                Callback = function(v)
                    camlockSettings.smoothingFactor = v / 100
                end
            },
            Callback = function(v)
                state.camlockEnabled = v
                camlockSettings.aimLockEnabled = v
                camlockSettings.isLockedOn = v
                if v then
                    camlockSettings.targetPlayer = getCamlockTarget()
                else
                    camlockSettings.targetPlayer = nil
                end
                toggleCamlockConnection(v)
                if mobileCamlockBtn and mobileCamlockBtn.GetState and mobileCamlockBtn:GetState() ~= v then
                    mobileCamlockBtn:SetState(v, false)
                end
            end
        },

        {
            Id = "CamlockBodyPart",
            Type = "Dropdown",
            Title = "Target body part",
            Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
            Default = "Head",
            Callback = function(v)
                camlockSettings.bodyPartSelected = v
            end
        },

        {
            Id = "CamlockHorizPred",
            Type = "Slider",
            Title = "Horizontal prediction",
            Description = "Lead moving targets horizontally (default 0.2)",
            Min = 0,
            Max = 200,
            Default = 20,
            Suffix = " %",
            Callback = function(v)
                local n = tonumber(v) or 0
                camlockSettings.horizontalPrediction = n / 100
                camlockSettings.predictionFactor = n / 100
            end
        },

        {
            Id = "CamlockVertPred",
            Type = "Slider",
            Title = "Vertical prediction",
            Description = "Lead jumping/falling targets vertically (default 0.2)",
            Min = 0,
            Max = 200,
            Default = 20,
            Suffix = " %",
            Callback = function(v)
                local n = tonumber(v) or 0
                camlockSettings.verticalPrediction = n / 100
            end
        }
    })

    Tabs.Player:AddSection("Target")

    local function getPlayerList()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        if #list == 0 then table.insert(list, "None") end
        table.sort(list)
        return list
    end

    local initialPlayers = getPlayerList()
    if initialPlayers[1] and initialPlayers[1] ~= "None" then
        state.targetUsername = initialPlayers[1]
    end

    local targetDropdown = nil
    targetDropdown = Tabs.Player:AddDropdown("TargetPlayer", {
        Title = "Target player",
        Values = initialPlayers,
        Default = initialPlayers[1] or "None",
        Callback = function(name)
            if name == "None" or name == "" then
                state.targetUsername = ""
            else
                state.targetUsername = name
                log("Target set to: " .. name)
            end
        end
    })

    local function updateTargetDropdown()
        if targetDropdown then
            local currentList = getPlayerList()
            targetDropdown:SetValues(currentList)
            if state.targetUsername and state.targetUsername ~= "" then
                local found = false
                for _, n in ipairs(currentList) do
                    if n == state.targetUsername then found = true; break end
                end
                if not found then
                    local newTarget = (currentList[1] ~= "None") and currentList[1] or ""
                    state.targetUsername = newTarget
                    targetDropdown:SetValue(currentList[1] or "None", false)
                end
            elseif currentList[1] and currentList[1] ~= "None" then
                state.targetUsername = currentList[1]
                targetDropdown:SetValue(currentList[1], false)
            end
        end
    end

    trackConnection(Players.PlayerAdded:Connect(function()
        task.wait(0.2)
        updateTargetDropdown()
    end))

    trackConnection(Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        updateTargetDropdown()
    end))

    Tabs.Player:AddButton({
        Title = "Teleport to target",
        Callback = function()
            local target = findPlayer(state.targetUsername)
            if target and isPlayerAlive(target) then
                local tHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and myHrp then
                    myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                    log("Teleported to: " .. target.Name)
                end
            else
                log("Target not found or dead")
            end
        end
    })

    local spectateConn = nil
    Tabs.Player:AddToggle("SpectateTarget", {
        Title = "Spectate target",
        Default = false,
        Callback = function(v)
            state.spectateTarget = v
            if spectateConn then
                pcall(function() spectateConn:Disconnect() end)
                spectateConn = nil
            end
            if v then
                spectateConn = RunService.RenderStepped:Connect(function()
                    if not state.spectateTarget then
                        if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
                        return
                    end
                    local target = findPlayer(state.targetUsername)
                    local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if CurrentCamera.CameraSubject ~= hum then
                            CurrentCamera.CameraSubject = hum
                        end
                    end
                end)
                trackConnection(spectateConn)
                local target = findPlayer(state.targetUsername)
                if target then log("Spectating: " .. target.Name) end
            else
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then CurrentCamera.CameraSubject = hum end
                log("Stopped spectating")
            end
        end
    })

    Tabs.Player:AddSlider("FlingForwardOffset", {
        Title = "Fling offset",
        Min = 0,
        Max = 10,
        Default = 6,
        Increment = 0.1,
        Rounding = 1,
        Suffix = " studs",
        Callback = function(val)
            state.flingForwardOffset = val
        end
    })

    -- dispatch targeted flings against players
    mdTabs.Player:AddButtonRow({
        { Text = "Fling target", Callback = function()
            local target, err = findPlayer(state.targetUsername)
            if not target then log("Fling stopped: " .. (err or "No target")); return end
            if not isPlayerAlive(target) then log("target died"); return end
            if not isPlayerAlive(LocalPlayer) then log("Cannot fling while dead"); return end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local originalCF = hrp.CFrame
            log("Flinging: " .. target.Name)
            flingTarget(target, true)
            char = LocalPlayer.Character; hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = originalCF
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            end
            log("Fling done")
        end },
        { Text = "Fling murderer", Callback = function()
            local target = state.knifeHolder or getMurd()
            if not target then log("Murderer not found"); return end
            if not isPlayerAlive(target) then log("Murderer not alive"); return end
            if not isPlayerAlive(LocalPlayer) then log("Cannot fling while dead"); return end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local originalCF = hrp.CFrame
            log("flinging murderer: " .. target.Name)
            flingTarget(target, true)
            char = LocalPlayer.Character; hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = originalCF
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            end
            log("Fling done")
        end },
        { Text = "Fling sheriff", Callback = function()
            local target = state.gunHolder or getSheriff()
            if not target then log("Sheriff not found"); return end
            if not isPlayerAlive(target) then log("Sheriff not alive"); return end
            if not isPlayerAlive(LocalPlayer) then log("Cannot fling while dead"); return end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local originalCF = hrp.CFrame
            log("flinging sheriff: " .. target.Name)
            flingTarget(target, true)
            char = LocalPlayer.Character; hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = originalCF
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            end
            log("Fling done")
        end }
    }, 31)

    -- construct murderer combat and kill-all controls
    Tabs.Murderer:AddSection("Murderer tools")

    -- provide quick actions for knife attacks
    Tabs.Murderer:AddButtonRow({
        { Text = "Kill all", Callback = function()
            if not isPlayerAlive(LocalPlayer) then log("Dead - cannot kill"); return end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local knifeTool = getPlayerTool(LocalPlayer, "Knife")
            if not knifeTool or not hrp or not hum then log("No knife found"); return end
            hum:EquipTool(knifeTool)
            task.wait(0.1)
            local events = getKnifeEvents()
            if events then
                pcall(function() events.KnifeStabbed:FireServer() end)
                local count = 0
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and isPlayerAlive(target) then
                        local tChar = target.Character
                        local tHrp  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                        if tChar and tHrp then
                            local handle = nil
                            for _, acc in ipairs(tChar:GetChildren()) do
                                if acc:IsA("Accessory") then local h = acc:FindFirstChild("Handle"); if h then handle = h; break end end
                            end
                            handle = handle or tHrp
                            pcall(function() events.KnifeStabbed:FireServer() end)
                            pcall(function() events.HandleTouched:FireServer(handle) end)
                            local tKnifeLook = tHrp.CFrame.LookVector
                            local tKnifeStart = Vector3.new(tHrp.Position.X - tKnifeLook.X * 0.1, tHrp.Position.Y, tHrp.Position.Z - tKnifeLook.Z * 0.1)
                            pcall(function() events.KnifeThrown:FireServer(CFrame.new(tKnifeStart, tHrp.Position), CFrame.new(tHrp.Position)) end)
                            count = count + 1
                        end
                    end
                end
                log("Kill all executed on " .. count .. " players")
            end
        end },
        { Text = "Fling sheriff", Callback = function()
            local target = state.gunHolder or getSheriff()
            if not target then log("Sheriff not found"); return end
            if not isPlayerAlive(target) then log("Sheriff not alive"); return end
            if not isPlayerAlive(LocalPlayer) then log("Cannot fling while dead"); return end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local originalCF = hrp.CFrame
            log("flinging sheriff: " .. target.Name)
            flingTarget(target, true)
            char = LocalPlayer.Character; hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = originalCF
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            end
            log("Fling done")
        end }
    }, 24)

    Tabs.Murderer:AddToggleGroup({
        {
            Id = "KillAuraEnabled",
            Title = "Kill aura",
            Default = false,
            Slider = {
                Title = "Kill aura range",
                Min = 5,
                Max = 30,
                Default = 15,
                Suffix = " studs",
                Callback = function(v)
                    state.killAuraRange = v
                end
            },
            Callback = function(v)
                state.killAuraEnabled = v
                if v and state.killAuraParticleEnabled then
                    rebuildParticleAura()
                end
            end
        },
        {
            Id = "KillAuraVisible",
            Title = "Kill aura zone visible",
            Default = true,
            Callback = function(v)
                state.killAuraVisible = v
            end
        }
    })

    Tabs.Murderer:AddDropdown("KillAuraType", {
        Title = "Kill aura type",
        Values = { "Stab", "Throw" },
        Default = "Stab",
        Callback = function(v)
            state.killAuraType = v
        end
    })

    Tabs.Murderer:AddSection("Kill aura circle")

    Tabs.Murderer:AddToggle("KillAuraParticleEnabled", {
        Title = "Kill aura circle",
        Default = false,
        Callback = function(v)
            state.killAuraParticleEnabled = v
            if v then
                rebuildParticleAura()
            else
                cleanupParticleAura()
            end
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleCount", {
        Title = "Circle layers",
        Min = 1,
        Max = 10,
        Default = 1,
        Increment = 1,
        Callback = function(v)
            state.killAuraParticleCount = v
            if state.killAuraParticleEnabled then
                rebuildParticleAura()
            end
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleSpawnDelay", {
        Title = "Degree difference",
        Min = 0,
        Max = 360,
        Default = 0,
        Increment = 1,
        Suffix = "°",
        Callback = function(v)
            state.killAuraDegreeOffset = v
            state.killAuraParticleSpawnDelay = v
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleHeightOffset", {
        Title = "Height difference",
        Min = -5,
        Max = 10,
        Default = 0,
        Increment = 0.1,
        Precision = 1,
        Suffix = " studs",
        Callback = function(v)
            state.killAuraHeightOffset = v
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleSize", {
        Title = "Circle size",
        Min = 0.1,
        Max = 50,
        Default = 15,
        Increment = 0.1,
        Precision = 1,
        Suffix = " studs",
        Callback = function(v)
            state.killAuraParticleSize = v
            if state.killAuraParticleEnabled then
                for _, layer in ipairs(auraLayers) do
                    if layer.part and layer.part.Parent == workspace then
                        layer.part.Size = Vector3.new(v, 0.05, v)
                    end
                end
            end
        end
    })

    Tabs.Murderer:AddDropdown("KillAuraParticlePreset", {
        Title = "Circle texture",
        Values = { "Fade circle", "Telemon's fire circle", "Dashed circle", "Magic circle", "Custom" },
        Default = "Fade circle",
        Callback = function(v)
            state.killAuraParticlePreset = v
            if state.killAuraParticleEnabled then
                rebuildParticleAura()
            end
        end
    })

    Tabs.Murderer:AddInput("KillAuraParticleCustomId", {
        Title = "Custom texture ID",
        Default = "",
        Placeholder = "58889937 or rbxassetid://...",
        Callback = function(text)
            state.killAuraParticleCustomId = text
            if state.killAuraParticleEnabled and state.killAuraParticlePreset == "Custom" then
                rebuildParticleAura()
            end
        end
    })

    Tabs.Murderer:AddDropdown("KillAuraParticleColorMode", {
        Title = "Color mode",
        Values = { "Normal", "Gradient", "Shift", "Rainbow" },
        Default = "Normal",
        Callback = function(v)
            state.killAuraParticleColorMode = v
            if state.killAuraParticleEnabled then
                rebuildParticleAura()
            end
        end
    })

    Tabs.Murderer:AddColorpicker("KillAuraParticleColor", {
        Title = "Circle color 1",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(col)
            state.killAuraParticleColor = col
            if state.killAuraParticleEnabled then
                rebuildParticleAura()
            end
        end
    })

    Tabs.Murderer:AddColorpicker("KillAuraParticleColor2", {
        Title = "Circle color 2",
        Default = Color3.fromRGB(255, 0, 128),
        Callback = function(col)
            state.killAuraParticleColor2 = col
            if state.killAuraParticleEnabled then
                rebuildParticleAura()
            end
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleMinSpin", {
        Title = "Min spin speed",
        Min = -360,
        Max = 360,
        Default = 0,
        Increment = 5,
        Suffix = "°/s",
        Callback = function(v)
            state.killAuraParticleMinSpin = v
            if state.killAuraParticleEnabled then
                randomizeLayerSpeeds()
            end
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleMaxSpin", {
        Title = "Max spin speed",
        Min = -360,
        Max = 360,
        Default = 0,
        Increment = 5,
        Suffix = "°/s",
        Callback = function(v)
            state.killAuraParticleMaxSpin = v
            if state.killAuraParticleEnabled then
                randomizeLayerSpeeds()
            end
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleTransparency", {
        Title = "Circle transparency",
        Min = 0,
        Max = 100,
        Default = 20,
        Increment = 1,
        Suffix = "%",
        Callback = function(v)
            state.killAuraParticleTransparency = v / 100
            if state.killAuraParticleEnabled then
                for _, layer in ipairs(auraLayers) do
                    if layer.imageLabel then
                        pcall(function() layer.imageLabel.ImageTransparency = state.killAuraParticleTransparency end)
                    end
                end
            end
        end
    })

    Tabs.Murderer:AddSlider("KillAuraParticleGlow", {
        Title = "Circle glow",
        Min = 0,
        Max = 100,
        Default = 100,
        Increment = 1,
        Suffix = "%",
        Callback = function(v)
            state.killAuraParticleGlow = v / 100
            if state.killAuraParticleEnabled then
                for _, layer in ipairs(auraLayers) do
                    if layer.surfaceGui then
                        pcall(function() layer.surfaceGui.Brightness = 1 + (state.killAuraParticleGlow * 2) end)
                    end
                end
            end
        end
    })

    Tabs.Sheriff:AddSection("Sheriff tools")

    -- construct sheriff shooting and role assist tools
    Tabs.Sheriff:AddButtonRow({
        { Text = "Wallbang murder", Callback = function()
            local murderer = state.knifeHolder or getMurd()
            if not murderer or not isPlayerAlive(murderer) then log("Murderer not found or dead"); return end
            local gunTool = getPlayerTool(LocalPlayer, "Gun")
            if not gunTool then log("No gun found!"); return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if gunTool.Parent ~= char then
                hum:EquipTool(gunTool)
                task.wait(0.1)
            end
            local shootEvent = getGunShootEvent()
            local mChar = murderer.Character
            if shootEvent and mChar then
                local head = mChar:FindFirstChild("Head")
                local torso = mChar:FindFirstChild("UpperTorso") or mChar:FindFirstChild("Torso") or mChar:FindFirstChild("LowerTorso") or mChar:FindFirstChild("HumanoidRootPart")
                if torso then
                    local rawPos = torso.Position
                    local predH, predV = getSilentAimPred()
                    local targetPos = calculateAimPosition(rawPos, torso, predH, predV)
                    local startPos = head and head.Position or (rawPos + Vector3.new(0, 1.5, 0))

                    local startCF = CFrame.new(startPos, targetPos)
                    local targetCF = CFrame.new(targetPos)
                    pcall(function()
                        shootEvent:FireServer(startCF, targetCF)
                    end)
                    log("Wallbanged murderer: " .. murderer.Name)
                end
            end
        end },
        { Text = "Fling murderer", Callback = function()
            local target = state.knifeHolder or getMurd()
            if not target then log("Murderer not found"); return end
            if not isPlayerAlive(target) then log("Murderer not alive"); return end
            if not isPlayerAlive(LocalPlayer) then log("Cannot fling while dead"); return end
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local originalCF = hrp.CFrame
            log("flinging murderer: " .. target.Name)
            flingTarget(target, true)
            char = LocalPlayer.Character; hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = originalCF
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            end
            log("Fling done")
        end }
    }, 24)

    Tabs.Sheriff:AddSection("Auto aim")
    Tabs.Sheriff:AddGroup({
        {
            Id = "AutoAimEnabled",
            Type = "Toggle",
            Title = "Auto aim",
            Description = "Always hits murderer with gun (no FOV needed)",
            Default = false,
            Callback = function(v)
                state.autoAimEnabled = v
                log("Auto aim: " .. (v and "on" or "off"))
            end
        },
        {
            Id = "AutoAimWallbang",
            Type = "Toggle",
            Title = "Wallbang",
            Description = "Shoots from target head into torso to bypass walls",
            Default = false,
            Callback = function(v)
                state.autoAimWallbang = v
                silentAimConfig.wallbang = v
                log("Auto aim wallbang: " .. (v and "on" or "off"))
            end
        },
        {
            Id = "AutoAimHorizPred",
            Type = "Slider",
            Title = "Horizontal prediction",
            Description = "Lead moving targets horizontally (default 0.2)",
            Min = 0,
            Max = 200,
            Default = 20,
            Suffix = " %",
            Callback = function(val)
                local n = tonumber(val) or 0
                silentAimConfig.horizontalPrediction = n / 100
                silentAimConfig.predictionFactor = n / 100
            end
        },
        {
            Id = "AutoAimVertPred",
            Type = "Slider",
            Title = "Vertical prediction",
            Description = "Lead jumping/falling targets vertically (default 0.2)",
            Min = 0,
            Max = 200,
            Default = 20,
            Suffix = " %",
            Callback = function(val)
                local n = tonumber(val) or 0
                silentAimConfig.verticalPrediction = n / 100
            end
        }
    })

    Tabs.Player:AddSection("Silent aim")
    Tabs.Player:AddGroup({
        {
            Id = "SilentAimEnabled",
            Type = "Toggle",
            Title = "Silent aim",
            Default = false,
            Callback = function(v)
                silentAimConfig.enabled = v
                if not v then removeFOVCircle() end
            end
        },
        {
            Id = "SilentAimWallbang",
            Type = "Checkbox",
            Title = "Wallbang",
            Description = "Shoots from target head into torso to bypass walls",
            Default = false,
            Callback = function(v)
                silentAimConfig.wallbang = v
                state.autoAimWallbang = v
            end
        },
        {
            Id = "SilentAimTargetPart",
            Type = "Dropdown",
            Title = "Target part",
            Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random"},
            Default = "Head",
            Callback = function(selected)
                silentAimConfig.targetPart = selected
            end
        },
        {
            Id = "SilentAimHitChance",
            Type = "Slider",
            Title = "Hit chance",
            Min = 1,
            Max = 100,
            Default = 100,
            Suffix = "%",
            Callback = function(val)
                silentAimConfig.hitChance = val
            end
        },
        {
            Id = "SilentAimHorizPred",
            Type = "Slider",
            Title = "Horizontal prediction",
            Description = "Lead moving targets horizontally (default 0.2)",
            Min = 0,
            Max = 200,
            Default = 20,
            Suffix = " %",
            Callback = function(val)
                local n = tonumber(val) or 0
                silentAimConfig.horizontalPrediction = n / 100
                silentAimConfig.predictionFactor = n / 100
            end
        },
        {
            Id = "SilentAimVertPred",
            Type = "Slider",
            Title = "Vertical prediction",
            Description = "Lead jumping/falling targets vertically (default 0.2)",
            Min = 0,
            Max = 200,
            Default = 20,
            Suffix = " %",
            Callback = function(val)
                local n = tonumber(val) or 0
                silentAimConfig.verticalPrediction = n / 100
            end
        }
    })

    Tabs.Player:AddCheckbox("SilentAimWallCheck", {
        Title = "Wall check",
        Default = false,
        Callback = function(v)
            silentAimConfig.wallCheck = v
        end
    })

    Tabs.Player:AddCheckbox("SilentAimAliveCheck", {
        Title = "Alive check",
        Default = true,
        Callback = function(v)
            silentAimConfig.aliveCheck = v
        end
    })

    Tabs.Player:AddCheckbox("SilentAimRandomOffset", {
        Title = "Random offset",
        Default = false,
        Callback = function(v)
            silentAimConfig.randomOffset = v
        end
    })

    Tabs.Player:AddToggle("SilentAimFOVVisible", {
        Title = "Fov circle",
        Default = true,
        Slider = {
            Title = "Fov radius",
            Min = 20,
            Max = 600,
            Default = 125,
            Suffix = " px",
            Callback = function(val)
                silentAimConfig.fovRadius = val
            end
        },
        Callback = function(v)
            silentAimConfig.fovVisible = v
            if not v then removeFOVCircle() end
        end
    })

    local fovDropRow = Tabs.Player:AddRow(44, 8)
    fovDropRow:AddDropdown(
        "Fov shape",
        {"Normal", "Dots", "Dots out of dots", "Stripes"},
        "Normal",
        function(selected)
            silentAimConfig.fovType = selected
        end
    )
    fovDropRow:AddDropdown(
        "Color mode",
        {"Normal", "Rainbow", "Rainbow 2", "Shift", "Gradient"},
        "Normal",
        function(selected)
            silentAimConfig.colorMode = selected
        end
    )

    Tabs.Player:AddToggleGroup({
        {
            Title = "Spin fov",
            Default = false,
            Callback = function(v)
                silentAimConfig.spin = v
            end
        },
        {
            Title = "Fill fov",
            Default = false,
            Callback = function(v)
                silentAimConfig.filled = v
            end
        }
    })

    Tabs.Player:AddSlider("SilentAimSpinSpeed", {
        Title = "Spin speed",
        Min = 10,
        Max = 360,
        Default = 60,
        Suffix = "°/s",
        Callback = function(val)
            silentAimConfig.spinSpeed = val
        end
    })

    local fovColorRow = Tabs.Player:AddRow(44, 8)
    fovColorRow:AddColorPicker("Fov color", Color3.fromRGB(255, 60, 60), function(col)
        silentAimConfig.color1 = col
    end)
    fovColorRow:AddColorPicker("Fov secondary color", Color3.fromRGB(0, 170, 255), function(col)
        silentAimConfig.color2 = col
    end)

    Tabs.Player:AddSlider("SilentAimTransparency", {
        Title = "Fov transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(v)
            silentAimConfig.transparency = v / 100
        end
    })

    Tabs.Player:AddToggle("SilentAimShadow", {
        Title = "Fov drop shadow",
        Default = false,
        Slider = {
            Title = "Fov shadow transparency",
            Min = 0,
            Max = 100,
            Default = 50,
            Suffix = "%",
            Callback = function(v)
                silentAimConfig.shadowTransparency = v / 100
            end
        },
        Callback = function(v)
            silentAimConfig.shadow = v
        end
    })
    
    local customSoundOriginals = setmetatable({}, { __mode = "k" })

    local function isOwnSoundInstance(sound)
        local char = LocalPlayer.Character
        if char and sound:IsDescendantOf(char) then return true end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp and sound:IsDescendantOf(bp) then return true end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg and sound:IsDescendantOf(pg) then return true end
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and sound.Parent and sound.Parent:IsA("BasePart") then
                if (sound.Parent.Position - hrp.Position).Magnitude <= 20 then
                    return true
                end
            end
        end
        return false
    end

    local function getSoundType(sound)
        if not sound or not sound:IsA("Sound") then return nil end
        local name = sound.Name:lower()
        if name == "coinsound" then
            return "Coin"
        elseif name == "reload" then
            return "Reload"
        elseif name == "gunkill" or name == "hit" or name == "gunhit" or name == "bullethit" or name == "headshot" then
            return "GunKill"
        elseif name == "kill" or name == "knifekill" then
            return "KnifeKill"
        elseif name == "gunshot" or name == "shoot" or name == "shot" or name == "gunsound" or name == "shootsound" or name == "fire" then
            return "Gunshot"
        end
        return nil
    end

    local function applyCustomSoundInstanceDirect(cat, sound)
        if not sound or not sound:IsA("Sound") then return end
        local cfg = customSoundConfigs[cat]
        if not cfg then return end

        if not customSoundOriginals[sound] then
            customSoundOriginals[sound] = {
                SoundId = sound.SoundId,
                Volume = sound.Volume
            }
        end

        local isOwn = isOwnSoundInstance(sound)
        local shouldReplace = cfg.Enabled and (cfg.Target == "All" or isOwn)

        if shouldReplace then
            local targetId = formatCustomAssetId(cfg.SoundId or getActiveCustomSoundId(cat))
            if targetId ~= "" and sound.SoundId ~= targetId then
                sound.SoundId = targetId
            end
            local vol = cfg.Volume
            if vol then
                sound.Volume = vol
            end
        else
            local orig = customSoundOriginals[sound]
            if orig and sound.SoundId ~= orig.SoundId then
                sound.SoundId = orig.SoundId
                sound.Volume = orig.Volume
            end
        end
    end

    local function applyCustomSoundInstance(sound)
        local cat = getSoundType(sound)
        if not cat then return end
        applyCustomSoundInstanceDirect(cat, sound)
    end

    refreshCustomSounds = function()
        for _, cfg in pairs(customSoundConfigs) do
            local isEnabled = cfg.Enabled or cfg.enabled
            local sId = cfg.SoundId or cfg.soundId or ""
            if isEnabled and sId ~= "" then
                local formatted = formatCustomAssetId(sId)
                if formatted and formatted ~= "" then
                    task.spawn(function()
                        local s = Instance.new("Sound")
                        s.SoundId = formatted
                        pcall(function() ContentProvider:PreloadAsync({ s }) end)
                        s:Destroy()
                    end)
                end
            end
        end

        for _, sound in ipairs(Workspace:GetDescendants()) do
            if sound:IsA("Sound") and getSoundType(sound) then
                applyCustomSoundInstance(sound)
            end
        end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, sound in ipairs(bp:GetDescendants()) do
                if sound:IsA("Sound") and getSoundType(sound) then
                    applyCustomSoundInstance(sound)
                end
            end
        end
        local soundService = game:GetService("SoundService")
        for _, sound in ipairs(soundService:GetDescendants()) do
            if sound:IsA("Sound") and getSoundType(sound) then
                applyCustomSoundInstance(sound)
            end
        end
    end

    local customGunSoundConfig = customSoundConfigs.Gunshot

    local function applyGunSound(tool)
        if not tool or not tool:IsA("Tool") then return end

        if isGunTool(tool) then
            for _, s in ipairs(tool:GetDescendants()) do
                if s:IsA("Sound") then
                    local sType = getSoundType(s)
                    if sType then
                        applyCustomSoundInstance(s)
                    elseif s.Name ~= "Reload" and s.Name ~= "GunKill" and s.Name ~= "Kill" and s.Name ~= "Hit" and s.Name ~= "GunHit" and s.Name ~= "BulletHit" and s.Name ~= "Headshot" then
                        applyCustomSoundInstanceDirect("Gunshot", s)
                    end
                end
            end
        else
            for _, s in ipairs(tool:GetDescendants()) do
                if s:IsA("Sound") and getSoundType(s) then
                    applyCustomSoundInstance(s)
                end
            end
        end
    end

    local function hookGunSounds()
        if customGunSoundConfig.Target == "All" then
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                if plr.Character then
                    for _, item in ipairs(plr.Character:GetChildren()) do
                        applyGunSound(item)
                    end
                end
                local bp = plr:FindFirstChild("Backpack")
                if bp then
                    for _, item in ipairs(bp:GetChildren()) do
                        applyGunSound(item)
                    end
                end
            end
        else
            local char = LocalPlayer.Character
            if char then
                for _, item in ipairs(char:GetChildren()) do
                    applyGunSound(item)
                end
            end
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    applyGunSound(item)
                end
            end
        end
        refreshCustomSounds()
    end

    local ownBpChildConn = nil
    local ownCharChildConn = nil

    local function setupBackpackListener(bp)
        if ownBpChildConn then pcall(function() ownBpChildConn:Disconnect() end) ownBpChildConn = nil end
        if bp then
            ownBpChildConn = bp.ChildAdded:Connect(function(tool)
                if customGunSoundConfig and customGunSoundConfig.Enabled then
                    task.wait(0.1)
                    applyGunSound(tool)
                end
            end)
        end
    end

    trackConnection(LocalPlayer.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then
            task.wait(0.2)
            hookGunSounds()
            setupBackpackListener(child)
        end
    end))

    if LocalPlayer:FindFirstChild("Backpack") then
        setupBackpackListener(LocalPlayer.Backpack)
    end

    trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        if ownCharChildConn then pcall(function() ownCharChildConn:Disconnect() end) ownCharChildConn = nil end
        task.wait(0.5)
        hookGunSounds()
        ownCharChildConn = char.ChildAdded:Connect(function(child)
            if customGunSoundConfig and customGunSoundConfig.Enabled then
                task.wait(0.1)
                applyGunSound(child)
            end
        end)
    end))

    trackConnection(Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") and getSoundType(descendant) then
            applyCustomSoundInstance(descendant)
        end
    end))

    trackConnection(game:GetService("SoundService").DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") and getSoundType(descendant) then
            applyCustomSoundInstance(descendant)
        end
    end))

    -- construct custom sound effect triggers
    Tabs.Sounds:AddSection("Gunshot sound")
    Tabs.Sounds:AddGroup({
        {
            Id = "CustomGunSoundEnabled",
            Type = "Toggle",
            Title = "Custom gun sound",
            Default = false,
            Slider = {
                Title = "Gun sound volume",
                Min = 0,
                Max = 150,
                Default = 100,
                Increment = 1,
                Suffix = "%",
                Callback = function(v)
                    customGunSoundConfig.Volume = v / 100
                    refreshCustomSounds()
                end
            },
            Callback = function(v)
                customGunSoundConfig.Enabled = v
                hookGunSounds()
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomGunSoundPreset",
            Type = "Dropdown",
            Title = "Gun sound preset",
            Values = {"Minecraft", "Laser", "CS:GO Deagle", "Custom"},
            Default = "Minecraft",
            Callback = function(v)
                customGunSoundConfig.Preset = v
                customGunSoundConfig.SoundId = getActiveCustomSoundId("Gunshot")
                hookGunSounds()
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomGunSoundTarget",
            Type = "Dropdown",
            Title = "Target",
            Values = {"Own", "All"},
            Default = "Own",
            Callback = function(v)
                customGunSoundConfig.Target = v
                hookGunSounds()
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomGunSoundId",
            Type = "Input",
            Title = "Custom sound asset ID",
            Default = "",
            Placeholder = "7554632797",
            Callback = function(text)
                customGunSoundConfig.CustomId = text
                if customGunSoundConfig.Preset == "Custom" then
                    customGunSoundConfig.SoundId = text
                    hookGunSounds()
                    refreshCustomSounds()
                end
            end
        }
    })

    Tabs.Sounds:AddSection("Reload sound")
    Tabs.Sounds:AddGroup({
        {
            Id = "CustomReloadSoundEnabled",
            Type = "Toggle",
            Title = "Custom reload sound",
            Default = false,
            Slider = {
                Title = "Reload volume",
                Min = 0,
                Max = 150,
                Default = 100,
                Increment = 1,
                Suffix = "%",
                Callback = function(v)
                    customSoundConfigs.Reload.Volume = v / 100
                    refreshCustomSounds()
                end
            },
            Callback = function(v)
                customSoundConfigs.Reload.Enabled = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomReloadSoundPreset",
            Type = "Dropdown",
            Title = "Preset",
            Values = {"Laser pistol", "Custom"},
            Default = "Laser pistol",
            Callback = function(v)
                customSoundConfigs.Reload.Preset = v
                customSoundConfigs.Reload.SoundId = getActiveCustomSoundId("Reload")
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomReloadSoundTarget",
            Type = "Dropdown",
            Title = "Target",
            Values = {"Own", "All"},
            Default = "Own",
            Callback = function(v)
                customSoundConfigs.Reload.Target = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomReloadSoundId",
            Type = "Input",
            Title = "Custom sound asset ID",
            Default = "",
            Placeholder = "1898332552",
            Callback = function(text)
                customSoundConfigs.Reload.CustomId = text
                if customSoundConfigs.Reload.Preset == "Custom" then
                    customSoundConfigs.Reload.SoundId = text
                    refreshCustomSounds()
                end
            end
        }
    })

    Tabs.Sounds:AddSection("Gun kill sound")
    Tabs.Sounds:AddGroup({
        {
            Id = "CustomGunKillSoundEnabled",
            Type = "Toggle",
            Title = "Custom gun kill sound",
            Default = false,
            Slider = {
                Title = "Gun kill volume",
                Min = 0,
                Max = 150,
                Default = 100,
                Increment = 1,
                Suffix = "%",
                Callback = function(v)
                    customSoundConfigs.GunKill.Volume = v / 100
                    refreshCustomSounds()
                end
            },
            Callback = function(v)
                customSoundConfigs.GunKill.Enabled = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomGunKillSoundPreset",
            Type = "Dropdown",
            Title = "Preset",
            Values = {"Fortnite knocked", "CS:GO headshot", "Fatality", "Rust headshot", "Tom scream", "Old church bell", "Ouch", "Minecraft", "Death note", "Victory", "Stariy bog", "Stariy bog yaica", "Custom"},
            Default = "Fortnite knocked",
            Callback = function(v)
                customSoundConfigs.GunKill.Preset = v
                customSoundConfigs.GunKill.SoundId = getActiveCustomSoundId("GunKill")
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomGunKillSoundTarget",
            Type = "Dropdown",
            Title = "Target",
            Values = {"Own", "All"},
            Default = "Own",
            Callback = function(v)
                customSoundConfigs.GunKill.Target = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomGunKillSoundId",
            Type = "Input",
            Title = "Custom sound asset ID",
            Default = "",
            Placeholder = "118171751820277",
            Callback = function(text)
                customSoundConfigs.GunKill.CustomId = text
                if customSoundConfigs.GunKill.Preset == "Custom" then
                    customSoundConfigs.GunKill.SoundId = text
                    refreshCustomSounds()
                end
            end
        }
    })

    Tabs.Sounds:AddSection("Knife kill sound")
    Tabs.Sounds:AddGroup({
        {
            Id = "CustomKnifeKillSoundEnabled",
            Type = "Toggle",
            Title = "Custom knife kill sound",
            Default = false,
            Slider = {
                Title = "Knife kill volume",
                Min = 0,
                Max = 150,
                Default = 100,
                Increment = 1,
                Suffix = "%",
                Callback = function(v)
                    customSoundConfigs.KnifeKill.Volume = v / 100
                    refreshCustomSounds()
                end
            },
            Callback = function(v)
                customSoundConfigs.KnifeKill.Enabled = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomKnifeKillSoundPreset",
            Type = "Dropdown",
            Title = "Preset",
            Values = {"Golden pan", "Orange water", "Bye bye", "Katana", "Knife slice", "Custom"},
            Default = "Golden pan",
            Callback = function(v)
                customSoundConfigs.KnifeKill.Preset = v
                customSoundConfigs.KnifeKill.SoundId = getActiveCustomSoundId("KnifeKill")
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomKnifeKillSoundTarget",
            Type = "Dropdown",
            Title = "Target",
            Values = {"Own", "All"},
            Default = "Own",
            Callback = function(v)
                customSoundConfigs.KnifeKill.Target = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomKnifeKillSoundId",
            Type = "Input",
            Title = "Custom sound asset ID",
            Default = "",
            Placeholder = "135260359985455",
            Callback = function(text)
                customSoundConfigs.KnifeKill.CustomId = text
                if customSoundConfigs.KnifeKill.Preset == "Custom" then
                    customSoundConfigs.KnifeKill.SoundId = text
                    refreshCustomSounds()
                end
            end
        }
    })

    Tabs.Sounds:AddSection("Coin pickup sound")
    Tabs.Sounds:AddGroup({
        {
            Id = "CustomCoinSoundEnabled",
            Type = "Toggle",
            Title = "Custom coin pickup sound",
            Default = false,
            Slider = {
                Title = "Coin sound volume",
                Min = 0,
                Max = 150,
                Default = 100,
                Increment = 1,
                Suffix = "%",
                Callback = function(v)
                    customSoundConfigs.Coin.Volume = v / 100
                    refreshCustomSounds()
                end
            },
            Callback = function(v)
                customSoundConfigs.Coin.Enabled = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomCoinSoundPreset",
            Type = "Dropdown",
            Title = "Preset",
            Values = {"Ultrakill coinflip", "Coin click", "Coin click 2", "Custom"},
            Default = "Ultrakill coinflip",
            Callback = function(v)
                customSoundConfigs.Coin.Preset = v
                customSoundConfigs.Coin.SoundId = getActiveCustomSoundId("Coin")
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomCoinSoundTarget",
            Type = "Dropdown",
            Title = "Target",
            Values = {"Own", "All"},
            Default = "Own",
            Callback = function(v)
                customSoundConfigs.Coin.Target = v
                refreshCustomSounds()
            end
        },
        {
            Id = "CustomCoinSoundId",
            Type = "Input",
            Title = "Custom sound asset ID",
            Default = "",
            Placeholder = "138571475125488",
            Callback = function(text)
                customSoundConfigs.Coin.CustomId = text
                if customSoundConfigs.Coin.Preset == "Custom" then
                    customSoundConfigs.Coin.SoundId = text
                    refreshCustomSounds()
                end
            end
        }
    })

    -- configure particle ribbons and orbiting spheres 
    local trailConfig = {
        enabled = false,
        colorMode = "Normal",
        color1 = Color3.fromRGB(0, 170, 255),
        color2 = Color3.fromRGB(255, 0, 128),
        color = Color3.fromRGB(0, 170, 255),
        lifetime = 1.0,
        width = 1.0,
        lightEmission = 0.5,
        transparency = 0,
    }

    local orbConfig = {
        enabled = false,
        colorMode = "Normal",
        color1 = Color3.fromRGB(0, 255, 170),
        color2 = Color3.fromRGB(255, 85, 0),
        speed = 4,
        radius = 3,
        size = 0.3,
        brightness = 1.43,
        range = 8
    }

    local localTrail = nil
    local localOrb = nil
    local orbRotationAngle = 0
    local function getTrailColors()
        local mode = trailConfig.colorMode
        local c1 = trailConfig.color1 or trailConfig.color or Color3.fromRGB(0, 170, 255)
        local c2 = trailConfig.color2 or Color3.fromRGB(255, 0, 128)
        local shiftSpeed = state and state.colorShiftSpeed or 3

        if mode == "Shift" then
            local tVal = (math.sin(tick() * shiftSpeed) + 1) * 0.5
            return ColorSequence.new(c1:Lerp(c2, tVal))
        elseif mode == "Gradient" then
            local tVal = (math.sin(tick() * shiftSpeed) + 1) / 2
            return ColorSequence.new(c1:Lerp(c2, tVal), c2:Lerp(c1, tVal))
        elseif mode == "Rainbow" then
            local hue = ((tick() * 0.45) % 1.0)
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV((hue + 0.00) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.25, Color3.fromHSV((hue + 0.25) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV((hue + 0.50) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.75, Color3.fromHSV((hue + 0.75) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV((hue + 1.00) % 1, 1, 1)),
            })
        elseif mode == "2 colors" then
            local tVal = (math.sin(tick() * shiftSpeed) + 1) / 2
            return ColorSequence.new(c1:Lerp(c2, tVal))
        else
            return ColorSequence.new(c1)
        end
    end

    -- attach decorative emitters to character limbs 
    local translucentBodyConfig = {
        enabled = false,
        colorMode = "Normal",
        color1 = Color3.fromRGB(255, 255, 255),
        color2 = Color3.fromRGB(0, 0, 0),
        color = Color3.fromRGB(255, 255, 255)
    }
    local originalBodyProperties = {}

    local function applyTranslucentBody()
        local char = LocalPlayer.Character
        if not char then return end

        if translucentBodyConfig.enabled then
            local bodyColor = getColor(
                translucentBodyConfig.colorMode or "Normal",
                translucentBodyConfig.color1 or translucentBodyConfig.color or Color3.fromRGB(255, 255, 255),
                translucentBodyConfig.color2 or Color3.fromRGB(0, 0, 0)
            )

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not originalBodyProperties[part] then
                        originalBodyProperties[part] = {
                            Material = part.Material,
                            Color = part.Color,
                            Transparency = part.Transparency
                        }
                    end

                    if part.Name == "HumanoidRootPart" or part.Name == "KillAuraZone" or part.Name == "OrbitingOrb" then
                        part.Transparency = 1
                    else
                        part.Material = Enum.Material.ForceField
                        part.Transparency = 0.35
                        part.Color = bodyColor
                    end
                end
            end
        else
            for part, props in pairs(originalBodyProperties) do
                if part and part.Parent then
                    pcall(function()
                        part.Material = props.Material
                        part.Color = props.Color
                        part.Transparency = props.Transparency
                    end)
                end
            end
            table.clear(originalBodyProperties)
        end
    end

    -- configure particle preset parameters
    local BODY_PARTICLE_PRESETS = {
        ["Hexagon"] = {
            texture = "http://www.roblox.com/asset/?id=5021159599",
            isAnimated = false
        },
        ["Triangle"] = {
            texture = "http://www.roblox.com/asset/?id=4505798638",
            isAnimated = false
        },
        ["Heart"] = {
            texture = "http://www.roblox.com/asset/?id=241778280",
            isAnimated = false
        },
        ["Square"] = {
            texture = "http://www.roblox.com/asset/?id=642505794",
            isAnimated = false
        },
        ["Smoke (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=8733226116",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["Pixel sparkle (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=13448020277",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["Spinning robux (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=12859930047",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["Bat (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=117267873734624",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["Potion particle (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=8733731095",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["Wingdings (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=92668765537961",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
        },
        ["YouAreAnIdiot (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=119483013767759",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid2x2
        },
        ["Eye (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=136598435215978",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
        },
        ["Dollar (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=17451596749",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["maxwell (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=12890944256",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
        },
        ["Triangle shard (animated)"] = {
            texture = "http://www.roblox.com/asset/?id=79466620842369",
            isAnimated = true,
            flipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8
        },
        ["Custom"] = {
            texture = "",
            isAnimated = false
        }
    }

    local VALID_BODY_PARTS = {
        ["Head"] = true,
        ["Torso"] = true,
        ["UpperTorso"] = true,
        ["LowerTorso"] = true,
        ["Left Arm"] = true,
        ["LeftUpperArm"] = true,
        ["LeftLowerArm"] = true,
        ["LeftHand"] = true,
        ["Right Arm"] = true,
        ["RightUpperArm"] = true,
        ["RightLowerArm"] = true,
        ["RightHand"] = true,
        ["Left Leg"] = true,
        ["LeftUpperLeg"] = true,
        ["LeftLowerLeg"] = true,
        ["LeftFoot"] = true,
        ["Right Leg"] = true,
        ["RightUpperLeg"] = true,
        ["RightLowerLeg"] = true,
        ["RightFoot"] = true
    }

    local bodyParticlesConfig = {
        enabled = false,
        preset = "Pixel sparkle (animated)",
        customTextureId = "",
        colorMode = "Normal",
        color1 = Color3.fromRGB(255, 255, 255),
        color2 = Color3.fromRGB(0, 0, 0),
        size = 0.2,
        transparency = 0,
        speed = 0.0,
        spin = 0,
        lifetime = 5,
        rate = 2,
        orientation = "Camera",
        glowing = false,
        anchored = false,
        fadeIn = true,
        fadeOut = true,
        isCustomFlipbook = false,
        customFlipbookLayout = "Grid4x4",
        customFlipbookMode = "Loop",
        flipbookPlaySpeed = 15
    }

    local bodyParticleEmitters = {}
    local bodySliceParts = {}
    local bodyContainerPart = nil
    local bodyContainerHeartbeat = nil

    local function removeBodyContainerPart()
        if bodyContainerHeartbeat then
            pcall(function() bodyContainerHeartbeat:Disconnect() end)
            bodyContainerHeartbeat = nil
        end
        for _, sInfo in ipairs(bodySliceParts) do
            if sInfo.part then
                pcall(function() sInfo.part:Destroy() end)
            end
        end
        table.clear(bodySliceParts)
        if bodyContainerPart then
            pcall(function() bodyContainerPart:Destroy() end)
            bodyContainerPart = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, desc in ipairs(char:GetChildren()) do
                if desc.Name == "BodyParticleContainerPart" or desc.Name == "BodyParticleSlice" then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
    end

    local function removeBodyParticles()
        for _, emitter in ipairs(bodyParticleEmitters) do
            if emitter and emitter.Parent then
                pcall(function() emitter:Destroy() end)
            end
        end
        table.clear(bodyParticleEmitters)
        removeBodyContainerPart()

        local char = LocalPlayer.Character
        if char then
            for _, desc in ipairs(char:GetDescendants()) do
                if desc:IsA("ParticleEmitter") and desc.Name == "BodyParticleEmitter" then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
    end

    local function getBodyBounds(char)
        if not char then return nil, nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil end

        local hrpCF = hrp.CFrame

        local minX, maxX = math.huge, -math.huge
        local minY, maxY = math.huge, -math.huge
        local minZ, maxZ = math.huge, -math.huge
        local found = false

        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("BasePart") and VALID_BODY_PARTS[child.Name] then
                found = true
                local pCF = child.CFrame
                local half = child.Size * 0.5
                for x = -1, 1, 2 do
                    for y = -1, 1, 2 do
                        for z = -1, 1, 2 do
                            local worldPt = pCF * Vector3.new(half.X * x, half.Y * y, half.Z * z)
                            local localPt = hrpCF:PointToObjectSpace(worldPt)
                            minX = math.min(minX, localPt.X)
                            maxX = math.max(maxX, localPt.X)
                            minY = math.min(minY, localPt.Y)
                            maxY = math.max(maxY, localPt.Y)
                            minZ = math.min(minZ, localPt.Z)
                            maxZ = math.max(maxZ, localPt.Z)
                        end
                    end
                end
            end
        end

        if not found then
            return hrpCF, Vector3.new(3.0, 5.0, 1.2)
        end

        local sizeX = math.clamp(maxX - minX, 1.5, 4.0)
        local sizeY = math.clamp(maxY - minY, 3.5, 6.0)
        local sizeZ = math.clamp(maxZ - minZ, 0.8, 2.5)

        local size = Vector3.new(sizeX, sizeY, sizeZ)
        local localCenter = Vector3.new((minX + maxX) * 0.5, (minY + maxY) * 0.5, (minZ + maxZ) * 0.5)
        local centerCF = hrpCF * CFrame.new(localCenter)

        return centerCF, size
    end

    local function getParticleColors(mode, c1, c2)
        local col1 = c1 or Color3.fromRGB(255, 0, 0)
        local col2 = c2 or Color3.fromRGB(0, 170, 255)
        local shiftSpeed = state and state.colorShiftSpeed or 3
        local phase = (tick() * (shiftSpeed * 0.15)) % 1.0

        if mode == "2 colors" then
            local tVal = (math.sin(tick() * shiftSpeed) + 1) / 2
            local cycled = col1:Lerp(col2, tVal)
            return ColorSequence.new(cycled)
        elseif mode == "Gradient" then
            local tVal = (math.sin(tick() * shiftSpeed) + 1) / 2
            local lerped1 = col1:Lerp(col2, tVal)
            local lerped2 = col2:Lerp(col1, tVal)
            return ColorSequence.new(lerped1, lerped2)
        elseif mode == "Gradient 2" then
            local function getSmoothCol(off)
                local tVal = (math.sin((phase + off) * math.pi * 2) + 1) * 0.5
                return col1:Lerp(col2, tVal)
            end
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0,    getSmoothCol(0)),
                ColorSequenceKeypoint.new(0.25, getSmoothCol(0.25)),
                ColorSequenceKeypoint.new(0.5,  getSmoothCol(0.5)),
                ColorSequenceKeypoint.new(0.75, getSmoothCol(0.75)),
                ColorSequenceKeypoint.new(1,    getSmoothCol(1))
            })
        elseif mode == "Rainbow" then
            local hue = rainbowHue or ((tick() * 0.45) % 1.0)
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV((hue + 0.00) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV((hue + 0.17) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV((hue + 0.33) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV((hue + 0.50) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV((hue + 0.67) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV((hue + 0.83) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1.00, Color3.fromHSV((hue + 1.00) % 1, 1, 1))
            })
        elseif mode == "Rainbow 2" then
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV((0.00 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV((0.17 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV((0.33 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV((0.50 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV((0.67 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV((0.83 + phase) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1.00, Color3.fromHSV((1.00 + phase) % 1, 1, 1))
            })
        else
            return ColorSequence.new(col1)
        end
    end

    local function applyBodyParticles()
        removeBodyParticles()

        if not bodyParticlesConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local centerCF, boxSize = getBodyBounds(char)
        if not centerCF or not boxSize then return end

        local container = Instance.new("Part")
        container.Name = "BodyParticleContainerPart"
        container.Size = boxSize
        container.CFrame = centerCF
        container.Transparency = 1
        container.CanCollide = false
        container.CanTouch = false
        container.CanQuery = false
        container.CastShadow = false
        container.Massless = true
        container.Anchored = false
        container.Parent = char

        bodyContainerPart = container

        
        container.Changed:Connect(function(prop)
            if prop == "Transparency" and container.Transparency ~= 1 then
                container.Transparency = 1
            end
            if prop == "CanCollide" and container.CanCollide ~= false then
                container.CanCollide = false
            end
            if prop == "CanTouch" and container.CanTouch ~= false then
                container.CanTouch = false
            end
            if prop == "CanQuery" and container.CanQuery ~= false then
                container.CanQuery = false
            end
        end)

        
        local _bodyHBFrame = 0
        local _cachedBodySize = nil
        bodyContainerHeartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            if not container or not container.Parent then
                if bodyContainerHeartbeat then
                    bodyContainerHeartbeat:Disconnect()
                    bodyContainerHeartbeat = nil
                end
                return
            end
            local c = LocalPlayer.Character
            if not c then return end
            _bodyHBFrame = _bodyHBFrame + 1
            -- smooth container position without lag spikes
            local hrpPart = c:FindFirstChild("HumanoidRootPart")
            if not hrpPart then return end
            if _bodyHBFrame % 5 == 0 or not _cachedBodySize then
                local newCF, newSize = getBodyBounds(c)
                if newCF then
                    container.CFrame = newCF
                    if newSize and newSize ~= _cachedBodySize then
                        container.Size = newSize
                        _cachedBodySize = newSize
                        if #bodySliceParts > 0 then
                            local n = #bodySliceParts
                            local sW = newSize.X / n
                            for i, sInfo in ipairs(bodySliceParts) do
                                sInfo.offset = Vector3.new((i - (n + 1) * 0.5) * sW, 0, 0)
                                if sInfo.part and sInfo.part.Parent then
                                    sInfo.part.Size = Vector3.new(sW, newSize.Y, newSize.Z)
                                end
                            end
                        end
                    end
                end
            else
                -- anchor container to root part coordinates
                container.CFrame = hrpPart.CFrame
            end

            if #bodySliceParts > 0 then
                for _, sInfo in ipairs(bodySliceParts) do
                    if sInfo.part and sInfo.part.Parent then
                        sInfo.part.CFrame = container.CFrame * CFrame.new(sInfo.offset)
                    end
                end
            end

            if container.Transparency ~= 1 then container.Transparency = 1 end
            if container.CanCollide then container.CanCollide = false end
        end)

        local presetData = BODY_PARTICLE_PRESETS[bodyParticlesConfig.preset] or BODY_PARTICLE_PRESETS["Custom"]
        local textureUrl = presetData.texture or ""
        if bodyParticlesConfig.preset == "Custom" and bodyParticlesConfig.customTextureId and bodyParticlesConfig.customTextureId ~= "" then
            local raw = tostring(bodyParticlesConfig.customTextureId):gsub("%s+", "")
            local id = raw:match("(%d+)")
            if id and not raw:find("^http") then
                textureUrl = "rbxassetid://" .. id
            else
                textureUrl = raw
            end
        end

        local isAnim = presetData.isAnimated or bodyParticlesConfig.isCustomFlipbook

        local function getSafeEnum(enumType, memberName)
            if not memberName or type(memberName) ~= "string" then return nil end
            local ok, val = pcall(function()
                return enumType[memberName]
            end)
            if ok and val then return val end
            return nil
        end

        local function configureEmitter(emitter, rateToUse, colSeq)
            emitter.Name = "BodyParticleEmitter"
            emitter.Texture = textureUrl

            if isAnim then
                pcall(function()
                    local customStr = tostring(bodyParticlesConfig.customFlipbookLayout or "4x4"):gsub("%s+", "")
                    local customCols, customRows = customStr:match("^(%d+)[xX*:,](%d+)$")
                    if not customCols and customStr:match("^(%d+)$") then
                        local d = customStr:match("^(%d+)$")
                        customCols, customRows = d, d
                    end

                    local layoutToUse = presetData.flipbookLayout

                    if not layoutToUse or bodyParticlesConfig.preset == "Custom" or bodyParticlesConfig.isCustomFlipbook then
                        if customCols and customRows then
                            local c = tonumber(customCols)
                            local r = tonumber(customRows)
                            if c == 2 and r == 2 then
                                layoutToUse = Enum.ParticleFlipbookLayout.Grid2x2
                            elseif c == 4 and r == 4 then
                                layoutToUse = Enum.ParticleFlipbookLayout.Grid4x4
                            elseif c == 8 and r == 8 then
                                layoutToUse = Enum.ParticleFlipbookLayout.Grid8x8
                            else
                                local customEnum = getSafeEnum(Enum.ParticleFlipbookLayout, "Custom")
                                if customEnum then
                                    layoutToUse = customEnum
                                    pcall(function() emitter.FlipbookSize = Vector2.new(c, r) end)
                                else
                                    local maxDim = math.max(c, r)
                                    if maxDim <= 2 then
                                        layoutToUse = Enum.ParticleFlipbookLayout.Grid2x2
                                    elseif maxDim <= 4 then
                                        layoutToUse = Enum.ParticleFlipbookLayout.Grid4x4
                                    else
                                        layoutToUse = Enum.ParticleFlipbookLayout.Grid8x8
                                    end
                                    pcall(function() emitter.FlipbookSize = Vector2.new(c, r) end)
                                end
                            end
                        else
                            layoutToUse = getSafeEnum(Enum.ParticleFlipbookLayout, customStr) or Enum.ParticleFlipbookLayout.Grid4x4
                        end
                    end

                    if layoutToUse then
                        emitter.FlipbookLayout = layoutToUse
                    end

                    local modeToUse = presetData.flipbookMode or getSafeEnum(Enum.ParticleFlipbookMode, bodyParticlesConfig.customFlipbookMode) or Enum.ParticleFlipbookMode.Loop
                    emitter.FlipbookMode = modeToUse

                    local fps = tonumber(bodyParticlesConfig.flipbookPlaySpeed) or 15
                    emitter.FlipbookFramerate = NumberRange.new(fps)
                end)
            else
                pcall(function()
                    emitter.FlipbookLayout = Enum.ParticleFlipbookLayout.None
                end)
            end

            local sz = math.clamp(bodyParticlesConfig.size or 0.2, 0.01, 10.0)
            emitter.Size = NumberSequence.new(sz)

            local trans = bodyParticlesConfig.transparency or 0.2
            local fadeIn = bodyParticlesConfig.fadeIn
            local fadeOut = bodyParticlesConfig.fadeOut

            if fadeIn and fadeOut then
                emitter.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1.0),
                    NumberSequenceKeypoint.new(0.2, trans),
                    NumberSequenceKeypoint.new(0.8, trans),
                    NumberSequenceKeypoint.new(1, 1.0)
                })
            elseif fadeIn then
                emitter.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1.0),
                    NumberSequenceKeypoint.new(0.3, trans),
                    NumberSequenceKeypoint.new(1, trans)
                })
            elseif fadeOut then
                emitter.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, trans),
                    NumberSequenceKeypoint.new(1, 1.0)
                })
            else
                emitter.Transparency = NumberSequence.new(trans)
            end

            local spd = bodyParticlesConfig.speed or 0.0
            emitter.Speed = NumberRange.new(spd, spd)

            local rotSpd = bodyParticlesConfig.spin or 0
            emitter.RotSpeed = NumberRange.new(-rotSpd, rotSpd)

            local life = bodyParticlesConfig.lifetime or 1.5
            emitter.Lifetime = NumberRange.new(life * 0.8, life * 1.2)

            emitter.Rate = rateToUse

            if bodyParticlesConfig.glowing then
                emitter.LightEmission = 1.0
                emitter.LightInfluence = 0.0
            else
                emitter.LightEmission = 0.0
                emitter.LightInfluence = 1.0
            end

            if bodyParticlesConfig.anchored then
                emitter.LockedToPart = true
            else
                emitter.LockedToPart = false
            end

            local orientMode = bodyParticlesConfig.orientation or "Camera"
            pcall(function()
                if orientMode == "VelocityParallel" then
                    emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
                elseif orientMode == "VelocityPerpendicular" then
                    emitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
                else
                    emitter.Orientation = Enum.ParticleOrientation.Camera
                end
            end)

            emitter.Color = colSeq
        end

        local isRainbow2 = (bodyParticlesConfig.colorMode == "Rainbow 2")
        local numSlices = isRainbow2 and 5 or 1
        local sliceWidth = boxSize.X / numSlices
        local baseRate = bodyParticlesConfig.rate or 10
        local ratePerSlice = isRainbow2 and math.max(1, math.ceil(baseRate / numSlices)) or baseRate
        local shiftSpeed = state and state.colorShiftSpeed or 3
        local phase = (tick() * (shiftSpeed * 0.15)) % 1.0

        for i = 1, numSlices do
            local parentPart = container
            local colSeq = nil
            if isRainbow2 then
                local slice = Instance.new("Part")
                slice.Name = "BodyParticleSlice"
                slice.Size = Vector3.new(sliceWidth, boxSize.Y, boxSize.Z)
                local xOffset = (i - (numSlices + 1) * 0.5) * sliceWidth
                slice.CFrame = container.CFrame * CFrame.new(xOffset, 0, 0)
                slice.Transparency = 1
                slice.CanCollide = false
                slice.CanTouch = false
                slice.CanQuery = false
                slice.CastShadow = false
                slice.Massless = true
                slice.Anchored = false
                slice.Parent = container
                table.insert(bodySliceParts, {part = slice, offset = Vector3.new(xOffset, 0, 0)})
                parentPart = slice

                local frac = (i - 1) / numSlices
                local hue = (phase - frac) % 1.0
                if hue < 0 then hue = hue + 1 end
                colSeq = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.1) % 1.0, 1, 1))
                })
            else
                colSeq = getParticleColors(bodyParticlesConfig.colorMode, bodyParticlesConfig.color1, bodyParticlesConfig.color2)
            end

            local emitter = Instance.new("ParticleEmitter")
            configureEmitter(emitter, ratePerSlice, colSeq)
            emitter.Parent = parentPart
            table.insert(bodyParticleEmitters, emitter)
        end
    end

    local function updateBodyParticlesColors()
        if not bodyParticlesConfig.enabled then return end
        local mode = bodyParticlesConfig.colorMode
        local shiftSpeed = state and state.colorShiftSpeed or 3
        local phase = (tick() * (shiftSpeed * 0.15)) % 1.0

        if mode == "Rainbow 2" and #bodyParticleEmitters > 1 then
            local n = #bodyParticleEmitters
            for i, emitter in ipairs(bodyParticleEmitters) do
                if emitter and emitter.Parent then
                    local frac = (i - 1) / n
                    local hue = (phase - frac) % 1.0
                    if hue < 0 then hue = hue + 1 end
                    emitter.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.1) % 1.0, 1, 1))
                    })
                end
            end
        else
            for _, emitter in ipairs(bodyParticleEmitters) do
                if emitter and emitter.Parent then
                    emitter.Color = getParticleColors(bodyParticlesConfig.colorMode, bodyParticlesConfig.color1, bodyParticlesConfig.color2)
                end
            end
        end
    end

    local translucentDescConn = nil
    trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        table.clear(originalBodyProperties)
        if translucentDescConn then pcall(function() translucentDescConn:Disconnect() end) translucentDescConn = nil end
        if translucentBodyConfig.enabled then
            task.wait(0.3)
            applyTranslucentBody()
            translucentDescConn = char.DescendantAdded:Connect(function(desc)
                if translucentBodyConfig.enabled and desc:IsA("BasePart") then
                    task.wait(0.05)
                    applyTranslucentBody()
                end
            end)
        end
        if bodyParticlesConfig.enabled then
            task.wait(0.3)
            applyBodyParticles()
        end
    end))

    local function removeAllTrails(char)
        localTrail = nil
        char = char or LocalPlayer.Character
        if char then
            for _, desc in ipairs(char:GetDescendants()) do
                if desc:IsA("Trail") and desc.Name == "Trail" then
                    pcall(function() desc:Destroy() end)
                elseif desc:IsA("Attachment") and (desc.Name == "TrailAtt1" or desc.Name == "TrailAtt2") then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
    end

    local function applyTrail(char)
        char = char or LocalPlayer.Character
        if not char then return end
        removeAllTrails(char)
        local parentPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not parentPart then return end
    
        local w = math.clamp(tonumber(trailConfig.width) or 1.0, 0.1, 10)
        local att1 = Instance.new("Attachment", parentPart)
        att1.Name = "TrailAtt1"
        att1.Position = Vector3.new(0, w, 0)
    
        local att2 = Instance.new("Attachment", parentPart)
        att2.Name = "TrailAtt2"
        att2.Position = Vector3.new(0, -w, 0)
    
        local t = Instance.new("Trail", parentPart)
        t.Name = "Trail"
        t.Attachment0 = att1
        t.Attachment1 = att2
        t.Texture = "rbxassetid://446111271"
        t.TextureMode = Enum.TextureMode.Stretch
        t.Color = getTrailColors()
        t.Lifetime = math.clamp(tonumber(trailConfig.lifetime) or 1.0, 0.05, 10)
        local trans = math.clamp(tonumber(trailConfig.transparency) or 0, 0, 0.95)
        t.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, trans), NumberSequenceKeypoint.new(1, 1) })
        t.LightEmission = 0.8
        t.LightInfluence = 0
        t.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2) })
        t.FaceCamera = true
        localTrail = t
    end

    local function updateTrailProps()
        if not trailConfig.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local parentPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not parentPart then return end

        local att1 = parentPart:FindFirstChild("TrailAtt1")
        local att2 = parentPart:FindFirstChild("TrailAtt2")
        if not localTrail or not localTrail.Parent or not att1 or not att2 then
            applyTrail(char)
            return
        end

        local w = math.clamp(tonumber(trailConfig.width) or 1.0, 0.1, 10)
        att1.Position = Vector3.new(0, w, 0)
        att2.Position = Vector3.new(0, -w, 0)
        localTrail.Texture = "rbxassetid://446111271"
        localTrail.TextureMode = Enum.TextureMode.Stretch
        localTrail.Color = getTrailColors()
        localTrail.Lifetime = math.clamp(tonumber(trailConfig.lifetime) or 1.0, 0.05, 10)
        local trans = math.clamp(tonumber(trailConfig.transparency) or 0, 0, 0.95)
        localTrail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, trans), NumberSequenceKeypoint.new(1, 1) })
        localTrail.LightEmission = 0.8
        localTrail.LightInfluence = 0
    end

    local function removeOrb()
        if localOrb then
            pcall(function() localOrb:Destroy() end)
            localOrb = nil
        end
    end

    local function applyOrb()
        removeOrb()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local orb = Instance.new("Part")
        orb.Name = "OrbitingOrb"
        orb.Shape = Enum.PartType.Ball
        orb.Size = Vector3.new(orbConfig.size, orbConfig.size, orbConfig.size)
        orb.CanCollide = false
        orb.CanQuery   = false
        orb.CanTouch   = false
        orb.Anchored = true
        orb.Transparency = 1
        orb.Parent = char

        local bgui = Instance.new("BillboardGui", orb)
        bgui.Name = "OrbGui"
        bgui.Size = UDim2.new(orbConfig.size * 3, 0, orbConfig.size * 3, 0)
        bgui.AlwaysOnTop = false
        bgui.LightInfluence = 0

        local orbColor = getColor(orbConfig.colorMode, orbConfig.color1, orbConfig.color2)

        local img = Instance.new("ImageLabel", bgui)
        img.Name = "OrbImage"
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Image = "http://www.roblox.com/asset/?id=112882057182762"
        img.ImageColor3 = orbColor
        img.Rotation = 0

        local light = Instance.new("PointLight", orb)
        light.Name = "OrbLight"
        light.Color = orbColor
        light.Brightness = orbConfig.brightness
        light.Range = orbConfig.range

        local att1 = Instance.new("Attachment", orb)
        att1.Name = "OrbAtt1"
        att1.Position = Vector3.new(0, orbConfig.size / 2, 0)

        local att2 = Instance.new("Attachment", orb)
        att2.Name = "OrbAtt2"
        att2.Position = Vector3.new(0, -orbConfig.size / 2, 0)

        local trail = Instance.new("Trail", orb)
        trail.Name = "OrbTrail"
        trail.Attachment0 = att1
        trail.Attachment1 = att2
        trail.Color = ColorSequence.new(orbColor)
        trail.Lifetime = 0.8
        trail.WidthScale = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.8),
                NumberSequenceKeypoint.new(1, 0)
        })
        trail.LightEmission = 0.57
        trail.FaceCamera = true

        localOrb = orb
    end

    local crosshairConfig, updateCrosshair, removeCrosshair
    local visualHeartbeatConn = nil
    local function startVisualUpdates()
        if visualHeartbeatConn then return end
        local _vHBFrame = 0
        visualHeartbeatConn = RunService.Heartbeat:Connect(function(dt)
            if state.unloaded then
                if visualHeartbeatConn then pcall(function() visualHeartbeatConn:Disconnect() end) visualHeartbeatConn = nil end
                return
            end
            _vHBFrame = _vHBFrame + 1
            -- compute common transformation factors once per frame
            local speed = state and state.colorShiftSpeed or 3
            rainbowHue = (rainbowHue + dt * (speed * 0.15)) % 1.0
            _G.rainbowHue = rainbowHue
            local _t = tick()
            local _gradTVal = (math.sin(_t * speed) + 1) * 0.5

            if trailConfig.enabled and localTrail and localTrail.Parent then
                if trailConfig.colorMode ~= "Normal" then
                    localTrail.Color = getTrailColors()
                end
            end

            -- throttle palette updates for body, particles, and hat
            if _vHBFrame % 3 == 0 then
                if translucentBodyConfig.enabled and translucentBodyConfig.colorMode ~= "Normal" then
                    applyTranslucentBody()
                end

                if bodyParticlesConfig.enabled and bodyParticlesConfig.colorMode ~= "Normal" then
                    updateBodyParticlesColors()
                end

                if chinaHatConfig.enabled then
                    updateHatColors()
                end
            end

            if wingsConfig.enabled then
                local flapSpeed = wingsConfig.speed or 3.5
                local flapAngle = math.sin(_t * flapSpeed) * math.rad(14)
                -- avoid redundant palette calculations across wings
                local curColor = getColor(wingsConfig.colorMode, wingsConfig.color1, wingsConfig.color2)

                for player, w in pairs(wingsParts) do
                    local char = player.Character
                    local root = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
                    if root and w.left and w.left.Parent and w.right and w.right.Parent then
                        local zCompensation = math.sin(_t * flapSpeed) * -0.23
                        local xCompensation = math.sin(_t * flapSpeed) * 0.12
                        local backCF = root.CFrame * CFrame.new(0, wingsConfig.posY, wingsConfig.posZ)

                        w.left.CFrame  = backCF * CFrame.new(-wingsConfig.posX - xCompensation, 0, zCompensation) * CFrame.Angles(0, math.rad(15) - flapAngle, math.rad(-5))
                        w.right.CFrame = backCF * CFrame.new(wingsConfig.posX + xCompensation, 0, zCompensation) * CFrame.Angles(0, math.rad(-15) + flapAngle, math.rad(5))

                        w.left.CanCollide = false
                        w.right.CanCollide = false
                        w.left.Transparency  = wingsConfig.transparency
                        w.right.Transparency = wingsConfig.transparency

                        w.left.Color  = curColor
                        w.right.Color = curColor

                        if w.emitterL then w.emitterL.Color = ColorSequence.new(curColor) end
                        if w.emitterR then w.emitterR.Color = ColorSequence.new(curColor) end
                        if w.lightL then w.lightL.Color = curColor end
                        if w.lightR then w.lightR.Color = curColor end
                    end
                end
            end

            if orbConfig.enabled then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not localOrb or localOrb.Parent ~= char then
                        applyOrb()
                    end

                    if localOrb then
                        orbRotationAngle = (orbRotationAngle + dt * orbConfig.speed) % (math.pi * 2)
                        local t = _t
                        local radius = orbConfig.radius

                        local maxTiltRad = math.rad(25)
                        local tiltAngle  = math.sin(t * 0.5) * maxTiltRad

                        local horizRadius = math.cos(tiltAngle) * radius
                        local vertOffset  = math.sin(tiltAngle) * radius * math.sin(orbRotationAngle)

                        local offset = Vector3.new(
                            math.cos(orbRotationAngle) * horizRadius,
                            vertOffset,
                            math.sin(orbRotationAngle) * horizRadius
                        )
                        localOrb.Position = hrp.Position + Vector3.new(0, 0.5, 0) + offset
                    
                        local bgui = localOrb:FindFirstChild("OrbGui")
                        local img = bgui and bgui:FindFirstChild("OrbImage")
                        if img then
                            img.Rotation = (img.Rotation + dt * 180) % 360
                        end

                        local currentOrbColor = getColor(orbConfig.colorMode, orbConfig.color1, orbConfig.color2)
                        local light = localOrb:FindFirstChild("OrbLight")
                        local trail = localOrb:FindFirstChild("OrbTrail")

                        if img then img.ImageColor3 = currentOrbColor end
                        if light then light.Color = currentOrbColor end

                        if img then
                            if orbConfig.colorMode == "Gradient" or orbConfig.colorMode == "Gradient 2" or orbConfig.colorMode == "Rainbow" or orbConfig.colorMode == "Rainbow 2" then
                                local uiGrad = img:FindFirstChildOfClass("UIGradient")
                                if not uiGrad then
                                    uiGrad = Instance.new("UIGradient")
                                    uiGrad.Parent = img
                                end
                                local c1 = orbConfig.color1 or Color3.new(1, 1, 1)
                                local c2 = orbConfig.color2 or Color3.new(0, 170, 255)
                                local phase = (tick() * (speed * 0.15)) % 1.0

                                if orbConfig.colorMode == "Gradient" then
                                    uiGrad.Enabled = true
                                    uiGrad.Rotation = (uiGrad.Rotation + dt * (speed * 60)) % 360
                                    uiGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, c1),
                                        ColorSequenceKeypoint.new(0.5, c2),
                                        ColorSequenceKeypoint.new(1, c1)
                                    })
                                    img.ImageColor3 = Color3.new(1, 1, 1)
                                elseif orbConfig.colorMode == "Gradient 2" then
                                    uiGrad.Enabled = true
                                    uiGrad.Rotation = 0
                                    local function getSmoothCol(off)
                                        local tVal = (math.sin((phase + off) * math.pi * 2) + 1) * 0.5
                                        return c1:Lerp(c2, tVal)
                                    end
                                    uiGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0,    getSmoothCol(0)),
                                        ColorSequenceKeypoint.new(0.25, getSmoothCol(0.25)),
                                        ColorSequenceKeypoint.new(0.5,  getSmoothCol(0.5)),
                                        ColorSequenceKeypoint.new(0.75, getSmoothCol(0.75)),
                                        ColorSequenceKeypoint.new(1,    getSmoothCol(1))
                                    })
                                    img.ImageColor3 = Color3.new(1, 1, 1)
                                elseif orbConfig.colorMode == "Rainbow" then
                                    uiGrad.Enabled = true
                                    uiGrad.Rotation = (uiGrad.Rotation + dt * (speed * 60)) % 360
                                    uiGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0,    Color3.fromHSV(0.00, 1, 1)),
                                        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                                        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                                        ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
                                        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                                        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                                        ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1))
                                    })
                                    img.ImageColor3 = Color3.new(1, 1, 1)
                                elseif orbConfig.colorMode == "Rainbow 2" then
                                    uiGrad.Enabled = true
                                    uiGrad.Rotation = 0
                                    uiGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0,    Color3.fromHSV((0.00 + phase) % 1, 1, 1)),
                                        ColorSequenceKeypoint.new(0.17, Color3.fromHSV((0.17 + phase) % 1, 1, 1)),
                                        ColorSequenceKeypoint.new(0.33, Color3.fromHSV((0.33 + phase) % 1, 1, 1)),
                                        ColorSequenceKeypoint.new(0.50, Color3.fromHSV((0.50 + phase) % 1, 1, 1)),
                                        ColorSequenceKeypoint.new(0.67, Color3.fromHSV((0.67 + phase) % 1, 1, 1)),
                                        ColorSequenceKeypoint.new(0.83, Color3.fromHSV((0.83 + phase) % 1, 1, 1)),
                                        ColorSequenceKeypoint.new(1.00, Color3.fromHSV((1.00 + phase) % 1, 1, 1))
                                    })
                                    img.ImageColor3 = Color3.new(1, 1, 1)
                                end
                            else
                                local oldGrad = img:FindFirstChildOfClass("UIGradient")
                                if oldGrad then oldGrad.Enabled = false end
                                img.ImageColor3 = currentOrbColor
                            end
                        end

                        if trail then
                            trail.Color = getParticleColors(orbConfig.colorMode, orbConfig.color1, orbConfig.color2)
                        end
                    end
                else
                    removeOrb()
                end
            else
                removeOrb()
            end

            if trailConfig.enabled and localTrail and localTrail.Parent then
                local cMode = trailConfig.colorMode
                if cMode == "Rainbow" or cMode == "Rainbow 2" or cMode == "Shift" or cMode == "2 colors" or cMode == "Gradient" or cMode == "Gradient 2" then
                    localTrail.Color = getTrailColors()
                end
            end

            if chinaHatConfig.enabled then
                if updateHatColors then updateHatColors() end
            end
            if wingsConfig.enabled then
                if updateWings then updateWings() end
            end
        end)
        trackConnection(visualHeartbeatConn)
    end
    startVisualUpdates()

    trackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if trailConfig.enabled then
            pcall(function() applyTrail(char) end)
        end
        if orbConfig.enabled then
            pcall(function() applyOrb() end)
        end
    end))

    registerCleanupHook(function()
        local char = LocalPlayer.Character
        if char then
            removeAllTrails(char)
            removeOrb()
        end
        if removeCrosshair then pcall(removeCrosshair) end
    end)

    -- draw customizable center-screen reticle 
    removeCrosshair = nil
    local crosshairPresets = {
        ["Heart"]                  = { texture = "rbxassetid://11754490323" },
        ["Parenthesis"]            = { texture = "rbxassetid://10872863389" },
        [">.<"]                    = { texture = "rbxassetid://10831379335" },
        ["somename (animated)"]    = { texture = "http://www.roblox.com/asset/?id=77885757570841", isAnimated = true, gridX = 4, gridY = 4, fps = 15 },
        ["shockwave (animated)"]   = { texture = "http://www.roblox.com/asset/?id=9872919636", isAnimated = true, gridX = 4, gridY = 4, fps = 15 },
        ["pixel shockwave (animated)"] = { texture = "http://www.roblox.com/asset/?id=11817698226", isAnimated = true, gridX = 8, gridY = 8, fps = 20 },
        ["maxwell (animated)"]     = { texture = "http://www.roblox.com/asset/?id=12890944256", isAnimated = true, gridX = 4, gridY = 4, fps = 15 }
    }

    crosshairConfig = {
        enabled = false,
        preset = "Parenthesis",
        customAssetId = "",
        size = 50,
        color = Color3.fromRGB(255, 255, 255),
        color1 = Color3.fromRGB(255, 255, 255),
        color2 = Color3.fromRGB(0, 170, 255),
        colorMode = "Normal",
        transparency = 0,
        followCursor = false,
        spinEnabled = false,
        spinSpeed = 180,
        rainbowEnabled = false,
        isCustomFlipbook = false,
        customFlipbookLayout = "Grid4x4",
        customFlipbookMode = "Loop",
        flipbookPlaySpeed = 15
    }

    local crosshairGui = nil
    local crosshairImage = nil
    local crosshairConn = nil
    local crosshairThread = nil

    local function formatAssetId(rawInput)
        if not rawInput or rawInput == "" then return "" end
        local id = rawInput:match("%d+")
        if id then
            return "rbxassetid://" .. id
        end
        return rawInput
    end

    local function getCrosshairData()
        if crosshairConfig.preset == "Custom" then
            local data = { texture = formatAssetId(crosshairConfig.customAssetId) }
            if crosshairConfig.isCustomFlipbook then
                data.isAnimated = true
                local customStr = tostring(crosshairConfig.customFlipbookLayout or "4x4"):gsub("%s+", "")
                local cols, rows = customStr:match("^(%d+)[xX*:,](%d+)$")
                if not cols and customStr:match("^(%d+)$") then
                    local d = customStr:match("^(%d+)$")
                    cols, rows = d, d
                end
                data.gridX = tonumber(cols) or 4
                data.gridY = tonumber(rows) or 4
                data.fps = tonumber(crosshairConfig.flipbookPlaySpeed) or 15
                data.flipbookMode = crosshairConfig.customFlipbookMode or "Loop"
            end
            return data
        end
        local data = crosshairPresets[crosshairConfig.preset] or { texture = "rbxassetid://10872863389" }
        local res = {}
        for k, v in pairs(data) do res[k] = v end
        if res.isAnimated then
            if crosshairConfig.flipbookPlaySpeed then res.fps = crosshairConfig.flipbookPlaySpeed end
            res.flipbookMode = crosshairConfig.customFlipbookMode or "Loop"
        end
        return res
    end

    local function getCrosshairAsset()
        local data = getCrosshairData()
        return data.texture or "rbxassetid://10872863389"
    end

    updateCrosshair = nil
    local createCrosshair = function() if updateCrosshair then updateCrosshair() end end

    removeCrosshair = function()
        if crosshairConn then
            pcall(function() crosshairConn:Disconnect() end)
            crosshairConn = nil
        end
        if crosshairThread then
            pcall(function() task.cancel(crosshairThread) end)
            crosshairThread = nil
        end
        if crosshairImage then
            pcall(function() crosshairImage:Destroy() end)
            crosshairImage = nil
        end
        pcall(function() UserInputService.MouseIconEnabled = true end)
        pcall(function()
            local m = LocalPlayer:GetMouse()
            if m then m.Icon = "" end
        end)
        pcall(function() UserInputService.MouseIcon = "" end)
    end

    updateCrosshair = function()
        removeCrosshair()
        if not crosshairConfig.enabled then return end

        if not fovCircleGui or not fovCircleGui.Parent then
            local parentGui = gethui and gethui() or (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or PlayerGui)
            local sg = Instance.new("ScreenGui")
            sg.Name = "FOVCircleGui"
            sg.ResetOnSpawn = false
            sg.IgnoreGuiInset = true
            sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            sg.DisplayOrder = 2147483647
            pcall(function()
                if syn and syn.protect_gui then syn.protect_gui(sg) end
            end)
            sg.Parent = parentGui
            fovCircleGui = sg
        end

        local img = Instance.new("ImageLabel")
        img.Name = "CrosshairImage"
        img.AnchorPoint = Vector2.new(0.5, 0.5)
        img.BackgroundTransparency = 1
        img.Active = false
        img.Size = UDim2.fromOffset(crosshairConfig.size, crosshairConfig.size)
        img.Position = UDim2.new(0.5, 0, 0.5, 0)
        img.Image = getCrosshairAsset()
        img.ImageColor3 = getColor(crosshairConfig.colorMode, crosshairConfig.color1, crosshairConfig.color2)
        img.ImageTransparency = crosshairConfig.transparency
        img.ZIndex = 2147483647
        img.Parent = fovCircleGui

        crosshairGui = fovCircleGui
        crosshairImage = img

        local frameIndex = 0
        local lastFrameTime = tick()
        local pingPongForward = true

        crosshairConn = RunService.RenderStepped:Connect(function(dt)
            if not crosshairConfig.enabled or not crosshairImage or not crosshairImage.Parent then return end
            
            local data = getCrosshairData()
            local assetId = data.texture or "rbxassetid://10872863389"
            crosshairImage.Image = assetId
            crosshairImage.Size = UDim2.fromOffset(crosshairConfig.size, crosshairConfig.size)
            crosshairImage.ImageTransparency = crosshairConfig.transparency

            -- animate flipbook textures across frames
            if data.isAnimated and data.gridX and data.gridY then
                local fps = data.fps or 15
                local interval = 1 / fps
                if tick() - lastFrameTime >= interval then
                    lastFrameTime = tick()
                    local totalFrames = data.gridX * data.gridY
                    local mode = data.flipbookMode or crosshairConfig.customFlipbookMode or "Loop"

                    if mode == "OneShot" then
                        frameIndex = math.min(frameIndex + 1, totalFrames - 1)
                    elseif mode == "PingPong" then
                        if pingPongForward then
                            frameIndex = frameIndex + 1
                            if frameIndex >= totalFrames - 1 then
                                frameIndex = totalFrames - 1
                                pingPongForward = false
                            end
                        else
                            frameIndex = frameIndex - 1
                            if frameIndex <= 0 then
                                frameIndex = 0
                                pingPongForward = true
                            end
                        end
                    else -- loop sprite playback continuously
                        frameIndex = (frameIndex + 1) % totalFrames
                    end
                end
                local col = frameIndex % data.gridX
                local row = math.floor(frameIndex / data.gridX)
                pcall(function()
                    if crosshairImage.ContentImageSize and crosshairImage.ContentImageSize.X > 0 then
                        local imgW = crosshairImage.ContentImageSize.X
                        local imgH = crosshairImage.ContentImageSize.Y
                        local frameW = imgW / data.gridX
                        local frameH = imgH / data.gridY
                        crosshairImage.ImageRectSize = Vector2.new(frameW, frameH)
                        crosshairImage.ImageRectOffset = Vector2.new(col * frameW, row * frameH)
                    else
                        local frameW = 256 / data.gridX
                        local frameH = 256 / data.gridY
                        crosshairImage.ImageRectSize = Vector2.new(frameW, frameH)
                        crosshairImage.ImageRectOffset = Vector2.new(col * frameW, row * frameH)
                    end
                end)
            else
                crosshairImage.ImageRectSize = Vector2.zero
                crosshairImage.ImageRectOffset = Vector2.zero
            end

            local uiGrad = crosshairImage:FindFirstChildOfClass("UIGradient")
            if not uiGrad then
                uiGrad = Instance.new("UIGradient")
                uiGrad.Name = "CrosshairGradient"
                uiGrad.Parent = crosshairImage
            end

            local mode = crosshairConfig.colorMode or "Normal"
            local c1 = crosshairConfig.color1 or Color3.fromRGB(255, 255, 255)
            local c2 = crosshairConfig.color2 or Color3.fromRGB(0, 170, 255)
            local speed = state and state.colorShiftSpeed or 3
            local phase = (tick() * (speed * 0.15)) % 1.0

            if mode == "Gradient" then
                uiGrad.Enabled = true
                uiGrad.Rotation = (uiGrad.Rotation + dt * (speed * 60)) % 360
                uiGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c1),
                    ColorSequenceKeypoint.new(0.5, c2),
                    ColorSequenceKeypoint.new(1, c1)
                })
                crosshairImage.ImageColor3 = Color3.new(1, 1, 1)
            elseif mode == "Gradient 2" then
                uiGrad.Enabled = true
                uiGrad.Rotation = 0
                local function getSmoothCol(off)
                    local tVal = (math.sin((phase - off) * math.pi * 2) + 1) * 0.5
                    return c1:Lerp(c2, tVal)
                end
                uiGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    getSmoothCol(0)),
                    ColorSequenceKeypoint.new(0.25, getSmoothCol(0.25)),
                    ColorSequenceKeypoint.new(0.5,  getSmoothCol(0.5)),
                    ColorSequenceKeypoint.new(0.75, getSmoothCol(0.75)),
                    ColorSequenceKeypoint.new(1,    getSmoothCol(1))
                })
                crosshairImage.ImageColor3 = Color3.new(1, 1, 1)
            elseif mode == "Shift" then
                uiGrad.Enabled = true
                uiGrad.Rotation = 0
                local function shiftCol(off)
                    local tVal = (math.sin((phase - off) * math.pi * 2) + 1) * 0.5
                    return c1:Lerp(c2, tVal)
                end
                uiGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    shiftCol(0)),
                    ColorSequenceKeypoint.new(0.25, shiftCol(0.25)),
                    ColorSequenceKeypoint.new(0.5,  shiftCol(0.5)),
                    ColorSequenceKeypoint.new(0.75, shiftCol(0.75)),
                    ColorSequenceKeypoint.new(1,    shiftCol(1))
                })
                crosshairImage.ImageColor3 = Color3.new(1, 1, 1)
            elseif mode == "Rainbow" then
                uiGrad.Enabled = true
                uiGrad.Rotation = (uiGrad.Rotation + dt * (speed * 60)) % 360
                uiGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0.00, 1, 1)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1))
                })
                crosshairImage.ImageColor3 = Color3.new(1, 1, 1)
            elseif mode == "Rainbow 2" then
                uiGrad.Enabled = true
                uiGrad.Rotation = 0
                local function getRainbowCol(off)
                    return Color3.fromHSV((phase - off) % 1, 1, 1)
                end
                uiGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    getRainbowCol(0)),
                    ColorSequenceKeypoint.new(0.17, getRainbowCol(0.17)),
                    ColorSequenceKeypoint.new(0.33, getRainbowCol(0.33)),
                    ColorSequenceKeypoint.new(0.50, getRainbowCol(0.50)),
                    ColorSequenceKeypoint.new(0.67, getRainbowCol(0.67)),
                    ColorSequenceKeypoint.new(0.83, getRainbowCol(0.83)),
                    ColorSequenceKeypoint.new(1.00, getRainbowCol(1))
                })
                crosshairImage.ImageColor3 = Color3.new(1, 1, 1)
            else
                uiGrad.Enabled = false
                crosshairImage.ImageColor3 = getColor(mode, c1, c2)
            end

            if crosshairConfig.followCursor then
                pcall(function() UserInputService.MouseIconEnabled = false end)
                local mouseLoc = UserInputService:GetMouseLocation()
                crosshairImage.Position = UDim2.fromOffset(mouseLoc.X, mouseLoc.Y)
            else
                pcall(function() UserInputService.MouseIconEnabled = true end)
                crosshairImage.Position = UDim2.new(0.5, 0, 0.5, 0)
            end

            if crosshairConfig.spinEnabled then
                crosshairImage.Rotation = (crosshairImage.Rotation + dt * crosshairConfig.spinSpeed) % 360
            end
        end)
        trackConnection(crosshairConn)
    end




    -- construct visual esp and chams configurations
    Tabs.Visuals:AddSection("Value calculator")
    Tabs.Visuals:AddToggle("ValueCalculatorEnabled", {
        Title = "Trade & inventory values",
        Default = true,
        Callback = function(v)
            state.valueCalculatorEnabled = v
        end
    })

    Tabs.Visuals:AddSection("Player esp")

    -- group visual tracking checkboxes
    mdTabs.Visuals:AddToggleGroup({
        { Name = "Enable ESP", Default = false, Callback = function(v) state.espEnabled = v end },
        { Name = "Esp chams", Default = true, Callback = function(v) state.chamsEnabled = v end },
        { Name = "Esp box", Default = false, Callback = function(v) state.boxEspEnabled = v end },
        { Name = "Esp name", Default = true, Callback = function(v) state.nameEspEnabled = v end },
        { Name = "Esp role", Default = true, Callback = function(v) state.roleEspEnabled = v end },
        { Name = "Gun ESP", Default = true, Callback = function(v) state.gunEspEnabled = v end }
    })

    Tabs.Visuals:AddSlider("ESPMaxDistance", {
        Title = "Esp max render distance",
        Min = 100,
        Max = 5000,
        Default = 1000,
        Suffix = " studs",
        Callback = function(v)
            state.espMaxDistance = v
        end
    })

    Tabs.Visuals:AddDropdown("ChamsMode", {
        Title = "Chams mode",
        Values = {"Highlight", "Glow Outline", "Fill Only", "Box Adornment"},
        Default = "Highlight",
        Callback = function(v)
            state.chamsMode = v
        end
    })

    Tabs.Visuals:AddGroup({
        {
            Id = "ChamsMurdererColor",
            Type = "ColorPicker",
            Title = "Murderer chams color",
            Default = Color3.fromRGB(255, 70, 70),
            Callback = function(c) state.chamsMurdererColor = c end
        },
        {
            Id = "ChamsSheriffColor",
            Type = "ColorPicker",
            Title = "Sheriff chams color",
            Default = Color3.fromRGB(90, 120, 255),
            Callback = function(c) state.chamsSheriffColor = c end
        },
        {
            Id = "ChamsInnocentColor",
            Type = "ColorPicker",
            Title = "Innocent chams color",
            Default = Color3.fromRGB(50, 230, 110),
            Callback = function(c) state.chamsInnocentColor = c end
        }
    })

    Tabs.Visuals:AddSection("Body stuff")
    Tabs.Visuals:AddGroup({
        {
            Id = "TranslucentBodyEnabled",
            Type = "Toggle",
            Title = "Translucent body",
            Default = false,
            Callback = function(v)
                translucentBodyConfig.enabled = v
                applyTranslucentBody()
            end
        },
        {
            Id = "TranslucentBodyColorMode",
            Type = "Dropdown",
            Title = "Body color mode",
            Values = {"Normal", "Rainbow", "Shift", "Gradient"},
            Default = "Normal",
            Callback = function(v)
                translucentBodyConfig.colorMode = v
                applyTranslucentBody()
            end
        },
        {
            Id = "TranslucentBodyColor1",
            Type = "ColorPicker",
            Title = "Body primary color",
            Default = Color3.fromRGB(0, 170, 255),
            Callback = function(c)
                translucentBodyConfig.color1 = c
                applyTranslucentBody()
            end
        },
        {
            Id = "TranslucentBodyColor2",
            Type = "ColorPicker",
            Title = "Body secondary color",
            Default = Color3.fromRGB(255, 0, 128),
            Callback = function(c)
                translucentBodyConfig.color2 = c
                applyTranslucentBody()
            end
        }
    })

    Tabs.Visuals:AddGroup({
        {
            Id = "BodyParticlesEnabled",
            Type = "Toggle",
            Title = "Body particles",
            Default = false,
            Callback = function(v)
                bodyParticlesConfig.enabled = v
                if v then applyBodyParticles() else removeBodyParticles() end
            end
        },
        {
            Id = "BodyParticlesPreset",
            Type = "Dropdown",
            Title = "Particle preset",
            Values = {
                "Hexagon",
                "Triangle",
                "Heart",
                "Square",
                "Smoke (animated)",
                "Pixel sparkle (animated)",
                "Spinning robux (animated)",
                "Bat (animated)",
                "Potion particle (animated)",
                "Wingdings (animated)",
                "YouAreAnIdiot (animated)",
                "Eye (animated)",
                "Dollar (animated)",
                "maxwell (animated)",
                "Triangle shard (animated)",
                "Custom"
            },
            Default = "Pixel sparkle (animated)",
            Callback = function(v)
                bodyParticlesConfig.preset = v
                applyBodyParticles()
            end
        },
        {
            Id = "BodyParticlesCustomId",
            Type = "Input",
            Title = "Custom particle asset id",
            Default = "",
            Placeholder = "rbxassetid://...",
            Callback = function(text)
                bodyParticlesConfig.customTextureId = text
                applyBodyParticles()
            end
        }
    })

    Tabs.Visuals:AddGroup({
        {
            Id = "BodyParticlesCustomFlipbook",
            Type = "Toggle",
            Title = "Particle flipbook animation",
            Default = false,
            Callback = function(v)
                bodyParticlesConfig.isCustomFlipbook = v
                applyBodyParticles()
            end
        },
        {
            Id = "BodyParticlesFlipbookLayout",
            Type = "Input",
            Title = "Flipbook layout (grid)",
            Default = "Grid4x4",
            Placeholder = "Grid2x2, Grid4x4, Grid8x8",
            Callback = function(text)
                bodyParticlesConfig.customFlipbookLayout = text
                applyBodyParticles()
            end
        },
        {
            Id = "BodyParticlesFlipbookMode",
            Type = "Dropdown",
            Title = "Flipbook mode",
            Values = {"Loop", "OneShot", "PingPong"},
            Default = "Loop",
            Callback = function(v)
                bodyParticlesConfig.customFlipbookMode = v
                applyBodyParticles()
            end
        },
        {
            Id = "BodyParticlesFlipbookSpeed",
            Type = "Slider",
            Title = "Flipbook play speed",
            Min = 1,
            Max = 60,
            Default = 15,
            Suffix = " fps",
            Callback = function(v)
                bodyParticlesConfig.flipbookPlaySpeed = v
                applyBodyParticles()
            end
        }
    })

    Tabs.Visuals:AddGroup({
        {
            Id = "BodyParticlesColorMode",
            Type = "Dropdown",
            Title = "Particle color mode",
            Values = {"Normal", "Rainbow", "Rainbow 2", "Shift", "Gradient"},
            Default = "Normal",
            Callback = function(v)
                bodyParticlesConfig.colorMode = v
                applyBodyParticles()
            end
        },
        {
            Id = "BodyParticlesColor1",
            Type = "ColorPicker",
            Title = "Particle primary color",
            Default = Color3.fromRGB(255, 255, 255),
            Callback = function(c)
                bodyParticlesConfig.color1 = c
                applyBodyParticles()
            end
        },
        {
            Id = "BodyParticlesColor2",
            Type = "ColorPicker",
            Title = "Particle secondary color",
            Default = Color3.fromRGB(0, 0, 0),
            Callback = function(c)
                bodyParticlesConfig.color2 = c
                applyBodyParticles()
            end
        }
    })

    Tabs.Visuals:AddSlider("BodyParticlesSize", {
        Title = "Particle size",
        Min = 0.01,
        Max = 3,
        Default = 0.2,
        Increment = 0.01,
        Rounding = 2,
        Suffix = "",
        Callback = function(v)
            bodyParticlesConfig.size = v
            applyBodyParticles()
        end
    })

    Tabs.Visuals:AddSlider("BodyParticlesTransparency", {
        Title = "Particle transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(v)
            bodyParticlesConfig.transparency = v / 100
            applyBodyParticles()
        end
    })

    Tabs.Visuals:AddSlider("BodyParticlesSpeed", {
        Title = "Particle speed",
        Min = -10,
        Max = 10,
        Default = 0,
        Increment = 0.1,
        Rounding = 1,
        Suffix = "",
        Callback = function(v)
            bodyParticlesConfig.speed = v
            applyBodyParticles()
        end
    })

    Tabs.Visuals:AddSlider("BodyParticlesSpin", {
        Title = "Particle spin",
        Min = -360,
        Max = 360,
        Default = 0,
        Suffix = " deg/s",
        Callback = function(v)
            bodyParticlesConfig.spin = v
            applyBodyParticles()
        end
    })

    Tabs.Visuals:AddSlider("BodyParticlesLifetime", {
        Title = "Particle lifetime",
        Min = 0.1,
        Max = 20,
        Default = 5,
        Increment = 0.1,
        Rounding = 1,
        Suffix = " s",
        Callback = function(v)
            bodyParticlesConfig.lifetime = v
            applyBodyParticles()
        end
    })

    Tabs.Visuals:AddSlider("BodyParticlesRate", {
        Title = "Particle emission rate",
        Min = 1,
        Max = 50,
        Default = 2,
        Callback = function(v)
            bodyParticlesConfig.rate = v
            applyBodyParticles()
        end
    })

    Tabs.Visuals:AddDropdown("BodyParticlesOrientation", {
        Title = "Particle orientation",
        Values = {"Camera", "FacingCameraWorldUp", "VelocityParallel", "VelocityPerpendicular"},
        Default = "Camera",
        Callback = function(v)
            bodyParticlesConfig.orientation = v
            applyBodyParticles()
        end
    })

    -- align visual appearance toggles in a row
    mdTabs.Visuals:AddToggleGroup({
        { Title = "Glowing", Default = false, Callback = function(v) bodyParticlesConfig.glowing = v; applyBodyParticles() end },
        { Title = "Anchored", Default = false, Callback = function(v) bodyParticlesConfig.anchored = v; applyBodyParticles() end },
        { Title = "Fade in", Default = true, Callback = function(v) bodyParticlesConfig.fadeIn = v; applyBodyParticles() end }
    })

    Tabs.Visuals:AddSection("Crosshair")
    Tabs.Visuals:AddToggle("CrosshairEnabled", {
        Title = "Custom crosshair",
        Default = false,
        Callback = function(v)
            crosshairConfig.enabled = v
            if v then
                if crosshairConfig.followCursor then
                    pcall(function() UserInputService.MouseIconEnabled = false end)
                end
                updateCrosshair()
            else
                pcall(function() UserInputService.MouseIconEnabled = true end)
                removeCrosshair()
            end
        end
    })

    Tabs.Visuals:AddDropdown("CrosshairPreset", {
        Title = "Crosshair preset",
        Values = {
            "Heart",
            "Parenthesis",
            ">.<",
            "somename (animated)",
            "shockwave (animated)",
            "pixel shockwave (animated)",
            "maxwell (animated)",
            "Custom"
        },
        Default = "Parenthesis",
        Callback = function(v)
            crosshairConfig.preset = v
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddInput("CrosshairCustomId", {
        Title = "Custom crosshair asset id",
        Default = "",
        Placeholder = "rbxassetid://...",
        Callback = function(text)
            crosshairConfig.customAssetId = text
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddToggle("CrosshairCustomFlipbook", {
        Title = "Crosshair flipbook animation",
        Default = false,
        Callback = function(v)
            crosshairConfig.isCustomFlipbook = v
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddInput("CrosshairFlipbookLayout", {
        Title = "Crosshair flipbook layout",
        Default = "Grid4x4",
        Placeholder = "Grid2x2, Grid4x4, Grid8x8",
        Callback = function(text)
            crosshairConfig.customFlipbookLayout = text
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddDropdown("CrosshairFlipbookMode", {
        Title = "Crosshair flipbook mode",
        Values = {"Loop", "OneShot", "PingPong"},
        Default = "Loop",
        Callback = function(v)
            crosshairConfig.customFlipbookMode = v
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddSlider("CrosshairFlipbookSpeed", {
        Title = "Crosshair animation speed",
        Min = 1,
        Max = 60,
        Default = 15,
        Suffix = " fps",
        Callback = function(v)
            crosshairConfig.flipbookPlaySpeed = v
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddSlider("CrosshairSize", {
        Title = "Crosshair size scale",
        Min = 10,
        Max = 200,
        Default = 50,
        Suffix = " px",
        Callback = function(v)
            crosshairConfig.size = v
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddDropdown("CrosshairColorMode", {
        Title = "Crosshair color mode",
        Values = {"Normal", "Gradient", "Gradient 2", "Rainbow", "Rainbow 2"},
        Default = "Normal",
        Callback = function(v)
            crosshairConfig.colorMode = v
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddColorpicker("CrosshairColor1", {
        Title = "Crosshair primary color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(c)
            crosshairConfig.color1 = c
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddColorpicker("CrosshairColor2", {
        Title = "Crosshair secondary color",
        Default = Color3.fromRGB(0, 170, 255),
        Callback = function(c)
            crosshairConfig.color2 = c
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddSlider("CrosshairTransparency", {
        Title = "Crosshair transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(v)
            crosshairConfig.transparency = v / 100
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddCheckbox("CrosshairFollowCursor", {
        Title = "Crosshair follows cursor",
        Default = false,
        Callback = function(v)
            crosshairConfig.followCursor = v
            if not v or not crosshairConfig.enabled then
                pcall(function() UserInputService.MouseIconEnabled = true end)
            else
                pcall(function() UserInputService.MouseIconEnabled = false end)
            end
            if crosshairConfig.enabled then updateCrosshair() end
        end
    })

    Tabs.Visuals:AddToggle("CrosshairSpinEnabled", {
        Title = "Spin crosshair",
        Default = false,
        Slider = {
            Title = "Crosshair spin speed",
            Min = 10,
            Max = 360,
            Default = 180,
            Suffix = " deg/s",
            Callback = function(v)
                crosshairConfig.spinSpeed = v
            end
        },
        Callback = function(v)
            crosshairConfig.spinEnabled = v
        end
    })

    Tabs.Visuals:AddSection("Color animation")
    Tabs.Visuals:AddSlider("ColorShiftSpeed", {
        Title = "Rainbow & gradient animation speed",
        Min = 0.1,
        Max = 20,
        Default = 3,
        Increment = 0.1,
        Rounding = 1,
        Suffix = "x",
        Callback = function(v)
            state.colorShiftSpeed = v
        end
    })

    Tabs.Visuals:AddSection("Trail")
    Tabs.Visuals:AddToggle("TrailEnabled", {
        Title = "Character trail",
        Default = false,
        Callback = function(v)
            trailConfig.enabled = v
            if v then applyTrail() else removeAllTrails() end
        end
    })

    Tabs.Visuals:AddDropdown("TrailColorMode", {
        Title = "Trail color mode",
        Values = {"Normal", "Rainbow", "Shift", "Gradient"},
        Default = "Normal",
        Callback = function(v)
            trailConfig.colorMode = v
            updateTrailProps()
        end
    })

    Tabs.Visuals:AddGroup({
        {
            Id = "TrailColor1",
            Type = "ColorPicker",
            Title = "Trail primary color",
            Default = Color3.fromRGB(0, 170, 255),
            Callback = function(c)
                trailConfig.color1 = c
                updateTrailProps()
            end
        },
        {
            Id = "TrailColor2",
            Type = "ColorPicker",
            Title = "Trail secondary color",
            Default = Color3.fromRGB(255, 0, 128),
            Callback = function(c)
                trailConfig.color2 = c
                updateTrailProps()
            end
        }
    })

    Tabs.Visuals:AddSlider("TrailLifetime", {
        Title = "Trail duration lifetime",
        Min = 0.05,
        Max = 5,
        Default = 1.0,
        Increment = 0.05,
        Rounding = 2,
        Suffix = " s",
        Callback = function(v)
            trailConfig.lifetime = v
            updateTrailProps()
        end
    })

    Tabs.Visuals:AddSlider("TrailWidth", {
        Title = "Trail width scale",
        Min = 0.05,
        Max = 5,
        Default = 1.0,
        Increment = 0.05,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            trailConfig.width = v
            updateTrailProps()
        end
    })

    Tabs.Visuals:AddSlider("TrailTransparency", {
        Title = "Trail transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(v)
            trailConfig.transparency = v / 100
            updateTrailProps()
        end
    })

    Tabs.Visuals:AddSection("Orb")
    Tabs.Visuals:AddGroup({
        {
            Id = "OrbEnabled",
            Type = "Toggle",
            Title = "Orbiting light orb",
            Default = false,
            Callback = function(v)
                orbConfig.enabled = v
                if v then applyOrb() else removeOrb() end
            end
        },
        {
            Id = "OrbColorMode",
            Type = "Dropdown",
            Title = "Orb color mode",
            Values = {"Normal", "Rainbow", "Shift", "Gradient"},
            Default = "Normal",
            Callback = function(v)
                orbConfig.colorMode = v
            end
        },
        {
            Id = "OrbColor1",
            Type = "ColorPicker",
            Title = "Orb primary color",
            Default = Color3.fromRGB(0, 255, 170),
            Callback = function(c)
                orbConfig.color1 = c
            end
        },
        {
            Id = "OrbColor2",
            Type = "ColorPicker",
            Title = "Orb secondary color",
            Default = Color3.fromRGB(255, 85, 0),
            Callback = function(c)
                orbConfig.color2 = c
            end
        }
    })

    Tabs.Visuals:AddSlider("OrbRadius", {
        Title = "Orb orbit distance",
        Min = 0.5,
        Max = 20,
        Default = 3,
        Increment = 0.1,
        Rounding = 1,
        Suffix = " studs",
        Callback = function(v)
            orbConfig.radius = v
        end
    })

    Tabs.Visuals:AddSlider("OrbSpeed", {
        Title = "Orb orbit speed",
        Min = 0.1,
        Max = 20,
        Default = 4,
        Increment = 0.1,
        Rounding = 1,
        Suffix = "x",
        Callback = function(v)
            orbConfig.speed = v
        end
    })

    Tabs.Visuals:AddSlider("OrbSize", {
        Title = "Orb size scale",
        Min = 0.05,
        Max = 5,
        Default = 0.3,
        Increment = 0.05,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            orbConfig.size = v
        end
    })

    Tabs.Visuals:AddSection("China hat")
    Tabs.Visuals:AddGroup({
        {
            Id = "ChinaHatEnabled",
            Type = "Toggle",
            Title = "China hat cosmetic",
            Default = false,
            Callback = function(v)
                chinaHatConfig.enabled = v
                if v then startChinaHat() else stopChinaHat() end
            end
        },
        {
            Id = "ChinaHatColorMode",
            Type = "Dropdown",
            Title = "Hat color mode",
            Values = {"Normal", "Rainbow", "Shift", "Gradient"},
            Default = "Normal",
            Callback = function(v)
                chinaHatConfig.colorMode = v
                updateHatColors()
            end
        },
        {
            Id = "ChinaHatColor1",
            Type = "ColorPicker",
            Title = "Hat primary color",
            Default = Color3.fromRGB(255, 0, 100),
            Callback = function(c)
                chinaHatConfig.color1 = c
                updateHatColors()
            end
        },
        {
            Id = "ChinaHatColor2",
            Type = "ColorPicker",
            Title = "Hat secondary color",
            Default = Color3.fromRGB(0, 200, 255),
            Callback = function(c)
                chinaHatConfig.color2 = c
                updateHatColors()
            end
        }
    })

    Tabs.Visuals:AddSlider("ChinaHatTransparency", {
        Title = "Hat transparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Suffix = "%",
        Callback = function(v)
            chinaHatConfig.transparency = v / 100
            updateHatProps()
        end
    })

    Tabs.Visuals:AddToggleGroup({
        {
            Id = "ChinaHatAlwaysOnTop",
            Title = "Hat always on top",
            Default = false,
            Callback = function(v)
                chinaHatConfig.alwaysOnTop = v
                updateHatProps()
            end
        },
        {
            Id = "ChinaHatSelfOnly",
            Title = "Hat self player only",
            Default = true,
            Callback = function(v)
                chinaHatConfig.selfOnly = v
                if chinaHatConfig.enabled then
                    stopChinaHat()
                    startChinaHat()
                end
            end
        }
    })

    Tabs.Visuals:AddSlider("ChinaHatHeight", {
        Title = "Hat cone height",
        Min = 0.1,
        Max = 5,
        Default = 0.6,
        Increment = 0.05,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            chinaHatConfig.height = v
            updateHatProps()
        end
    })

    Tabs.Visuals:AddSlider("ChinaHatRadius", {
        Title = "Hat cone radius",
        Min = 0.1,
        Max = 10,
        Default = 1.2,
        Increment = 0.05,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            chinaHatConfig.radius = v
            updateHatProps()
        end
    })

    Tabs.Visuals:AddSlider("ChinaHatHeightOffset", {
        Title = "Hat head offset",
        Min = -2,
        Max = 5,
        Default = 2.0,
        Increment = 0.05,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            chinaHatConfig.heightOffset = v
            updateHatProps()
        end
    })

    Tabs.Visuals:AddSection("Neon wings")
    Tabs.Visuals:AddToggle("WingsEnabled", {
        Title = "Neon wings cosmetic",
        Default = false,
        Callback = function(v)
            wingsConfig.enabled = v
            if v then startWings() else stopWings() end
        end
    })

    Tabs.Visuals:AddDropdown("WingsColorMode", {
        Title = "Wings color mode",
        Values = {"Normal", "Rainbow", "Shift", "Gradient"},
        Default = "Normal",
        Callback = function(v)
            wingsConfig.colorMode = v
        end
    })

    Tabs.Visuals:AddColorpicker("WingsColor1", {
        Title = "Wings primary color",
        Default = Color3.fromRGB(0, 255, 170),
        Callback = function(c)
            wingsConfig.color1 = c
        end
    })

    Tabs.Visuals:AddColorpicker("WingsColor2", {
        Title = "Wings secondary color",
        Default = Color3.fromRGB(170, 0, 255),
        Callback = function(c)
            wingsConfig.color2 = c
        end
    })

    Tabs.Visuals:AddSlider("WingsTransparency", {
        Title = "Wings transparency",
        Min = 0,
        Max = 100,
        Default = 55,
        Suffix = "%",
        Callback = function(v)
            wingsConfig.transparency = v / 100
        end
    })

    Tabs.Visuals:AddSlider("WingsSpeed", {
        Title = "Wings flap speed",
        Min = 0.1,
        Max = 20,
        Default = 3.5,
        Increment = 0.1,
        Rounding = 1,
        Suffix = "x",
        Callback = function(v)
            wingsConfig.speed = v
        end
    })

    Tabs.Visuals:AddCheckbox("WingsSelfOnly", {
        Title = "Wings self player only",
        Default = true,
        Callback = function(v)
            wingsConfig.selfOnly = v
            if wingsConfig.enabled then
                stopWings()
                startWings()
            end
        end
    })

    Tabs.Visuals:AddSlider("WingsSize", {
        Title = "Wings scale size",
        Min = 0.1,
        Max = 5,
        Default = 0.59,
        Increment = 0.01,
        Rounding = 2,
        Suffix = "x",
        Callback = function(v)
            wingsConfig.size = v
        end
    })

    Tabs.Visuals:AddSlider("WingsPosX", {
        Title = "Wings position offset x",
        Min = -5,
        Max = 5,
        Default = 1.41,
        Increment = 0.01,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            wingsConfig.posX = v
        end
    })

    Tabs.Visuals:AddSlider("WingsPosY", {
        Title = "Wings position offset y",
        Min = -5,
        Max = 5,
        Default = 2.12,
        Increment = 0.01,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            wingsConfig.posY = v
        end
    })

    Tabs.Visuals:AddSlider("WingsPosZ", {
        Title = "Wings position offset z",
        Min = -5,
        Max = 5,
        Default = 1.41,
        Increment = 0.01,
        Rounding = 2,
        Suffix = " studs",
        Callback = function(v)
            wingsConfig.posZ = v
        end
    })

    Tabs.Visuals:AddSection("Spinbot")
    Tabs.Visuals:AddToggle("SpinbotEnabled", {
        Title = "Spinbot",
        Default = false,
        Slider = {
            Title = "Spinbot rotation speed",
            Min = 5,
            Max = 100,
            Default = 30,
            Suffix = "°/s",
            Callback = function(v)
                state.spinbotSpeed = v
            end
        },
        Callback = function(v)
            state.spinbotEnabled = v
            if v then startSpinbot() else stopSpinbot() end
        end
    })

    -- construct character animation overrides
    Tabs.Animations:AddSection("Custom animations")
    Tabs.Animations:AddGroup({
        {
            Id = "CustomAnimationsEnabled",
            Type = "Toggle",
            Title = "Custom animations",
            Default = false,
            Callback = function(v)
                customAnimationConfig.enabled = v
                task.spawn(applyCustomAnimations)
            end
        },
        {
            Id = "CustomAnimationPreset",
            Type = "Dropdown",
            Title = "Preset",
            Values = {"Mage", "Vampire", "Zombie", "Adidas", "Elder", "Dumb Dumb", "Custom"},
            Default = "Mage",
            Callback = function(v)
                customAnimationConfig.preset = v
                task.spawn(applyCustomAnimations)
            end
        },
        {
            Id = "CustomAnimationPackId",
            Type = "Input",
            Title = "Animation pack ID",
            Default = "",
            Placeholder = "Bundle or pack ID...",
            Callback = function(text)
                customAnimationConfig.customPackId = text
                if customAnimationConfig.preset == "Custom" then
                    task.spawn(applyCustomAnimations)
                end
            end
        }
    })

    -- construct character dance and wave presets
    Tabs.Animations:AddSection("Emotes")

    local function getEmoteOptions()
        local list = { "Take The L", "neck roller", "WISH NLE", "Zero Two Dance", "Gangnam Style" }
        if state.customEmotes then
            for name, _ in pairs(state.customEmotes) do
                local found = false
                for _, existing in ipairs(list) do
                    if existing == name then found = true; break end
                end
                if not found then table.insert(list, name) end
            end
        end
        return list
    end

    local emoteDropdownObj = Tabs.Animations:AddDropdown("SelectedEmote", {
        Title = "Select emote",
        Values = getEmoteOptions(),
        Default = "Take The L",
        Callback = function(v)
            state.selectedEmote = v
        end
    })

    Tabs.Animations:AddButtonRow({
        {
            Text = "Play emote",
            Callback = function()
                playEmote(state.selectedEmote)
            end
        },
        {
            Text = "Stop emote",
            Callback = function()
                stopEmote()
            end
        }
    }, 28)

    Tabs.Animations:AddCheckbox("EmoteStopOnMove", {
        Title = "Stop on move",
        Default = false,
        Callback = function(v)
            state.emoteStopOnMove = v
        end
    })

    local customEmoteTempName = ""
    local customEmoteTempId = ""

    Tabs.Animations:AddInput("CustomEmoteNameInput", {
        Title = "Custom emote name",
        Placeholder = "e.g. MyDance",
        Callback = function(txt)
            customEmoteTempName = txt
        end
    })

    Tabs.Animations:AddInput("CustomEmoteIdInput", {
        Title = "Custom animation ID",
        Placeholder = "rbxassetid://... or numbers",
        Callback = function(txt)
            customEmoteTempId = txt
        end
    })

    Tabs.Animations:AddButton({
        Title = "Add custom emote",
        Callback = function()
            local name = customEmoteTempName:gsub("^%s+", ""):gsub("%s+$", "")
            local id = customEmoteTempId:gsub("^%s+", ""):gsub("%s+$", "")
            if name == "" then
                name = "Custom_" .. (#getEmoteOptions() + 1)
            end
            if id ~= "" then
                state.customEmotes = state.customEmotes or {}
                state.customEmotes[name] = id
                if emoteDropdownObj and emoteDropdownObj.RefreshOptions then
                    emoteDropdownObj:RefreshOptions(getEmoteOptions())
                elseif emoteDropdownObj and emoteDropdownObj.SetValues then
                    emoteDropdownObj:SetValues(getEmoteOptions())
                end
                pcall(function()
                    if Window.Notify then
                        Window:Notify("Emote added", "Added custom emote: " .. name, 2.5)
                    end
                end)
            end
        end
    })

    Tabs.Animations:AddButton({
        Title = "Remove custom emote",
        Callback = function()
            local selected = state.selectedEmote
            if selected and state.customEmotes and state.customEmotes[selected] then
                state.customEmotes[selected] = nil
                local opts = getEmoteOptions()
                state.selectedEmote = opts[1] or "Take The L"
                if emoteDropdownObj and emoteDropdownObj.RefreshOptions then
                    emoteDropdownObj:RefreshOptions(opts)
                    if emoteDropdownObj.Select then emoteDropdownObj:Select(state.selectedEmote) end
                elseif emoteDropdownObj and emoteDropdownObj.SetValues then
                    emoteDropdownObj:SetValues(opts)
                end
                pcall(function()
                    if Window.Notify then
                        Window:Notify("Emote removed", "Removed custom emote: " .. selected, 2.5)
                    end
                end)
            else
                pcall(function()
                    if Window.Notify then
                        Window:Notify("Emotes", "Cannot remove standard preset emote", 2)
                    end
                end)
            end
        end
    })

    Window.ConfigSavedCallbacks = Window.ConfigSavedCallbacks or {}
    table.insert(Window.ConfigSavedCallbacks, function(cName, saveData)
        saveData.CustomEmotes = state.customEmotes
    end)

    Window.ConfigLoadedCallbacks = Window.ConfigLoadedCallbacks or {}
    table.insert(Window.ConfigLoadedCallbacks, function(data)
        if data and data.CustomEmotes then
            state.customEmotes = data.CustomEmotes
            if emoteDropdownObj and emoteDropdownObj.RefreshOptions then
                emoteDropdownObj:RefreshOptions(getEmoteOptions())
            end
        end
    end)

Tabs.World:AddSection("Skybox")

    Tabs.World:AddDropdown("WorldSkyboxPreset", {
        Title = "Skybox preset",
        Values = {"Default", "Space Skybox", "Fog on the water", "Red sky", "Midnight", "Tattletail"},
        Default = "Default",
        Callback = function(selected)
            worldState.skyboxPreset = selected
            local id = skyboxPresets[selected]
            applySkybox(id)
        end
    })

    Tabs.World:AddInput("WorldCustomSkybox", {
        Title = "Custom skybox id",
        Placeholder = "Asset id",
        ClearTextOnFocus = false,
        Callback = function(txt)
            applySkybox(txt)
        end
    })

    Tabs.World:AddSection("Atmosphere and lighting")

    Tabs.World:AddToggle("WorldCustomTime", {
        Title = "Custom time",
        Default = false,
        Callback = function(v)
            worldState.timeEnabled = v
            if not v then
                LightingService.ClockTime = defaultLighting.ClockTime
            end
        end
    })

    Tabs.World:AddSlider("WorldTime", {
        Title = "Time",
        Min = 0,
        Max = 24,
        Default = 14,
        Suffix = " hrs",
        Callback = function(val)
            worldState.customTime = val
        end
    })

    Tabs.World:AddToggle("WorldCustomBrightness", {
        Title = "Custom brightness",
        Default = false,
        Callback = function(v)
            worldState.brightnessEnabled = v
            if not v then
                LightingService.Brightness = defaultLighting.Brightness
            end
        end
    })

    Tabs.World:AddSlider("WorldBrightness", {
        Title = "Brightness",
        Min = 0,
        Max = 10,
        Default = 2,
        Suffix = "",
        Callback = function(val)
            worldState.customBrightness = val
        end
    })

    Tabs.World:AddToggle("WorldCustomFog", {
        Title = "Custom fog",
        Default = false,
        Callback = function(v)
            worldState.customFog = v
            if not v then
                LightingService.FogEnd = defaultLighting.FogEnd
                LightingService.FogColor = defaultLighting.FogColor
            end
        end
    })

    Tabs.World:AddSlider("WorldFogDistance", {
        Title = "Fog distance",
        Min = 100,
        Max = 5000,
        Default = 2000,
        Suffix = " studs",
        Callback = function(val)
            worldState.fogEndDistance = val
        end
    })

    Tabs.World:AddColorpicker("WorldFogColor", {
        Title = "Fog color",
        Default = Color3.fromRGB(180, 200, 220),
        Callback = function(col)
            worldState.fogColor = col
        end
    })

    -- construct camera fov and stretch adjustments
    Tabs.Camera:AddSection("Resolution stretch")

    Tabs.Camera:AddToggle("CameraEnableStretch", {
        Title = "Enable stretch",
        Default = false,
        Callback = function(v)
            stretchSettings.enabled = v
        end
    })

    Tabs.Camera:AddSlider("CameraHorizontalStretch", {
        Title = "Horizontal stretch",
        Min = 10,
        Max = 53,
        Default = 53,
        Suffix = "%",
        Callback = function(val)
            stretchSettings.horizontalScale = val / 100
        end
    })

    Tabs.Camera:AddSlider("CameraVerticalStretch", {
        Title = "Vertical stretch",
        Min = 10,
        Max = 74,
        Default = 74,
        Suffix = "%",
        Callback = function(val)
            stretchSettings.verticalScale = val / 100
        end
    })

    Tabs.Camera:AddToggle("CameraCustomFOV", {
        Title = "Custom field of view",
        Default = false,
        Callback = function(v)
            stretchSettings.fovModifierEnabled = v
            if not v then
                CurrentCamera.FieldOfView = 70
            else
                CurrentCamera.FieldOfView = stretchSettings.customFov
            end
        end
    })

    Tabs.Camera:AddSlider("CameraFOV", {
        Title = "Field of view",
        Min = 40,
        Max = 120,
        Default = 70,
        Suffix = "°",
        Callback = function(val)
            stretchSettings.customFov = val
            if stretchSettings.fovModifierEnabled then
                CurrentCamera.FieldOfView = val
            end
        end
    })


    -- mount floating action buttons for touch devices
    mobileFlyBtn = Window:CreateMobileButton({
        Text = "Fly",
        Type = "Toggle",
        Default = false,
        Visible = true,
        SaveKey = "mobile_fly",
        Callback = function(btnState, btn)
            state.flightEnabled = btnState
            toggleFlyConnection(btnState)
            if Options and Options.FlightEnabled and Options.FlightEnabled.Value ~= btnState then
                Options.FlightEnabled:SetValue(btnState, false)
            end
        end
    })

    mobileCamlockBtn = Window:CreateMobileButton({
        Text = "Camlock",
        Type = "Toggle",
        Default = false,
        Visible = true,
        SaveKey = "mobile_camlock",
        Callback = function(btnState, btn)
            state.camlockEnabled = btnState
            camlockSettings.aimLockEnabled = btnState
            camlockSettings.isLockedOn = btnState
            if btnState then
                camlockSettings.targetPlayer = getCamlockTarget()
            else
                camlockSettings.targetPlayer = nil
            end
            toggleCamlockConnection(btnState)
            if Options and Options.CamlockEnabled and Options.CamlockEnabled.Value ~= btnState then
                Options.CamlockEnabled:SetValue(btnState, false)
            end
        end
    })

    mobileShootBtn = Window:CreateMobileButton({
        Text = "Shoot",
        Type = "Button",
        Visible = true,
        SaveKey = "mobile_shoot",
        Callback = function(btn)
            local char = LocalPlayer.Character
            if not char then return end
            local gunTool = getPlayerTool(LocalPlayer, "Gun")
            if not gunTool then
                log("No gun found")
                return
            end
            if gunTool.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(gunTool); task.wait(0.05) end
            end

            local shootEvent = getGunShootEvent()
            if not shootEvent then
                log("Gun remote missing")
                return
            end

            local target, tPart = nil, nil
            if state and state.autoAimEnabled then
                target, tPart = getAutoAimTarget()
            else
                local murderer = state.knifeHolder or getMurd()
                if murderer and isPlayerAlive(murderer) then
                    target = murderer
                    tPart = murderer.Character and (murderer.Character:FindFirstChild("UpperTorso") or murderer.Character:FindFirstChild("HumanoidRootPart"))
                else
                    local t, p, _ = getSilentAimTarget()
                    target, tPart = t, p
                end
            end

            local targetChar = target and target.Character
            local isWallbang = (state and state.autoAimWallbang) or (silentAimConfig and silentAimConfig.wallbang)
            local shootPart = tPart
            if isWallbang and targetChar then
                shootPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("LowerTorso") or tPart
            else
                shootPart = tPart or (targetChar and (targetChar:FindFirstChild(silentAimConfig and silentAimConfig.targetPart or "Head") or targetChar:FindFirstChild("HumanoidRootPart")))
            end

            local targetPos = nil
            local originPos = nil
            if shootPart then
                local rawPos = shootPart.Position
                local predH, predV = getSilentAimPred()
                targetPos = calculateAimPosition(rawPos, shootPart, predH, predV)

                if isWallbang and targetChar then
                    local head = targetChar:FindFirstChild("Head")
                    originPos = head and head.Position or (rawPos + Vector3.new(0, 1.5, 0))
                end
            end

            if not originPos then
                local handle = getOwnGunHandle()
                local myHrp = char:FindFirstChild("HumanoidRootPart")
                originPos = handle and (handle.CFrame * CFrame.new(0, 0.5, -1)).Position or (myHrp and myHrp.Position or Vector3.zero)
            end

            if not targetPos then
                local vpSize = CurrentCamera.ViewportSize
                local ray = CurrentCamera:ViewportPointToRay(vpSize.X / 2, vpSize.Y / 2)
                targetPos = originPos + ray.Direction * 1000
            end

            pcall(function()
                shootEvent:FireServer(CFrame.new(originPos, targetPos), CFrame.new(targetPos))
            end)
            log("Mobile shot triggered")
        end
    })

    mobileFlingMurdBtn = Window:CreateMobileButton({
        Text = "Fling murd",
        Type = "Button",
        Visible = true,
        SaveKey = "mobile_fling_murd",
        Callback = function(btn)
            if (tick() - state.startTime) < 2.0 then return end
            local target = state.knifeHolder or getMurd()
            if target and isPlayerAlive(target) then
                log("flinging murderer: " .. target.Name)
                flingTarget(target, true, 3.5)
            else
                log("Murderer not found or dead")
            end
        end
    })

    mobileFlingSheriffBtn = Window:CreateMobileButton({
        Text = "Fling sheriff",
        Type = "Button",
        Visible = true,
        SaveKey = "mobile_fling_sheriff",
        Callback = function(btn)
            if (tick() - state.startTime) < 2.0 then return end
            local target = state.gunHolder or getSheriff()
            if target and isPlayerAlive(target) then
                log("flinging sheriff: " .. target.Name)
                flingTarget(target, true, 3.5)
            else
                log("Sheriff not found or dead")
            end
        end
    })


    -- construct match logging webhook settings
    Tabs.Webhook:AddSection("Discord webhook")
    Tabs.Webhook:AddToggle("WebhookEnabled", {
        Title = "Webhook logger",
        Default = false,
        Callback = function(v)
            state.webhookEnabled = v
            log("Webhook logger: " .. (v and "Enabled" or "Disabled"))
        end
    })

    Tabs.Webhook:AddInput("WebhookUrl", {
        Title = "Webhook url",
        Default = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(text)
            state.webhookUrl = text
        end
    })

    Tabs.Webhook:AddInput("WebhookInterval", {
        Title = "Webhook interval",
        Default = "5m",
        Placeholder = "e.g. 5m, 1h, 30s",
        Callback = function(text)
            state.webhookIntervalStr = text
            state.webhookIntervalSec = parseInterval(text)
        end
    })

    mdTabs.Webhook:AddToggleGroup({
        { Name = "Include current coins", Default = true, Callback = function(v) state.webhookCurrentCoins = v end },
        { Name = "Include coins / hour", Default = true, Callback = function(v) state.webhookCoinsPerHour = v end }
    })

    Tabs.Webhook:AddButton({
        Title = "Send test webhook",
        Callback = function()
            sendDiscordWebhook(true)
        end
    })

    -- construct script configuration and reload options
    Tabs.Settings:AddSection("Mobile overlay")

    -- group mobile on-screen buttons
    mdTabs.Settings:AddToggleGroup({
        { Name = "Mobile buttons overlay", Default = false, Callback = function(v)
            state.mobileButtonsEnabled = v
            if Window.MobileUI then
                Window.MobileUI.Enabled = v
            end
        end },
        { Name = "Lock button positions", Default = false, Callback = function(v)
            state.lockMobileButtons = v
            if Window.SetMobileButtonsLocked then
                Window:SetMobileButtonsLocked(v)
            end
        end },
        { Name = "Flight button", Default = true, Callback = function(v)
            state.mobileBtnFlightEnabled = v
            if mobileFlyBtn then mobileFlyBtn:SetVisible(v) end
        end },
        { Name = "Camlock button", Default = true, Callback = function(v)
            state.mobileBtnLockEnabled = v
            if mobileCamlockBtn then mobileCamlockBtn:SetVisible(v) end
        end },
        { Name = "Shoot button", Default = true, Callback = function(v)
            state.mobileBtnShootEnabled = v
            if mobileShootBtn then mobileShootBtn:SetVisible(v) end
        end },
        { Name = "Fling murderer button", Default = true, Callback = function(v)
            state.mobileBtnFlingMurdEnabled = v
            if mobileFlingMurdBtn then mobileFlingMurdBtn:SetVisible(v) end
        end },
        { Name = "Fling sheriff button", Default = true, Callback = function(v)
            state.mobileBtnFlingSheriffEnabled = v
            if mobileFlingSheriffBtn then mobileFlingSheriffBtn:SetVisible(v) end
        end }
    })

    Tabs.Settings:AddSection("Server")

    -- group server management shortcuts
    mdTabs.Settings:AddButtonRow({
        { Text = "Server hop", Callback = function() serverHop() end },
        { Text = "Rejoin server", Callback = function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end }
    }, 31)

    -- render 2d boxes, nametags, and chams highlights for players
    local _espState = { gunLabel = nil, gunOutline = nil, gunChamsObj = nil }
    espPlayers = {}

    local function safeRemoveDrawing(obj)
        if not obj then return end
        pcall(function() obj.Visible = false end)
        pcall(function() obj:Remove() end)
        pcall(function() obj:Destroy() end)
    end

    removeESP = function(player)
        local drawings = espPlayers[player]
        if drawings then
            safeRemoveDrawing(drawings.Box)
            safeRemoveDrawing(drawings.BoxOutline)
            safeRemoveDrawing(drawings.Name)
            if drawings.Highlight then
                pcall(function() drawings.Highlight:Destroy() end)
                drawings.Highlight = nil
            end
            if drawings.HasAdornments and player and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local ch = part:FindFirstChild("AdornChams")
                        if ch then pcall(function() ch:Destroy() end) end
                    end
                end
            end
            espPlayers[player] = nil
        end
    end

    local function hide2DDrawings(drawings)
        if not drawings then return end
        if drawings.BoxVisible then
            drawings.Box.Visible = false
            drawings.BoxVisible = false
        end
        if drawings.BoxOutlineVisible then
            drawings.BoxOutline.Visible = false
            drawings.BoxOutlineVisible = false
        end
        if drawings.NameVisible then
            drawings.Name.Visible = false
            drawings.NameVisible = false
        end
    end

    local function hideESPDrawings(drawings, plr)
        if not drawings then return end
        hide2DDrawings(drawings)
        if drawings.Highlight and drawings.Highlight.Enabled then
            drawings.Highlight.Enabled = false
        end
        if drawings.HasAdornments and plr and plr.Character then
            drawings.HasAdornments = false
            for _, part in ipairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local ch = part:FindFirstChild("AdornChams")
                    if ch then pcall(function() ch.Visible = false end) end
                end
            end
        end
    end

    local function createESP(player)
        if player == LocalPlayer or not state.espEnabled or espPlayers[player] then return end

        local ok, box        = pcall(function() return Drawing.new("Square") end)
        local ok2, outline   = pcall(function() return Drawing.new("Square") end)
        local ok3, nameLabel = pcall(function() return Drawing.new("Text") end)

        if not ok or not ok2 or not ok3 then
            if ok  then pcall(function() box:Remove() end) end
            if ok2 then pcall(function() outline:Remove() end) end
            if ok3 then pcall(function() nameLabel:Remove() end) end
            return
        end

        box.Thickness = 1.5
        box.Filled = false
        box.Visible = false

        outline.Thickness = 2.5
        outline.Color = Color3.new(0, 0, 0)
        outline.Filled = false
        outline.Visible = false

        nameLabel.Font = Drawing.Fonts and Drawing.Fonts.Michroma or 34
        nameLabel.Size = 17
        nameLabel.Center = true
        nameLabel.Outline = false
        nameLabel.Visible = false

        espPlayers[player] = {
            Box               = box,
            BoxOutline        = outline,
            Name              = nameLabel,
            Highlight         = nil,
            BoxVisible        = false,
            BoxOutlineVisible = false,
            NameVisible       = false,
            LastRole          = nil,
            LastRoleColor     = nil,
            LastChamsMode     = nil,
            LastNameText      = nil,
            LastNameColor     = nil,
            LastBoxColor      = nil,
            HasAdornments     = false,
        }
    end

    registerCleanupHook(function()
        for plr, _ in pairs(espPlayers) do
            removeESP(plr)
        end
        table.clear(espPlayers)
        safeRemoveDrawing(_espState.gunOutline)
        _espState.gunOutline = nil
        safeRemoveDrawing(_espState.gunLabel)
        _espState.gunLabel = nil
        if _espState.gunChamsObj then
            pcall(function() _espState.gunChamsObj:Destroy() end)
            _espState.gunChamsObj = nil
        end
    end)

    trackConnection(Players.PlayerAdded:Connect(function(plr)
        if plr ~= LocalPlayer and state.espEnabled then
            createESP(plr)
        end
    end))

    trackConnection(Players.PlayerRemoving:Connect(function(plr)
        removeESP(plr)
    end))

    local espLoopThread = task.spawn(function()
        local _frameRoles = {}
        local _frameMurderer, _frameSheriff = nil, nil
        local lastGunSearch = 0
        local cachedGunObj = nil
        local wasEspEnabled = false

        local function getPlayerRoleCached(plr)
            local cached = _frameRoles[plr]
            if cached then return cached end

            local role
            if plr == _frameMurderer and isPlayerAlive(plr) then
                role = "Murderer"
            elseif plr == _frameSheriff and isPlayerAlive(plr) then
                role = "Sheriff"
            elseif hasTool(plr, "Knife") then
                role = "Murderer"
            elseif hasTool(plr, "Gun") then
                role = "Sheriff"
            else
                role = "Innocent"
            end
            _frameRoles[plr] = role
            return role
        end

        while not state.unloaded do
            if not state.espEnabled then
                if wasEspEnabled then
                    wasEspEnabled = false
                    for plr, drawings in pairs(espPlayers) do
                        hideESPDrawings(drawings, plr)
                    end
                    if _espState.gunLabel and _espState.gunLabel.Visible then
                        _espState.gunLabel.Visible = false
                    end
                    if _espState.gunOutline and _espState.gunOutline.Visible then
                        _espState.gunOutline.Visible = false
                    end
                    if _espState.gunChamsObj then
                        pcall(function() _espState.gunChamsObj:Destroy() end)
                        _espState.gunChamsObj = nil
                    end
                end
                task.wait(0.2)
            else
                wasEspEnabled = true
                table.clear(_frameRoles)
                _frameMurderer = state.knifeHolder
                _frameSheriff  = state.gunHolder

                local cam = CurrentCamera
                local camPos = cam and cam.CFrame.Position
                local maxDist = state.espMaxDistance or 1000
                local chamsOn = state.chamsEnabled
                local cMode   = state.chamsMode or "Highlight"
                local murdCol = state.chamsMurdererColor or Color3.fromRGB(255, 70, 70)
                local sherCol = state.chamsSheriffColor or Color3.fromRGB(90, 120, 255)
                local innoCol = state.chamsInnocentColor or Color3.fromRGB(50, 230, 110)

                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        if not espPlayers[plr] then
                            createESP(plr)
                        end
                        local drawings = espPlayers[plr]
                        if drawings then
                            local char = plr.Character
                            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                            local hum  = char and char:FindFirstChildOfClass("Humanoid")
                            local alive = hrp and hum and hum.Health > 0

                            if not alive or not camPos then
                                hideESPDrawings(drawings, plr)
                            else
                                local hrpPos = hrp.Position
                                local playerDist = (hrpPos - camPos).Magnitude

                                if playerDist > maxDist then
                                    hideESPDrawings(drawings, plr)
                                else
                                    local role = getPlayerRoleCached(plr)
                                    local roleColor = (role == "Murderer" and murdCol)
                                        or (role == "Sheriff" and sherCol)
                                        or innoCol

                                    -- refresh highlight styles when role shifts
                                    if chamsOn then
                                        if cMode == "Highlight" or cMode == "Glow Outline" or cMode == "Fill Only" then
                                            -- destroy leftover adornments before switching mode
                                            if drawings.HasAdornments then
                                                drawings.HasAdornments = false
                                                for _, part in ipairs(char:GetChildren()) do
                                                    if part:IsA("BasePart") then
                                                        local ch1 = part:FindFirstChild("AdornChams")
                                                        if ch1 then pcall(function() ch1:Destroy() end) end
                                                    end
                                                end
                                            end

                                            local hl = drawings.Highlight
                                            if not hl or hl.Parent ~= char then
                                                if hl then pcall(function() hl:Destroy() end) end
                                                hl = Instance.new("Highlight")
                                                hl.Name = "ChamsHighlight"
                                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                                hl.Parent = char
                                                drawings.Highlight = hl
                                                drawings.LastRoleColor = nil
                                                drawings.LastChamsMode = nil
                                            end

                                            if drawings.LastRoleColor ~= roleColor or drawings.LastChamsMode ~= cMode then
                                                hl.FillColor = roleColor
                                                hl.OutlineColor = roleColor
                                                if cMode == "Glow Outline" then
                                                    hl.FillTransparency = 1.0
                                                    hl.OutlineTransparency = 0
                                                elseif cMode == "Fill Only" then
                                                    hl.FillTransparency = 0.3
                                                    hl.OutlineTransparency = 1.0
                                                else
                                                    hl.FillTransparency = 0.45
                                                    hl.OutlineTransparency = 0
                                                end
                                                drawings.LastRoleColor = roleColor
                                                drawings.LastChamsMode = cMode
                                            end
                                            if not hl.Enabled then
                                                hl.Enabled = true
                                            end
                                        elseif cMode == "Box Adornment" then
                                            if drawings.Highlight and drawings.Highlight.Enabled then
                                                drawings.Highlight.Enabled = false
                                            end
                                            drawings.HasAdornments = true
                                            for _, part in ipairs(char:GetChildren()) do
                                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                                    local adorn = part:FindFirstChild("AdornChams")
                                                    if not adorn then
                                                        adorn = Instance.new("BoxHandleAdornment")
                                                        adorn.Name = "AdornChams"
                                                        adorn.AlwaysOnTop = true
                                                        adorn.ZIndex = 5
                                                        adorn.Adornee = part
                                                        adorn.Parent = part
                                                    end
                                                    adorn.Size = part.Size + Vector3.new(0.04, 0.04, 0.04)
                                                    adorn.Color3 = roleColor
                                                    adorn.Transparency = 0.35
                                                    adorn.Visible = true
                                                end
                                            end
                                        end
                                    else
                                        if drawings.Highlight and drawings.Highlight.Enabled then
                                            drawings.Highlight.Enabled = false
                                        end
                                        if drawings.HasAdornments then
                                            drawings.HasAdornments = false
                                            for _, part in ipairs(char:GetChildren()) do
                                                if part:IsA("BasePart") then
                                                    local ch1 = part:FindFirstChild("AdornChams")
                                                    if ch1 then pcall(function() ch1:Destroy() end) end
                                                end
                                            end
                                        end
                                    end

                                    -- project 3d player bounds onto screen space
                                    local rootScreen, onScreen = cam:WorldToViewportPoint(hrpPos)
                                    if not onScreen or rootScreen.Z <= 0 then
                                        hide2DDrawings(drawings)
                                    else
                                        local topScr = cam:WorldToViewportPoint(hrpPos + Vector3.new(0, 3.0, 0))
                                        local botScr = cam:WorldToViewportPoint(hrpPos - Vector3.new(0, 3.2, 0))
                                        local height = math.abs(topScr.Y - botScr.Y)
                                        local width  = height * 0.55
                                        local boxX   = rootScreen.X - width * 0.5
                                        local boxY   = topScr.Y

                                        if state.boxEspEnabled then
                                            local box = drawings.Box
                                            box.Size = Vector2.new(width, height)
                                            box.Position = Vector2.new(boxX, boxY)
                                            if drawings.LastBoxColor ~= roleColor then
                                                box.Color = roleColor
                                                drawings.LastBoxColor = roleColor
                                            end
                                            if not drawings.BoxVisible then
                                                box.Visible = true
                                                drawings.BoxVisible = true
                                            end
                                        elseif drawings.BoxVisible then
                                            drawings.Box.Visible = false
                                            drawings.BoxVisible = false
                                        end

                                        if state.nameEspEnabled or state.roleEspEnabled then
                                            local nameLabel = drawings.Name
                                            nameLabel.Position = Vector2.new(rootScreen.X, boxY - 16)
                                            if drawings.LastRole ~= role or drawings.LastNameText == nil then
                                                local textStr = state.nameEspEnabled and plr.Name or ""
                                                if state.roleEspEnabled then
                                                    textStr = textStr ~= "" and (textStr .. " [" .. role .. "]") or ("[" .. role .. "]")
                                                end
                                                nameLabel.Text = textStr
                                                drawings.LastNameText = textStr
                                                drawings.LastRole = role
                                            end
                                            if drawings.LastNameColor ~= roleColor then
                                                nameLabel.Color = roleColor
                                                drawings.LastNameColor = roleColor
                                            end
                                            if not drawings.NameVisible then
                                                nameLabel.Visible = true
                                                drawings.NameVisible = true
                                            end
                                        elseif drawings.NameVisible then
                                            drawings.Name.Visible = false
                                            drawings.NameVisible = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- locate dropped gun in workspace for esp
                if state.gunEspEnabled and state.roundActive then
                    local now = tick()
                    if now - lastGunSearch >= 0.3 or not cachedGunObj or not cachedGunObj.Parent then
                        lastGunSearch = now
                        cachedGunObj = getDroppedGun()
                    end

                    local gunObj = cachedGunObj
                    local gunPos = nil
                    if gunObj and gunObj.Parent then
                        if gunObj:IsA("BasePart") then
                            gunPos = gunObj.Position
                        elseif gunObj:IsA("Model") then
                            local pp = gunObj.PrimaryPart or gunObj:FindFirstChildWhichIsA("BasePart", true)
                            if pp then gunPos = pp.Position end
                        end

                        if not _espState.gunChamsObj or _espState.gunChamsObj.Parent ~= gunObj then
                            if _espState.gunChamsObj then
                                pcall(function() _espState.gunChamsObj:Destroy() end)
                            end
                            local hl = Instance.new("Highlight")
                            hl.Name = "GunChams"
                            hl.FillColor = Color3.fromRGB(255, 220, 50)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.35
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = gunObj
                            _espState.gunChamsObj = hl
                        end
                        if not _espState.gunChamsObj.Enabled then
                            _espState.gunChamsObj.Enabled = true
                        end
                    else
                        if _espState.gunChamsObj then
                            pcall(function() _espState.gunChamsObj:Destroy() end)
                            _espState.gunChamsObj = nil
                        end
                    end

                    if gunPos and cam then
                        local scr, onScr = cam:WorldToViewportPoint(gunPos)
                        if onScr and scr.Z > 0 then
                            if not _espState.gunOutline then
                                local ok2, obj = pcall(function() return Drawing.new("Text") end)
                                if ok2 then
                                    obj.Font = Drawing.Fonts and Drawing.Fonts.Michroma or 34
                                    obj.Size = 18
                                    obj.Outline = false
                                    obj.Color = Color3.fromRGB(0, 0, 0)
                                    obj.Center = true
                                    obj.ZIndex = 4
                                    _espState.gunOutline = obj
                                end
                            end
                            if not _espState.gunLabel then
                                local ok3, obj = pcall(function() return Drawing.new("Text") end)
                                if ok3 then
                                    obj.Font = Drawing.Fonts and Drawing.Fonts.Michroma or 34
                                    obj.Size = 18
                                    obj.Color = Color3.fromRGB(255, 220, 50)
                                    obj.Center = true
                                    obj.ZIndex = 5
                                    _espState.gunLabel = obj
                                end
                            end
                            local dist = math.floor((gunPos - camPos).Magnitude)
                            local labelText = "[GUN] " .. dist .. "m"
                            local labelPos  = Vector2.new(scr.X, scr.Y - 8)

                            if _espState.gunOutline then
                                _espState.gunOutline.Text     = labelText
                                _espState.gunOutline.Position = labelPos
                                _espState.gunOutline.Visible  = true
                            end
                            if _espState.gunLabel then
                                _espState.gunLabel.Text       = labelText
                                _espState.gunLabel.Position   = labelPos
                                _espState.gunLabel.Visible    = true
                            end
                        else
                            if _espState.gunLabel and _espState.gunLabel.Visible then _espState.gunLabel.Visible = false end
                            if _espState.gunOutline and _espState.gunOutline.Visible then _espState.gunOutline.Visible = false end
                        end
                    else
                        if _espState.gunLabel and _espState.gunLabel.Visible then _espState.gunLabel.Visible = false end
                        if _espState.gunOutline and _espState.gunOutline.Visible then _espState.gunOutline.Visible = false end
                    end
                else
                    if _espState.gunLabel and _espState.gunLabel.Visible then _espState.gunLabel.Visible = false end
                    if _espState.gunOutline and _espState.gunOutline.Visible then _espState.gunOutline.Visible = false end
                    if _espState.gunChamsObj then
                        pcall(function() _espState.gunChamsObj:Destroy() end)
                        _espState.gunChamsObj = nil
                    end
                end

                RunService.RenderStepped:Wait()
            end
        end
    end)
    trackThread(espLoopThread)

    -- enforce configured movement speed multiplier 
    local speedThread = task.spawn(function()
        while not state.unloaded do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and state.speedEnabled then
                hum.WalkSpeed = state.speedValue
            end
            task.wait(0.1)
        end
    end)
    trackThread(speedThread)

    -- align camera with active target position 
    local aimbotThread = task.spawn(function()
        while not state.unloaded do
            if state.aimbotEnabled and not camlockSettings.isLockedOn then
                local targetPlr = nil
                local localHasKnife = hasTool(LocalPlayer, "Knife")
            
                if localHasKnife then
                    if state.gunHolder and isPlayerAlive(state.gunHolder) and state.gunHolder ~= LocalPlayer then
                        targetPlr = state.gunHolder
                    else
                        local closestDist = math.huge
                        local lHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if lHrp then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and isPlayerAlive(p) then
                                    local pHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                                    if pHrp then
                                        local dist = (pHrp.Position - lHrp.Position).Magnitude
                                        if dist < closestDist then
                                            closestDist = dist
                                            targetPlr = p
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if state.knifeHolder and isPlayerAlive(state.knifeHolder) and state.knifeHolder ~= LocalPlayer then
                        targetPlr = state.knifeHolder
                    end
                end
            
                if targetPlr and isPlayerAlive(targetPlr) then
                    local tHrp = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
                    if tHrp then
                        CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, tHrp.Position)
                    end
                end
            end
            task.wait(0.02)
        end
    end)
    trackThread(aimbotThread)

    -- handle keybind shortcuts and mouse triggers
    local silentAimFiring = false
    -- trigger aim assist on click or touch activation
    trackConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local focused = UserInputService:GetFocusedTextBox()
        if focused then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if (state and (state.autoAimEnabled or (silentAimConfig and silentAimConfig.enabled))) and not silentAimFiring then
                local hasGun = hasTool(LocalPlayer, "Gun")
                if hasGun then
                    local target, tPart = nil, nil
                    if state.autoAimEnabled then
                        target, tPart = getAutoAimTarget()
                    elseif silentAimConfig and silentAimConfig.enabled then
                        local t, p, _ = getSilentAimTarget()
                        target, tPart = t, p
                    end

                    if target and isPlayerAlive(target) then
                        local targetChar = target.Character
                        local isWallbang = (state and state.autoAimWallbang) or (silentAimConfig and silentAimConfig.wallbang)

                        local shootPart = tPart
                        if isWallbang and targetChar then
                            shootPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("LowerTorso") or tPart
                        else
                            shootPart = tPart or (targetChar and (targetChar:FindFirstChild(silentAimConfig.targetPart) or targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Head")))
                        end

                        if shootPart then
                            local shootEvent = getGunShootEvent()
                            if shootEvent then
                                silentAimFiring = true
                                task.spawn(function()
                                    task.wait(0.01)
                                    local rawPos = shootPart.Position
                                    local predH, predV = getSilentAimPred()
                                    local targetPos = calculateAimPosition(rawPos, shootPart, predH, predV)

                                    local originPos = nil
                                    if isWallbang and targetChar then
                                        local head = targetChar:FindFirstChild("Head")
                                        originPos = head and head.Position or (rawPos + Vector3.new(0, 1.5, 0))
                                    else
                                        local handle = getOwnGunHandle()
                                        local char = LocalPlayer.Character
                                        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                                        originPos = handle and (handle.CFrame * CFrame.new(0, 0.5, -1)).Position or (myHrp and myHrp.Position or Vector3.zero)
                                    end

                                    pcall(function()
                                        shootEvent:FireServer(CFrame.new(originPos, targetPos), CFrame.new(targetPos))
                                    end)
                                    task.wait(0.01)
                                    silentAimFiring = false
                                end)
                            end
                        end
                    end
                end
            end
        end
    end))

    -- minimize ui panel on keypress
    trackConnection(UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end
        local focused = UserInputService:GetFocusedTextBox()
        if focused then return end

        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end

        local menuKey = toKeyCode(state.menuToggleKey or Enum.KeyCode.End)
        if menuKey and kc == menuKey then
            Window.Minimized = not Window.Minimized
        end
    end))

    -- restore saved profile settings on startup
    task.spawn(function()
        if Window.SnapshotDefaultConfig then
            Window:SnapshotDefaultConfig()
        end
        local auto = Window:GetAutoloadConfig()
        if auto and auto ~= "" and auto:upper() ~= "NONE" then
            task.wait(0.3)
            Window:LoadConfig(auto)
        end
    end)

end
_buildScriptUI()
