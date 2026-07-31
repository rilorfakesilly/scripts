print("test3")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local Library = {}
Library.Connections = {}
Library.Threads = {}
Library.Unloaded = false

-- ── sound ids ───────────────────────────────────────────
local HOVER_SOUND = 139719503904449
local CLICK_SOUND = 88442833509532

local function playSound(soundId)
    if Library.Unloaded then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://" .. tostring(soundId)
        s.Volume = 0.75
        s.Parent = game:GetService("SoundService") or workspace
        s:Play()
        task.spawn(function()
            task.wait(1.5)
            s:Destroy()
        end)
    end)
end

-- ── UI Colors & Theme ───────────────────────────────────
local THEME = {
    BG = Color3.fromRGB(16, 16, 20),              -- Deep glass dark background
    BAR = Color3.fromRGB(24, 24, 30),             -- Header/containers
    ACCENT = Color3.fromRGB(255, 120, 0),         -- Default Orange accent
    ACCENT_LIGHT = Color3.fromRGB(255, 190, 60),   -- Orange light
    ACCENT_DARK = Color3.fromRGB(150, 60, 0),      -- Orange dark
    TEXT = Color3.fromRGB(245, 245, 250),         -- Off-white text
    TEXT_DIM = Color3.fromRGB(140, 140, 150),     -- Muted label text
    BORDER = Color3.fromRGB(40, 40, 48),           -- Dark border
    SUCCESS = Color3.fromRGB(50, 210, 110),       -- Success green
    DANGER = Color3.fromRGB(255, 75, 75)          -- Danger red
}

local PRESETS = {
    ["Orange"] = {
        ACCENT = Color3.fromRGB(255, 120, 0),
        ACCENT_LIGHT = Color3.fromRGB(255, 190, 60),
        ACCENT_DARK = Color3.fromRGB(150, 60, 0)
    },
    ["Pink"] = {
        ACCENT = Color3.fromRGB(255, 64, 128),
        ACCENT_LIGHT = Color3.fromRGB(255, 110, 180),
        ACCENT_DARK = Color3.fromRGB(180, 30, 80)
    },
    ["Green"] = {
        ACCENT = Color3.fromRGB(64, 224, 128),
        ACCENT_LIGHT = Color3.fromRGB(140, 255, 180),
        ACCENT_DARK = Color3.fromRGB(20, 140, 70)
    },
    ["Purple"] = {
        ACCENT = Color3.fromRGB(150, 80, 255),
        ACCENT_LIGHT = Color3.fromRGB(190, 140, 255),
        ACCENT_DARK = Color3.fromRGB(80, 30, 160)
    },
    ["Blue"] = {
        ACCENT = Color3.fromRGB(0, 160, 255),
        ACCENT_LIGHT = Color3.fromRGB(100, 210, 255),
        ACCENT_DARK = Color3.fromRGB(0, 70, 160)
    },
    ["Red"] = {
        ACCENT = Color3.fromRGB(255, 60, 60),
        ACCENT_LIGHT = Color3.fromRGB(255, 120, 120),
        ACCENT_DARK = Color3.fromRGB(150, 20, 20)
    },
    ["Gold"] = {
        ACCENT = Color3.fromRGB(255, 200, 0),
        ACCENT_LIGHT = Color3.fromRGB(255, 230, 100),
        ACCENT_DARK = Color3.fromRGB(160, 110, 0)
    },
    ["Custom"] = {
        ACCENT = Color3.fromRGB(255, 120, 0),
        ACCENT_LIGHT = Color3.fromRGB(255, 190, 60),
        ACCENT_DARK = Color3.fromRGB(150, 60, 0)
    }
}

local themeableGradients = {}
local themeableAccents = {}
local themeableAccentLights = {}
local themeableScrollBars = {}
local themeableFonts = {}
local themeableGlows = {}   -- tracks glow frames for accent color sync
local currentFontName = "GothamBold"
local currentThemeName = "Orange"

local function registerGlowFrame(frame)
    table.insert(themeableGlows, frame)
end

local function registerGradientColor(grad)
    table.insert(themeableGradients, grad)
end

local function registerAccentColor(inst)
    table.insert(themeableAccents, inst)
end

local function registerAccentLightColor(inst)
    table.insert(themeableAccentLights, inst)
end

local function registerFontElement(inst)
    table.insert(themeableFonts, inst)
    pcall(function()
        inst.Font = Enum.Font[currentFontName]
    end)
end

local function applyFont(fontName)
    local enumFont
    local success = pcall(function()
        enumFont = Enum.Font[fontName]
    end)
    if not success or not enumFont then
        enumFont = Enum.Font.GothamBold
    end
    currentFontName = fontName
    local i = 1
    while i <= #themeableFonts do
        local inst = themeableFonts[i]
        if inst and inst.Parent then
            pcall(function()
                inst.Font = enumFont
            end)
            i = i + 1
        else
            table.remove(themeableFonts, i)
        end
    end
end

local function registerScrollBar(scrollFrame)
    table.insert(themeableScrollBars, scrollFrame)
    pcall(function()
        scrollFrame.Active = true
        scrollFrame.ScrollBarImageColor3 = THEME.ACCENT
        
        -- Touch/mouse scroll drag support
        local dragging = false
        local lastInputPos = nil
        local dragInput = nil
        
        local function isWithinBounds(frame, position)
            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize
            if absSize.X <= 0 or absSize.Y <= 0 then return false end
            return position.X >= absPos.X and position.X <= absPos.X + absSize.X and
                   position.Y >= absPos.Y and position.Y <= absPos.Y + absSize.Y
        end
        
        local bConn = UserInputService.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
                if isWithinBounds(scrollFrame, input.Position) then
                    dragging = true
                    lastInputPos = input.Position
                    dragInput = input
                end
            end
        end)
        
        local cConn = UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local currentPos = input.Position
                if lastInputPos then
                    local delta = currentPos - lastInputPos
                    scrollFrame.CanvasPosition = scrollFrame.CanvasPosition - Vector2.new(delta.X, delta.Y)
                end
                lastInputPos = currentPos
            end
        end)
        
        local eConn = UserInputService.InputEnded:Connect(function(input)
            if input == dragInput or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                lastInputPos = nil
                dragInput = nil
            end
        end)
        
        table.insert(Library.Connections, bConn)
        table.insert(Library.Connections, cConn)
        table.insert(Library.Connections, eConn)
    end)
end

-- ── Animation Engine ─────────────────────────────────────────────────────────
local tweenCache = setmetatable({}, {__mode = "k"})

local function safeCancelAndDestroy(tween)
    if tween then
        pcall(tween.Cancel, tween)
        pcall(tween.Destroy, tween)
    end
end

local function playTween(instance, tweenInfo, props)
    if not instance or Library.Unloaded then return end
    local activeTweens = tweenCache[instance]
    if not activeTweens then
        activeTweens = {}
        tweenCache[instance] = activeTweens
    end
    for propName in pairs(props) do
        local existing = activeTweens[propName]
        if existing then
            safeCancelAndDestroy(existing)
            activeTweens[propName] = nil
        end
    end
    local t = TweenService:Create(instance, tweenInfo, props)
    for propName in pairs(props) do
        activeTweens[propName] = t
    end
    t:Play()
    t.Completed:Once(function()
        for propName in pairs(props) do
            if activeTweens[propName] == t then
                activeTweens[propName] = nil
            end
        end
        pcall(t.Destroy, t)
    end)
end

local function addHoverAnimation(button, hoverBgColor, originalBgColor)
    local uiScale = button:FindFirstChildWhichIsA("UIScale") or Instance.new("UIScale", button)
    
    if button.AnchorPoint ~= Vector2.new(0.5, 0.5) then
        local pos = button.Position
        local size = button.Size
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.Position = UDim2.new(
            pos.X.Scale + (size.X.Scale / 2), pos.X.Offset + (size.X.Offset / 2),
            pos.Y.Scale + (size.Y.Scale / 2), pos.Y.Offset + (size.Y.Offset / 2)
        )
    end
    
    local hoverInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    button.MouseEnter:Connect(function()
        playSound(HOVER_SOUND)
        local hover = button:GetAttribute("Themeable") and THEME.ACCENT_LIGHT or hoverBgColor
        playTween(button, hoverInfo, {BackgroundColor3 = hover})
        playTween(uiScale, hoverInfo, {Scale = 1.04})
    end)
    button.MouseLeave:Connect(function()
        local orig = button:GetAttribute("Themeable") and THEME.ACCENT or originalBgColor
        playTween(button, hoverInfo, {BackgroundColor3 = orig})
        playTween(uiScale, hoverInfo, {Scale = 1.0})
    end)
end

-- Shared Gradient Loop
local gradientRegistry = {}
local function registerGradient(grad)
    gradientRegistry[#gradientRegistry + 1] = grad
end

local gradientThread = task.spawn(function()
    while not Library.Unloaded do
        local i = 1
        while i <= #gradientRegistry do
            if Library.Unloaded then break end
            local g = gradientRegistry[i]
            if g and g.Parent then
                g.Rotation = (g.Rotation + 2) % 360
                i = i + 1
            else
                table.remove(gradientRegistry, i)
            end
        end
        task.wait(0.03)
    end
end)
table.insert(Library.Threads, gradientThread)

-- Theme Apply
local tabs = {}
local currentTab = nil
local selectTab -- forward declaration

local function applyTheme(name)
    local preset = PRESETS[name]
    if not preset then return end
    currentThemeName = name
    
    THEME.ACCENT = preset.ACCENT
    THEME.ACCENT_LIGHT = preset.ACCENT_LIGHT
    THEME.ACCENT_DARK = preset.ACCENT_DARK
    
    local newGradColor = ColorSequence.new(THEME.ACCENT_DARK, THEME.ACCENT_LIGHT)
    local i = 1
    while i <= #themeableGradients do
        local g = themeableGradients[i]
        if g and g.Parent then
            g.Color = newGradColor
            i = i + 1
        else
            table.remove(themeableGradients, i)
        end
    end
    
    -- Sync glow frames to new accent color
    i = 1
    while i <= #themeableGlows do
        local gf = themeableGlows[i]
        if gf and gf.Parent then
            gf.BackgroundColor3 = THEME.ACCENT
            i = i + 1
        else
            table.remove(themeableGlows, i)
        end
    end
    
    i = 1
    while i <= #themeableAccents do
        local inst = themeableAccents[i]
        if inst and inst.Parent then
            local isTab = false
            for tabName, tabData in pairs(tabs) do
                if tabData.Button == inst then
                    isTab = true
                    inst.TextColor3 = (currentTab == tabName) and THEME.ACCENT or THEME.TEXT_DIM
                    break
                end
            end
            if not isTab then
                local switchState = inst:GetAttribute("SwitchState")
                if switchState ~= nil then
                    inst.BackgroundColor3 = switchState and THEME.ACCENT or THEME.BAR
                elseif inst:GetAttribute("Themeable") then
                    inst.BackgroundColor3 = THEME.ACCENT
                elseif inst:IsA("Frame") then
                    inst.BackgroundColor3 = THEME.ACCENT
                end
            end
            i = i + 1
        else
            table.remove(themeableAccents, i)
        end
    end
    
    i = 1
    while i <= #themeableAccentLights do
        local inst = themeableAccentLights[i]
        if inst and inst.Parent then
            inst.BackgroundColor3 = THEME.ACCENT_LIGHT
            i = i + 1
        else
            table.remove(themeableAccentLights, i)
        end
    end
    
    i = 1
    while i <= #themeableScrollBars do
        local sf = themeableScrollBars[i]
        if sf and sf.Parent then
            sf.ScrollBarImageColor3 = THEME.ACCENT
            i = i + 1
        else
            table.remove(themeableScrollBars, i)
        end
    end
    
    if currentTab and selectTab then
        selectTab(currentTab, true)
    end
end

-- ── CreateWindow ─────────────────────────────────────────────────────────────
function Library.CreateWindow(titleText, subtitleText, hubIconId)
    -- Accept either a config table {title, subtitle, icon} or positional args
    if type(titleText) == "table" then
        local cfg = titleText
        titleText    = cfg.title    or cfg[1] or "WINDOW"
        subtitleText = cfg.subtitle or cfg[2] or ""
        hubIconId    = cfg.icon     or cfg[3] or nil
    else
        titleText    = titleText    or "WINDOW"
        subtitleText = subtitleText or ""
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PremiumModernUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999        -- always render above game UI
    screenGui.IgnoreGuiInset = true     -- full-screen coordinates
    
    -- Secure GUI parenting
    local parentedOk = false
    pcall(function()
        if gethui then
            screenGui.Parent = gethui()
            parentedOk = screenGui.Parent ~= nil
        end
    end)
    if not parentedOk then
        pcall(function()
            screenGui.Parent = game:GetService("CoreGui")
            parentedOk = screenGui.Parent ~= nil
        end)
    end
    if not parentedOk then
        screenGui.Parent = PlayerGui
    end
    
    -- ── Soft border glow (single frame, UIGradient transparency) ───────────
    -- One frame, slightly larger than main, with a UIGradient that fades from
    -- semi-opaque at the center (where the border is) to fully transparent at
    -- the outer edge. ZIndex=0 keeps it behind main. ClipsDescendants on the
    -- ScreenGui is false so it renders outside the window rect naturally.
    local MAIN_W, MAIN_H = 275, 370
    local GLOW_PAD = 10   -- how many px the glow extends past main on each side

    local glowFrame = Instance.new("Frame", screenGui)
    glowFrame.Size = UDim2.new(0, MAIN_W + GLOW_PAD * 2, 0, MAIN_H + GLOW_PAD * 2)
    glowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    glowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    glowFrame.BackgroundColor3 = THEME.ACCENT
    glowFrame.BackgroundTransparency = 0
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 0
    -- Corner radius = main's radius + pad so the shape follows the window exactly
    Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 14 + GLOW_PAD)

    -- Diagonal gradient: transparent at corners/edges → semi-opaque near border
    local glowGrad = Instance.new("UIGradient", glowFrame)
    glowGrad.Rotation = 90
    -- Simple two-keypoint fade: fully transparent at both ends, peek in the middle
    -- (the middle is the border of main which sits on top, so only the outer ring shows)
    glowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    1.0),   -- top outer edge: transparent
        NumberSequenceKeypoint.new(0.08, 0.50),  -- just outside top border: glow peak
        NumberSequenceKeypoint.new(0.18, 0.92),  -- fading toward interior
        NumberSequenceKeypoint.new(0.50, 1.0),   -- center: fully transparent
        NumberSequenceKeypoint.new(0.82, 0.92),
        NumberSequenceKeypoint.new(0.92, 0.50),  -- just outside bottom border
        NumberSequenceKeypoint.new(1.0,  1.0),   -- bottom outer edge: transparent
    })

    registerGlowFrame(glowFrame)
    local glowLayers = {{frame = glowFrame, offset = GLOW_PAD}}

    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.new(0, 275, 0, 370)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = THEME.BG
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    
    -- Rotating accent border stroke
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = Color3.new(1, 1, 1)
    mainStroke.Thickness = 1.8
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local mainStrokeGrad = Instance.new("UIGradient", mainStroke)
    mainStrokeGrad.Color = ColorSequence.new(THEME.ACCENT_DARK, THEME.ACCENT_LIGHT)
    registerGradientColor(mainStrokeGrad)
    registerGradient(mainStrokeGrad)

    -- Keep glow frame anchored to main when it moves / resizes / hides
    main:GetPropertyChangedSignal("Position"):Connect(function()
        for _, gl in ipairs(glowLayers) do
            gl.frame.Position = main.Position
        end
    end)
    main:GetPropertyChangedSignal("Size"):Connect(function()
        local s = main.AbsoluteSize
        for _, gl in ipairs(glowLayers) do
            gl.frame.Size = UDim2.new(0, s.X + GLOW_PAD * 2, 0, s.Y + GLOW_PAD * 2)
        end
    end)
    main:GetPropertyChangedSignal("Visible"):Connect(function()
        for _, gl in ipairs(glowLayers) do
            gl.frame.Visible = main.Visible
        end
    end)
    
    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 66)
    header.BackgroundColor3 = THEME.BAR
    header.BackgroundTransparency = 0.4
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
    
    local dragDetector = Instance.new("Frame", header)
    dragDetector.Name = "DragDetector"
    dragDetector.Size = UDim2.new(1, -75, 0, 36)
    dragDetector.BackgroundTransparency = 1
    dragDetector.Active = true
    
    local icon = Instance.new("ImageLabel", header)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 8, 0, 6)
    icon.BackgroundTransparency = 1
    icon.Image = hubIconId or "rbxthumb://type=Asset&id=140295322336049&w=150&h=150"
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -110, 0, 20)
    titleLabel.Position = UDim2.new(0, 38, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText:upper()
    titleLabel.TextColor3 = THEME.TEXT
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    registerFontElement(titleLabel)
    
    local subLabel = Instance.new("TextLabel", header)
    subLabel.Size = UDim2.new(1, -110, 0, 12)
    subLabel.Position = UDim2.new(0, 38, 0, 20)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subtitleText:upper()
    subLabel.TextColor3 = THEME.TEXT_DIM
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.GothamBold
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    registerFontElement(subLabel)
    
    -- ── Control Pill Container (matching MDhubV2.lua) ───────────────────
    local controlPill = Instance.new("Frame", header)
    controlPill.Size = UDim2.new(0, 92, 0, 25)
    controlPill.Position = UDim2.new(1, -98, 0, 6)
    controlPill.BackgroundColor3 = THEME.BAR
    controlPill.BackgroundTransparency = 0.4
    controlPill.BorderSizePixel = 0
    controlPill.ZIndex = 20
    Instance.new("UICorner", controlPill).CornerRadius = UDim.new(0, 7)

    -- 1. Gear button -> opens MISC tab
    local gearBtn = Instance.new("ImageButton", controlPill)
    gearBtn.Size = UDim2.new(0, 16, 0, 16)
    gearBtn.Position = UDim2.new(0, 8, 0.5, -8)
    gearBtn.BackgroundTransparency = 1
    gearBtn.Image = "rbxthumb://type=Asset&id=101671992802622&w=150&h=150"
    gearBtn.ImageColor3 = THEME.TEXT_DIM
    gearBtn.ZIndex = 21

    gearBtn.MouseEnter:Connect(function()
        playSound(HOVER_SOUND)
        playTween(gearBtn, TweenInfo.new(0.12), {ImageColor3 = THEME.TEXT})
    end)
    gearBtn.MouseLeave:Connect(function()
        playTween(gearBtn, TweenInfo.new(0.12), {ImageColor3 = THEME.TEXT_DIM})
    end)
    gearBtn.MouseButton1Click:Connect(function()
        playSound(CLICK_SOUND)
        if selectTab then
            if currentTab == "MISC" then
                -- Toggle back to first non-MISC visible tab
                local firstTab = nil
                for name, tData in pairs(tabs) do
                    if name ~= "MISC" and tData.Button and tData.Button.Visible then
                        if not firstTab or tData.Order < tabs[firstTab].Order then
                            firstTab = name
                        end
                    end
                end
                if firstTab then selectTab(firstTab, true) end
            elseif tabs["MISC"] then
                selectTab("MISC", true)
            end
        end
    end)

    -- 2. Minimize button: 22x22 hitbox with 15x3 solid visual pill line
    local minHitbox = Instance.new("TextButton", controlPill)
    minHitbox.Size = UDim2.new(0, 22, 0, 22)
    minHitbox.Position = UDim2.new(0, 35, 0.5, -11)
    minHitbox.BackgroundTransparency = 1
    minHitbox.Text = ""
    minHitbox.BorderSizePixel = 0
    minHitbox.ZIndex = 21

    local minVisual = Instance.new("Frame", minHitbox)
    minVisual.Size = UDim2.new(0, 15, 0, 3)
    minVisual.Position = UDim2.new(0.5, 0, 0.5, 0)
    minVisual.AnchorPoint = Vector2.new(0.5, 0.5)
    minVisual.BackgroundColor3 = THEME.TEXT_DIM
    minVisual.BorderSizePixel = 0
    minVisual.ZIndex = 21
    Instance.new("UICorner", minVisual).CornerRadius = UDim.new(0, 2)

    minHitbox.MouseEnter:Connect(function()
        playSound(HOVER_SOUND)
        playTween(minVisual, TweenInfo.new(0.12), {BackgroundColor3 = THEME.TEXT})
    end)
    minHitbox.MouseLeave:Connect(function()
        playTween(minVisual, TweenInfo.new(0.12), {BackgroundColor3 = THEME.TEXT_DIM})
    end)

    local doUnload
    local confirmOverlay = nil
    local function showCloseConfirmation()
        if confirmOverlay then return end
        
        confirmOverlay = Instance.new("Frame", main)
        confirmOverlay.Size = UDim2.new(1, 0, 1, 0)
        confirmOverlay.Position = UDim2.new(0, 0, 0, 0)
        confirmOverlay.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        confirmOverlay.BackgroundTransparency = 0.25
        confirmOverlay.ZIndex = 200
        confirmOverlay.Active = true
        Instance.new("UICorner", confirmOverlay).CornerRadius = UDim.new(0, 14)

        local confirmBox = Instance.new("Frame", confirmOverlay)
        confirmBox.Size = UDim2.new(0, 210, 0, 120)
        confirmBox.Position = UDim2.new(0.5, 0, 0.5, 0)
        confirmBox.AnchorPoint = Vector2.new(0.5, 0.5)
        confirmBox.BackgroundColor3 = THEME.BAR
        confirmBox.BorderSizePixel = 0
        confirmBox.ZIndex = 201
        Instance.new("UICorner", confirmBox).CornerRadius = UDim.new(0, 10)

        local boxStroke = Instance.new("UIStroke", confirmBox)
        boxStroke.Color = THEME.BORDER
        boxStroke.Thickness = 1.5

        local msgLabel = Instance.new("TextLabel", confirmBox)
        msgLabel.Size = UDim2.new(1, -20, 0, 44)
        msgLabel.Position = UDim2.new(0, 10, 0, 10)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = "Are you sure you want to close the script?"
        msgLabel.TextColor3 = THEME.TEXT
        msgLabel.TextSize = 9.5
        msgLabel.Font = Enum.Font.GothamBold
        msgLabel.TextWrapped = true
        msgLabel.ZIndex = 202
        registerFontElement(msgLabel)

        -- Yes Button
        local yesBtn = Instance.new("TextButton", confirmBox)
        yesBtn.Size = UDim2.new(0, 80, 0, 26)
        yesBtn.Position = UDim2.new(0.5, -88, 1, -34)
        yesBtn.BackgroundColor3 = THEME.ACCENT
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = THEME.TEXT
        yesBtn.TextSize = 9
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.BorderSizePixel = 0
        yesBtn.ZIndex = 202
        Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)
        registerFontElement(yesBtn)
        registerAccentColor(yesBtn)

        -- No Button
        local noBtn = Instance.new("TextButton", confirmBox)
        noBtn.Size = UDim2.new(0, 80, 0, 26)
        noBtn.Position = UDim2.new(0.5, 8, 1, -34)
        noBtn.BackgroundColor3 = THEME.BG
        noBtn.Text = "No"
        noBtn.TextColor3 = THEME.TEXT
        noBtn.TextSize = 9
        noBtn.Font = Enum.Font.GothamBold
        noBtn.BorderSizePixel = 0
        noBtn.ZIndex = 202
        Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)
        registerFontElement(noBtn)

        local noStroke = Instance.new("UIStroke", noBtn)
        noStroke.Color = THEME.BORDER
        noStroke.Thickness = 1

        local hoverInfo = TweenInfo.new(0.12)
        yesBtn.MouseEnter:Connect(function()
            playSound(HOVER_SOUND)
            playTween(yesBtn, hoverInfo, {BackgroundTransparency = 0.2})
        end)
        yesBtn.MouseLeave:Connect(function()
            playTween(yesBtn, hoverInfo, {BackgroundTransparency = 0})
        end)

        noBtn.MouseEnter:Connect(function()
            playSound(HOVER_SOUND)
            playTween(noBtn, hoverInfo, {BackgroundTransparency = 0.2})
        end)
        noBtn.MouseLeave:Connect(function()
            playTween(noBtn, hoverInfo, {BackgroundTransparency = 0})
        end)

        yesBtn.MouseButton1Click:Connect(function()
            playSound(CLICK_SOUND)
            if doUnload then
                doUnload()
            elseif Library.Unload then
                Library.Unload()
            else
                screenGui:Destroy()
            end
        end)

        noBtn.MouseButton1Click:Connect(function()
            playSound(CLICK_SOUND)
            confirmOverlay:Destroy()
            confirmOverlay = nil
        end)
    end

    -- 3. Close button -> opens close confirmation UI
    local closeBtn = Instance.new("ImageButton", controlPill)
    closeBtn.Size = UDim2.new(0, 13, 0, 13)
    closeBtn.Position = UDim2.new(0, 70, 0.5, -6.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxthumb://type=Asset&id=127825940291362&w=150&h=150"
    closeBtn.ImageColor3 = Color3.fromRGB(235, 235, 235)
    closeBtn.ZIndex = 21

    closeBtn.MouseEnter:Connect(function()
        playSound(HOVER_SOUND)
        playTween(closeBtn, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    closeBtn.MouseLeave:Connect(function()
        playTween(closeBtn, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(235, 235, 235)})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        playSound(CLICK_SOUND)
        showCloseConfirmation()
    end)

    -- Minimize Icon setup
    local miniIcon = Instance.new("ImageButton", screenGui)
    miniIcon.Size = UDim2.new(0, 40, 0, 40)
    miniIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    miniIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    miniIcon.BackgroundColor3 = THEME.BG
    miniIcon.Image = hubIconId or "rbxthumb://type=Asset&id=140295322336049&w=150&h=150"
    miniIcon.Visible = false
    miniIcon.Active = true
    Instance.new("UICorner", miniIcon).CornerRadius = UDim.new(0, 10)
    
    local mStroke = Instance.new("UIStroke", miniIcon)
    mStroke.Color = Color3.new(1, 1, 1)
    mStroke.Thickness = 2
    local mGrad = Instance.new("UIGradient", mStroke)
    mGrad.Color = ColorSequence.new(THEME.ACCENT_DARK, THEME.ACCENT_LIGHT)
    registerGradientColor(mGrad)
    registerGradient(mGrad)
    
    local miniIconScale = Instance.new("UIScale", miniIcon)
    local miniIconHoverInfo = TweenInfo.new(0.15)
    miniIcon.MouseEnter:Connect(function()
        playSound(HOVER_SOUND)
        playTween(miniIconScale, miniIconHoverInfo, {Scale = 1.08})
    end)
    miniIcon.MouseLeave:Connect(function()
        playTween(miniIconScale, miniIconHoverInfo, {Scale = 1.0})
    end)
    
    local animInfo = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local isAnimating = false
    
    minHitbox.MouseButton1Click:Connect(function()
        if isAnimating then return end
        isAnimating = true
        playSound(CLICK_SOUND)
        
        local shrinkTarget = main.Position
        miniIcon.Size = UDim2.new(0, 0, 0, 0)
        miniIcon.Position = shrinkTarget
        miniIcon.Visible = true
        
        playTween(main, animInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = shrinkTarget
        })
        playTween(miniIcon, animInfo, {
            Size = UDim2.new(0, 40, 0, 40),
            Position = shrinkTarget
        })
        task.delay(animInfo.Time, function()
            main.Visible = false
            isAnimating = false
        end)
    end)
    
    local mDragging, mMoved = false, false
    local mDragOffsetX, mDragOffsetY = 0, 0
    local mDragOriginX, mDragOriginY = 0, 0
    
    miniIcon.MouseButton1Click:Connect(function()
        if mMoved or isAnimating then return end
        isAnimating = true
        playSound(CLICK_SOUND)
        
        local expandStart = miniIcon.Position
        main.Size = UDim2.new(0, 0, 0, 0)
        main.Position = expandStart
        main.Visible = true
        
        playTween(main, animInfo, {
            Size = UDim2.new(0, 275, 0, 370),
            Position = expandStart
        })
        playTween(miniIcon, animInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = expandStart
        })
        task.delay(animInfo.Time, function()
            miniIcon.Visible = false
            isAnimating = false
        end)
    end)
    
    -- Tab bar: scrollable, compact 22 px height
    local TabBar = Instance.new("ScrollingFrame", header)
    TabBar.Size = UDim2.new(1, 0, 0, 22)
    TabBar.Position = UDim2.new(0, 0, 0, 38)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.ScrollingDirection = Enum.ScrollingDirection.X
    TabBar.CanvasSize = UDim2.new(0, 0, 1, 0)
    TabBar.ClipsDescendants = true
    TabBar.Active = true

    -- Horizontal list inside the scrollable tab bar
    local tabBarLayout = Instance.new("UIListLayout", TabBar)
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding = UDim.new(0, 2)

    -- Expand canvas as tabs are added
    tabBarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBar.CanvasSize = UDim2.new(0, tabBarLayout.AbsoluteContentSize.X, 1, 0)
    end)

    -- Mouse-wheel scrolls the tab bar horizontally (left/right)
    local SCROLL_STEP = 80
    local tabBarScrollConn = TabBar.MouseWheelForward:Connect(function()
        local target = math.max(0, TabBar.CanvasPosition.X - SCROLL_STEP)
        playTween(TabBar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(target, 0)})
    end)
    local tabBarScrollBackConn = TabBar.MouseWheelBackward:Connect(function()
        local maxX = math.max(0, TabBar.CanvasSize.X.Offset - TabBar.AbsoluteSize.X)
        local target = math.min(maxX, TabBar.CanvasPosition.X + SCROLL_STEP)
        playTween(TabBar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(target, 0)})
    end)
    table.insert(Library.Connections, tabBarScrollConn)
    table.insert(Library.Connections, tabBarScrollBackConn)

    -- Accent underline indicator sits just below the tab bar
    local indicatorBar = Instance.new("Frame", header)
    indicatorBar.Size = UDim2.new(0, 36, 0, 2)
    indicatorBar.Position = UDim2.new(0, 0, 0, 61)
    indicatorBar.BackgroundColor3 = THEME.ACCENT
    indicatorBar.BorderSizePixel = 0
    indicatorBar.ZIndex = 6
    registerAccentColor(indicatorBar)
    
    table.clear(tabs)
    currentTab = nil
    local sortedNames = {}
    local TAB_MIN_W = 52   -- minimum tab button width in px

    local function realignTabs()
        local visibleTabs = {}
        for _, name in ipairs(sortedNames) do
            local tData = tabs[name]
            if tData and tData.Button and tData.Button.Visible then
                table.insert(visibleTabs, name)
            end
        end

        local visibleCount = #visibleTabs
        if visibleCount == 0 then return end

        -- Distribute evenly up to bar width; if too many, use fixed min width (scrollable)
        local barW = TabBar.AbsoluteSize.X > 0 and TabBar.AbsoluteSize.X or 275
        local equalW = math.floor(barW / visibleCount)
        local tabW = math.max(equalW, TAB_MIN_W)

        for idx, name in ipairs(visibleTabs) do
            local tData = tabs[name]
            tData.Button.Size = UDim2.new(0, tabW, 1, 0)
            tData.Button.LayoutOrder = idx
        end

        -- Update canvas so the scrollframe knows the total width
        TabBar.CanvasSize = UDim2.new(0, tabW * visibleCount, 1, 0)

        -- If current tab is now invisible, select the first visible one
        if currentTab and tabs[currentTab] and not tabs[currentTab].Button.Visible then
            selectTab(visibleTabs[1])
        end
    end
    
    selectTab = function(tabName, force)
        if currentTab == tabName and not force then return end
        currentTab = tabName

        local slideTweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local fadeInfo = TweenInfo.new(0.12)

        for name, tabData in pairs(tabs) do
            if name == tabName then
                -- Active: bright accent text, opaque pill
                playTween(tabData.Button, fadeInfo, {
                    TextColor3 = THEME.ACCENT,
                    BackgroundTransparency = 0.1
                })
                playTween(tabData.Container, slideTweenInfo, {Position = UDim2.new(0, 0, 0, 66)})

                local btn = tabData.Button
                local btnAbsX = btn.AbsolutePosition.X - TabBar.AbsolutePosition.X + TabBar.CanvasPosition.X
                playTween(indicatorBar, slideTweenInfo, {
                    Position = UDim2.new(0, btnAbsX + btn.AbsoluteSize.X / 2 - 18, 0, 61),
                    BackgroundColor3 = THEME.ACCENT
                })

                local scrollTarget = math.clamp(
                    btnAbsX + btn.AbsoluteSize.X / 2 - TabBar.AbsoluteSize.X / 2,
                    0,
                    math.max(0, TabBar.CanvasSize.X.Offset - TabBar.AbsoluteSize.X)
                )
                playTween(TabBar, slideTweenInfo, {CanvasPosition = Vector2.new(scrollTarget, 0)})
            else
                -- Inactive: bright-grey text, transparent pill
                playTween(tabData.Button, fadeInfo, {
                    TextColor3 = Color3.fromRGB(210, 210, 220),
                    BackgroundTransparency = 0.7
                })
                if tabData.Order < tabs[tabName].Order then
                    playTween(tabData.Container, slideTweenInfo, {Position = UDim2.new(-1.1, 0, 0, 66)})
                else
                    playTween(tabData.Container, slideTweenInfo, {Position = UDim2.new(1.1, 0, 0, 66)})
                end
            end
        end
    end
    
    local tabCount = 0
    
    -- Component factory creation helpers
    
    -- Component factory creation helpers
    local function createComponentsBuilder(container)
        local builder = {}
        
        -- Toggle (flat, clean — no 3D ring or shadow)
        function builder:Toggle(text, default, callback)
            local row = Instance.new("Frame", container)
            row.Size = UDim2.new(1, -16, 0, 32)
            row.BackgroundTransparency = 1

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 4, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text:upper()
            lbl.TextColor3 = THEME.TEXT
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            registerFontElement(lbl)

            -- Track
            local switch = Instance.new("TextButton", row)
            switch.Size = UDim2.new(0, 34, 0, 16)
            switch.Position = UDim2.new(1, -38, 0.5, -8)
            switch.BackgroundColor3 = default and THEME.ACCENT or THEME.BAR
            switch.Text = ""
            switch.BorderSizePixel = 0
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
            switch:SetAttribute("SwitchState", default)
            registerAccentColor(switch)

            -- Simple flat knob (no gradient, no shadow, no extra stroke)
            local dot = Instance.new("Frame", switch)
            dot.Size = UDim2.new(0, 12, 0, 12)
            dot.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BorderSizePixel = 0
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local toggleInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local state = default

            local function setToggleState(newState, fireCallback)
                state = newState
                switch:SetAttribute("SwitchState", state)
                local targetColor = state and THEME.ACCENT or THEME.BAR
                local targetPos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                playTween(switch, toggleInfo, {BackgroundColor3 = targetColor})
                playTween(dot, toggleInfo, {Position = targetPos})
                if fireCallback ~= false then
                    callback(state)
                end
            end

            switch.MouseButton1Click:Connect(function()
                playSound(CLICK_SOUND)
                setToggleState(not state, true)
            end)

            return {
                Row = row,
                SetState = setToggleState,
                GetState = function() return state end
            }
        end

        -- Group: titled card that visually groups related elements
        function builder:Group(title)
            local card = Instance.new("Frame", container)
            card.Size = UDim2.new(1, -16, 0, 32)   -- grows with content
            card.BackgroundColor3 = THEME.BAR
            card.BackgroundTransparency = 0.55
            card.BorderSizePixel = 0
            card.ClipsDescendants = false
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

            local cardStroke = Instance.new("UIStroke", card)
            cardStroke.Color = THEME.BORDER
            cardStroke.Thickness = 1
            cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            -- Accent left bar
            local accentBar = Instance.new("Frame", card)
            accentBar.Size = UDim2.new(0, 3, 1, -12)
            accentBar.Position = UDim2.new(0, 0, 0.5, 0)
            accentBar.AnchorPoint = Vector2.new(0, 0.5)
            accentBar.BackgroundColor3 = THEME.ACCENT
            accentBar.BorderSizePixel = 0
            Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 3)
            registerAccentColor(accentBar)

            -- Group title label
            local titleLbl = Instance.new("TextLabel", card)
            titleLbl.Size = UDim2.new(1, -14, 0, 22)
            titleLbl.Position = UDim2.new(0, 10, 0, 0)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = title:upper()
            titleLbl.TextColor3 = THEME.TEXT_DIM
            titleLbl.TextSize = 8.5
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            registerFontElement(titleLbl)

            -- Inner container for child elements
            local body = Instance.new("Frame", card)
            body.Size = UDim2.new(1, -6, 0, 0)
            body.Position = UDim2.new(0, 3, 0, 22)
            body.BackgroundTransparency = 1
            body.ClipsDescendants = false

            local bodyList = Instance.new("UIListLayout", body)
            bodyList.Padding = UDim.new(0, 6)
            bodyList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local bodyPad = Instance.new("UIPadding", body)
            bodyPad.PaddingTop = UDim.new(0, 4)
            bodyPad.PaddingBottom = UDim.new(0, 6)

            -- Auto-resize card to match body content
            bodyList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local h = bodyList.AbsoluteContentSize.Y + 22 + 10  -- title + padding
                body.Size = UDim2.new(1, -6, 0, bodyList.AbsoluteContentSize.Y + 10)
                card.Size = UDim2.new(1, -16, 0, h)
                accentBar.Size = UDim2.new(0, 3, 0, math.max(h - 12, 4))
            end)

            -- Return a nested builder scoped to body
            return createComponentsBuilder(body)
        end
        
        -- Slider
        function builder:Slider(labelPrefix, minVal, maxVal, defaultVal, suffix, callback)
            local sliderFrame = Instance.new("Frame", container)
            sliderFrame.Size = UDim2.new(1, -16, 0, 42)
            sliderFrame.BackgroundColor3 = THEME.BAR
            sliderFrame.BorderSizePixel = 0
            Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)
            
            local sliderLabel = Instance.new("TextLabel", sliderFrame)
            sliderLabel.Size = UDim2.new(1, 0, 0, 18)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = labelPrefix .. ": " .. tostring(defaultVal) .. suffix
            sliderLabel.TextColor3 = THEME.TEXT_DIM
            sliderLabel.TextSize = 8
            sliderLabel.Font = Enum.Font.GothamBold
            registerFontElement(sliderLabel)
            
            local sliderBar = Instance.new("Frame", sliderFrame)
            sliderBar.Size = UDim2.new(1, -24, 0, 4)
            sliderBar.Position = UDim2.new(0.5, 0, 0.72, 0)
            sliderBar.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderBar.BackgroundColor3 = THEME.BG
            sliderBar.BorderSizePixel = 0
            Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
            
            local sliderFill = Instance.new("Frame", sliderBar)
            sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
            sliderFill.BackgroundColor3 = THEME.ACCENT
            sliderFill.BorderSizePixel = 0
            Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
            registerAccentColor(sliderFill)
            
            local sliderDot = Instance.new("Frame", sliderFill)
            sliderDot.Size = UDim2.new(0, 10, 0, 10)
            sliderDot.Position = UDim2.new(1, 0, 0.5, 0)
            sliderDot.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderDot.BackgroundColor3 = THEME.ACCENT_LIGHT
            sliderDot.BorderSizePixel = 0
            Instance.new("UICorner", sliderDot).CornerRadius = UDim.new(1, 0)
            registerAccentLightColor(sliderDot)
            
            local sliderDotScale = Instance.new("UIScale", sliderDot)
            local sliderHoverInfo = TweenInfo.new(0.12)
            
            sliderFrame.MouseEnter:Connect(function()
                playSound(HOVER_SOUND)
                playTween(sliderDotScale, sliderHoverInfo, {Scale = 1.3})
                playTween(sliderDot, sliderHoverInfo, {BackgroundColor3 = THEME.ACCENT})
                playTween(sliderFrame, sliderHoverInfo, {BackgroundColor3 = THEME.BORDER})
            end)
            sliderFrame.MouseLeave:Connect(function()
                playTween(sliderDotScale, sliderHoverInfo, {Scale = 1.0})
                playTween(sliderDot, sliderHoverInfo, {BackgroundColor3 = THEME.ACCENT_LIGHT})
                playTween(sliderFrame, sliderHoverInfo, {BackgroundColor3 = THEME.BAR})
            end)
            
            local currentVal = defaultVal
            local function update(input)
                local percentage = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                local rawVal = percentage * (maxVal - minVal) + minVal
                if suffix == "s" or suffix == "x" then
                    currentVal = math.floor(rawVal * 10 + 0.5) / 10
                    sliderLabel.Text = labelPrefix .. ": " .. string.format("%.1f", currentVal) .. suffix
                else
                    currentVal = math.floor(rawVal)
                    sliderLabel.Text = labelPrefix .. ": " .. tostring(currentVal) .. suffix
                end
                sliderFill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
                callback(currentVal)
            end
            
            local activeMoveConn, activeEndedConn
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    playSound(CLICK_SOUND)
                    if activeMoveConn then activeMoveConn:Disconnect() end
                    if activeEndedConn then activeEndedConn:Disconnect() end
                    activeMoveConn = UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement then
                            update(inp)
                        end
                    end)
                    activeEndedConn = UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            if activeMoveConn then activeMoveConn:Disconnect() end
                            if activeEndedConn then activeEndedConn:Disconnect() end
                        end
                    end)
                    update(input)
                end
            end)
            
            local function setValue(v)
                currentVal = math.clamp(v, minVal, maxVal)
                if suffix == "s" or suffix == "x" then
                    sliderLabel.Text = labelPrefix .. ": " .. string.format("%.1f", currentVal) .. suffix
                else
                    sliderLabel.Text = labelPrefix .. ": " .. tostring(currentVal) .. suffix
                end
                sliderFill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
            end
            
            return {
                Frame = sliderFrame,
                SetValue = setValue
            }
        end
        
        -- Dropdown
        function builder:Dropdown(label, options, defaultVal, callback, customFilterModes)
            return builder:SearchableDropdown(label, options, defaultVal, callback, customFilterModes)
        end
        -- Searchable Dropdown
        function builder:SearchableDropdown(label, options, defaultVal, callback, customFilterModes)
            local frame = Instance.new("Frame", container)
            frame.Size = UDim2.new(1, -16, 0, 52)
            frame.BackgroundTransparency = 1
            frame.ClipsDescendants = false
            
            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = label:upper()
            lbl.TextColor3 = THEME.TEXT_DIM
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            registerFontElement(lbl)
            
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, -4, 0, 30)
            btn.Position = UDim2.new(0.5, 0, 0, 35)
            btn.AnchorPoint = Vector2.new(0.5, 0.5)
            btn.BackgroundColor3 = THEME.BAR
            btn.BackgroundTransparency = 0.3
            btn.Text = defaultVal
            btn.TextColor3 = THEME.TEXT
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamBold
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            registerFontElement(btn)
            
            local btnScale = Instance.new("UIScale", btn)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = THEME.BORDER
            stroke.Thickness = 1
            
            local btnArrow = Instance.new("TextLabel", btn)
            btnArrow.Size = UDim2.new(0, 20, 1, 0)
            btnArrow.Position = UDim2.new(1, -25, 0, 0)
            btnArrow.BackgroundTransparency = 1
            btnArrow.Text = "▼"
            btnArrow.TextColor3 = THEME.TEXT
            btnArrow.TextSize = 10
            btnArrow.Font = Enum.Font.GothamBold
            registerFontElement(btnArrow)
            
            local listFrame = Instance.new("ScrollingFrame", frame)
            listFrame.Size = UDim2.new(1, -4, 0, 0)
            listFrame.Position = UDim2.new(0, 2, 0, 52)
            listFrame.BackgroundColor3 = THEME.BAR
            listFrame.BorderSizePixel = 0
            listFrame.Visible = false
            listFrame.ZIndex = 20
            listFrame.ScrollBarThickness = 3
            listFrame.ScrollBarImageColor3 = THEME.ACCENT
            Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
            registerScrollBar(listFrame)
            
            local listStroke = Instance.new("UIStroke", listFrame)
            listStroke.Color = THEME.BORDER
            listStroke.Thickness = 1
            
            local listLayout = Instance.new("UIListLayout", listFrame)
            listLayout.Padding = UDim.new(0, 2)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local listPad = Instance.new("UIPadding", listFrame)
            listPad.PaddingTop = UDim.new(0, 4)
            listPad.PaddingBottom = UDim.new(0, 4)
            
            local searchFrame = Instance.new("Frame", listFrame)
            searchFrame.Size = UDim2.new(1, -10, 0, 26)
            searchFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            searchFrame.BackgroundTransparency = 0
            searchFrame.BorderSizePixel = 0
            searchFrame.LayoutOrder = 0
            searchFrame.ZIndex = 21
            Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 6)
            local sfStroke = Instance.new("UIStroke", searchFrame)
            sfStroke.Color = THEME.BORDER
            sfStroke.Thickness = 1
            
            local searchInput = Instance.new("TextBox", searchFrame)
            searchInput.Size = UDim2.new(1, -34, 1, 0)
            searchInput.Position = UDim2.new(0, 8, 0, 0)
            searchInput.BackgroundTransparency = 1
            searchInput.Text = ""
            searchInput.PlaceholderText = "Enter text..."
            searchInput.PlaceholderColor3 = Color3.fromRGB(130, 130, 145)
            searchInput.TextColor3 = Color3.fromRGB(235, 235, 245)
            searchInput.TextSize = 8.5
            searchInput.TextXAlignment = Enum.TextXAlignment.Left
            searchInput.ClearTextOnFocus = false
            searchInput.ZIndex = 22
            registerFontElement(searchInput)
            
            -- Filter icon button (top-right of search box)
            local filterCycleBtn = Instance.new("ImageButton", searchFrame)
            filterCycleBtn.Size = UDim2.new(0, 16, 0, 16)
            filterCycleBtn.Position = UDim2.new(1, -22, 0.5, -8)
            filterCycleBtn.BackgroundTransparency = 1
            filterCycleBtn.Image = "rbxthumb://type=Asset&id=94521628289852&w=150&h=150"
            filterCycleBtn.ImageColor3 = Color3.fromRGB(240, 240, 240)
            filterCycleBtn.ImageTransparency = 0
            filterCycleBtn.ScaleType = Enum.ScaleType.Fit
            filterCycleBtn.BorderSizePixel = 0
            filterCycleBtn.ZIndex = 25

            local rawOptions = {}
            local optButtons = {}
            local renderButtons
            local currentSortMode = "A-Z"

            filterCycleBtn.MouseButton1Click:Connect(function()
                playSound(CLICK_SOUND)
                
                local activeModes = customFilterModes or { "A-Z", "Z-A" }
                
                local foundIdx = 1
                for idx, modeName in ipairs(activeModes) do
                    if modeName == currentSortMode then
                        foundIdx = idx
                        break
                    end
                end
                
                local nextIdx = (foundIdx % #activeModes) + 1
                currentSortMode = activeModes[nextIdx]
                -- icon stays the same; mode cycles silently
                
                local sorted = {}
                for _, v in ipairs(rawOptions) do table.insert(sorted, v) end
                
                if currentSortMode == "A-Z" then
                    table.sort(sorted, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
                elseif currentSortMode == "Z-A" then
                    table.sort(sorted, function(a, b) return tostring(a):lower() > tostring(b):lower() end)
                elseif currentSortMode == "HP+" then
                    table.sort(sorted, function(a, b)
                        local hpA = tonumber(tostring(a):match("%[(%d+)%s*HP%]")) or 0
                        local hpB = tonumber(tostring(b):match("%[(%d+)%s*HP%]")) or 0
                        return hpA < hpB
                    end)
                elseif currentSortMode == "HP-" then
                    table.sort(sorted, function(a, b)
                        local hpA = tonumber(tostring(a):match("%[(%d+)%s*HP%]")) or 0
                        local hpB = tonumber(tostring(b):match("%[(%d+)%s*HP%]")) or 0
                        return hpA > hpB
                    end)
                end
                renderButtons(sorted)
            end)

            local currentVal = defaultVal
            local open = false
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local function toggleDropdown(shouldOpen)
                open = shouldOpen
                if open then
                    if typeof(options) == "function" then
                        updateOptions(options())
                    end
                    listFrame.Visible = true
                    local numOptions = 0
                    for _, ob in ipairs(optButtons) do
                        if ob.Visible then numOptions = numOptions + 1 end
                    end
                    local targetHeight = math.min((numOptions + 1) * 26 + 32, 160)
                    listFrame.CanvasSize = UDim2.new(0, 0, 0, (numOptions + 1) * 26 + 32)
                    
                    playTween(btnArrow, tweenInfo, {Rotation = 180})
                    playTween(listFrame, tweenInfo, {Size = UDim2.new(1, -4, 0, targetHeight)})
                    playTween(frame, tweenInfo, {Size = UDim2.new(1, -16, 0, 52 + targetHeight)})
                else
                    playTween(btnArrow, tweenInfo, {Rotation = 0})
                    playTween(listFrame, tweenInfo, {Size = UDim2.new(1, -4, 0, 0)})
                    playTween(frame, tweenInfo, {Size = UDim2.new(1, -16, 0, 52)})
                    task.delay(tweenInfo.Time, function()
                        if not open then listFrame.Visible = false end
                    end)
                end
            end
            
            btn.MouseButton1Click:Connect(function()
                playSound(CLICK_SOUND)
                toggleDropdown(not open)
            end)
            
            local ddHoverInfo = TweenInfo.new(0.12)
            btn.MouseEnter:Connect(function()
                playSound(HOVER_SOUND)
                playTween(btn, ddHoverInfo, {BackgroundTransparency = 0.1})
                playTween(btnScale, ddHoverInfo, {Scale = 1.02})
            end)
            btn.MouseLeave:Connect(function()
                playTween(btn, ddHoverInfo, {BackgroundTransparency = 0.3})
                playTween(btnScale, ddHoverInfo, {Scale = 1.0})
            end)

            renderButtons = function(optsToRender)
                for _, ob in ipairs(optButtons) do
                    ob:Destroy()
                end
                table.clear(optButtons)

                local query = searchInput.Text:lower()
                
                for idx, opt in ipairs(optsToRender) do
                    local optBtn = Instance.new("TextButton", listFrame)
                    optBtn.Size = UDim2.new(1, -10, 0, 24)
                    optBtn.BackgroundColor3 = THEME.BG
                    optBtn.BackgroundTransparency = 0.8
                    optBtn.BorderSizePixel = 0
                    optBtn.Text = opt
                    optBtn.TextColor3 = THEME.TEXT
                    optBtn.TextSize = 8.5
                    optBtn.ZIndex = 21
                    optBtn.LayoutOrder = idx + 1
                    optBtn.Visible = (query == "" or opt:lower():find(query, 1, true) ~= nil)
                    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)
                    registerFontElement(optBtn)
                    
                    local optHoverInfo = TweenInfo.new(0.12)
                    optBtn.MouseEnter:Connect(function()
                        playSound(HOVER_SOUND)
                        playTween(optBtn, optHoverInfo, {BackgroundTransparency = 0.4})
                    end)
                    optBtn.MouseLeave:Connect(function()
                        playTween(optBtn, optHoverInfo, {BackgroundTransparency = 0.8})
                    end)
                    
                    optBtn.MouseButton1Click:Connect(function()
                        playSound(CLICK_SOUND)
                        currentVal = opt
                        btn.Text = opt
                        toggleDropdown(false)
                        callback(opt)
                    end)
                    
                    table.insert(optButtons, optBtn)
                end
            end
            
            local function updateOptions(newOptions)
                rawOptions = newOptions or {}
                local sorted = {}
                for _, v in ipairs(rawOptions) do table.insert(sorted, v) end
                if currentSortMode == "A-Z" then
                    table.sort(sorted, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
                elseif currentSortMode == "Z-A" then
                    table.sort(sorted, function(a, b) return tostring(a):lower() > tostring(b):lower() end)
                elseif currentSortMode == "HP+" then
                    table.sort(sorted, function(a, b)
                        local hpA = tonumber(tostring(a):match("%[(%d+)%s*HP%]")) or 0
                        local hpB = tonumber(tostring(b):match("%[(%d+)%s*HP%]")) or 0
                        return hpA < hpB
                    end)
                elseif currentSortMode == "HP-" then
                    table.sort(sorted, function(a, b)
                        local hpA = tonumber(tostring(a):match("%[(%d+)%s*HP%]")) or 0
                        local hpB = tonumber(tostring(b):match("%[(%d+)%s*HP%]")) or 0
                        return hpA > hpB
                    end)
                end
                renderButtons(sorted)
            end
            
            searchInput:GetPropertyChangedSignal("Text"):Connect(function()
                local query = searchInput.Text:lower()
                for _, ob in ipairs(optButtons) do
                    ob.Visible = (query == "" or ob.Text:lower():find(query, 1, true) ~= nil)
                end
                if open then
                    local numOptions = 0
                    for _, ob in ipairs(optButtons) do
                        if ob.Visible then numOptions = numOptions + 1 end
                    end
                    local targetHeight = math.min((numOptions + 1) * 26 + 12, 140)
                    listFrame.CanvasSize = UDim2.new(0, 0, 0, (numOptions + 1) * 26 + 12)
                    playTween(listFrame, tweenInfo, {Size = UDim2.new(1, -4, 0, targetHeight)})
                    playTween(frame, tweenInfo, {Size = UDim2.new(1, -16, 0, 52 + targetHeight)})
                end
            end)
            
            if typeof(options) ~= "function" then
                updateOptions(options)
            end
            
            return {
                Frame = frame,
                SetOptions = updateOptions,
                SetSelected = function(val)
                    currentVal = val
                    btn.Text = val
                end
            }
        end
        
        -- TextBox
        function builder:TextBox(placeholder, defaultVal, callback)
            local textBoxFrame = Instance.new("Frame", container)
            textBoxFrame.Size = UDim2.new(1, -16, 0, 42)
            textBoxFrame.BackgroundColor3 = THEME.BAR
            textBoxFrame.BorderSizePixel = 0
            Instance.new("UICorner", textBoxFrame).CornerRadius = UDim.new(0, 8)
            
            local textInput = Instance.new("TextBox", textBoxFrame)
            textInput.Size = UDim2.new(1, -20, 1, -8)
            textInput.Position = UDim2.new(0.5, 0, 0.5, 0)
            textInput.AnchorPoint = Vector2.new(0.5, 0.5)
            textInput.BackgroundTransparency = 1
            textInput.Text = defaultVal or ""
            textInput.PlaceholderText = placeholder
            textInput.PlaceholderColor3 = THEME.TEXT_DIM
            textInput.TextColor3 = THEME.TEXT
            textInput.TextSize = 11
            textInput.Font = Enum.Font.GothamBold
            textInput.ClearTextOnFocus = false
            registerFontElement(textInput)
            
            local tbHoverInfo = TweenInfo.new(0.12)
            textBoxFrame.MouseEnter:Connect(function()
                playSound(HOVER_SOUND)
                playTween(textBoxFrame, tbHoverInfo, {BackgroundColor3 = THEME.BORDER})
            end)
            textBoxFrame.MouseLeave:Connect(function()
                playTween(textBoxFrame, tbHoverInfo, {BackgroundColor3 = THEME.BAR})
            end)
            
            textInput.FocusLost:Connect(function()
                callback(textInput.Text)
            end)
            
            return textBoxFrame, textInput
        end
        
        -- Button
        function builder:Button(text, colorType, callback)
            if typeof(colorType) == "function" then
                callback = colorType
                colorType = nil
            end
            
            local defaultColor = THEME.ACCENT
            local hoverColor = THEME.ACCENT_LIGHT
            local themeable = true
            
            if colorType == "SUCCESS" then
                defaultColor = THEME.SUCCESS
                hoverColor = Color3.fromRGB(40, 190, 100)
                themeable = false
            elseif colorType == "DANGER" then
                defaultColor = THEME.DANGER
                hoverColor = Color3.fromRGB(240, 60, 60)
                themeable = false
            end
            
            local btn = Instance.new("TextButton", container)
            btn.Size = UDim2.new(1, -16, 0, 32)
            btn.BackgroundColor3 = defaultColor
            btn.Text = text:upper()
            btn.TextColor3 = THEME.TEXT
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            -- Subtle stroke for depth
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.82
            stroke.Thickness = 1
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            
            -- Visual-only bevel overlay: Active=false so all input passes through to btn
            local bevelOverlay = Instance.new("Frame", btn)
            bevelOverlay.Size = UDim2.new(1, 0, 1, 0)
            bevelOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            bevelOverlay.BorderSizePixel = 0
            bevelOverlay.Active = false
            bevelOverlay.ZIndex = btn.ZIndex + 1
            Instance.new("UICorner", bevelOverlay).CornerRadius = UDim.new(0, 8)
            local bevelGrad = Instance.new("UIGradient", bevelOverlay)
            bevelGrad.Rotation = 90
            bevelGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,   0,   0)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,   0,   0))
            })
            bevelGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,   0.76),
                NumberSequenceKeypoint.new(0.25, 1),
                NumberSequenceKeypoint.new(0.75, 1),
                NumberSequenceKeypoint.new(1,   0.84)
            })
            
            if themeable then
                btn:SetAttribute("Themeable", true)
                registerAccentColor(btn)
            end
            
            addHoverAnimation(btn, hoverColor, defaultColor)
            registerFontElement(btn)
            
            -- UIScale press: tactile feel, no layout disruption
            local btnScale = Instance.new("UIScale", btn)
            local clickInfo = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            btn.MouseButton1Down:Connect(function()
                playTween(btnScale, clickInfo, {Scale = 0.96})
            end)
            btn.MouseButton1Up:Connect(function()
                playTween(btnScale, clickInfo, {Scale = 1})
            end)
            btn.MouseLeave:Connect(function()
                playTween(btnScale, clickInfo, {Scale = 1})
            end)
            
            btn.MouseButton1Click:Connect(function()
                playSound(CLICK_SOUND)
                if callback then callback() end
            end)
            
            return btn
        end
        
        -- Collapsible Section
        function builder:Collapsible(title)
            local sectionFrame = Instance.new("Frame", container)
            sectionFrame.Size = UDim2.new(1, -16, 0, 36)
            sectionFrame.BackgroundColor3 = THEME.BAR
            sectionFrame.BackgroundTransparency = 0.5
            sectionFrame.BorderSizePixel = 0
            sectionFrame.ClipsDescendants = true
            Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 8)
            
            local sectionStroke = Instance.new("UIStroke", sectionFrame)
            sectionStroke.Color = THEME.BORDER
            sectionStroke.Thickness = 1
            
            local headerBtn = Instance.new("TextButton", sectionFrame)
            headerBtn.Size = UDim2.new(1, 0, 0, 36)
            headerBtn.BackgroundTransparency = 1
            headerBtn.Text = ""
            
            local titleLabel = Instance.new("TextLabel", headerBtn)
            titleLabel.Size = UDim2.new(1, -36, 1, 0)
            titleLabel.Position = UDim2.new(0, 28, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title:upper()
            titleLabel.TextColor3 = THEME.TEXT
            titleLabel.TextSize = 11
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            registerFontElement(titleLabel)
            
            local arrow = Instance.new("TextLabel", headerBtn)
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(0, 8, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = THEME.TEXT
            arrow.TextSize = 9
            arrow.Font = Enum.Font.GothamBold
            registerFontElement(arrow)
            
            local body = Instance.new("Frame", sectionFrame)
            body.Size = UDim2.new(1, 0, 0, 0)
            body.Position = UDim2.new(0, 0, 0, 36)
            body.BackgroundTransparency = 1
            body.Visible = false
            body.ClipsDescendants = true
            
            local bodyList = Instance.new("UIListLayout", body)
            bodyList.Padding = UDim.new(0, 6)
            bodyList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local bodyPad = Instance.new("UIPadding", body)
            bodyPad.PaddingTop = UDim.new(0, 6)
            bodyPad.PaddingBottom = UDim.new(0, 6)
            
            local expanded = false
            local isTweening = false
            local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local function updateLayout()
                if expanded and not isTweening then
                    local totalHeight = bodyList.AbsoluteContentSize.Y + 12
                    body.Size = UDim2.new(1, 0, 0, totalHeight)
                    sectionFrame.Size = UDim2.new(1, -16, 0, 36 + totalHeight)
                end
            end
            bodyList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLayout)
            
            local secHoverInfo = TweenInfo.new(0.12)
            headerBtn.MouseButton1Click:Connect(function()
                playSound(CLICK_SOUND)
                expanded = not expanded
                isTweening = true
                if expanded then
                    body.Visible = true
                    local totalHeight = bodyList.AbsoluteContentSize.Y + 12
                    playTween(arrow, tweenInfo, {Rotation = 90})
                    playTween(body, tweenInfo, {Size = UDim2.new(1, 0, 0, totalHeight)})
                    playTween(sectionFrame, tweenInfo, {Size = UDim2.new(1, -16, 0, 36 + totalHeight)})
                    task.delay(tweenInfo.Time, function() isTweening = false end)
                else
                    playTween(arrow, tweenInfo, {Rotation = 0})
                    playTween(body, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)})
                    playTween(sectionFrame, tweenInfo, {Size = UDim2.new(1, -16, 0, 36)})
                    task.delay(tweenInfo.Time, function()
                        isTweening = false
                        if not expanded then body.Visible = false end
                    end)
                end
            end)
            
            headerBtn.MouseEnter:Connect(function()
                playSound(HOVER_SOUND)
                playTween(arrow, secHoverInfo, {TextColor3 = THEME.ACCENT})
                playTween(titleLabel, secHoverInfo, {TextColor3 = THEME.ACCENT})
            end)
            headerBtn.MouseLeave:Connect(function()
                playTween(arrow, secHoverInfo, {TextColor3 = THEME.TEXT})
                playTween(titleLabel, secHoverInfo, {TextColor3 = THEME.TEXT})
            end)
            
            return createComponentsBuilder(body)
        end
        
        -- Custom grid elements (like timescale)
        function builder:TimescaleGrid(callback)
            local gridFrame = Instance.new("Frame", container)
            gridFrame.Size = UDim2.new(1, -16, 0, 34)
            gridFrame.BackgroundTransparency = 1
            
            local listLayout = Instance.new("UIListLayout", gridFrame)
            listLayout.FillDirection = Enum.FillDirection.Horizontal
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.Padding = UDim.new(0, 4)
            
            local speeds = {"x0", "x0.5", "x1", "x1.5", "x2"}
            local buttons = {}
            
            for _, sp in ipairs(speeds) do
                local btn = Instance.new("TextButton", gridFrame)
                btn.Size = UDim2.new(0.2, -4, 1, 0)
                btn.BackgroundColor3 = THEME.BAR
                btn.Text = sp
                btn.TextColor3 = THEME.TEXT_DIM
                btn.TextSize = 8.5
                btn.Font = Enum.Font.GothamBold
                btn.BorderSizePixel = 0
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                local stroke = Instance.new("UIStroke", btn)
                stroke.Color = THEME.BORDER
                stroke.Thickness = 1
                
                btn.MouseButton1Click:Connect(function()
                    playSound(CLICK_SOUND)
                    for _, b in ipairs(buttons) do
                        b.BackgroundColor3 = THEME.BAR
                        b.TextColor3 = THEME.TEXT_DIM
                    end
                    btn.BackgroundColor3 = THEME.ACCENT
                    btn.TextColor3 = THEME.TEXT
                    callback(sp)
                end)
                
                table.insert(buttons, btn)
            end
            
            local function selectSpeed(spName)
                for _, b in ipairs(buttons) do
                    if b.Text == spName then
                        b.BackgroundColor3 = THEME.ACCENT
                        b.TextColor3 = THEME.TEXT
                    else
                        b.BackgroundColor3 = THEME.BAR
                        b.TextColor3 = THEME.TEXT_DIM
                    end
                end
            end
            
            return {
                Frame = gridFrame,
                SelectSpeed = selectSpeed
            }
        end
        
        -- Custom simple log label box
        function builder:LogBox(height)
            local logFrame = Instance.new("ScrollingFrame", container)
            logFrame.Size = UDim2.new(1, -16, 0, height or 70)
            logFrame.BackgroundColor3 = THEME.BAR
            logFrame.BorderSizePixel = 0
            logFrame.ScrollBarThickness = 2
            logFrame.ScrollBarImageColor3 = THEME.ACCENT
            Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 8)
            registerScrollBar(logFrame)
            
            local logStroke = Instance.new("UIStroke", logFrame)
            logStroke.Color = THEME.BORDER
            logStroke.Thickness = 1
            
            local layout = Instance.new("UIListLayout", logFrame)
            layout.Padding = UDim.new(0, 2)
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local pad = Instance.new("UIPadding", logFrame)
            pad.PaddingTop = UDim.new(0, 4)
            pad.PaddingBottom = UDim.new(0, 4)
            pad.PaddingLeft = UDim.new(0, 6)
            pad.PaddingRight = UDim.new(0, 6)
            
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                logFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                logFrame.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y - logFrame.AbsoluteSize.Y + 10))
            end)
            
            local function addLog(text, color)
                local lbl = Instance.new("TextLabel", logFrame)
                lbl.Size = UDim2.new(1, 0, 0, 14)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = color or THEME.TEXT
                lbl.TextSize = 7.5
                lbl.Font = Enum.Font.GothamBold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                registerFontElement(lbl)
                
                local currentLogs = logFrame:GetChildren()
                if #currentLogs > 50 then
                    for i = 1, #currentLogs do
                        if currentLogs[i]:IsA("TextLabel") then
                            currentLogs[i]:Destroy()
                            break
                        end
                    end
                end
            end
            
            return {
                Frame = logFrame,
                Log = addLog,
                Clear = function()
                    for _, c in ipairs(logFrame:GetChildren()) do
                        if c:IsA("TextLabel") then c:Destroy() end
                    end
                end
            }
        end
        
        -- ButtonRow: side by side buttons
        function builder:ButtonRow(buttonsData)
            local row = Instance.new("Frame", container)
            row.Size = UDim2.new(1, -16, 0, 32)
            row.BackgroundTransparency = 1
            
            local listLayout = Instance.new("UIListLayout", row)
            listLayout.FillDirection = Enum.FillDirection.Horizontal
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 6)
            
            local numButtons = #buttonsData
            local buttons = {}
            for idx, btnData in ipairs(buttonsData) do
                local defaultColor = THEME.ACCENT
                local hoverColor = THEME.ACCENT_LIGHT
                local themeable = true
                
                if btnData.colorType == "SUCCESS" then
                    defaultColor = THEME.SUCCESS
                    hoverColor = Color3.fromRGB(40, 190, 100)
                    themeable = false
                elseif btnData.colorType == "DANGER" then
                    defaultColor = THEME.DANGER
                    hoverColor = Color3.fromRGB(240, 60, 60)
                    themeable = false
                elseif btnData.colorType == "SECONDARY" then
                    defaultColor = THEME.BAR
                    hoverColor = Color3.fromRGB(45, 45, 52)
                    themeable = false
                end
                
                local btn = Instance.new("TextButton", row)
                btn.Size = UDim2.new(1 / numButtons, - (6 * (numButtons - 1) / numButtons), 1, 0)
                btn.LayoutOrder = idx
                btn.BackgroundColor3 = defaultColor
                btn.Text = btnData.text:upper()
                btn.TextColor3 = THEME.TEXT
                btn.TextSize = 8.5
                btn.Font = Enum.Font.GothamBold
                btn.BorderSizePixel = 0
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                
                -- Subtle stroke for depth
                local stroke = Instance.new("UIStroke", btn)
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stroke.Transparency = 0.82
                stroke.Thickness = 1
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                -- Visual-only bevel overlay: Active=false so all input passes through to btn
                local bevelOverlay = Instance.new("Frame", btn)
                bevelOverlay.Size = UDim2.new(1, 0, 1, 0)
                bevelOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                bevelOverlay.BorderSizePixel = 0
                bevelOverlay.Active = false
                bevelOverlay.ZIndex = btn.ZIndex + 1
                Instance.new("UICorner", bevelOverlay).CornerRadius = UDim.new(0, 8)
                local bevelGrad = Instance.new("UIGradient", bevelOverlay)
                bevelGrad.Rotation = 90
                bevelGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,   0,   0)),
                    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,   0,   0))
                })
                bevelGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,    0.76),
                    NumberSequenceKeypoint.new(0.25, 1),
                    NumberSequenceKeypoint.new(0.75, 1),
                    NumberSequenceKeypoint.new(1,    0.84)
                })
                
                if themeable then
                    btn:SetAttribute("Themeable", true)
                    registerAccentColor(btn)
                end
                
                addHoverAnimation(btn, hoverColor, defaultColor)
                registerFontElement(btn)
                
                -- UIScale press: tactile feel, no layout disruption
                local btnScale = Instance.new("UIScale", btn)
                local clickInfo = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                btn.MouseButton1Down:Connect(function()
                    playTween(btnScale, clickInfo, {Scale = 0.96})
                end)
                btn.MouseButton1Up:Connect(function()
                    playTween(btnScale, clickInfo, {Scale = 1})
                end)
                btn.MouseLeave:Connect(function()
                    playTween(btnScale, clickInfo, {Scale = 1})
                end)
                
                btn.MouseButton1Click:Connect(function()
                    playSound(CLICK_SOUND)
                    btnData.callback()
                end)
                
                table.insert(buttons, btn)
            end
            return {
                Row = row,
                Buttons = buttons
            }
        end
        
        -- Label
        function builder:Label(text, color)
            local lbl = Instance.new("TextLabel", container)
            lbl.Size = UDim2.new(1, -16, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = color or THEME.TEXT_DIM
            lbl.TextSize = 8.5
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            registerFontElement(lbl)
            return lbl
        end
        
        return builder
    end
    
    -- CreateTab
    local function createTab(tabName)
        tabCount = tabCount + 1
        local tabOrder = tabCount
        
        local contentFrame = Instance.new("ScrollingFrame", main)
        contentFrame.Size = UDim2.new(1, 0, 1, -86)
        contentFrame.Position = UDim2.new(1.1, 0, 0, 66)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 3
        contentFrame.ScrollBarImageColor3 = THEME.ACCENT
        contentFrame.ClipsDescendants = true
        contentFrame.Visible = true
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        registerScrollBar(contentFrame)
        
        local listLayout = Instance.new("UIListLayout", contentFrame)
        listLayout.Padding = UDim.new(0, 6)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local padding = Instance.new("UIPadding", contentFrame)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end)
        
        local tabBtn = Instance.new("TextButton", TabBar)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        tabBtn.BackgroundTransparency = 0.7
        tabBtn.Text = tabName:upper()
        tabBtn.TextColor3 = Color3.fromRGB(215, 215, 225)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 11
        tabBtn.Size = UDim2.new(0, TAB_MIN_W, 1, 0)
        tabBtn.BorderSizePixel = 0
        tabBtn.ZIndex = 5
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)
        registerAccentColor(tabBtn)
        registerFontElement(tabBtn)
        
        tabs[tabName] = {
            Container = contentFrame,
            Button = tabBtn,
            Order = tabOrder
        }
        
        if tabName == "MISC" then
            tabBtn.Visible = false
        end
        
        table.insert(sortedNames, tabName)
        table.sort(sortedNames, function(a, b) return tabs[a].Order < tabs[b].Order end)
        
        tabBtn:GetPropertyChangedSignal("Visible"):Connect(realignTabs)
        realignTabs()
        
        tabBtn.MouseButton1Click:Connect(function()
            playSound(CLICK_SOUND)
            selectTab(tabName)
        end)
        
        local tabHoverInfo = TweenInfo.new(0.12)
        tabBtn.MouseEnter:Connect(function()
            if currentTab ~= tabName then
                playSound(HOVER_SOUND)
                playTween(tabBtn, tabHoverInfo, {
                    TextColor3 = THEME.TEXT,
                    BackgroundTransparency = 0.35
                })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if currentTab ~= tabName then
                playTween(tabBtn, tabHoverInfo, {
                    TextColor3 = Color3.fromRGB(210, 210, 220),
                    BackgroundTransparency = 0.7
                })
            end
        end)
        
        local builder = createComponentsBuilder(contentFrame)
        builder.TabButton = tabBtn
        builder.Container = contentFrame
        return builder
    end
    
    -- Draggable Window handler
    local dragging = false
    local dragInput, dragStart, startPos
    local mDragInput, mDragStart, mStartPos
    
    local function updateMain(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    local function updateMini(input)
        local delta = input.Position - mDragStart
        miniIcon.Position = UDim2.new(mStartPos.X.Scale, mStartPos.X.Offset + delta.X, mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y)
    end
    
    local bConn1 = dragDetector.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            local cConn
            cConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if cConn then cConn:Disconnect() end
                end
            end)
        end
    end)
    
    local cConn1 = dragDetector.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            updateMain(input)
        end
    end)
    
    local bConn2 = miniIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mDragging = true
            mMoved = false
            mDragStart = input.Position
            mStartPos = miniIcon.Position
            
            local cConn
            cConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mDragging = false
                    if cConn then cConn:Disconnect() end
                end
            end)
        end
    end)
    
    local cConn2 = miniIcon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            mDragInput = input
        end
    end)
    
    local miniDragConn = UserInputService.InputChanged:Connect(function(input)
        if mDragging and input == mDragInput then
            local delta = input.Position - mDragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                mMoved = true
            end
            updateMini(input)
        end
    end)
    
    table.insert(Library.Connections, bConn1)
    table.insert(Library.Connections, cConn1)
    table.insert(Library.Connections, dragConn)
    table.insert(Library.Connections, bConn2)
    table.insert(Library.Connections, cConn2)
    table.insert(Library.Connections, miniDragConn)
    
    -- Cleanup function
    doUnload = function()
        if Library.Unloaded then return end
        Library.Unloaded = true
        
        for _, conn in ipairs(Library.Connections) do
            if conn then pcall(conn.Disconnect, conn) end
        end
        table.clear(Library.Connections)
        
        for _, thr in ipairs(Library.Threads) do
            if thr then pcall(task.cancel, thr) end
        end
        table.clear(Library.Threads)
        
        table.clear(gradientRegistry)
        
        pcall(function() screenGui:Destroy() end)
    end
    
    return {
        CreateTab = createTab,
        SelectTab = function(name) selectTab(name) end,
        RealignTabs = realignTabs,
        Unload = doUnload,
        ScreenGui = screenGui,           -- exposed for external cleanup tracking
        ApplyTheme = applyTheme,
        ApplyFont = applyFont,
        ThemePresets = PRESETS,
        ThemeColors = THEME,
        GetFont = function() return currentFontName end,
        GetTheme = function() return currentThemeName end,
        AccentRGBInputs = function(rInput, lInput, dInput)
            -- Allows registering textboxes to update custom colors
            local function handleCustomColorChange()
                if currentThemeName ~= "Custom" then return end
                
                local function parseColor(str, fallback)
                    local r, g, b = str:match("(%d+),%s*(%d+),%s*(%d+)")
                    if r and g and b then
                        return Color3.fromRGB(
                            math.clamp(tonumber(r), 0, 255),
                            math.clamp(tonumber(g), 0, 255),
                            math.clamp(tonumber(b), 0, 255)
                        )
                    end
                    return fallback
                end
                
                local cAccent = parseColor(rInput.Text, PRESETS.Orange.ACCENT)
                local cLight = parseColor(lInput.Text, PRESETS.Orange.ACCENT_LIGHT)
                local cDark = parseColor(dInput.Text, PRESETS.Orange.ACCENT_DARK)
                
                PRESETS.Custom.ACCENT = cAccent
                PRESETS.Custom.ACCENT_LIGHT = cLight
                PRESETS.Custom.ACCENT_DARK = cDark
                
                applyTheme("Custom")
            end
            return handleCustomColorChange
        end
    }
end

return Library
