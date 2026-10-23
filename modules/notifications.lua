-- modules/notifications.lua
-- MorningDrift UI Library: Notifications, Tooltips & Overlay Module
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

return function(Library, Window)
    local PlayNotifSFX = (Window._I and Window._I.PlayNotifSFX)
        or Window.PlayNotifSFX
        or (Library and Library.PlayNotifSFX)
        or function() end
    local PlayHoverSFX = (Window._I and Window._I.PlayHoverSFX)
        or Window.PlayHoverSFX
        or (Library and Library.PlayHoverSFX)
        or function() end
    local TrackConn = (Window._I and Window._I.TrackConn)
        or Window.TrackConn
        or (Library and Library.TrackConn)
        or function(c) return c end

    local tooltipContentMap = Window._TooltipContentMap or setmetatable({}, {__mode = "k"})
    Window._TooltipContentMap = tooltipContentMap

    local activeTooltipTarget = nil
    local tooltipTween = nil

    local function GetTooltipComponents()
        local frame = Window.TooltipFrame
        local stroke = Window.TooltipStroke or (frame and frame:FindFirstChildWhichIsA("UIStroke", true))
        local shadow = Window.TooltipShadow
        local text = Window.TooltipText or (frame and frame:FindFirstChildWhichIsA("TextLabel", true))
        return frame, stroke, shadow, text
    end

    function Window:AttachTooltip(guiObject, text)
        if not guiObject or not text or text == "" then return end
        tooltipContentMap[guiObject] = text

        TrackConn(guiObject.MouseEnter:Connect(function()
            if not guiObject or not tooltipContentMap[guiObject] or tooltipContentMap[guiObject] == "" then return end
            local TooltipFrame, TooltipStroke, TooltipShadow, TooltipText = GetTooltipComponents()
            if not TooltipFrame or not TooltipText then return end

            activeTooltipTarget = guiObject
            TooltipText.Text = tostring(tooltipContentMap[guiObject])

            local bounds = TextService:GetTextSize(TooltipText.Text, 12, Enum.Font.Montserrat or Enum.Font.SourceSans, Vector2.new(300, 100))
            local tw = math.clamp(bounds.X + 20, 48, 320)
            local th = math.clamp(bounds.Y + 12, 24, 80)
            TooltipFrame.Size = UDim2.new(0, tw, 0, th)

            local mousePos = UserInputService:GetMouseLocation()
            local inset = game:GetService("GuiService"):GetGuiInset()
            TooltipFrame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - inset.Y + 12)
            TooltipText.TextColor3 = (Window.CurrentTheme and Window.CurrentTheme.Text) or Color3.fromRGB(240, 240, 245)
            TooltipFrame.BackgroundColor3 = (Window.CurrentTheme and Window.CurrentTheme.CardBG) or Color3.fromRGB(24, 26, 34)
            if TooltipStroke then
                TooltipStroke.Color = (Window.CurrentTheme and Window.CurrentTheme.Divider) or Color3.fromRGB(65, 70, 88)
            end
            TooltipFrame.Visible = true

            if tooltipTween then tooltipTween:Cancel() end
            tooltipTween = TweenService:Create(TooltipFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0.05})
            tooltipTween:Play()
            if TooltipStroke then
                TweenService:Create(TooltipStroke, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
            end
            TweenService:Create(TooltipText, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
            if TooltipShadow then
                local intensity = Library.ShadowIntensity or (1 / 1.8)
                local curTrans = 1 - math.clamp((1 - 0.45) * intensity, 0, 1)
                TweenService:Create(TooltipShadow, TweenInfo.new(0.15), {Transparency = curTrans}):Play()
            end
        end))

        TrackConn(guiObject.MouseMoved:Connect(function()
            if activeTooltipTarget == guiObject then
                local TooltipFrame = Window.TooltipFrame
                if TooltipFrame and TooltipFrame.Visible then
                    local mousePos = UserInputService:GetMouseLocation()
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    TooltipFrame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - inset.Y + 12)
                end
            end
        end))

        TrackConn(guiObject.MouseLeave:Connect(function()
            if activeTooltipTarget == guiObject then
                activeTooltipTarget = nil
                local TooltipFrame, TooltipStroke, TooltipShadow, TooltipText = GetTooltipComponents()
                if not TooltipFrame then return end

                if tooltipTween then tooltipTween:Cancel() end
                tooltipTween = TweenService:Create(TooltipFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1})
                tooltipTween:Play()
                if TooltipStroke then
                    TweenService:Create(TooltipStroke, TweenInfo.new(0.15), {Transparency = 1}):Play()
                end
                if TooltipText then
                    TweenService:Create(TooltipText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
                end
                if TooltipShadow then
                    TweenService:Create(TooltipShadow, TweenInfo.new(0.15), {Transparency = 1}):Play()
                end
                task.delay(0.16, function()
                    if activeTooltipTarget == nil and TooltipFrame then
                        TooltipFrame.Visible = false
                    end
                end)
            end
        end))
    end


    function Window:Notify(titleText, contentText, duration, notifType)
        if not Window.NotificationsEnabled then return end
        PlayNotifSFX()
        if type(titleText) == "table" then
            notifType = titleText.Type or titleText.notifType or notifType
            duration = titleText.Duration or titleText.duration or duration
            contentText = titleText.Content or titleText.Text or titleText.Body or contentText
            titleText = titleText.Title or titleText.title or "MD Notification"
        end
        duration = duration or 3.5

        local NotificationUI = Window.NotificationUI or Library.NotificationUI
        if not NotificationUI then return end

        local ActiveNotifications = Window.ActiveNotifications or Library.ActiveNotifications or {}
        local RegisterHUDScale = Window.RegisterHUDScale or Library.RegisterHUDScale or function(o) return o end
        local ApplyCornerRadii = Window.ApplyCornerRadii or Library.ApplyCornerRadii or function() end
        local AddUIShadow = Window.AddUIShadow or Library.AddUIShadow or function() end
        local FontTitle = Window.FontTitle or Library.FontTitle or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        local FontRegular = Window.FontRegular or Library.FontRegular or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        local iconAsset = Window.IconAsset or Window.iconAsset or "rbxassetid://78209859871518"

        local currentTheme = Window.CurrentTheme or Library.CurrentTheme or {}
        local typeColors = {
            success = Color3.fromRGB(46, 204, 113),
            warning = Color3.fromRGB(241, 196, 15),
            error   = Color3.fromRGB(231, 76, 60),
            info    = currentTheme.ButtonBG or Color3.fromRGB(60, 100, 200),
        }
        local accentCol = typeColors[string.lower(tostring(notifType or ""))] or currentTheme.ButtonBG or Color3.fromRGB(60, 100, 200)

        local NotifContainer = Instance.new("Frame")
        NotifContainer.Name = "NotifContainer"
        NotifContainer.Size = UDim2.new(0, 290, 0, 105)
        NotifContainer.Position = UDim2.new(1, 350, 1, -105)
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.ZIndex = 30
        NotifContainer.Parent = NotificationUI
        RegisterHUDScale(NotifContainer)

        local NotifTop = Instance.new("Frame")
        NotifTop.Name = "TopFrame"
        NotifTop.Size = UDim2.new(1, 0, 0, 28)
        NotifTop.Position = UDim2.new(0, 0, 0, 0)
        NotifTop.BackgroundColor3 = currentTheme.TopBG or Color3.fromRGB(30, 30, 36)
        NotifTop.BackgroundTransparency = currentTheme.TopTrans or 0
        NotifTop.BorderSizePixel = 0
        NotifTop.ZIndex = 31
        NotifTop.Parent = NotifContainer

        local NotifTopCorner = Instance.new("UICorner")
        ApplyCornerRadii(NotifTopCorner, 8, 8, 0, 0)
        NotifTopCorner.Parent = NotifTop

        AddUIShadow(NotifTop, 20, 0.5)

        local NotifTextFolder = Instance.new("Folder")
        NotifTextFolder.Name = "Text"
        NotifTextFolder.Parent = NotifTop

        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Name = "NotificationName"
        NotifTitle.Size = UDim2.new(1, -20, 1, 0)
        NotifTitle.Position = UDim2.new(0, 12, 0, 0)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.FontFace = FontTitle
        NotifTitle.Text = titleText or "MD Notification"
        NotifTitle.TextColor3 = currentTheme.Text or Color3.fromRGB(240, 240, 245)
        NotifTitle.TextSize = 14
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.TextYAlignment = Enum.TextYAlignment.Center
        NotifTitle.ZIndex = 32
        NotifTitle.Parent = NotifTextFolder

        local NotifMain = Instance.new("Frame")
        NotifMain.Name = "MainFrame"
        NotifMain.Size = UDim2.new(1, 0, 0, 77)
        NotifMain.Position = UDim2.new(0, 0, 0, 28)
        NotifMain.BackgroundColor3 = currentTheme.MainBG or Color3.fromRGB(20, 20, 26)
        NotifMain.BackgroundTransparency = currentTheme.MainTrans or 0
        NotifMain.BorderSizePixel = 0
        NotifMain.ZIndex = 31
        NotifMain.Parent = NotifContainer

        local NotifMainCorner = Instance.new("UICorner")
        ApplyCornerRadii(NotifMainCorner, 0, 0, 8, 8)
        NotifMainCorner.Parent = NotifMain

        AddUIShadow(NotifMain, 20, 0.5)

        local NotifIcon = Instance.new("ImageLabel")
        NotifIcon.Name = "Icon"
        NotifIcon.Size = UDim2.new(0, 48, 0, 48)
        NotifIcon.Position = UDim2.new(0, 12, 0.5, -24)
        NotifIcon.BackgroundTransparency = 1
        NotifIcon.Image = iconAsset or "rbxassetid://78209859871518"
        NotifIcon.ImageColor3 = currentTheme.Text or Color3.fromRGB(240, 240, 245)
        NotifIcon.ZIndex = 32
        NotifIcon.Parent = NotifMain

        local NotifBody = Instance.new("TextLabel")
        NotifBody.Name = "NOTIFICATIONTXT"
        NotifBody.Size = UDim2.new(1, -72, 1, -12)
        NotifBody.Position = UDim2.new(0, 64, 0, 4)
        NotifBody.BackgroundTransparency = 1
        NotifBody.FontFace = FontRegular
        NotifBody.Text = contentText or ""
        NotifBody.TextColor3 = currentTheme.Text or Color3.fromRGB(240, 240, 245)
        NotifBody.TextSize = 12
        NotifBody.TextWrapped = true
        NotifBody.TextXAlignment = Enum.TextXAlignment.Left
        NotifBody.TextYAlignment = Enum.TextYAlignment.Center
        NotifBody.ZIndex = 32
        NotifBody.Parent = NotifMain

        -- Bottom Progress Bar showing remaining time
        local ProgressBarBG = Instance.new("Frame")
        ProgressBarBG.Name = "ProgressBarBG"
        ProgressBarBG.Size = UDim2.new(1, 0, 0, 2)
        ProgressBarBG.Position = UDim2.new(0, 0, 1, -2)
        ProgressBarBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ProgressBarBG.BackgroundTransparency = 0.6
        ProgressBarBG.BorderSizePixel = 0
        ProgressBarBG.ZIndex = 33
        ProgressBarBG.Parent = NotifMain

        local ProgressBar = Instance.new("Frame")
        ProgressBar.Name = "ProgressBar"
        ProgressBar.Size = UDim2.new(1, 0, 1, 0)
        ProgressBar.Position = UDim2.new(0, 0, 0, 0)
        ProgressBar.BackgroundColor3 = accentCol
        ProgressBar.BorderSizePixel = 0
        ProgressBar.ZIndex = 34
        ProgressBar.Parent = ProgressBarBG

        local progressTween = TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        })
        progressTween:Play()

        table.insert(ActiveNotifications, 1, NotifContainer)

        for index, notif in ipairs(ActiveNotifications) do
            local targetX = -320 + ((index - 1) * 18)
            local targetY = -105 + ((index - 1) * 12)
            local targetZ = math.max(1, 30 - ((index - 1) * 10))

            notif.ZIndex = targetZ
            for _, child in ipairs(notif:GetDescendants()) do
                if child:IsA("GuiObject") then
                    child.ZIndex = targetZ + (child.ZIndex % 5)
                end
            end

            TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, targetX, 1, targetY)
            }):Play()
        end

        task.delay(duration, function()
            if not NotifContainer or not NotifContainer.Parent then return end

            local slideOut = TweenService:Create(NotifContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 350, NotifContainer.Position.Y.Scale, NotifContainer.Position.Y.Offset)
            })
            slideOut:Play()
            slideOut.Completed:Wait()

            for idx, item in ipairs(ActiveNotifications) do
                if item == NotifContainer then
                    table.remove(ActiveNotifications, idx)
                    break
                end
            end
            NotifContainer:Destroy()

            for index, notif in ipairs(ActiveNotifications) do
                local targetX = -320 + ((index - 1) * 18)
                local targetY = -105 + ((index - 1) * 12)
                local targetZ = math.max(1, 30 - ((index - 1) * 10))

                notif.ZIndex = targetZ
                for _, child in ipairs(notif:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        child.ZIndex = targetZ + (child.ZIndex % 5)
                    end
                end

                TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, targetX, 1, targetY)
                }):Play()
            end
        end)
    end

end
