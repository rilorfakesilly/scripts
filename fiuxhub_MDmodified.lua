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

local function refreshMultiEquipDropdown()
    if not multiEquipDropdown then return end
    local tools = getInventoryTools()
    multiEquipDropdown:SetValues(tools)
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

setupInventoryListeners()
setupToolActivationHook()

localPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    setupInventoryListeners()
    setupToolActivationHook()
    refreshMultiEquipDropdown()
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if multiEquipSettings.enabled and localPlayer.Character then
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

local lightingConnection
lightingConnection = RunService.Heartbeat:Connect(function()
    if lightingConfig.Enabled then
        applyLightingSettings()
    end
end)

--------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------

local function checkTeam(player)
    return not camlockSettings.teamCheckEnabled or player.Team ~= localPlayer.Team
end

local function getRole(player)
    if not player or not player.Character then return nil end
    for _, v in pairs(player.Character:GetDescendants()) do
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
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild(camlockSettings.bodyPartSelected) and checkTeam(p) then
            local part = p.Character[camlockSettings.bodyPartSelected]
            local sp, onScreen = currentCamera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(playerMouse.X, playerMouse.Y)).Magnitude
                if dist < shortest then shortest = dist result = p end
            end
        end
    end
    return result
end

RunService.RenderStepped:Connect(function()
    if not (camlockSettings.aimLockEnabled and camlockSettings.lockEnabled and camlockSettings.isLockedOn) then return end
    local tp = camlockSettings.targetPlayer
    if not tp or not tp.Character then
        camlockSettings.isLockedOn = false
        camlockSettings.targetPlayer = nil
        return
    end
    local hum = tp.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        camlockSettings.isLockedOn = false
        camlockSettings.targetPlayer = nil
        return
    end
    local be = tp.Character:FindFirstChild("BodyEffects")
    local ko = be and be:FindFirstChild("K.O")
    if ko and ko.Value then
        camlockSettings.isLockedOn = false
        camlockSettings.targetPlayer = nil
        return
    end
    local part = tp.Character:FindFirstChild(camlockSettings.bodyPartSelected)
    if part then
        local predicted = part.Position + (part.AssemblyLinearVelocity or Vector3.zero) * camlockSettings.predictionFactor
        local goalCF = CFrame.new(currentCamera.CFrame.Position, predicted)
        local alpha = math.clamp(1 - camlockSettings.smoothingFactor, 0.05, 1)
        currentCamera.CFrame = currentCamera.CFrame:Lerp(goalCF, alpha)
    end
end)

local function toggleCamlock()
    if camlockSettings.lockEnabled and camlockSettings.aimLockEnabled then
        if camlockSettings.isLockedOn then
            camlockSettings.isLockedOn = false
            camlockSettings.targetPlayer = nil
        else
            camlockSettings.targetPlayer = getCamlockTarget()
            if camlockSettings.targetPlayer and camlockSettings.targetPlayer.Character then
                local part = camlockSettings.targetPlayer.Character:FindFirstChild(camlockSettings.bodyPartSelected)
                if part then camlockSettings.isLockedOn = true end
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
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local sp, onScreen = currentCamera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(sp.X, sp.Y) - mouseLoc).Magnitude
                if dist < shortest then shortest = dist result = p end
            end
        end
    end
    return result
end

RunService.RenderStepped:Connect(function(dt)
    if strafeSettings.enabled and isStrafing and strafeTargetPlayer and strafeTargetPlayer.Character and strafeTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = strafeTargetPlayer.Character.HumanoidRootPart
        currentStrafeAngle = (currentStrafeAngle + strafeSettings.strafeSpeed * dt * 360) % 360
        local x = math.cos(math.rad(currentStrafeAngle)) * strafeSettings.strafeRadius
        local z = math.sin(math.rad(currentStrafeAngle)) * strafeSettings.strafeRadius
        local newPos = Vector3.new(targetRoot.Position.X + x, targetRoot.Position.Y + strafeSettings.strafeHeight, targetRoot.Position.Z + z)
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(newPos, targetRoot.Position)
            currentCamera.CameraSubject = targetRoot
        end
    end
end)

local function toggleStrafe()
    if isStrafing then
        isStrafing = false
        currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
        notify("Strafe", "Unstrafed " .. (strafeTargetPlayer and strafeTargetPlayer.Name or ""))
        strafeTargetPlayer = nil
    else
        strafeTargetPlayer = getStrafeTarget()
        if strafeTargetPlayer then
            isStrafing = true
            notify("Strafe", "Strafing " .. strafeTargetPlayer.Name)
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
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
    if hum then currentCamera.CameraSubject = hum end
end

local function toggleDesync(state)
    desyncConfig.enabled = state
    if state then
        currentCamera.CameraSubject = desyncPart
        notify("Anti-Aim", "Desync ON — mode: " .. desyncConfig.mode)
    else
        resetCameraToPlayer()
        notify("Anti-Aim", "Desync OFF")
    end
end

RunService.Heartbeat:Connect(function()
    local root = desyncConfig.enabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        desyncConfig.oldPosition = root.CFrame
        local mode = desyncConfig.mode
        local velocity = root.AssemblyLinearVelocity or Vector3.zero
        if mode == "Bait" then
            -- Teleports the character slightly to replicate baiting hitboxes
            desyncConfig.teleportPos = root.Position + Vector3.new(math.random(-5, 5), math.random(-2, 2), math.random(-5, 5))
        elseif mode == "Randomize" then
            -- Rapidly randomizes coordinates
            desyncConfig.teleportPos = root.Position + Vector3.new(math.random(-200, 200), math.random(-50, 50), math.random(-200, 200))
        elseif mode == "Destroy Cheaters" then
            -- Extremely large numbers to crash mathematical logic of auto-aim predictions
            desyncConfig.teleportPos = Vector3.new(9e18, 9e18, 9e18)
        elseif mode == "Static Void" then
            -- Fixed offset down into the void
            desyncConfig.teleportPos = root.Position - Vector3.new(0, 1500, 0)
        elseif mode == "Predictions Breaker" then
            -- Reversing current moving velocity to break lag-compensation calculations
            desyncConfig.teleportPos = root.Position - (velocity * 2.5) + Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
        elseif mode == "Unhittable" then
            -- Super high velocity vectors and erratic offsets
            desyncConfig.teleportPos = root.Position + Vector3.new(math.random(-99999, 99999), math.random(-99999, 99999), math.random(-99999, 99999))
        end
        root.CFrame = CFrame.new(desyncConfig.teleportPos)
        currentCamera.CameraSubject = desyncPart
        RunService.RenderStepped:Wait()
        desyncPart.CFrame = desyncConfig.oldPosition * CFrame.new(0, root.Size.Y/2 + 0.5, 0)
        root.CFrame = desyncConfig.oldPosition
    end
end)



-- FOV rendering removed

--------------------------------------------------
-- HITBOX EXPANDER
--------------------------------------------------

local function getHitboxTarget()
    local shortest = math.huge
    local mv = Vector2.new(playerMouse.X, playerMouse.Y)
    local result = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
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
    if player and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
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

local function runHitboxExpander()
    if not hitboxSettings.scriptEnabled or not hitboxSettings.expanderActive then
        if hitboxSettings.expandedPlayer then revertHitbox(hitboxSettings.expandedPlayer) hitboxSettings.expandedPlayer = nil end
        return
    end
    local target = getHitboxTarget()
    local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root then
        if hitboxSettings.expandedPlayer and hitboxSettings.expandedPlayer ~= target then revertHitbox(hitboxSettings.expandedPlayer) end
        if not hitboxSettings.originalProps[target] then
            hitboxSettings.originalProps[target] = { Size = root.Size, Transparency = root.Transparency, CanCollide = root.CanCollide }
        end
        hitboxSettings.expandedPlayer = target
        root.Size = Vector3.new(hitboxSettings.size, hitboxSettings.size, hitboxSettings.size)
        root.Transparency = hitboxSettings.transparency
        root.CanCollide = false
    end
end

RunService.RenderStepped:Connect(runHitboxExpander)

--------------------------------------------------
-- CFRAME SPEED
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait()
        if cframeSpeedSettings.isFunctionalityEnabled then
            local char = localPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hum = char:FindFirstChild("Humanoid")
                if cframeSpeedSettings.isSpeedActive and hum and hum.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + hum.MoveDirection.Unit * cframeSpeedSettings.multiplier
                end
            end
        end
    end
end)

--------------------------------------------------
-- FLY
--------------------------------------------------

local flyMaid = {}
local isCFrameFlying = false
local cframeFlySpeed = 3
local flyCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local flyPivot = flyCharacter:GetPivot()
local flyActive = false

Players.LocalPlayer.CharacterAdded:Connect(function(c) flyCharacter = c end)

RunService.Stepped:Connect(function()
    if flyActive then
        flyPivot = CFrame.new(flyPivot.Position, flyPivot.Position + currentCamera.CFrame.LookVector)
        flyCharacter:PivotTo(flyPivot)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not flyActive then return end
    local kc = input.KeyCode
    task.spawn(function()
        if kc == Enum.KeyCode.W then while UserInputService:IsKeyDown(Enum.KeyCode.W) and flyActive do flyPivot = flyPivot * CFrame.new(0,0,-cframeFlySpeed) RunService.Stepped:Wait() end
        elseif kc == Enum.KeyCode.S then while UserInputService:IsKeyDown(Enum.KeyCode.S) and flyActive do flyPivot = flyPivot * CFrame.new(0,0,cframeFlySpeed) RunService.Stepped:Wait() end
        elseif kc == Enum.KeyCode.A then while UserInputService:IsKeyDown(Enum.KeyCode.A) and flyActive do flyPivot = flyPivot * CFrame.new(-cframeFlySpeed,0,0) RunService.Stepped:Wait() end
        elseif kc == Enum.KeyCode.D then while UserInputService:IsKeyDown(Enum.KeyCode.D) and flyActive do flyPivot = flyPivot * CFrame.new(cframeFlySpeed,0,0) RunService.Stepped:Wait() end
        end
    end)
end)

--------------------------------------------------
-- SHOP & PLAYER ACTIONS
--------------------------------------------------

local shopFolder = Workspace:WaitForChild("Ignored"):WaitForChild("Shop")
local selectedShopItem = nil
local isBuyingItem = false
local autoBuyOnRespawn = false

local function getLocalRoot()
    return localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getRandomShopItemByName(itemName)
    local items = {}
    for _, child in ipairs(shopFolder:GetChildren()) do
        if child.Name == itemName then
            table.insert(items, child)
        end
    end
    if #items > 0 then
        return items[math.random(1, #items)]
    end
    return nil
end

local cachedShopItemNames = {}

local function updateShopCache()
    local names = {}
    local seen = {}
    for _, child in ipairs(shopFolder:GetChildren()) do
        if not seen[child.Name] then
            seen[child.Name] = true
            table.insert(names, child.Name)
        end
    end
    table.sort(names)
    cachedShopItemNames = names
end

-- Initial population
updateShopCache()

local function getShopItemNames()
    return cachedShopItemNames
end

local function refreshShopDropdown()
    updateShopCache()
    if Options.ShopItem then
        local searchText = Options.ShopSearch and Options.ShopSearch.Value or ""
        local allItems = getShopItemNames()
        local filtered = {}
        local lowerSearch = searchText:lower()
        for _, name in ipairs(allItems) do
            if name:lower():find(lowerSearch, 1, true) then
                table.insert(filtered, name)
            end
        end
        Options.ShopItem:SetValues(filtered)
    end
end

shopFolder.ChildAdded:Connect(refreshShopDropdown)
shopFolder.ChildRemoved:Connect(refreshShopDropdown)

local function executeBuyItem(itemName)
    if not itemName or isBuyingItem then return end
    isBuyingItem = true
    local desyncWas = desyncConfig.enabled
    if desyncWas then toggleDesync(false) task.wait(0.1) end
    local root = getLocalRoot()
    if root then
        local item = getRandomShopItemByName(itemName)
        if item then
            local cd = item:FindFirstChildOfClass("ClickDetector")
            local targetPart = item:FindFirstChild("Head") or item:FindFirstChildOfClass("Part") or item:FindFirstChildWhichIsA("BasePart")
            if cd and targetPart then
                local saved = root.CFrame
                root.CFrame = CFrame.new(targetPart.Position + Vector3.new(0,3,0))
                task.wait(0.2)
                fireclickdetector(cd)
                notify("Shop", "Purchased: " .. itemName)
                root.CFrame = saved
            else notify("Shop Error", "ClickDetector or target part not found in " .. itemName) end
        else notify("Shop Error", "Item not found: " .. itemName) end
        if desyncWas then task.wait(0.2) toggleDesync(true) end
    end
    isBuyingItem = false
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    shopFolder = Workspace:WaitForChild("Ignored"):WaitForChild("Shop")
    refreshShopDropdown()
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

local function removeAllTrails(char)
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
    local char = localPlayer.Character
    if not char or not trailConfig.enabled then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, c in pairs(hrp:GetChildren()) do
        if c:IsA("Trail") then
            c.Color = getTrailColorSequence()
            c.Lifetime = trailConfig.lifetime
            c.Transparency = NumberSequence.new(trailConfig.transparency, 1)
            c.LightEmission = trailConfig.lightEmission
            c.WidthScale = NumberSequence.new(trailConfig.width / 10)
            if trailConfig.textureId ~= "" then
                c.Texture = "rbxassetid://" .. trailConfig.textureId
                c.TextureMode = Enum.TextureMode.Static
            else
                c.Texture = ""
            end
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    if trailConfig.enabled and trailConfig.colorMode == "Rainbow" then
        rainbowHue = (rainbowHue + dt * 0.5) % 1
        updateTrailProps()
    end
end)

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
    local char = localPlayer.Character
    if char and selfHighlightEnabled then
        applySelfHighlight(char)
    end
end

-- ==================================================
-- ESP (Drawing & Highlights) System
-- ==================================================

local espPlayers = {}

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
        Highlight = nil
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

for _, p in pairs(Players:GetPlayers()) do
    createESP(p)
end

local espPlayerAddedConnection = Players.PlayerAdded:Connect(createESP)
local espPlayerRemovingConnection = Players.PlayerRemoving:Connect(removeESP)

local espConnection
espConnection = RunService.RenderStepped:Connect(function()
    if not espConfig.enabled then return end
    for player, drawings in pairs(espPlayers) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        local visible = false
        
        if char and root and hum and hum.Health > 0 then
            local pos, onScreen = currentCamera:WorldToViewportPoint(root.Position)
            if onScreen then
                visible = true
                
                local extents = char:GetExtentsSize()
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
                    drawings.BoxOutline.Size = Vector2.new(width, height)
                    drawings.BoxOutline.Position = Vector2.new(boxX, boxY)
                    drawings.BoxOutline.Visible = true
                    
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(boxX, boxY)
                    drawings.Box.Color = espConfig.boxColor
                    drawings.Box.Transparency = espConfig.boxOpacity
                    drawings.Box.Visible = true
                else
                    drawings.BoxOutline.Visible = false
                    drawings.Box.Visible = false
                end
                
                -- Name
                if espConfig.showName then
                    drawings.Name.Position = Vector2.new(pos.X, boxY - 16)
                    drawings.Name.Text = player.Name
                    drawings.Name.Color = espConfig.nameColor
                    drawings.Name.Transparency = espConfig.nameOpacity
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
                
                -- Health Bar
                if espConfig.showHealthBar then
                    local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local healthColor = espConfig.healthColorLow:Lerp(espConfig.healthColorFull, healthPercent)
                    
                    local barX = boxX - 6
                    local barY = boxY
                    
                    drawings.HealthBarBg.From = Vector2.new(barX, barY)
                    drawings.HealthBarBg.To = Vector2.new(barX, barY + height)
                    drawings.HealthBarBg.Visible = true
                    
                    drawings.HealthBar.From = Vector2.new(barX, barY + height)
                    drawings.HealthBar.To = Vector2.new(barX, barY + height - (height * healthPercent))
                    drawings.HealthBar.Color = healthColor
                    drawings.HealthBar.Visible = true
                else
                    drawings.HealthBarBg.Visible = false
                    drawings.HealthBar.Visible = false
                end
                
                -- Tracer
                if espConfig.showTracers then
                    local fromPos
                    if espConfig.tracerPosition == "Bottom" then
                        fromPos = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y)
                    else
                        fromPos = UserInputService:GetMouseLocation()
                    end
                    
                    drawings.Tracer.From = fromPos
                    drawings.Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
                    drawings.Tracer.Color = espConfig.tracerColor
                    drawings.Tracer.Transparency = espConfig.tracerOpacity
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                -- Chams
                if espConfig.showChams then
                    if not drawings.Highlight or drawings.Highlight.Parent ~= char then
                        if drawings.Highlight then pcall(function() drawings.Highlight:Destroy() end) end
                        drawings.Highlight = Instance.new("Highlight")
                        drawings.Highlight.Name = "FIXZ_ESPChams"
                        drawings.Highlight.Parent = char
                    end
                    drawings.Highlight.FillColor = espConfig.chamFillColor
                    drawings.Highlight.OutlineColor = espConfig.chamOutlineColor
                    drawings.Highlight.FillTransparency = espConfig.chamFillTransparency
                    drawings.Highlight.OutlineTransparency = espConfig.chamOutlineTransparency
                    drawings.Highlight.Enabled = true
                else
                    if drawings.Highlight then
                        drawings.Highlight.Enabled = false
                    end
                end
            end
        end
        
        if not visible then
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            drawings.Name.Visible = false
            drawings.Tracer.Visible = false
            drawings.HealthBarBg.Visible = false
            drawings.HealthBar.Visible = false
            if drawings.Highlight then
                drawings.Highlight.Enabled = false
            end
        end
    end
end)

localPlayer.CharacterAdded:Connect(function(c)
    task.wait(1)
    if trailConfig.enabled then applyTrail(c) end
    if selfMaterialMode ~= "None" and materialMap[selfMaterialMode] then
        applyMaterial(c, materialMap[selfMaterialMode])
    end
    if selfHighlightEnabled then applySelfHighlight(c) end
end)

RunService.RenderStepped:Connect(function()
    if not spinbotConfig.enabled then return end
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    spinbotConfig.angle = (spinbotConfig.angle + spinbotConfig.speed) % 360
    local yaw = math.rad(spinbotConfig.angle)
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
    if spinbotConfig.lookUp then
        local neck = char:FindFirstChild("Neck", true)
        if neck and neck:IsA("Motor6D") then
            neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-85), math.rad(spinbotConfig.angle), 0)
        end
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            local rj = char:FindFirstChild("RightGrip", true)
            if rj and rj:IsA("Motor6D") then
                rj.C1 = CFrame.Angles(math.rad(90), 0, 0)
            end
        end
    end
end)

local function setupAntiStomp(char)
    local be = char:WaitForChild("BodyEffects")
    local ko = be:WaitForChild("K.O")
    ko:GetPropertyChangedSignal("Value"):Connect(function()
        if ko.Value then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p:Destroy() end) end
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
}):OnChanged(function(v) strafeSettings.enabled = v end)
Options.StrafeEnabled:SetValue(false)

Tabs.Rage:AddButton({
    Title = "Toggle Strafe (keybind: B)",
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

Tabs.Rage:AddSection("Targeting")

local targetDropdown = Tabs.Rage:AddDropdown("RageTargetSelect", {
    Title = "Select Target Player",
    Description = "Select a player from the server to target.",
    Values = playerList,
    Default = playerList[1] or ""
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

task.spawn(function()
    while not targetDropdown.Frame or not targetDropdown.Frame.Parent do
        task.wait()
    end
    targetAvatarFrame.Parent = targetDropdown.Frame.Parent
    targetAvatarFrame.LayoutOrder = targetDropdown.Frame.LayoutOrder + 1
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

Tabs.Rage:AddButton({
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

Tabs.Rage:AddToggle("KillTargetToggle", {
    Title = "Kill Target",
    Description = "Teleport above target and shoot until they are knocked.",
    Default = false
}):OnChanged(function(v)
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
    Title = "Toggle Lock (set bind in Settings tab)",
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
end)
Options.HitboxMaster:SetValue(false)

Tabs.Legit:AddToggle("HitboxExpander", {
    Title = "Activate Expander (H)",
    Default = false
}):OnChanged(function(v)
    if hitboxSettings.scriptEnabled then hitboxSettings.expanderActive = v end
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
}):OnChanged(function(v) cframeSpeedSettings.isFunctionalityEnabled = v end)
Options.SpeedEnabled:SetValue(false)

Tabs.Game:AddToggle("SpeedActive", {
    Title = "Activate Speed (C)",
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
    if v and localPlayer.Character then flyPivot = localPlayer.Character:GetPivot() end
end)
Options.FlyEnabled:SetValue(false)

Tabs.Game:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 30, Min = 30, Max = 500, Rounding = 0
}):OnChanged(function(v) cframeFlySpeed = v / 10 end)

Tabs.Game:AddSection("Shop")

local searchDebounce = nil
Tabs.Game:AddInput("ShopSearch", {
    Title = "Search Shop Item",
    Default = "",
    Placeholder = "Search item name..."
}):OnChanged(function(searchText)
    if searchDebounce then task.cancel(searchDebounce) end
    searchDebounce = task.delay(0.25, function()
        local allItems = getShopItemNames()
        local filtered = {}
        local lowerSearch = searchText:lower()
        for _, name in ipairs(allItems) do
            if name:lower():find(lowerSearch, 1, true) then
                table.insert(filtered, name)
            end
        end
        if Options.ShopItem then
            Options.ShopItem:SetValues(filtered)
            if #filtered > 0 then
                if Options.ShopItem.Value ~= filtered[1] then
                    Options.ShopItem:SetValue(filtered[1])
                end
            else
                Options.ShopItem:SetValue("")
            end
        end
    end)
end)

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
    Title = "Magic Bullet",
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
    Title = "Anti Stomp",
    Default = false
}):OnChanged(function(v)
    if v then
        local char = localPlayer.Character
        if char then pcall(function() setupAntiStomp(char) end) end
        localPlayer.CharacterAdded:Connect(function(c) pcall(function() setupAntiStomp(c) end) end)
    end
end)
Options.AntiStomp:SetValue(false)

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
    if not v then
        for _, drawings in pairs(espPlayers) do
            pcall(function() drawings.Box.Visible = false end)
            pcall(function() drawings.BoxOutline.Visible = false end)
            pcall(function() drawings.Name.Visible = false end)
            pcall(function() drawings.Tracer.Visible = false end)
            pcall(function() drawings.HealthBarBg.Visible = false end)
            pcall(function() drawings.HealthBar.Visible = false end)
            if drawings.Highlight then
                pcall(function() drawings.Highlight.Enabled = false end)
            end
        end
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
end)
Options.Trail:SetValue(false)

Tabs.Visuals:AddDropdown("TrailColorMode", {
    Title = "Color Mode",
    Values = {"Solid", "Gradient", "Rainbow"},
    Default = "Solid"
}):OnChanged(function(v)
    trailConfig.colorMode = v
    if trailConfig.enabled then updateTrailProps() end
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
}):OnChanged(function(v) spinbotConfig.enabled = v end)
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

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local kc = input.KeyCode
    if kc == camlockBind then
        toggleCamlock()
    elseif kc == Enum.KeyCode.V and desyncConfig.toggleEnabled then
        toggleDesync(not desyncConfig.enabled)
    elseif kc == Enum.KeyCode.B and strafeSettings.enabled then
        toggleStrafe()
    elseif kc == Enum.KeyCode.C then
        cframeSpeedSettings.isSpeedActive = not cframeSpeedSettings.isSpeedActive
    elseif kc == Enum.KeyCode.H and hitboxSettings.scriptEnabled then
        hitboxSettings.expanderActive = not hitboxSettings.expanderActive
        Options.HitboxExpander:SetValue(hitboxSettings.expanderActive)
    elseif kc == Enum.KeyCode.X and flyConfig.enabled then
        flyActive = not flyActive
        if flyActive and localPlayer.Character then flyPivot = localPlayer.Character:GetPivot() end
    end
end)

--------------------------------------------------
-- SETTINGS TAB
--------------------------------------------------

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
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

Tabs.Settings:AddSection("Script")

Tabs.Settings:AddButton({
    Title = "Unload Script",
    Description = "Cleans up all hooks and destroys the UI",
    Callback = function()
        -- disable all active systems
        targetKillActive = false
        camlockSettings.enabled = false
        desyncConfig.enabled = false
        strafeSettings.enabled = false
        spinbotConfig.enabled = false
        -- silent aim settings disable removed
        hitboxSettings.expanderActive = false
        flyActive = false
        flyConfig.enabled = false
        espConfig.enabled = false
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
