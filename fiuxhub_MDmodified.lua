local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- GoldNotify (inline)
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local _LocalPlayer = game:GetService("Players").LocalPlayer
local GuiParent = CoreGui:FindFirstChild("RobloxGui") or _LocalPlayer:WaitForChild("PlayerGui")

local function GetExecutor()
    if identifyexecutor then return identifyexecutor() end
    if getexecutorname then return getexecutorname() end
    return "Unknown"
end

local function JoinDiscord()
    local inviteCode = "Z2U67B49Pk"
    if setclipboard then setclipboard("https://discord.gg/" .. inviteCode) end
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if httpRequest then
        pcall(function()
            httpRequest({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
                Body = game:GetService("HttpService"):JSONEncode({
                    cmd = "INVITE_BROWSER",
                    args = { code = inviteCode },
                    nonce = game:GetService("HttpService"):GenerateGUID(false)
                }),
            })
        end)
    end
end

local NotifyGui = GuiParent:FindFirstChild("GoldNotifyGui")
if not NotifyGui then
    NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "GoldNotifyGui"
    NotifyGui.DisplayOrder = 999
    NotifyGui.Parent = GuiParent
end

local function SendNotification(title, message, duration, customIcon)
    local assetId = customIcon or "rbxthumb://type=Asset&id=9267155972&w=150&h=150"
    local spacing = 75

    for _, existingFrame in ipairs(NotifyGui:GetChildren()) do
        if existingFrame:IsA("Frame") then
            TweenService:Create(existingFrame, TweenInfo.new(0.3), {
                Position = existingFrame.Position - UDim2.new(0, 0, 0, spacing)
            }):Play()
        end
    end

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "NotifyFrame"
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    NotifyFrame.Size = UDim2.new(0, 280, 0, 65)
    NotifyFrame.Position = UDim2.new(1, 30, 1, -100)
    NotifyFrame.Parent = NotifyGui

    Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", NotifyFrame)
    Stroke.Color = Color3.fromRGB(45, 45, 45)
    Stroke.Thickness = 1.2

    local Icon = Instance.new("ImageLabel", NotifyFrame)
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 12, 0, 12)
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Image = assetId
    if customIcon then Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0) end

    local TitleLabel = Instance.new("TextLabel", NotifyFrame)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 42, 0, 12)
    TitleLabel.Size = UDim2.new(0, 180, 0, 24)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TextLabel = Instance.new("TextLabel", NotifyFrame)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 12, 0, 38)
    TextLabel.Size = UDim2.new(1, -24, 0, 20)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = message
    TextLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    TextLabel.TextSize = 11
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    local function Exit()
        local currentY = NotifyFrame.Position.Y.Offset
        for _, otherFrame in ipairs(NotifyGui:GetChildren()) do
            if otherFrame:IsA("Frame") and otherFrame ~= NotifyFrame then
                if otherFrame.Position.Y.Offset < currentY then
                    TweenService:Create(otherFrame, TweenInfo.new(0.3), {
                        Position = otherFrame.Position + UDim2.new(0, 0, 0, spacing)
                    }):Play()
                end
            end
        end
        local tweenOut = TweenService:Create(NotifyFrame, TweenInfo.new(0.4), {
            Position = NotifyFrame.Position + UDim2.new(0, 350, 0, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function() NotifyFrame:Destroy() end)
    end

    local CloseBtn = Instance.new("TextButton", NotifyFrame)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -30, 0, 8)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    CloseBtn.TextSize = 22
    CloseBtn.MouseButton1Click:Connect(Exit)

    TweenService:Create(NotifyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -300, 1, -100)
    }):Play()

    task.delay(duration or 5, function() if NotifyFrame.Parent then Exit() end end)
end

local Executor = GetExecutor()
local Avatar = "rbxthumb://type=AvatarHeadShot&id=" .. _LocalPlayer.UserId .. "&w=150&h=150"

SendNotification("gold™", "game found, loading script...", 5)
JoinDiscord()

task.wait(0.5)
SendNotification("USER INFO", "User: " .. _LocalPlayer.Name .. " | ID: " .. _LocalPlayer.UserId, 6, Avatar)

task.wait(0.5)
SendNotification("EXECUTOR INFO", "Running on: " .. Executor, 7)

task.wait(0.5)
SendNotification("CREDITS", "GoldNotify - discord.gg/Q9hFWuVGPJ", 8)

task.wait(0.5)
SendNotification("CREDITS", "Insignificant", 8)

-- Services
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace       = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerMouse = localPlayer:GetMouse()
local currentCamera = Workspace.CurrentCamera

-- Window
local Window = Fluent:CreateWindow({
    Title = "fiux Hub (MD modified) | Da Hood",
    SubTitle = "FH modded by MD",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.End
})

local Tabs = {
    Rage     = Window:AddTab({ Title = "Rage",    Icon = "flame" }),
    Legit    = Window:AddTab({ Title = "Legit",   Icon = "crosshair" }),
    Game     = Window:AddTab({ Title = "Game",    Icon = "gamepad-2" }),
    Visuals  = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Lighting = Window:AddTab({ Title = "Lighting",Icon = "sun" }),
    Settings = Window:AddTab({ Title = "Settings",Icon = "settings" })
}

local Options = Fluent.Options

--------------------------------------------------
-- SHARED STATE
--------------------------------------------------

-- Silent Aim configs removed

local camlockSettings = {
    isLockedOn      = false,
    targetPlayer    = nil,
    lockEnabled     = false,
    aimLockEnabled  = false,
    smoothingFactor = 0.1,
    predictionFactor= 0,
    bodyPartSelected= "Head",
    teamCheckEnabled= false,
}

local strafeSettings = {
    enabled      = false,
    strafeRadius = 10,
    strafeSpeed  = 5,
    strafeHeight = 5,
}

local desyncConfig = {
    enabled       = false,
    mode          = "Bait",
    toggleEnabled = false,
    oldPosition   = nil,
    teleportPos   = Vector3.new(0,0,0),
}

local espConfig = {
    enabled = false,
    showBox = false,
    showChams = false,
    showHealthBar = false,
    showName = false,
    showTracers = false,
    tracerPosition = "Bottom",
    tracerThickness = 1,
    boxColor = Color3.fromRGB(255, 0, 0),
    boxOpacity = 1.0,
    nameColor = Color3.fromRGB(255, 255, 255),
    nameOpacity = 1.0,
    tracerColor = Color3.fromRGB(255, 0, 0),
    tracerOpacity = 1.0,
    healthColorFull = Color3.fromRGB(0, 255, 0),
    healthColorLow = Color3.fromRGB(255, 0, 0),
    chamFillColor = Color3.fromRGB(255, 0, 128),
    chamOutlineColor = Color3.fromRGB(255, 255, 255),
    chamFillTransparency = 0.5,
    chamOutlineTransparency = 0,
}

local hitboxSettings = {
    scriptEnabled  = false,
    expanderActive = false,
    size           = 30,
    transparency   = 0.5,
    expandedPlayer = nil,
    originalProps  = {},
}

local cframeSpeedSettings = {
    multiplier          = 1,
    isSpeedActive       = false,
    isFunctionalityEnabled = false,
}

local flyConfig = {
    enabled = false,
    speed   = 30,
}

local selectedTargetPlayer = nil
local targetKillActive = false

local autoReloadEnabled = false
local autoReloadThread = nil

local multiEquipDropdown
local multiEquipSettings = {
    enabled = false,
    selected = {}
}

local function getInventoryTools()
    local tools = {}
    local seen = {}
    
    local function collect(container)
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and not seen[item.Name] then
                table.insert(tools, item.Name)
                seen[item.Name] = true
            end
        end
    end
    
    if localPlayer:FindFirstChild("Backpack") then
        collect(localPlayer.Backpack)
    end
    if localPlayer.Character then
        collect(localPlayer.Character)
    end
    
    table.sort(tools)
    return tools
end

local multiEquipRefreshDebounce
local function refreshMultiEquipDropdown()
    if not multiEquipDropdown then return end
    if multiEquipRefreshDebounce then task.cancel(multiEquipRefreshDebounce) end
    multiEquipRefreshDebounce = task.delay(0.3, function()
        local tools = getInventoryTools()
        multiEquipDropdown:SetValues(tools)
    end)
end

local backpackConnection1
local backpackConnection2
local charConnection1
local charConnection2

local function setupInventoryListeners()
    if backpackConnection1 then backpackConnection1:Disconnect() end
    if backpackConnection2 then backpackConnection2:Disconnect() end
    if charConnection1 then charConnection1:Disconnect() end
    if charConnection2 then charConnection2:Disconnect() end
    
    local backpack = localPlayer:WaitForChild("Backpack", 5)
    if backpack then
        backpackConnection1 = backpack.ChildAdded:Connect(refreshMultiEquipDropdown)
        backpackConnection2 = backpack.ChildRemoved:Connect(refreshMultiEquipDropdown)
    end
    
    local char = localPlayer.Character
    if char then
        charConnection1 = char.ChildAdded:Connect(refreshMultiEquipDropdown)
        charConnection2 = char.ChildRemoved:Connect(refreshMultiEquipDropdown)
    end
end

local toolActivationConnection
local function setupToolActivationHook()
    if toolActivationConnection then toolActivationConnection:Disconnect() end
    toolActivationConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if multiEquipSettings.enabled and localPlayer.Character then
                for _, tool in ipairs(localPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") and multiEquipSettings.selected[tool.Name] then
                        task.spawn(function()
                            pcall(function() tool:Activate() end)
                        end)
                    end
                end
            end
        end
    end)
end

local multiEquipThread = nil
local function startMultiEquipLoop()
    if multiEquipThread then return end
    multiEquipThread = task.spawn(function()
        while multiEquipSettings.enabled do
            task.wait(0.1)
            if localPlayer.Character then
                local backpack = localPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and multiEquipSettings.selected[tool.Name] then
                            tool.Parent = localPlayer.Character
                        end
                    end
                end
            end
        end
        multiEquipThread = nil
    end)
end

setupInventoryListeners()

localPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    setupInventoryListeners()
    if multiEquipSettings.enabled then
        setupToolActivationHook()
        startMultiEquipLoop()
    end
    refreshMultiEquipDropdown()
end)

local lightingConfig = {
    Enabled = false,
    AmbientEnabled = false,
    AmbientColor = Color3.fromRGB(163, 204, 255),
    ColorShiftTopEnabled = false,
    ColorShiftTopColor = Color3.fromRGB(163, 204, 255),
    ColorShiftBottomEnabled = false,
    ColorShiftBottomColor = Color3.fromRGB(163, 204, 255),
    CustomFogEnabled = false,
    FogColor = Color3.fromRGB(163, 204, 255),
    FogEnd = 500,
    FogStart = 0,
    CustomTimeEnabled = false,
    ClockTime = 11.8,
}

local LightingService = game:GetService("Lighting")
local originalLighting = {
    Ambient = LightingService.Ambient,
    ColorShift_Top = LightingService.ColorShift_Top,
    ColorShift_Bottom = LightingService.ColorShift_Bottom,
    FogColor = LightingService.FogColor,
    FogEnd = LightingService.FogEnd,
    FogStart = LightingService.FogStart,
    ClockTime = LightingService.ClockTime,
}

local function applyLightingSettings()
    if not lightingConfig.Enabled then
        LightingService.Ambient = originalLighting.Ambient
        LightingService.ColorShift_Top = originalLighting.ColorShift_Top
        LightingService.ColorShift_Bottom = originalLighting.ColorShift_Bottom
        LightingService.FogColor = originalLighting.FogColor
        LightingService.FogEnd = originalLighting.FogEnd
        LightingService.FogStart = originalLighting.FogStart
        LightingService.ClockTime = originalLighting.ClockTime
        return
    end

    if lightingConfig.AmbientEnabled then
        LightingService.Ambient = lightingConfig.AmbientColor
    else
        LightingService.Ambient = originalLighting.Ambient
    end

    if lightingConfig.ColorShiftTopEnabled then
        LightingService.ColorShift_Top = lightingConfig.ColorShiftTopColor
    else
        LightingService.ColorShift_Top = originalLighting.ColorShift_Top
    end

    if lightingConfig.ColorShiftBottomEnabled then
        LightingService.ColorShift_Bottom = lightingConfig.ColorShiftBottomColor
    else
        LightingService.ColorShift_Bottom = originalLighting.ColorShift_Bottom
    end

    if lightingConfig.CustomFogEnabled then
        LightingService.FogColor = lightingConfig.FogColor
        LightingService.FogEnd = lightingConfig.FogEnd
        LightingService.FogStart = lightingConfig.FogStart
    else
        LightingService.FogColor = originalLighting.FogColor
        LightingService.FogEnd = originalLighting.FogEnd
        LightingService.FogStart = originalLighting.FogStart
    end

    if lightingConfig.CustomTimeEnabled then
        LightingService.ClockTime = lightingConfig.ClockTime
    else
        LightingService.ClockTime = originalLighting.ClockTime
    end
end

local lightingConnection = nil
-- lightingConnection removed to prevent heavy rendering lag from setting properties every frame
--------------------------------------------------
-- GLOBAL PLAYER CACHE & UTILITIES (OPTIMIZATION)
--------------------------------------------------
local espPlayers = {}
local playerCache = {}

local function onPlayerAdded(p)
    if p == localPlayer then return end
    local data = {
        char = nil,
        hrp = nil,
        hum = nil,
        conn = nil
    }
    playerCache[p] = data
    
    local function onCharAdded(char)
        data.char = char
        data.hrp = char:WaitForChild("HumanoidRootPart", 10)
        data.hum = char:WaitForChild("Humanoid", 10)
    end
    
    if p.Character then
        task.spawn(onCharAdded, p.Character)
    end
    data.conn = p.CharacterAdded:Connect(onCharAdded)
end

local function onPlayerRemoving(p)
    local data = playerCache[p]
    if data then
        if data.conn then data.conn:Disconnect() end
        playerCache[p] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end
local playerAddedConn = Players.PlayerAdded:Connect(onPlayerAdded)
local playerRemovingConn = Players.PlayerRemoving:Connect(onPlayerRemoving)

local function getPlayerParts(p)
    local data = playerCache[p]
    if not data then return nil, nil, nil end
    local char = p.Character
    if not char then
        data.char = nil
        data.hrp = nil
        data.hum = nil
        return nil, nil, nil
    end
    
    -- If character changed or cache is empty, update it
    if data.char ~= char or not (data.hrp and data.hrp.Parent == char and data.hum and data.hum.Parent == char) then
        data.char = char
        data.hrp = char:FindFirstChild("HumanoidRootPart")
        data.hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Reset ESP drawings specific cache if this player has drawings
        local drawings = espPlayers[p]
        if drawings then
            drawings.ExtentsSize = nil
        end
    end
    return char, data.hrp, data.hum
end

-- Local player cache
local localCharacter = nil
local localHrp = nil
local localHumanoid = nil

local function updateLocalCharCache(char)
    localCharacter = char
    if char then
        localHrp = char:WaitForChild("HumanoidRootPart", 10)
        localHumanoid = char:WaitForChild("Humanoid", 10)
    else
        localHrp = nil
        localHumanoid = nil
    end
end

if localPlayer.Character then updateLocalCharCache(localPlayer.Character) end
local localCharAddedConn = localPlayer.CharacterAdded:Connect(updateLocalCharCache)

local function setDrawProp(drawings, objName, prop, val)
    local cacheKey = "_" .. objName .. prop
    if drawings[cacheKey] ~= val then
        drawings[cacheKey] = val
        pcall(function() drawings[objName][prop] = val end)
    end
end

--------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------

local function checkTeam(player)
    return not camlockSettings.teamCheckEnabled or player.Team ~= localPlayer.Team
end

local function getRole(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Tool") then
            local n = v.Name:lower()
            if n:match("knife") then return "Murder" end
            if n:match("gun")   then return "Sheriff" end
        end
    end
    return nil
end

local function notify(title, content, duration)
    Fluent:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

--------------------------------------------------
-- SILENT AIM (mt hook)
--------------------------------------------------

-- Metamethod Silent Aim hooks removed

--------------------------------------------------
-- CAMLOCK
--------------------------------------------------

local function getCamlockTarget()
    if not camlockSettings.aimLockEnabled then return nil end
    local shortest = math.huge
    local result = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and checkTeam(p) then
            local char, hrp, hum = getPlayerParts(p)
            if char and hum and hum.Health > 0 then
                local part = char:FindFirstChild(camlockSettings.bodyPartSelected)
                if part then
                    local sp, onScreen = currentCamera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(playerMouse.X, playerMouse.Y)).Magnitude
                        if dist < shortest then shortest = dist result = p end
                    end
                end
            end
        end
    end
    return result
end

local camlockConnection = nil
local function updateCamlock()
    local tp = camlockSettings.targetPlayer
    if not tp then
        camlockSettings.isLockedOn = false
        if camlockConnection then camlockConnection:Disconnect() camlockConnection = nil end
        return
    end
    local char, hrp, hum = getPlayerParts(tp)
    if not char or not hum or hum.Health <= 0 then
        camlockSettings.isLockedOn = false
        camlockSettings.targetPlayer = nil
        if camlockConnection then camlockConnection:Disconnect() camlockConnection = nil end
        return
    end
    local be = char:FindFirstChild("BodyEffects")
    local ko = be and be:FindFirstChild("K.O")
    if ko and ko.Value then
        camlockSettings.isLockedOn = false
        camlockSettings.targetPlayer = nil
        if camlockConnection then camlockConnection:Disconnect() camlockConnection = nil end
        return
    end
    local part = char:FindFirstChild(camlockSettings.bodyPartSelected)
    if part then
        local predicted = part.Position + (part.AssemblyLinearVelocity or Vector3.zero) * camlockSettings.predictionFactor
        local goalCF = CFrame.new(currentCamera.CFrame.Position, predicted)
        local alpha = math.clamp(1 - camlockSettings.smoothingFactor, 0.05, 1)
        currentCamera.CFrame = currentCamera.CFrame:Lerp(goalCF, alpha)
    end
end

local function toggleCamlockConnection(state)
    if camlockConnection then camlockConnection:Disconnect() camlockConnection = nil end
    if state then
        camlockConnection = RunService.RenderStepped:Connect(updateCamlock)
    end
end

local function toggleCamlock()
    if camlockSettings.lockEnabled and camlockSettings.aimLockEnabled then
        if camlockSettings.isLockedOn then
            camlockSettings.isLockedOn = false
            camlockSettings.targetPlayer = nil
            toggleCamlockConnection(false)
        else
            camlockSettings.targetPlayer = getCamlockTarget()
            if camlockSettings.targetPlayer then
                local char, hrp, hum = getPlayerParts(camlockSettings.targetPlayer)
                if char then
                    local part = char:FindFirstChild(camlockSettings.bodyPartSelected)
                    if part then 
                        camlockSettings.isLockedOn = true 
                        toggleCamlockConnection(true)
                    end
                end
            end
        end
    end
end

--------------------------------------------------
-- TARGET STRAFE
--------------------------------------------------

local isStrafing = false
local strafeTargetPlayer = nil
local currentStrafeAngle = 0

local function getStrafeTarget()
    local shortest = math.huge
    local mouseLoc = UserInputService:GetMouseLocation()
    local result = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local char, hrp, hum = getPlayerParts(p)
            if hrp and hum and hum.Health > 0 then
                local sp, onScreen = currentCamera:WorldToScreenPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - mouseLoc).Magnitude
                    if dist < shortest then shortest = dist result = p end
                end
            end
        end
    end
    return result
end

local strafeConnection = nil
local function updateStrafe(dt)
    if not (strafeSettings.enabled and isStrafing and strafeTargetPlayer) then return end
    local char, targetRoot, hum = getPlayerParts(strafeTargetPlayer)
    if not targetRoot or not hum or hum.Health <= 0 then return end
    currentStrafeAngle = (currentStrafeAngle + strafeSettings.strafeSpeed * dt * 360) % 360
    local x = math.cos(math.rad(currentStrafeAngle)) * strafeSettings.strafeRadius
    local z = math.sin(math.rad(currentStrafeAngle)) * strafeSettings.strafeRadius
    local newPos = Vector3.new(targetRoot.Position.X + x, targetRoot.Position.Y + strafeSettings.strafeHeight, targetRoot.Position.Z + z)
    if localHrp then
        localHrp.CFrame = CFrame.new(newPos, targetRoot.Position)
        currentCamera.CameraSubject = targetRoot
    end
end

local function toggleStrafeConnection(state)
    if strafeConnection then strafeConnection:Disconnect() strafeConnection = nil end
    if state then
        strafeConnection = RunService.RenderStepped:Connect(updateStrafe)
    end
end

local function toggleStrafe()
    if isStrafing then
        isStrafing = false
        currentCamera.CameraSubject = localHumanoid
        notify("Strafe", "Unstrafed " .. (strafeTargetPlayer and strafeTargetPlayer.Name or ""))
        strafeTargetPlayer = nil
        toggleStrafeConnection(false)
    else
        strafeTargetPlayer = getStrafeTarget()
        if strafeTargetPlayer then
            isStrafing = true
            notify("Strafe", "Strafing " .. strafeTargetPlayer.Name)
            toggleStrafeConnection(true)
        end
    end
end

--------------------------------------------------
-- DESYNC (Anti-Aim)
--------------------------------------------------

local desyncPart = Instance.new("Part")
desyncPart.Name = "DesyncPart"
desyncPart.Size = Vector3.new(2,2,1)
desyncPart.CanCollide = false
desyncPart.Anchored = true
desyncPart.Transparency = 1
desyncPart.Parent = Workspace

local function resetCameraToPlayer()
    if localHumanoid then currentCamera.CameraSubject = localHumanoid end
end

local desyncConnection = nil
local function updateDesync()
    if localHrp and localHrp.Parent == localCharacter then
        desyncConfig.oldPosition = localHrp.CFrame
        local mode = desyncConfig.mode
        local velocity = localHrp.AssemblyLinearVelocity or Vector3.zero
        if mode == "Bait" then
            desyncConfig.teleportPos = localHrp.Position + Vector3.new(math.random(-5, 5), math.random(-2, 2), math.random(-5, 5))
        elseif mode == "Randomize" then
            desyncConfig.teleportPos = localHrp.Position + Vector3.new(math.random(-200, 200), math.random(-50, 50), math.random(-200, 200))
        elseif mode == "Destroy Cheaters" then
            desyncConfig.teleportPos = Vector3.new(9e18, 9e18, 9e18)
        elseif mode == "Static Void" then
            desyncConfig.teleportPos = localHrp.Position - Vector3.new(0, 1500, 0)
        elseif mode == "Predictions Breaker" then
            desyncConfig.teleportPos = localHrp.Position - (velocity * 2.5) + Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
        elseif mode == "Unhittable" then
            desyncConfig.teleportPos = localHrp.Position + Vector3.new(math.random(-99999, 99999), math.random(-99999, 99999), math.random(-99999, 99999))
        end
        localHrp.CFrame = CFrame.new(desyncConfig.teleportPos)
        currentCamera.CameraSubject = desyncPart
        RunService.RenderStepped:Wait()
        desyncPart.CFrame = desyncConfig.oldPosition * CFrame.new(0, localHrp.Size.Y/2 + 0.5, 0)
        localHrp.CFrame = desyncConfig.oldPosition
    end
end

local function toggleDesyncConnection(state)
    if desyncConnection then desyncConnection:Disconnect() desyncConnection = nil end
    if state then
        desyncConnection = RunService.Heartbeat:Connect(updateDesync)
    else
        resetCameraToPlayer()
    end
end

local function toggleDesync(state)
    desyncConfig.enabled = state
    toggleDesyncConnection(state)
    if state then
        notify("Anti-Aim", "Desync ON — mode: " .. desyncConfig.mode)
    else
        notify("Anti-Aim", "Desync OFF")
    end
end

-- FOV rendering removed

--------------------------------------------------
-- HITBOX EXPANDER
--------------------------------------------------

local function getHitboxTarget()
    local shortest = math.huge
    local mv = Vector2.new(playerMouse.X, playerMouse.Y)
    local result = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local char, root, hum = getPlayerParts(p)
            if root and hum and hum.Health > 0 then
                local sp, onScreen = currentCamera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (mv - Vector2.new(sp.X, sp.Y)).Magnitude
                    if dist < shortest then shortest = dist result = p end
                end
            end
        end
    end
    return result
end

local function revertHitbox(player)
    if player then
        local char, root, hum = getPlayerParts(player)
        if not char and player.Character then char = player.Character root = char:FindFirstChild("HumanoidRootPart") end
        if root and hitboxSettings.originalProps[player] then
            root.Size = hitboxSettings.originalProps[player].Size
            root.Transparency = hitboxSettings.originalProps[player].Transparency
            root.CanCollide = hitboxSettings.originalProps[player].CanCollide
            for _, c in pairs(root:GetChildren()) do
                if c:IsA("SelectionBox") or c:IsA("BoxHandleAdornment") then c:Destroy() end
            end
            hitboxSettings.originalProps[player] = nil
        end
    end
end

local hitboxConnection = nil
local lastHitboxScan = 0
local hitboxTarget = nil
local function runHitboxExpander()
    local now = os.clock()
    if now - lastHitboxScan > 0.1 then
        lastHitboxScan = now
        hitboxTarget = getHitboxTarget()
    end
    local target = hitboxTarget
    
    local isTargetValid = false
    if target then
        local char, root, hum = getPlayerParts(target)
        if char and root and hum and hum.Health > 0 then
            local be = char:FindFirstChild("BodyEffects")
            local ko = be and be:FindFirstChild("K.O")
            if not (ko and ko.Value) then
                isTargetValid = true
            end
        end
    end
    
    if not isTargetValid or not target then
        if hitboxSettings.expandedPlayer then
            revertHitbox(hitboxSettings.expandedPlayer)
            hitboxSettings.expandedPlayer = nil
        end
        return
    end
    
    if hitboxSettings.expandedPlayer ~= target then
        if hitboxSettings.expandedPlayer then
            revertHitbox(hitboxSettings.expandedPlayer)
        end
        local char, root, hum = getPlayerParts(target)
        if root then
            if not hitboxSettings.originalProps[target] then
                hitboxSettings.originalProps[target] = { Size = root.Size, Transparency = root.Transparency, CanCollide = root.CanCollide }
            end
            hitboxSettings.expandedPlayer = target
            root.Size = Vector3.new(hitboxSettings.size, hitboxSettings.size, hitboxSettings.size)
            root.Transparency = hitboxSettings.transparency
            root.CanCollide = false
        end
    else
        local char, root, hum = getPlayerParts(target)
        if root and root.Size.X ~= hitboxSettings.size then
            root.Size = Vector3.new(hitboxSettings.size, hitboxSettings.size, hitboxSettings.size)
            root.Transparency = hitboxSettings.transparency
        end
    end
end

local function toggleHitboxConnection(state)
    if hitboxConnection then hitboxConnection:Disconnect() hitboxConnection = nil end
    if state then
        hitboxConnection = RunService.RenderStepped:Connect(runHitboxExpander)
    else
        if hitboxSettings.expandedPlayer then revertHitbox(hitboxSettings.expandedPlayer) hitboxSettings.expandedPlayer = nil end
    end
end

--------------------------------------------------
-- CFRAME SPEED
--------------------------------------------------

local speedConnection
local function updateSpeed()
    if not cframeSpeedSettings.isFunctionalityEnabled or not cframeSpeedSettings.isSpeedActive then return end
    if localHrp and localHumanoid and localHumanoid.Parent == localCharacter and localHumanoid.MoveDirection.Magnitude > 0 then
        localHrp.CFrame = localHrp.CFrame + localHumanoid.MoveDirection.Unit * cframeSpeedSettings.multiplier
    end
end

local function toggleSpeedConnection(state)
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    if state then
        speedConnection = RunService.Heartbeat:Connect(updateSpeed)
    end
end

--------------------------------------------------
-- FLY
--------------------------------------------------

local cframeFlySpeed = 3
local flyActive = false

local flyConnection = nil
local function updateFly(dt)
    if not flyActive or not localHrp or not localHumanoid then return end
    
    local moveDir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + currentCamera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir - currentCamera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - currentCamera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + currentCamera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDir = moveDir + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDir = moveDir - Vector3.new(0, 1, 0)
    end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end
    
    local look = currentCamera.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    if flatLook.Magnitude == 0 then
        flatLook = Vector3.new(0, 0, -1)
    else
        flatLook = flatLook.Unit
    end
    
    pcall(function()
        localHrp.AssemblyLinearVelocity = Vector3.zero
        localHrp.AssemblyAngularVelocity = Vector3.zero
    end)
    
    local targetPos = localHrp.Position + moveDir * (cframeFlySpeed * 60 * dt)
    localHrp.CFrame = CFrame.new(targetPos, targetPos + flatLook)
end

local function toggleFlyConnection(state)
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if state then
        if localHumanoid then
            localHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
        flyConnection = RunService.Heartbeat:Connect(updateFly)
    else
        if localHumanoid then
            localHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if localHrp then
            pcall(function()
                localHrp.AssemblyLinearVelocity = Vector3.zero
                localHrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end

--------------------------------------------------
-- SHOP & PLAYER ACTIONS
--------------------------------------------------

local shopFolder = Workspace:WaitForChild("Ignored"):WaitForChild("Shop")
local selectedShopItem = nil
local isBuyingItem = false
local autoBuyOnRespawn = false

local function getLocalRoot()
    return localHrp
end

local shopItemsCache = {} -- itemName -> list of { position = Vector3, cd = ClickDetector, part = BasePart }
local cachedShopItemNames = {}
local cachedLowerShopItemNames = {}

local function updateShopCache()
    local names = {}
    local seen = {}
    local newCache = {}
    for _, child in ipairs(shopFolder:GetChildren()) do
        local name = child.Name
        if not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
        
        local cd = child:FindFirstChildOfClass("ClickDetector")
        local targetPart = child:FindFirstChild("Head") or child:FindFirstChildOfClass("Part") or child:FindFirstChildWhichIsA("BasePart")
        if targetPart then
            if not newCache[name] then
                newCache[name] = {}
            end
            table.insert(newCache[name], {
                position = targetPart.Position,
                cd = cd,
                part = targetPart
            })
        end
    end
    table.sort(names)
    cachedShopItemNames = names
    shopItemsCache = newCache
    
    local lowerNames = {}
    for i, name in ipairs(names) do
        lowerNames[i] = name:lower()
    end
    cachedLowerShopItemNames = lowerNames
end

-- Initial population
updateShopCache()

local function getShopItemNames()
    return cachedShopItemNames
end

local function executeBuyItem(itemName)
    if not itemName or isBuyingItem then return end
    isBuyingItem = true
    local desyncWas = desyncConfig.enabled
    if desyncWas then toggleDesync(false) task.wait(0.1) end
    local root = getLocalRoot()
    if root then
        local cachedList = shopItemsCache[itemName]
        local itemData = cachedList and cachedList[math.random(1, #cachedList)]
        if itemData then
            local targetPos = itemData.position
            if itemData.part and itemData.part.Parent then
                targetPos = itemData.part.Position
            end
            
            local saved = root.CFrame
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            task.wait(0.25)
            
            local cd = itemData.cd
            if not (cd and cd.Parent) then
                for _, child in ipairs(shopFolder:GetChildren()) do
                    if child.Name == itemName then
                        local head = child:FindFirstChild("Head") or child:FindFirstChildOfClass("Part") or child:FindFirstChildWhichIsA("BasePart")
                        if head and (head.Position - targetPos).Magnitude < 10 then
                            local foundCd = child:FindFirstChildOfClass("ClickDetector")
                            if foundCd then
                                cd = foundCd
                                itemData.part = head
                                itemData.cd = foundCd
                                break
                            end
                        end
                    end
                end
            end
            
            if cd then
                fireclickdetector(cd)
                notify("Shop", "Purchased: " .. itemName)
            else
                notify("Shop Error", "ClickDetector not found for " .. itemName)
            end
            root.CFrame = saved
        else
            notify("Shop Error", "Item not found: " .. itemName)
        end
        if desyncWas then task.wait(0.2) toggleDesync(true) end
    end
    isBuyingItem = false
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    shopFolder = Workspace:WaitForChild("Ignored"):WaitForChild("Shop")
    updateShopCache()
    if autoBuyOnRespawn and selectedShopItem then
        executeBuyItem(selectedShopItem)
    end
end)

local function shootAtHead(tool, targetChar, bursts)
    bursts = bursts or 3
    local head = targetChar:FindFirstChild("Head")
    local handle = tool and tool:FindFirstChild("Handle")
    if not head or not handle or not tool:FindFirstChild("Ammo") then return end
    local origin = handle.CFrame.Position
    local dir = (head.Position - origin).Unit
    for _ = 1, bursts do
        pcall(function()
            ReplicatedStorage.MainEvent:FireServer("ShootGun", handle, origin, head.Position, head, dir)
        end)
    end
end

local function autoReloadAndAim(tool, targetChar)
    if not tool or not targetChar then return false end
    local ammo = tool:FindFirstChild("Ammo")
    if ammo and ammo.Value == 0 then
        ReplicatedStorage.MainEvent:FireServer("Reload", tool)
        task.wait(1.5)
        return false
    end
    local head = targetChar:FindFirstChild("Head")
    if head then
        ReplicatedStorage.MainEvent:FireServer("UpdateMousePosI2", head.Position)
    end
    return true
end

local function startAutoReloadLoop()
    if autoReloadThread then return end
    autoReloadThread = task.spawn(function()
        while autoReloadEnabled do
            task.wait(0.1)
            pcall(function()
                local char = localPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local ammo = tool:FindFirstChild("Ammo")
                        if ammo and ammo.Value == 0 then
                            ReplicatedStorage.MainEvent:FireServer("Reload", tool)
                            task.wait(1.5)
                        end
                    end
                end
            end)
        end
        autoReloadThread = nil
    end)
end

-- Self chams / trail / highlight
local trailConfig = {
    enabled     = false,
    color       = Color3.fromRGB(255, 255, 255),
    color2      = Color3.fromRGB(255, 0, 255),
    colorMode   = "Solid",
    lifetime    = 1,
    width       = 2,
    lightEmission = 1,
    transparency = 0,
    textureId   = "",
}

local spinbotConfig = {
    enabled  = false,
    speed    = 20,
    angle    = 0,
    lookUp   = true,
}

local forcefieldEnabled = false
local selfHighlightEnabled = false
local selfHighlight = nil
local selfHighlightFillColor = Color3.fromRGB(0, 200, 255)
local selfHighlightOutlineColor = Color3.fromRGB(255, 255, 255)
local selfHighlightFillTransparency = 0.5
local selfHighlightOutlineTransparency = 0
local selfMaterialMode = "None"
local initialChar = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local function applyMaterial(char, mat)
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.Material = mat end)
        end
    end
end

local function removeMaterial(char)
    applyMaterial(char, Enum.Material.Plastic)
end

local materialMap = {
    ForceField = Enum.Material.ForceField,
    Neon = Enum.Material.Neon,
    Glass = Enum.Material.Glass,
    SmoothPlastic = Enum.Material.SmoothPlastic,
}

local localTrail = nil

local function removeAllTrails(char)
    localTrail = nil
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, c in pairs(hrp:GetChildren()) do
            if c:IsA("Trail") or c:IsA("Attachment") then c:Destroy() end
        end
    end
end

local rainbowHue = 0

local function getTrailColorSequence()
    if trailConfig.colorMode == "Gradient" then
        return ColorSequence.new(trailConfig.color, trailConfig.color2)
    elseif trailConfig.colorMode == "Rainbow" then
        return ColorSequence.new(Color3.fromHSV(rainbowHue, 1, 1), Color3.fromHSV((rainbowHue + 0.5) % 1, 1, 1))
    else
        return ColorSequence.new(trailConfig.color)
    end
end

local function updateTrailProps()
    if not trailConfig.enabled or not localTrail or not localTrail.Parent then return end
    localTrail.Color = getTrailColorSequence()
    localTrail.Lifetime = trailConfig.lifetime
    localTrail.Transparency = NumberSequence.new(trailConfig.transparency, 1)
    localTrail.LightEmission = trailConfig.lightEmission
    localTrail.WidthScale = NumberSequence.new(trailConfig.width / 10)
    if trailConfig.textureId ~= "" then
        localTrail.Texture = "rbxassetid://" .. trailConfig.textureId
        localTrail.TextureMode = Enum.TextureMode.Static
    else
        localTrail.Texture = ""
    end
end

local chinaHatConfig = {
    enabled = false,
    color = Color3.fromRGB(0, 200, 255),
    transparency = 0.3,
    alwaysOnTop = true,
    rainbow = false,
    selfOnly = true,
    height = 0.6,
    radius = 1.2,
    heightOffset = 2.0
}

local chinaHatAdornments = {}
local chinaHatConnections = {}
local chinaHatPlayerAddedConn = nil
local chinaHatPlayerRemovingConn = nil

local function applyChinaHat(player, char)
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 3) or char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local existing = hrp:FindFirstChild("FIXZ_ChinaHat")
    if existing then existing:Destroy() end
    
    local adornment = Instance.new("ConeHandleAdornment")
    adornment.Name = "FIXZ_ChinaHat"
    adornment.Height = chinaHatConfig.height
    adornment.Radius = chinaHatConfig.radius
    adornment.Color3 = chinaHatConfig.rainbow and Color3.fromHSV(rainbowHue, 1, 1) or chinaHatConfig.color
    adornment.Transparency = chinaHatConfig.transparency
    adornment.AlwaysOnTop = chinaHatConfig.alwaysOnTop
    adornment.Adornee = hrp
    adornment.CFrame = CFrame.new(0, chinaHatConfig.heightOffset, 0) * CFrame.Angles(math.rad(90), 0, 0)
    adornment.Parent = hrp
    
    chinaHatAdornments[player] = adornment
end

local function removeChinaHat(player, char)
    chinaHatAdornments[player] = nil
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local adornment = hrp:FindFirstChild("FIXZ_ChinaHat")
        if adornment then adornment:Destroy() end
    end
end

local function setupChinaHatForPlayer(player)
    local function onCharAdded(char)
        task.wait(1)
        if chinaHatConfig.enabled then
            if player == localPlayer or not chinaHatConfig.selfOnly then
                applyChinaHat(player, char)
            end
        end
    end
    if player.Character then task.spawn(onCharAdded, player.Character) end
    chinaHatConnections[player] = player.CharacterAdded:Connect(onCharAdded)
end

local function removeChinaHatForPlayer(player)
    if chinaHatConnections[player] then
        chinaHatConnections[player]:Disconnect()
        chinaHatConnections[player] = nil
    end
    if player.Character then
        removeChinaHat(player, player.Character)
    end
end

local function updateChinaHatColors()
    local color = chinaHatConfig.rainbow and Color3.fromHSV(rainbowHue, 1, 1) or chinaHatConfig.color
    
    local localAdornment = chinaHatAdornments[localPlayer]
    if localAdornment and localAdornment.Parent then
        localAdornment.Color3 = color
    end
    
    if not chinaHatConfig.selfOnly then
        for player, adornment in pairs(chinaHatAdornments) do
            if player ~= localPlayer and adornment and adornment.Parent then
                adornment.Color3 = color
            end
        end
    end
end

local function updateChinaHatProperties()
    local color = chinaHatConfig.rainbow and Color3.fromHSV(rainbowHue, 1, 1) or chinaHatConfig.color
    local function applyProps(player, char)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local adornment = hrp and hrp:FindFirstChild("FIXZ_ChinaHat")
        if adornment then
            adornment.Color3 = color
            adornment.Transparency = chinaHatConfig.transparency
            adornment.AlwaysOnTop = chinaHatConfig.alwaysOnTop
            adornment.Height = chinaHatConfig.height
            adornment.Radius = chinaHatConfig.radius
            adornment.CFrame = CFrame.new(0, chinaHatConfig.heightOffset, 0) * CFrame.Angles(math.rad(90), 0, 0)
        end
    end
    
    if localPlayer.Character then applyProps(localPlayer, localPlayer.Character) end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            if not chinaHatConfig.selfOnly then
                applyProps(p, p.Character)
            else
                removeChinaHat(p, p.Character)
            end
        end
    end
end

local function startChinaHat()
    if chinaHatPlayerAddedConn then return end
    for _, p in pairs(Players:GetPlayers()) do
        setupChinaHatForPlayer(p)
    end
    chinaHatPlayerAddedConn = Players.PlayerAdded:Connect(setupChinaHatForPlayer)
    chinaHatPlayerRemovingConn = Players.PlayerRemoving:Connect(removeChinaHatForPlayer)
end

local function stopChinaHat()
    if chinaHatPlayerAddedConn then
        chinaHatPlayerAddedConn:Disconnect()
        chinaHatPlayerAddedConn = nil
    end
    if chinaHatPlayerRemovingConn then
        chinaHatPlayerRemovingConn:Disconnect()
        chinaHatPlayerRemovingConn = nil
    end
    for p in pairs(chinaHatConnections) do
        removeChinaHatForPlayer(p)
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then removeChinaHat(p, p.Character) end
    end
end

local function updateTrailColorOnly()
    if localTrail and localTrail.Parent then
        localTrail.Color = getTrailColorSequence()
    end
end

local rainbowConnection = nil
local function updateRainbowTrail(dt)
    rainbowHue = (rainbowHue + dt * 0.5) % 1
    if trailConfig.enabled and trailConfig.colorMode == "Rainbow" then
        updateTrailColorOnly()
    end
    if chinaHatConfig.enabled and chinaHatConfig.rainbow then
        updateChinaHatColors()
    end
end

local function toggleRainbowConnection(state)
    if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
    if state then
        rainbowConnection = RunService.Heartbeat:Connect(updateRainbowTrail)
    end
end

local function updateRainbowState()
    local needRainbow = (trailConfig.enabled and trailConfig.colorMode == "Rainbow")
                     or (chinaHatConfig.enabled and chinaHatConfig.rainbow)
    toggleRainbowConnection(needRainbow)
end

local function applyTrail(char)
    removeAllTrails(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local att1 = Instance.new("Attachment", hrp)
    att1.Name = "FIXZ_TrailAtt1"
    att1.Position = Vector3.new(0, 1, 0)
    local att2 = Instance.new("Attachment", hrp)
    att2.Name = "FIXZ_TrailAtt2"
    att2.Position = Vector3.new(0, -1, 0)
    local t = Instance.new("Trail", hrp)
    t.Name = "FIXZ_Trail"
    t.Attachment0 = att1
    t.Attachment1 = att2
    t.Color = getTrailColorSequence()
    t.Lifetime = trailConfig.lifetime
    t.Transparency = NumberSequence.new(trailConfig.transparency, 1)
    t.LightEmission = trailConfig.lightEmission
    t.WidthScale = NumberSequence.new(trailConfig.width / 10)
    t.FaceCamera = true
    if trailConfig.textureId ~= "" then
        t.Texture = "rbxassetid://" .. trailConfig.textureId
        t.TextureMode = Enum.TextureMode.Static
    end
    localTrail = t
end

local function applySelfHighlight(char)
    if selfHighlight then pcall(function() selfHighlight:Destroy() end) end
    selfHighlight = Instance.new("Highlight")
    selfHighlight.Name = "FIXZ_SelfHL"
    selfHighlight.FillColor = selfHighlightFillColor
    selfHighlight.OutlineColor = selfHighlightOutlineColor
    selfHighlight.FillTransparency = selfHighlightFillTransparency
    selfHighlight.OutlineTransparency = selfHighlightOutlineTransparency
    selfHighlight.Parent = char
end

local function updateSelfHighlight()
    if selfHighlightEnabled and selfHighlight and selfHighlight.Parent then
        selfHighlight.FillColor = selfHighlightFillColor
        selfHighlight.OutlineColor = selfHighlightOutlineColor
        selfHighlight.FillTransparency = selfHighlightFillTransparency
        selfHighlight.OutlineTransparency = selfHighlightOutlineTransparency
    else
        local char = localPlayer.Character
        if char and selfHighlightEnabled then
            applySelfHighlight(char)
        end
    end
end

-- ==================================================
-- ESP (Drawing & Highlights) System
-- ==================================================

local function createESP(player)
    if player == localPlayer then return end
    if espPlayers[player] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBarBg = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        Highlight = nil,
        
        -- Cache to prevent crossing Lua/C++ bridge unnecessarily
        _BoxVisible = false,
        _BoxOutlineVisible = false,
        _NameVisible = false,
        _TracerVisible = false,
        _HealthBarBgVisible = false,
        _HealthBarVisible = false
    }
    
    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    drawings.BoxOutline.Thickness = 2.5
    drawings.BoxOutline.Color = Color3.new(0, 0, 0)
    drawings.BoxOutline.Filled = false
    drawings.BoxOutline.Visible = false
    
    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    
    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Visible = false
    
    drawings.HealthBarBg.Thickness = 3
    drawings.HealthBarBg.Color = Color3.new(0, 0, 0)
    drawings.HealthBarBg.Visible = false
    
    drawings.HealthBar.Thickness = 1.5
    drawings.HealthBar.Visible = false
    
    espPlayers[player] = drawings
end

local function removeESP(player)
    local drawings = espPlayers[player]
    if drawings then
        pcall(function() drawings.Box:Remove() end)
        pcall(function() drawings.BoxOutline:Remove() end)
        pcall(function() drawings.Name:Remove() end)
        pcall(function() drawings.Tracer:Remove() end)
        pcall(function() drawings.HealthBarBg:Remove() end)
        pcall(function() drawings.HealthBar:Remove() end)
        if drawings.Highlight then
            pcall(function() drawings.Highlight:Destroy() end)
        end
        espPlayers[player] = nil
    end
end

local espConnection = nil
local espPlayerAddedConnection = nil
local espPlayerRemovingConnection = nil

local function startESP()
    if espConnection then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        createESP(p)
    end
    
    espPlayerAddedConnection = Players.PlayerAdded:Connect(createESP)
    espPlayerRemovingConnection = Players.PlayerRemoving:Connect(removeESP)
    
    espConnection = RunService.RenderStepped:Connect(function()
        local mouseLoc = UserInputService:GetMouseLocation()
        local viewportSize = currentCamera.ViewportSize
        
        for player, drawings in pairs(espPlayers) do
            local char, root, hum = getPlayerParts(player)
            local visible = false
            
            if char and root and hum and hum.Health > 0 then
                local pos, onScreen = currentCamera:WorldToViewportPoint(root.Position)
                if onScreen then
                    visible = true
                    
                    local extents = drawings.ExtentsSize
                    if not extents then
                        extents = char:GetExtentsSize()
                        drawings.ExtentsSize = extents
                    end
                    
                    local topPoint = root.Position + Vector3.new(0, extents.Y / 2 + 0.5, 0)
                    local bottomPoint = root.Position - Vector3.new(0, extents.Y / 2 + 0.5, 0)
                    
                    local topScreen = currentCamera:WorldToViewportPoint(topPoint)
                    local bottomScreen = currentCamera:WorldToViewportPoint(bottomPoint)
                    
                    local height = math.abs(topScreen.Y - bottomScreen.Y)
                    local width = height * 0.55
                    
                    local boxX = pos.X - width / 2
                    local boxY = pos.Y - height / 2
                    
                    -- Box
                    if espConfig.showBox then
                        setDrawProp(drawings, "BoxOutline", "Size", Vector2.new(width, height))
                        setDrawProp(drawings, "BoxOutline", "Position", Vector2.new(boxX, boxY))
                        if not drawings._BoxOutlineVisible then
                            drawings._BoxOutlineVisible = true
                            pcall(function() drawings.BoxOutline.Visible = true end)
                        end
                        
                        setDrawProp(drawings, "Box", "Size", Vector2.new(width, height))
                        setDrawProp(drawings, "Box", "Position", Vector2.new(boxX, boxY))
                        setDrawProp(drawings, "Box", "Color", espConfig.boxColor)
                        setDrawProp(drawings, "Box", "Transparency", espConfig.boxOpacity)
                        if not drawings._BoxVisible then
                            drawings._BoxVisible = true
                            pcall(function() drawings.Box.Visible = true end)
                        end
                    else
                        if drawings._BoxOutlineVisible then
                            drawings._BoxOutlineVisible = false
                            pcall(function() drawings.BoxOutline.Visible = false end)
                        end
                        if drawings._BoxVisible then
                            drawings._BoxVisible = false
                            pcall(function() drawings.Box.Visible = false end)
                        end
                    end
                    
                    -- Name
                    if espConfig.showName then
                        setDrawProp(drawings, "Name", "Position", Vector2.new(pos.X, boxY - 16))
                        setDrawProp(drawings, "Name", "Text", player.Name)
                        setDrawProp(drawings, "Name", "Color", espConfig.nameColor)
                        setDrawProp(drawings, "Name", "Transparency", espConfig.nameOpacity)
                        if not drawings._NameVisible then
                            drawings._NameVisible = true
                            pcall(function() drawings.Name.Visible = true end)
                        end
                    else
                        if drawings._NameVisible then
                            drawings._NameVisible = false
                            pcall(function() drawings.Name.Visible = false end)
                        end
                    end
                    
                    -- Health Bar
                    if espConfig.showHealthBar then
                        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local healthColor = espConfig.healthColorLow:Lerp(espConfig.healthColorFull, healthPercent)
                        
                        local barX = boxX - 6
                        local barY = boxY
                        
                        setDrawProp(drawings, "HealthBarBg", "From", Vector2.new(barX, barY))
                        setDrawProp(drawings, "HealthBarBg", "To", Vector2.new(barX, barY + height))
                        if not drawings._HealthBarBgVisible then
                            drawings._HealthBarBgVisible = true
                            pcall(function() drawings.HealthBarBg.Visible = true end)
                        end
                        
                        setDrawProp(drawings, "HealthBar", "From", Vector2.new(barX, barY + height))
                        setDrawProp(drawings, "HealthBar", "To", Vector2.new(barX, barY + height - (height * healthPercent)))
                        setDrawProp(drawings, "HealthBar", "Color", healthColor)
                        if not drawings._HealthBarVisible then
                            drawings._HealthBarVisible = true
                            pcall(function() drawings.HealthBar.Visible = true end)
                        end
                    else
                        if drawings._HealthBarBgVisible then
                            drawings._HealthBarBgVisible = false
                            pcall(function() drawings.HealthBarBg.Visible = false end)
                        end
                        if drawings._HealthBarVisible then
                            drawings._HealthBarVisible = false
                            pcall(function() drawings.HealthBar.Visible = false end)
                        end
                    end
                    
                    -- Tracer
                    if espConfig.showTracers then
                        local fromPos
                        if espConfig.tracerPosition == "Bottom" then
                            fromPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                        else
                            fromPos = mouseLoc
                        end
                        
                        setDrawProp(drawings, "Tracer", "From", fromPos)
                        setDrawProp(drawings, "Tracer", "To", Vector2.new(pos.X, pos.Y + height / 2))
                        setDrawProp(drawings, "Tracer", "Color", espConfig.tracerColor)
                        setDrawProp(drawings, "Tracer", "Transparency", espConfig.tracerOpacity)
                        if not drawings._TracerVisible then
                            drawings._TracerVisible = true
                            pcall(function() drawings.Tracer.Visible = true end)
                        end
                    else
                        if drawings._TracerVisible then
                            drawings._TracerVisible = false
                            pcall(function() drawings.Tracer.Visible = false end)
                        end
                    end
                    
                    -- Chams
                    if espConfig.showChams then
                        if not drawings.Highlight or drawings.Highlight.Parent ~= char then
                            if drawings.Highlight then pcall(function() drawings.Highlight:Destroy() end) end
                            drawings.Highlight = Instance.new("Highlight")
                            drawings.Highlight.Name = "FIXZ_ESPChams"
                            drawings.Highlight.Parent = char
                        end
                        local h = drawings.Highlight
                        if h.FillColor ~= espConfig.chamFillColor then h.FillColor = espConfig.chamFillColor end
                        if h.OutlineColor ~= espConfig.chamOutlineColor then h.OutlineColor = espConfig.chamOutlineColor end
                        if h.FillTransparency ~= espConfig.chamFillTransparency then h.FillTransparency = espConfig.chamFillTransparency end
                        if h.OutlineTransparency ~= espConfig.chamOutlineTransparency then h.OutlineTransparency = espConfig.chamOutlineTransparency end
                        if not h.Enabled then h.Enabled = true end
                    else
                        if drawings.Highlight and drawings.Highlight.Enabled then
                            drawings.Highlight.Enabled = false
                        end
                    end
                end
            end
            
            if not visible then
                if drawings._BoxVisible then drawings._BoxVisible = false pcall(function() drawings.Box.Visible = false end) end
                if drawings._BoxOutlineVisible then drawings._BoxOutlineVisible = false pcall(function() drawings.BoxOutline.Visible = false end) end
                if drawings._NameVisible then drawings._NameVisible = false pcall(function() drawings.Name.Visible = false end) end
                if drawings._TracerVisible then drawings._TracerVisible = false pcall(function() drawings.Tracer.Visible = false end) end
                if drawings._HealthBarBgVisible then drawings._HealthBarBgVisible = false pcall(function() drawings.HealthBarBg.Visible = false end) end
                if drawings._HealthBarVisible then drawings._HealthBarVisible = false pcall(function() drawings.HealthBar.Visible = false end) end
                if drawings.Highlight and drawings.Highlight.Enabled then
                    drawings.Highlight.Enabled = false
                end
            end
        end
    end)
end

local function stopESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    if espPlayerAddedConnection then
        espPlayerAddedConnection:Disconnect()
        espPlayerAddedConnection = nil
    end
    if espPlayerRemovingConnection then
        espPlayerRemovingConnection:Disconnect()
        espPlayerRemovingConnection = nil
    end
    for p in pairs(espPlayers) do
        removeESP(p)
    end
end

localPlayer.CharacterAdded:Connect(function(c)
    task.wait(1)
    if trailConfig.enabled then applyTrail(c) end
    if selfMaterialMode ~= "None" and materialMap[selfMaterialMode] then
        applyMaterial(c, materialMap[selfMaterialMode])
    end
    if selfHighlightEnabled then applySelfHighlight(c) end
end)

local spinbotConnection = nil
local function updateSpinbot()
    if not localHrp or localHrp.Parent ~= localCharacter then return end
    spinbotConfig.angle = (spinbotConfig.angle + spinbotConfig.speed) % 360
    local yaw = math.rad(spinbotConfig.angle)
    localHrp.CFrame = CFrame.new(localHrp.Position) * CFrame.Angles(0, yaw, 0)
    if spinbotConfig.lookUp and localCharacter then
        local neck = localCharacter:FindFirstChild("Neck", true)
        if neck and neck:IsA("Motor6D") then
            neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-85), math.rad(spinbotConfig.angle), 0)
        end
        local tool = localCharacter:FindFirstChildWhichIsA("Tool")
        if tool then
            local rj = localCharacter:FindFirstChild("RightGrip", true)
            if rj and rj:IsA("Motor6D") then
                rj.C1 = CFrame.Angles(math.rad(90), 0, 0)
            end
        end
    end
end

local function toggleSpinbotConnection(state)
    if spinbotConnection then spinbotConnection:Disconnect() spinbotConnection = nil end
    if state then
        spinbotConnection = RunService.RenderStepped:Connect(updateSpinbot)
    end
end

local antiStompThread = nil
local antiStompAnimationTrack = nil

local function playAntiStompEmote()
    if antiStompThread then task.cancel(antiStompThread) end
    if antiStompAnimationTrack then pcall(function() antiStompAnimationTrack:Stop(0.1) end) antiStompAnimationTrack = nil end
    
    antiStompThread = task.spawn(function()
        while Options.AntiStomp and Options.AntiStomp.Value do
            local char = localPlayer.Character
            local be = char and char:FindFirstChild("BodyEffects")
            local ko = be and be:FindFirstChild("K.O")
            if ko and ko.Value then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                if animator then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://135373056067761" -- Tornado Emote (Massive movement/bug)
                    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
                    if ok and track then
                        track.Priority = Enum.AnimationPriority.Action
                        track.Looped = false
                        track.Speed = 1000 -- Max speed to bug out character completely
                        track:Play(0.1)
                        antiStompAnimationTrack = track
                        
                        -- Wait for track to stop or KO to end
                        local stopped = false
                        local trackConn = track.Stopped:Connect(function() stopped = true end)
                        while not stopped and ko.Parent and ko.Value and Options.AntiStomp.Value do
                            task.wait(0.05)
                        end
                        trackConn:Disconnect()
                        pcall(function() track:Stop(0.1) end)
                        antiStompAnimationTrack = nil
                    else
                        task.wait(0.5)
                    end
                else
                    task.wait(0.5)
                end
            else
                if antiStompAnimationTrack then
                    pcall(function() antiStompAnimationTrack:Stop(0.1) end)
                    antiStompAnimationTrack = nil
                end
                task.wait(0.2)
            end
        end
    end)
end

local function isKO(player)
    local be = player.Character and player.Character:FindFirstChild("BodyEffects")
    local ko = be and be:FindFirstChild("K.O")
    return ko and ko.Value or false
end

--------------------------------------------------
-- CUSTOM SHOOT SOUND
--------------------------------------------------

local customSoundId = ""
local customSoundEnabled = false
local soundConnections = {}

local function replaceSoundsInChar(char)
    if not customSoundEnabled or customSoundId == "" then return end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                local snd = handle:FindFirstChild("ShootSound")
                if snd and snd:IsA("Sound") then
                    pcall(function() snd.SoundId = "rbxassetid://" .. customSoundId end)
                end
            end
        end
    end
end

local function applyCustomSounds()
    for _, c in pairs(soundConnections) do pcall(function() c:Disconnect() end) end
    soundConnections = {}
    if not customSoundEnabled or customSoundId == "" then return end

    local char = localPlayer.Character
    if char then
        replaceSoundsInChar(char)
        -- Watch for tools being equipped into the character
        local conn = char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                local handle = child:FindFirstChild("Handle")
                if handle and customSoundEnabled then
                    local snd = handle:FindFirstChild("ShootSound")
                    if snd and snd:IsA("Sound") then
                        pcall(function() snd.SoundId = "rbxassetid://" .. customSoundId end)
                    end
                end
            end
        end)
        table.insert(soundConnections, conn)
    end

    local respawnConn = localPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        replaceSoundsInChar(c)
        local conn2 = c.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                local handle = child:FindFirstChild("Handle")
                if handle and customSoundEnabled then
                    local snd = handle:FindFirstChild("ShootSound")
                    if snd and snd:IsA("Sound") then
                        pcall(function() snd.SoundId = "rbxassetid://" .. customSoundId end)
                    end
                end
            end
        end)
        table.insert(soundConnections, conn2)
    end)
    table.insert(soundConnections, respawnConn)
end

--------------------------------------------------
-- BUILD UI - RAGE TAB
--------------------------------------------------

local playerList = {}
for _, p in pairs(Players:GetPlayers()) do if p ~= localPlayer then table.insert(playerList, p.Name) end end

local function updateAllDropdowns()
    table.sort(playerList)
    if Options.RageTargetSelect then
        Options.RageTargetSelect:SetValues(playerList)
    end
end

local function updateTargetAvatar(playerName)
    local avatarImage = localPlayer.PlayerGui:FindFirstChild("TargetAvatarFrame", true) and localPlayer.PlayerGui:FindFirstChild("TargetAvatarFrame", true):FindFirstChild("AvatarImage")
    local playerInfoLabel = localPlayer.PlayerGui:FindFirstChild("TargetAvatarFrame", true) and localPlayer.PlayerGui:FindFirstChild("TargetAvatarFrame", true):FindFirstChild("PlayerInfoLabel")
    local player = Players:FindFirstChild(playerName)
    if player then
        local avatarId = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
        if avatarImage then avatarImage.Image = avatarId end
        if playerInfoLabel then playerInfoLabel.Text = "Username: " .. player.Name .. "\nDisplay Name: " .. player.DisplayName .. "\nUser ID: " .. player.UserId end
    else
        if avatarImage then avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150" end
        if playerInfoLabel then playerInfoLabel.Text = "Player not found" end
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= localPlayer and not table.find(playerList, p.Name) then
        table.insert(playerList, p.Name)
        updateAllDropdowns()
    end
end)

Players.PlayerRemoving:Connect(function(p)
    for i, n in pairs(playerList) do
        if n == p.Name then
            table.remove(playerList, i)
            break
        end
    end
    updateAllDropdowns()
    if selectedTargetPlayer == p.Name then
        selectedTargetPlayer = playerList[1] or ""
        updateTargetAvatar(selectedTargetPlayer)
        if Options.RageTargetSelect then
            Options.RageTargetSelect:SetValue(selectedTargetPlayer)
        end
    end
end)

-- Silent Aim UI section removed

Tabs.Rage:AddSection("Anti-Aim (Desync)")

Tabs.Rage:AddToggle("DesyncToggle", {
    Title = "Enable Anti-Aim",
    Default = false
}):OnChanged(function(v)
    desyncConfig.toggleEnabled = v
    if not v then toggleDesync(false) end
end)
Options.DesyncToggle:SetValue(false)

Tabs.Rage:AddDropdown("DesyncMode", {
    Title = "Desync Method",
    Values = {"Bait", "Randomize", "Destroy Cheaters", "Static Void", "Predictions Breaker", "Unhittable"},
    Default = "Bait"
}):OnChanged(function(v) desyncConfig.mode = v end)

Tabs.Rage:AddButton({
    Title = "Activate Desync",
    Description = "Toggle desync ON/OFF.",
    Callback = function()
        if desyncConfig.toggleEnabled then
            toggleDesync(not desyncConfig.enabled)
        else
            notify("Anti-Aim", "Enable Anti-Aim toggle first!")
        end
    end
})

Tabs.Rage:AddSection("Target Strafe")

Tabs.Rage:AddToggle("StrafeEnabled", {
    Title = "Enable Target Strafe",
    Default = false
}):OnChanged(function(v)
    strafeSettings.enabled = v
    if not v and isStrafing then toggleStrafe() end
end)
Options.StrafeEnabled:SetValue(false)

Tabs.Rage:AddButton({
    Title = "Toggle Strafe",
    Callback = function() toggleStrafe() end
})

Tabs.Rage:AddSlider("StrafeRadius", {
    Title = "Strafe Radius",
    Default = 10, Min = 5, Max = 50, Rounding = 1
}):OnChanged(function(v) strafeSettings.strafeRadius = v end)

Tabs.Rage:AddSlider("StrafeSpeed", {
    Title = "Strafe Speed",
    Default = 5, Min = 1, Max = 20, Rounding = 1
}):OnChanged(function(v) strafeSettings.strafeSpeed = v end)

Tabs.Rage:AddSlider("StrafeHeight", {
    Title = "Strafe Height",
    Default = 5, Min = 0, Max = 20, Rounding = 1
}):OnChanged(function(v) strafeSettings.strafeHeight = v end)

--------------------------------------------------
-- BUILD UI - TARGETING SECTION
--------------------------------------------------

do
    --------------------------------------------------
    -- CLICK TO TARGET STATE & FUNCTIONS
    --------------------------------------------------
    local pickingTarget = false
    local pickConnection = nil
    local hoverConnection = nil
    local currentHoveredChar = nil
    local hoverHighlight = nil

    local function clearHoverHighlight()
        if hoverHighlight then
            pcall(function() hoverHighlight:Destroy() end)
            hoverHighlight = nil
        end
        currentHoveredChar = nil
    end

    local function stopPicking()
        pickingTarget = false
        if pickConnection then pickConnection:Disconnect() pickConnection = nil end
        if hoverConnection then hoverConnection:Disconnect() hoverConnection = nil end
        clearHoverHighlight()
    end
    
    _G.stopPickingTarget = stopPicking

    local function startPickingTarget()
        if pickingTarget then
            stopPicking()
            notify("Targeting", "Target pick cancelled.")
            return
        end
        
        pickingTarget = true
        notify("Targeting", "Hover over a player and click to target them. (ESC to cancel)")
        
        local function getPlayerUnderMouse()
            local mousePos = UserInputService:GetMouseLocation()
            local unitRay = currentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
            
            -- Find the player whose character is closest to the ray
            local closestPlayer = nil
            local closestDistance = 15 -- Max stud distance from ray line to character root
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Calculate distance from point (root position) to line (ray origin + ray direction)
                        local rayToRoot = root.Position - unitRay.Origin
                        local projection = rayToRoot:Dot(unitRay.Direction)
                        if projection > 0 then
                            local closestPointOnRay = unitRay.Origin + (unitRay.Direction * projection)
                            local dist = (root.Position - closestPointOnRay).Magnitude
                            if dist < closestDistance then
                                closestDistance = dist
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            
            return closestPlayer
        end

        hoverConnection = RunService.RenderStepped:Connect(function()
            local player = getPlayerUnderMouse()
            local model = player and player.Character
            if model then
                if currentHoveredChar ~= model then
                    clearHoverHighlight()
                    currentHoveredChar = model
                    hoverHighlight = Instance.new("Highlight")
                    hoverHighlight.Name = "FIXZ_HoverHighlight"
                    hoverHighlight.FillColor = Color3.fromRGB(0, 255, 128)
                    hoverHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hoverHighlight.FillTransparency = 0.6
                    hoverHighlight.OutlineTransparency = 0.2
                    hoverHighlight.Parent = model
                end
            else
                clearHoverHighlight()
            end
        end)
        
        pickConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local player = getPlayerUnderMouse()
                if player then
                    stopPicking()
                    if Options.RageTargetSelect then
                        Options.RageTargetSelect:SetValue(player.Name)
                    end
                    notify("Targeting", "Selected target: " .. player.Name)
                end
            elseif input.KeyCode == Enum.KeyCode.Escape then
                stopPicking()
                notify("Targeting", "Target pick cancelled.")
            end
        end)
    end

    --------------------------------------------------
    -- BUILD UI - TARGETING SECTION
    --------------------------------------------------

    Tabs.Rage:AddSection("Targeting")

    local targetDropdown = Tabs.Rage:AddDropdown("RageTargetSelect", {
        Title = "Select Target Player",
        Description = "Select a player from the server to target.",
        Values = playerList,
        Default = playerList[1] or ""
    })

    local pickTargetBtn = Tabs.Rage:AddButton({
        Title = "Pick Target (Hover & Click)",
        Description = "Click here, then click a player character in the workspace to target them.",
        Callback = function()
            startPickingTarget()
        end
    })

    -- Custom Avatar Frame
    local targetAvatarFrame = Instance.new("Frame")
    targetAvatarFrame.Name = "TargetAvatarFrame"
    targetAvatarFrame.Size = UDim2.new(1, -20, 0, 120)
    targetAvatarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    targetAvatarFrame.BorderSizePixel = 0

    local corner = Instance.new("UICorner", targetAvatarFrame)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", targetAvatarFrame)
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1.2

    local avatarImage = Instance.new("ImageLabel", targetAvatarFrame)
    avatarImage.Name = "AvatarImage"
    avatarImage.Size = UDim2.new(0, 90, 0, 90)
    avatarImage.Position = UDim2.new(0, 15, 0, 15)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"

    local avatarCorner = Instance.new("UICorner", avatarImage)
    avatarCorner.CornerRadius = UDim.new(1, 0)

    local avatarStroke = Instance.new("UIStroke", avatarImage)
    avatarStroke.Color = Color3.fromRGB(60, 60, 60)
    avatarStroke.Thickness = 1.5

    local playerInfoLabel = Instance.new("TextLabel", targetAvatarFrame)
    playerInfoLabel.Name = "PlayerInfoLabel"
    playerInfoLabel.Size = UDim2.new(1, -130, 0, 80)
    playerInfoLabel.Position = UDim2.new(0, 120, 0, 20)
    playerInfoLabel.BackgroundTransparency = 1
    playerInfoLabel.Font = Enum.Font.GothamBold
    playerInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerInfoLabel.TextSize = 13
    playerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    playerInfoLabel.TextWrapped = true
    playerInfoLabel.LineHeight = 1.3
    playerInfoLabel.Text = "Select a player to view info"

    local gotoBtn = Tabs.Rage:AddButton({
        Title = "Teleport to Target (Goto)",
        Description = "Teleport to the selected target player's position.",
        Callback = function()
            if not selectedTargetPlayer or selectedTargetPlayer == "" then
                notify("Target Error", "Select a target first!")
                return
            end
            local target = Players:FindFirstChild(selectedTargetPlayer)
            local char = target and target.Character
            local targetHrp = char and char:FindFirstChild("HumanoidRootPart")
            local localHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and localHrp then
                localHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                notify("Target", "Teleported to " .. selectedTargetPlayer)
            else
                notify("Target Error", "Could not find player or target character.")
            end
        end
    })

    local killToggle = Tabs.Rage:AddToggle("KillTargetToggle", {
        Title = "Kill Target",
        Description = "Teleport above target and shoot until they are knocked.",
        Default = false
    })

    killToggle:OnChanged(function(v)
        targetKillActive = v
        if v then
            if not selectedTargetPlayer or selectedTargetPlayer == "" then
                notify("Target Error", "Select a target first!")
                Options.KillTargetToggle:SetValue(false)
                return
            end
            local target = Players:FindFirstChild(selectedTargetPlayer)
            if not target or not target.Character then
                notify("Target Error", "Target player or character not found.")
                Options.KillTargetToggle:SetValue(false)
                return
            end
            
            task.spawn(function()
                local savedPos = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character.HumanoidRootPart.CFrame
                
                -- Ensure gun equipped
                local tool = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Tool")
                if not tool or not tool:FindFirstChild("Ammo") then
                    tool = localPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                    if tool and tool:FindFirstChild("Ammo") then
                        tool.Parent = localPlayer.Character
                    end
                end
                
                if not tool or not tool:FindFirstChild("Ammo") then
                    notify("Kill Error", "Equip a gun or make sure you have one in your backpack!")
                    Options.KillTargetToggle:SetValue(false)
                    return
                end
                
                notify("Kill Target", "Activating kill automation on " .. target.Name)
                
                while targetKillActive and target.Character and not isKO(target) do
                    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        root.CFrame = targetRoot.CFrame * CFrame.new(0, 3.2, 0)
                        if not localPlayer.Character:FindFirstChild(tool.Name) then
                            tool.Parent = localPlayer.Character
                        end
                        if autoReloadAndAim(tool, target.Character) then
                            shootAtHead(tool, target.Character, 5)
                        end
                    end
                    task.wait(0.08)
                end
                
                targetKillActive = false
                Options.KillTargetToggle:SetValue(false)
                
                if savedPos and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = savedPos
                end
                
                notify("Kill Target", "Kill automation ended.")
            end)
        end
    end)

    task.spawn(function()
        while not targetDropdown.Frame or not targetDropdown.Frame.Parent or not pickTargetBtn.Frame or not gotoBtn.Frame or not killToggle.Frame do
            task.wait()
        end
        local baseOrder = targetDropdown.Frame.LayoutOrder
        targetAvatarFrame.Parent = targetDropdown.Frame.Parent
        targetAvatarFrame.LayoutOrder = baseOrder + 1
        pickTargetBtn.Frame.LayoutOrder = baseOrder + 2
        gotoBtn.Frame.LayoutOrder = baseOrder + 3
        killToggle.Frame.LayoutOrder = baseOrder + 4
    end)

    local function updateTargetAvatarLocal(playerName)
        local player = Players:FindFirstChild(playerName)
        if player then
            local avatarId = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
            avatarImage.Image = avatarId
            playerInfoLabel.Text = "Username: " .. player.Name .. "\nDisplay Name: " .. player.DisplayName .. "\nUser ID: " .. player.UserId
        else
            avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
            playerInfoLabel.Text = "Player not found"
        end
    end

    targetDropdown:OnChanged(function(v)
        selectedTargetPlayer = v
        updateTargetAvatarLocal(v)
    end)

    if playerList[1] then
        selectedTargetPlayer = playerList[1]
        updateTargetAvatarLocal(playerList[1])
    end
end

--------------------------------------------------
-- BUILD UI - LEGIT TAB
--------------------------------------------------

Tabs.Legit:AddSection("Camlock")

Tabs.Legit:AddToggle("CamlockEnabled", {
    Title = "Enable Camlock",
    Default = false
}):OnChanged(function(v)
    camlockSettings.aimLockEnabled = v
    if not v then camlockSettings.lockEnabled = false camlockSettings.isLockedOn = false camlockSettings.targetPlayer = nil end
end)
Options.CamlockEnabled:SetValue(false)

Tabs.Legit:AddButton({
    Title = "Toggle Lock (click to turn on. Press keybind to toggle)",
    Callback = function()
        camlockSettings.lockEnabled = not camlockSettings.lockEnabled
        if not camlockSettings.lockEnabled then camlockSettings.isLockedOn = false camlockSettings.targetPlayer = nil end
        toggleCamlock()
    end
})

Tabs.Legit:AddSlider("CamlockSmoothing", {
    Title = "Camera Smoothing",
    Default = 10, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v) camlockSettings.smoothingFactor = v / 100 end)

Tabs.Legit:AddSlider("CamlockPrediction", {
    Title = "Prediction Factor",
    Default = 0, Min = 0, Max = 90, Rounding = 0
}):OnChanged(function(v) camlockSettings.predictionFactor = v / 100 end)

Tabs.Legit:AddDropdown("CamlockBodyPart", {
    Title = "Target Body Part",
    Values = {"Head","UpperTorso","HumanoidRootPart","RightUpperArm","LeftUpperArm","RightUpperLeg","LeftUpperLeg"},
    Default = "Head"
}):OnChanged(function(v) camlockSettings.bodyPartSelected = v end)

Tabs.Legit:AddToggle("TeamCheck", {
    Title = "Team Check",
    Default = false
}):OnChanged(function(v) camlockSettings.teamCheckEnabled = v end)
Options.TeamCheck:SetValue(false)

-- Streamable Silent Aim UI section removed

Tabs.Legit:AddSection("Hitbox Expander")

Tabs.Legit:AddToggle("HitboxMaster", {
    Title = "Enable Hitbox Expander",
    Default = false
}):OnChanged(function(v)
    hitboxSettings.scriptEnabled = v
    if not v then hitboxSettings.expanderActive = false end
    toggleHitboxConnection(v and hitboxSettings.expanderActive)
end)
Options.HitboxMaster:SetValue(false)

Tabs.Legit:AddToggle("HitboxExpander", {
    Title = "Activate Expander",
    Default = false
}):OnChanged(function(v)
    if hitboxSettings.scriptEnabled then hitboxSettings.expanderActive = v end
    toggleHitboxConnection(hitboxSettings.scriptEnabled and hitboxSettings.expanderActive)
end)
Options.HitboxExpander:SetValue(false)

Tabs.Legit:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Default = 30, Min = 10, Max = 100, Rounding = 0
}):OnChanged(function(v) hitboxSettings.size = v end)

Tabs.Legit:AddSlider("HitboxTransparency", {
    Title = "Hitbox Transparency",
    Default = 50, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v) hitboxSettings.transparency = v / 100 end)

-- Old Target UI section removed

--------------------------------------------------
-- BUILD UI - GAME TAB
--------------------------------------------------

Tabs.Game:AddSection("Movement")

Tabs.Game:AddToggle("SpeedEnabled", {
    Title = "Enable CFrame Speed",
    Default = false
}):OnChanged(function(v)
    cframeSpeedSettings.isFunctionalityEnabled = v
    toggleSpeedConnection(v)
end)
Options.SpeedEnabled:SetValue(false)

Tabs.Game:AddToggle("SpeedActive", {
    Title = "Activate Speed (press keybind or turn on ->)",
    Default = false
}):OnChanged(function(v) cframeSpeedSettings.isSpeedActive = v end)
Options.SpeedActive:SetValue(false)

Tabs.Game:AddSlider("SpeedMultiplier", {
    Title = "Speed Multiplier",
    Default = 1, Min = 1, Max = 20, Rounding = 1
}):OnChanged(function(v) cframeSpeedSettings.multiplier = v end)

Tabs.Game:AddToggle("FlyEnabled", {
    Title = "Enable CFrame Fly",
    Default = false
}):OnChanged(function(v)
    flyConfig.enabled = v
    flyActive = v
    toggleFlyConnection(v)
end)
Options.FlyEnabled:SetValue(false)

Tabs.Game:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 30, Min = 30, Max = 500, Rounding = 0
}):OnChanged(function(v) cframeFlySpeed = v / 10 end)

Tabs.Game:AddSection("Shop")

do
    local searchDebounce = nil
    Tabs.Game:AddInput("ShopSearch", {
        Title = "Search Shop Item",
        Default = "",
        Placeholder = "Search item name..."
    }):OnChanged(function(searchText)
        if searchDebounce then task.cancel(searchDebounce) end
        searchDebounce = task.delay(0.1, function()
            local lowerSearch = searchText:lower()
            if lowerSearch == "" then return end
            local allItems = getShopItemNames()
            local lowerItems = cachedLowerShopItemNames
            for i = 1, #allItems do
                local name = allItems[i]
                local lowerName = lowerItems[i]
                if lowerName and lowerName:find(lowerSearch, 1, true) then
                    if Options.ShopItem and Options.ShopItem.Value ~= name then
                        Options.ShopItem:SetValue(name)
                    end
                    break
                end
            end
        end)
    end)
end

Tabs.Game:AddDropdown("ShopItem", {
    Title = "Select Item",
    Values = getShopItemNames(),
    Default = getShopItemNames()[1] or ""
}):OnChanged(function(v) selectedShopItem = v end)

Tabs.Game:AddButton({
    Title = "Buy Item",
    Callback = function() executeBuyItem(selectedShopItem) end
})

Tabs.Game:AddToggle("AutoBuyRespawn", {
    Title = "Auto Buy on Respawn",
    Default = false
}):OnChanged(function(v) autoBuyOnRespawn = v end)
Options.AutoBuyRespawn:SetValue(false)

Tabs.Game:AddSection("Misc")

Tabs.Game:AddToggle("RapidFire", {
    Title = "Rapid Fire",
    Default = false
}):OnChanged(function(v)
    if v then
        task.spawn(function()
            local lastTool = nil
            while Options.RapidFire.Value do
                local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool ~= lastTool and tool:FindFirstChild("GunScript") then
                    lastTool = tool
                    pcall(function()
                        for _, conn in ipairs(getconnections(tool.Activated)) do
                            for i = 1, debug.getinfo(conn.Function).nups do
                                local n = debug.getupvalue(conn.Function, i)
                                if type(n) == "number" then debug.setupvalue(conn.Function, i, 1e-20) end
                            end
                        end
                    end)
                end
                task.wait(0.1)
            end
            lastTool = nil
        end)
    end
end)
Options.RapidFire:SetValue(false)

local hyperFireEnabled = false
Tabs.Game:AddToggle("AutoGuns", {
    Title = "Automatic Guns",
    Default = false
}):OnChanged(function(v)
    hyperFireEnabled = v
    if v then
        pcall(function()
            local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                for _, d in pairs(tool:GetDescendants()) do
                    if d.Name == "ToleranceCooldown" and d:IsA("ValueBase") then d.Value = 0 end
                end
            end
        end)
    end
end)
Options.AutoGuns:SetValue(false)

RunService.RenderStepped:Connect(function()
    if hyperFireEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and localPlayer.Character then
        local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Ammo") then pcall(function() tool:Activate() end) end
    end
end)

Tabs.Game:AddButton({
    Title = "Magic Bullet (might work might not)",
    Callback = function()
        pcall(function()
            local mm = game:FindService("ReplicatedStorage").MainModule
            require(mm).Ignored = {
                Workspace:WaitForChild("Vehicles"),
                Workspace:WaitForChild("MAP"),
                Workspace:WaitForChild("Ignored"),
            }
        end)
        notify("Magic Bullet", "Applied!")
    end
})

Tabs.Game:AddToggle("AntiStomp", {
    Title = "Anti Stomp (doesnt work sorry :( )",
    Default = false
}):OnChanged(function(v)
    if v then
        playAntiStompEmote()
    else
        if antiStompThread then task.cancel(antiStompThread) antiStompThread = nil end
        if antiStompAnimationTrack then pcall(function() antiStompAnimationTrack:Stop(0.1) end) antiStompAnimationTrack = nil end
    end
end)
Options.AntiStomp:SetValue(false)



Tabs.Game:AddToggle("AutoReloadToggle", {
    Title = "Auto Reload",
    Description = "Automatically reloads equipped guns when out of ammo",
    Default = false
}):OnChanged(function(v)
    autoReloadEnabled = v
    if v then
        startAutoReloadLoop()
    else
        if autoReloadThread then
            task.cancel(autoReloadThread)
            autoReloadThread = nil
        end
    end
end)
Options.AutoReloadToggle:SetValue(false)

Tabs.Game:AddSection("Multi Equip Tools")

multiEquipDropdown = Tabs.Game:AddDropdown("MultiEquipDropdown", {
    Title = "Select Tools",
    Description = "Select multiple tools to equip.",
    Values = getInventoryTools(),
    Multi = true,
    Default = {}
})

multiEquipDropdown:OnChanged(function(v)
    multiEquipSettings.selected = v
end)

Tabs.Game:AddToggle("MultiEquipToggle", {
    Title = "Enable Multi Equip",
    Default = false
}):OnChanged(function(v)
    multiEquipSettings.enabled = v
    if v then
        setupToolActivationHook()
        startMultiEquipLoop()
    else
        if toolActivationConnection then
            toolActivationConnection:Disconnect()
            toolActivationConnection = nil
        end
    end
end)
Options.MultiEquipToggle:SetValue(false)

Tabs.Game:AddButton({
    Title = "Refresh Tool List",
    Callback = function()
        refreshMultiEquipDropdown()
    end
})

--------------------------------------------------
-- BUILD UI - VISUALS TAB
--------------------------------------------------

Tabs.Visuals:AddSection("Self Chams")

Tabs.Visuals:AddDropdown("SelfMaterial", {
    Title = "Self Material",
    Values = {"None", "ForceField", "Neon", "Glass", "SmoothPlastic"},
    Default = "None"
}):OnChanged(function(v)
    selfMaterialMode = v
    local char = localPlayer.Character
    if char then
        if v == "None" then removeMaterial(char)
        elseif materialMap[v] then applyMaterial(char, materialMap[v]) end
    end
end)

Tabs.Visuals:AddToggle("SelfHighlight", {
    Title = "Self Highlight",
    Default = false
}):OnChanged(function(v)
    selfHighlightEnabled = v
    local char = localPlayer.Character
    if v and char then
        applySelfHighlight(char)
    elseif selfHighlight then
        pcall(function() selfHighlight:Destroy() end)
        selfHighlight = nil
    end
end)
Options.SelfHighlight:SetValue(false)

Tabs.Visuals:AddColorpicker("SelfHighlightFillColor", {
    Title = "Self Fill Color",
    Default = Color3.fromRGB(0, 200, 255)
}):OnChanged(function(v)
    selfHighlightFillColor = v
    updateSelfHighlight()
end)

Tabs.Visuals:AddSlider("SelfHighlightFillBrightness", {
    Title = "Self Fill Brightness (Opacity)",
    Default = 50, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    selfHighlightFillTransparency = (100 - v) / 100
    updateSelfHighlight()
end)

Tabs.Visuals:AddColorpicker("SelfHighlightOutlineColor", {
    Title = "Self Outline Color",
    Default = Color3.fromRGB(255, 255, 255)
}):OnChanged(function(v)
    selfHighlightOutlineColor = v
    updateSelfHighlight()
end)

Tabs.Visuals:AddSlider("SelfHighlightOutlineBrightness", {
    Title = "Self Outline Brightness (Opacity)",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    selfHighlightOutlineTransparency = (100 - v) / 100
    updateSelfHighlight()
end)

Tabs.Visuals:AddSection("ESP")

Tabs.Visuals:AddToggle("ESPEnabled", {
    Title = "Enable ESP",
    Default = false
}):OnChanged(function(v)
    espConfig.enabled = v
    if v then
        startESP()
    else
        stopESP()
    end
end)
Options.ESPEnabled:SetValue(false)

Tabs.Visuals:AddToggle("ESPShowBox", {
    Title = "Show Box",
    Default = false
}):OnChanged(function(v)
    espConfig.showBox = v
end)
Options.ESPShowBox:SetValue(false)

Tabs.Visuals:AddColorpicker("ESPBoxColor", {
    Title = "Box Color",
    Default = Color3.fromRGB(255, 0, 0)
}):OnChanged(function(v)
    espConfig.boxColor = v
end)

Tabs.Visuals:AddSlider("ESPBoxOpacity", {
    Title = "Box Opacity",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    espConfig.boxOpacity = v / 100
end)

Tabs.Visuals:AddToggle("ESPShowName", {
    Title = "Show Name",
    Default = false
}):OnChanged(function(v)
    espConfig.showName = v
end)
Options.ESPShowName:SetValue(false)

Tabs.Visuals:AddColorpicker("ESPNameColor", {
    Title = "Name Color",
    Default = Color3.fromRGB(255, 255, 255)
}):OnChanged(function(v)
    espConfig.nameColor = v
end)

Tabs.Visuals:AddSlider("ESPNameOpacity", {
    Title = "Name Opacity",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    espConfig.nameOpacity = v / 100
end)

Tabs.Visuals:AddToggle("ESPShowHealthBar", {
    Title = "Show Health Bar",
    Default = false
}):OnChanged(function(v)
    espConfig.showHealthBar = v
end)
Options.ESPShowHealthBar:SetValue(false)

Tabs.Visuals:AddColorpicker("ESPHealthColorFull", {
    Title = "Health Bar Full Color",
    Default = Color3.fromRGB(0, 255, 0)
}):OnChanged(function(v)
    espConfig.healthColorFull = v
end)

Tabs.Visuals:AddColorpicker("ESPHealthColorLow", {
    Title = "Health Bar Low Color",
    Default = Color3.fromRGB(255, 0, 0)
}):OnChanged(function(v)
    espConfig.healthColorLow = v
end)

Tabs.Visuals:AddToggle("ESPShowTracers", {
    Title = "Show Tracers",
    Default = false
}):OnChanged(function(v)
    espConfig.showTracers = v
end)
Options.ESPShowTracers:SetValue(false)

Tabs.Visuals:AddDropdown("ESPTracerPos", {
    Title = "Tracer Position",
    Values = {"Bottom", "Mouse"},
    Default = "Bottom"
}):OnChanged(function(v)
    espConfig.tracerPosition = v
end)

Tabs.Visuals:AddColorpicker("ESPTracerColor", {
    Title = "Tracer Color",
    Default = Color3.fromRGB(255, 0, 0)
}):OnChanged(function(v)
    espConfig.tracerColor = v
end)

Tabs.Visuals:AddSlider("ESPTracerOpacity", {
    Title = "Tracer Opacity",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    espConfig.tracerOpacity = v / 100
end)

Tabs.Visuals:AddToggle("ESPShowChams", {
    Title = "Show Chams",
    Default = false
}):OnChanged(function(v)
    espConfig.showChams = v
end)
Options.ESPShowChams:SetValue(false)

Tabs.Visuals:AddColorpicker("ESPChamFillColor", {
    Title = "Chams Fill Color",
    Default = Color3.fromRGB(255, 0, 128)
}):OnChanged(function(v)
    espConfig.chamFillColor = v
end)

Tabs.Visuals:AddSlider("ESPChamFillBrightness", {
    Title = "Chams Fill Brightness",
    Default = 50, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    espConfig.chamFillTransparency = (100 - v) / 100
end)

Tabs.Visuals:AddColorpicker("ESPChamOutlineColor", {
    Title = "Chams Outline Color",
    Default = Color3.fromRGB(255, 255, 255)
}):OnChanged(function(v)
    espConfig.chamOutlineColor = v
end)

Tabs.Visuals:AddSlider("ESPChamOutlineBrightness", {
    Title = "Chams Outline Brightness",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    espConfig.chamOutlineTransparency = (100 - v) / 100
end)

Tabs.Visuals:AddSection("Trail")

Tabs.Visuals:AddToggle("Trail", {
    Title = "Enable Trail",
    Default = false
}):OnChanged(function(v)
    trailConfig.enabled = v
    local char = localPlayer.Character
    if char then
        if v then applyTrail(char) else removeAllTrails(char) end
    end
    updateRainbowState()
end)
Options.Trail:SetValue(false)

Tabs.Visuals:AddDropdown("TrailColorMode", {
    Title = "Color Mode",
    Values = {"Solid", "Gradient", "Rainbow"},
    Default = "Solid"
}):OnChanged(function(v)
    trailConfig.colorMode = v
    if trailConfig.enabled then updateTrailProps() end
    updateRainbowState()
end)

Tabs.Visuals:AddColorpicker("TrailColorPrimary", {
    Title = "Trail Primary Color (Solid/Gradient)",
    Default = Color3.fromRGB(255, 255, 255)
}):OnChanged(function(v)
    trailConfig.color = v
    if trailConfig.enabled then updateTrailProps() end
end)

Tabs.Visuals:AddColorpicker("TrailColorSecondary", {
    Title = "Trail Secondary Color (Gradient)",
    Default = Color3.fromRGB(255, 0, 255)
}):OnChanged(function(v)
    trailConfig.color2 = v
    if trailConfig.enabled then updateTrailProps() end
end)

Tabs.Visuals:AddDropdown("TrailTexture", {
    Title = "Trail Shape",
    Values = {"Default", "Custom"},
    Default = "Default"
}):OnChanged(function(v)
    if v == "Default" then
        trailConfig.textureId = ""
        if trailConfig.enabled then updateTrailProps() end
    end
end)

Tabs.Visuals:AddInput("TrailCustomId", {
    Title = "Custom Texture ID",
    Description = "Enter Roblox asset ID for trail texture",
    Default = "",
    Placeholder = "e.g. 2529507921"
}):OnChanged(function(v)
    local id = v:match("%d+") or ""
    trailConfig.textureId = id
    if trailConfig.enabled then updateTrailProps() end
end)

Tabs.Visuals:AddSlider("TrailLifetime", {
    Title = "Trail Lifetime",
    Default = 10, Min = 1, Max = 50, Rounding = 1
}):OnChanged(function(v) trailConfig.lifetime = v / 10; updateTrailProps() end)

Tabs.Visuals:AddSlider("TrailWidth", {
    Title = "Trail Width",
    Default = 2, Min = 1, Max = 20, Rounding = 0
}):OnChanged(function(v) trailConfig.width = v; updateTrailProps() end)

Tabs.Visuals:AddSlider("TrailGlow", {
    Title = "Trail Glow",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v) trailConfig.lightEmission = v / 100; updateTrailProps() end)

Tabs.Visuals:AddSlider("TrailTransparency", {
    Title = "Trail Transparency",
    Default = 0, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v) trailConfig.transparency = v / 100; updateTrailProps() end)

Tabs.Visuals:AddSection("Spinbot")

Tabs.Visuals:AddToggle("SpinbotToggle", {
    Title = "Enable Spinbot",
    Description = "CS2-style character spin",
    Default = false
}):OnChanged(function(v)
    spinbotConfig.enabled = v
    toggleSpinbotConnection(v)
end)
Options.SpinbotToggle:SetValue(false)

Tabs.Visuals:AddSlider("SpinbotSpeed", {
    Title = "Spin Speed",
    Default = 20, Min = 1, Max = 60, Rounding = 0
}):OnChanged(function(v) spinbotConfig.speed = v end)

Tabs.Visuals:AddToggle("SpinbotLookUp", {
    Title = "Look Up (CS2 Style)",
    Description = "Tilts head and tool upward",
    Default = true
}):OnChanged(function(v) spinbotConfig.lookUp = v end)
Options.SpinbotLookUp:SetValue(true)

Tabs.Visuals:AddSection("Custom Shoot Sound")

Tabs.Visuals:AddToggle("CustomSoundEnabled", {
    Title = "Enable Custom Sound",
    Description = "Replace your ShootSound with a custom ID",
    Default = false
}):OnChanged(function(v)
    customSoundEnabled = v
    if v then
        applyCustomSounds()
    else
        for _, c in pairs(soundConnections) do pcall(function() c:Disconnect() end) end
        soundConnections = {}
        notify("Sound", "Custom shoot sound disabled.")
    end
end)
Options.CustomSoundEnabled:SetValue(false)

Tabs.Visuals:AddInput("CustomSoundId", {
    Title = "Sound ID",
    Description = "Enter Roblox sound asset ID (numbers only)",
    Default = "",
    Placeholder = "e.g. 131961136"
}):OnChanged(function(v)
    customSoundId = v:match("%d+") or ""
    if customSoundEnabled and customSoundId ~= "" then
        applyCustomSounds()
        notify("Sound", "Sound ID updated: " .. customSoundId)
    end
end)

Tabs.Visuals:AddDropdown("CustomSoundPreset", {
    Title = "Preset Sounds",
    Description = "Select a preset sound effect",
    Values = {"None", "Bark Fart", "Laser 1", "Laser 2", "Love Rev", "Meow"},
    Default = "None"
}):OnChanged(function(v)
    local presets = {
        ["Bark Fart"] = "119447356569253",
        ["Laser 1"] = "77280130656922",
        ["Laser 2"] = "105335761848767",
        ["Love Rev"] = "90072080058983",
        ["Meow"] = "134881862056957"
    }
    local id = presets[v]
    if id and Options.CustomSoundId then
        Options.CustomSoundId:SetValue(id)
    end
end)

Tabs.Visuals:AddButton({
    Title = "Apply Sound Now",
    Description = "Force-apply to current equipped tools",
    Callback = function()
        if customSoundId == "" then notify("Sound Error", "Enter a Sound ID first!") return end
        if not customSoundEnabled then notify("Sound Error", "Enable Custom Sound toggle first!") return end
        local char = localPlayer.Character
        if char then replaceSoundsInChar(char) end
        notify("Sound", "Applied sound ID: " .. customSoundId)
    end
})

Tabs.Visuals:AddSection("China Hat")

Tabs.Visuals:AddToggle("ChinaHatEnabled", {
    Title = "Enable China Hat",
    Description = "Renders a cosmetic conical hat on your character",
    Default = false
}):OnChanged(function(v)
    chinaHatConfig.enabled = v
    if v then
        startChinaHat()
    else
        stopChinaHat()
    end
    updateRainbowState()
end)
Options.ChinaHatEnabled:SetValue(false)

Tabs.Visuals:AddToggle("ChinaHatRainbow", {
    Title = "Rainbow Color",
    Description = "Cycle hat colors smoothly",
    Default = false
}):OnChanged(function(v)
    chinaHatConfig.rainbow = v
    updateRainbowState()
    if not v then
        updateChinaHatProperties()
    end
end)
Options.ChinaHatRainbow:SetValue(false)

Tabs.Visuals:AddColorpicker("ChinaHatColor", {
    Title = "Hat Color",
    Default = Color3.fromRGB(0, 200, 255)
}):OnChanged(function(v)
    chinaHatConfig.color = v
    if not chinaHatConfig.rainbow then
        updateChinaHatProperties()
    end
end)

Tabs.Visuals:AddSlider("ChinaHatTransparency", {
    Title = "Hat Transparency",
    Default = 30, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v)
    chinaHatConfig.transparency = v / 100
    updateChinaHatProperties()
end)

Tabs.Visuals:AddToggle("ChinaHatAlwaysOnTop", {
    Title = "Always On Top",
    Description = "Hat renders through walls",
    Default = true
}):OnChanged(function(v)
    chinaHatConfig.alwaysOnTop = v
    updateChinaHatProperties()
end)
Options.ChinaHatAlwaysOnTop:SetValue(true)

Tabs.Visuals:AddToggle("ChinaHatSelfOnly", {
    Title = "Self Only",
    Description = "Only render on your own character",
    Default = true
}):OnChanged(function(v)
    chinaHatConfig.selfOnly = v
    updateChinaHatProperties()
    if chinaHatConfig.enabled then
        stopChinaHat()
        startChinaHat()
    end
end)
Options.ChinaHatSelfOnly:SetValue(true)

Tabs.Visuals:AddSlider("ChinaHatHeight", {
    Title = "Hat Height",
    Default = 6, Min = 1, Max = 30, Rounding = 0
}):OnChanged(function(v)
    chinaHatConfig.height = v / 10
    updateChinaHatProperties()
end)

Tabs.Visuals:AddSlider("ChinaHatRadius", {
    Title = "Hat Radius",
    Default = 12, Min = 5, Max = 40, Rounding = 0
}):OnChanged(function(v)
    chinaHatConfig.radius = v / 10
    updateChinaHatProperties()
end)

Tabs.Visuals:AddSlider("ChinaHatHeightOffset", {
    Title = "Hat Height Offset",
    Description = "Adjust hat position above torso",
    Default = 20, Min = 10, Max = 40, Rounding = 1
}):OnChanged(function(v)
    chinaHatConfig.heightOffset = v / 10
    updateChinaHatProperties()
end)

--------------------------------------------------
-- BUILD UI - LIGHTING TAB
--------------------------------------------------

Tabs.Lighting:AddSection("Lighting")

Tabs.Lighting:AddToggle("LightingEnabled", {
    Title = "Enabled",
    Default = false
}):OnChanged(function(v)
    lightingConfig.Enabled = v
    applyLightingSettings()
end)
Options.LightingEnabled:SetValue(false)

Tabs.Lighting:AddToggle("LightingAmbient", {
    Title = "Ambient",
    Default = false
}):OnChanged(function(v)
    lightingConfig.AmbientEnabled = v
    applyLightingSettings()
end)
Options.LightingAmbient:SetValue(false)

Tabs.Lighting:AddColorpicker("LightingAmbientColor", {
    Title = "Ambient Color",
    Default = Color3.fromRGB(163, 204, 255)
}):OnChanged(function(v)
    lightingConfig.AmbientColor = v
    applyLightingSettings()
end)

Tabs.Lighting:AddToggle("LightingColorShiftTop", {
    Title = "Color Shift Top",
    Default = false
}):OnChanged(function(v)
    lightingConfig.ColorShiftTopEnabled = v
    applyLightingSettings()
end)
Options.LightingColorShiftTop:SetValue(false)

Tabs.Lighting:AddColorpicker("LightingTopColor", {
    Title = "Top Color",
    Default = Color3.fromRGB(163, 204, 255)
}):OnChanged(function(v)
    lightingConfig.ColorShiftTopColor = v
    applyLightingSettings()
end)

Tabs.Lighting:AddToggle("LightingColorShiftBottom", {
    Title = "Color Shift Bottom",
    Default = false
}):OnChanged(function(v)
    lightingConfig.ColorShiftBottomEnabled = v
    applyLightingSettings()
end)
Options.LightingColorShiftBottom:SetValue(false)

Tabs.Lighting:AddColorpicker("LightingBottomColor", {
    Title = "Bottom Color",
    Default = Color3.fromRGB(163, 204, 255)
}):OnChanged(function(v)
    lightingConfig.ColorShiftBottomColor = v
    applyLightingSettings()
end)

Tabs.Lighting:AddToggle("LightingCustomFog", {
    Title = "Custom Fog",
    Default = false
}):OnChanged(function(v)
    lightingConfig.CustomFogEnabled = v
    applyLightingSettings()
end)
Options.LightingCustomFog:SetValue(false)

Tabs.Lighting:AddColorpicker("LightingFogColor", {
    Title = "Fog Color",
    Default = Color3.fromRGB(163, 204, 255)
}):OnChanged(function(v)
    lightingConfig.FogColor = v
    applyLightingSettings()
end)

Tabs.Lighting:AddSlider("LightingFogEnd", {
    Title = "Fog End",
    Default = 500, Min = 0, Max = 10000, Rounding = 0
}):OnChanged(function(v)
    lightingConfig.FogEnd = v
    applyLightingSettings()
end)

Tabs.Lighting:AddSlider("LightingFogStart", {
    Title = "Fog Start",
    Default = 0, Min = 0, Max = 10000, Rounding = 0
}):OnChanged(function(v)
    lightingConfig.FogStart = v
    applyLightingSettings()
end)

Tabs.Lighting:AddToggle("LightingCustomTime", {
    Title = "Custom Time",
    Default = false
}):OnChanged(function(v)
    lightingConfig.CustomTimeEnabled = v
    applyLightingSettings()
end)
Options.LightingCustomTime:SetValue(false)

Tabs.Lighting:AddSlider("LightingClockTime", {
    Title = "Clock Time",
    Default = 11.8, Min = 0, Max = 24, Rounding = 1
}):OnChanged(function(v)
    lightingConfig.ClockTime = v
    applyLightingSettings()
end)

--------------------------------------------------
-- KEYBINDS
--------------------------------------------------

local camlockBind = Enum.KeyCode.Q
local flyBind     = Enum.KeyCode.F
local desyncBind  = Enum.KeyCode.V
local strafeBind  = Enum.KeyCode.B
local speedBind   = Enum.KeyCode.C
local hitboxBind  = Enum.KeyCode.H

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local kc = input.KeyCode
    if kc == camlockBind then
        toggleCamlock()
    elseif kc == desyncBind and desyncConfig.toggleEnabled then
        toggleDesync(not desyncConfig.enabled)
    elseif kc == strafeBind and strafeSettings.enabled then
        toggleStrafe()
    elseif kc == speedBind then
        cframeSpeedSettings.isSpeedActive = not cframeSpeedSettings.isSpeedActive
    elseif kc == hitboxBind and hitboxSettings.scriptEnabled then
        hitboxSettings.expanderActive = not hitboxSettings.expanderActive
        Options.HitboxExpander:SetValue(hitboxSettings.expanderActive)
    elseif kc == flyBind and flyConfig.enabled then
        flyActive = not flyActive
        Options.FlyEnabled:SetValue(flyActive)
    end
end)

--------------------------------------------------
-- SETTINGS TAB
--------------------------------------------------

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"ShopSearch"})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/da-hood")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Settings:AddSection("Camera Lock")

Tabs.Settings:AddDropdown("CamlockBind", {
    Title = "Camlock Keybind",
    Description = "Key to toggle camera lock",
    Values = {"Q","E","R","T","Y","F","G","Z","X","C","V","B","N","M",
              "F1","F2","F3","F4","F5","F6","F7","F8",
              "LeftAlt","RightAlt","LeftControl","RightControl"},
    Default = "Q"
}):OnChanged(function(v)
    local ok, key = pcall(function() return Enum.KeyCode[v] end)
    if ok and key then camlockBind = key end
end)

Tabs.Settings:AddDropdown("FlyBind", {
    Title = "Fly Keybind",
    Description = "Key to toggle flying",
    Values = {"Q","E","R","T","Y","F","G","Z","X","C","V","B","N","M",
              "F1","F2","F3","F4","F5","F6","F7","F8",
              "LeftAlt","RightAlt","LeftControl","RightControl"},
    Default = "F"
}):OnChanged(function(v)
    local ok, key = pcall(function() return Enum.KeyCode[v] end)
    if ok and key then flyBind = key end
end)

Tabs.Settings:AddDropdown("DesyncBind", {
    Title = "Desync Keybind",
    Description = "Key to toggle desync (anti-aim)",
    Values = {"Q","E","R","T","Y","F","G","Z","X","C","V","B","N","M",
              "F1","F2","F3","F4","F5","F6","F7","F8",
              "LeftAlt","RightAlt","LeftControl","RightControl"},
    Default = "V"
}):OnChanged(function(v)
    local ok, key = pcall(function() return Enum.KeyCode[v] end)
    if ok and key then desyncBind = key end
end)

Tabs.Settings:AddDropdown("StrafeBind", {
    Title = "Strafe Keybind",
    Description = "Key to toggle target strafe",
    Values = {"Q","E","R","T","Y","F","G","Z","X","C","V","B","N","M",
              "F1","F2","F3","F4","F5","F6","F7","F8",
              "LeftAlt","RightAlt","LeftControl","RightControl"},
    Default = "B"
}):OnChanged(function(v)
    local ok, key = pcall(function() return Enum.KeyCode[v] end)
    if ok and key then strafeBind = key end
end)

Tabs.Settings:AddDropdown("SpeedBind", {
    Title = "Speed Keybind",
    Description = "Key to toggle CFrame speed",
    Values = {"Q","E","R","T","Y","F","G","Z","X","C","V","B","N","M",
              "F1","F2","F3","F4","F5","F6","F7","F8",
              "LeftAlt","RightAlt","LeftControl","RightControl"},
    Default = "C"
}):OnChanged(function(v)
    local ok, key = pcall(function() return Enum.KeyCode[v] end)
    if ok and key then speedBind = key end
end)

Tabs.Settings:AddDropdown("HitboxBind", {
    Title = "Hitbox Keybind",
    Description = "Key to toggle hitbox expander",
    Values = {"Q","E","R","T","Y","F","G","Z","X","C","V","B","N","M",
              "F1","F2","F3","F4","F5","F6","F7","F8",
              "LeftAlt","RightAlt","LeftControl","RightControl"},
    Default = "H"
}):OnChanged(function(v)
    local ok, key = pcall(function() return Enum.KeyCode[v] end)
    if ok and key then hitboxBind = key end
end)

Tabs.Settings:AddSection("Script")

Tabs.Settings:AddButton({
    Title = "Unload Script",
    Description = "Cleans up all hooks and destroys the UI",
    Callback = function()
        -- disable all active systems
        targetKillActive = false
        if _G.stopPickingTarget then
            pcall(_G.stopPickingTarget)
            _G.stopPickingTarget = nil
        end
        autoReloadEnabled = false
        if antiStompThread then
            task.cancel(antiStompThread)
            antiStompThread = nil
        end
        if antiStompAnimationTrack then
            pcall(function() antiStompAnimationTrack:Stop(0.1) end)
            antiStompAnimationTrack = nil
        end
        if autoReloadThread then
            task.cancel(autoReloadThread)
            autoReloadThread = nil
        end
        camlockSettings.enabled = false
        desyncConfig.enabled = false
        strafeSettings.enabled = false
        spinbotConfig.enabled = false
        -- silent aim settings disable removed
        hitboxSettings.expanderActive = false
        flyActive = false
        flyConfig.enabled = false
        espConfig.enabled = false
        stopESP()
        chinaHatConfig.enabled = false
        stopChinaHat()
        if camlockConnection then camlockConnection:Disconnect() camlockConnection = nil end
        if strafeConnection then strafeConnection:Disconnect() strafeConnection = nil end
        if desyncConnection then desyncConnection:Disconnect() desyncConnection = nil end
        if hitboxConnection then hitboxConnection:Disconnect() hitboxConnection = nil end
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if spinbotConnection then spinbotConnection:Disconnect() spinbotConnection = nil end
        if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        multiEquipSettings.enabled = false
        if toolActivationConnection then
            toolActivationConnection:Disconnect()
            toolActivationConnection = nil
        end
        if backpackConnection1 then backpackConnection1:Disconnect() end
        if backpackConnection2 then backpackConnection2:Disconnect() end
        if charConnection1 then charConnection1:Disconnect() end
        if charConnection2 then charConnection2:Disconnect() end
        lightingConfig.Enabled = false
        applyLightingSettings()
        if lightingConnection then
            lightingConnection:Disconnect()
            lightingConnection = nil
        end
        -- metamethod restore removed
        -- unbind render steps
        pcall(function() RunService:UnbindFromRenderStep("fixz_camlock") end)
        pcall(function() RunService:UnbindFromRenderStep("fixz_hitbox") end)
        pcall(function() RunService:UnbindFromRenderStep("fixz_spinbot") end)
        pcall(function() RunService:UnbindFromRenderStep("fixz_fly") end)
        -- restore camera
        pcall(function()
            currentCamera.CameraType = Enum.CameraType.Custom
            currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        end)
        if playerAddedConn then playerAddedConn:Disconnect() playerAddedConn = nil end
        if playerRemovingConn then playerRemovingConn:Disconnect() playerRemovingConn = nil end
        if localCharAddedConn then localCharAddedConn:Disconnect() localCharAddedConn = nil end
        for p, data in pairs(playerCache) do
            if data.conn then data.conn:Disconnect() end
        end
        playerCache = {}
        chinaHatAdornments = {}
        espPlayers = {}
        
        -- remove self visuals
        pcall(function()
            local char = localPlayer.Character
            if char then removeMaterial(char) end
        end)
        pcall(function()
            if selfHighlight then selfHighlight:Destroy() end
        end)
        pcall(function()
            local char = localPlayer.Character
            if char then removeAllTrails(char) end
        end)
        -- remove notify GUI
        pcall(function()
            local g = game:GetService("CoreGui"):FindFirstChild("GoldNotifyGui")
            if not g then
                g = localPlayer:FindFirstChild("PlayerGui") and localPlayer.PlayerGui:FindFirstChild("GoldNotifyGui")
            end
            if g then g:Destroy() end
        end)
        -- destroy Fluent window
        pcall(function() Window:Destroy() end)
        notify("MD Hub", "Script unloaded successfully.")
    end
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
