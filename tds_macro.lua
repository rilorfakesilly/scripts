
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local remoteEvent = RS:WaitForChild("RemoteEvent")
local remoteFunction = RS:WaitForChild("RemoteFunction")

-- ─── State ─────────────────────────────────────────────
local state = {
    recording = false,
    playing = false,
    startTime = 0,
    macroData = {},
    autoReplay = false,
    replayDelay = 10,
    loopActive = false,
    unloaded = false,
}

local captureQueue = {} 
local triggerQueue = {} 
local connections = {}

-- ─── UI ────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "TDS_Macro_v4"
gui.ResetOnSpawn = false
if gethui then gui.Parent = gethui() else gui.Parent = game:GetService("CoreGui") end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 480)
main.Position = UDim2.new(0.8, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local uiStroke = Instance.new("UIStroke", main)
uiStroke.Color = Color3.fromRGB(0, 170, 255)
uiStroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 36)
title.Text = "MD MACRO TDS"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1

-- Console
local console = Instance.new("ScrollingFrame", main)
console.Size = UDim2.new(0.9, 0, 0, 105)
console.Position = UDim2.new(0.05, 0, 0, 36)
console.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
console.BorderSizePixel = 0
console.CanvasSize = UDim2.new(0, 0, 0, 0)
console.ScrollBarThickness = 3
console.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", console).CornerRadius = UDim.new(0, 6)
local cLayout = Instance.new("UIListLayout", console)
cLayout.Padding = UDim.new(0, 1)

local function log(text, color)
    local l = Instance.new("TextLabel", console)
    l.Size = UDim2.new(1, -6, 0, 14)
    l.Text = " " .. text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    l.Font = Enum.Font.Code
    l.TextSize = 10
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    console.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 4)
    console.CanvasPosition = Vector2.new(0, 99999)
end

-- Dragging
do
    local dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragStart = nil end
    end)
end

-- ─── Safe Serialization ──────
local function safeSerialize(val)
    if val == nil then return nil end
    local t = typeof(val)
    if t == "string" or t == "number" or t == "boolean" then
        return val
    elseif t == "Vector3" then
        return {__t = "v3", x = val.X, y = val.Y, z = val.Z}
    elseif t == "CFrame" then
        return {__t = "cf", c = {val:GetComponents()}}
    elseif t == "Instance" then
        -- Check if it looks like a placed tower (Model with PrimaryPart)
        local ok, isPart = pcall(function() return val:IsA("Model") and val.PrimaryPart ~= nil end)
        if ok and isPart then
            local pos = val.PrimaryPart.Position
            return {__t = "tower", px = pos.X, py = pos.Y, pz = pos.Z, name = val.Name}
        end
        return {__t = "inst", name = val.Name}
    elseif t == "table" then
        local out = {}
        for k, v in pairs(val) do
            out[k] = safeSerialize(v)
        end
        return out
    elseif t == "EnumItem" then
        return {__t = "enum", v = tostring(val)}
    else
        return tostring(val)
    end
end

local function findTowerAtPos(px, py, pz)
    local target = Vector3.new(px, py, pz)
    local best, bestDist = nil, 3
    for _, folder in ipairs({workspace, workspace:FindFirstChild("Towers"), workspace:FindFirstChild("Troops")}) do
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                local ok, pp = pcall(function() return obj:IsA("Model") and obj.PrimaryPart end)
                if ok and pp then
                    local d = (pp.Position - target).Magnitude
                    if d < bestDist then bestDist = d; best = obj end
                end
            end
        end
    end
    return best
end

local function safeDeserialize(val)
    if typeof(val) ~= "table" then return val end
    if val.__t == "v3" then
        return Vector3.new(val.x, val.y, val.z)
    elseif val.__t == "cf" then
        return CFrame.new(unpack(val.c))
    elseif val.__t == "tower" then
        local tower = findTowerAtPos(val.px, val.py, val.pz)
        if not tower then log("WARN: Tower not found at saved pos", Color3.new(1, 0.4, 0.2)) end
        return tower
    elseif val.__t == "inst" then
        return val.name 
    elseif val.__t == "enum" then
        return val.v
    else
        -- Regular table, recurse
        local out = {}
        for k, v in pairs(val) do
            out[k] = safeDeserialize(v)
        end
        return out
    end
end

-- ─── The Hook ─
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    -- ONLY process if it's our specific remotes
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        if self == remoteEvent or self == remoteFunction then
            local n = select("#", ...)
            local args = {...}
            
            -- Detect game start / wave skip
            if method == "InvokeServer" and args[1] == "Voting" and args[2] == "Skip" then
                triggerQueue[#triggerQueue + 1] = tick()
            end
            
            -- Record remotes
            if state.recording then
                captureQueue[#captureQueue + 1] = {
                    t = tick() - state.startTime,
                    m = method == "FireServer" and "F" or "I",
                    a = args
                }
            end
            
            return oldNamecall(self, unpack(args, 1, n))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- ─── Deferred Processing ─
connections.processor = RunService.Heartbeat:Connect(function()
    if state.unloaded then return end
    if #captureQueue == 0 then return end
    
    while #captureQueue > 0 do
        local raw = table.remove(captureQueue, 1)
        local args = raw.a
        
        local dominated = false
        if args[1] == "Hotbar" or args[1] == "Streaming" or args[1] == "Troops" or args[1] == "Voting" then
            dominated = true
        end
        
        if dominated then
            local serialized = {}
            for i, v in ipairs(args) do
                serialized[i] = safeSerialize(v)
            end
            
            table.insert(state.macroData, {
                time = raw.t,
                type = raw.m,
                args = serialized,
            })
            
            local label = tostring(args[2] or args[1])
            log("REC: " .. label .. " [" .. #state.macroData .. "]", Color3.fromRGB(100, 255, 100))
        end
    end
end)

-- ─── Game Start Trigger Processing ─────────────────────
local recBtn 
local lastTriggerTime = 0
local TRIGGER_COOLDOWN = 120 -- seconds: ignore Voting/Skip for this long after a trigger

connections.trigger = RunService.Heartbeat:Connect(function()
    if state.unloaded then return end
    if #triggerQueue == 0 then return end
    triggerQueue = {} -- consume all
    
    -- Cooldown: ignore if we triggered recently (mid-game wave skips / restarts)
    if (tick() - lastTriggerTime) < TRIGGER_COOLDOWN then
        return
    end
    
    if state.autoRecord and not state.recording and not state.playing then
        lastTriggerTime = tick()
        -- Auto-start recording
        state.recording = true
        state.macroData = {}
        captureQueue = {}
        state.startTime = tick()
        if recBtn then recBtn.Text = "⏹ STOP RECORDING" end
        log("AUTO-REC: Game detected!", Color3.fromRGB(255, 180, 50))
    end
end)

-- ─── Playback ──────────────────────────────────────────
local function playMacro()
    if #state.macroData == 0 then
        log("No macro data!", Color3.new(1, 0.3, 0.3))
        return
    end
    
    state.playing = true
    local start = tick()
    log("Playing " .. #state.macroData .. " actions...", Color3.fromRGB(0, 200, 255))
    
    local idx = 1
    while state.playing and idx <= #state.macroData do
        local entry = state.macroData[idx]
        local elapsed = tick() - start
        
        if elapsed >= entry.time then
            -- Deserialize args
            local dArgs = {}
            for i, v in ipairs(entry.args) do
                dArgs[i] = safeDeserialize(v)
            end
            
            -- Fire in a separate thread so InvokeServer doesn't block timing
            task.spawn(function()
                if entry.type == "F" then
                    remoteEvent:FireServer(unpack(dArgs))
                else
                    remoteFunction:InvokeServer(unpack(dArgs))
                end
            end)
            
            local label = tostring(dArgs[2] or dArgs[1])
            log("PLAY: " .. label, Color3.fromRGB(0, 200, 255))
            idx = idx + 1
        end
        task.wait()
    end
    
    state.playing = false
    log("Playback finished.", Color3.fromRGB(255, 255, 255))
end

-- ─── Auto-Replay Loop (standalone) ─────────────────────
-- ─── Unified AFK Engine (v5) ──────────────────────────
local function getReadyButton()
    local ok, btn = pcall(function()
        local gui = player.PlayerGui.ReactOverridesVote
        if not gui.Enabled then return nil end
        local b = gui.Frame.votes.container.ready.container.button
        if b.Visible and b.AbsoluteSize.Y > 0 then return b end
    end)
    return ok and btn or nil
end

local function getRestartButton()
    local ok, btn = pcall(function()
        local gui = player.PlayerGui.ReactGameNewRewards
        if not gui.Enabled then return nil end
        local b = gui.Frame.gameOver.RewardsScreen.PlayAgain.button
        if b.Visible and b.AbsoluteSize.Y > 0 then return b end
    end)
    return ok and btn or nil
end

local function isMatchLive()
    local ok, res = pcall(function()
        local bar = player.PlayerGui.ReactHotbar
        return bar.Enabled and bar.Frame.Visible
    end)
    return ok and res
end

local function clickAction(btn)
    pcall(function() remoteFunction:InvokeServer("Voting", "Skip") end)
    pcall(function()
        if firesignal then firesignal(btn.MouseButton1Click); firesignal(btn.Activated)
        else btn.MouseButton1Click:Fire() end
    end)
end

local function autoReplayLoop()
    if state.loopActive then return end
    state.loopActive = true
    log("MD MACRO: Active.", Color3.fromRGB(50, 255, 200))
    
    while state.autoReplay and not state.unloaded do
        -- 1. If macro is playing, absolute silence
        if state.playing then
            task.wait(5)
        else
            -- 2. Check current state with priority
            local live = isMatchLive()
            local rdy = getReadyButton()
            local rst = getRestartButton()
            
            if live and not rdy then
                -- We are mid-match, ignore everything else
                task.wait(5)
            elseif rdy then
                log("MD MACRO: Ready Screen. Voting...", Color3.fromRGB(50, 255, 120))
                clickAction(rdy)
                
                -- Wait 2.5s for transition then start
                task.wait(2.5)
                
                if state.autoReplay and not state.unloaded then
                    log("MD MACRO: Match Started. Playing...", Color3.fromRGB(50, 200, 255))
                    playMacro()
                end
            elseif rst then
                log("MD MACRO: Game Over. Restarting...", Color3.fromRGB(255, 180, 50))
                clickAction(rst)
                task.wait(10) -- Cool-down for map load
            else
                -- Idle / Lobby
                task.wait(1)
            end
        end
        task.wait(0.5)
    end
    
    state.loopActive = false
    log("MD MACRO: Stopped.", Color3.fromRGB(150, 150, 150))
end

-- ─── UI Buttons ────────────────────────────────────────
local function btn(text, y, color, cb)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 32)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.AutoButtonColor = true
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", b)
    bs.Color = color
    bs.Thickness = 1
    b.MouseButton1Click:Connect(cb)
    return b
end

recBtn = btn("⏺ START RECORDING", 152, Color3.fromRGB(255, 60, 60), function() end)
recBtn.MouseButton1Click:Connect(function()
    state.recording = not state.recording
    if state.recording then
        state.macroData = {}
        captureQueue = {}
        state.startTime = tick()
        recBtn.Text = "⏹ STOP RECORDING"
        log("Recording started.", Color3.fromRGB(255, 100, 100))
    else
        recBtn.Text = "⏺ START RECORDING"
        log("Stopped. " .. #state.macroData .. " actions captured.", Color3.fromRGB(255, 255, 255))
    end
end)

local playBtn = btn("▶ PLAY MACRO", 194, Color3.fromRGB(60, 255, 120), function()
    if state.playing then
        state.playing = false
        log("Playback stopped.", Color3.fromRGB(255, 200, 100))
    else
        task.spawn(playMacro)
    end
end)

-- Name input
local nameBox = Instance.new("TextBox", main)
nameBox.Size = UDim2.new(0.9, 0, 0, 28)
nameBox.Position = UDim2.new(0.05, 0, 0, 240)
nameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
nameBox.Text = "macro1"
nameBox.PlaceholderText = "Macro name..."
nameBox.TextColor3 = Color3.new(1, 1, 1)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 12
nameBox.ClearTextOnFocus = false
nameBox.BorderSizePixel = 0
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 6)

btn("💾 SAVE", 278, Color3.fromRGB(0, 150, 255), function()
    if not isfolder("tds_macros") then makefolder("tds_macros") end
    local path = "tds_macros/" .. nameBox.Text .. ".json"
    writefile(path, HttpService:JSONEncode(state.macroData))
    log("Saved: " .. nameBox.Text .. " (" .. #state.macroData .. ")", Color3.fromRGB(100, 180, 255))
end)

btn("📂 LOAD", 320, Color3.fromRGB(120, 120, 140), function()
    local path = "tds_macros/" .. nameBox.Text .. ".json"
    if isfile(path) then
        state.macroData = HttpService:JSONDecode(readfile(path))
        log("Loaded: " .. nameBox.Text .. " (" .. #state.macroData .. ")", Color3.fromRGB(100, 180, 255))
    else
        log("File not found: " .. nameBox.Text, Color3.new(1, 0.3, 0.3))
    end
end)

-- ─── Auto Toggles ──────────────────────────────────────
local function makeToggle(text, y, color, stateKey)
    local tBtn = Instance.new("TextButton", main)
    tBtn.Size = UDim2.new(0.9, 0, 0, 28)
    tBtn.Position = UDim2.new(0.05, 0, 0, y)
    tBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tBtn.Text = text .. ": OFF"
    tBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 11
    tBtn.AutoButtonColor = true
    tBtn.BorderSizePixel = 0
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
    local ts = Instance.new("UIStroke", tBtn)
    ts.Color = Color3.fromRGB(60, 60, 70)
    ts.Thickness = 1
    
    tBtn.MouseButton1Click:Connect(function()
        state[stateKey] = not state[stateKey]
        if state[stateKey] then
            tBtn.Text = text .. ": ON"
            tBtn.TextColor3 = Color3.new(1, 1, 1)
            ts.Color = color
            log(text .. " enabled.", color)
        else
            tBtn.Text = text .. ": OFF"
            tBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            ts.Color = Color3.fromRGB(60, 60, 70)
            log(text .. " disabled.", Color3.fromRGB(180, 180, 180))
        end
    end)
    return tBtn
end

makeToggle("Auto-Record on Start", 362, Color3.fromRGB(255, 120, 50), "autoRecord")

local replayToggle = makeToggle("Auto-Replay Match", 398, Color3.fromRGB(50, 220, 180), "autoReplay")

-- Background Watcher
task.spawn(function()
    while not state.unloaded do
        if state.autoReplay and not state.loopActive then
            task.spawn(autoReplayLoop)
        end
        task.wait(5)
    end
end)

btn("🗑 UNLOAD", 440, Color3.fromRGB(60, 60, 70), function()
    state.unloaded = true
    state.autoReplay = false
    state.recording = false
    state.playing = false
    
    for _, c in pairs(connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    
    pcall(function()
        hookmetamethod(game, "__namecall", oldNamecall)
    end)
    
    state.macroData = {}
    captureQueue = {}
    triggerQueue = {}
    
    gui:Destroy()
end).TextSize = 10

log("MD MACRO Ready.", Color3.fromRGB(0, 200, 255))
-- yes, it is skidded but only some of it
