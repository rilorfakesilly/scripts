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
    Settings = Window:AddTab({ Title = "Settings",Icon = "settings" })
}

local Options = Fluent.Options

--------------------------------------------------
-- SHARED STATE
--------------------------------------------------

local silentAimSettings = {
    Enabled       = false,
    HitPart       = "Head",
    KOCheck       = false,
    HitChance     = 100,
    LockOnEnabled = false,
    LockedTarget  = nil,
    Prediction    = 0,
}

local streamableSettings = {
    Enabled       = false,
    HitPart       = "Head",
    KOCheck       = false,
    HitChance     = 100,
    LockOnEnabled = false,
    LockedTarget  = nil,
    ShowTracer    = false,
    Prediction    = 0,
    FOV = {
        Enabled      = false,
        Radius       = 100,
        Thickness    = 2,
        Transparency = 1,
    },
}

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
    mode          = "Void",
    toggleEnabled = false,
    oldPosition   = nil,
    teleportPos   = Vector3.new(0,0,0),
}

local espConfig = {
    showBox       = false,
    showChams     = false,
    showHealthBar = false,
    showName      = false,
    showDistance  = false,
    showTracers   = false,
    tracerPosition= "Mouse",
    tracerThickness = 1,
    defaultColor  = Color3.fromRGB(255,0,0),
    teamColor     = true,
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

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

local function getPredictedPos(part, predFactor)
    if predFactor <= 0 then return part.Position end
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    return part.Position + vel * predFactor
end

local function isValidTarget(player, koCheck)
    if player == localPlayer or not player.Character then return false end
    local hum = player.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if koCheck then
        local be = player.Character:FindFirstChild("BodyEffects")
        local ko = be and be:FindFirstChild("K.O")
        if ko and ko.Value then return false end
    end
    return true
end

local function getSilentTarget()
    local shortest = math.huge
    local mouseLoc = UserInputService:GetMouseLocation()
    local result = nil
    for _, p in pairs(Players:GetPlayers()) do
        if isValidTarget(p, silentAimSettings.KOCheck) then
            local part = p.Character:FindFirstChild(silentAimSettings.HitPart)
            if part then
                local pos = getPredictedPos(part, silentAimSettings.Prediction)
                local sp, onScreen = currentCamera:WorldToViewportPoint(pos)
                if onScreen then
                    local dist = (mouseLoc - Vector2.new(sp.X, sp.Y)).Magnitude
                    if dist < shortest then shortest = dist; result = part end
                end
            end
        end
    end
    return result
end

local function getStreamableTarget()
    local shortest = math.huge
    local mouseLoc = UserInputService:GetMouseLocation()
    local result = nil
    for _, p in pairs(Players:GetPlayers()) do
        if isValidTarget(p, streamableSettings.KOCheck) then
            local part = p.Character:FindFirstChild(streamableSettings.HitPart)
            if part then
                local pos = getPredictedPos(part, streamableSettings.Prediction)
                local sp, onScreen = currentCamera:WorldToViewportPoint(pos)
                if onScreen then
                    local dist = (mouseLoc - Vector2.new(sp.X, sp.Y)).Magnitude
                    if dist < shortest and dist <= streamableSettings.FOV.Radius then
                        shortest = dist; result = part
                    end
                end
            end
        end
    end
    return result
end

function mt.__index(self, key)
    if not checkcaller() and self == playerMouse and (key == "Hit" or key == "Target") then
        local target, pred = nil, 0
        if silentAimSettings.Enabled then
            pred = silentAimSettings.Prediction
            target = (silentAimSettings.LockOnEnabled and silentAimSettings.LockedTarget) or getSilentTarget()
        elseif streamableSettings.Enabled then
            pred = streamableSettings.Prediction
            target = (streamableSettings.LockOnEnabled and streamableSettings.LockedTarget) or getStreamableTarget()
        end
        if target then
            local aimPos = getPredictedPos(target, pred)
            local chance = silentAimSettings.Enabled and silentAimSettings.HitChance or streamableSettings.HitChance
            if math.random(1, 100) <= chance then
                return key == "Hit" and CFrame.new(aimPos) or target
            end
            local spread = 3
            local ox = (math.random() + math.random() - 1) * spread
            local oy = (math.random() + math.random() - 1) * spread
            local oz = (math.random() + math.random() - 1) * spread
            return key == "Hit" and CFrame.new(aimPos + Vector3.new(ox, oy, oz)) or target
        end
    end
    return oldIndex(self, key)
end

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
        if mode == "Void" then
            desyncConfig.teleportPos = Vector3.new(root.Position.X + math.random(-444444,444444), root.Position.Y + math.random(-444444,444444), root.Position.Z + math.random(-44444,44444))
        elseif mode == "Void Spam" then
            desyncConfig.teleportPos = math.random(1,2) == 1 and desyncConfig.oldPosition.Position or Vector3.new(math.random(10000,50000), math.random(10000,50000), math.random(10000,50000))
        elseif mode == "Underground" then
            desyncConfig.teleportPos = root.Position - Vector3.new(0,12,0)
        elseif mode == "Destroy Cheaters" then
            desyncConfig.teleportPos = Vector3.new(1.122334455667789e19, 1, 1)
        end
        root.CFrame = CFrame.new(desyncConfig.teleportPos)
        currentCamera.CameraSubject = desyncPart
        RunService.RenderStepped:Wait()
        desyncPart.CFrame = desyncConfig.oldPosition * CFrame.new(0, root.Size.Y/2 + 0.5, 0)
        root.CFrame = desyncConfig.oldPosition
    end
end)



-- FOV Circle & tracer for streamable
local fovCircle = Drawing.new("Circle")
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Radius = 100
fovCircle.Thickness = 2
fovCircle.Transparency = 1

local fovTracer = Drawing.new("Line")
fovTracer.Visible = false
fovTracer.Thickness = 2
fovTracer.Transparency = 1

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = streamableSettings.FOV.Enabled and streamableSettings.Enabled
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Radius = streamableSettings.FOV.Radius
    if streamableSettings.ShowTracer and streamableSettings.Enabled then
        local t = streamableSettings.LockedTarget or getStreamableTarget()
        if t then
            local sp = currentCamera:WorldToViewportPoint(t.Position)
            fovTracer.From = Vector2.new(fovCircle.Position.X, fovCircle.Position.Y + fovCircle.Radius)
            fovTracer.To = Vector2.new(sp.X, sp.Y)
            fovTracer.Visible = true
        else
            fovTracer.Visible = false
        end
    else
        fovTracer.Visible = false
    end
end)

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

local function executeBuyItem(itemName)
    if not itemName or isBuyingItem then return end
    isBuyingItem = true
    local desyncWas = desyncConfig.enabled
    if desyncWas then toggleDesync(false) task.wait(0.1) end
    local root = getLocalRoot()
    if root then
        local item = shopFolder:FindFirstChild(itemName)
        if item then
            local cd = item:FindFirstChildOfClass("ClickDetector")
            if cd then
                local saved = root.CFrame
                root.CFrame = CFrame.new(item.Head.Position + Vector3.new(0,3,0))
                task.wait(0.2)
                fireclickdetector(cd)
                notify("Shop", "Purchased: " .. itemName)
                root.CFrame = saved
            else notify("Shop Error", "ClickDetector not found in " .. itemName) end
        else notify("Shop Error", "Item not found: " .. itemName) end
        if desyncWas then task.wait(0.2) toggleDesync(true) end
    end
    isBuyingItem = false
end

local ammoMap = {
    ["[Revolver] - $1421"] = "12 [Revolver Ammo] - $55",
    ["[AUG] - $2131"]      = "90 [AUG Ammo] - $87",
    ["[LMG] - $4098"]      = "200 [LMG Ammo] - $328",
    ["[Rifle] - $1694"]    = "5 [Rifle Ammo] - $273",
}

local function executeBuyAmmo()
    if not selectedShopItem then return end
    local ammoItem = ammoMap[selectedShopItem]
    if ammoItem then executeBuyItem(ammoItem)
    else notify("Shop Error", "No ammo for this item.") end
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    shopFolder = Workspace:WaitForChild("Ignored"):WaitForChild("Shop")
    if autoBuyOnRespawn and selectedShopItem then
        executeBuyItem(selectedShopItem)
        for _ = 1,3 do executeBuyAmmo() task.wait(0.5) end
    end
end)

-- Player actions
local isActionRunning = false
local actionOldPos = nil
local selectedTarget = nil
local selectedAction = "Knock"

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

local function executeKnock(target)
    local tc = target.Character
    local be = tc and tc:FindFirstChild("BodyEffects")
    local ko = be and be:WaitForChild("K.O", 5)
    if not ko then return end
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local savedPos = root and root.Position
    isActionRunning = true
    task.spawn(function()
        while not ko.Value and isActionRunning do
            if tc:FindFirstChild("HumanoidRootPart") then
                root.CFrame = CFrame.new(tc.HumanoidRootPart.Position + Vector3.new(0,-20,0))
            end
            shootAtHead(localPlayer.Character:FindFirstChildWhichIsA("Tool"), tc)
            task.wait()
        end
        if savedPos then root.CFrame = CFrame.new(savedPos) end
        isActionRunning = false
    end)
end

local function executeStomp(target)
    local tc = target.Character
    local be = tc and tc:FindFirstChild("BodyEffects")
    local ko = be and be:WaitForChild("K.O", 5)
    local sd = be and be:WaitForChild("SDeath", 5)
    if not ko or not sd then return end
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    actionOldPos = root and root.Position
    isActionRunning = true
    task.spawn(function()
        while not ko.Value and isActionRunning do
            if tc:FindFirstChild("HumanoidRootPart") then
                root.CFrame = CFrame.new(tc.HumanoidRootPart.Position + Vector3.new(0,-20,0))
            end
            shootAtHead(localPlayer.Character:FindFirstChildWhichIsA("Tool"), tc)
            task.wait()
        end
        while not sd.Value and isActionRunning do
            local torso = tc:FindFirstChild("UpperTorso")
            if torso then root.CFrame = CFrame.new(torso.Position + Vector3.new(0,3,0)) RunService.RenderStepped:Wait() end
            pcall(function() ReplicatedStorage.MainEvent:FireServer("Stomp") end)
            task.wait()
        end
        if actionOldPos then root.CFrame = CFrame.new(actionOldPos) end
        isActionRunning = false
    end)
end

local function executeBring(target)
    local tc = target.Character
    local be = tc and tc:FindFirstChild("BodyEffects")
    local ko = be and be:FindFirstChild("K.O")
    if not ko then return end
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    actionOldPos = root and root.Position
    isActionRunning = true
    task.spawn(function()
        while not ko.Value and isActionRunning do
            local tRoot = tc:FindFirstChild("HumanoidRootPart")
            if tRoot then root.CFrame = CFrame.new(tRoot.Position + Vector3.new(0,-20,0)) end
            shootAtHead(localPlayer.Character:FindFirstChildWhichIsA("Tool"), tc)
            task.wait()
        end
        while ko.Value and not tc:FindFirstChild("GRABBING_CONSTRAINT") and isActionRunning do
            local torso = tc:FindFirstChild("UpperTorso")
            if torso then root.CFrame = CFrame.new(torso.Position + Vector3.new(0,3,0)) RunService.RenderStepped:Wait() end
            pcall(function() ReplicatedStorage.MainEvent:FireServer("Grabbing", false) end)
            task.wait(0.1)
        end
        if actionOldPos then root.CFrame = CFrame.new(actionOldPos) end
        isActionRunning = false
    end)
end

local function stopAllActions()
    isActionRunning = false
    if actionOldPos and localPlayer.Character then
        local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(actionOldPos) end
    end
    notify("Actions", "All actions stopped.")
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
local selfHighlightColor = Color3.fromRGB(0, 200, 255)
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
    selfHighlight.FillColor = selfHighlightColor
    selfHighlight.OutlineColor = Color3.new(1, 1, 1)
    selfHighlight.FillTransparency = 0.5
    selfHighlight.OutlineTransparency = 0
    selfHighlight.Parent = char
end

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

local killAllActive = false
local stompAllActive = false

local function isKO(player)
    local be = player.Character and player.Character:FindFirstChild("BodyEffects")
    local ko = be and be:FindFirstChild("K.O")
    return ko and ko.Value or false
end

local function performStompAll()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local be = p.Character:FindFirstChild("BodyEffects")
            local ko = be and be:FindFirstChild("K.O")
            local sd = be and be:FindFirstChild("SDeath")
            if ko and sd and ko.Value and not sd.Value then
                while not sd.Value and stompAllActive do
                    if not ko.Value then break end
                    local torso = p.Character:FindFirstChild("UpperTorso")
                    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if torso and root then
                        root.CFrame = CFrame.new(torso.Position + Vector3.new(0,3,0))
                        RunService.RenderStepped:Wait()
                    end
                    pcall(function() ReplicatedStorage.MainEvent:FireServer("Stomp") end)
                    task.wait()
                end
            end
        end
    end
end

local function buyItemMass(itemName)
    for _, c in pairs(localPlayer.Character:GetChildren()) do if c:IsA("Tool") then c.Parent = localPlayer.Backpack end end
    for _, item in pairs(shopFolder:GetChildren()) do
        if item.Name == itemName then
            local head = item:FindFirstChild("Head")
            if head then
                localPlayer.Character.HumanoidRootPart.CFrame = head.CFrame + Vector3.new(0,3.2,0)
                task.wait(0.1)
                local cd = item:FindFirstChild("ClickDetector")
                if cd then fireclickdetector(cd) end
            end
            break
        end
    end
end

local function performKillAll()
    local savedPos = localPlayer.Character.HumanoidRootPart.CFrame
    for _, c in pairs(localPlayer.Character:GetChildren()) do if c:IsA("Tool") then c.Parent = localPlayer.Backpack end end
    while not (localPlayer.Backpack:FindFirstChild("[LMG]") or localPlayer.Character:FindFirstChild("[LMG]")) do
        buyItemMass("[LMG] - $4098") task.wait(0.2)
    end
    for _ = 1,5 do buyItemMass("200 [LMG Ammo] - $328") task.wait(0) end
    local lmg = localPlayer.Backpack:FindFirstChild("[LMG]") or localPlayer.Character:FindFirstChild("[LMG]")
    if lmg then lmg.Parent = localPlayer.Character end
    local tool = localPlayer.Character:FindFirstChild("[LMG]")
    if not tool then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            currentCamera.CameraSubject = p.Character.Humanoid
            while not isKO(p) and killAllActive do
                localPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame - Vector3.new(0,20,0)
                shootAtHead(tool, p.Character, 5)
                task.wait()
            end
            if not killAllActive then break end
        end
    end
    localPlayer.Character.HumanoidRootPart.CFrame = savedPos
    currentCamera.CameraSubject = localPlayer.Character.Humanoid
    if stompAllActive then task.spawn(performStompAll) end
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

Tabs.Rage:AddSection("Silent Aim")

Tabs.Rage:AddToggle("SilentAim", {
    Title = "Silent Aim",
    Description = "Silently redirect shots to target.",
    Default = false
}):OnChanged(function(v) silentAimSettings.Enabled = v end)
Options.SilentAim:SetValue(false)

Tabs.Rage:AddToggle("KOCheck", {
    Title = "K.O Check",
    Description = "Skip knocked players.",
    Default = false
}):OnChanged(function(v) silentAimSettings.KOCheck = v end)
Options.KOCheck:SetValue(false)

Tabs.Rage:AddSlider("HitChance", {
    Title = "Hit Chance",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v) silentAimSettings.HitChance = v end)

Tabs.Rage:AddDropdown("HitPart", {
    Title = "Hit Part",
    Values = {"Head","UpperTorso","HumanoidRootPart","LowerTorso","LeftHand","RightHand","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"},
    Default = "Head"
}):OnChanged(function(v) silentAimSettings.HitPart = v end)

Tabs.Rage:AddSlider("SilentPrediction", {
    Title = "Prediction (ms)",
    Default = 0, Min = 0, Max = 200, Rounding = 0
}):OnChanged(function(v) silentAimSettings.Prediction = v / 1000 end)

Tabs.Rage:AddSection("Targeting")

Tabs.Rage:AddToggle("ShowSilentTracer", {
    Title = "Show Tracer (Silent Aim Target)",
    Default = false
})

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
    Values = {"Void","Void Spam","Underground","Destroy Cheaters"},
    Default = "Void"
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

Tabs.Rage:AddSection("Player Actions")

local playerList = {}
for _, p in pairs(Players:GetPlayers()) do if p ~= localPlayer then table.insert(playerList, p.Name) end end
Players.PlayerAdded:Connect(function(p) table.insert(playerList, p.Name) end)
Players.PlayerRemoving:Connect(function(p)
    for i, n in pairs(playerList) do if n == p.Name then table.remove(playerList, i) break end end
end)

Tabs.Rage:AddDropdown("TargetPlayer", {
    Title = "Select Target",
    Values = playerList,
    Default = playerList[1] or ""
}):OnChanged(function(v) selectedTarget = v end)

Tabs.Rage:AddDropdown("ActionType", {
    Title = "Action",
    Values = {"Knock","Bring","Stomp"},
    Default = "Knock"
}):OnChanged(function(v) selectedAction = v end)

Tabs.Rage:AddButton({
    Title = "Execute Action",
    Callback = function()
        if not selectedTarget then notify("Error", "Select a target first!") return end
        local target = Players:FindFirstChild(selectedTarget)
        if not target or not target.Character then notify("Error", "Target not found.") return end
        local tool = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Tool")
        if not tool or not tool:FindFirstChild("Ammo") then notify("Error", "Equip a gun first!") return end
        if selectedAction == "Knock" then executeKnock(target)
        elseif selectedAction == "Bring" then executeBring(target)
        elseif selectedAction == "Stomp" then executeStomp(target) end
    end
})

Tabs.Rage:AddButton({
    Title = "Stop All Actions",
    Callback = function() stopAllActions() end
})

Tabs.Rage:AddSection("Mass Actions")

Tabs.Rage:AddToggle("KillAll", {
    Title = "Kill All",
    Default = false
}):OnChanged(function(v)
    killAllActive = v
    if v then task.spawn(performKillAll)
    else
        local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and actionOldPos then root.CFrame = CFrame.new(actionOldPos) end
        currentCamera.CameraSubject = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
    end
end)
Options.KillAll:SetValue(false)

Tabs.Rage:AddToggle("StompAll", {
    Title = "Stomp All",
    Default = false
}):OnChanged(function(v)
    stompAllActive = v
    if v and not killAllActive then task.spawn(performStompAll) end
end)
Options.StompAll:SetValue(false)

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

Tabs.Legit:AddSection("Streamable Silent Aim")

Tabs.Legit:AddToggle("StreamableEnabled", {
    Title = "Streamable Silent Aim",
    Default = false
}):OnChanged(function(v) streamableSettings.Enabled = v end)
Options.StreamableEnabled:SetValue(false)

Tabs.Legit:AddToggle("StreamableKOCheck", {
    Title = "K.O Check",
    Default = false
}):OnChanged(function(v) streamableSettings.KOCheck = v end)
Options.StreamableKOCheck:SetValue(false)

Tabs.Legit:AddToggle("FOVEnabled", {
    Title = "Show FOV Circle",
    Default = false
}):OnChanged(function(v) streamableSettings.FOV.Enabled = v end)
Options.FOVEnabled:SetValue(false)

Tabs.Legit:AddToggle("StreamableTracer", {
    Title = "Show Tracer",
    Default = false
}):OnChanged(function(v) streamableSettings.ShowTracer = v end)
Options.StreamableTracer:SetValue(false)

Tabs.Legit:AddSlider("FOVRadius", {
    Title = "FOV Radius",
    Default = 100, Min = 0, Max = 500, Rounding = 0
}):OnChanged(function(v) streamableSettings.FOV.Radius = v end)

Tabs.Legit:AddSlider("StreamableHitChance", {
    Title = "Hit Chance",
    Default = 100, Min = 0, Max = 100, Rounding = 0
}):OnChanged(function(v) streamableSettings.HitChance = v end)

Tabs.Legit:AddDropdown("StreamableHitPart", {
    Title = "Hit Part",
    Values = {"Head","UpperTorso","HumanoidRootPart","LowerTorso","LeftHand","RightHand"},
    Default = "Head"
}):OnChanged(function(v) streamableSettings.HitPart = v end)

Tabs.Legit:AddSlider("StreamablePrediction", {
    Title = "Prediction (ms)",
    Default = 0, Min = 0, Max = 200, Rounding = 0
}):OnChanged(function(v) streamableSettings.Prediction = v / 1000 end)

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

Tabs.Game:AddDropdown("ShopItem", {
    Title = "Select Item",
    Values = {
        "[Taco] - $2","[Hamburger] - $5","[Revolver] - $1421",
        "12 [Revolver Ammo] - $55","90 [AUG Ammo] - $87",
        "[AUG] - $2131","[Rifle] - $1694","[LMG] - $4098","200 [LMG Ammo] - $328"
    },
    Default = "[Taco] - $2"
}):OnChanged(function(v) selectedShopItem = v end)

Tabs.Game:AddButton({
    Title = "Buy Item",
    Callback = function() executeBuyItem(selectedShopItem) end
})

Tabs.Game:AddButton({
    Title = "Buy Ammo",
    Callback = function() executeBuyAmmo() end
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
        camlockSettings.enabled = false
        desyncConfig.enabled = false
        strafeSettings.enabled = false
        spinbotConfig.enabled = false
        silentAimSettings.Enabled = false
        hitboxSettings.expanderActive = false
        flyActive = false
        flyConfig.enabled = false
        -- restore metamethod
        pcall(function()
            local mt2 = getrawmetatable(game)
            setreadonly(mt2, false)
            mt2.__index = oldIndex
            setreadonly(mt2, true)
        end)
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
