-- modules/theme_manager.lua
-- MorningDrift UI Library: Theme Manager & Visual Effects Module
local TweenService = game:GetService("TweenService")
local LightingService = game:GetService("Lighting")
local Lighting = LightingService

return function(Library, Window)
    local GetThemedDarkColor = Library.GetThemedDarkColor or function(theme)
        local cardBG = (theme and theme.CardBG) or Color3.fromRGB(30, 32, 40)
        return cardBG
    end
    local GetOnAccent = Library.GetOnAccent or function(bg)
        if typeof(bg) ~= "Color3" then return Color3.fromRGB(255, 255, 255) end
        local lum = 0.299 * bg.R + 0.587 * bg.G + 0.114 * bg.B
        return lum > 0.6 and Color3.fromRGB(20, 22, 28) or Color3.fromRGB(255, 255, 255)
    end
    local IsInsideSection = Library.IsInsideSection or function() return false end
    local ApplyCornerRadii = Library.ApplyCornerRadii or Window.ApplyCornerRadii or function() end

    local function GetIconColorForTheme(theme)
        if Window.GetIconColorForTheme then
            return Window.GetIconColorForTheme(theme)
        end
        if Library.GetIconColorForTheme then
            return Library.GetIconColorForTheme(theme)
        end
        if not theme then return Color3.fromRGB(255, 255, 255) end
        local bg = theme.MainBG or Color3.fromRGB(30, 30, 30)
        local _, s, v = Color3.toHSV(bg)

        if s < 0.3 and v < 0.1 then
            return Color3.fromRGB(255, 255, 255)
        end
        if s < 0.15 and v > 0.85 then
            return Color3.fromRGB(0, 0, 0)
        end

        return theme.ButtonBG or theme.Text or Color3.fromRGB(255, 255, 255)
    end

    local activeThemeTweens = {}
    local function cancelActiveThemeTweens()
        for _, tw in ipairs(activeThemeTweens) do
            pcall(function() tw:Cancel() end)
        end
        table.clear(activeThemeTweens)
    end

    function Window:ApplyTheme(themeKey, animated)
        cancelActiveThemeTweens()
        animated = (animated == nil) and true or animated
        local newTheme = Library.ThemePresets[themeKey]
        if not newTheme then return end

        local themeCopy = {}
        for k, v in pairs(newTheme) do
            themeCopy[k] = v
        end
        Window.CurrentTheme = themeCopy
        Window.CurrentThemeKey = themeKey

        if themeKey == "Custom" then
            Window.IsCustomTheme = true
        else
            Window.IsCustomTheme = false
            Window.CustomThemeColor = nil
            if Window.RegisteredColorPickers then
                if Window.RegisteredColorPickers["CustomTheme"] then
                    pcall(function()
                        Window.RegisteredColorPickers["CustomTheme"].SetColor(newTheme.ButtonBG, false)
                    end)
                end
                if Window.RegisteredColorPickers["Custom theme"] then
                    pcall(function()
                        Window.RegisteredColorPickers["Custom theme"].SetColor(newTheme.ButtonBG, false)
                    end)
                end
            end
        end

        local RealTweenService = game:GetService("TweenService")
        local TweenService = {
            Create = function(_, inst, info, props)
                local tw = RealTweenService:Create(inst, info, props)
                table.insert(activeThemeTweens, tw)
                return tw
            end
        }

        local tweenInfo = TweenInfo.new(animated and 0.35 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        if Window.MainFrame then
            local mainTrans = Window.CustomBGTransparency or newTheme.MainTrans
            local rightColor = newTheme.TopBG or newTheme.AccentBG
            if animated then
                TweenService:Create(Window.MainFrame, tweenInfo, {
                    BackgroundColor3 = rightColor,
                    BackgroundTransparency = mainTrans
                }):Play()
            else
                Window.MainFrame.BackgroundColor3 = rightColor
                Window.MainFrame.BackgroundTransparency = mainTrans
            end
        end
        local frameColor = newTheme.MainBG
        local frameTrans = Window.TopBottomTransparency or newTheme.TopTrans or 0.12

        if Window.LeftFrame then
            if animated then
                TweenService:Create(Window.LeftFrame, tweenInfo, {
                    BackgroundColor3 = frameColor,
                    BackgroundTransparency = frameTrans
                }):Play()
            else
                Window.LeftFrame.BackgroundColor3 = frameColor
                Window.LeftFrame.BackgroundTransparency = frameTrans
            end
        end
        if Window.TopFrame then
            if animated then
                TweenService:Create(Window.TopFrame, tweenInfo, {
                    BackgroundColor3 = frameColor,
                    BackgroundTransparency = frameTrans
                }):Play()
            else
                Window.TopFrame.BackgroundColor3 = frameColor
                Window.TopFrame.BackgroundTransparency = frameTrans
            end
        end
        if Window.BottomFrame then
            local existingGrad = Window.BottomFrame:FindFirstChildOfClass("UIGradient")
            if existingGrad then existingGrad:Destroy() end
            if animated then
                TweenService:Create(Window.BottomFrame, tweenInfo, {
                    BackgroundColor3 = frameColor,
                    BackgroundTransparency = frameTrans
                }):Play()
            else
                Window.BottomFrame.BackgroundColor3 = frameColor
                Window.BottomFrame.BackgroundTransparency = frameTrans
            end
        end

        if Window.SidebarScroll then
            if animated then
                TweenService:Create(Window.SidebarScroll, tweenInfo, {ScrollBarImageColor3 = newTheme.Divider}):Play()
            else
                Window.SidebarScroll.ScrollBarImageColor3 = newTheme.Divider
            end
        end

        if Window.SidebarCollapseBtn then
            if animated then
                TweenService:Create(Window.SidebarCollapseBtn, tweenInfo, {ImageColor3 = newTheme.Text}):Play()
            else
                Window.SidebarCollapseBtn.ImageColor3 = newTheme.Text
            end
        end

        if Window.BottomFrame then
            local existingGrad = Window.BottomFrame:FindFirstChildOfClass("UIGradient")
            if existingGrad then existingGrad:Destroy() end
        end

        if Window.SidebarDividers then
            for _, div in ipairs(Window.SidebarDividers) do
                if div and div.Parent then
                    local targetImg = div:IsA("ImageLabel") and div or div:FindFirstChildOfClass("ImageLabel")
                    if targetImg then
                        if animated then
                            TweenService:Create(targetImg, tweenInfo, {ImageColor3 = newTheme.Divider, BackgroundTransparency = 1}):Play()
                        else
                            targetImg.ImageColor3 = newTheme.Divider
                            targetImg.BackgroundTransparency = 1
                        end
                    else
                        if animated then
                            TweenService:Create(div, tweenInfo, {BackgroundColor3 = newTheme.Divider, BackgroundTransparency = 1}):Play()
                        else
                            div.BackgroundColor3 = newTheme.Divider
                            div.BackgroundTransparency = 1
                        end
                    end
                end
            end
        end

        if Window._MDicon and Window._MDicon.Parent then
            if not Window.PlayerProfileEnabled then
                local iconCol = GetIconColorForTheme(newTheme)
                if animated then
                    TweenService:Create(Window._MDicon, tweenInfo, {ImageColor3 = iconCol}):Play()
                else
                    Window._MDicon.ImageColor3 = iconCol
                end
            else
                Window._MDicon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        if Window._MadebyText and Window._MadebyText.Parent then
            if animated then
                TweenService:Create(Window._MadebyText, tweenInfo, {TextColor3 = newTheme.Text}):Play()
            else
                Window._MadebyText.TextColor3 = newTheme.Text
            end
        end

        if Window.ResizeArcStroke and Window.ResizeArcStroke.Parent then
            if animated then
                TweenService:Create(Window.ResizeArcStroke, tweenInfo, {Color = newTheme.Text}):Play()
            else
                Window.ResizeArcStroke.Color = newTheme.Text
            end
        end

        if Window.ActiveTabGlow and Window.ActiveTabGlow.Parent then
            local bg = newTheme.MainBG or Color3.fromRGB(25, 27, 34)
            local isBright = (0.299 * bg.R + 0.587 * bg.G + 0.114 * bg.B) > 0.6
            local glowColor = isBright and Color3.fromRGB(30, 32, 40) or Color3.fromRGB(220, 225, 235)
            local glowTrans = isBright and 0.90 or 0.88
            if animated then
                TweenService:Create(Window.ActiveTabGlow, tweenInfo, {BackgroundColor3 = glowColor, BackgroundTransparency = glowTrans}):Play()
            else
                Window.ActiveTabGlow.BackgroundColor3 = glowColor
                Window.ActiveTabGlow.BackgroundTransparency = glowTrans
            end
        end


        for _, btnData in ipairs(Window.RegisteredMDButtons) do
            if btnData and btnData.RefreshTheme then
                pcall(function() btnData.RefreshTheme(newTheme) end)
            elseif btnData and btnData.Frame and btnData.Frame.Parent then
                if animated then
                    TweenService:Create(btnData.Frame, tweenInfo, {BackgroundColor3 = newTheme.ButtonBG}):Play()
                else
                    btnData.Frame.BackgroundColor3 = newTheme.ButtonBG
                end
                local onAccent = GetOnAccent(newTheme.ButtonBG)
                if btnData.TextLabel then
                    if animated then
                        TweenService:Create(btnData.TextLabel, tweenInfo, {TextColor3 = onAccent}):Play()
                    else
                        btnData.TextLabel.TextColor3 = onAccent
                    end
                end
                if btnData.Stroke then
                    btnData.Stroke.Color = Color3.fromRGB(255, 255, 255)
                    btnData.Stroke.Thickness = 1.2
                end
                if btnData.ArrowIcon then
                    if animated then
                        TweenService:Create(btnData.ArrowIcon, tweenInfo, {ImageColor3 = onAccent}):Play()
                    else
                        btnData.ArrowIcon.ImageColor3 = onAccent
                    end
                end
            end
        end

        local refreshedToggles = {}
        for _, toggle in ipairs(Window.RegisteredMDToggles or {}) do
            refreshedToggles[toggle] = true
            if toggle and toggle.RefreshTheme then
                pcall(function() toggle.RefreshTheme(newTheme, animated) end)
            elseif toggle and toggle.Frame and toggle.Frame.Parent then
                local isToggled = (toggle.GetState and toggle.GetState())
                local targetColor = isToggled and newTheme.ButtonBG or GetThemedDarkColor(newTheme)
                local targetBaseColor = isToggled and GetOnAccent(newTheme.ButtonBG) or newTheme.ButtonBG
                local targetOverlayColor = isToggled and newTheme.ButtonBG or Color3.fromRGB(255, 255, 255)

                if toggle.Overlay then
                    if animated then
                        TweenService:Create(toggle.Overlay, tweenInfo, {ImageColor3 = targetOverlayColor}):Play()
                    else
                        toggle.Overlay.ImageColor3 = targetOverlayColor
                    end
                end
                if toggle.BaseCircle then
                    if animated then
                        TweenService:Create(toggle.BaseCircle, tweenInfo, {ImageColor3 = targetBaseColor}):Play()
                    else
                        toggle.BaseCircle.ImageColor3 = targetBaseColor
                    end
                end
                if toggle.CheckIcon then
                    local targetCheckColor = GetOnAccent(newTheme.ButtonBG)
                    if animated then
                        TweenService:Create(toggle.CheckIcon, tweenInfo, {ImageColor3 = targetCheckColor}):Play()
                    else
                        toggle.CheckIcon.ImageColor3 = targetCheckColor
                    end
                end
                if animated then
                    TweenService:Create(toggle.Frame, tweenInfo, {BackgroundColor3 = targetColor}):Play()
                else
                    toggle.Frame.BackgroundColor3 = targetColor
                end
            end
        end

        if Window.RegisteredToggles then
            for _, toggle in pairs(Window.RegisteredToggles) do
                if toggle and not refreshedToggles[toggle] then
                    refreshedToggles[toggle] = true
                    if toggle.RefreshTheme then
                        pcall(function() toggle.RefreshTheme(newTheme, animated) end)
                    elseif toggle.Frame and toggle.Frame.Parent then
                        local isToggled = (toggle.GetState and toggle.GetState())
                        local targetColor = isToggled and newTheme.ButtonBG or GetThemedDarkColor(newTheme)
                        local targetBaseColor = isToggled and GetOnAccent(newTheme.ButtonBG) or newTheme.ButtonBG
                        local targetOverlayColor = isToggled and newTheme.ButtonBG or Color3.fromRGB(255, 255, 255)

                        if toggle.Overlay then
                            if animated then
                                TweenService:Create(toggle.Overlay, tweenInfo, {ImageColor3 = targetOverlayColor}):Play()
                            else
                                toggle.Overlay.ImageColor3 = targetOverlayColor
                            end
                        end
                        if toggle.BaseCircle then
                            if animated then
                                TweenService:Create(toggle.BaseCircle, tweenInfo, {ImageColor3 = targetBaseColor}):Play()
                            else
                                toggle.BaseCircle.ImageColor3 = targetBaseColor
                            end
                        end
                        if toggle.CheckIcon then
                            local targetCheckColor = GetOnAccent(newTheme.ButtonBG)
                            if animated then
                                TweenService:Create(toggle.CheckIcon, tweenInfo, {ImageColor3 = targetCheckColor}):Play()
                            else
                                toggle.CheckIcon.ImageColor3 = targetCheckColor
                            end
                        end
                        if animated then
                            TweenService:Create(toggle.Frame, tweenInfo, {BackgroundColor3 = targetColor}):Play()
                        else
                            toggle.Frame.BackgroundColor3 = targetColor
                        end
                    end
                end
            end
        end

        for _, slider in ipairs(Window.RegisteredMDSliders) do
            if slider and slider.RefreshTheme then
                pcall(function() slider.RefreshTheme(newTheme) end)
            elseif slider and slider.Track and slider.Track.Parent then
                local trackColor = GetThemedDarkColor(newTheme)
                if animated then
                    TweenService:Create(slider.Track, tweenInfo, {BackgroundColor3 = trackColor}):Play()
                else
                    slider.Track.BackgroundColor3 = trackColor
                end
                if slider.FilledPart then
                    if animated then
                        TweenService:Create(slider.FilledPart, tweenInfo, {BackgroundColor3 = newTheme.ButtonBG}):Play()
                    else
                        slider.FilledPart.BackgroundColor3 = newTheme.ButtonBG
                    end
                end
                if slider.Overlay then
                    if animated then
                        TweenService:Create(slider.Overlay, tweenInfo, {ImageColor3 = newTheme.ButtonBG}):Play()
                    else
                        slider.Overlay.ImageColor3 = newTheme.ButtonBG
                    end
                end
                if slider.ValueLabel then
                    if animated then
                        TweenService:Create(slider.ValueLabel, tweenInfo, {TextColor3 = newTheme.Text}):Play()
                    else
                        slider.ValueLabel.TextColor3 = newTheme.Text
                    end
                end
            end
        end

        if Window.RegisteredTextboxesList then
            for _, box in ipairs(Window.RegisteredTextboxesList) do
                if box and box.RefreshTheme then
                    pcall(function() box.RefreshTheme(newTheme) end)
                end
            end
        end

        if Window.RegisteredDropdownsList then
            for _, drop in ipairs(Window.RegisteredDropdownsList) do
                if drop and drop.RefreshTheme then
                    pcall(function() drop.RefreshTheme(newTheme) end)
                end
            end
        end

        if Window.RegisteredColorPickersList then
            for _, cp in ipairs(Window.RegisteredColorPickersList) do
                if cp and cp.RefreshTheme then
                    pcall(function() cp.RefreshTheme(newTheme) end)
                end
            end
        end

        if Window.RegisteredKeybindBadges then
            for _, b in ipairs(Window.RegisteredKeybindBadges) do
                if b and b.Container and b.Container.Parent then
                    local containerColor = GetThemedDarkColor(newTheme)
                    if animated then
                        TweenService:Create(b.Container, tweenInfo, {BackgroundColor3 = containerColor}):Play()
                    else
                        b.Container.BackgroundColor3 = containerColor
                    end
                    if b.Label then
                        if animated then
                            TweenService:Create(b.Label, tweenInfo, {TextColor3 = newTheme.Text}):Play()
                        else
                            b.Label.TextColor3 = newTheme.Text
                        end
                    end
                    if b.DeleteBtn then
                        if animated then
                            TweenService:Create(b.DeleteBtn, tweenInfo, {ImageColor3 = newTheme.Text}):Play()
                        else
                            b.DeleteBtn.ImageColor3 = newTheme.Text
                        end
                    end
                end
            end
        end

        if Window.RegisteredMobileButtons then
            for _, mb in ipairs(Window.RegisteredMobileButtons) do
                if mb and mb.RefreshTheme then
                    pcall(function() mb.RefreshTheme(newTheme) end)
                end
            end
        end

        if Window.RegisteredSections then
            for _, sec in ipairs(Window.RegisteredSections) do
                if sec and sec.RefreshTheme then
                    pcall(function() sec:RefreshTheme(newTheme, animated) end)
                end
            end
        end

        if Window.RegisteredLabels then
            for _, lbl in ipairs(Window.RegisteredLabels) do
                if lbl and lbl.RefreshTheme then
                    pcall(function() lbl:RefreshTheme(newTheme) end)
                end
            end
        end

        if Window.RegisteredDividers then
            for _, div in ipairs(Window.RegisteredDividers) do
                if div and div.RefreshTheme then
                    pcall(function() div:RefreshTheme(newTheme, animated) end)
                end
            end
        end

        if Window.RegisteredSubTabs then
            for _, st in ipairs(Window.RegisteredSubTabs) do
                if st and st.RefreshTheme then
                    pcall(function() st.RefreshTheme(newTheme, animated) end)
                end
            end
        end

        local SearchBarContainer = Window.SearchBarContainer
        local SearchInput = Window.SearchInput
        local SearchIcon = Window.SearchIcon
        local ClearSearchBtn = Window.ClearSearchBtn

        if SearchBarContainer then
            local searchBarColor = GetThemedDarkColor(newTheme)
            if animated then
                TweenService:Create(SearchBarContainer, tweenInfo, {BackgroundColor3 = searchBarColor}):Play()
            else
                SearchBarContainer.BackgroundColor3 = searchBarColor
            end
            if SearchInput then
                if animated then
                    TweenService:Create(SearchInput, tweenInfo, {TextColor3 = newTheme.Text}):Play()
                else
                    SearchInput.TextColor3 = newTheme.Text
                end
                SearchInput.PlaceholderColor3 = newTheme.SubText
            end
            if SearchIcon then
                if animated then
                    TweenService:Create(SearchIcon, tweenInfo, {ImageColor3 = newTheme.SubText}):Play()
                else
                    SearchIcon.ImageColor3 = newTheme.SubText
                end
            end
            if ClearSearchBtn then
                if animated then
                    TweenService:Create(ClearSearchBtn, tweenInfo, {ImageColor3 = newTheme.SubText}):Play()
                else
                    ClearSearchBtn.ImageColor3 = newTheme.SubText
                end
            end
        end

        if Window.MinimizedImage then
            -- Always recolor all icon layers (including mini icon) to theme accent color
            if Window.MinimizedLayers then
                local minGrad = newTheme.MinGradient or newTheme.BottomGradient
                local themeColor = (minGrad and minGrad[1]) or newTheme.AccentBG or newTheme.Text or Color3.fromRGB(255, 255, 255)
                for idx, layer in ipairs(Window.MinimizedLayers) do
                    if layer and layer.Parent then
                        if animated then
                            TweenService:Create(layer, tweenInfo, {ImageColor3 = themeColor}):Play()
                        else
                            layer.ImageColor3 = themeColor
                        end
                    end
                end
            end
        end

        if Window.RegisteredSliders then
            local bgSld = Window.RegisteredSliders["BGTransparency"]
            if bgSld and bgSld.SetValue and bgSld.GetValue then
                local targetVal = math.floor((Window.CustomBGTransparency or newTheme.MainTrans or 0.12) * 100)
                if bgSld:GetValue() ~= targetVal then
                    pcall(function() bgSld:SetValue(targetVal, false) end)
                end
            end
            local tbSld = Window.RegisteredSliders["TopBottomTransparency"]
            if tbSld and tbSld.SetValue and tbSld.GetValue then
                local targetVal = math.floor((Window.TopBottomTransparency or newTheme.TopTrans or 0.12) * 100)
                if tbSld:GetValue() ~= targetVal then
                    pcall(function() tbSld:SetValue(targetVal, false) end)
                end
            end
            local elemSld = Window.RegisteredSliders["ElementsTransparency"]
            if elemSld and elemSld.SetValue and elemSld.GetValue then
                local targetVal = math.floor((Window.ElementsTransparency or 0.33) * 100)
                if elemSld:GetValue() ~= targetVal then
                    pcall(function() elemSld:SetValue(targetVal, false) end)
                end
            end
        end

        if Window.UpdateThemeSwatches then
            pcall(function() Window:UpdateThemeSwatches() end)
        elseif Window.ThemePresetBtnMap then
            for k, btnData in pairs(Window.ThemePresetBtnMap) do
                if btnData then
                    if btnData.Stroke then
                        btnData.Stroke.Thickness = (k == themeKey) and 2.2 or 1.2
                    end
                    if btnData.Frame then
                        btnData.Frame.BackgroundColor3 = newTheme.ButtonBG
                    end
                    if btnData.TextLabel then
                        btnData.TextLabel.TextColor3 = newTheme.Text
                    end
                end
            end
        end
        if Window.ThemeCard then
            Window.ThemeCard.BackgroundColor3 = newTheme.CardBG
            Window.ThemeCard.BackgroundTransparency = newTheme.AccentTrans or 0.12
            local tTitle = Window.ThemeCard:FindFirstChild("ThemeTitle", true)
            if tTitle then tTitle.TextColor3 = newTheme.Text end
        end

        if Window.MDHUBNAME then
            if animated then
                TweenService:Create(Window.MDHUBNAME, tweenInfo, {TextColor3 = newTheme.Text}):Play()
            else
                Window.MDHUBNAME.TextColor3 = newTheme.Text
            end
        end
        if Window.MadebyText then
            if animated then
                TweenService:Create(Window.MadebyText, tweenInfo, {TextColor3 = newTheme.Text}):Play()
            else
                Window.MadebyText.TextColor3 = newTheme.Text
            end
        end
        if Window.DiscordBtn then
            if animated then
                TweenService:Create(Window.DiscordBtn, tweenInfo, {TextColor3 = newTheme.SubText}):Play()
            else
                Window.DiscordBtn.TextColor3 = newTheme.SubText
            end
        end
        if Window.LocalTime then
            if animated then
                TweenService:Create(Window.LocalTime, tweenInfo, {TextColor3 = newTheme.Text}):Play()
            else
                Window.LocalTime.TextColor3 = newTheme.Text
            end
        end
        if Window.WelcomeMsg then
            if animated then
                TweenService:Create(Window.WelcomeMsg, tweenInfo, {TextColor3 = newTheme.Text}):Play()
            else
                Window.WelcomeMsg.TextColor3 = newTheme.Text
            end
        end

        if Window.Tabs then
            for name, tabData in pairs(Window.Tabs) do
                if tabData.Button then
                    local targetColor = (name == Window.ActiveTab) and newTheme.Text or newTheme.SubText
                    if animated then
                        TweenService:Create(tabData.Button, tweenInfo, {TextColor3 = targetColor}):Play()
                    else
                        tabData.Button.TextColor3 = targetColor
                    end
                end
                if tabData.Icon then
                    local targetColor = (name == Window.ActiveTab) and newTheme.Text or newTheme.SubText
                    if animated then
                        TweenService:Create(tabData.Icon, tweenInfo, {ImageColor3 = targetColor}):Play()
                    else
                        tabData.Icon.ImageColor3 = targetColor
                    end
                end

                if tabData.ContentFrame then
                    if animated then
                        TweenService:Create(tabData.ContentFrame, tweenInfo, {ScrollBarImageColor3 = newTheme.Divider}):Play()
                    else
                        tabData.ContentFrame.ScrollBarImageColor3 = newTheme.Divider
                    end
                    -- Deep traversal: refresh all Cards, TextLabels, TextBoxes, and Icons in tab ContentFrame
                    for _, desc in ipairs(tabData.ContentFrame:GetDescendants()) do
                        if desc:IsA("TextLabel") then
                            local dName = desc.Name
                            if dName == "CardBody" or dName == "DescLabel" or dName == "WebDesc" or dName == "BlurDesc" or dName == "CustomThemeDesc" or dName == "ClickEffectsDesc" or dName:find("Desc") or dName == "SubTitle" then
                                if animated then
                                    TweenService:Create(desc, tweenInfo, {TextColor3 = newTheme.SubText}):Play()
                                else
                                    desc.TextColor3 = newTheme.SubText
                                end
                            elseif dName ~= "LocalTime" and dName ~= "percloaded" and dName ~= "Loadingtext" then
                                if animated then
                                    TweenService:Create(desc, tweenInfo, {TextColor3 = newTheme.Text}):Play()
                                else
                                    desc.TextColor3 = newTheme.Text
                                end
                            end
                        elseif desc:IsA("TextBox") and desc.Name ~= "HexBox" then
                            if animated then
                                TweenService:Create(desc, tweenInfo, {
                                    TextColor3 = newTheme.Text,
                                    PlaceholderColor3 = newTheme.SubText
                                }):Play()
                            else
                                desc.TextColor3 = newTheme.Text
                                desc.PlaceholderColor3 = newTheme.SubText
                            end
                        elseif desc:IsA("ImageLabel") and (desc.Name == "ArrowIcon" or desc.Name == "SearchIcon") then
                            if animated then
                                TweenService:Create(desc, tweenInfo, {ImageColor3 = newTheme.SubText}):Play()
                            else
                                desc.ImageColor3 = newTheme.SubText
                            end
                        elseif desc:IsA("Frame") then
                            local fName = desc.Name
                            if fName:find("SectionCard") or fName == "ColorPickerCard" or fName == "SliderCard" or fName == "ToggleCard" or (fName:find("Card") and fName ~= "MDButtonCard" and fName ~= "TogglePill") then
                                if animated then
                                    TweenService:Create(desc, tweenInfo, {BackgroundColor3 = newTheme.CardBG}):Play()
                                else
                                    desc.BackgroundColor3 = newTheme.CardBG
                                end
                            elseif fName == "SectionColumns" or fName == "LeftColumn" or fName == "RightColumn" or fName:find("Row") or fName:find("Group") then
                                desc.BackgroundTransparency = 1
                            end
                        elseif desc:IsA("UIStroke") and desc.Parent and desc.Parent:IsA("Frame") and desc.Parent.Name:find("SectionCard") then
                            desc.Color = newTheme.Divider or Color3.fromRGB(65, 70, 88)
                        end
                    end
                end
            end
        end

        if Window.RegisteredCustom then
            for _, o in ipairs(Window.RegisteredCustom) do
                if o and o.RefreshTheme then
                    pcall(o.RefreshTheme, newTheme)
                end
            end
        end

        Window:Notify("Theme updated", "Applied " .. newTheme.Name .. " theme!", 2.5)
    end

    function Window:ApplyCustomTheme(baseColor, animated)
        if not baseColor then return end
        animated = (animated == nil) and true or animated
        Window.CustomThemeColor = baseColor
        local h, s, v = baseColor:ToHSV()

        local mainBG, accentBG, topBG, bottomBG, cardBG, buttonBG, divider, text, subText
        local bot1, bot2, bot3, min1, min2, min3

        if s <= 0.05 then
            -- Grayscale / Monochrome selection (Black, Grey, White)
            local isDark = (v < 0.55)
            if v <= 0.10 then
                -- Deep black palette
                mainBG = Color3.fromRGB(13, 13, 16)
                accentBG = Color3.fromRGB(19, 19, 24)
                topBG = Color3.fromRGB(24, 24, 28)
                bottomBG = topBG
                cardBG = Color3.fromRGB(16, 16, 20)
                buttonBG = Color3.fromRGB(34, 34, 42)
                divider = Color3.fromRGB(55, 55, 65)
                text = Color3.fromRGB(245, 245, 250)
                subText = Color3.fromRGB(150, 150, 165)
                bot1 = Color3.fromRGB(22, 22, 28)
                bot2 = Color3.fromRGB(36, 36, 46)
                bot3 = Color3.fromRGB(18, 18, 24)
                min1 = Color3.fromRGB(32, 32, 40)
                min2 = Color3.fromRGB(50, 50, 62)
                min3 = Color3.fromRGB(28, 28, 36)
            elseif v >= 0.88 then
                -- Light white palette
                mainBG = Color3.fromRGB(238, 240, 246)
                accentBG = Color3.fromRGB(224, 228, 236)
                topBG = Color3.fromRGB(246, 248, 252)
                bottomBG = topBG
                cardBG = Color3.fromRGB(255, 255, 255)
                buttonBG = Color3.fromRGB(210, 216, 228)
                divider = Color3.fromRGB(175, 182, 196)
                text = Color3.fromRGB(20, 22, 28)
                subText = Color3.fromRGB(90, 95, 110)
                bot1 = Color3.fromRGB(220, 225, 236)
                bot2 = Color3.fromRGB(245, 247, 252)
                bot3 = Color3.fromRGB(210, 216, 228)
                min1 = Color3.fromRGB(215, 220, 232)
                min2 = Color3.fromRGB(250, 252, 255)
                min3 = Color3.fromRGB(205, 212, 225)
            else
                -- Neutral grey palette 
                mainBG = Color3.fromHSV(0, 0, math.clamp(v * 0.45 + 0.05, 0.10, 0.70))
                accentBG = Color3.fromHSV(0, 0, math.clamp(v * 0.60 + 0.08, 0.14, 0.76))
                topBG = Color3.fromHSV(0, 0, math.clamp(v * 0.65 + 0.10, 0.16, 0.82))
                bottomBG = topBG
                cardBG = Color3.fromHSV(0, 0, math.clamp(v * 0.40 + 0.06, 0.08, 0.90))
                buttonBG = Color3.fromHSV(0, 0, math.clamp(v * 0.85 + 0.15, 0.22, 0.88))
                divider = Color3.fromHSV(0, 0, math.clamp(v * 0.70 + 0.20, 0.25, 0.85))
                text = isDark and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(20, 22, 28)
                subText = isDark and Color3.fromRGB(160, 165, 180) or Color3.fromRGB(85, 90, 105)
                bot1 = Color3.fromHSV(0, 0, math.clamp(v * 0.50 + 0.08, 0.15, 0.75))
                bot2 = Color3.fromHSV(0, 0, math.clamp(v * 0.75 + 0.12, 0.25, 0.85))
                bot3 = Color3.fromHSV(0, 0, math.clamp(v * 0.45 + 0.06, 0.12, 0.70))
                min1 = Color3.fromHSV(0, 0, math.clamp(v * 0.60 + 0.10, 0.20, 0.80))
                min2 = Color3.fromHSV(0, 0, math.clamp(v * 0.90 + 0.10, 0.35, 0.98))
                min3 = Color3.fromHSV(0, 0, math.clamp(v * 0.55 + 0.08, 0.18, 0.75))
            end
        else
            -- Saturated chromatic palette
            buttonBG = Color3.fromHSV(h, math.clamp(s * 0.88, 0.05, 0.95), math.clamp(v * 0.78, 0.20, 0.82))
            accentBG = Color3.fromHSV(h, math.clamp(s * 0.75, 0.04, 0.8), math.clamp(v * 0.45, 0.12, 0.55))
            topBG = Color3.fromHSV(h, math.clamp(s * 0.70, 0.04, 0.75), math.clamp(v * 0.38, 0.10, 0.50))
            bottomBG = topBG
            mainBG = Color3.fromHSV(h, math.clamp(s * 0.65, 0.03, 0.60), math.clamp(v * 0.24, 0.06, 0.38))
            cardBG = Color3.fromHSV(h, math.clamp(s * 0.60, 0.03, 0.55), math.clamp(v * 0.16, 0.04, 0.28))
            divider = Color3.fromHSV(h, math.clamp(s * 0.90, 0.05, 0.95), math.clamp(v * 0.75, 0.20, 0.85))

            text = Color3.fromRGB(245, 245, 250)
            subText = Color3.fromHSV(h, math.clamp(s * 0.25, 0.02, 0.35), 0.85)

            bot1 = Color3.fromHSV(h, math.clamp(s * 0.80, 0.05, 0.85), math.clamp(v * 0.35, 0.10, 0.45))
            bot2 = Color3.fromHSV(h, math.clamp(s * 0.85, 0.05, 0.90), math.clamp(v * 0.55, 0.18, 0.65))
            bot3 = Color3.fromHSV(h, math.clamp(s * 0.80, 0.05, 0.85), math.clamp(v * 0.30, 0.08, 0.40))

            min1 = Color3.fromHSV(h, math.clamp(s * 0.90, 0.08, 0.95), math.clamp(v * 0.65, 0.25, 0.80))
            min2 = Color3.fromHSV(h, math.clamp(s * 0.75, 0.05, 0.80), math.clamp(v * 0.95, 0.45, 1.0))
            min3 = Color3.fromHSV(h, math.clamp(s * 0.90, 0.08, 0.95), math.clamp(v * 0.70, 0.28, 0.85))
        end

        local customTheme = {
            Name = "Custom",
            MainBG = mainBG,
            MainTrans = Window.CustomBGTransparency or 0.12,
            AccentBG = topBG,
            AccentTrans = Window.TopBottomTransparency or 0.12,
            TopBG = topBG,
            TopTrans = Window.TopBottomTransparency or 0.12,
            BottomBG = topBG,
            BottomTrans = Window.TopBottomTransparency or 0.12,
            BottomGradient = { bot1, bot2, bot3 },
            MinGradient = { min1, min2, min3 },
            Divider = divider,
            Text = text,
            SubText = subText,
            CardBG = cardBG,
            ButtonBG = buttonBG
        }

        Library.ThemePresets["Custom"] = customTheme
        Window:ApplyTheme("Custom", animated)
    end

    function Window:SetBackgroundTransparency(transparency)
        local pct = math.clamp(transparency or 0.12, 0, 0.95)
        Window.CustomBGTransparency = pct
        if Window.MainFrame then
            Window.MainFrame.BackgroundTransparency = pct
        end
        if Window.RegisteredSliders then
            local sld = Window.RegisteredSliders["BGTransparency"]
            if sld and sld.SetValue and sld.GetValue and sld:GetValue() ~= math.floor(pct * 100) then
                pcall(function() sld:SetValue(math.floor(pct * 100), false) end)
            end
        end
    end

    function Window:SetElementsTransparency(transparency)
        local pct = math.clamp(transparency or 0.33, 0, 0.95)
        Window.ElementsTransparency = pct
        if Window.RegisteredSections then
            for _, sec in ipairs(Window.RegisteredSections) do
                if sec and sec.Card and sec.Card.Parent then
                    if not Window.SectionsTransparent then
                        sec.Card.BackgroundTransparency = pct
                    end
                end
                local cont = sec and (sec.Container or sec.ItemContainer)
                if cont and cont.Parent then
                    for _, desc in ipairs(cont:GetDescendants()) do
                        if desc:IsA("Frame") and desc.Parent then
                            local dName = desc.Name
                            local isButton = (dName == "MDButtonCard" or dName:find("BtnFrame") or dName == "Btn" or (desc:FindFirstChildOfClass("TextButton") and (dName:find("Btn") or dName:find("Button"))))
                            if not isButton then
                                local isCard = (desc:GetAttribute("MDCard") == true) or dName:find("Card") or dName:find("TextboxFrame") or dName:find("DropdownFrame") or dName:find("BoxFrame")
                                if not isCard and desc.BackgroundColor3 == Window.CurrentTheme.CardBG then
                                    isCard = true
                                end
                                if isCard then
                                    if Window.SectionsTransparent then
                                        desc.BackgroundTransparency = 1
                                    else
                                        desc.BackgroundTransparency = pct
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if Window.RegisteredMDButtons then
            for _, btn in ipairs(Window.RegisteredMDButtons) do
                if btn and btn.CardFrame and btn.CardFrame.Parent then
                    if btn.Button and IsInsideSection(btn.CardFrame) and Window.SectionsTransparent then
                        btn.CardFrame.BackgroundTransparency = 1
                    else
                        btn.CardFrame.BackgroundTransparency = pct
                    end
                end
            end
        end
        if Window.RegisteredMDToggles then
            for _, tog in ipairs(Window.RegisteredMDToggles) do
                local cFrame = tog and (tog.CardFrame or tog.Frame)
                if cFrame and cFrame.Parent then
                    if IsInsideSection(cFrame) and Window.SectionsTransparent then
                        cFrame.BackgroundTransparency = 1
                    else
                        cFrame.BackgroundTransparency = pct
                    end
                end
            end
        end
        if Window.RegisteredMDSliders then
            for _, sld in ipairs(Window.RegisteredMDSliders) do
                if sld and sld.CardFrame and sld.CardFrame.Parent then
                    if IsInsideSection(sld.CardFrame) and Window.SectionsTransparent then
                        sld.CardFrame.BackgroundTransparency = 1
                    else
                        sld.CardFrame.BackgroundTransparency = pct
                    end
                end
            end
        end
        if Window.RegisteredDropdownsList then
            for _, drp in ipairs(Window.RegisteredDropdownsList) do
                local drpFrame = drp and (drp.CardFrame or drp.Frame)
                if drpFrame and drpFrame.Parent then
                    if IsInsideSection(drpFrame) and Window.SectionsTransparent then
                        drpFrame.BackgroundTransparency = 1
                    else
                        drpFrame.BackgroundTransparency = pct
                    end
                end
            end
        end
        if Window.RegisteredTextboxesList then
            for _, tb in ipairs(Window.RegisteredTextboxesList) do
                local tbFrame = tb and (tb.CardFrame or tb.Frame)
                if tbFrame and tbFrame.Parent then
                    if IsInsideSection(tbFrame) and Window.SectionsTransparent then
                        tbFrame.BackgroundTransparency = 1
                    else
                        tbFrame.BackgroundTransparency = pct
                    end
                end
            end
        end
        if Window.RegisteredColorPickersList then
            for _, cp in ipairs(Window.RegisteredColorPickersList) do
                local cpFrame = cp and (cp.CardFrame or cp.Frame)
                if cpFrame and cpFrame.Parent then
                    if IsInsideSection(cpFrame) and Window.SectionsTransparent then
                        cpFrame.BackgroundTransparency = 1
                    else
                        cpFrame.BackgroundTransparency = pct
                    end
                end
            end
        end
        if Window.RegisteredSliders then
            local sld = Window.RegisteredSliders["ElementsTransparency"]
            if sld and sld.SetValue and sld.GetValue and sld:GetValue() ~= math.floor(pct * 100) then
                pcall(function() sld:SetValue(math.floor(pct * 100), false) end)
            end
        end
    end

    function Window:SetTopBottomTransparency(transparency)
        local pct = math.clamp(transparency or 0.12, 0, 0.95)
        Window.TopBottomTransparency = pct
        if Window.TopFrame and Window.TopFrame.Parent then
            Window.TopFrame.BackgroundTransparency = pct
        end
        if Window.LeftFrame and Window.LeftFrame.Parent then
            Window.LeftFrame.BackgroundTransparency = pct
        end
        if Window.BottomFrame and Window.BottomFrame.Parent then
            Window.BottomFrame.BackgroundTransparency = pct
        end
        if Window.RegisteredSliders then
            local sld = Window.RegisteredSliders["TopBottomTransparency"]
            if sld and sld.SetValue and sld.GetValue and sld:GetValue() ~= math.floor(pct * 100) then
                pcall(function() sld:SetValue(math.floor(pct * 100), false) end)
            end
        end
    end

    function Window:SetUISounds(enabled)
        Window.UISoundsEnabled = enabled
    end

    function Window:SetSoundVolume(volume)
        local pct = math.clamp(volume or 0.8, 0, 1)
        Window.SoundVolume = pct
        local HoverSoundTemplate = Window.HoverSoundTemplate
        local ClickSoundTemplate = Window.ClickSoundTemplate
        local NotifSoundTemplate = Window.NotifSoundTemplate
        if HoverSoundTemplate then HoverSoundTemplate.Volume = pct * 0.4 end
        if ClickSoundTemplate then ClickSoundTemplate.Volume = pct * 0.5 end
        if NotifSoundTemplate then NotifSoundTemplate.Volume = pct * 0.5 end
    end

    function Window:SetBlurIntensity(val)
        local num = tonumber(val) or 1.0
        if num > 1 then num = num / 100 end
        num = math.clamp(num, 0, 1.0)
        Window.BlurIntensity = num
        local BackgroundDOF = Window.BackgroundDOF
        if BackgroundDOF and BackgroundDOF.Parent then
            BackgroundDOF.NearIntensity = num
        end
    end

    function Window:SetBackgroundBlur(enabled)
        Window.BackgroundBlurEnabled = enabled
        local BackgroundDOF = Window.BackgroundDOF
        local LocalUIBlurPart = Window.LocalUIBlurPart
        local UpdateLocalUIBlur = Window.UpdateLocalUIBlur
        if BackgroundDOF and BackgroundDOF.Parent then
            BackgroundDOF.Enabled = enabled
            if enabled then
                BackgroundDOF.NearIntensity = Window.BlurIntensity or 0.5
            end
        elseif enabled then
            BackgroundDOF = Instance.new("DepthOfFieldEffect")
            BackgroundDOF.Name = "ScriptHubDOF"
            BackgroundDOF.FocusDistance = 2.5
            BackgroundDOF.InFocusRadius = 0
            BackgroundDOF.NearIntensity = Window.BlurIntensity or 0.5
            BackgroundDOF.FarIntensity = 0.0
            BackgroundDOF.Enabled = true
            BackgroundDOF.Parent = Lighting
            Window.BackgroundDOF = BackgroundDOF
        end

        if LocalUIBlurPart and LocalUIBlurPart.Parent then
            LocalUIBlurPart.Transparency = enabled and 0.98 or 1
        elseif enabled then
            LocalUIBlurPart = Instance.new("Part")
            LocalUIBlurPart.Name = "LocalUIBlurPart"
            LocalUIBlurPart.Material = Enum.Material.Glass
            LocalUIBlurPart.Transparency = 0.98
            LocalUIBlurPart.Color = Color3.fromRGB(255, 255, 255)
            LocalUIBlurPart.CastShadow = false
            LocalUIBlurPart.CanCollide = false
            LocalUIBlurPart.CanTouch = false
            LocalUIBlurPart.CanQuery = false
            LocalUIBlurPart.Anchored = true
            LocalUIBlurPart.Size = Vector3.new(1, 1, 0.01)
            LocalUIBlurPart.Parent = workspace
            Window.LocalUIBlurPart = LocalUIBlurPart
        end

        if enabled and UpdateLocalUIBlur then
            pcall(UpdateLocalUIBlur)
        end
    end

    function Window:SetSpiderwebBackground(enabled)
        Window.SpiderwebBGEnabled = enabled
    end

    function Window:SetNoiseEnabled(enabled)
        Window.NoiseEnabled = (enabled == true)
        if Window._NoiseUpdateFunc then
            Window._NoiseUpdateFunc()
        end
        if Window.RegisteredToggles and Window.RegisteredToggles["BackgroundNoise"] then
            local tog = Window.RegisteredToggles["BackgroundNoise"]
            if tog and tog.SetState and tog.GetState and tog:GetState() ~= (enabled == true) then
                pcall(function() tog:SetState(enabled == true, false) end)
            end
        end
    end

    function Window:SetNoiseType(noiseType)
        Window.NoiseType = "Generated"
        if Window._NoiseUpdateFunc then
            Window._NoiseUpdateFunc()
        end
        if Window.RegisteredDropdowns and Window.RegisteredDropdowns["NoiseType"] then
            local dd = Window.RegisteredDropdowns["NoiseType"]
            if dd and dd.SelectOption then
                pcall(function() dd:SelectOption(Window.NoiseType, false) end)
            end
        end
    end

    function Window:SetNoiseSize(size)
        Window.NoiseSize = tonumber(size) or 128
        if Window._NoiseUpdateFunc then
            Window._NoiseUpdateFunc()
        end
        if Window.RegisteredSliders and Window.RegisteredSliders["NoiseSize"] then
            local sld = Window.RegisteredSliders["NoiseSize"]
            if sld and sld.SetValue and sld.GetValue and sld:GetValue() ~= Window.NoiseSize then
                pcall(function() sld:SetValue(Window.NoiseSize, false) end)
            end
        end
    end

    function Window:SetNoiseTransparency(transparency)
        Window.NoiseTransparency = tonumber(transparency) or 0.88
        for _, n in ipairs(Window.NoiseOverlays or {}) do
            if n and n.Parent then
                n.ImageTransparency = Window.NoiseTransparency
            end
        end
    end

    function Window:SetContentBackgroundImage(configOrImage, size, position, zIndex, color, transparency)
        local img, sz, pos, z, col, trans, scaleType
        if type(configOrImage) == "table" then
            img = configOrImage.Image or configOrImage.Asset or configOrImage.Texture or configOrImage[1]
            sz = configOrImage.Size or configOrImage.size
            pos = configOrImage.Position or configOrImage.position or (configOrImage.X and configOrImage.Y and UDim2.new(0, configOrImage.X, 0, configOrImage.Y))
            z = configOrImage.ZIndex or configOrImage.zIndex or configOrImage.Z
            col = configOrImage.Color or configOrImage.ImageColor3 or configOrImage.Color3
            trans = configOrImage.Transparency or configOrImage.ImageTransparency
            scaleType = configOrImage.ScaleType
        else
            img = configOrImage
            sz = size
            pos = position
            z = zIndex
            col = color
            trans = transparency
        end

        local parentTarget = MainContentFrame or Window.MainFrame
        if not Window.ContentBGImage then
            local bgImg = Instance.new("ImageLabel")
            bgImg.Name = "ContentBackgroundImage"
            bgImg.BackgroundTransparency = 1
            bgImg.BorderSizePixel = 0
            bgImg.ScaleType = scaleType or Enum.ScaleType.Stretch
            bgImg.Parent = parentTarget
            Window.ContentBGImage = bgImg
        end

        local bg = Window.ContentBGImage
        if img ~= nil then
            bg.Image = tostring(img):find("://") and tostring(img) or ("rbxassetid://" .. tostring(img))
        end
        if sz ~= nil then bg.Size = sz else bg.Size = UDim2.new(1, 0, 1, 0) end
        if pos ~= nil then bg.Position = pos else bg.Position = UDim2.new(0, 0, 0, 0) end
        if z ~= nil then bg.ZIndex = z else bg.ZIndex = 1 end
        if col ~= nil then bg.ImageColor3 = col else bg.ImageColor3 = Color3.fromRGB(255, 255, 255) end
        if trans ~= nil then bg.ImageTransparency = trans else bg.ImageTransparency = 0 end
        if scaleType ~= nil then bg.ScaleType = scaleType end
        bg.Visible = (bg.Image ~= "")
        return bg
    end

    function Window:SetShadowIntensity(intensity)
        local pct = math.clamp(tonumber(intensity) or 56, 0, 100) / 100
        Window.ShadowIntensity = pct
        Library.ShadowIntensity = pct

        local function applyShadow(shadow, origTrans)
            if not shadow then return end
            local parentCard = shadow.Parent
            local isSuppressed = false
            if parentCard and parentCard:IsA("GuiObject") then
                if parentCard.BackgroundTransparency >= 0.99 then
                    isSuppressed = true
                elseif IsInsideSection(parentCard) and Window.SectionsTransparent then
                    isSuppressed = true
                end
            end
            local baseOpacity = 1 - (origTrans or 0.5)
            local curOpacity = math.clamp(baseOpacity * pct, 0, 1)
            local curTrans = 1 - curOpacity
            local shouldShow = (Window.ShadowsEnabled and pct > 0) and not isSuppressed
            pcall(function() shadow.Enabled = shouldShow end)
            pcall(function() shadow.Visible = shouldShow end)
            pcall(function() shadow.Transparency = shouldShow and curTrans or 1 end)
        end

        for shadow, origTrans in pairs(Library.Shadows) do
            if shadow and shadow.Parent then
                applyShadow(shadow, origTrans)
            else
                Library.Shadows[shadow] = nil
            end
        end

        local roots = {
            ScriptUi,
            Window.ScriptUi,
            Window.MinimisedUI,
            Window.NotificationUI,
            ParentGui
        }
        for _, root in ipairs(roots) do
            if root and typeof(root) == "Instance" and root.Parent then
                pcall(function()
                    for _, desc in ipairs(root:GetDescendants()) do
                        local isShadow = false
                        pcall(function()
                            if desc.ClassName == "UIShadow" or desc:IsA("UIShadow") then
                                isShadow = true
                            end
                        end)
                        if not isShadow and desc.Name and tostring(desc.Name):sub(1, 8) == "UIShadow" then
                            isShadow = true
                        end
                        if isShadow then
                            local orig = Library.Shadows[desc] or (desc.Transparency < 1 and desc.Transparency or 0.5)
                            Library.Shadows[desc] = orig
                            applyShadow(desc, orig)
                        end
                    end
                end)
            end
        end
    end

    function Window:SetShadowsEnabled(enabled)
        enabled = (enabled ~= false)
        Window.ShadowsEnabled = enabled
        Library.ShadowsEnabled = enabled

        local function applyShadowState(shadow, origTrans)
            if not shadow then return end
            local parentCard = shadow.Parent
            local isSuppressed = false
            if parentCard and parentCard:IsA("GuiObject") then
                if parentCard.BackgroundTransparency >= 0.99 then
                    isSuppressed = true
                elseif IsInsideSection(parentCard) and Window.SectionsTransparent then
                    isSuppressed = true
                end
            end
            local intensity = Window.ShadowIntensity or Library.ShadowIntensity or (1 / 1.8)
            local baseOpacity = 1 - (origTrans or 0.5)
            local curOpacity = math.clamp(baseOpacity * intensity, 0, 1)
            local curTrans = 1 - curOpacity
            local shouldShow = (enabled and intensity > 0) and not isSuppressed
            pcall(function() shadow.Enabled = shouldShow end)
            pcall(function() shadow.Visible = shouldShow end)
            pcall(function()
                shadow.Transparency = shouldShow and curTrans or 1
            end)
        end

        for shadow, origTrans in pairs(Library.Shadows) do
            if shadow and shadow.Parent then
                applyShadowState(shadow, origTrans)
            else
                Library.Shadows[shadow] = nil -- prune destroyed ones
            end
        end

        -- Also sweep all UI roots to ensure every shadow node is reached
        local roots = {
            ScriptUi,
            Window.ScriptUi,
            Window.MinimisedUI,
            Window.NotificationUI,
            ParentGui
        }
        for _, root in ipairs(roots) do
            if root and typeof(root) == "Instance" and root.Parent then
                pcall(function()
                    for _, desc in ipairs(root:GetDescendants()) do
                        local isShadow = false
                        local ok = pcall(function()
                            if desc.ClassName == "UIShadow" or desc:IsA("UIShadow") then
                                isShadow = true
                            end
                        end)
                        if not isShadow and desc.Name and tostring(desc.Name):sub(1, 8) == "UIShadow" then
                            isShadow = true
                        end
                        if isShadow then
                            local orig = Library.Shadows[desc]
                            if not orig and desc.Transparency < 1 then
                                orig = desc.Transparency
                            end
                            orig = orig or 0.5
                            Library.Shadows[desc] = orig
                            applyShadowState(desc, orig)
                        end
                    end
                end)
            end
        end
    end

    function Window:SetSectionBGTransparent(enabled)
        enabled = (enabled ~= false)
        Window.SectionsTransparent = enabled
        if not Window.RegisteredSections then return end
        for _, sec in ipairs(Window.RegisteredSections) do
            pcall(function()
                if sec.Card and sec.Card.Parent then
                    sec.Card.BackgroundTransparency = enabled and 1 or (Window.ElementsTransparency or 0.33)
                end
                if sec.Stroke and sec.Stroke.Parent then
                    sec.Stroke.Transparency = enabled and 1 or 0.5
                end
                local cont = sec.Container or sec.ItemContainer
                if cont and cont.Parent then
                    for _, desc in ipairs(cont:GetDescendants()) do
                        if desc:IsA("Frame") and desc.Parent then
                            local dName = desc.Name
                            local isButton = (dName == "MDButtonCard" or dName:find("BtnFrame") or dName == "Btn" or (desc:FindFirstChildOfClass("TextButton") and (dName:find("Btn") or dName:find("Button"))))
                            if not isButton then
                                local isCard = (desc:GetAttribute("MDCard") == true) or dName:find("Card") or dName:find("TextboxFrame") or dName:find("DropdownFrame") or dName:find("BoxFrame")
                                if not isCard and (desc.BackgroundColor3 == Window.CurrentTheme.CardBG or (Window.CurrentTheme and desc.BackgroundColor3 == Window.CurrentTheme.CardBG)) then
                                    isCard = true
                                end
                                if isCard then
                                    desc.BackgroundTransparency = enabled and 1 or (Window.ElementsTransparency or 0.33)
                                    for _, child in ipairs(desc:GetChildren()) do
                                        if child.ClassName == "UIShadow" or child:IsA("UIShadow") or (child.Name and tostring(child.Name):sub(1, 8) == "UIShadow") then
                                            child.Visible = (not enabled) and (Window.ShadowsEnabled and (Window.ShadowIntensity or 1) > 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

end
