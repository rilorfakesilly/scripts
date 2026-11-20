-- modules/notifications.lua
-- MorningDrift UI Library: Notifications, Tooltips & Overlay Module

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local MAX_VISIBLE = 5
local MIN_DURATION = 0.5
local TOOLTIP_FADE = TweenInfo.new(0.15)
local SLIDE_IN = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SLIDE_OUT = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

-- Notifications whose titles match these still show while the UI is loading a config.
local LOADING_ALLOWED = {
    "config loaded", "loaded config", "tab config loaded", "config imported", "config error", "import error",
}

local function matchesAny(text, patterns)
    text = text:lower()
    for _, p in ipairs(patterns) do
        if text:find(p, 1, true) then return true end
    end
    return false
end

return function(Library, Window)
    local function resolve(key, fallback)
        return (Window._I and Window._I[key]) or Window[key] or (Library and Library[key]) or fallback
    end

    -- Resolved at call time: the main lib defines these after modules load.
    local function PlayNotifSFX()
        local fn = resolve("PlayNotifSFX", nil)
        if fn then fn() end
    end
    local function TrackConn(c)
        local fn = resolve("TrackConn", nil)
        return fn and fn(c) or c
    end

    ---------------------------------------------------------------------------
    -- Tooltips
    ---------------------------------------------------------------------------

    local tooltipContentMap = Window._TooltipContentMap or setmetatable({}, { __mode = "k" })
    Window._TooltipContentMap = tooltipContentMap

    local activeTooltipTarget = nil
    local tooltipTween = nil
    local hideToken = 0

    local function getTooltipComponents()
        local frame = Window.TooltipFrame
        local stroke = Window.TooltipStroke or (frame and frame:FindFirstChildWhichIsA("UIStroke", true))
        local text = Window.TooltipText or (frame and frame:FindFirstChildWhichIsA("TextLabel", true))
        return frame, stroke, Window.TooltipShadow, text
    end

    local function positionTooltip(frame, w, h)
        local mouse = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        local size = (w and h) and Vector2.new(w, h) or frame.AbsoluteSize
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)

        local x = mouse.X + 12
        local y = mouse.Y - inset.Y + 12
        if x + size.X > viewport.X - 4 then x = mouse.X - size.X - 12 end
        if y + size.Y > viewport.Y - inset.Y - 4 then y = mouse.Y - inset.Y - size.Y - 12 end
        frame.Position = UDim2.new(0, math.max(4, x), 0, math.max(4, y))
    end

    local function showTooltip(guiObject)
        local content = tooltipContentMap[guiObject]
        if not content or content == "" then return end

        local frame, stroke, shadow, label = getTooltipComponents()
        if not frame or not label then return end

        hideToken += 1
        activeTooltipTarget = guiObject

        local text = tostring(content)
        label.Text = text
        local bounds = TextService:GetTextSize(text, 12, Enum.Font.Montserrat, Vector2.new(300, 100))
        local tw = math.clamp(bounds.X + 20, 48, 320)
        local th = math.clamp(bounds.Y + 12, 24, 80)
        frame.Size = UDim2.new(0, tw, 0, th)

        local theme = Window.CurrentTheme
        label.TextColor3 = (theme and theme.Text) or Color3.fromRGB(240, 240, 245)
        frame.BackgroundColor3 = (theme and theme.CardBG) or Color3.fromRGB(24, 26, 34)
        if stroke then
            stroke.Color = (theme and theme.Divider) or Color3.fromRGB(65, 70, 88)
        end

        positionTooltip(frame, tw, th)
        frame.Visible = true

        if tooltipTween then tooltipTween:Cancel() end
        tooltipTween = TweenService:Create(frame, TOOLTIP_FADE, { BackgroundTransparency = 0.05 })
        tooltipTween:Play()
        if stroke then TweenService:Create(stroke, TOOLTIP_FADE, { Transparency = 0.2 }):Play() end
        TweenService:Create(label, TOOLTIP_FADE, { TextTransparency = 0 }):Play()
        if shadow then
            local intensity = Library.ShadowIntensity or (1 / 1.8)
            local trans = 1 - math.clamp(0.55 * intensity, 0, 1)
            TweenService:Create(shadow, TOOLTIP_FADE, { Transparency = trans }):Play()
        end
    end

    local function hideTooltip()
        activeTooltipTarget = nil
        local frame, stroke, shadow, label = getTooltipComponents()
        if not frame then return end

        if tooltipTween then tooltipTween:Cancel() end
        tooltipTween = TweenService:Create(frame, TOOLTIP_FADE, { BackgroundTransparency = 1 })
        tooltipTween:Play()
        if stroke then TweenService:Create(stroke, TOOLTIP_FADE, { Transparency = 1 }):Play() end
        if label then TweenService:Create(label, TOOLTIP_FADE, { TextTransparency = 1 }):Play() end
        if shadow then TweenService:Create(shadow, TOOLTIP_FADE, { Transparency = 1 }):Play() end

        hideToken += 1
        local token = hideToken
        task.delay(0.16, function()
            if token == hideToken and activeTooltipTarget == nil and frame.Parent then
                frame.Visible = false
            end
        end)
    end

    -- Attaches (or updates) a tooltip. Returns a function that removes it.
    function Window:AttachTooltip(guiObject, text)
        if typeof(guiObject) ~= "Instance" or not text or text == "" then return function() end end

        local alreadyAttached = tooltipContentMap[guiObject] ~= nil
        tooltipContentMap[guiObject] = text
        if alreadyAttached then
            if activeTooltipTarget == guiObject then showTooltip(guiObject) end
            return function() tooltipContentMap[guiObject] = nil end
        end

        TrackConn(guiObject.MouseEnter:Connect(function()
            showTooltip(guiObject)
        end))

        TrackConn(guiObject.MouseMoved:Connect(function()
            if activeTooltipTarget == guiObject and Window.TooltipFrame and Window.TooltipFrame.Visible then
                positionTooltip(Window.TooltipFrame)
            end
        end))

        TrackConn(guiObject.MouseLeave:Connect(function()
            if activeTooltipTarget == guiObject then hideTooltip() end
        end))

        TrackConn(guiObject.AncestryChanged:Connect(function(_, parent)
            if not parent and activeTooltipTarget == guiObject then hideTooltip() end
        end))

        return function()
            tooltipContentMap[guiObject] = nil
            if activeTooltipTarget == guiObject then hideTooltip() end
        end
    end

    ---------------------------------------------------------------------------
    -- Notifications
    ---------------------------------------------------------------------------

    -- Lays out the stack: newest at index 1, older ones step back and up.
    local function restack(list, scale, animTime)
        local baseX = math.round(-32 * scale)
        local baseY = math.round(2 * scale)
        local info = TweenInfo.new(animTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        for index, notif in ipairs(list) do
            if notif and notif.Parent then
                local z = math.max(1, 40 - (index - 1) * 8)
                notif.ZIndex = z
                for _, child in ipairs(notif:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        child.ZIndex = z + (child:GetAttribute("ZOff") or 1)
                    end
                end
                TweenService:Create(notif, info, {
                    Position = UDim2.new(
                        1, baseX + math.round((index - 1) * 14 * scale),
                        1, baseY + math.round((index - 1) * 4 * scale)
                    ),
                }):Play()
            end
        end
    end

    function Window:Notify(titleText, contentText, duration, notifType)
        if not Window.NotificationsEnabled then return nil end

        -- Accept either positional args or a single options table.
        if type(titleText) == "table" then
            local o = titleText
            notifType = o.Type or o.notifType or notifType
            duration = o.Duration or o.duration or duration
            contentText = o.Content or o.Text or o.Body or contentText
            titleText = o.Title or o.title or "MD Notification"
        end
        titleText = tostring(titleText or "MD Notification")
        contentText = tostring(contentText or "")
        duration = math.max(MIN_DURATION, tonumber(duration) or 3.5)

        if (Window._SuppressNotifications or Window._IsLoadingConfig) and not matchesAny(titleText, LOADING_ALLOWED) then
            return nil
        end

        local NotificationUI = Window.NotificationUI or Library.NotificationUI
        if not NotificationUI then return nil end

        PlayNotifSFX()

        local active = Window.ActiveNotifications or Library.ActiveNotifications
        if not active then
            active = {}
            Library.ActiveNotifications = active
        end
        Window.ActiveNotifications = active

        local RegisterHUDScale = resolve("RegisterHUDScale", function(o) return o end)
        local GetHUDScale = resolve("GetHUDScale", function() return 1 end)
        local ApplyCornerRadii = Window.ApplyCornerRadii or Library.ApplyCornerRadii or function() end
        local AddUIShadow = Window.AddUIShadow or Library.AddUIShadow or function() end
        local FontTitle = Window.FontTitle or Library.FontTitle
            or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        local FontRegular = Window.FontRegular or Library.FontRegular
            or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        local iconAsset = Window.IconAsset or Window.iconAsset or "rbxassetid://78209859871518"

        local scale = GetHUDScale()
        local theme = Window.CurrentTheme or Library.CurrentTheme or {}
        local textColor = theme.Text or Color3.fromRGB(240, 240, 245)
        local themeAccent = theme.ButtonBG or Color3.fromRGB(60, 100, 200)
        local accent = ({
            success = Color3.fromRGB(46, 204, 113),
            warning = Color3.fromRGB(241, 196, 15),
            error = Color3.fromRGB(231, 76, 60),
        })[string.lower(tostring(notifType or ""))] or themeAccent

        -- Enforce the visible cap by dismissing the oldest first.
        while #active >= MAX_VISIBLE do
            local oldest = table.remove(active)
            local signal = oldest and oldest.Parent and oldest:FindFirstChild("DismissSignal")
            if signal then signal:Fire() end
        end

        local container = Instance.new("Frame")
        container.Name = "NotifContainer"
        container.Size = UDim2.new(0, 290, 0, 105)
        container.AnchorPoint = Vector2.new(1, 1)
        container.Position = UDim2.new(1, math.round(350 * scale), 1, math.round(2 * scale))
        container.BackgroundTransparency = 1
        container.ZIndex = 35
        container.Parent = NotificationUI
        RegisterHUDScale(container)

        local top = Instance.new("Frame")
        top.Name = "TopFrame"
        top.Size = UDim2.new(1, 0, 0, 28)
        top.BackgroundColor3 = theme.TopBG or Color3.fromRGB(30, 30, 36)
        top.BackgroundTransparency = theme.TopTrans or 0
        top.BorderSizePixel = 0
        top.ZIndex = 31
        top.Parent = container

        local topCorner = Instance.new("UICorner")
        ApplyCornerRadii(topCorner, 8, 8, 0, 0)
        topCorner.Parent = top
        AddUIShadow(top, 20, 0.5)

        local titleFolder = Instance.new("Folder")
        titleFolder.Name = "Text"
        titleFolder.Parent = top

        local title = Instance.new("TextLabel")
        title.Name = "NotificationName"
        title.Size = UDim2.new(1, -20, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.FontFace = FontTitle
        title.Text = titleText
        title.TextColor3 = textColor
        title.TextSize = 14
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 32
        title.Parent = titleFolder

        local main = Instance.new("Frame")
        main.Name = "MainFrame"
        main.Size = UDim2.new(1, 0, 0, 77)
        main.Position = UDim2.new(0, 0, 0, 28)
        main.BackgroundColor3 = theme.MainBG or Color3.fromRGB(20, 20, 26)
        main.BackgroundTransparency = theme.MainTrans or 0
        main.BorderSizePixel = 0
        main.ZIndex = 31
        main.Parent = container

        local mainCorner = Instance.new("UICorner")
        ApplyCornerRadii(mainCorner, 0, 0, 0, 0)
        mainCorner.Parent = main
        AddUIShadow(main, 20, 0.5)

        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 48, 0, 48)
        icon.Position = UDim2.new(0, 12, 0.5, -24)
        icon.BackgroundTransparency = 1
        icon.Image = iconAsset
        icon.ImageColor3 = textColor
        icon.ZIndex = 32
        icon.Parent = main

        local body = Instance.new("TextLabel")
        body.Name = "NOTIFICATIONTXT"
        body.Size = UDim2.new(1, -86, 1, -12)
        body.Position = UDim2.new(0, 72, 0, 4)
        body.BackgroundTransparency = 1
        body.FontFace = FontRegular
        body.Text = contentText
        body.TextColor3 = textColor
        body.TextSize = 12
        body.TextWrapped = true
        body.TextTruncate = Enum.TextTruncate.AtEnd
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Center
        body.ZIndex = 32
        body.Parent = main

        local barBG = Instance.new("Frame")
        barBG.Name = "ProgressBarBG"
        barBG.Size = UDim2.new(1, 0, 0, 3)
        barBG.Position = UDim2.new(0, 0, 1, -3)
        barBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        barBG.BackgroundTransparency = 0.6
        barBG.BorderSizePixel = 0
        barBG.ZIndex = 33
        barBG.Parent = main

        local bar = Instance.new("Frame")
        bar.Name = "ProgressBar"
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.BackgroundColor3 = accent
        bar.BorderSizePixel = 0
        bar.ZIndex = 34
        bar.Parent = barBG

        -- Opt-in: set Window.NotificationClickToDismiss = true
        local clickArea = nil
        if Window.NotificationClickToDismiss == true then
            clickArea = Instance.new("TextButton")
            clickArea.Name = "DismissArea"
            clickArea.Size = UDim2.new(1, 0, 1, 0)
            clickArea.BackgroundTransparency = 1
            clickArea.Text = ""
            clickArea.AutoButtonColor = false
            clickArea.ZIndex = 36
            clickArea.Parent = container
        end

        -- Record per-child z offsets so restacking never drifts.
        for _, child in ipairs(container:GetDescendants()) do
            if child:IsA("GuiObject") then
                child:SetAttribute("ZOff", math.clamp(child.ZIndex - 30, 1, 7))
            end
        end

        local dismissSignal = Instance.new("BindableEvent")
        dismissSignal.Name = "DismissSignal"
        dismissSignal.Parent = container

        local progressTween = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0),
        })
        progressTween:Play()

        table.insert(active, 1, container)
        restack(active, scale, 0.35)

        local dismissed = false
        local function dismiss()
            if dismissed then return end
            dismissed = true
            progressTween:Cancel()

            for i, item in ipairs(active) do
                if item == container then
                    table.remove(active, i)
                    break
                end
            end

            if not container.Parent then return end
            TweenService:Create(container, SLIDE_OUT, {
                Position = UDim2.new(1, math.round(350 * scale), 1, container.Position.Y.Offset),
            }):Play()
            task.delay(SLIDE_OUT.Time + 0.02, function()
                if container.Parent then container:Destroy() end
            end)
            restack(active, scale, 0.25)
        end

        dismissSignal.Event:Connect(dismiss)
        if clickArea then clickArea.MouseButton1Click:Connect(dismiss) end
        task.delay(duration, dismiss)

        return { Dismiss = dismiss, Frame = container }
    end

    function Window:DismissAllNotifications()
        local active = Window.ActiveNotifications
        if not active then return end
        for _, notif in ipairs(table.clone(active)) do
            local signal = notif and notif:FindFirstChild("DismissSignal")
            if signal then signal:Fire() end
        end
    end
end
