-- modules/config_system.lua
-- MorningDrift UI Library: Configuration Management Module
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

return function(Library, Window)
    local HttpService = game:GetService("HttpService")
    Window.KnownConfigs = Window.KnownConfigs or {}

    local function GetConfigFolderPath()
        local name = Window.ScriptName or Window.Title or "default"
        local sanitized = name:gsub("[^%w_%-]", "_")
        return "MD_Configs/" .. sanitized
    end

    local function GetAutoloadFilePath()
        return GetConfigFolderPath() .. "/autoload.txt"
    end

    local function EnsureConfigFolder()
        pcall(function()
            local folder = GetConfigFolderPath()
            if makefolder then
                if isfolder then
                    if not isfolder("MD_Configs") then makefolder("MD_Configs") end
                    if not isfolder(folder) then makefolder(folder) end
                else
                    pcall(makefolder, "MD_Configs")
                    pcall(makefolder, folder)
                end
            end
        end)
    end
    EnsureConfigFolder()

    local function GetConfigList()
        local list = {"DEFAULT"}
        local seen = {["DEFAULT"] = true}

        -- always include autoload config if set
        local auto = Window:GetAutoloadConfig()
        if auto and auto ~= "" and auto:upper() ~= "DEFAULT" and auto:upper() ~= "NONE" then
            if not seen[auto] then
                seen[auto] = true
                table.insert(list, auto)
            end
        end

        -- include in-memory registered configs
        if Window.KnownConfigs then
            for name in pairs(Window.KnownConfigs) do
                if name and name ~= "" and not seen[name] then
                    seen[name] = true
                    table.insert(list, name)
                end
            end
        end

        -- scan config folder on disk
        local folder = GetConfigFolderPath()
        pcall(function()
            if listfiles then
                local files = nil
                local ok, res = pcall(listfiles, folder)
                if ok and type(res) == "table" then
                    files = res
                elseif isfolder and isfolder(folder) then
                    local ok2, res2 = pcall(listfiles, folder)
                    if ok2 and type(res2) == "table" then files = res2 end
                end

                if files then
                    for _, filePath in ipairs(files) do
                        local fileName = tostring(filePath):match("([^/\\]+)%.json$")
                        if fileName and fileName ~= "DEFAULT" and not fileName:find("^TAB_") then
                            if not seen[fileName] then
                                seen[fileName] = true
                                table.insert(list, fileName)
                            end
                        end
                    end
                end
            end
        end)

        return list
    end

    function Window:GetAutoloadConfig()
        local autoloadName = nil
        pcall(function()
            local paths = {
                GetAutoloadFilePath(),
                "MD_Configs/" .. ((Window.ScriptName or "default"):gsub("[^%w_%-]", "_")) .. "/autoload.txt",
                "MD_Configs/autoload.txt"
            }
            for _, p in ipairs(paths) do
                if readfile and isfile and isfile(p) then
                    local content = readfile(p)
                    if content then
                        content = content:gsub("^%s+", ""):gsub("%s+$", "")
                        if content ~= "" and content:upper() ~= "NONE" then
                            autoloadName = content
                            Window.KnownConfigs = Window.KnownConfigs or {}
                            Window.KnownConfigs[autoloadName] = true
                            break
                        end
                    end
                end
            end
        end)
        return autoloadName
    end

    function Window:SetAutoloadConfig(configName)
        EnsureConfigFolder()
        local filePath = GetAutoloadFilePath()
        if not configName or configName == "" or configName:upper() == "NONE" then
            pcall(function()
                if delfile and isfile and isfile(filePath) then
                    delfile(filePath)
                end
            end)
            if Window.ConfigDropdown and Window.ConfigDropdown.RefreshOptions then
                Window.ConfigDropdown.RefreshOptions(GetConfigList())
            end
            return nil
        else
            local nameStr = tostring(configName):gsub("^%s+", ""):gsub("%s+$", "")
            pcall(function()
                if writefile then
                    writefile(filePath, nameStr)
                end
            end)
            Window.KnownConfigs = Window.KnownConfigs or {}
            Window.KnownConfigs[nameStr] = true
            if Window.ConfigDropdown and Window.ConfigDropdown.RefreshOptions then
                Window.ConfigDropdown.RefreshOptions(GetConfigList())
                Window.ConfigDropdown.SetSelected(nameStr, false)
            end
            return nameStr
        end
    end

    function Window:GetConfigSaveData()
        local data = {
            Theme = Window.CurrentThemeKey or "Dark",
            SidebarCollapsed = Window.SidebarCollapsed == true,
            Settings = {
                Spiderweb = (Window.SpiderwebBGEnabled ~= nil) and Window.SpiderwebBGEnabled or Window.SpiderwebEnabled,
                Blur = Window.BackgroundBlurEnabled,
                Sounds = Window.UISoundsEnabled,
                SoundVolume = Window.SoundVolume or 0.8,
                HoverSound = Window.HoverSoundId or "88894490577328",
                ClickSound = Window.ClickSoundId or "86313632275410",
                NotifSound = Window.NotifSoundId or "97455084935031",
                Notifications = Window.NotificationsEnabled,
                CustomThemeColor = (Window.IsCustomTheme and Window.CustomThemeColor) and Window.CustomThemeColor:ToHex() or nil,
                BGTransparency = Window.CustomBGTransparency or 0.22,
                ElementsTransparency = Window.ElementsTransparency or 0.33,
                TopBottomTransparency = Window.TopBottomTransparency or (Window.CurrentTheme and Window.CurrentTheme.TopTrans) or 0.30,
                Shadows = Window.ShadowsEnabled,
                ShadowIntensity = math.floor((Window.ShadowIntensity or (1 / 1.8)) * 100),
                SectionBGTransparent = Window.SectionsTransparent,
                ClickEffects = Window.ClickEffectsEnabled,
                ClickParticle = Window.ClickParticleType or "Theme default",
                CustomParticle = Window.CustomParticleAsset or "",
                NoiseEnabled = Window.NoiseEnabled == true,
                NoiseType = Window.NoiseType or "Texture",
                NoiseSize = Window.NoiseSize or 128
            },
            Toggles = {},
            ToggleBinds = {},
            Sliders = {},
            Textboxes = {},
            Dropdowns = {},
            MultiDropdowns = {},
            NumberInputs = {},
            ColorPickers = {},
            MobileButtons = {}
        }
        if Window.RegisteredMDToggles then
            for _, toggle in ipairs(Window.RegisteredMDToggles) do
                pcall(function()
                    local key = toggle.SaveKey or toggle.Name
                    if key then
                        if toggle.GetState then
                            data.Toggles[key] = toggle.GetState()
                        end
                        if toggle.Keybind and toggle.Keybind.CurrentKey then
                            data.ToggleBinds[key] = toggle.Keybind.CurrentKey.Name
                        end
                    end
                end)
            end
        end
        if Window.RegisteredToggles then
            for key, toggle in pairs(Window.RegisteredToggles) do
                if key and data.Toggles[key] == nil and type(toggle) == "table" and toggle.GetState then
                    pcall(function()
                        data.Toggles[key] = toggle.GetState()
                    end)
                end
            end
        end
        if Window.RegisteredMDSliders then
            for _, slider in ipairs(Window.RegisteredMDSliders) do
                pcall(function()
                    local key = slider.SaveKey or slider.Name
                    if key and slider.GetValue then
                        data.Sliders[key] = slider.GetValue()
                    end
                end)
            end
        end
        if Window.RegisteredTextboxesList then
            for _, box in ipairs(Window.RegisteredTextboxesList) do
                pcall(function()
                    local key = box.SaveKey or box.Name
                    if key and box.GetText then
                        data.Textboxes[key] = box.GetText()
                    end
                end)
            end
        end
        if Window.RegisteredDropdownsList then
            for _, drop in ipairs(Window.RegisteredDropdownsList) do
                pcall(function()
                    local key = drop.SaveKey or drop.Name
                    if key and drop.GetSelected then
                        data.Dropdowns[key] = drop.GetSelected()
                    end
                    if key and (drop.GetOptions or drop.GetValues) then
                        local opts = (drop.GetOptions and drop.GetOptions()) or (drop.GetValues and drop.GetValues())
                        if opts and type(opts) == "table" then
                            data.DropdownOptions = data.DropdownOptions or {}
                            data.DropdownOptions[key] = opts
                        end
                    end
                end)
            end
        end
        if Window.RegisteredMultiDropdownsList then
            for _, mdrop in ipairs(Window.RegisteredMultiDropdownsList) do
                pcall(function()
                    local key = mdrop.SaveKey or mdrop.Name
                    if key and mdrop.GetSelections then
                        data.MultiDropdowns[key] = mdrop.GetSelections()
                    end
                end)
            end
        end
        if Window.RegisteredNumberInputsList then
            for _, numInput in ipairs(Window.RegisteredNumberInputsList) do
                pcall(function()
                    local key = numInput.SaveKey or numInput.Name
                    if key and numInput.GetValue then
                        data.NumberInputs[key] = numInput.GetValue()
                    end
                end)
            end
        end
        if Window.RegisteredColorPickersList then
            for _, cp in ipairs(Window.RegisteredColorPickersList) do
                pcall(function()
                    local key = cp.SaveKey or cp.Name
                    if key and cp.GetColor then
                        local c = cp.GetColor()
                        if typeof(c) == 'Color3' then
                            data.ColorPickers[key] = c:ToHex()
                        end
                    end
                end)
            end
        end
        if Window.RegisteredMobileButtons then
            for idx, mb in ipairs(Window.RegisteredMobileButtons) do
                pcall(function()
                    local key = mb.SaveKey or (mb.Text and mb.Text ~= "" and mb.Text) or ("MobileBtn_" .. idx)
                    local pos = mb.Frame and mb.Frame.Position
                    data.MobileButtons[key] = {
                        Visible = (mb.GetVisible and mb:GetVisible()) or (mb.Frame and mb.Frame.Visible),
                        State = mb.IsToggle and mb.State or nil,
                        Position = pos and {
                            XScale = pos.X.Scale,
                            XOffset = pos.X.Offset,
                            YScale = pos.Y.Scale,
                            YOffset = pos.Y.Offset
                        }
                    }
                end)
            end
        end
        return data
    end

    function Window:ApplyConfigSaveData(data)
        if not data then return end

        if data.Theme == "Custom" and data.Settings and data.Settings.CustomThemeColor and data.Settings.CustomThemeColor ~= "" and Window.ApplyCustomTheme then
            pcall(function()
                local col = Color3.fromHex(data.Settings.CustomThemeColor)
                Window:ApplyCustomTheme(col, false)
            end)
        elseif data.Theme and Library.ThemePresets[data.Theme] then
            if Window.ApplyTheme then
                pcall(function() Window:ApplyTheme(data.Theme, false) end)
            else
                Window.CurrentTheme = Library.ThemePresets[data.Theme]
                Window.CurrentThemeKey = data.Theme
            end
        elseif data.Settings and data.Settings.CustomThemeColor and data.Settings.CustomThemeColor ~= "" and Window.ApplyCustomTheme then
            pcall(function()
                local col = Color3.fromHex(data.Settings.CustomThemeColor)
                Window:ApplyCustomTheme(col, false)
            end)
        end

        if data.Settings then
            if data.Settings.Spiderweb ~= nil and Window.SetSpiderwebBackground then
                pcall(function() Window:SetSpiderwebBackground(data.Settings.Spiderweb) end)
            end
            if data.Settings.Blur ~= nil and Window.SetBackgroundBlur then
                pcall(function() Window:SetBackgroundBlur(data.Settings.Blur) end)
            end
            if data.Settings.Sounds ~= nil and Window.SetUISounds then
                pcall(function() Window:SetUISounds(data.Settings.Sounds) end)
            end
            if data.Settings.SoundVolume ~= nil and Window.SetSoundVolume then
                pcall(function() Window:SetSoundVolume(data.Settings.SoundVolume) end)
            end
            if data.Settings.HoverSound ~= nil and Window.SetHoverSound then
                pcall(function()
                    Window:SetHoverSound(data.Settings.HoverSound)
                    local box = Window.RegisteredTextboxes and Window.RegisteredTextboxes["HoverSound"]
                    if box and box.SetText then box.SetText(data.Settings.HoverSound) end
                end)
            end
            if data.Settings.ClickSound ~= nil and Window.SetClickSound then
                pcall(function()
                    Window:SetClickSound(data.Settings.ClickSound)
                    local box = Window.RegisteredTextboxes and Window.RegisteredTextboxes["ClickSound"]
                    if box and box.SetText then box.SetText(data.Settings.ClickSound) end
                end)
            end
            if data.Settings.NotifSound ~= nil and Window.SetNotificationSound then
                pcall(function()
                    Window:SetNotificationSound(data.Settings.NotifSound)
                    local box = Window.RegisteredTextboxes and Window.RegisteredTextboxes["NotifSound"]
                    if box and box.SetText then box.SetText(data.Settings.NotifSound) end
                end)
            end
            if data.Settings.Notifications ~= nil then
                Window.NotificationsEnabled = data.Settings.Notifications
            end
            if data.Settings.BGTransparency ~= nil and Window.SetBackgroundTransparency then
                pcall(function() Window:SetBackgroundTransparency(data.Settings.BGTransparency) end)
            end
            if data.Settings.ElementsTransparency ~= nil and Window.SetElementsTransparency then
                pcall(function()
                    Window:SetElementsTransparency(data.Settings.ElementsTransparency)
                    local sld = Window.RegisteredSliders and Window.RegisteredSliders["ElementsTransparency"]
                    if sld and sld.SetValue then sld.SetValue(math.floor(data.Settings.ElementsTransparency * 100), false) end
                end)
            end
            if data.Settings.TopBottomTransparency ~= nil and Window.SetTopBottomTransparency then
                pcall(function()
                    Window:SetTopBottomTransparency(data.Settings.TopBottomTransparency)
                    local sld = Window.RegisteredSliders and Window.RegisteredSliders["TopBottomTransparency"]
                    if sld and sld.SetValue then sld.SetValue(math.floor(data.Settings.TopBottomTransparency * 100), false) end
                end)
            end
            if data.Settings.Shadows ~= nil then
                pcall(function()
                    Window:SetShadowsEnabled(data.Settings.Shadows)
                    local t = Window.RegisteredToggles["Shadows"]
                    if t and t.SetState then t.SetState(data.Settings.Shadows, false) end -- sync the switch visually
                end)
            end
            if data.Settings.ShadowIntensity ~= nil and Window.SetShadowIntensity then
                pcall(function()
                    Window:SetShadowIntensity(data.Settings.ShadowIntensity)
                    local sld = Window.RegisteredSliders and Window.RegisteredSliders["ShadowIntensity"]
                    if sld and sld.SetValue then sld.SetValue(data.Settings.ShadowIntensity, false) end
                end)
            end
            if data.Settings.SectionBGTransparent ~= nil then
                pcall(function()
                    Window:SetSectionBGTransparent(data.Settings.SectionBGTransparent)
                    local t = Window.RegisteredToggles["SectionBGTransparent"]
                    -- toggle is "Section backgrounds" which is ON when NOT transparent
                    if t and t.SetState then t.SetState(not data.Settings.SectionBGTransparent, false) end
                end)
            end
            if data.Settings.ClickEffects ~= nil then
                Window.ClickEffectsEnabled = data.Settings.ClickEffects
            end
            if data.Settings.ClickParticle ~= nil then
                Window.ClickParticleType = data.Settings.ClickParticle
            end
            if data.Settings.CustomParticle ~= nil then
                Window.CustomParticleAsset = data.Settings.CustomParticle
            end
            if data.Settings.NoiseEnabled ~= nil and Window.SetNoiseEnabled then
                pcall(function() Window:SetNoiseEnabled(data.Settings.NoiseEnabled) end)
            end
            if data.Settings.NoiseType ~= nil and Window.SetNoiseType then
                pcall(function() Window:SetNoiseType(data.Settings.NoiseType) end)
            end
            if data.Settings.NoiseSize ~= nil and Window.SetNoiseSize then
                pcall(function() Window:SetNoiseSize(data.Settings.NoiseSize) end)
            end
        end

        if data.SidebarCollapsed ~= nil and Window.SetSidebarCollapsed then
            pcall(function() Window:SetSidebarCollapsed(data.SidebarCollapsed) end)
        end

        if data.Toggles then
            for name, state in pairs(data.Toggles) do
                local toggle = Window.RegisteredToggles[name]
                if not toggle and Window.RegisteredMDToggles then
                    for _, t in ipairs(Window.RegisteredMDToggles) do
                        if t.SaveKey == name or t.Name == name or t.Identifier == name then
                            toggle = t
                            break
                        end
                    end
                end
                if toggle and toggle.SetState then
                    pcall(function() toggle.SetState(state, true) end)
                end
            end
        end

        if data.ToggleBinds then
            for name, bindKeyName in pairs(data.ToggleBinds) do
                local toggle = Window.RegisteredToggles[name]
                if toggle then
                    pcall(function()
                        if bindKeyName and bindKeyName ~= "" and bindKeyName ~= "None" then
                            local keyCode = Enum.KeyCode[bindKeyName]
                            if keyCode then
                                if toggle.Keybind and toggle.Keybind.SetKey then
                                    toggle.Keybind.SetKey(keyCode, false)
                                elseif toggle.WithKeybind then
                                    toggle:WithKeybind(keyCode)
                                end
                            end
                        elseif bindKeyName == "" or bindKeyName == "None" or bindKeyName == nil then
                            if toggle.Keybind and toggle.Keybind.ClearKey then
                                toggle.Keybind.ClearKey(false)
                            end
                        end
                    end)
                end
            end
        end

        if data.Sliders then
            for name, val in pairs(data.Sliders) do
                local slider = Window.RegisteredSliders[name]
                    or Window.RegisteredSliders[name .. "_Slider"]
                    or (Window.RegisteredToggles[name] and Window.RegisteredToggles[name].ConnectedSlider)
                if not slider and name:sub(-7) == "_Slider" then
                    local baseName = name:sub(1, -8)
                    slider = (Window.RegisteredToggles[baseName] and Window.RegisteredToggles[baseName].ConnectedSlider)
                        or Window.RegisteredSliders[baseName]
                end
                if not slider and name:sub(-6) == "Volume" then
                    local baseName = name:sub(1, -7)
                    slider = (Window.RegisteredToggles[baseName] and Window.RegisteredToggles[baseName].ConnectedSlider)
                        or Window.RegisteredSliders[baseName]
                        or Window.RegisteredSliders[baseName .. "_Slider"]
                end
                if slider and slider.SetValue then
                    pcall(function() slider.SetValue(val, true) end)
                end
            end
        end

        if data.Textboxes then
            for name, text in pairs(data.Textboxes) do
                local box = Window.RegisteredTextboxes[name]
                if box and box.SetText then
                    pcall(function() box.SetText(text, true) end)
                end
            end
        end

        if data.DropdownOptions then
            for name, opts in pairs(data.DropdownOptions) do
                local drop = Window.RegisteredDropdowns[name]
                if drop and drop.SetOptions then
                    pcall(function()
                        local currentOpts = (drop.InitialOptions and #drop.InitialOptions > 0 and drop.InitialOptions)
                            or (drop.GetOptions and drop.GetOptions())
                        if currentOpts and type(currentOpts) == "table" and #currentOpts > 0 then
                            local merged = {}
                            local seen = {}
                            for _, opt in ipairs(currentOpts) do
                                table.insert(merged, opt)
                                seen[tostring(opt)] = true
                            end
                            if type(opts) == "table" then
                                for _, opt in ipairs(opts) do
                                    if not seen[tostring(opt)] then
                                        table.insert(merged, opt)
                                        seen[tostring(opt)] = true
                                    end
                                end
                            end
                            drop.SetOptions(merged)
                        else
                            drop.SetOptions(opts)
                        end
                    end)
                elseif drop and drop.RefreshOptions then
                    pcall(function() drop.RefreshOptions(opts) end)
                end
            end
        end

        if data.Dropdowns then
            for name, selected in pairs(data.Dropdowns) do
                local drop = Window.RegisteredDropdowns[name]
                if drop and drop.SetSelected then
                    pcall(function()
                        local validOpts = (drop.GetOptions and drop.GetOptions()) or (drop.GetValues and drop.GetValues())
                        local isValid = false
                        if validOpts and type(validOpts) == "table" and #validOpts > 0 then
                            for _, v in ipairs(validOpts) do
                                if tostring(v) == tostring(selected) then
                                    isValid = true
                                    break
                                end
                            end
                        else
                            isValid = true
                        end
                        if isValid then
                            drop.SetSelected(selected, true)
                        else
                            local fallback = drop.DefaultOption or (validOpts and validOpts[1])
                            if fallback then
                                drop.SetSelected(fallback, true)
                            end
                        end
                    end)
                end
            end
        end

        if data.MultiDropdowns then
            for name, selected in pairs(data.MultiDropdowns) do
                local mdrop = Window.RegisteredMultiDropdowns[name]
                if mdrop and mdrop.SetSelections then
                    pcall(function()
                        local validOpts = (mdrop.GetOptions and mdrop.GetOptions()) or (mdrop.GetValues and mdrop.GetValues())
                        if validOpts and type(validOpts) == "table" and #validOpts > 0 and type(selected) == "table" then
                            local validSet = {}
                            for _, v in ipairs(validOpts) do validSet[tostring(v)] = true end
                            local filtered = {}
                            for k, v in pairs(selected) do
                                local optStr = (type(k) == "number") and tostring(v) or tostring(k)
                                if validSet[optStr] then
                                    if type(k) == "number" then
                                        table.insert(filtered, optStr)
                                    else
                                        filtered[optStr] = v
                                    end
                                end
                            end
                            mdrop.SetSelections(filtered, true)
                        else
                            mdrop.SetSelections(selected, true)
                        end
                    end)
                end
            end
        end

        if data.NumberInputs then
            for name, val in pairs(data.NumberInputs) do
                local numInput = Window.RegisteredNumberInputs[name]
                if numInput and numInput.SetValue then
                    pcall(function() numInput.SetValue(val, true) end)
                end
            end
        end

        if data.ColorPickers then
            for name, hex in pairs(data.ColorPickers) do
                local cp = Window.RegisteredColorPickers[name] or (name == "Custom theme" and Window.RegisteredColorPickers["CustomTheme"]) or (name == "CustomTheme" and Window.RegisteredColorPickers["Custom theme"])
                if cp and cp.SetColor then
                    pcall(function()
                        local col = Color3.fromHex(hex)
                        local isThemeCP = (name == "CustomTheme" or name == "Custom theme" or name:lower():gsub("%s+", "") == "customtheme")
                        if isThemeCP then
                            cp.SetColor(col, false)
                        else
                            cp.SetColor(col, true)
                        end
                    end)
                end
            end
        end

        if data.MobileButtons and Window.RegisteredMobileButtons then
            for key, info in pairs(data.MobileButtons) do
                for idx, mb in ipairs(Window.RegisteredMobileButtons) do
                    local mbKey = mb.SaveKey or (mb.Text and mb.Text ~= "" and mb.Text) or ("MobileBtn_" .. idx)
                    if mbKey == key or tostring(idx) == tostring(key) then
                        if info.Visible ~= nil and mb.SetVisible then
                            mb:SetVisible(info.Visible)
                        end
                        if mb.IsToggle and info.State ~= nil and mb.SetState then
                            mb:SetState(info.State, false)
                        end
                        if info.Position and mb.Frame then
                            mb.Frame.Position = UDim2.new(
                                info.Position.XScale or mb.Frame.Position.X.Scale,
                                info.Position.XOffset or mb.Frame.Position.X.Offset,
                                info.Position.YScale or mb.Frame.Position.Y.Scale,
                                info.Position.YOffset or mb.Frame.Position.Y.Offset
                            )
                        end
                        break
                    end
                end
            end
        end

        if Window.ConfigLoadedCallbacks then
            for _, fn in ipairs(Window.ConfigLoadedCallbacks) do
                pcall(fn, data)
            end
        end
    end

    local DefaultConfigMemoryData = nil

    local function ResolveUniqueConfigName(requestedName)
        requestedName = requestedName:gsub("^%s+", ""):gsub("%s+$", "")
        if requestedName == "" then requestedName = "Config" end
        if requestedName:upper() == "DEFAULT" then return "DEFAULT" end

        local existingConfigs = GetConfigList()
        local exists = false
        for _, name in ipairs(existingConfigs) do
            if name == requestedName then
                exists = true
                break
            end
        end

        if not exists then
            return requestedName
        end

        local baseCopyName = requestedName .. " copy"
        local copyIndex = 1
        local candidateName = baseCopyName

        while true do
            local candidateExists = false
            for _, name in ipairs(existingConfigs) do
                if name == candidateName then
                    candidateExists = true
                    break
                end
            end
            if not candidateExists then
                return candidateName
            end
            copyIndex = copyIndex + 1
            candidateName = baseCopyName .. " " .. copyIndex
        end
    end

    function Window:SaveConfig(configName)
        configName = configName or "DEFAULT"

        if configName:upper() == "DEFAULT" then
            Window:Notify("Config error", "Default config cannot be overwritten!", 3)
            return false
        end

        local finalName = ResolveUniqueConfigName(configName)
        local saveData = Window:GetConfigSaveData()
        local jsonString = HttpService:JSONEncode(saveData)

        EnsureConfigFolder()
        local filePath = GetConfigFolderPath() .. "/" .. finalName .. ".json"
        local success = pcall(function()
            if writefile then
                writefile(filePath, jsonString)
            end
        end)

        if success then
            Window.KnownConfigs = Window.KnownConfigs or {}
            Window.KnownConfigs[finalName] = true
            Window:Notify("Config saved", "Saved config as '" .. finalName .. "'", 2.5)
            if Window.ConfigSavedCallbacks then
                for _, fn in ipairs(Window.ConfigSavedCallbacks) do
                    pcall(fn, finalName, saveData)
                end
            end
            if Window.ConfigDropdown and Window.ConfigDropdown.RefreshOptions then
                Window.ConfigDropdown.RefreshOptions(GetConfigList())
                Window.ConfigDropdown.SetSelected(finalName, false)
            end
            return finalName
        else
            Window:Notify("Config error", "Failed to write config file", 3)
            return false
        end
    end

    function Window:RewriteConfig(configName)
        if not configName or configName:upper() == "DEFAULT" then
            Window:Notify("Config error", "Default config cannot be overwritten!", 3)
            return false
        end

        local saveData = Window:GetConfigSaveData()
        local jsonString = HttpService:JSONEncode(saveData)
        EnsureConfigFolder()
        local filePath = GetConfigFolderPath() .. "/" .. configName .. ".json"
        local success = pcall(function()
            if writefile then writefile(filePath, jsonString) end
        end)

        if success then
            Window.KnownConfigs = Window.KnownConfigs or {}
            Window.KnownConfigs[configName] = true
            Window:Notify("Config rewritten", "Overwrote '" .. configName .. "'!", 2.5)
            if Window.ConfigSavedCallbacks then
                for _, fn in ipairs(Window.ConfigSavedCallbacks) do
                    pcall(fn, configName, saveData)
                end
            end
            if Window.ConfigDropdown and Window.ConfigDropdown.RefreshOptions then
                Window.ConfigDropdown.RefreshOptions(GetConfigList())
                Window.ConfigDropdown.SetSelected(configName, false)
            end
            return true
        else
            Window:Notify("Config error", "Failed to overwrite file", 3)
            return false
        end
    end

    function Window:SnapshotDefaultConfig()
        DefaultConfigMemoryData = Window:GetConfigSaveData()
        return DefaultConfigMemoryData
    end

    function Window:LoadConfig(configName)
        configName = configName or "DEFAULT"

        if configName:upper() == "DEFAULT" then
            if not DefaultConfigMemoryData then
                DefaultConfigMemoryData = Window:GetConfigSaveData()
            end
            if DefaultConfigMemoryData then
                Window:ApplyConfigSaveData(DefaultConfigMemoryData)
            end
            if Window.ConfigDropdown and Window.ConfigDropdown.SetSelected then
                Window.ConfigDropdown.SetSelected("DEFAULT", false)
            end
            Window:Notify("Config loaded", "Loaded default config!", 2.5)
            return true
        end

        EnsureConfigFolder()
        local filePath = GetConfigFolderPath() .. "/" .. configName .. ".json"
        local loadedData = nil

        pcall(function()
            if readfile and isfile and isfile(filePath) then
                local content = readfile(filePath)
                loadedData = HttpService:JSONDecode(content)
            end
        end)

        if loadedData then
            Window.KnownConfigs = Window.KnownConfigs or {}
            Window.KnownConfigs[configName] = true
            Window:ApplyConfigSaveData(loadedData)
            if Window.ConfigDropdown then
                if Window.ConfigDropdown.RefreshOptions then
                    Window.ConfigDropdown.RefreshOptions(GetConfigList())
                end
                if Window.ConfigDropdown.SetSelected then
                    Window.ConfigDropdown.SetSelected(configName, false)
                end
            end
            Window:Notify("Config loaded", "Loaded '" .. configName .. "'!", 2.5)
            return true
        else
            Window:Notify("Config error", "Config '" .. configName .. "' not found!", 3)
            return false
        end
    end

    function Window:DeleteConfig(configName)
        if not configName or configName:upper() == "DEFAULT" then
            Window:Notify("Config error", "Default config cannot be deleted!", 3)
            return false
        end

        EnsureConfigFolder()
        local filePath = GetConfigFolderPath() .. "/" .. configName .. ".json"
        local success = pcall(function()
            if delfile and isfile and isfile(filePath) then
                delfile(filePath)
            end
        end)

        if success then
            if Window.KnownConfigs then
                Window.KnownConfigs[configName] = nil
            end
            Window:Notify("Config deleted", "Deleted config '" .. configName .. "'", 2.5)
            if Window.ConfigDropdown and Window.ConfigDropdown.RefreshOptions then
                Window.ConfigDropdown.RefreshOptions(GetConfigList())
                Window.ConfigDropdown.SetSelected("DEFAULT", false)
            end
            return true
        else
            Window:Notify("Config error", "Failed to delete config file", 3)
            return false
        end
    end

    function Window:ExportConfigToClipboard()
        local saveData = Window:GetConfigSaveData()
        local jsonString = HttpService:JSONEncode(saveData)
        local success = pcall(function()
            if setclipboard then
                setclipboard(jsonString)
            elseif toclipboard then
                toclipboard(jsonString)
            end
        end)
        if success then
            Window:Notify("Config Exported", "Config copied to clipboard as JSON!", 2.5)
            return jsonString
        else
            Window:Notify("Export Error", "Clipboard not supported on this executor", 3)
            return nil
        end
    end

    function Window:ImportConfigFromClipboard(jsonOverride)
        local jsonString = jsonOverride
        if not jsonString then
            pcall(function()
                if getclipboard then
                    jsonString = getclipboard()
                end
            end)
        end
        if not jsonString or jsonString == "" then
            Window:Notify("Import Error", "Clipboard is empty or not accessible", 3)
            return false
        end
        local success, loadedData = pcall(function()
            return HttpService:JSONDecode(jsonString)
        end)
        if success and type(loadedData) == "table" then
            Window:ApplyConfigSaveData(loadedData)
            Window:Notify("Config Imported", "Applied configuration from clipboard!", 2.5)
            return true
        else
            Window:Notify("Import Error", "Invalid JSON config data in clipboard", 3)
            return false
        end
    end

    function Window:SaveTabConfig(tabName, configName)
        if not tabName or tabName == "" then return false end
        configName = configName or "TabConfig"
        local fullSave = Window:GetConfigSaveData()
        local tabData = {
            Tab = tabName,
            Toggles = {},
            Sliders = {},
            Textboxes = {},
            Dropdowns = {},
            MultiDropdowns = {},
            NumberInputs = {},
            ColorPickers = {}
        }
        for _, item in ipairs(Window.SearchableItems) do
            if item.TabName == tabName then
                local n = item.Name
                if item.Type == "Toggle" and fullSave.Toggles[n] ~= nil then
                    tabData.Toggles[n] = fullSave.Toggles[n]
                elseif item.Type == "Slider" and fullSave.Sliders[n] ~= nil then
                    tabData.Sliders[n] = fullSave.Sliders[n]
                elseif item.Type == "Textbox" and fullSave.Textboxes[n] ~= nil then
                    tabData.Textboxes[n] = fullSave.Textboxes[n]
                elseif item.Type == "Dropdown" and fullSave.Dropdowns[n] ~= nil then
                    tabData.Dropdowns[n] = fullSave.Dropdowns[n]
                elseif item.Type == "MultiDropdown" and fullSave.MultiDropdowns[n] ~= nil then
                    tabData.MultiDropdowns[n] = fullSave.MultiDropdowns[n]
                elseif item.Type == "NumberInput" and fullSave.NumberInputs[n] ~= nil then
                    tabData.NumberInputs[n] = fullSave.NumberInputs[n]
                elseif item.Type == "Color picker" and fullSave.ColorPickers[n] ~= nil then
                    tabData.ColorPickers[n] = fullSave.ColorPickers[n]
                end
            end
        end
        local jsonString = HttpService:JSONEncode(tabData)
        EnsureConfigFolder()
        local filePath = GetConfigFolderPath() .. "/TAB_" .. tabName:gsub("[^%w_%-]", "_") .. "_" .. configName .. ".json"
        local success = pcall(function()
            if writefile then writefile(filePath, jsonString) end
        end)
        if success then
            Window:Notify("Tab config saved", "Saved '" .. tabName .. "' config as '" .. configName .. "'", 2.5)
            return true
        else
            Window:Notify("Config error", "Failed to write tab config file", 3)
            return false
        end
    end

    function Window:LoadTabConfig(tabName, configName)
        if not tabName or tabName == "" then return false end
        configName = configName or "TabConfig"
        EnsureConfigFolder()
        local filePath = GetConfigFolderPath() .. "/TAB_" .. tabName:gsub("[^%w_%-]", "_") .. "_" .. configName .. ".json"
        local loadedData = nil
        pcall(function()
            if readfile and isfile and isfile(filePath) then
                local content = readfile(filePath)
                loadedData = HttpService:JSONDecode(content)
            end
        end)
        if loadedData and type(loadedData) == "table" then
            Window:ApplyConfigSaveData(loadedData)
            Window:Notify("Tab config loaded", "Loaded '" .. tabName .. "' config '" .. configName .. "'!", 2.5)
            return true
        else
            Window:Notify("Config error", "Tab config '" .. configName .. "' not found!", 3)
            return false
        end
    end


    function Window:CreateConfigSection(parentTab)
        local configSec = parentTab:AddSection("Configurations", true)
        local SectionFrame = configSec.Container or configSec.ItemContainer

        local PasteBoxFrame, PasteBoxStroke, PasteLabel, PasteInput

        local origSecRefresh = configSec.RefreshTheme
        configSec.RefreshTheme = function(self, theme, anim)
            if origSecRefresh then origSecRefresh(self, theme, anim) end
            local twInfo = TweenInfo.new(anim and 0.35 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local divColor = theme.Divider or Color3.fromRGB(80, 85, 100)
            if anim then
                if PasteBoxFrame then TweenService:Create(PasteBoxFrame, twInfo, {BackgroundColor3 = theme.CardBG}):Play() end
                if PasteBoxStroke then TweenService:Create(PasteBoxStroke, twInfo, {Color = divColor}):Play() end
                if PasteLabel then TweenService:Create(PasteLabel, twInfo, {TextColor3 = theme.SubText}):Play() end
                if PasteInput then TweenService:Create(PasteInput, twInfo, {TextColor3 = theme.Text, PlaceholderColor3 = theme.SubText}):Play() end
            else
                if PasteBoxFrame then PasteBoxFrame.BackgroundColor3 = theme.CardBG end
                if PasteBoxStroke then PasteBoxStroke.Color = divColor end
                if PasteLabel then PasteLabel.TextColor3 = theme.SubText end
                if PasteInput then
                    PasteInput.TextColor3 = theme.Text
                    PasteInput.PlaceholderColor3 = theme.SubText
                end
            end
        end

        local nameBoxObj = Window:CreateMDTextbox(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "Config name", "MyConfig", nil)

        local currentAuto = Window:GetAutoloadConfig()
        local initialSelected = (currentAuto and currentAuto ~= "" and currentAuto:upper() ~= "NONE") and currentAuto or "DEFAULT"

        local configDropdownObj = Window:CreateMDDropdown(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "", GetConfigList(), initialSelected, nil, {
            GetOptions = GetConfigList
        })
        Window.ConfigDropdown = configDropdownObj
        configDropdownObj.SetSelected(initialSelected, false)

        local Row1 = Instance.new("Frame")
        Row1.Name = GenerateSafeName("Row")
        Row1.Size = UDim2.new(1, 0, 0, 31)
        Row1.BackgroundTransparency = 1
        Row1.BorderSizePixel = 0
        Row1.ZIndex = 4
        Row1.Parent = SectionFrame

        local autoloadBtn = nil

        local function GetAutoloadButtonLabel()
            local auto = Window:GetAutoloadConfig()
            if auto and auto ~= "" and auto:upper() ~= "NONE" then
                return "Autoload config: " .. auto
            else
                return "Autoload config: None"
            end
        end

        Window:CreateMDButtonLong(Row1, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 1, 0), "Create config", function()
            local requested = nameBoxObj.GetText()
            local savedName = Window:SaveConfig(requested)
            if savedName then
                configDropdownObj.RefreshOptions(GetConfigList())
                configDropdownObj.SetSelected(savedName, false)
            end
        end)

        Window:CreateMDButtonLong(Row1, UDim2.new(0.515, 4, 0, 0), UDim2.new(0.485, -4, 1, 0), "Delete config", function()
            local current = configDropdownObj.GetSelected()
            if not current or current == "" or current:upper() == "DEFAULT" then
                Window:Notify("Config error", "Default config cannot be deleted!", 3)
                return
            end
            Window:Confirm({
                Title = "Delete Config",
                Message = "Are you sure you want to delete '" .. current .. "'?\nThis action cannot be undone.",
                ConfirmText = "Delete",
                CancelText = "Cancel",
                OnConfirm = function()
                    if Window:DeleteConfig(current) then
                        configDropdownObj.RefreshOptions(GetConfigList())
                        configDropdownObj.SetSelected("DEFAULT", false)
                        if Window:GetAutoloadConfig() == current then
                            Window:SetAutoloadConfig(nil)
                            if autoloadBtn and autoloadBtn.TextLabel then
                                autoloadBtn.TextLabel.Text = GetAutoloadButtonLabel()
                            end
                        end
                    end
                end
            })
        end)

        local Row2 = Instance.new("Frame")
        Row2.Name = GenerateSafeName("Row")
        Row2.Size = UDim2.new(1, 0, 0, 31)
        Row2.BackgroundTransparency = 1
        Row2.BorderSizePixel = 0
        Row2.ZIndex = 4
        Row2.Parent = SectionFrame

        Window:CreateMDButtonLong(Row2, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 1, 0), "Overwrite config", function()
            local current = configDropdownObj.GetSelected()
            Window:RewriteConfig(current)
        end)

        Window:CreateMDButtonLong(Row2, UDim2.new(0.515, 4, 0, 0), UDim2.new(0.485, -4, 1, 0), "Load config", function()
            local current = configDropdownObj.GetSelected()
            Window:LoadConfig(current)
        end)

        local ShareSection = Instance.new("Frame")
        ShareSection.Name = GenerateSafeName("ShareSection")
        ShareSection.Size = UDim2.new(1, 0, 0, 104)
        ShareSection.BackgroundTransparency = 1
        ShareSection.BorderSizePixel = 0
        ShareSection.ZIndex = 4
        ShareSection.Parent = SectionFrame

        local ShareLayout = Instance.new("UIListLayout")
        ShareLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ShareLayout.Padding = UDim.new(0, 6)
        ShareLayout.Parent = ShareSection

        PasteLabel = Instance.new("TextLabel")
        PasteLabel.Name = GenerateSafeName("Label")
        PasteLabel.Size = UDim2.new(1, 0, 0, 16)
        PasteLabel.LayoutOrder = 1
        PasteLabel.BackgroundTransparency = 1
        PasteLabel.FontFace = FontFingerPaintRegular
        PasteLabel.Text = "Paste config JSON here to import:"
        PasteLabel.TextColor3 = Window.CurrentTheme.SubText
        PasteLabel.TextSize = 11
        PasteLabel.TextXAlignment = Enum.TextXAlignment.Left
        PasteLabel.ZIndex = 5
        PasteLabel.Parent = ShareSection

        PasteBoxFrame = Instance.new("Frame")
        PasteBoxFrame.Name = GenerateSafeName("Box")
        PasteBoxFrame.Size = UDim2.new(1, 0, 0, 44)
        PasteBoxFrame.LayoutOrder = 2
        PasteBoxFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        PasteBoxFrame.BackgroundTransparency = 0.1
        PasteBoxFrame.BorderSizePixel = 0
        PasteBoxFrame.ZIndex = 5
        PasteBoxFrame.Parent = ShareSection

        local PasteBoxCorner = Instance.new("UICorner")
        PasteBoxCorner.CornerRadius = UDim.new(0, 8)
        PasteBoxCorner.Parent = PasteBoxFrame

        PasteBoxStroke = Instance.new("UIStroke")
        PasteBoxStroke.Thickness = 1
        PasteBoxStroke.Transparency = 0.6
        PasteBoxStroke.Color = Window.CurrentTheme.Divider or Color3.fromRGB(80, 85, 100)
        PasteBoxStroke.Parent = PasteBoxFrame

        PasteInput = Instance.new("TextBox")
        PasteInput.Name = GenerateSafeName("Input")
        PasteInput.Size = UDim2.new(1, -16, 1, -8)
        PasteInput.Position = UDim2.new(0, 8, 0, 4)
        PasteInput.BackgroundTransparency = 1
        PasteInput.BorderSizePixel = 0
        PasteInput.FontFace = FontFingerPaintRegular
        PasteInput.PlaceholderText = "{\"...\"}"
        PasteInput.PlaceholderColor3 = Window.CurrentTheme.SubText
        PasteInput.Text = ""
        PasteInput.TextColor3 = Window.CurrentTheme.Text
        PasteInput.TextSize = 11
        PasteInput.TextWrapped = true
        PasteInput.MultiLine = true
        PasteInput.ClearTextOnFocus = false
        PasteInput.ClipsDescendants = true
        PasteInput.ZIndex = 6
        PasteInput.Parent = PasteBoxFrame

        local ShareBtnRow = Instance.new("Frame")
        ShareBtnRow.Name = GenerateSafeName("BtnRow")
        ShareBtnRow.Size = UDim2.new(1, 0, 0, 36)
        ShareBtnRow.LayoutOrder = 3
        ShareBtnRow.BackgroundTransparency = 1
        ShareBtnRow.BorderSizePixel = 0
        ShareBtnRow.ZIndex = 4
        ShareBtnRow.Parent = ShareSection

        -- "Copy Export" - writes to clipboard so user can share
        Window:CreateMDButtonLong(ShareBtnRow, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 1, 0), "Copy Config", function()
            local jsonString = Window:ExportConfigToClipboard()
            if jsonString then
                -- Also populate the paste box so user can see/edit what was exported
                PasteInput.Text = jsonString
            end
        end)

        -- Import config parsed from input textbox
        Window:CreateMDButtonLong(ShareBtnRow, UDim2.new(0.515, 4, 0, 0), UDim2.new(0.485, -4, 1, 0), "Import Config", function()
            local text = PasteInput.Text
            if not text or text == "" then
                Window:Notify("Import", "Paste your config JSON into the box first", 3)
                return
            end
            local ok = Window:ImportConfigFromClipboard(text)
            if ok then
                PasteInput.Text = ""
            end
        end)



        autoloadBtn = Window:CreateMDButtonLong(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 31), GetAutoloadButtonLabel(), function()
            local selected = configDropdownObj.GetSelected()
            local currentAuto = Window:GetAutoloadConfig()
            if currentAuto == selected then
                Window:SetAutoloadConfig(nil)
                Window:Notify("Autoload", "Disabled config autoload", 2.5)
            else
                Window:SetAutoloadConfig(selected)
                Window:Notify("Autoload", "Set '" .. selected .. "' as autoload config!", 2.5)
            end
            configDropdownObj.RefreshOptions(GetConfigList())
            if autoloadBtn and autoloadBtn.TextLabel then
                autoloadBtn.TextLabel.Text = GetAutoloadButtonLabel()
            end
        end)

        parentTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, parentTab.Layout.AbsoluteContentSize.Y + 20)
        return SectionFrame
    end


end
