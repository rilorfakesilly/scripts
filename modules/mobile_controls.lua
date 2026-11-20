-- modules/mobile_controls.lua
-- MorningDrift UI Library: Mobile Action Buttons & Layout Module

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local DRAG_THRESHOLD = 8
local TRIGGER_COOLDOWN = 0.22
local ACTIVATE_GRACE = 1.0

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[MobileButton] callback error: " .. tostring(err))
    end
end

local function toAsset(v)
    if v == nil or v == "" then return v end
    if type(v) == "number" or tostring(v):match("^%d+$") then
        return "rbxassetid://" .. tostring(v)
    end
    return v
end

return function(Library, Window)
    local function resolve(key, fallback)
        return (Window._I and Window._I[key]) or Window[key] or (Library and Library[key]) or fallback
    end

    -- HUD scaling is captured at load, exactly as before: buttons only get a UIScale
    -- when these helpers already exist at that point.
    local RegisterHUDScale = resolve("RegisterHUDScale", function(o) return o end)

    -- Everything below is resolved when used, because the main lib defines some of it
    -- after modules are loaded.
    local function GenerateSafeName(prefix)
        local fn = resolve("GenerateSafeName", nil)
        if fn then return fn(prefix) end
        return (prefix or "MD") .. "_" .. tostring(math.random(100000, 999999))
    end

    local function AddUIShadow(...)
        local fn = resolve("AddUIShadow", nil)
        if fn then return fn(...) end
    end

    local function PlayClickSFX()
        local fn = resolve("PlayClickSFX", nil)
        if fn then fn() end
    end

    local function TrackConn(c)
        local fn = resolve("TrackConn", nil)
        return fn and fn(c) or c
    end

    local function GetFont()
        return resolve("FontTabBtn", nil) or resolve("FontTitle", nil)
            or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    end

    function Window:CreateMobileButton(arg1, arg2, arg3, arg4, arg5)
        local MobileUI = Window.MobileUI
        if not MobileUI then return end
        Window.RegisteredMobileButtons = Window.RegisteredMobileButtons or {}

        local config = {}
        if type(arg1) == "table" then
            config = arg1
        else
            config.Text = arg1
            config.Callback = arg2
            config.Type = arg3 or "Button"
            config.Icon = arg4
            config.Position = arg5
        end

        local text = tostring(config.Text or config.Title or config.Name or config[1] or "")
        local btnType = tostring(config.Type or config.type or "Button"):lower()
        local isToggle = (btnType == "toggle")
        local initialToggleState = (config.Default == true or config.State == true or config.Value == true)
        local currentState = initialToggleState
        local callback = config.Callback or config.OnClick or config.OnToggle or config.callback or config[2]

        local iconAsset = toAsset(config.Icon or config.Image or config.IconAsset or config.icon)

        local bgAssetOn = config.BackgroundImageOn or config.OnImage or config.BackgroundImage or config.Background or config.ImageBackground or config.bgImage
        local bgAssetOff = config.BackgroundImageOff or config.OffImage or config.BackgroundImage or config.Background or config.ImageBackground or config.bgImage
        if type(config.BackgroundImage) == "table" then
            bgAssetOn = config.BackgroundImage.On or config.BackgroundImage[1] or bgAssetOn
            bgAssetOff = config.BackgroundImage.Off or config.BackgroundImage[2] or bgAssetOff
        end

        local shape = tostring(config.Shape or config.shape or (text == "" and iconAsset and "Circle") or "Pill"):lower()
        local customBgColor = config.Color or config.BackgroundColor or config.ButtonBG
        local customTextColor = config.TextColor or config.textColor
        local customImageColor = config.ImageColor or config.imageColor
        local customStrokeColor = config.StrokeColor or config.strokeColor

        local baseSize = config.Size or UDim2.new(0, 64, 0, 64)

        -- Default position: stack in columns from the bottom-right corner.
        local function ComputeDefaultPosition(index)
            local layout = Window.MobileButtonsLayout or {}
            local baseOffsetX = layout.BaseOffsetX or 80
            local baseOffsetY = layout.BaseOffsetY or 80
            local spacingY = layout.SpacingY or 74
            local itemWidth = (baseSize.X.Offset > 0) and baseSize.X.Offset or 64
            local spacingX = layout.SpacingX or (itemWidth + 14)
            local maxPerCol = math.max(1, layout.MaxButtonsPerColumn or 6)

            local rowInCol = index % maxPerCol
            local colIndex = math.floor(index / maxPerCol)
            return UDim2.new(1, -(baseOffsetX + colIndex * spacingX), 1, -(baseOffsetY + rowInCol * spacingY))
        end

        local defaultPos = config.Position or ComputeDefaultPosition(#Window.RegisteredMobileButtons)

        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = GenerateSafeName("Btn")
        BtnFrame.Size = baseSize
        BtnFrame.Position = defaultPos
        BtnFrame.BorderSizePixel = 0
        BtnFrame.ClipsDescendants = false
        BtnFrame.ZIndex = 100
        BtnFrame.Parent = MobileUI
        RegisterHUDScale(BtnFrame)

        local Corner = Instance.new("UICorner")
        Corner.Name = "BtnCorner"
        Corner.CornerRadius = config.CornerRadius and UDim.new(0, config.CornerRadius) or UDim.new(1, 0)
        Corner.Parent = BtnFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "BtnStroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Thickness = 1.2
        Stroke.Parent = BtnFrame

        AddUIShadow(BtnFrame, 14, 0.45)

        -- Connections owned by this button, disconnected on Destroy.
        local conns = {}
        local function bind(signal, fn)
            local c = signal:Connect(fn)
            TrackConn(c)
            table.insert(conns, c)
            return c
        end

        local function GetScale()
            local sc = BtnFrame:FindFirstChildOfClass("UIScale")
            return (sc and sc.Scale > 0) and sc.Scale or 1
        end

        ---------------------------------------------------------------------
        -- Content
        ---------------------------------------------------------------------

        local BgImageLabel = nil
        local function UpdateBgImage()
            local targetImg
            if isToggle then
                targetImg = currentState and (bgAssetOn or bgAssetOff) or (bgAssetOff or bgAssetOn)
            else
                targetImg = bgAssetOn or bgAssetOff
            end
            targetImg = toAsset(targetImg)
            if targetImg and targetImg ~= "" then
                if not BgImageLabel then
                    BgImageLabel = Instance.new("ImageLabel")
                    BgImageLabel.Name = "BgImage"
                    BgImageLabel.Size = UDim2.new(1, 0, 1, 0)
                    BgImageLabel.BackgroundTransparency = 1
                    BgImageLabel.ImageTransparency = config.BgTransparency or 0.2
                    BgImageLabel.ScaleType = Enum.ScaleType.Crop
                    BgImageLabel.ZIndex = 101
                    BgImageLabel.Parent = BtnFrame
                    Corner:Clone().Parent = BgImageLabel
                end
                BgImageLabel.Image = targetImg
                BgImageLabel.Visible = true
            elseif BgImageLabel then
                BgImageLabel.Visible = false
            end
        end

        local ToggleIndicator = nil
        if isToggle then
            ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "ToggleIndicator"
            ToggleIndicator.Size = UDim2.new(0, 6, 0, 6)
            ToggleIndicator.Position = UDim2.new(1, -12, 0, 6)
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 120)
            ToggleIndicator.BackgroundTransparency = initialToggleState and 0 or 1
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.ZIndex = 105
            ToggleIndicator.Parent = BtnFrame

            local IndCorner = Instance.new("UICorner")
            IndCorner.CornerRadius = UDim.new(1, 0)
            IndCorner.Parent = ToggleIndicator
        end

        local IconImage, TextLabel = nil, nil

        -- Positions icon and text for whichever of the two are present.
        local function Layout()
            local hasText = TextLabel and TextLabel.Text ~= ""
            local hasIcon = IconImage and IconImage.Visible
            if IconImage then
                if hasText then
                    IconImage.AnchorPoint = Vector2.new(0, 0)
                    IconImage.Size = UDim2.new(0, 18, 0, 18)
                    IconImage.Position = UDim2.new(0.5, -9, 0, 4)
                else
                    IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
                    IconImage.Size = UDim2.new(0, 24, 0, 24)
                    IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
                end
            end
            if TextLabel then
                if hasIcon then
                    TextLabel.Size = UDim2.new(1, -4, 0, 14)
                    TextLabel.Position = UDim2.new(0, 2, 1, -16)
                else
                    TextLabel.Size = UDim2.new(1, -4, 1, 0)
                    TextLabel.Position = UDim2.new(0, 2, 0, 0)
                end
            end
        end

        local function CreateIcon(asset)
            IconImage = Instance.new("ImageLabel")
            IconImage.Name = "BtnIcon"
            IconImage.BackgroundTransparency = 1
            IconImage.Image = asset
            IconImage.ZIndex = 103
            IconImage.Parent = BtnFrame
        end

        local function CreateText(str)
            TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "BtnText"
            TextLabel.BackgroundTransparency = 1
            TextLabel.FontFace = GetFont()
            TextLabel.Text = str
            TextLabel.TextScaled = false
            TextLabel.TextSize = config.TextSize or 11
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Center
            TextLabel.TextYAlignment = Enum.TextYAlignment.Center
            TextLabel.ZIndex = 103
            TextLabel.Parent = BtnFrame
        end

        if iconAsset and iconAsset ~= "" then CreateIcon(iconAsset) end
        if text ~= "" then CreateText(text) end
        Layout()

        local Hitbox = Instance.new("TextButton")
        Hitbox.Name = "Hitbox"
        Hitbox.Size = UDim2.new(1, 0, 1, 0)
        Hitbox.BackgroundTransparency = 1
        Hitbox.Text = ""
        Hitbox.ZIndex = 110
        Hitbox.Parent = BtnFrame

        local isVisibleInitial = (config.Visible ~= false)
        BtnFrame.Visible = isVisibleInitial

        local enabled = true

        local ButtonObj = {
            Frame = BtnFrame,
            Hitbox = Hitbox,
            TextLabel = TextLabel,
            IconImage = IconImage,
            Stroke = Stroke,
            Corner = Corner,
            ToggleIndicator = ToggleIndicator,
            Type = btnType,
            Shape = shape,
            IsToggle = isToggle,
            IsLocked = (config.Locked == true),
            IsDraggable = (config.Draggable ~= false),
            State = currentState,
            Visible = isVisibleInitial,
            DefaultPosition = defaultPos,
            SaveKey = config.SaveKey or config.saveKey or (text ~= "" and text) or nil,
            FollowTheme = (config.FollowTheme ~= false),
            CustomBgColor = customBgColor,
            CustomTextColor = customTextColor,
            CustomImageColor = customImageColor,
            CustomStrokeColor = customStrokeColor,
        }
        ButtonObj.BackgroundImage = BgImageLabel

        ---------------------------------------------------------------------
        -- Appearance
        ---------------------------------------------------------------------

        local function RefreshAppearance(theme)
            theme = theme or Window.CurrentTheme or Library.ThemePresets.Dark
            local lightCard = (theme.CardBG == Color3.fromRGB(255, 255, 255))
            local fg, imgCol

            if isToggle and currentState then
                BtnFrame.BackgroundColor3 = customBgColor or theme.ButtonBG
                BtnFrame.BackgroundTransparency = 0.05
                Stroke.Color = customStrokeColor or theme.Divider or Color3.fromRGB(255, 255, 255)
                Stroke.Thickness = 1.8
                fg = customTextColor or theme.Text
                imgCol = customImageColor or theme.Text
            elseif isToggle then
                BtnFrame.BackgroundColor3 = customBgColor or theme.CardBG
                BtnFrame.BackgroundTransparency = 0.25
                Stroke.Color = customStrokeColor or (lightCard and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(70, 75, 88))
                Stroke.Thickness = 1.2
                fg = customTextColor or theme.SubText
                imgCol = customImageColor or theme.SubText
            else
                BtnFrame.BackgroundColor3 = customBgColor or theme.ButtonBG
                BtnFrame.BackgroundTransparency = 0.1
                Stroke.Color = customStrokeColor or (lightCard and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(255, 255, 255))
                Stroke.Thickness = 1.2
                fg = customTextColor or theme.Text
                imgCol = customImageColor or theme.Text
            end

            if ToggleIndicator then
                ToggleIndicator.BackgroundTransparency = currentState and 0 or 1
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 120)
            end
            if TextLabel then TextLabel.TextColor3 = fg end
            if IconImage then IconImage.ImageColor3 = imgCol end

            if not enabled then
                BtnFrame.BackgroundTransparency = 0.6
            end
        end

        ButtonObj.RefreshTheme = RefreshAppearance
        RefreshAppearance(Window.CurrentTheme)
        UpdateBgImage()
        ButtonObj.BackgroundImage = BgImageLabel

        local bounceTween = nil
        local function PlayBounceAnim()
            if bounceTween then bounceTween:Cancel() end
            local shrunk = UDim2.new(baseSize.X.Scale, baseSize.X.Offset * 0.92, baseSize.Y.Scale, baseSize.Y.Offset * 0.92)
            BtnFrame.Size = baseSize
            bounceTween = TweenService:Create(BtnFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = shrunk })
            bounceTween:Play()
            task.delay(0.08, function()
                if not BtnFrame.Parent then return end
                bounceTween = TweenService:Create(BtnFrame, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = baseSize })
                bounceTween:Play()
            end)
        end

        ---------------------------------------------------------------------
        -- Input
        ---------------------------------------------------------------------

        local lastTriggerTime = 0
        local function TriggerAction()
            if not enabled then return end
            if (os.clock() - lastTriggerTime) < TRIGGER_COOLDOWN then return end
            lastTriggerTime = os.clock()
            PlayClickSFX()
            PlayBounceAnim()
            if isToggle then
                currentState = not currentState
                ButtonObj.State = currentState
                RefreshAppearance(Window.CurrentTheme)
                UpdateBgImage()
                safeCall(callback, currentState, ButtonObj)
            else
                safeCall(callback, ButtonObj)
            end
        end

        local creationTime = os.clock()
        local isPressed = false
        local dragging = false
        local dragStart, startPos = nil, nil
        local dragInput = nil
        local hasMoved = false

        local function CanDrag()
            return ButtonObj.IsDraggable and not Window.MobileButtonsLocked and not ButtonObj.IsLocked
        end

        local function isPointer(input)
            local t = input.UserInputType
            return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
        end

        bind(Hitbox.InputBegan, function(input)
            if not isPointer(input) or not BtnFrame.Visible then return end
            isPressed = true
            hasMoved = false
            dragInput = input
            if not CanDrag() then
                dragging = false
                return
            end
            dragging = true
            dragStart = input.Position
            startPos = BtnFrame.Position
        end)

        bind(UserInputService.InputChanged, function(input)
            if not dragging then return end
            local t = input.UserInputType
            if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
            -- Ignore other fingers while this one is dragging.
            if t == Enum.UserInputType.Touch and dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then
                return
            end
            if not BtnFrame.Visible then
                dragging = false
                return
            end
            if not CanDrag() or not dragStart or not startPos then return end

            local dx = input.Position.X - dragStart.X
            local dy = input.Position.Y - dragStart.Y
            if math.abs(dx) > DRAG_THRESHOLD or math.abs(dy) > DRAG_THRESHOLD then
                hasMoved = true
            end
            if hasMoved then
                local scale = GetScale()
                BtnFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + dx / scale,
                    startPos.Y.Scale, startPos.Y.Offset + dy / scale
                )
            end
        end)

        bind(UserInputService.InputEnded, function(input)
            if not isPointer(input) then return end
            if not (isPressed or dragging) then return end
            if input.UserInputType == Enum.UserInputType.Touch and dragInput
                and dragInput.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then
                return
            end
            dragging = false
            dragInput = nil
            task.delay(0.05, function()
                hasMoved = false
                isPressed = false
            end)
        end)

        bind(Hitbox.Activated, function()
            if not BtnFrame.Visible then return end
            if (os.clock() - creationTime) < ACTIVATE_GRACE then return end
            if not isPressed then return end
            isPressed = false
            if not hasMoved then
                TriggerAction()
            end
        end)

        ---------------------------------------------------------------------
        -- API
        ---------------------------------------------------------------------

        function ButtonObj:SetText(newText)
            newText = tostring(newText or "")
            if TextLabel then
                TextLabel.Text = newText
            elseif newText ~= "" then
                CreateText(newText)
                ButtonObj.TextLabel = TextLabel
                RefreshAppearance(Window.CurrentTheme)
            end
            Layout()
        end

        function ButtonObj:SetIcon(newIcon)
            newIcon = toAsset(newIcon)
            if IconImage then
                if newIcon and newIcon ~= "" then
                    IconImage.Image = newIcon
                    IconImage.Visible = true
                else
                    IconImage.Visible = false
                end
            elseif newIcon and newIcon ~= "" then
                CreateIcon(newIcon)
                ButtonObj.IconImage = IconImage
                RefreshAppearance(Window.CurrentTheme)
            end
            Layout()
        end

        function ButtonObj:SetBackgroundImage(onImg, offImg)
            bgAssetOn = onImg
            bgAssetOff = offImg or onImg
            UpdateBgImage()
            ButtonObj.BackgroundImage = BgImageLabel
        end
        ButtonObj.SetToggleImages = ButtonObj.SetBackgroundImage

        function ButtonObj:SetState(newState, triggerCb)
            if not isToggle then return end
            currentState = (newState == true)
            ButtonObj.State = currentState
            RefreshAppearance(Window.CurrentTheme)
            UpdateBgImage()
            if triggerCb then safeCall(callback, currentState, ButtonObj) end
        end

        function ButtonObj:GetState()
            return currentState
        end

        function ButtonObj:SetVisible(isVisible)
            local vis = (isVisible ~= false)
            BtnFrame.Visible = vis
            ButtonObj.Visible = vis
            Hitbox.Active = vis and enabled
            if not vis then dragging = false end
        end

        function ButtonObj:GetVisible()
            return BtnFrame.Visible == true
        end

        function ButtonObj:SetEnabled(isEnabled)
            enabled = (isEnabled ~= false)
            Hitbox.Active = enabled and BtnFrame.Visible
            RefreshAppearance(Window.CurrentTheme)
        end

        function ButtonObj:SetLocked(locked)
            ButtonObj.IsLocked = (locked == true)
        end

        function ButtonObj:SetDraggable(draggable)
            ButtonObj.IsDraggable = (draggable ~= false)
        end

        function ButtonObj:SetCallback(fn)
            callback = fn
        end

        function ButtonObj:ResetPosition()
            BtnFrame.Position = ButtonObj.DefaultPosition
        end

        ButtonObj.WithCallback = function(self, fn) self:SetCallback(fn) return self end
        ButtonObj.WithState = function(self, st, triggerCb) self:SetState(st, triggerCb) return self end
        ButtonObj.WithVisible = function(self, vis) self:SetVisible(vis) return self end
        ButtonObj.WithLocked = function(self, locked) self:SetLocked(locked) return self end
        ButtonObj.WithDraggable = function(self, drag) self:SetDraggable(drag) return self end
        ButtonObj.WithPosition = function(self, pos)
            if pos then BtnFrame.Position = pos end
            return self
        end
        ButtonObj.WithTooltip = function(self, tt)
            if Window.AttachTooltip and BtnFrame then
                Window:AttachTooltip(BtnFrame, tt)
            end
            return self
        end
        ButtonObj.WithSaveKey = function(self, key)
            if key and key ~= "" then self.SaveKey = key end
            return self
        end

        function ButtonObj:Destroy()
            for idx, b in ipairs(Window.RegisteredMobileButtons) do
                if b == ButtonObj then
                    table.remove(Window.RegisteredMobileButtons, idx)
                    break
                end
            end
            for _, c in ipairs(conns) do
                pcall(function() c:Disconnect() end)
            end
            table.clear(conns)
            if bounceTween then bounceTween:Cancel() end
            if BtnFrame and BtnFrame.Parent then
                BtnFrame:Destroy()
            end
        end

        table.insert(Window.RegisteredMobileButtons, ButtonObj)
        return ButtonObj
    end
    Window.AddMobileButton = Window.CreateMobileButton

    function Window:ConfigureMobileLayout(options)
        if type(options) ~= "table" then return end
        Window.MobileButtonsLayout = Window.MobileButtonsLayout or {}
        for k, v in pairs(options) do
            Window.MobileButtonsLayout[k] = v
        end
    end
    Window.SetMobileButtonsLayout = Window.ConfigureMobileLayout

    function Window:SetMobileButtonsLocked(locked)
        Window.MobileButtonsLocked = (locked == true)
    end
    Window.LockMobileButtons = Window.SetMobileButtonsLocked

    function Window:GetMobileButtonsLocked()
        return Window.MobileButtonsLocked == true
    end

    -- Puts every button back where it was first placed.
    function Window:ResetMobileButtonPositions()
        for _, b in ipairs(Window.RegisteredMobileButtons or {}) do
            if b and b.ResetPosition then pcall(b.ResetPosition, b) end
        end
    end
end
