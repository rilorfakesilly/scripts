-- modules/theme_manager.lua
-- MorningDrift UI Library: Theme Manager & Visual Effects Module

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local WHITE = Color3.fromRGB(255, 255, 255)
local DEFAULT_DIVIDER = Color3.fromRGB(65, 70, 88)

local DESC_NAMES = {
    CardBody = true, DescLabel = true, WebDesc = true, BlurDesc = true,
    CustomThemeDesc = true, ClickEffectsDesc = true, SubTitle = true,
}
local SKIP_TEXT_NAMES = { LocalTime = true, percloaded = true, Loadingtext = true }
local CUSTOM_THEME_PICKERS = { "CustomTheme", "Custom theme" }

local function luminance(c)
    return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end

local function shallowCopy(t)
    local out = {}
    for k, v in pairs(t) do out[k] = v end
    return out
end

local function isShadowInstance(inst)
    if inst.Name:sub(1, 8) == "UIShadow" then return true end
    local ok, res = pcall(function() return inst.ClassName == "UIShadow" end)
    return ok and res == true
end

-- Calls RefreshTheme on every registered object in `list`, isolating errors.
-- useSelf = true for objects that define RefreshTheme as a method (obj:RefreshTheme()).
local function refreshAll(list, useSelf, ...)
    if not list then return end
    for _, obj in ipairs(list) do
        if obj and obj.RefreshTheme then
            if useSelf then
                pcall(obj.RefreshTheme, obj, ...)
            else
                pcall(obj.RefreshTheme, ...)
            end
        end
    end
end

return function(Library, Window)
    Library.Shadows = Library.Shadows or {}
    Library.ThemePresets = Library.ThemePresets or {}

    local GetThemedDarkColor = Library.GetThemedDarkColor or function(theme)
        return (theme and theme.CardBG) or Color3.fromRGB(30, 32, 40)
    end
    local GetOnAccent = Library.GetOnAccent or function(bg)
        if typeof(bg) ~= "Color3" then return WHITE end
        return luminance(bg) > 0.6 and Color3.fromRGB(20, 22, 28) or WHITE
    end
    local IsInsideSection = Library.IsInsideSection or function() return false end

    local function GetIconColorForTheme(theme)
        if Window.GetIconColorForTheme then return Window.GetIconColorForTheme(theme) end
        if Library.GetIconColorForTheme then return Library.GetIconColorForTheme(theme) end
        if not theme then return WHITE end

        local bg = theme.MainBG or Color3.fromRGB(30, 30, 30)
        local _, s, v = Color3.toHSV(bg)
        if s < 0.3 and v < 0.1 then return WHITE end
        if s < 0.15 and v > 0.85 then return Color3.fromRGB(0, 0, 0) end
        return theme.ButtonBG or theme.Text or WHITE
    end

    ---------------------------------------------------------------------------
    -- Shared helpers
    ---------------------------------------------------------------------------

    local activeThemeTweens = {}
    local function cancelActiveThemeTweens()
        for _, tw in ipairs(activeThemeTweens) do
            pcall(function() tw:Cancel() end)
        end
        table.clear(activeThemeTweens)
    end

    local function themeRoots()
        return {
            Window.ScriptUi, Library.ScriptUi, Window.MinimisedUI,
            Window.NotificationUI, Window.ParentGui, Library.ParentGui,
        }
    end

    -- Single source of truth for shadow visibility/transparency.
    local function refreshShadows(sweep)
        local enabled = Window.ShadowsEnabled ~= false
        local intensity = Window.ShadowIntensity or Library.ShadowIntensity or (1 / 1.8)

        local function apply(shadow, origTrans)
            local parent = shadow.Parent
            local suppressed = false
            if parent and parent:IsA("GuiObject") then
                if parent.BackgroundTransparency >= 0.99 then
                    suppressed = true
                elseif Window.SectionsTransparent and IsInsideSection(parent) then
                    suppressed = true
                end
            end
            local opacity = math.clamp((1 - (origTrans or 0.5)) * intensity, 0, 1)
            local show = enabled and intensity > 0 and not suppressed
            pcall(function() shadow.Enabled = show end)
            pcall(function() shadow.Visible = show end)
            pcall(function() shadow.Transparency = show and (1 - opacity) or 1 end)
        end

        for shadow, orig in pairs(Library.Shadows) do
            if shadow and shadow.Parent then
                apply(shadow, orig)
            else
                Library.Shadows[shadow] = nil
            end
        end

        if not sweep then return end
        -- Sweep for shadows that were never registered.
        local seen = {}
        for _, root in ipairs(themeRoots()) do
            if typeof(root) == "Instance" and root.Parent and not seen[root] then
                seen[root] = true
                pcall(function()
                    for _, desc in ipairs(root:GetDescendants()) do
                        if isShadowInstance(desc) then
                            local orig = Library.Shadows[desc]
                            if not orig then
                                orig = (desc.Transparency < 1) and desc.Transparency or 0.5
                                Library.Shadows[desc] = orig
                            end
                            apply(desc, orig)
                        end
                    end
                end)
            end
        end
    end

    local function syncSlider(key, value)
        local sld = Window.RegisteredSliders and Window.RegisteredSliders[key]
        if sld and sld.SetValue and sld.GetValue and sld:GetValue() ~= value then
            pcall(function() sld:SetValue(value, false) end)
        end
    end

    local function isButtonFrame(f)
        local n = f.Name
        return n == "MDButtonCard" or n:find("BtnFrame") ~= nil or n == "Btn"
            or (f:FindFirstChildOfClass("TextButton") ~= nil and (n:find("Btn") ~= nil or n:find("Button") ~= nil))
    end

    local function isCardFrame(f)
        local n = f.Name
        if f:GetAttribute("MDCard") == true then return true end
        if n:find("Card") or n:find("TextboxFrame") or n:find("DropdownFrame") or n:find("BoxFrame") then
            return true
        end
        local theme = Window.CurrentTheme
        return theme ~= nil and f.BackgroundColor3 == theme.CardBG
    end

    local function setCardTransparency(frame, pct)
        if not (frame and frame.Parent) then return end
        if Window.SectionsTransparent and IsInsideSection(frame) then
            frame.BackgroundTransparency = 1
        else
            frame.BackgroundTransparency = pct
        end
    end

    -- Toggle fallback used when a toggle exposes no RefreshTheme.
    local function refreshToggleFallback(toggle, theme, set)
        if not (toggle.Frame and toggle.Frame.Parent) then return end
        local on = toggle.GetState and toggle.GetState()
        local onAccent = GetOnAccent(theme.ButtonBG)
        if toggle.Overlay then
            set(toggle.Overlay, { ImageColor3 = on and theme.ButtonBG or WHITE })
        end
        if toggle.BaseCircle then
            set(toggle.BaseCircle, { ImageColor3 = on and onAccent or theme.ButtonBG })
        end
        if toggle.CheckIcon then
            set(toggle.CheckIcon, { ImageColor3 = onAccent })
        end
        set(toggle.Frame, { BackgroundColor3 = on and theme.ButtonBG or GetThemedDarkColor(theme) })
    end

    ---------------------------------------------------------------------------
    -- Themes
    ---------------------------------------------------------------------------

    function Window:ApplyTheme(themeKey, animated, silent)
        local preset = Library.ThemePresets[themeKey]
        if not preset then return false end

        cancelActiveThemeTweens()
        animated = (animated ~= false)

        local theme = shallowCopy(preset)
        Window.CurrentTheme = theme
        Window.CurrentThemeKey = themeKey

        if themeKey == "Custom" then
            Window.IsCustomTheme = true
        else
            Window.IsCustomTheme = false
            Window.CustomThemeColor = nil
            local pickers = Window.RegisteredColorPickers
            if pickers then
                for _, key in ipairs(CUSTOM_THEME_PICKERS) do
                    local cp = pickers[key]
                    if cp and cp.SetColor then
                        pcall(cp.SetColor, theme.ButtonBG, false)
                    end
                end
            end
        end

        local tweenInfo = TweenInfo.new(animated and 0.35 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        local function set(inst, props)
            if not inst then return end
            if animated then
                local tw = TweenService:Create(inst, tweenInfo, props)
                activeThemeTweens[#activeThemeTweens + 1] = tw
                tw:Play()
            else
                for k, v in pairs(props) do inst[k] = v end
            end
        end

        -- Core frames
        local frameColor = theme.MainBG
        local frameTrans = Window.TopBottomTransparency or theme.TopTrans or 0.12

        set(Window.MainFrame, {
            BackgroundColor3 = theme.TopBG or theme.AccentBG,
            BackgroundTransparency = Window.CustomBGTransparency or theme.MainTrans,
        })
        for _, frame in ipairs({ Window.LeftFrame, Window.TopFrame, Window.BottomFrame }) do
            if frame then
                if frame == Window.BottomFrame then
                    local grad = frame:FindFirstChildOfClass("UIGradient")
                    if grad then grad:Destroy() end
                end
                set(frame, { BackgroundColor3 = frameColor, BackgroundTransparency = frameTrans })
            end
        end

        -- Sidebar
        set(Window.SidebarScroll, { ScrollBarImageColor3 = theme.Divider })
        set(Window.SidebarCollapseBtn, { ImageColor3 = theme.Text })

        for _, div in ipairs(Window.SidebarDividers or {}) do
            if div and div.Parent then
                local img = div:IsA("ImageLabel") and div or div:FindFirstChildOfClass("ImageLabel")
                if img then
                    set(img, { ImageColor3 = theme.Divider, BackgroundTransparency = 1 })
                else
                    set(div, { BackgroundColor3 = theme.Divider, BackgroundTransparency = 1 })
                end
            end
        end

        -- Branding / header
        if Window._MDicon and Window._MDicon.Parent then
            if Window.PlayerProfileEnabled then
                Window._MDicon.ImageColor3 = WHITE
            else
                set(Window._MDicon, { ImageColor3 = GetIconColorForTheme(theme) })
            end
        end
        set(Window._MadebyText, { TextColor3 = theme.Text })
        set(Window.MadebyText, { TextColor3 = theme.Text })
        set(Window.MDHUBNAME, { TextColor3 = theme.Text })
        set(Window.DiscordBtn, { TextColor3 = theme.SubText })
        set(Window.LocalTime, { TextColor3 = theme.Text })
        set(Window.WelcomeMsg, { TextColor3 = theme.Text })
        if Window.ResizeArcStroke and Window.ResizeArcStroke.Parent then
            set(Window.ResizeArcStroke, { Color = theme.Text })
        end

        if Window.ActiveTabGlow and Window.ActiveTabGlow.Parent then
            local bright = luminance(theme.MainBG or Color3.fromRGB(25, 27, 34)) > 0.6
            set(Window.ActiveTabGlow, {
                BackgroundColor3 = bright and Color3.fromRGB(30, 32, 40) or Color3.fromRGB(220, 225, 235),
                BackgroundTransparency = bright and 0.90 or 0.88,
            })
        end

        -- Buttons
        for _, btn in ipairs(Window.RegisteredMDButtons or {}) do
            if btn and btn.RefreshTheme then
                pcall(btn.RefreshTheme, theme)
            elseif btn and btn.Frame and btn.Frame.Parent then
                local onAccent = GetOnAccent(theme.ButtonBG)
                set(btn.Frame, { BackgroundColor3 = theme.ButtonBG })
                set(btn.TextLabel, { TextColor3 = onAccent })
                set(btn.ArrowIcon, { ImageColor3 = onAccent })
                if btn.Stroke then
                    btn.Stroke.Color = WHITE
                    btn.Stroke.Thickness = 1.2
                end
            end
        end

        -- Toggles (list + keyed registry, de-duplicated)
        local refreshed = {}
        local function refreshToggle(toggle)
            if not toggle or refreshed[toggle] then return end
            refreshed[toggle] = true
            if toggle.RefreshTheme then
                pcall(toggle.RefreshTheme, theme, animated)
            else
                refreshToggleFallback(toggle, theme, set)
            end
        end
        for _, toggle in ipairs(Window.RegisteredMDToggles or {}) do refreshToggle(toggle) end
        for _, toggle in pairs(Window.RegisteredToggles or {}) do refreshToggle(toggle) end

        -- Sliders
        for _, slider in ipairs(Window.RegisteredMDSliders or {}) do
            if slider and slider.RefreshTheme then
                pcall(slider.RefreshTheme, theme)
            elseif slider and slider.Track and slider.Track.Parent then
                set(slider.Track, { BackgroundColor3 = GetThemedDarkColor(theme) })
                set(slider.FilledPart, { BackgroundColor3 = theme.ButtonBG })
                set(slider.Overlay, { ImageColor3 = theme.ButtonBG })
                set(slider.ValueLabel, { TextColor3 = theme.Text })
            end
        end

        refreshAll(Window.RegisteredTextboxesList, false, theme)
        refreshAll(Window.RegisteredDropdownsList, false, theme)
        refreshAll(Window.RegisteredColorPickersList, false, theme)
        refreshAll(Window.RegisteredMobileButtons, false, theme)
        refreshAll(Window.RegisteredSections, true, theme, animated)
        refreshAll(Window.RegisteredLabels, false, theme)
        refreshAll(Window.RegisteredDividers, false, theme, animated)
        refreshAll(Window.RegisteredMultiDropdownsList, false, theme)
        refreshAll(Window.RegisteredNumberInputsList, false, theme)
        refreshAll(Window.RegisteredSubTabs, false, theme, animated)

        -- Keybind badges
        for _, badge in ipairs(Window.RegisteredKeybindBadges or {}) do
            if badge and badge.Container and badge.Container.Parent then
                set(badge.Container, { BackgroundColor3 = GetThemedDarkColor(theme) })
                set(badge.Label, { TextColor3 = theme.Text })
                set(badge.DeleteBtn, { ImageColor3 = theme.Text })
            end
        end

        -- Search bar
        if Window.SearchBarContainer then
            set(Window.SearchBarContainer, { BackgroundColor3 = GetThemedDarkColor(theme) })
            set(Window.SearchInput, { TextColor3 = theme.Text })
            if Window.SearchInput then Window.SearchInput.PlaceholderColor3 = theme.SubText end
            set(Window.SearchIcon, { ImageColor3 = theme.SubText })
            set(Window.ClearSearchBtn, { ImageColor3 = theme.SubText })
        end

        -- Minimized icon layers
        if Window.MinimizedImage and Window.MinimizedLayers then
            local grad = theme.MinGradient or theme.BottomGradient
            local color = (grad and grad[1]) or theme.AccentBG or theme.Text or WHITE
            for _, layer in ipairs(Window.MinimizedLayers) do
                if layer and layer.Parent then
                    set(layer, { ImageColor3 = color })
                end
            end
        end

        -- Keep transparency sliders in sync with the theme
        syncSlider("BGTransparency", math.floor((Window.CustomBGTransparency or theme.MainTrans or 0.12) * 100))
        syncSlider("TopBottomTransparency", math.floor((Window.TopBottomTransparency or theme.TopTrans or 0.12) * 100))
        syncSlider("ElementsTransparency", math.floor((Window.ElementsTransparency or 0.33) * 100))

        -- Theme preset buttons
        if Window.UpdateThemeSwatches then
            pcall(function() Window:UpdateThemeSwatches() end)
        elseif Window.ThemePresetBtnMap then
            for key, btn in pairs(Window.ThemePresetBtnMap) do
                if btn then
                    if btn.Stroke then btn.Stroke.Thickness = (key == themeKey) and 2.2 or 1.2 end
                    if btn.Frame then btn.Frame.BackgroundColor3 = theme.ButtonBG end
                    if btn.TextLabel then btn.TextLabel.TextColor3 = theme.Text end
                end
            end
        end
        if Window.ThemeCard then
            Window.ThemeCard.BackgroundColor3 = theme.CardBG
            Window.ThemeCard.BackgroundTransparency = theme.AccentTrans or 0.12
            local title = Window.ThemeCard:FindFirstChild("ThemeTitle", true)
            if title then title.TextColor3 = theme.Text end
        end

        -- Deep tab traversal
        for name, tab in pairs(Window.Tabs or {}) do
            local active = (name == Window.ActiveTab)
            local tabColor = active and theme.Text or theme.SubText
            set(tab.Button, { TextColor3 = tabColor })
            set(tab.Icon, { ImageColor3 = tabColor })

            local content = tab.ContentFrame
            if content then
                set(content, { ScrollBarImageColor3 = theme.Divider })
                for _, desc in ipairs(content:GetDescendants()) do
                    local dName = desc.Name
                    if desc:IsA("TextLabel") then
                        if DESC_NAMES[dName] or dName:find("Desc") then
                            set(desc, { TextColor3 = theme.SubText })
                        elseif not SKIP_TEXT_NAMES[dName] then
                            set(desc, { TextColor3 = theme.Text })
                        end
                    elseif desc:IsA("TextBox") then
                        if dName ~= "HexBox" then
                            set(desc, { TextColor3 = theme.Text, PlaceholderColor3 = theme.SubText })
                        end
                    elseif desc:IsA("ImageLabel") then
                        if dName == "ArrowIcon" or dName == "SearchIcon" then
                            set(desc, { ImageColor3 = theme.SubText })
                        end
                    elseif desc:IsA("Frame") then
                        if dName:find("Card") and dName ~= "MDButtonCard" and dName ~= "TogglePill" then
                            set(desc, { BackgroundColor3 = theme.CardBG })
                        elseif dName == "SectionColumns" or dName == "LeftColumn" or dName == "RightColumn"
                            or dName:find("Row") or dName:find("Group") then
                            desc.BackgroundTransparency = 1
                        end
                    elseif desc:IsA("UIStroke") then
                        local p = desc.Parent
                        if p and p:IsA("Frame") and p.Name:find("SectionCard") then
                            desc.Color = theme.Divider or DEFAULT_DIVIDER
                        end
                    end
                end
            end
        end

        refreshAll(Window.RegisteredCustom, false, theme)

        if not silent and Window.Notify then
            Window:Notify("Theme updated", "Applied " .. tostring(theme.Name or themeKey) .. " theme!", 2.5)
        end
        return true
    end

    -- Builds a full palette from a single base color.
    local function buildGrayscalePalette(v)
        local isDark = v < 0.55
        local p = {}
        if v <= 0.10 then
            p.mainBG, p.accentBG, p.topBG = Color3.fromRGB(13, 13, 16), Color3.fromRGB(19, 19, 24), Color3.fromRGB(24, 24, 28)
            p.cardBG, p.buttonBG, p.divider = Color3.fromRGB(16, 16, 20), Color3.fromRGB(34, 34, 42), Color3.fromRGB(55, 55, 65)
            p.text, p.subText = Color3.fromRGB(245, 245, 250), Color3.fromRGB(150, 150, 165)
            p.bot = { Color3.fromRGB(22, 22, 28), Color3.fromRGB(36, 36, 46), Color3.fromRGB(18, 18, 24) }
            p.min = { Color3.fromRGB(32, 32, 40), Color3.fromRGB(50, 50, 62), Color3.fromRGB(28, 28, 36) }
        elseif v >= 0.88 then
            p.mainBG, p.accentBG, p.topBG = Color3.fromRGB(238, 240, 246), Color3.fromRGB(224, 228, 236), Color3.fromRGB(246, 248, 252)
            p.cardBG, p.buttonBG, p.divider = Color3.fromRGB(255, 255, 255), Color3.fromRGB(210, 216, 228), Color3.fromRGB(175, 182, 196)
            p.text, p.subText = Color3.fromRGB(20, 22, 28), Color3.fromRGB(90, 95, 110)
            p.bot = { Color3.fromRGB(220, 225, 236), Color3.fromRGB(245, 247, 252), Color3.fromRGB(210, 216, 228) }
            p.min = { Color3.fromRGB(215, 220, 232), Color3.fromRGB(250, 252, 255), Color3.fromRGB(205, 212, 225) }
        else
            local function g(mul, add, lo, hi) return Color3.fromHSV(0, 0, math.clamp(v * mul + add, lo, hi)) end
            p.mainBG, p.accentBG, p.topBG = g(0.45, 0.05, 0.10, 0.70), g(0.60, 0.08, 0.14, 0.76), g(0.65, 0.10, 0.16, 0.82)
            p.cardBG, p.buttonBG, p.divider = g(0.40, 0.06, 0.08, 0.90), g(0.85, 0.15, 0.22, 0.88), g(0.70, 0.20, 0.25, 0.85)
            p.text = isDark and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(20, 22, 28)
            p.subText = isDark and Color3.fromRGB(160, 165, 180) or Color3.fromRGB(85, 90, 105)
            p.bot = { g(0.50, 0.08, 0.15, 0.75), g(0.75, 0.12, 0.25, 0.85), g(0.45, 0.06, 0.12, 0.70) }
            p.min = { g(0.60, 0.10, 0.20, 0.80), g(0.90, 0.10, 0.35, 0.98), g(0.55, 0.08, 0.18, 0.75) }
        end
        return p
    end

    local function buildChromaticPalette(h, s, v)
        local function c(sMul, sLo, sHi, vMul, vLo, vHi)
            return Color3.fromHSV(h, math.clamp(s * sMul, sLo, sHi), math.clamp(v * vMul, vLo, vHi))
        end
        local p = {}
        p.buttonBG = c(0.88, 0.05, 0.95, 0.78, 0.20, 0.82)
        p.accentBG = c(0.75, 0.04, 0.80, 0.45, 0.12, 0.55)
        p.topBG = c(0.70, 0.04, 0.75, 0.38, 0.10, 0.50)
        p.mainBG = c(0.65, 0.03, 0.60, 0.24, 0.06, 0.38)
        p.cardBG = c(0.60, 0.03, 0.55, 0.16, 0.04, 0.28)
        p.divider = c(0.90, 0.05, 0.95, 0.75, 0.20, 0.85)
        p.text = Color3.fromRGB(245, 245, 250)
        p.subText = Color3.fromHSV(h, math.clamp(s * 0.25, 0.02, 0.35), 0.85)
        p.bot = { c(0.80, 0.05, 0.85, 0.35, 0.10, 0.45), c(0.85, 0.05, 0.90, 0.55, 0.18, 0.65), c(0.80, 0.05, 0.85, 0.30, 0.08, 0.40) }
        p.min = { c(0.90, 0.08, 0.95, 0.65, 0.25, 0.80), c(0.75, 0.05, 0.80, 0.95, 0.45, 1.0), c(0.90, 0.08, 0.95, 0.70, 0.28, 0.85) }
        return p
    end

    function Window:ApplyCustomTheme(baseColor, animated, silent)
        if typeof(baseColor) ~= "Color3" then return false end
        Window.CustomThemeColor = baseColor

        local h, s, v = baseColor:ToHSV()
        local p = (s <= 0.05) and buildGrayscalePalette(v) or buildChromaticPalette(h, s, v)
        local topTrans = Window.TopBottomTransparency or 0.12

        Library.ThemePresets["Custom"] = {
            Name = "Custom",
            MainBG = p.mainBG,
            MainTrans = Window.CustomBGTransparency or 0.12,
            AccentBG = p.topBG,
            AccentTrans = topTrans,
            TopBG = p.topBG,
            TopTrans = topTrans,
            BottomBG = p.topBG,
            BottomTrans = topTrans,
            BottomGradient = p.bot,
            MinGradient = p.min,
            Divider = p.divider,
            Text = p.text,
            SubText = p.subText,
            CardBG = p.cardBG,
            ButtonBG = p.buttonBG,
        }

        return Window:ApplyTheme("Custom", animated, silent)
    end

    ---------------------------------------------------------------------------
    -- Transparency
    ---------------------------------------------------------------------------

    function Window:SetBackgroundTransparency(transparency)
        local pct = math.clamp(tonumber(transparency) or 0.12, 0, 0.95)
        Window.CustomBGTransparency = pct
        if Window.MainFrame then Window.MainFrame.BackgroundTransparency = pct end
        syncSlider("BGTransparency", math.floor(pct * 100))
    end

    function Window:SetElementsTransparency(transparency)
        local pct = math.clamp(tonumber(transparency) or 0.33, 0, 0.95)
        Window.ElementsTransparency = pct

        for _, sec in ipairs(Window.RegisteredSections or {}) do
            if sec then
                if sec.Card and sec.Card.Parent and not Window.SectionsTransparent then
                    sec.Card.BackgroundTransparency = pct
                end
                local cont = sec.Container or sec.ItemContainer
                if cont and cont.Parent then
                    for _, desc in ipairs(cont:GetDescendants()) do
                        if desc:IsA("Frame") and not isButtonFrame(desc) and isCardFrame(desc) then
                            desc.BackgroundTransparency = Window.SectionsTransparent and 1 or pct
                        end
                    end
                end
            end
        end

        local registries = {
            Window.RegisteredMDButtons, Window.RegisteredMDToggles, Window.RegisteredMDSliders,
            Window.RegisteredDropdownsList, Window.RegisteredTextboxesList, Window.RegisteredColorPickersList,
        }
        for _, list in ipairs(registries) do
            for _, obj in ipairs(list or {}) do
                setCardTransparency(obj and (obj.CardFrame or obj.Frame), pct)
            end
        end

        syncSlider("ElementsTransparency", math.floor(pct * 100))
    end

    function Window:SetTopBottomTransparency(transparency)
        local pct = math.clamp(tonumber(transparency) or 0.12, 0, 0.95)
        Window.TopBottomTransparency = pct
        for _, frame in ipairs({ Window.TopFrame, Window.LeftFrame, Window.BottomFrame }) do
            if frame and frame.Parent then frame.BackgroundTransparency = pct end
        end
        syncSlider("TopBottomTransparency", math.floor(pct * 100))
    end

    function Window:SetSectionBGTransparent(enabled)
        enabled = (enabled ~= false)
        Window.SectionsTransparent = enabled

        for _, sec in ipairs(Window.RegisteredSections or {}) do
            pcall(function()
                local elemTrans = Window.ElementsTransparency or 0.33
                if sec.Card and sec.Card.Parent then
                    sec.Card.BackgroundTransparency = enabled and 1 or elemTrans
                end
                if sec.Stroke and sec.Stroke.Parent then
                    sec.Stroke.Transparency = enabled and 1 or 0.5
                end
                local cont = sec.Container or sec.ItemContainer
                if cont and cont.Parent then
                    for _, desc in ipairs(cont:GetDescendants()) do
                        if desc:IsA("Frame") and not isButtonFrame(desc) and isCardFrame(desc) then
                            desc.BackgroundTransparency = enabled and 1 or elemTrans
                        end
                    end
                end
            end)
        end

        refreshShadows()
    end

    ---------------------------------------------------------------------------
    -- Shadows
    ---------------------------------------------------------------------------

    function Window:SetShadowIntensity(intensity)
        local pct = math.clamp(tonumber(intensity) or 56, 0, 100) / 100
        Window.ShadowIntensity = pct
        Library.ShadowIntensity = pct
        refreshShadows(true)
    end

    function Window:SetShadowsEnabled(enabled)
        enabled = (enabled ~= false)
        Window.ShadowsEnabled = enabled
        Library.ShadowsEnabled = enabled
        refreshShadows(true)
    end

    ---------------------------------------------------------------------------
    -- Sound
    ---------------------------------------------------------------------------

    function Window:SetUISounds(enabled)
        Window.UISoundsEnabled = enabled and true or false
    end

    function Window:SetSoundVolume(volume)
        local pct = math.clamp(tonumber(volume) or 0.8, 0, 1)
        Window.SoundVolume = pct
        if Window.HoverSoundTemplate then Window.HoverSoundTemplate.Volume = pct * 0.4 end
        if Window.ClickSoundTemplate then Window.ClickSoundTemplate.Volume = pct * 0.5 end
        if Window.NotifSoundTemplate then Window.NotifSoundTemplate.Volume = pct * 0.5 end
    end

    ---------------------------------------------------------------------------
    -- Blur
    ---------------------------------------------------------------------------

    function Window:SetBlurIntensity(val)
        local num = tonumber(val) or 1.0
        if num > 1 then num = num / 100 end
        num = math.clamp(num, 0, 1)
        Window.BlurIntensity = num
        if Window.BackgroundDOF and Window.BackgroundDOF.Parent then
            Window.BackgroundDOF.NearIntensity = num
        end
    end

    function Window:SetBackgroundBlur(enabled)
        enabled = enabled and true or false
        Window.BackgroundBlurEnabled = enabled

        local dof = Window.BackgroundDOF
        if dof and dof.Parent then
            dof.Enabled = enabled
            if enabled then dof.NearIntensity = Window.BlurIntensity or 0.5 end
        elseif enabled then
            dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "ScriptHubDOF"
            dof.FocusDistance = 2.5
            dof.InFocusRadius = 0
            dof.NearIntensity = Window.BlurIntensity or 0.5
            dof.FarIntensity = 0
            dof.Enabled = true
            dof.Parent = Lighting
            Window.BackgroundDOF = dof
        end

        local part = Window.LocalUIBlurPart
        if part and part.Parent then
            part.Transparency = enabled and 0.98 or 1
        elseif enabled then
            part = Instance.new("Part")
            part.Name = "LocalUIBlurPart"
            part.Material = Enum.Material.Glass
            part.Transparency = 0.98
            part.Color = WHITE
            part.CastShadow = false
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Anchored = true
            part.Size = Vector3.new(1, 1, 0.01)
            part.Parent = workspace
            Window.LocalUIBlurPart = part
        end

        if enabled and Window.UpdateLocalUIBlur then
            pcall(Window.UpdateLocalUIBlur)
        end
    end

    function Window:SetSpiderwebBackground(enabled)
        Window.SpiderwebBGEnabled = enabled and true or false
    end

    ---------------------------------------------------------------------------
    -- Noise
    ---------------------------------------------------------------------------

    local function updateNoise()
        if Window._NoiseUpdateFunc then Window._NoiseUpdateFunc() end
    end

    function Window:SetNoiseEnabled(enabled)
        enabled = (enabled == true)
        Window.NoiseEnabled = enabled
        updateNoise()
        local tog = Window.RegisteredToggles and Window.RegisteredToggles["BackgroundNoise"]
        if tog and tog.SetState and tog.GetState and tog:GetState() ~= enabled then
            pcall(function() tog:SetState(enabled, false) end)
        end
    end

    function Window:SetNoiseType()
        -- Only the generated noise texture is supported.
        Window.NoiseType = "Generated"
        updateNoise()
        local dd = Window.RegisteredDropdowns and Window.RegisteredDropdowns["NoiseType"]
        if dd and dd.SelectOption then
            pcall(function() dd:SelectOption(Window.NoiseType, false) end)
        end
    end

    function Window:SetNoiseSize(size)
        Window.NoiseSize = math.clamp(tonumber(size) or 128, 16, 1024)
        updateNoise()
        local sld = Window.RegisteredSliders and Window.RegisteredSliders["NoiseSize"]
        if sld and sld.SetValue and sld.GetValue and sld:GetValue() ~= Window.NoiseSize then
            pcall(function() sld:SetValue(Window.NoiseSize, false) end)
        end
    end

    function Window:SetNoiseTransparency(transparency)
        Window.NoiseTransparency = math.clamp(tonumber(transparency) or 0.88, 0, 1)
        for _, n in ipairs(Window.NoiseOverlays or {}) do
            if n and n.Parent then n.ImageTransparency = Window.NoiseTransparency end
        end
    end

    ---------------------------------------------------------------------------
    -- Content background image
    ---------------------------------------------------------------------------

    function Window:SetContentBackgroundImage(configOrImage, size, position, zIndex, color, transparency)
        local img, sz, pos, z, col, trans, scaleType
        if type(configOrImage) == "table" then
            local c = configOrImage
            img = c.Image or c.Asset or c.Texture or c[1]
            sz = c.Size or c.size
            pos = c.Position or c.position or (c.X and c.Y and UDim2.new(0, c.X, 0, c.Y)) or nil
            z = c.ZIndex or c.zIndex or c.Z
            col = c.Color or c.ImageColor3 or c.Color3
            trans = c.Transparency or c.ImageTransparency
            scaleType = c.ScaleType
        else
            img, sz, pos, z, col, trans = configOrImage, size, position, zIndex, color, transparency
        end

        local parent = Window.MainFrame
        if not parent then return nil end

        local bg = Window.ContentBGImage
        if not (bg and bg.Parent) then
            bg = Instance.new("ImageLabel")
            bg.Name = "ContentBackgroundImage"
            bg.BackgroundTransparency = 1
            bg.BorderSizePixel = 0
            bg.ScaleType = Enum.ScaleType.Stretch
            bg.Parent = parent
            Window.ContentBGImage = bg
        end

        if img ~= nil then
            local str = tostring(img)
            bg.Image = str:find("://") and str or ("rbxassetid://" .. str)
        end
        bg.Size = sz or UDim2.new(1, 0, 1, 0)
        bg.Position = pos or UDim2.new(0, 0, 0, 0)
        bg.ZIndex = z or 1
        bg.ImageColor3 = col or WHITE
        bg.ImageTransparency = trans or 0
        if scaleType ~= nil then bg.ScaleType = scaleType end
        bg.Visible = (bg.Image ~= "")
        return bg
    end
end
