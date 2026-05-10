local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local combatRemote = RS:WaitForChild("Net"):WaitForChild("Events"):WaitForChild("Combat")

local SIDES = {"Front", "Behind", "Above", "Below"}

local state = {
    enabled = false,
    speed = 8,
    counter = 500,
    distance = 14,
    sideIndex = 4,
    currentTarget = nil,
    kills = 0,
    returnToStart = true,
    startPos = nil,
    noclip = false,
    autoLoot = false,
    nextLootId = 0,
    lootSynced = false,
    filterEnabled = false,
    targetList = {},
    lastCleanup = tick(),
    isCleaning = false,
}

local lootRemote = RS:WaitForChild("Net"):WaitForChild("Events"):WaitForChild("LootDrop")
local originalCollisions = {}
local collectedLoot = {}
local dropToIdMap = {}
local noclipConn = nil
local deathConns = {}
local isLootUpFiring = false
local uiElements = {}
local mainConn = nil

local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getEnemies()
    local list = {}
    local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("NPCs")}
    for _, folder in pairs(folders) do
        for _, mob in pairs(folder:GetChildren()) do
            local hum = mob:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 then
                if state.filterEnabled then
                    if state.targetList[mob.Name] then table.insert(list, mob) end
                else
                    table.insert(list, mob)
                end
            end
        end
    end
    if #list == 0 and state.filterEnabled then
        for _, mob in pairs(workspace:GetChildren()) do
            if state.targetList[mob.Name] then
                local hum = mob:FindFirstChildWhichIsA("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(list, mob)
                end
            end
        end
    end
    return list
end

local function getMobRoot(mob)
    return mob:FindFirstChild("HumanoidRootPart")
        or mob:FindFirstChild("Head")
        or mob:FindFirstChildWhichIsA("BasePart")
end

local function getNearestEnemy()
    local root = getRoot()
    if not root then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for _, mob in pairs(getEnemies()) do
        local er = getMobRoot(mob)
        if er then
            local d = (er.Position - root.Position).Magnitude
            if d < bestDist then
                best, bestDist = mob, d
            end
        end
    end
    return best, bestDist
end

local function teleportToMob(mob)
    local root = getRoot()
    local er = getMobRoot(mob)
    if not root or not er then return end
    local side = SIDES[state.sideIndex] or "Front"
    local dist = state.distance
    local enemyPos = er.Position
    local offset
    if side == "Front" then
        offset = er.CFrame.LookVector * dist
    elseif side == "Behind" then
        offset = -er.CFrame.LookVector * dist
    elseif side == "Above" then
        offset = Vector3.new(0, dist, 0)
    elseif side == "Below" then
        offset = Vector3.new(0, -dist, 0)
    end
    local targetPos = enemyPos + offset
    root.CFrame = CFrame.lookAt(targetPos, enemyPos)
    root.Velocity = Vector3.new(0, 0, 0)
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

local function returnToStart()
    if state.startPos then
        local root = getRoot()
        if root then
            root.CFrame = state.startPos
        end
        state.startPos = nil
    end
end

local function fireAttack(mob)
    state.counter = state.counter + 1
    local c = state.counter
    combatRemote:FireServer("s", "Attack", c)
    combatRemote:FireServer("h", c, {mob})
end

local function setupNetworkHook()
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if not isLootUpFiring and method == "FireServer" and (self == lootRemote or self.Name == "LootDrop") then
                local args = {...}
                local id = args[1]
                if typeof(id) == "number" and id > 0 then
                    state.nextLootId = id + 1
                    state.lootSynced = true
                    if uiElements.idLabel then
                        uiElements.idLabel.Text = "Sync: " .. state.nextLootId
                        uiElements.idLabel.TextColor3 = Color3.fromRGB(255, 160, 20)
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
    lootRemote.OnClientEvent:Connect(function(...)
        for _, arg in pairs({...}) do
            if typeof(arg) == "number" and not state.lootSynced then
                state.nextLootId = arg
                if uiElements.idLabel then
                    uiElements.idLabel.Text = "Sync: " .. state.nextLootId
                    uiElements.idLabel.TextColor3 = Color3.fromRGB(255, 160, 20)
                end
            end
        end
    end)
end

local handledModels = setmetatable({}, {__mode = "k"})
local function processLoot()
    if not state.autoLoot or state.nextLootId == 0 then return end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "LootDrop" and not handledModels[obj] then
            local id = state.nextLootId
            handledModels[obj] = true
            isLootUpFiring = true
            pcall(function() lootRemote:FireServer(id) end)
            isLootUpFiring = false
            state.nextLootId = id + 1
            if uiElements.idLabel then
                uiElements.idLabel.Text = "Next: " .. state.nextLootId
            end
        end
    end
end

local function clearTarget()
    state.currentTarget = nil
    for _, conn in pairs(deathConns) do
        pcall(function() conn:Disconnect() end)
    end
    deathConns = {}
end

local function acquireTarget()
    if state.currentTarget then
        local hum = state.currentTarget:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Health > 0 and state.currentTarget.Parent then
            return state.currentTarget
        end
        state.kills = state.kills + 1
        clearTarget()
    end
    local mob = getNearestEnemy()
    if not mob then return nil end
    state.currentTarget = mob
    local hum = mob:FindFirstChildWhichIsA("Humanoid")
    if hum then
        table.insert(deathConns, hum.Died:Connect(function()
            state.kills = state.kills + 1
            clearTarget()
        end))
    end
    table.insert(deathConns, mob.AncestryChanged:Connect(function(_, newParent)
        if not newParent then
            clearTarget()
        end
    end))
    return mob
end

local function startLoop()
    if mainConn then return end
    mainConn = RunService.Heartbeat:Connect(function()
        if not state.enabled then return end
        if tick() - state.lastCleanup > 70 then
            state.isCleaning = true
            if uiElements.statusLabel then
                uiElements.statusLabel.Text = "Status: CLEANING"
                uiElements.statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "LootDrop" then
                        obj:Destroy()
                    end
                end
            end)
            task.delay(1.5, function()
                state.isCleaning = false
                state.lastCleanup = tick()
                if state.enabled and uiElements.statusLabel then
                    uiElements.statusLabel.Text = "Status: KILLING"
                    uiElements.statusLabel.TextColor3 = Color3.fromRGB(255, 160, 20)
                end
            end)
        end
        local mob = acquireTarget()
        if mob then
            teleportToMob(mob)
            if not state.isCleaning then
                fireAttack(mob)
            end
        end
        processLoot()
    end)
end

local function stopLoop()
    if mainConn then
        mainConn:Disconnect()
        mainConn = nil
    end
    clearTarget()
end

local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not state.noclip then return end
        local char = player.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                originalCollisions[part] = true
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    for part, _ in pairs(originalCollisions) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    originalCollisions = {}
end

local gui = Instance.new("ScreenGui")
gui.Name = "LootUpGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if gethui then
    gui.Parent = gethui()
else
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = player.PlayerGui end
end

local C = {
    bg        = Color3.fromRGB(14, 10, 8),
    surface   = Color3.fromRGB(22, 16, 12),
    accent    = Color3.fromRGB(255, 100, 0),
    accentOn  = Color3.fromRGB(255, 160, 20),
    text      = Color3.fromRGB(235, 230, 225),
    dim       = Color3.fromRGB(150, 130, 120),
    border    = Color3.fromRGB(50, 35, 25),
    slider    = Color3.fromRGB(35, 25, 20),
}

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 240, 0, 640)
frame.Position = UDim2.new(0, 20, 0.5, -320)
frame.BackgroundColor3 = C.bg
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = C.border
stroke.Thickness = 1
stroke.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = C.surface
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = C.surface
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 36, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MD | Loot Up!"
titleLabel.TextColor3 = C.text
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local titleIcon = Instance.new("ImageLabel")
titleIcon.Size = UDim2.new(0, 24, 0, 24)
titleIcon.Position = UDim2.new(0, 6, 0.5, -12)
titleIcon.BackgroundTransparency = 1
titleIcon.Image = "rbxthumb://type=Asset&id=140295322336049&w=150&h=150"
titleIcon.Parent = titleBar

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 6)
iconCorner.Parent = titleIcon

local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -46)
content.Position = UDim2.new(0, 10, 0, 40)
content.BackgroundTransparency = 1
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = content

local function makeToggle(parent, label, default, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -42, 0.5, -11)
    btn.BackgroundColor3 = default and C.accentOn or C.slider
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = C.text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = row
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn
    local isOn = default
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        btn.Text = isOn and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and C.accentOn or C.slider
        }):Play()
        callback(isOn)
    end)
    return btn
end

local function makeSlider(parent, label, min, max, default, order, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(default)
    lbl.TextColor3 = C.dim
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 10)
    track.Position = UDim2.new(0, 0, 0, 24)
    track.BackgroundColor3 = C.slider
    track.BorderSizePixel = 0
    track.Parent = row
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 5)
    tc.Parent = track
    local fill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 5)
    fc.Parent = fill
    local sliding = false
    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = label .. ": " .. tostring(val)
        callback(val)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = C.accent
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 0
statusLabel.Parent = content
uiElements.statusLabel = statusLabel

local idLabel = Instance.new("TextLabel")
idLabel.Size = UDim2.new(1, 0, 0, 20)
idLabel.BackgroundTransparency = 1
idLabel.Text = "Sync: NOT SYNCED"
idLabel.TextColor3 = C.dim
idLabel.TextSize = 10
idLabel.Font = Enum.Font.GothamMedium
idLabel.TextXAlignment = Enum.TextXAlignment.Right
idLabel.Position = UDim2.new(0, 0, 0, 0)
idLabel.Parent = statusLabel
uiElements.idLabel = idLabel

makeToggle(content, "Auto Kill", false, 1, function(on)
    state.enabled = on
    if on then
        local root = getRoot()
        if root and not state.startPos then
            state.startPos = root.CFrame
        end
        startLoop()
        statusLabel.Text = "Status: KILLING"
        statusLabel.TextColor3 = C.accentOn
    else
        stopLoop()
        if state.returnToStart then
            returnToStart()
        end
        statusLabel.Text = "Status: OFF"
        statusLabel.TextColor3 = C.accent
    end
end)

makeToggle(content, "Return on stop", true, 2, function(on)
    state.returnToStart = on
end)

makeToggle(content, "Noclip", false, 3, function(on)
    state.noclip = on
    if on then
        startNoclip()
    else
        stopNoclip()
    end
end)

makeSlider(content, "Distance (studs)", 3, 30, state.distance, 5, function(v)
    state.distance = v
end)

makeToggle(content, "Auto Loot", false, 6, function(on)
    state.autoLoot = on
    if not on then 
        collectedLoot = {} 
        dropToIdMap = {}
    end
end)

makeToggle(content, "Filter Mobs", false, 8, function(on)
    state.filterEnabled = on
end)

do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 140)
    row.BackgroundTransparency = 1
    row.LayoutOrder = 9
    row.Parent = content
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Select Enemies to Farm:"
    lbl.TextColor3 = C.dim
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -18)
    scroll.Position = UDim2.new(0, 0, 0, 18)
    scroll.BackgroundColor3 = C.slider
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 2
    scroll.Parent = row
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = scroll
    local slist = Instance.new("UIListLayout")
    slist.Padding = UDim.new(0, 2)
    slist.Parent = scroll
    local lastNames = ""
    local function updateList()
        local folder = workspace:FindFirstChild("Enemies")
        if not folder then return end
        local currentNames = ""
        local found = {}
        for _, m in pairs(folder:GetChildren()) do
            if not found[m.Name] then
                found[m.Name] = true
                currentNames = currentNames .. m.Name .. ","
            end
        end
        if currentNames == lastNames then return end
        lastNames = currentNames
        for _, c in pairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local names = {}
        for _, mob in pairs(folder:GetChildren()) do
            if not names[mob.Name] then
                names[mob.Name] = true
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 22)
                btn.BackgroundColor3 = state.targetList[mob.Name] and C.accentOn or Color3.fromRGB(40, 30, 25)
                btn.Text = " " .. mob.Name
                btn.TextColor3 = C.text
                btn.TextSize = 11
                btn.Font = Enum.Font.Gotham
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.BorderSizePixel = 0
                btn.Parent = scroll
                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 4)
                bc.Parent = btn
                btn.MouseButton1Click:Connect(function()
                    state.targetList[mob.Name] = not state.targetList[mob.Name]
                    btn.BackgroundColor3 = state.targetList[mob.Name] and C.accentOn or Color3.fromRGB(45, 45, 60)
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, slist.AbsoluteContentSize.Y)
    end
    task.spawn(function()
        while gui.Parent do
            pcall(updateList)
            task.wait(2)
        end
    end)
end

do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder = 9
    row.Parent = content
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Side"
    lbl.TextColor3 = C.text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0, 22)
    btn.Position = UDim2.new(0.55, 0, 0.5, -11)
    btn.BackgroundColor3 = C.slider
    btn.Text = SIDES[state.sideIndex]
    btn.TextColor3 = C.text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = row
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn
    btn.MouseButton1Click:Connect(function()
        state.sideIndex = (state.sideIndex % #SIDES) + 1
        btn.Text = SIDES[state.sideIndex]
    end)
end

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 32)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Enemies: 0 | Kills: 0"
statsLabel.TextColor3 = C.dim
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.LayoutOrder = 10
statsLabel.Parent = content

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, 0, 0, 16)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target: none"
targetLabel.TextColor3 = C.dim
targetLabel.TextSize = 11
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.LayoutOrder = 11
targetLabel.Parent = content

task.spawn(function()
    while gui.Parent do
        local count = #getEnemies()
        statsLabel.Text = "Enemies: " .. count .. " | Kills: " .. state.kills
        if state.currentTarget and state.currentTarget.Parent then
            targetLabel.Text = "Target: " .. state.currentTarget.Name
        else
            targetLabel.Text = "Target: none"
        end
        task.wait(0.25)
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        state.enabled = not state.enabled
        if state.enabled then
            startLoop()
            statusLabel.Text = "Status: KILLING"
            statusLabel.TextColor3 = C.accentOn
        else
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = C.accent
        end
    end
end)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, 0, 0, 26)
unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 25, 25)
unloadBtn.Text = "Unload"
unloadBtn.TextColor3 = C.accent
unloadBtn.TextSize = 12
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.BorderSizePixel = 0
unloadBtn.LayoutOrder = 13
unloadBtn.Parent = content
local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 6)
uc.Parent = unloadBtn
unloadBtn.MouseButton1Click:Connect(function()
    state.enabled = false
    state.noclip = false
    stopLoop()
    stopNoclip()
    gui:Destroy()
end)

setupNetworkHook()
startLoop()
