-- modules/mobile_controls.lua
-- MorningDrift UI Library: Mobile Action Buttons & Layout Module
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return function(Library, Window)
    local GenerateSafeName = (Window._I and Window._I.GenerateSafeName)
        or Window.GenerateSafeName
        or Library.GenerateSafeName
        or function(prefix)
            return (prefix or "MD") .. "_" .. tostring(math.random(100000, 999999))
        end
    local RegisterHUDScale = (Window._I and Window._I.RegisterHUDScale)
        or Window.RegisterHUDScale
        or Library.RegisterHUDScale
        or function(o) return o end
    local AddUIShadow = (Window._I and Window._I.AddUIShadow)
        or Window.AddUIShadow
        or Library.AddUIShadow
        or function() end
    local FontTabBtn = (Window._I and Window._I.FontTabBtn)
        or Window.FontTabBtn
        or Library.FontTabBtn
        or Window.FontTitle
        or Library.FontTitle
        or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    local PlayClickSFX = (Window._I and Window._I.PlayClickSFX)
        or Window.PlayClickSFX
        or (Library and Library.PlayClickSFX)
        or function() end
    local TrackConn = (Window._I and Window._I.TrackConn)
        or Window.TrackConn
        or (Library and Library.TrackConn)
        or function(c) return c end
    local GetHUDScale = (Window._I and Window._I.GetHUDScale)
        or Window.GetHUDScale
        or Library.GetHUDScale
        or function() return 1 end

    function Window:CreateMobileButton(arg1, arg2, arg3, arg4, arg5)
        local MobileUI = Window.MobileUI
        if not MobileUI then return end
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

        local text = config.Text or config.Title or config.Name or config[1] or ""
        local btnType = (config.Type or config.type or "Button"):lower()
        local isToggle = (btnType == "toggle")
        local initialToggleState = (config.Default == true or config.State == true or config.Value == true)
        local currentState = initialToggleState
        local callback = config.Callback or config.OnClick or config.OnToggle or config.callback or config[2]

        local iconAsset = config.Icon or config.Image or config.IconAsset or config.icon
        if iconAsset and (type(iconAsset) == "number" or tostring(iconAsset):match("^%d+$")) then
            iconAsset = "rbxassetid://" .. tostring(iconAsset)
        end

        local bgAssetOn = config.BackgroundImageOn or config.OnImage or config.BackgroundImage or config.Background or config.ImageBackground or config.bgImage
        local bgAssetOff = config.BackgroundImageOff or config.OffImage or config.BackgroundImage or config.Background or config.ImageBackground or config.bgImage
        if type(config.BackgroundImage) == "table" then
            bgAssetOn = config.BackgroundImage.On or config.BackgroundImage[1] or bgAssetOn
            bgAssetOff = config.BackgroundImage.Off or config.BackgroundImage[2] or bgAssetOff
        end

        local shape = (config.Shape or config.shape or (text == "" and iconAsset and "Circle") or "Pill"):lower()
        local isDraggable = config.Draggable ~= false
        local followTheme = config.FollowTheme ~= false
        local customBgColor = config.Color or config.BackgroundColor or config.ButtonBG
        local customTextColor = config.TextColor or config.textColor
        local customImageColor = config.ImageColor or config.imageColor
        local customStrokeColor = config.StrokeColor or config.strokeColor

        local btnCount = #Window.RegisteredMobileButtons
        local defaultSize = config.Size or UDim2.new(0, 64, 0, 64)

        local defaultPos = config.Position
        if not defaultPos then
            local layout = Window.MobileButtonsLayout or {}
            local baseOffsetX = layout.BaseOffsetX or 80
            local baseOffsetY = layout.BaseOffsetY or 80
            local spacingY = layout.SpacingY or 74
            local itemWidth = (defaultSize.X.Offset > 0) and defaultSize.X.Offset or 64
            local spacingX = layout.SpacingX or (itemWidth + 14)
            local maxPerCol = layout.MaxButtonsPerColumn or 6

            local rowInCol = btnCount % maxPerCol
            local colIndex = math.floor(btnCount / maxPerCol)

            local offX = -(baseOffsetX + (colIndex * spacingX))
            local offY = -(baseOffsetY + (rowInCol * spacingY))
            defaultPos = UDim2.new(1, offX, 1, offY)
        end

        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = GenerateSafeName("Btn")
        BtnFrame.Size = defaultSize
        BtnFrame.Position = defaultPos
        BtnFrame.BorderSizePixel = 0
        BtnFrame.ClipsDescendants = false
        BtnFrame.ZIndex = 100
        BtnFrame.Parent = MobileUI
        RegisterHUDScale(BtnFrame)

        local Corner = Instance.new("UICorner")
        Corner.Name = "BtnCorner"
        if config.CornerRadius then
            Corner.CornerRadius = UDim.new(0, config.CornerRadius)
        else
            Corner.CornerRadius = UDim.new(1, 0)
        end
        Corner.Parent = BtnFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "BtnStroke"
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Thickness = 1.2
        Stroke.Parent = BtnFrame

        AddUIShadow(BtnFrame, 14, 0.45)

        local BgImageLabel = nil
        local function UpdateBgImage()
            local targetImg = isToggle and (currentState and (bgAssetOn or bgAssetOff) or (bgAssetOff or bgAssetOn)) or (bgAssetOn or bgAssetOff)
            if targetImg and targetImg ~= "" then
                if type(targetImg) == "number" or tostring(targetImg):match("^%d+$") then
                    targetImg = "rbxassetid://" .. tostring(targetImg)
                end
                if not BgImageLabel then
                    BgImageLabel = Instance.new("ImageLabel")
                    BgImageLabel.Name = "BgImage"
                    BgImageLabel.Size = UDim2.new(1, 0, 1, 0)
                    BgImageLabel.Position = UDim2.new(0, 0, 0, 0)
                    BgImageLabel.BackgroundTransparency = 1
                    BgImageLabel.ImageTransparency = config.BgTransparency or 0.2
                    BgImageLabel.ScaleType = Enum.ScaleType.Crop
                    BgImageLabel.ZIndex = 101
                    BgImageLabel.Parent = BtnFrame

                    local BgCorner = Corner:Clone()
                    BgCorner.Parent = BgImageLabel
                end
                BgImageLabel.Image = targetImg
                BgImageLabel.Visible = true
            elseif BgImageLabel then
                BgImageLabel.Visible = false
            end
        end

        if bgAssetOn or bgAssetOff then
            UpdateBgImage()
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

        local IconImage = nil
        if iconAsset and iconAsset ~= "" then
            IconImage = Instance.new("ImageLabel")
            IconImage.Name = "BtnIcon"
            IconImage.BackgroundTransparency = 1
            IconImage.Image = iconAsset
            IconImage.ZIndex = 103
            IconImage.Parent = BtnFrame

            if text ~= "" then
                IconImage.Size = UDim2.new(0, 18, 0, 18)
                IconImage.Position = UDim2.new(0.5, -9, 0, 4)
            else
                IconImage.Size = UDim2.new(0, 24, 0, 24)
                IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
                IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
            end
        end

        local TextLabel = nil
        if text ~= "" then
            TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "BtnText"
            TextLabel.BackgroundTransparency = 1
            TextLabel.FontFace = FontTabBtn
            TextLabel.Text = text
            TextLabel.TextScaled = false
            TextLabel.TextSize = config.TextSize or 11
            TextLabel.TextWrapped = true
            TextLabel.ZIndex = 103
            TextLabel.Parent = BtnFrame

            if IconImage then
                TextLabel.Size = UDim2.new(1, -4, 0, 14)
                TextLabel.Position = UDim2.new(0, 2, 1, -16)
                TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                TextLabel.TextYAlignment = Enum.TextYAlignment.Center
            else
                TextLabel.Size = UDim2.new(1, -4, 1, 0)
                TextLabel.Position = UDim2.new(0, 2, 0, 0)
                TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                TextLabel.TextYAlignment = Enum.TextYAlignment.Center
            end
        end

        local Hitbox = Instance.new("TextButton")
        Hitbox.Name = "Hitbox"
        Hitbox.Size = UDim2.new(1, 0, 1, 0)
        Hitbox.Position = UDim2.new(0, 0, 0, 0)
        Hitbox.BackgroundTransparency = 1
        Hitbox.Text = ""
        Hitbox.ZIndex = 110
        Hitbox.Parent = BtnFrame

        local isVisibleInitial = (config.Visible ~= false)
        BtnFrame.Visible = isVisibleInitial

        local ButtonObj = {
            Frame = BtnFrame,
            Hitbox = Hitbox,
            TextLabel = TextLabel,
            IconImage = IconImage,
            BackgroundImage = BgImageLabel,
            Stroke = Stroke,
            Corner = Corner,
            ToggleIndicator = ToggleIndicator,
            Type = btnType,
            IsToggle = isToggle,
            IsLocked = (config.Locked == true),
            IsDraggable = isDraggable,
            State = currentState,
            Visible = isVisibleInitial,
            SaveKey = config.SaveKey or config.saveKey or (text ~= "" and text) or nil,
            FollowTheme = followTheme,
            CustomBgColor = customBgColor,
            CustomTextColor = customTextColor,
            CustomImageColor = customImageColor,
            CustomStrokeColor = customStrokeColor
        }

        local function RefreshAppearance(theme)
            theme = theme or Window.CurrentTheme or Library.ThemePresets.Dark
            if isToggle then
                if currentState then
                    BtnFrame.BackgroundColor3 = customBgColor or theme.ButtonBG
                    BtnFrame.BackgroundTransparency = 0.05
                    Stroke.Color = customStrokeColor or theme.Divider or Color3.fromRGB(255, 255, 255)
                    Stroke.Thickness = 1.8
                    if ToggleIndicator then
                        ToggleIndicator.BackgroundTransparency = 0
                        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 120)
                    end
                    if TextLabel then
                        TextLabel.TextColor3 = customTextColor or theme.Text
                    end
                    if IconImage then
                        IconImage.ImageColor3 = customImageColor or theme.Text
                    end
                else
                    BtnFrame.BackgroundColor3 = customBgColor or theme.CardBG
                    BtnFrame.BackgroundTransparency = 0.25
                    Stroke.Color = customStrokeColor or (theme.CardBG == Color3.fromRGB(255, 255, 255) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(70, 75, 88))
                    Stroke.Thickness = 1.2
                    if ToggleIndicator then
                        ToggleIndicator.BackgroundTransparency = 1
                    end
                    if TextLabel then
                        TextLabel.TextColor3 = customTextColor or theme.SubText
                    end
                    if IconImage then
                        IconImage.ImageColor3 = customImageColor or theme.SubText
                    end
                end
            else
                BtnFrame.BackgroundColor3 = customBgColor or theme.ButtonBG
                BtnFrame.BackgroundTransparency = 0.1
                Stroke.Color = customStrokeColor or (theme.CardBG == Color3.fromRGB(255, 255, 255) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(255, 255, 255))
                Stroke.Thickness = 1.2
                if TextLabel then
                    TextLabel.TextColor3 = customTextColor or theme.Text
                end
                if IconImage then
                    IconImage.ImageColor3 = customImageColor or theme.Text
                end
            end
        end

        ButtonObj.RefreshTheme = RefreshAppearance
        RefreshAppearance(Window.CurrentTheme)

        local function PlayBounceAnim()
            local originalSize = BtnFrame.Size
            local targetSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.92, originalSize.Y.Scale, originalSize.Y.Offset * 0.92)
            TweenService:Create(BtnFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            task.delay(0.08, function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize}):Play()
            end)
        end

        local lastTriggerTime = 0
        local function TriggerAction()
            if (os.clock() - lastTriggerTime) < 0.22 then return end
            lastTriggerTime = os.clock()
            PlayClickSFX()
            PlayBounceAnim()
            if isToggle then
                currentState = not currentState
                ButtonObj.State = currentState
                RefreshAppearance(Window.CurrentTheme)
                UpdateBgImage()
                if callback then
                    pcall(callback, currentState, ButtonObj)
                end
            else
                if callback then
                    pcall(callback, ButtonObj)
                end
            end
        end

        local creationTime = os.clock()
        local isPressed = false
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local hasMoved = false
        local pressStartTime = 0

        TrackConn(Hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not BtnFrame.Visible then return end
                isPressed = true
                pressStartTime = os.clock()
                hasMoved = false
                if not ButtonObj.IsDraggable or Window.MobileButtonsLocked or ButtonObj.IsLocked then
                    dragging = false
                    return
                end
                dragging = true
                dragStart = input.Position
                startPos = BtnFrame.Position
            end
        end))

        TrackConn(UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if not BtnFrame.Visible then
                    dragging = false
                    return
                end
                if not ButtonObj.IsDraggable or Window.MobileButtonsLocked or ButtonObj.IsLocked then return end
                if dragging and dragStart and startPos then
                    local scale = GetHUDScale()
                    local deltaX = (input.Position.X - dragStart.X) / scale
                    local deltaY = (input.Position.Y - dragStart.Y) / scale
                    if math.abs(input.Position.X - dragStart.X) > 8 or math.abs(input.Position.Y - dragStart.Y) > 8 then
                        hasMoved = true
                    end
                    if hasMoved then
                        BtnFrame.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + deltaX,
                            startPos.Y.Scale,
                            startPos.Y.Offset + deltaY
                        )
                    end
                end
            end
        end))

        TrackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                task.delay(0.05, function()
                    hasMoved = false
                    isPressed = false
                    pressStartTime = 0
                end)
            end
        end))

        TrackConn(Hitbox.Activated:Connect(function()
            if not BtnFrame.Visible then return end
            if (os.clock() - creationTime) < 1.0 then return end
            if not isPressed then return end
            isPressed = false
            if not hasMoved then
                TriggerAction()
            end
        end))

        function ButtonObj:SetText(newText)
            newText = tostring(newText or "")
            if TextLabel then
                TextLabel.Text = newText
            elseif newText ~= "" then
                TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "BtnText"
                TextLabel.BackgroundTransparency = 1
                TextLabel.FontFace = FontTabBtn
                TextLabel.Text = newText
                TextLabel.TextScaled = false
                TextLabel.TextSize = config.TextSize or 11
                TextLabel.TextWrapped = true
                TextLabel.Size = UDim2.new(1, -4, 1, 0)
                TextLabel.Position = UDim2.new(0, 2, 0, 0)
                TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                TextLabel.TextYAlignment = Enum.TextYAlignment.Center
                TextLabel.ZIndex = 103
                TextLabel.Parent = BtnFrame
                ButtonObj.TextLabel = TextLabel
                RefreshAppearance(Window.CurrentTheme)
            end
        end

        function ButtonObj:SetIcon(newIcon)
            if newIcon and (type(newIcon) == "number" or tostring(newIcon):match("^%d+$")) then
                newIcon = "rbxassetid://" .. tostring(newIcon)
            end
            if IconImage then
                if newIcon and newIcon ~= "" then
                    IconImage.Image = newIcon
                    IconImage.Visible = true
                else
                    IconImage.Visible = false
                end
            elseif newIcon and newIcon ~= "" then
                IconImage = Instance.new("ImageLabel")
                IconImage.Name = "BtnIcon"
                IconImage.BackgroundTransparency = 1
                IconImage.Image = newIcon
                IconImage.ZIndex = 103
                IconImage.Size = UDim2.new(0, 24, 0, 24)
                IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
                IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
                IconImage.Parent = BtnFrame
                ButtonObj.IconImage = IconImage
                RefreshAppearance(Window.CurrentTheme)
            end
        end

        function ButtonObj:SetBackgroundImage(onImg, offImg)
            bgAssetOn = onImg
            bgAssetOff = offImg or onImg
            UpdateBgImage()
        end
        ButtonObj.SetToggleImages = ButtonObj.SetBackgroundImage

        function ButtonObj:SetState(newState, triggerCb)
            if not isToggle then return end
            currentState = (newState == true)
            ButtonObj.State = currentState
            RefreshAppearance(Window.CurrentTheme)
            UpdateBgImage()
            if triggerCb and callback then
                pcall(callback, currentState, ButtonObj)
            end
        end

        function ButtonObj:GetState()
            return currentState
        end

        function ButtonObj:SetVisible(isVisible)
            local vis = (isVisible ~= false)
            BtnFrame.Visible = vis
            ButtonObj.Visible = vis
            Hitbox.Active = vis
            if not vis then
                dragging = false
            end
        end

        function ButtonObj:GetVisible()
            return BtnFrame.Visible == true
        end

        function ButtonObj:SetEnabled(isEnabled)
            local en = (isEnabled ~= false)
            Hitbox.Active = en
            BtnFrame.BackgroundTransparency = en and (isToggle and (currentState and 0.05 or 0.25) or 0.1) or 0.6
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

        ButtonObj.WithCallback = function(self, fn)
            self:SetCallback(fn)
            return self
        end
        ButtonObj.WithState = function(self, st, triggerCb)
            self:SetState(st, triggerCb)
            return self
        end
        ButtonObj.WithVisible = function(self, vis)
            self:SetVisible(vis)
            return self
        end
        ButtonObj.WithLocked = function(self, locked)
            self:SetLocked(locked)
            return self
        end
        ButtonObj.WithDraggable = function(self, drag)
            self:SetDraggable(drag)
            return self
        end
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
            if key and key ~= "" then
                self.SaveKey = key
            end
            return self
        end

        function ButtonObj:Destroy()
            for idx, b in ipairs(Window.RegisteredMobileButtons) do
                if b == ButtonObj then
                    table.remove(Window.RegisteredMobileButtons, idx)
                    break
                end
            end
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


end
