-- modules/credits.lua
-- MorningDrift UI Library: Credits Section Module
local TweenService = game:GetService("TweenService")

return function(Library, Window)
    function Window:CreateCreditsSection(parentTab)
        local creditsConfig = Window.CreditsConfig or {
            Enabled = true,
            Title = "Credits",
            Creator = "@wavhx / @morningdrift",
            Discord = Window.DiscordLink or "discord.gg/48jdqB8rAw",
            DiscordLabel = "Discord server if you have any questions"
        }
        Window.CreditsConfig = creditsConfig

        local creditsSec = parentTab:AddSection(creditsConfig.Title or "Credits", true)
        local SectionCard = creditsSec.Card or creditsSec.SectionCard

        local creatorCard = creditsSec:AddCard({
            Title = "Creator and developer",
            Desc = creditsConfig.Creator or "@wavhx / @morningdrift",
            Height = 52
        })

        local discordCard = creditsSec:AddCard({
            Title = creditsConfig.DiscordLabel or "Discord server if you have any questions",
            Desc = creditsConfig.Discord or (Window.DiscordLink or "discord.gg/48jdqB8rAw"),
            Height = 52
        })

        local copyBadge = nil
        if discordCard and discordCard.Frame then
            local cardFrame = discordCard.Frame

            copyBadge = Instance.new("TextLabel")
            copyBadge.Name = "CopyBadge"
            copyBadge.AnchorPoint = Vector2.new(1, 0.5)
            copyBadge.Position = UDim2.new(1, -12, 0.5, 0)
            copyBadge.Size = UDim2.new(0, 68, 0, 24)
            copyBadge.BackgroundColor3 = Window.CurrentTheme.ButtonBG
            copyBadge.BackgroundTransparency = 0.25
            copyBadge.Font = Enum.Font.GothamMedium
            copyBadge.Text = "Copy link"
            copyBadge.TextColor3 = Window.CurrentTheme.Text
            copyBadge.TextSize = 11
            copyBadge.ZIndex = 12
            copyBadge.Parent = cardFrame

            local badgeCorner = Instance.new("UICorner")
            badgeCorner.CornerRadius = UDim.new(0, 6)
            badgeCorner.Parent = copyBadge

            local trigger = Instance.new("TextButton")
            trigger.Name = "CopyTrigger"
            trigger.Size = UDim2.new(1, 0, 1, 0)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.ZIndex = 13
            trigger.Parent = cardFrame

            local function copyDiscord()
                local link = Window.CreditsConfig.Discord or Window.DiscordLink or "discord.gg/48jdqB8rAw"
                local cleanLink = link
                if not cleanLink:find("^https?://") then
                    cleanLink = "https://" .. cleanLink
                end
                pcall(function()
                    if setclipboard then
                        setclipboard(cleanLink)
                    end
                end)
                Window:Notify("Credits", "Copied Discord invite to clipboard!", 2.5)
                copyBadge.Text = "Copied!"
                task.delay(1.5, function()
                    if copyBadge and copyBadge.Parent then
                        copyBadge.Text = "Copy link"
                    end
                end)
            end

            TrackConn(trigger.MouseButton1Click:Connect(function()
                PlayClickSFX()
                copyDiscord()
            end))

            TrackConn(trigger.MouseEnter:Connect(function()
                TweenService:Create(copyBadge, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            end))
            TrackConn(trigger.MouseLeave:Connect(function()
                TweenService:Create(copyBadge, TweenInfo.new(0.15), {BackgroundTransparency = 0.25}):Play()
            end))
        end

        if creatorCard and creatorCard.Frame then
            local cardFrame = creatorCard.Frame
            local trigger = Instance.new("TextButton")
            trigger.Name = "CopyCreatorTrigger"
            trigger.Size = UDim2.new(1, 0, 1, 0)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.ZIndex = 13
            trigger.Parent = cardFrame

            TrackConn(trigger.MouseButton1Click:Connect(function()
                PlayClickSFX()
                local creator = Window.CreditsConfig.Creator or "@wavhx / @morningdrift"
                pcall(function()
                    if setclipboard then
                        setclipboard(creator)
                    end
                end)
                Window:Notify("Credits", "Copied creator to clipboard: " .. creator, 2.5)
            end))
        end

        local origSecRefresh = creditsSec.RefreshTheme
        creditsSec.RefreshTheme = function(self, theme, anim)
            if origSecRefresh then origSecRefresh(self, theme, anim) end
            local twInfo = TweenInfo.new(anim and 0.35 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local divColor = theme.Divider or Color3.fromRGB(80, 85, 100)
            local isST = Window.SectionsTransparent
            local bgTrans = isST and 1 or (Window.ElementsTransparency or 0.33)

            local cards = { creatorCard, discordCard }
            for _, card in ipairs(cards) do
                if card and card.Frame and card.Frame.Parent then
                    if anim then
                        TweenService:Create(card.Frame, twInfo, {BackgroundColor3 = theme.CardBG, BackgroundTransparency = bgTrans}):Play()
                    else
                        card.Frame.BackgroundColor3 = theme.CardBG
                        card.Frame.BackgroundTransparency = bgTrans
                    end
                    local stroke = card.Frame:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        if anim then
                            TweenService:Create(stroke, twInfo, {Color = divColor}):Play()
                        else
                            stroke.Color = divColor
                        end
                    end
                    local titleLbl = card.Frame:FindFirstChild("Title")
                    if titleLbl then
                        if anim then
                            TweenService:Create(titleLbl, twInfo, {TextColor3 = theme.Text}):Play()
                        else
                            titleLbl.TextColor3 = theme.Text
                        end
                    end
                    local descLbl = card.Frame:FindFirstChild("Desc")
                    if descLbl then
                        if anim then
                            TweenService:Create(descLbl, twInfo, {TextColor3 = theme.SubText}):Play()
                        else
                            descLbl.TextColor3 = theme.SubText
                        end
                    end
                end
            end
            if copyBadge and copyBadge.Parent then
                if anim then
                    TweenService:Create(copyBadge, twInfo, {BackgroundColor3 = theme.ButtonBG, TextColor3 = theme.Text}):Play()
                else
                    copyBadge.BackgroundColor3 = theme.ButtonBG
                    copyBadge.TextColor3 = theme.Text
                end
            end
        end

        if SectionCard then
            SectionCard.Visible = (creditsConfig.Enabled == true)
        end

        Window.CreditsSection = {
            Section = creditsSec,
            SectionCard = SectionCard,
            CreatorCard = creatorCard,
            DiscordCard = discordCard
        }

        parentTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, parentTab.Layout.AbsoluteContentSize.Y + 20)
        return creditsSec
    end

    function Window:SetCreditsEnabled(enabled)
        enabled = (enabled == true)
        if Window.CreditsConfig then
            Window.CreditsConfig.Enabled = enabled
        end
        if Window.CreditsSection and Window.CreditsSection.SectionCard and Window.CreditsSection.SectionCard.Parent then
            Window.CreditsSection.SectionCard.Visible = enabled
            if Window.SettingsTab and Window.SettingsTab.ContentFrame and Window.SettingsTab.Layout then
                Window.SettingsTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, Window.SettingsTab.Layout.AbsoluteContentSize.Y + 20)
            end
        end
    end

    function Window:SetCredits(newConfig)
        if type(newConfig) == "boolean" then
            Window:SetCreditsEnabled(newConfig)
            return
        end
        if type(newConfig) ~= "table" then return end

        local cfg = Window.CreditsConfig or {}
        Window.CreditsConfig = cfg

        if newConfig.Enabled ~= nil then cfg.Enabled = (newConfig.Enabled == true) end
        if newConfig.Show ~= nil then cfg.Enabled = (newConfig.Show == true) end
        if newConfig.Visible ~= nil then cfg.Enabled = (newConfig.Visible == true) end
        if newConfig.Title then cfg.Title = tostring(newConfig.Title) end
        if newConfig.Creator then cfg.Creator = tostring(newConfig.Creator) end
        if newConfig.Developer then cfg.Creator = tostring(newConfig.Developer) end
        if newConfig.Discord then cfg.Discord = tostring(newConfig.Discord) end
        if newConfig.DiscordLabel then cfg.DiscordLabel = tostring(newConfig.DiscordLabel) end
        if newConfig.DiscordText then cfg.DiscordLabel = tostring(newConfig.DiscordText) end

        local secInfo = Window.CreditsSection
        if secInfo then
            if secInfo.Section and cfg.Title and secInfo.Section.TitleLabel then
                secInfo.Section.TitleLabel.Text = cfg.Title:upper()
            end
            if secInfo.CreatorCard and cfg.Creator and secInfo.CreatorCard.SetDesc then
                secInfo.CreatorCard:SetDesc(cfg.Creator)
            end
            if secInfo.DiscordCard then
                if cfg.DiscordLabel and secInfo.DiscordCard.SetTitle then
                    secInfo.DiscordCard:SetTitle(cfg.DiscordLabel)
                end
                if cfg.Discord and secInfo.DiscordCard.SetDesc then
                    secInfo.DiscordCard:SetDesc(cfg.Discord)
                end
            end
            if cfg.Enabled ~= nil then
                Window:SetCreditsEnabled(cfg.Enabled)
            end
        end
    end

    function Window:GetCredits()
        return Window.CreditsConfig
    end

end
