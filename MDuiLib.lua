local Library = {}
Library.Version = "2.7"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ParentGui = CoreGui
if gethui then
    ParentGui = gethui()
elseif syn and syn.protect_gui then
    ParentGui = Instance.new("Folder")
    syn.protect_gui(ParentGui)
    ParentGui.Parent = CoreGui
end

local FontMichromaBold = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
local FontMichromaRegular = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local FontMichromaHeavy = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)

Library.ThemePresets = {
    Dark = {
        Name = "Dark",
        MainBG = Color3.fromRGB(32, 34, 42),
        MainTrans = 0.10,
        AccentBG = Color3.fromRGB(45, 48, 60),
        AccentTrans = 0.20,
        TopBG = Color3.fromRGB(45, 48, 60),
        TopTrans = 0.05,
        BottomBG = Color3.fromRGB(45, 48, 60),
        BottomTrans = 0.0,
        BottomGradient = {
            Color3.fromRGB(45, 48, 60),
            Color3.fromRGB(60, 64, 80),
            Color3.fromRGB(40, 42, 54)
        },
        MinGradient = {
            Color3.fromRGB(65, 75, 100),
            Color3.fromRGB(90, 105, 140),
            Color3.fromRGB(50, 60, 85)
        },
        Divider = Color3.fromRGB(65, 70, 88),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(180, 185, 200),
        CardBG = Color3.fromRGB(25, 27, 34),
        ButtonBG = Color3.fromRGB(45, 48, 60),
    },
    Original = {
        Name = "Original orange",
        MainBG = Color3.fromRGB(134, 59, 15),
        MainTrans = 0.15,
        AccentBG = Color3.fromRGB(209, 100, 21),
        AccentTrans = 0.40,
        TopBG = Color3.fromRGB(171, 72, 22),
        TopTrans = 0.05,
        BottomBG = Color3.fromRGB(211, 177, 163),
        BottomTrans = 0,
        BottomGradient = {
            Color3.fromRGB(165, 74, 4),
            Color3.fromRGB(193, 106, 43),
            Color3.fromRGB(150, 86, 22)
        },
        MinGradient = {
            Color3.fromRGB(255, 107, 8),
            Color3.fromRGB(255, 166, 93),
            Color3.fromRGB(255, 113, 19)
        },
        Divider = Color3.fromRGB(182, 91, 41),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(235, 235, 235),
        CardBG = Color3.fromRGB(110, 48, 12),
        ButtonBG = Color3.fromRGB(171, 72, 22),
    },
    White = {
        Name = "White",
        MainBG = Color3.fromRGB(242, 244, 248),
        MainTrans = 0.05,
        AccentBG = Color3.fromRGB(220, 225, 235),
        AccentTrans = 0.10,
        TopBG = Color3.fromRGB(210, 215, 228),
        TopTrans = 0.0,
        BottomBG = Color3.fromRGB(210, 215, 228),
        BottomTrans = 0.0,
        BottomGradient = {
            Color3.fromRGB(210, 215, 228),
            Color3.fromRGB(230, 235, 245),
            Color3.fromRGB(200, 205, 220)
        },
        MinGradient = {
            Color3.fromRGB(200, 210, 235),
            Color3.fromRGB(240, 245, 255),
            Color3.fromRGB(180, 195, 225)
        },
        Divider = Color3.fromRGB(180, 190, 210),
        Text = Color3.fromRGB(30, 32, 40),
        SubText = Color3.fromRGB(70, 75, 90),
        CardBG = Color3.fromRGB(255, 255, 255),
        ButtonBG = Color3.fromRGB(210, 215, 228),
    },
    VeryDark = {
        Name = "Very dark",
        MainBG = Color3.fromRGB(15, 16, 20),
        MainTrans = 0.05,
        AccentBG = Color3.fromRGB(24, 26, 34),
        AccentTrans = 0.15,
        TopBG = Color3.fromRGB(24, 26, 34),
        TopTrans = 0.05,
        BottomBG = Color3.fromRGB(24, 26, 34),
        BottomTrans = 0.0,
        BottomGradient = {
            Color3.fromRGB(24, 26, 34),
            Color3.fromRGB(35, 38, 50),
            Color3.fromRGB(20, 22, 28)
        },
        MinGradient = {
            Color3.fromRGB(45, 50, 68),
            Color3.fromRGB(70, 78, 105),
            Color3.fromRGB(35, 40, 55)
        },
        Divider = Color3.fromRGB(40, 44, 58),
        Text = Color3.fromRGB(230, 235, 245),
        SubText = Color3.fromRGB(160, 165, 180),
        CardBG = Color3.fromRGB(10, 11, 14),
        ButtonBG = Color3.fromRGB(24, 26, 34),
    },
    Amethyst = {
        Name = "Amethyst",
        MainBG = Color3.fromRGB(58, 20, 95),
        MainTrans = 0.15,
        AccentBG = Color3.fromRGB(88, 28, 135),
        AccentTrans = 0.30,
        TopBG = Color3.fromRGB(88, 28, 135),
        TopTrans = 0.05,
        BottomBG = Color3.fromRGB(88, 28, 135),
        BottomTrans = 0.0,
        BottomGradient = {
            Color3.fromRGB(88, 28, 135),
            Color3.fromRGB(126, 34, 206),
            Color3.fromRGB(70, 20, 110)
        },
        MinGradient = {
            Color3.fromRGB(147, 51, 234),
            Color3.fromRGB(192, 132, 252),
            Color3.fromRGB(126, 34, 206)
        },
        Divider = Color3.fromRGB(126, 34, 206),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(225, 200, 245),
        CardBG = Color3.fromRGB(45, 15, 75),
        ButtonBG = Color3.fromRGB(88, 28, 135),
    },
    Nature = {
        Name = "Green/nature",
        MainBG = Color3.fromRGB(15, 60, 32),
        MainTrans = 0.15,
        AccentBG = Color3.fromRGB(20, 83, 45),
        AccentTrans = 0.30,
        TopBG = Color3.fromRGB(20, 83, 45),
        TopTrans = 0.05,
        BottomBG = Color3.fromRGB(20, 83, 45),
        BottomTrans = 0.0,
        BottomGradient = {
            Color3.fromRGB(20, 83, 45),
            Color3.fromRGB(34, 139, 74),
            Color3.fromRGB(15, 60, 32)
        },
        MinGradient = {
            Color3.fromRGB(34, 197, 94),
            Color3.fromRGB(134, 239, 172),
            Color3.fromRGB(22, 163, 74)
        },
        Divider = Color3.fromRGB(34, 139, 74),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 240, 215),
        CardBG = Color3.fromRGB(10, 45, 24),
        ButtonBG = Color3.fromRGB(20, 83, 45),
    }
}

local function ApplyCornerRadii(uiCorner, topLeft, topRight, bottomLeft, bottomRight)
    pcall(function()
        uiCorner.TopLeftRadius = UDim.new(0, topLeft)
        uiCorner.TopRightRadius = UDim.new(0, topRight)
        uiCorner.BottomLeftRadius = UDim.new(0, bottomLeft)
        uiCorner.BottomRightRadius = UDim.new(0, bottomRight)
    end)
end

local function AddUIShadow(parentFrame, blurRadius, transparency, color)
    blurRadius = blurRadius or 20
    transparency = transparency or 0.5
    color = color or Color3.fromRGB(0, 0, 0)

    local shadowNode = Instance.new("UIShadow")
    shadowNode.Name = "UIShadow"
    shadowNode.BlurRadius = UDim.new(0, blurRadius)
    shadowNode.Color = color
    shadowNode.Transparency = transparency
    shadowNode.ShowBehindParent = true
    shadowNode.Enabled = true
    shadowNode.Parent = parentFrame
    return shadowNode
end

Library.ApplyCornerRadii = ApplyCornerRadii
Library.AddUIShadow = AddUIShadow

function Library:CreateWindow(hubTitle, scriptName)
    hubTitle = hubTitle or "MD SCRIPT HUB"

    if ParentGui:FindFirstChild("ScriptUi") then ParentGui:FindFirstChild("ScriptUi"):Destroy() end
    if ParentGui:FindFirstChild("MinimisedUI") then ParentGui:FindFirstChild("MinimisedUI"):Destroy() end
    if ParentGui:FindFirstChild("NotificationUI") then ParentGui:FindFirstChild("NotificationUI"):Destroy() end
    if ParentGui:FindFirstChild("ParticleLayer") then ParentGui:FindFirstChild("ParticleLayer"):Destroy() end

    local Window = {
        ScriptName = scriptName or hubTitle or "MD_Script",
        CurrentTheme = Library.ThemePresets.Dark,
        CurrentThemeKey = "Dark",
        NotificationsEnabled = true,
        UISoundsEnabled = true,
        SoundVolume = 0.8,
        BackgroundBlurEnabled = true,
        SpiderwebBGEnabled = true,
        CustomThemeColor = nil,
        CustomBGTransparency = 0.10,
        ClickEffectsEnabled = true,
        ClickParticleType = "Theme default",
        CustomParticleAsset = "",
        Connections = {},
        ActiveNotifications = {},
        SidebarDividers = {},
        RegisteredMDButtons = {},
        RegisteredMDToggles = {},
        RegisteredMDSliders = {},
        RegisteredToggles = {},
        RegisteredSliders = {},
        RegisteredTextboxes = {},
        RegisteredTextboxesList = {},
        RegisteredDropdowns = {},
        RegisteredDropdownsList = {},
        RegisteredColorPickers = {},
        RegisteredColorPickersList = {},
        RegisteredKeybindBadges = {},
        KeybindMap = {},
        SearchableItems = {},
        ThemePresetBtnMap = {},
        Tabs = {},
        ActiveTab = nil
    }

    local ScriptUi = nil
    local MinimisedUI = nil
    local NotificationUI = nil
    local MainContainer = nil
    local MainContentFrame = nil
    local UIScaleConstraint = nil

    local function TrackConn(conn)
        if conn then
            table.insert(Window.Connections, conn)
        end
        return conn
    end

    -- =========================================================================
    -- AUDIO SFX CONTROLLER (Cloned Overlay Engine)
    -- =========================================================================
    local SoundFolder = Instance.new("Folder")
    SoundFolder.Name = "Sounds"
    SoundFolder.Parent = ParentGui

    local HoverSoundTemplate = Instance.new("Sound")
    HoverSoundTemplate.Name = "HoverSoundTemplate"
    HoverSoundTemplate.SoundId = "rbxassetid://5852311399"
    HoverSoundTemplate.Volume = 0.4
    HoverSoundTemplate.Parent = SoundFolder

    local ClickSoundTemplate = Instance.new("Sound")
    ClickSoundTemplate.Name = "ClickSoundTemplate"
    ClickSoundTemplate.SoundId = "rbxassetid://5852311745"
    ClickSoundTemplate.Volume = 0.5
    ClickSoundTemplate.Parent = SoundFolder

    local function PlayHoverSFX()
        if not Window or not Window.UISoundsEnabled then return end
        pcall(function()
            local snd = HoverSoundTemplate:Clone()
            snd.Parent = SoundFolder
            snd:Play()
            Debris:AddItem(snd, 1.5)
        end)
    end

    local function PlayClickSFX()
        if not Window or not Window.UISoundsEnabled then return end
        pcall(function()
            local snd = ClickSoundTemplate:Clone()
            snd.Parent = SoundFolder
            snd:Play()
            Debris:AddItem(snd, 1.5)
        end)
    end

    -- =========================================================================
    -- CONTROL REGISTRIES & CONFIG PERSISTENCE ENGINE
    -- =========================================================================


    local HttpService = game:GetService("HttpService")
    local SanitizedScriptName = (Window.ScriptName:gsub("[^%w_%-]", "_"))
    local ConfigFolderPath = "MD_Configs/" .. SanitizedScriptName
    local AutoloadFilePath = ConfigFolderPath .. "/autoload.txt"

    local function EnsureConfigFolder()
        pcall(function()
            if makefolder and isfolder then
                if not isfolder("MD_Configs") then makefolder("MD_Configs") end
                if not isfolder(ConfigFolderPath) then makefolder(ConfigFolderPath) end
            end
        end)
    end
    EnsureConfigFolder()

    local function GetConfigList()
        local list = {"DEFAULT"}
        pcall(function()
            if listfiles and isfolder and isfolder(ConfigFolderPath) then
                local files = listfiles(ConfigFolderPath)
                for _, filePath in ipairs(files) do
                    local fileName = filePath:match("([^/\\]+)%.json$")
                    if fileName and fileName ~= "DEFAULT" then
                        table.insert(list, fileName)
                    end
                end
            end
        end)
        return list
    end

    function Window:GetAutoloadConfig()
        local autoloadName = nil
        pcall(function()
            if readfile and isfile and isfile(AutoloadFilePath) then
                local content = readfile(AutoloadFilePath)
                if content then
                    content = content:gsub("^%s+", ""):gsub("%s+$", "")
                    if content ~= "" and content:upper() ~= "NONE" then
                        autoloadName = content
                    end
                end
            end
        end)
        return autoloadName
    end

    function Window:SetAutoloadConfig(configName)
        EnsureConfigFolder()
        if not configName or configName == "" or configName:upper() == "NONE" then
            pcall(function()
                if delfile and isfile and isfile(AutoloadFilePath) then
                    delfile(AutoloadFilePath)
                end
            end)
            return nil
        else
            pcall(function()
                if writefile then
                    writefile(AutoloadFilePath, tostring(configName))
                end
            end)
            return tostring(configName)
        end
    end

    function Window:GetConfigSaveData()
        local data = {
            Theme = Window.CurrentThemeKey or "Dark",
            Settings = {
                Spiderweb = (Window.SpiderwebBGEnabled ~= nil) and Window.SpiderwebBGEnabled or Window.SpiderwebEnabled,
                Blur = Window.BackgroundBlurEnabled,
                Sounds = Window.UISoundsEnabled,
                SoundVolume = Window.SoundVolume or 0.8,
                Notifications = Window.NotificationsEnabled,
                CustomThemeColor = Window.CustomThemeColor and Window.CustomThemeColor:ToHex() or nil,
                BGTransparency = Window.CustomBGTransparency or 0.10,
                ClickEffects = Window.ClickEffectsEnabled,
                ClickParticle = Window.ClickParticleType or "Theme default",
                CustomParticle = Window.CustomParticleAsset or ""
            },
            Toggles = {},
            Sliders = {},
            Textboxes = {},
            Dropdowns = {},
            ColorPickers = {}
        }
        for name, toggle in pairs(Window.RegisteredToggles) do
            pcall(function()
                if toggle and toggle.GetState then
                    data.Toggles[name] = toggle.GetState()
                end
            end)
        end
        for name, slider in pairs(Window.RegisteredSliders) do
            pcall(function()
                if slider and slider.GetValue then
                    data.Sliders[name] = slider.GetValue()
                end
            end)
        end
        for name, box in pairs(Window.RegisteredTextboxes) do
            pcall(function()
                if box and box.GetText then
                    data.Textboxes[name] = box.GetText()
                end
            end)
        end
        for name, drop in pairs(Window.RegisteredDropdowns) do
            pcall(function()
                if drop and drop.GetSelected then
                    data.Dropdowns[name] = drop.GetSelected()
                end
            end)
        end
        for name, cp in pairs(Window.RegisteredColorPickers) do
            pcall(function()
                if cp and cp.GetColor then
                    local c = cp.GetColor()
                    data.ColorPickers[name] = c:ToHex()
                end
            end)
        end
        return data
    end

    function Window:ApplyConfigSaveData(data)
        if not data then return end

        -- 1. Apply Theme Preset or Custom Theme First
        if data.Settings and data.Settings.CustomThemeColor and Window.ApplyCustomTheme then
            pcall(function()
                local col = Color3.fromHex(data.Settings.CustomThemeColor)
                Window:ApplyCustomTheme(col)
            end)
        elseif data.Theme then
            if Window.ApplyTheme then
                pcall(function() Window:ApplyTheme(data.Theme) end)
            elseif Library.ThemePresets[data.Theme] then
                Window.CurrentTheme = Library.ThemePresets[data.Theme]
                Window.CurrentThemeKey = data.Theme
            end
        end

        -- 2. Apply Global Settings
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
            if data.Settings.Notifications ~= nil then
                Window.NotificationsEnabled = data.Settings.Notifications
            end
            if data.Settings.BGTransparency ~= nil and Window.SetBackgroundTransparency then
                pcall(function() Window:SetBackgroundTransparency(data.Settings.BGTransparency) end)
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
        end

        -- 3. Apply Toggles (trigger callbacks to turn ON/OFF active features)
        if data.Toggles then
            for name, state in pairs(data.Toggles) do
                local toggle = Window.RegisteredToggles[name]
                if toggle and toggle.SetState then
                    pcall(function() toggle.SetState(state, true) end)
                end
            end
        end

        -- 4. Apply Sliders (trigger callbacks to adjust gameplay/UI values)
        if data.Sliders then
            for name, val in pairs(data.Sliders) do
                local slider = Window.RegisteredSliders[name]
                if slider and slider.SetValue then
                    pcall(function() slider.SetValue(val, true) end)
                end
            end
        end

        -- 5. Apply Textboxes
        if data.Textboxes then
            for name, text in pairs(data.Textboxes) do
                local box = Window.RegisteredTextboxes[name]
                if box and box.SetText then
                    pcall(function() box.SetText(text, true) end)
                end
            end
        end

        -- 6. Apply Dropdowns
        if data.Dropdowns then
            for name, selected in pairs(data.Dropdowns) do
                local drop = Window.RegisteredDropdowns[name]
                if drop and drop.SetSelected then
                    pcall(function() drop.SetSelected(selected, true) end)
                end
            end
        end

        -- 7. Apply Color Pickers
        if data.ColorPickers then
            for name, hex in pairs(data.ColorPickers) do
                local cp = Window.RegisteredColorPickers[name]
                if cp and cp.SetColor then
                    pcall(function()
                        local col = Color3.fromHex(hex)
                        cp.SetColor(col, true)
                    end)
                end
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
        local filePath = ConfigFolderPath .. "/" .. finalName .. ".json"
        local success = pcall(function()
            if writefile then
                writefile(filePath, jsonString)
            end
        end)

        if success then
            Window:Notify("Config saved", "Saved config as '" .. finalName .. "'", 2.5)
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
        local filePath = ConfigFolderPath .. "/" .. configName .. ".json"
        local success = pcall(function()
            if writefile then writefile(filePath, jsonString) end
        end)

        if success then
            Window:Notify("Config rewritten", "Overwrote '" .. configName .. "'!", 2.5)
            return true
        else
            Window:Notify("Config error", "Failed to overwrite file", 3)
            return false
        end
    end

    function Window:LoadConfig(configName)
        configName = configName or "DEFAULT"

        if configName:upper() == "DEFAULT" then
            if DefaultConfigMemoryData then
                Window:ApplyConfigSaveData(DefaultConfigMemoryData)
            end
            Window:Notify("Config loaded", "Loaded default config!", 2.5)
            return true
        end

        EnsureConfigFolder()
        local filePath = ConfigFolderPath .. "/" .. configName .. ".json"
        local loadedData = nil

        pcall(function()
            if readfile and isfile and isfile(filePath) then
                local content = readfile(filePath)
                loadedData = HttpService:JSONDecode(content)
            end
        end)

        if loadedData then
            Window:ApplyConfigSaveData(loadedData)
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
        local filePath = ConfigFolderPath .. "/" .. configName .. ".json"
        local success = pcall(function()
            if delfile and isfile and isfile(filePath) then
                delfile(filePath)
            end
        end)

        if success then
            Window:Notify("Config deleted", "Deleted config '" .. configName .. "'", 2.5)
            return true
        else
            Window:Notify("Config error", "Failed to delete config file", 3)
            return false
        end
    end

    -- =========================================================================
    -- TEXTBOX GENERATORS (Full & Half Width)
    -- =========================================================================
    function Window:CreateMDTextbox(parent, position, size, title, placeholder, defaultText, onSubmit)
        size = size or UDim2.new(1, -10, 0, 50)
        position = position or UDim2.new(0, 0, 0, 0)

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Name = "TextboxFrame"
        BoxFrame.Size = size
        BoxFrame.Position = position
        BoxFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        BoxFrame.BackgroundTransparency = 0.05
        BoxFrame.BorderSizePixel = 0
        BoxFrame.ZIndex = 10
        BoxFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = BoxFrame

        AddUIShadow(BoxFrame, 20, 0.5)

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(0, 140, 1, 0)
        TitleLabel.Position = UDim2.new(0, 12, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.FontFace = FontMichromaBold
        TitleLabel.Text = title or "Input"
        TitleLabel.TextColor3 = Window.CurrentTheme.Text
        TitleLabel.TextSize = 12
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 11
        TitleLabel.Parent = BoxFrame

        local InputBox = Instance.new("TextBox")
        InputBox.Name = "InputBox"
        InputBox.Size = UDim2.new(1, -165, 0, 30)
        InputBox.Position = UDim2.new(0, 150, 0.5, -15)
        InputBox.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        InputBox.BackgroundTransparency = 0.2
        InputBox.BorderSizePixel = 0
        InputBox.FontFace = FontMichromaRegular
        InputBox.PlaceholderText = placeholder or "Type here..."
        InputBox.PlaceholderColor3 = Window.CurrentTheme.SubText
        InputBox.Text = defaultText or ""
        InputBox.TextColor3 = Window.CurrentTheme.Text
        InputBox.TextSize = 12
        InputBox.TextWrapped = true
        InputBox.ClipsDescendants = true
        InputBox.ClearTextOnFocus = false
        InputBox.ZIndex = 12
        InputBox.Parent = BoxFrame

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 6)
        InputCorner.Parent = InputBox

        local boxObj = {
            Frame = BoxFrame,
            TitleLabel = TitleLabel,
            InputBox = InputBox,
            GetText = function() return InputBox.Text end,
            SetText = function(txt, triggerCallback)
                InputBox.Text = txt or ""
                if triggerCallback and onSubmit then onSubmit(InputBox.Text) end
            end,
            RefreshTheme = function(theme)
                BoxFrame.BackgroundColor3 = theme.CardBG
                TitleLabel.TextColor3 = theme.Text
                InputBox.TextColor3 = theme.Text
                InputBox.PlaceholderColor3 = theme.SubText
                InputBox.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(230, 234, 242) or Color3.fromRGB(20, 22, 28)
            end
        }

        TrackConn(InputBox.FocusLost:Connect(function(enterPressed)
            PlayClickSFX()
            if onSubmit then onSubmit(InputBox.Text, enterPressed) end
        end))

        if title and title ~= "" then
            Window.RegisteredTextboxes[title] = boxObj
        end
        table.insert(Window.RegisteredTextboxesList, boxObj)

        return boxObj
    end

    -- =========================================================================
    -- DROPDOWN GENERATORS (Full-Width & Half-Width from XML Specs)
    -- =========================================================================
    function Window:CreateMDDropdown(parent, position, size, title, options, defaultOption, onSelect)
        size = size or UDim2.new(1, -10, 0, 62)
        position = position or UDim2.new(0, 0, 0, 0)
        options = options or {}
        defaultOption = defaultOption or options[1] or "Select..."

        local initialParentZIndex = (parent and parent:IsA("GuiObject")) and parent.ZIndex or 3
        if parent and parent:IsA("GuiObject") then
            parent.ClipsDescendants = false
        end

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = "Dropdown"
        DropdownFrame.Size = size
        DropdownFrame.Position = position
        DropdownFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        DropdownFrame.BackgroundTransparency = 0.05
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.ZIndex = 15
        DropdownFrame.ClipsDescendants = false
        DropdownFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = DropdownFrame

        AddUIShadow(DropdownFrame, 20, 0.5)

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = "Text"
        MDTextFolder.Parent = DropdownFrame

        local TitleText = Instance.new("TextLabel")
        TitleText.Name = "drpdwntext"
        TitleText.Size = UDim2.new(1, -70, 0, 39)
        TitleText.Position = UDim2.new(0, 14, 0.5, -19)
        TitleText.BackgroundTransparency = 1
        TitleText.FontFace = FontMichromaRegular
        TitleText.RichText = true
        local displayTitle = (title and title ~= "") and (title .. ": " .. defaultOption) or defaultOption
        TitleText.Text = displayTitle
        TitleText.TextColor3 = Window.CurrentTheme.Text
        TitleText.TextScaled = false
        TitleText.TextSize = 12
        TitleText.TextWrapped = true
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.TextYAlignment = Enum.TextYAlignment.Center
        TitleText.ZIndex = 16
        TitleText.Parent = MDTextFolder

        local ArrowIcon = Instance.new("ImageLabel")
        ArrowIcon.Name = "ImageLabel"
        ArrowIcon.Size = UDim2.new(0, 36, 0, 36)
        ArrowIcon.Position = UDim2.new(1, -46, 0.5, -18)
        ArrowIcon.BackgroundTransparency = 1
        ArrowIcon.Image = "rbxassetid://11552476728"
        ArrowIcon.ImageColor3 = Window.CurrentTheme.Text
        ArrowIcon.ZIndex = 16
        ArrowIcon.Parent = DropdownFrame

        local HeaderTrigger = Instance.new("TextButton")
        HeaderTrigger.Name = "HeaderTrigger"
        HeaderTrigger.Size = UDim2.new(1, 0, 1, 0)
        HeaderTrigger.BackgroundTransparency = 1
        HeaderTrigger.Text = ""
        HeaderTrigger.ZIndex = 17
        HeaderTrigger.Parent = DropdownFrame

        -- Dropdown Content List Frame
        local DropdownContent = Instance.new("Frame")
        DropdownContent.Name = "DropdownContent"
        DropdownContent.Size = UDim2.new(1, 0, 0, 0)
        DropdownContent.Position = UDim2.new(0, 0, 1, 6)
        DropdownContent.BackgroundColor3 = Window.CurrentTheme.CardBG
        DropdownContent.BackgroundTransparency = 0.05
        DropdownContent.BorderSizePixel = 0
        DropdownContent.ClipsDescendants = true
        DropdownContent.Visible = false
        DropdownContent.ZIndex = 80
        DropdownContent.Parent = DropdownFrame

        local ContentCorner = Instance.new("UICorner")
        ContentCorner.CornerRadius = UDim.new(0, 8)
        ContentCorner.Parent = DropdownContent

        AddUIShadow(DropdownContent, 20, 0.5)

        local InnerScroll = Instance.new("ScrollingFrame")
        InnerScroll.Name = "DropdownContentcontents"
        InnerScroll.Size = UDim2.new(1, -10, 1, -10)
        InnerScroll.Position = UDim2.new(0, 5, 0, 5)
        InnerScroll.BackgroundTransparency = 1
        InnerScroll.BorderSizePixel = 0
        InnerScroll.ScrollBarThickness = 3
        InnerScroll.ZIndex = 81
        InnerScroll.Parent = DropdownContent

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.Parent = InnerScroll

        local selectedOption = defaultOption
        local isExpanded = false

        local function RefreshOptions(newOptions)
            options = newOptions or options
            for _, child in ipairs(InnerScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            for idx, opt in ipairs(options) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Name = "drpdwncntnts"
                ItemBtn.Size = UDim2.new(1, -6, 0, 34)
                ItemBtn.BackgroundColor3 = (opt == selectedOption) and Window.CurrentTheme.ButtonBG or Window.CurrentTheme.AccentBG
                ItemBtn.BackgroundTransparency = 0.1
                ItemBtn.FontFace = FontMichromaRegular
                ItemBtn.RichText = true
                ItemBtn.Text = opt
                ItemBtn.TextColor3 = Window.CurrentTheme.Text
                ItemBtn.TextSize = 12
                ItemBtn.ZIndex = 82
                ItemBtn.Parent = InnerScroll

                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 6)
                ItemCorner.Parent = ItemBtn

                TrackConn(ItemBtn.MouseButton1Click:Connect(function()
                    PlayClickSFX()
                    selectedOption = opt
                    local newDisplay = (title and title ~= "") and (title .. ": " .. selectedOption) or selectedOption
                    TitleText.Text = newDisplay
                    
                    isExpanded = false
                    DropdownFrame.ZIndex = 15
                    if parent and parent:IsA("GuiObject") then
                        parent.ZIndex = initialParentZIndex
                    end
                    TweenService:Create(ArrowIcon, TweenInfo.new(0.25), {Rotation = 0}):Play()
                    TweenService:Create(DropdownContent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                    task.delay(0.25, function() DropdownContent.Visible = false end)

                    if onSelect then onSelect(selectedOption) end
                end))
            end
            InnerScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end

        RefreshOptions(options)

        TrackConn(HeaderTrigger.MouseButton1Click:Connect(function()
            PlayClickSFX()
            isExpanded = not isExpanded
            local targetRotation = isExpanded and 180 or 0
            local targetHeight = isExpanded and math.clamp(#options * 39 + 15, 45, 220) or 0

            DropdownFrame.ZIndex = isExpanded and 75 or 15
            if parent and parent:IsA("GuiObject") then
                parent.ZIndex = isExpanded and 70 or initialParentZIndex
            end
            TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

            if isExpanded then
                DropdownContent.Visible = true
                TweenService:Create(DropdownContent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                }):Play()
            else
                local t = TweenService:Create(DropdownContent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, 0)
                })
                t:Play()
                t.Completed:Connect(function()
                    if not isExpanded then
                        DropdownContent.Visible = false
                        DropdownFrame.ZIndex = 15
                        if parent and parent:IsA("GuiObject") then
                            parent.ZIndex = initialParentZIndex
                        end
                    end
                end)
            end
        end))

        local dropObj = {
            Frame = DropdownFrame,
            Content = DropdownContent,
            InnerScroll = InnerScroll,
            TitleText = TitleText,
            ArrowIcon = ArrowIcon,
            GetSelected = function() return selectedOption end,
            SetSelected = function(opt, triggerCallback)
                selectedOption = opt
                local newDisplay = (title and title ~= "") and (title .. ": " .. selectedOption) or selectedOption
                TitleText.Text = newDisplay
                RefreshOptions(options)
                if triggerCallback and onSelect then onSelect(selectedOption) end
            end,
            RefreshOptions = RefreshOptions,
            RefreshTheme = function(theme)
                DropdownFrame.BackgroundColor3 = theme.CardBG
                TitleText.TextColor3 = theme.Text
                ArrowIcon.ImageColor3 = theme.Text
                DropdownContent.BackgroundColor3 = theme.CardBG
                InnerScroll.ScrollBarImageColor3 = theme.Divider
                RefreshOptions(options)
            end
        }

        if title and title ~= "" then
            Window.RegisteredDropdowns[title] = dropObj
        end
        table.insert(Window.RegisteredDropdownsList, dropObj)

        return dropObj
    end

    function Window:CreateMDDropdownHalf(parent, position, size, title, options, defaultOption, onSelect)
        size = size or UDim2.new(0, 309, 0, 62)
        return Window:CreateMDDropdown(parent, position, size, title, options, defaultOption, onSelect)
    end

    -- =========================================================================
    -- CONFIG UI SECTION BUILDER
    -- =========================================================================
    function Window:CreateConfigSection(parentTab)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = "ConfigSectionFrame"
        SectionFrame.Size = UDim2.new(1, -10, 0, 0)
        SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        SectionFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        SectionFrame.BorderSizePixel = 0
        SectionFrame.ZIndex = 3
        SectionFrame.Parent = parentTab.ContentFrame

        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 8)
        SectionCorner.Parent = SectionFrame
        AddUIShadow(SectionFrame, 12, 0.45)

        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SectionLayout.Padding = UDim.new(0, 8)
        SectionLayout.Parent = SectionFrame

        local SectionPadding = Instance.new("UIPadding")
        SectionPadding.PaddingTop = UDim.new(0, 10)
        SectionPadding.PaddingBottom = UDim.new(0, 12)
        SectionPadding.PaddingLeft = UDim.new(0, 10)
        SectionPadding.PaddingRight = UDim.new(0, 10)
        SectionPadding.Parent = SectionFrame

        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Size = UDim2.new(1, 0, 0, 24)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.FontFace = FontMichromaBold
        SectionTitle.Text = "Configurations"
        SectionTitle.TextColor3 = Window.CurrentTheme.Text
        SectionTitle.TextSize = 15
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.ZIndex = 4
        SectionTitle.Parent = SectionFrame

        -- 1. Config Name Textbox
        local nameBoxObj = Window:CreateMDTextbox(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "Config name", "MyConfig", nil)

        -- 2. Config Selector Dropdown
        local configDropdownObj = Window:CreateMDDropdown(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "", GetConfigList(), "DEFAULT", nil)

        -- 3. Row 1: Left = Create config, Right = Delete config
        local Row1 = Instance.new("Frame")
        Row1.Name = "ConfigRow1"
        Row1.Size = UDim2.new(1, 0, 0, 44)
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
        end)

        -- 4. Row 2: Left = Overwrite config, Right = Load config
        local Row2 = Instance.new("Frame")
        Row2.Name = "ConfigRow2"
        Row2.Size = UDim2.new(1, 0, 0, 44)
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

        -- 5. Row 3: Single Long Button for Autoload config
        autoloadBtn = Window:CreateMDButtonLong(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 44), GetAutoloadButtonLabel(), function()
            local selected = configDropdownObj.GetSelected()
            local currentAuto = Window:GetAutoloadConfig()
            if currentAuto == selected then
                Window:SetAutoloadConfig(nil)
                Window:Notify("Autoload", "Disabled config autoload", 2.5)
            else
                Window:SetAutoloadConfig(selected)
                Window:Notify("Autoload", "Set '" .. selected .. "' as autoload config!", 2.5)
            end
            if autoloadBtn and autoloadBtn.TextLabel then
                autoloadBtn.TextLabel.Text = GetAutoloadButtonLabel()
            end
        end)

        parentTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, parentTab.Layout.AbsoluteContentSize.Y + 20)
        return SectionFrame
    end





    -- =========================================================================
    -- LOADING SCREEN ENGINE (Centered on screen, progress bar, shrink tween & destroy)
    -- =========================================================================
    if ParentGui:FindFirstChild("LoadingUI") then ParentGui:FindFirstChild("LoadingUI"):Destroy() end

    local LoadingUI = Instance.new("ScreenGui")
    LoadingUI.Name = "LoadingUI"
    LoadingUI.ResetOnSpawn = false
    LoadingUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadingUI.DisplayOrder = 100
    LoadingUI.Parent = ParentGui

    local LoadCenterFrame = Instance.new("Frame")
    LoadCenterFrame.Name = "LoadCenterFrame"
    LoadCenterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadCenterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadCenterFrame.Size = UDim2.new(0, 360, 0, 140)
    LoadCenterFrame.BackgroundTransparency = 1
    LoadCenterFrame.ClipsDescendants = false
    LoadCenterFrame.ZIndex = 100
    LoadCenterFrame.Parent = LoadingUI

    local Loadbarempty = Instance.new("Frame")
    Loadbarempty.Name = "Loadbarempty"
    Loadbarempty.Size = UDim2.new(0, 326, 0, 23)
    Loadbarempty.Position = UDim2.new(0.5, -163, 0.5, -5)
    Loadbarempty.BackgroundColor3 = Color3.fromRGB(106, 106, 106)
    Loadbarempty.BackgroundTransparency = 0.15
    Loadbarempty.BorderSizePixel = 0
    Loadbarempty.ClipsDescendants = false
    Loadbarempty.ZIndex = 101
    Loadbarempty.Parent = LoadCenterFrame

    local LoadbaremptyCorner = Instance.new("UICorner")
    LoadbaremptyCorner.CornerRadius = UDim.new(0, 8)
    LoadbaremptyCorner.Parent = Loadbarempty

    local LoadbaremptyStroke = Instance.new("UIStroke")
    LoadbaremptyStroke.Name = "UIStroke"
    LoadbaremptyStroke.Color = Color3.fromRGB(179, 179, 179)
    LoadbaremptyStroke.Thickness = 1.5
    LoadbaremptyStroke.Transparency = 0
    LoadbaremptyStroke.Parent = Loadbarempty

    AddUIShadow(Loadbarempty, 20, 0.5, Color3.fromRGB(255, 255, 255))

    local Loadbar = Instance.new("Frame")
    Loadbar.Name = "Loadbar"
    Loadbar.Size = UDim2.new(0, 0, 0, 23)
    Loadbar.Position = UDim2.new(0.5, -163, 0.5, -5)
    Loadbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Loadbar.BackgroundTransparency = 0.15
    Loadbar.BorderSizePixel = 0
    Loadbar.ClipsDescendants = true
    Loadbar.ZIndex = 102
    Loadbar.Parent = LoadCenterFrame

    local LoadbarCorner = Instance.new("UICorner")
    LoadbarCorner.CornerRadius = UDim.new(0, 8)
    LoadbarCorner.Parent = Loadbar

    local Loadingtext = Instance.new("TextLabel")
    Loadingtext.Name = "Loadingtext"
    Loadingtext.Size = UDim2.new(0, 180, 0, 33)
    Loadingtext.Position = UDim2.new(0.5, -163, 0.5, 28)
    Loadingtext.BackgroundTransparency = 1
    Loadingtext.FontFace = FontMichromaRegular
    Loadingtext.Text = "Loading..."
    Loadingtext.TextColor3 = Color3.fromRGB(255, 255, 255)
    Loadingtext.TextSize = 22
    Loadingtext.TextWrapped = true
    Loadingtext.TextXAlignment = Enum.TextXAlignment.Left
    Loadingtext.ZIndex = 102
    Loadingtext.Parent = LoadCenterFrame

    local percloaded = Instance.new("TextLabel")
    percloaded.Name = "percloaded"
    percloaded.Size = UDim2.new(0, 131, 0, 33)
    percloaded.Position = UDim2.new(0.5, 32, 0.5, -42)
    percloaded.BackgroundTransparency = 1
    percloaded.FontFace = FontMichromaRegular
    percloaded.Text = "0 %"
    percloaded.TextColor3 = Color3.fromRGB(255, 255, 255)
    percloaded.TextSize = 18
    percloaded.TextWrapped = true
    percloaded.TextXAlignment = Enum.TextXAlignment.Right
    percloaded.ZIndex = 102
    percloaded.Parent = LoadCenterFrame

    local isFinishedLoading = false

    function Window:UpdateLoadingProgress(pct, statusText)
        if isFinishedLoading then return end
        pct = math.clamp(pct, 0, 100)
        percloaded.Text = string.format("%d %%", math.floor(pct))
        if statusText then
            Loadingtext.Text = statusText
        end
        local targetWidth = math.floor(326 * (pct / 100))
        TweenService:Create(Loadbar, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, targetWidth, 0, 23)
        }):Play()
    end

    function Window:FinishLoading()
        if isFinishedLoading then return end
        isFinishedLoading = true

        Window:UpdateLoadingProgress(100, "Loaded!")
        task.wait(0.3)
        local shrinkTween = TweenService:Create(LoadCenterFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        shrinkTween:Play()
        shrinkTween.Completed:Wait()
        if LoadingUI and LoadingUI.Parent then
            LoadingUI:Destroy()
        end
        if ScriptUi then
            ScriptUi.Enabled = true
        end

        -- Snapshot default config state after full initialization
        if not DefaultConfigMemoryData then
            DefaultConfigMemoryData = Window:GetConfigSaveData()
        end

        -- Trigger Autoload Config if set
        task.spawn(function()
            task.wait(0.2)
            local autoloadConfig = Window:GetAutoloadConfig()
            if autoloadConfig and autoloadConfig ~= "" and autoloadConfig:upper() ~= "NONE" then
                Window:LoadConfig(autoloadConfig)
            end
        end)

        task.delay(2.0, function()
            if Window and ScriptUi and ScriptUi.Enabled then
                Window:SetBackgroundBlur(Window.BackgroundBlurEnabled)
            end
        end)
    end


    -- (SFX functions declared at top of CreateWindow)

    local function AttachUniversalDrag(dragHandleFrame, targetContainer)
        local isDragging = false
        local dragStartPos = nil
        local frameStartPos = nil

        TrackConn(dragHandleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStartPos = input.Position
                frameStartPos = targetContainer.Position
            end
        end))

        TrackConn(UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStartPos
                targetContainer.Position = UDim2.new(
                    frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                    frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
                )
            end
        end))

        TrackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end))
    end

    -- Ultra-Smooth Button Generator Helper
    function Window:CreateMDButton(parent, size, position, text, onClick, showArrow)
        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = "TopFrame"
        BtnFrame.Size = size or UDim2.new(0, 260, 0, 62)
        BtnFrame.AutomaticSize = Enum.AutomaticSize.Y or UDim2.new(0, 80, 0, 26)
        BtnFrame.Position = position or UDim2.new(0, 0, 0, 0)
        BtnFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        BtnFrame.BackgroundTransparency = 0.05
        BtnFrame.BorderSizePixel = 0
        BtnFrame.ZIndex = 10
        BtnFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = BtnFrame

        AddUIShadow(BtnFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0
        Stroke.Parent = BtnFrame

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = "Text"
        MDTextFolder.Parent = BtnFrame

        local BtnText = Instance.new("TextLabel")
        BtnText.Name = "btntext"
        BtnText.BackgroundTransparency = 1
        BtnText.FontFace = FontMichromaBold
        BtnText.RichText = true
        BtnText.Text = text or "Button"
        BtnText.TextColor3 = Window.CurrentTheme.Text
        BtnText.TextScaled = true
        BtnText.TextWrapped = true
        BtnText.ZIndex = 11
        BtnText.Parent = MDTextFolder

        local ArrowIcon = nil
        if showArrow then
            BtnText.Size = UDim2.new(1, -30, 1, -6)
            BtnText.Position = UDim2.new(0, 8, 0, 3)
            BtnText.TextXAlignment = Enum.TextXAlignment.Left

            ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Name = "ArrowIcon"
            ArrowIcon.Size = UDim2.new(0, 18, 0, 18)
            ArrowIcon.Position = UDim2.new(1, -23, 0.5, -9)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://2418686949"
            ArrowIcon.ImageColor3 = Window.CurrentTheme.Text
            ArrowIcon.ZIndex = 11
            ArrowIcon.Parent = BtnFrame
        else
            BtnText.Size = UDim2.new(1, -6, 1, -6)
            BtnText.Position = UDim2.new(0, 3, 0, 3)
            BtnText.TextXAlignment = Enum.TextXAlignment.Center
            BtnText.TextYAlignment = Enum.TextYAlignment.Center
        end

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = "ClickTrigger"
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 12
        ClickBtn.Parent = BtnFrame

        TrackConn(ClickBtn.MouseEnter:Connect(function()
            PlayHoverSFX()
            TweenService:Create(Stroke, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 2.0}):Play()
            local hoverSize = UDim2.new(size.X.Scale, math.floor(size.X.Offset * 1.03), size.Y.Scale, math.floor(size.Y.Offset * 1.03))
            TweenService:Create(BtnFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = hoverSize}):Play()
        end))

        TrackConn(ClickBtn.MouseLeave:Connect(function()
            TweenService:Create(Stroke, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 1.2}):Play()
            TweenService:Create(BtnFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = size}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Down:Connect(function()
            PlayClickSFX()
            local pressedSize = UDim2.new(size.X.Scale, math.floor(size.X.Offset * 0.94), size.Y.Scale, math.floor(size.Y.Offset * 0.94))
            TweenService:Create(BtnFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = pressedSize}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Up:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = size}):Play()
        end))

        if onClick then
            TrackConn(ClickBtn.MouseButton1Click:Connect(onClick))
        end

        local btnData = {
            Frame = BtnFrame,
            TextLabel = BtnText,
            ArrowIcon = ArrowIcon,
            Stroke = Stroke,
            Trigger = ClickBtn,
            BaseSize = size
        }
        table.insert(Window.RegisteredMDButtons, btnData)

        return btnData
    end

    -- =========================================================================
    -- KEYBIND BADGE & TOGGLE FUNCTION BIND ENGINE
    -- =========================================================================
    local ActiveListeningBadge = nil

    local function ParseKeyCode(input)
        if not input or input == "..." or input == "" or input == false then
            return nil
        end
        if typeof(input) == "EnumItem" and input.EnumType == Enum.KeyCode then
            return input
        end
        if type(input) == "string" then
            local trimmed = input:gsub("%s+", "")
            if trimmed == "..." or trimmed == "" or trimmed:lower() == "none" or trimmed:lower() == "nil" then
                return nil
            end
            for _, code in ipairs(Enum.KeyCode:GetEnumItems()) do
                if code.Name:lower() == trimmed:lower() then
                    return code
                end
            end
        end
        return nil
    end

    local function GetKeyDisplayName(keyCode)
        if not keyCode or keyCode == Enum.KeyCode.Unknown then
            return "..."
        end
        local name = keyCode.Name
        if name:find("^Keypad") then
            name = name:gsub("^Keypad", "Num")
        elseif name == "LeftShift" then
            name = "LShift"
        elseif name == "RightShift" then
            name = "RShift"
        elseif name == "LeftControl" then
            name = "LCtrl"
        elseif name == "RightControl" then
            name = "RCtrl"
        elseif name == "LeftAlt" then
            name = "LAlt"
        elseif name == "RightAlt" then
            name = "RAlt"
        end
        return name
    end

    function Window:CreateKeybindBadge(parent, position, size, initialBind, onTrigger, identifier)
        size = size or UDim2.new(0, 36, 0, 22)
        position = position or UDim2.new(0, 0, 0, 0)

        local initialKey = ParseKeyCode(initialBind)

        local BadgeContainer = Instance.new("Frame")
        BadgeContainer.Name = "KeybindBadge"
        BadgeContainer.Size = size
        BadgeContainer.Position = position
        BadgeContainer.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(24, 26, 34)
        BadgeContainer.BackgroundTransparency = 0.15
        BadgeContainer.BorderSizePixel = 0
        BadgeContainer.ZIndex = 15
        BadgeContainer.ClipsDescendants = false
        BadgeContainer.Parent = parent

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(0, 6)
        BadgeCorner.Parent = BadgeContainer

        local BadgeStroke = Instance.new("UIStroke")
        BadgeStroke.Name = "BadgeStroke"
        BadgeStroke.Thickness = 1.1
        BadgeStroke.Color = Color3.fromRGB(255, 255, 255)
        BadgeStroke.Transparency = 0.75
        BadgeStroke.Parent = BadgeContainer

        local BadgeText = Instance.new("TextLabel")
        BadgeText.Name = "KeyLabel"
        BadgeText.Size = UDim2.new(1, -6, 1, 0)
        BadgeText.Position = UDim2.new(0, 3, 0, 0)
        BadgeText.BackgroundTransparency = 1
        BadgeText.FontFace = FontMichromaRegular
        BadgeText.Text = GetKeyDisplayName(initialKey)
        BadgeText.TextColor3 = Window.CurrentTheme.Text
        BadgeText.TextSize = 10
        BadgeText.TextXAlignment = Enum.TextXAlignment.Center
        BadgeText.TextYAlignment = Enum.TextYAlignment.Center
        BadgeText.ZIndex = 16
        BadgeText.Parent = BadgeContainer

        local TriggerBtn = Instance.new("TextButton")
        TriggerBtn.Name = "BindTrigger"
        TriggerBtn.Size = UDim2.new(1, 0, 1, 0)
        TriggerBtn.BackgroundTransparency = 1
        TriggerBtn.Text = ""
        TriggerBtn.ZIndex = 17
        TriggerBtn.Parent = BadgeContainer

        -- Small close icon that appears when editing to delete/clear bind
        local DeleteBtn = Instance.new("TextButton")
        DeleteBtn.Name = "DeleteBindBtn"
        DeleteBtn.Size = UDim2.new(0, 14, 0, 14)
        DeleteBtn.Position = UDim2.new(1, -15, 0.5, -7)
        DeleteBtn.BackgroundColor3 = Color3.fromRGB(215, 45, 45)
        DeleteBtn.BackgroundTransparency = 0.1
        DeleteBtn.FontFace = FontMichromaBold
        DeleteBtn.Text = "X"
        DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DeleteBtn.TextSize = 8
        DeleteBtn.ZIndex = 18
        DeleteBtn.Visible = false
        DeleteBtn.Parent = BadgeContainer

        local DelCorner = Instance.new("UICorner")
        DelCorner.CornerRadius = UDim.new(0, 7)
        DelCorner.Parent = DeleteBtn

        local badgeData = {
            Container = BadgeContainer,
            Label = BadgeText,
            Stroke = BadgeStroke,
            DeleteBtn = DeleteBtn,
            CurrentKey = initialKey,
            OnTrigger = onTrigger,
            Identifier = identifier or "Toggle",
            IsListening = false
        }

        local function UpdateUI()
            BadgeText.Text = GetKeyDisplayName(badgeData.CurrentKey)
            if badgeData.IsListening then
                BadgeText.Text = "..."
                BadgeText.Size = UDim2.new(1, -18, 1, 0)
                BadgeText.Position = UDim2.new(0, 2, 0, 0)
                BadgeStroke.Thickness = 1.6
                BadgeStroke.Color = Window.CurrentTheme.Text
                BadgeStroke.Transparency = 0.2
                DeleteBtn.Visible = true
            else
                BadgeText.Size = UDim2.new(1, -6, 1, 0)
                BadgeText.Position = UDim2.new(0, 3, 0, 0)
                BadgeStroke.Thickness = 1.1
                BadgeStroke.Color = Color3.fromRGB(255, 255, 255)
                BadgeStroke.Transparency = 0.75
                DeleteBtn.Visible = false
            end
        end

        function badgeData.SetKey(newKeyCode, isUserEdit)
            if badgeData.CurrentKey and Window.KeybindMap[badgeData.CurrentKey] == badgeData then
                Window.KeybindMap[badgeData.CurrentKey] = nil
            end

            if newKeyCode and newKeyCode ~= Enum.KeyCode.Unknown then
                -- Conflict check: if another toggle used this key, clear it
                local existing = Window.KeybindMap[newKeyCode]
                if existing and existing ~= badgeData then
                    existing.ClearKey(false)
                    if isUserEdit then
                        Window:Notify("Keybind", "Reassigned " .. newKeyCode.Name .. " (cleared from " .. (existing.Identifier or "toggle") .. ")", 2.5)
                    end
                end
                Window.KeybindMap[newKeyCode] = badgeData
                badgeData.CurrentKey = newKeyCode
            else
                badgeData.CurrentKey = nil
            end

            UpdateUI()
        end

        function badgeData.ClearKey(notify)
            if badgeData.CurrentKey and Window.KeybindMap[badgeData.CurrentKey] == badgeData then
                Window.KeybindMap[badgeData.CurrentKey] = nil
            end
            badgeData.CurrentKey = nil
            badgeData.IsListening = false
            UpdateUI()
            if notify then
                Window:Notify("Keybind", "Cleared bind for " .. (badgeData.Identifier or "toggle"), 2)
            end
        end

        function badgeData.StartListening()
            if ActiveListeningBadge and ActiveListeningBadge ~= badgeData then
                ActiveListeningBadge.StopListening()
            end
            badgeData.IsListening = true
            ActiveListeningBadge = badgeData
            PlayClickSFX()
            UpdateUI()
        end

        function badgeData.StopListening()
            badgeData.IsListening = false
            if ActiveListeningBadge == badgeData then
                ActiveListeningBadge = nil
            end
            UpdateUI()
        end

        TrackConn(TriggerBtn.MouseButton1Click:Connect(function()
            if badgeData.IsListening then
                badgeData.StopListening()
            else
                badgeData.StartListening()
            end
        end))

        TrackConn(DeleteBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            badgeData.ClearKey(true)
            badgeData.StopListening()
        end))

        if initialKey then
            badgeData.SetKey(initialKey, false)
        end

        table.insert(Window.RegisteredKeybindBadges, badgeData)
        return badgeData
    end

    function Window:CreateMDToggle(parent, position, size, initialState, onToggle, identifier, keybindConfig)
        size = size or UDim2.new(0, 56, 0, 26)

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "ToggleFrame"
        ToggleFrame.Size = size
        ToggleFrame.Position = position or UDim2.new(0, 0, 0, 0)
        ToggleFrame.BackgroundColor3 = initialState and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
        ToggleFrame.BackgroundTransparency = 0.05
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.ClipsDescendants = false
        ToggleFrame.ZIndex = 10
        ToggleFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 33)
        Corner.Parent = ToggleFrame

        AddUIShadow(ToggleFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0
        Stroke.Parent = ToggleFrame

        local KnobFrame = Instance.new("Frame")
        KnobFrame.Name = "KnobFrame"
        KnobFrame.Size = UDim2.new(0, 22, 0, 22)
        KnobFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        KnobFrame.Position = initialState and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0)
        KnobFrame.Rotation = initialState and 0 or 225
        KnobFrame.BackgroundTransparency = 1
        KnobFrame.ZIndex = 11
        KnobFrame.Parent = ToggleFrame

        local BaseCircle = Instance.new("ImageLabel")
        BaseCircle.Name = "ToggleThingLikeCircle"
        BaseCircle.Size = UDim2.new(1, 0, 1, 0)
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ZIndex = 11
        BaseCircle.Parent = KnobFrame

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = "ThethingOnTopThatMatchesBGofIt"
        OverlayCircle.Size = UDim2.new(1, 0, 1, 0)
        OverlayCircle.BackgroundTransparency = 1
        OverlayCircle.Image = "rbxassetid://100354746235648"
        OverlayCircle.ImageColor3 = Window.CurrentTheme.ButtonBG
        OverlayCircle.ZIndex = 12
        OverlayCircle.Parent = KnobFrame

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = "ClickTrigger"
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 13
        ClickBtn.Parent = ToggleFrame

        local isToggled = initialState

        local function PerformToggle(newState, triggerCallback)
            isToggled = (newState == true)
            local targetKnobPos = isToggled and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0)
            local targetRotation = isToggled and 0 or 225
            local targetBG = isToggled and Window.CurrentTheme.ButtonBG or ((Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))

            TweenService:Create(KnobFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetKnobPos,
                Rotation = targetRotation
            }):Play()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetBG}):Play()

            if triggerCallback and onToggle then
                pcall(onToggle, isToggled)
            end
        end

        TrackConn(ClickBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            PerformToggle(not isToggled, true)
        end))

        local toggleName = identifier or ("Toggle_" .. (#Window.RegisteredMDToggles + 1))
        local toggleData = {
            Name = toggleName,
            Frame = ToggleFrame,
            Knob = KnobFrame,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetState = function() return isToggled end,
            SetState = function(state, triggerCallback)
                PerformToggle(state, triggerCallback)
            end
        }

        if keybindConfig then
            local defaultKey = (type(keybindConfig) == "table" and (keybindConfig.Default or keybindConfig.Bind)) or (keybindConfig ~= true and keybindConfig or nil)
            local pos = position or UDim2.new(0, 0, 0, 0)
            local badgePos = UDim2.new(pos.X.Scale, pos.X.Offset - 42, pos.Y.Scale, pos.Y.Offset + 2)
            toggleData.Keybind = Window:CreateKeybindBadge(parent, badgePos, UDim2.new(0, 36, 0, 22), defaultKey, function()
                toggleData.SetState(not isToggled, true)
                PlayClickSFX()
            end, toggleName)
        end

        Window.RegisteredToggles[toggleName] = toggleData
        table.insert(Window.RegisteredMDToggles, toggleData)
        return toggleData
    end

    function Window:CreateMDSlider(parent, position, size, minVal, maxVal, defaultVal, onValueChange, identifier)
        size = size or UDim2.new(0, 210, 0, 14)
        minVal = minVal or 0
        maxVal = maxVal or 100
        defaultVal = math.clamp(defaultVal or 80, minVal, maxVal)

        local TrackFrame = Instance.new("Frame")
        TrackFrame.Name = "SliderTrackFrame"
        TrackFrame.Size = size
        TrackFrame.Position = position or UDim2.new(0, 0, 0, 0)
        TrackFrame.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(20, 22, 28)
        TrackFrame.BackgroundTransparency = 0.05
        TrackFrame.BorderSizePixel = 0
        TrackFrame.ZIndex = 10
        TrackFrame.ClipsDescendants = false
        TrackFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 33)
        Corner.Parent = TrackFrame

        AddUIShadow(TrackFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0
        Stroke.Parent = TrackFrame

        local initialPct = (maxVal > minVal) and math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1) or 0
        local knobSize = 22

        local FilledPart = Instance.new("Frame")
        FilledPart.Name = "Filledpart"
        FilledPart.Size = UDim2.new(initialPct, 0, 1, 0)
        FilledPart.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        FilledPart.BorderSizePixel = 0
        FilledPart.ZIndex = 11
        FilledPart.Parent = TrackFrame

        local FilledCorner = Instance.new("UICorner")
        FilledCorner.CornerRadius = UDim.new(0, 33)
        FilledCorner.Parent = FilledPart

        local HandleFrame = Instance.new("Frame")
        HandleFrame.Name = "SliderHandle"
        HandleFrame.Size = UDim2.new(0, knobSize, 0, knobSize)
        HandleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        HandleFrame.Position = UDim2.new(initialPct, 0, 0.5, 0)
        HandleFrame.BackgroundTransparency = 1
        HandleFrame.ZIndex = 12
        HandleFrame.Parent = TrackFrame

        local BaseCircle = Instance.new("ImageLabel")
        BaseCircle.Name = "ToggleThingLikeCircle"
        BaseCircle.Size = UDim2.new(1, 0, 1, 0)
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ZIndex = 12
        BaseCircle.Parent = HandleFrame

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = "ThethingOnTopThatMatchesBGofIt"
        OverlayCircle.Size = UDim2.new(1, 0, 1, 0)
        OverlayCircle.BackgroundTransparency = 1
        OverlayCircle.Image = "rbxassetid://100354746235648"
        OverlayCircle.ImageColor3 = Window.CurrentTheme.ButtonBG
        OverlayCircle.ZIndex = 13
        OverlayCircle.Parent = HandleFrame

        local Trigger = Instance.new("TextButton")
        Trigger.Name = "SliderTrigger"
        Trigger.Size = UDim2.new(1, 0, 1, 0)
        Trigger.BackgroundTransparency = 1
        Trigger.Text = ""
        Trigger.ZIndex = 14
        Trigger.Parent = TrackFrame

        local isDragging = false
        local currentVal = defaultVal

        local function UpdateSlider(inputPos)
            local trackAbsPos = TrackFrame.AbsolutePosition.X
            local trackAbsSize = TrackFrame.AbsoluteSize.X
            if trackAbsSize <= 0 then return end
            local pct = math.clamp((inputPos - trackAbsPos) / trackAbsSize, 0, 1)

            FilledPart.Size = UDim2.new(pct, 0, 1, 0)
            HandleFrame.Position = UDim2.new(pct, 0, 0.5, 0)

            currentVal = math.floor(minVal + (pct * (maxVal - minVal)))
            if onValueChange then
                pcall(onValueChange, currentVal, pct)
            end
        end

        TrackConn(Trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                UpdateSlider(input.Position.X)
            end
        end))

        TrackConn(UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input.Position.X)
            end
        end))

        TrackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end))

        local sliderName = identifier or ("Slider_" .. (#Window.RegisteredMDSliders + 1))
        local sliderData = {
            Name = sliderName,
            Track = TrackFrame,
            FilledPart = FilledPart,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetValue = function() return currentVal end,
            SetValue = function(val, triggerCallback)
                val = math.clamp(val, minVal, maxVal)
                currentVal = val
                local pct = (maxVal > minVal) and ((val - minVal) / (maxVal - minVal)) or 0
                FilledPart.Size = UDim2.new(pct, 0, 1, 0)
                HandleFrame.Position = UDim2.new(pct, 0, 0.5, 0)
                if triggerCallback and onValueChange then
                    pcall(onValueChange, currentVal, pct)
                end
            end,
            RefreshTheme = function(theme)
                TrackFrame.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(20, 22, 28)
                FilledPart.BackgroundColor3 = theme.ButtonBG
                OverlayCircle.ImageColor3 = theme.ButtonBG
            end
        }
        Window.RegisteredSliders[sliderName] = sliderData
        table.insert(Window.RegisteredMDSliders, sliderData)
        return sliderData
    end

    -- =========================================================================
    -- COLOR PICKER MODAL & WIDGET GENERATOR
    -- =========================================================================
    local ActiveColorPickerModal = nil

    function Window:OpenColorPicker(title, initialColor, onColorSelected)
        if ActiveColorPickerModal and ActiveColorPickerModal.Parent then
            ActiveColorPickerModal:Destroy()
            ActiveColorPickerModal = nil
        end

        initialColor = initialColor or Color3.fromRGB(255, 255, 255)
        local curH, curS, curV = initialColor:ToHSV()
        local selectedColor = initialColor

        local ModalBackdrop = Instance.new("TextButton")
        ModalBackdrop.Name = "ColorPickerBackdrop"
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.Position = UDim2.new(0, 0, 0, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 1
        ModalBackdrop.Text = ""
        ModalBackdrop.AutoButtonColor = false
        ModalBackdrop.ZIndex = 80
        ModalBackdrop.Parent = ScriptUi

        ActiveColorPickerModal = ModalBackdrop

        local ModalCard = Instance.new("Frame")
        ModalCard.Name = "ColorPickerModal"
        ModalCard.Size = UDim2.new(0, 290, 0, 310)
        ModalCard.AnchorPoint = Vector2.new(0.5, 0.5)
        ModalCard.Position = UDim2.new(0.5, 0, 0.5, 20)
        ModalCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        ModalCard.BackgroundTransparency = 0.02
        ModalCard.BorderSizePixel = 0
        ModalCard.ZIndex = 81
        ModalCard.Parent = ModalBackdrop

        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 12)
        ModalCorner.Parent = ModalCard

        local ModalStroke = Instance.new("UIStroke")
        ModalStroke.Thickness = 1.4
        ModalStroke.Color = Color3.fromRGB(255, 255, 255)
        ModalStroke.Transparency = 0.8
        ModalStroke.Parent = ModalCard

        AddUIShadow(ModalCard, 28, 0.6)

        -- Header
        local HeaderLabel = Instance.new("TextLabel")
        HeaderLabel.Name = "HeaderTitle"
        HeaderLabel.Size = UDim2.new(1, -50, 0, 32)
        HeaderLabel.Position = UDim2.new(0, 14, 0, 4)
        HeaderLabel.BackgroundTransparency = 1
        HeaderLabel.FontFace = FontMichromaBold
        HeaderLabel.Text = title or "Select color"
        HeaderLabel.TextColor3 = Window.CurrentTheme.Text
        HeaderLabel.TextSize = 12
        HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
        HeaderLabel.ZIndex = 82
        HeaderLabel.Parent = ModalCard

        local CloseModalBtn = Instance.new("TextButton")
        CloseModalBtn.Name = "CloseBtn"
        CloseModalBtn.Size = UDim2.new(0, 24, 0, 24)
        CloseModalBtn.Position = UDim2.new(1, -32, 0, 8)
        CloseModalBtn.BackgroundTransparency = 1
        CloseModalBtn.FontFace = FontMichromaBold
        CloseModalBtn.Text = "X"
        CloseModalBtn.TextColor3 = Window.CurrentTheme.SubText
        CloseModalBtn.TextSize = 13
        CloseModalBtn.ZIndex = 83
        CloseModalBtn.Parent = ModalCard

        -- SV 2D Canvas (Saturation & Value)
        local SVBox = Instance.new("Frame")
        SVBox.Name = "SVBox"
        SVBox.Size = UDim2.new(1, -28, 0, 125)
        SVBox.Position = UDim2.new(0, 14, 0, 38)
        SVBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        SVBox.BorderSizePixel = 0
        SVBox.ClipsDescendants = false
        SVBox.ZIndex = 82
        SVBox.Parent = ModalCard

        local SVCorner = Instance.new("UICorner")
        SVCorner.CornerRadius = UDim.new(0, 6)
        SVCorner.Parent = SVBox

        -- White horizontal gradient layer
        local WhiteGradFrame = Instance.new("Frame")
        WhiteGradFrame.Size = UDim2.new(1, 0, 1, 0)
        WhiteGradFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WhiteGradFrame.BorderSizePixel = 0
        WhiteGradFrame.ZIndex = 82
        WhiteGradFrame.Parent = SVBox

        local WhiteGradCorner = Instance.new("UICorner")
        WhiteGradCorner.CornerRadius = UDim.new(0, 6)
        WhiteGradCorner.Parent = WhiteGradFrame

        local WhiteGrad = Instance.new("UIGradient")
        WhiteGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
        WhiteGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        WhiteGrad.Rotation = 0
        WhiteGrad.Parent = WhiteGradFrame

        -- Black vertical gradient layer
        local BlackGradFrame = Instance.new("Frame")
        BlackGradFrame.Size = UDim2.new(1, 0, 1, 0)
        BlackGradFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BlackGradFrame.BorderSizePixel = 0
        BlackGradFrame.ZIndex = 83
        BlackGradFrame.Parent = SVBox

        local BlackGradCorner = Instance.new("UICorner")
        BlackGradCorner.CornerRadius = UDim.new(0, 6)
        BlackGradCorner.Parent = BlackGradFrame

        local BlackGrad = Instance.new("UIGradient")
        BlackGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
        BlackGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        BlackGrad.Rotation = 90
        BlackGrad.Parent = BlackGradFrame

        -- SV Draggable Knob
        local SVHandle = Instance.new("Frame")
        SVHandle.Name = "SVHandle"
        SVHandle.Size = UDim2.new(0, 14, 0, 14)
        SVHandle.AnchorPoint = Vector2.new(0.5, 0.5)
        SVHandle.Position = UDim2.new(curS, 0, 1 - curV, 0)
        SVHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SVHandle.BorderSizePixel = 0
        SVHandle.ZIndex = 85
        SVHandle.Parent = SVBox

        local SVHandleCorner = Instance.new("UICorner")
        SVHandleCorner.CornerRadius = UDim.new(1, 0)
        SVHandleCorner.Parent = SVHandle

        local SVHandleStroke = Instance.new("UIStroke")
        SVHandleStroke.Thickness = 1.5
        SVHandleStroke.Color = Color3.fromRGB(0, 0, 0)
        SVHandleStroke.Parent = SVHandle

        local SVTrigger = Instance.new("TextButton")
        SVTrigger.Name = "SVTrigger"
        SVTrigger.Size = UDim2.new(1, 0, 1, 0)
        SVTrigger.BackgroundTransparency = 1
        SVTrigger.Text = ""
        SVTrigger.ZIndex = 86
        SVTrigger.Parent = SVBox

        -- Hue Slider Bar
        local HueBar = Instance.new("Frame")
        HueBar.Name = "HueBar"
        HueBar.Size = UDim2.new(1, -28, 0, 14)
        HueBar.Position = UDim2.new(0, 14, 0, 172)
        HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueBar.BorderSizePixel = 0
        HueBar.ClipsDescendants = false
        HueBar.ZIndex = 82
        HueBar.Parent = ModalCard

        local HueCorner = Instance.new("UICorner")
        HueCorner.CornerRadius = UDim.new(0, 7)
        HueCorner.Parent = HueBar

        local HueGrad = Instance.new("UIGradient")
        HueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
        })
        HueGrad.Parent = HueBar

        local HueHandle = Instance.new("Frame")
        HueHandle.Name = "HueHandle"
        HueHandle.Size = UDim2.new(0, 16, 0, 16)
        HueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
        HueHandle.Position = UDim2.new(curH, 0, 0.5, 0)
        HueHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueHandle.BorderSizePixel = 0
        HueHandle.ZIndex = 85
        HueHandle.Parent = HueBar

        local HueHandleCorner = Instance.new("UICorner")
        HueHandleCorner.CornerRadius = UDim.new(1, 0)
        HueHandleCorner.Parent = HueHandle

        local HueHandleStroke = Instance.new("UIStroke")
        HueHandleStroke.Thickness = 1.5
        HueHandleStroke.Color = Color3.fromRGB(0, 0, 0)
        HueHandleStroke.Parent = HueHandle

        local HueTrigger = Instance.new("TextButton")
        HueTrigger.Name = "HueTrigger"
        HueTrigger.Size = UDim2.new(1, 0, 1, 0)
        HueTrigger.BackgroundTransparency = 1
        HueTrigger.Text = ""
        HueTrigger.ZIndex = 86
        HueTrigger.Parent = HueBar

        -- Preview Swatch & Hex Box
        local PreviewSwatch = Instance.new("Frame")
        PreviewSwatch.Name = "PreviewSwatch"
        PreviewSwatch.Size = UDim2.new(0, 36, 0, 26)
        PreviewSwatch.Position = UDim2.new(0, 14, 0, 196)
        PreviewSwatch.BackgroundColor3 = initialColor
        PreviewSwatch.BorderSizePixel = 0
        PreviewSwatch.ZIndex = 82
        PreviewSwatch.Parent = ModalCard

        local SwatchCorner = Instance.new("UICorner")
        SwatchCorner.CornerRadius = UDim.new(0, 6)
        SwatchCorner.Parent = PreviewSwatch

        local SwatchStroke = Instance.new("UIStroke")
        SwatchStroke.Thickness = 1.2
        SwatchStroke.Color = Color3.fromRGB(255, 255, 255)
        SwatchStroke.Transparency = 0.5
        SwatchStroke.Parent = PreviewSwatch

        local HexContainer = Instance.new("Frame")
        HexContainer.Name = "HexContainer"
        HexContainer.Size = UDim2.new(1, -62, 0, 26)
        HexContainer.Position = UDim2.new(0, 56, 0, 196)
        HexContainer.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        HexContainer.BorderSizePixel = 0
        HexContainer.ZIndex = 82
        HexContainer.Parent = ModalCard

        local HexCorner = Instance.new("UICorner")
        HexCorner.CornerRadius = UDim.new(0, 6)
        HexCorner.Parent = HexContainer

        local HexBox = Instance.new("TextBox")
        HexBox.Name = "HexBox"
        HexBox.Size = UDim2.new(1, -12, 1, 0)
        HexBox.Position = UDim2.new(0, 6, 0, 0)
        HexBox.BackgroundTransparency = 1
        HexBox.FontFace = FontMichromaRegular
        HexBox.PlaceholderText = "#FFFFFF"
        HexBox.PlaceholderColor3 = Window.CurrentTheme.SubText
        HexBox.Text = "#" .. initialColor:ToHex():upper()
        HexBox.TextColor3 = Window.CurrentTheme.Text
        HexBox.TextSize = 11
        HexBox.ClearTextOnFocus = false
        HexBox.ZIndex = 83
        HexBox.Parent = HexContainer

        -- Preset Swatches Row
        local PresetsRow = Instance.new("Frame")
        PresetsRow.Name = "PresetsRow"
        PresetsRow.Size = UDim2.new(1, -28, 0, 22)
        PresetsRow.Position = UDim2.new(0, 14, 0, 230)
        PresetsRow.BackgroundTransparency = 1
        PresetsRow.ZIndex = 82
        PresetsRow.Parent = ModalCard

        local PresetsLayout = Instance.new("UIListLayout")
        PresetsLayout.FillDirection = Enum.FillDirection.Horizontal
        PresetsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PresetsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        PresetsLayout.Padding = UDim.new(0, 6)
        PresetsLayout.Parent = PresetsRow

        local presetColors = {
            Color3.fromRGB(255, 60, 60),
            Color3.fromRGB(255, 145, 0),
            Color3.fromRGB(255, 225, 0),
            Color3.fromRGB(60, 220, 90),
            Color3.fromRGB(0, 210, 255),
            Color3.fromRGB(60, 120, 255),
            Color3.fromRGB(180, 80, 255),
            Color3.fromRGB(255, 255, 255)
        }

        -- Bottom Apply Button
        local ApplyBtn = Instance.new("TextButton")
        ApplyBtn.Name = "ApplyButton"
        ApplyBtn.Size = UDim2.new(1, -28, 0, 32)
        ApplyBtn.Position = UDim2.new(0, 14, 0, 262)
        ApplyBtn.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        ApplyBtn.BorderSizePixel = 0
        ApplyBtn.FontFace = FontMichromaBold
        ApplyBtn.Text = "Apply color"
        ApplyBtn.TextColor3 = Window.CurrentTheme.Text
        ApplyBtn.TextSize = 12
        ApplyBtn.ZIndex = 83
        ApplyBtn.Parent = ModalCard

        local ApplyCorner = Instance.new("UICorner")
        ApplyCorner.CornerRadius = UDim.new(0, 6)
        ApplyCorner.Parent = ApplyBtn

        local isDraggingSV = false
        local isDraggingHue = false

        local function RefreshAll(source)
            curH = math.clamp(curH, 0, 1)
            curS = math.clamp(curS, 0, 1)
            curV = math.clamp(curV, 0, 1)

            selectedColor = Color3.fromHSV(curH, curS, curV)
            SVBox.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            SVHandle.Position = UDim2.new(curS, 0, 1 - curV, 0)
            HueHandle.Position = UDim2.new(curH, 0, 0.5, 0)
            PreviewSwatch.BackgroundColor3 = selectedColor

            if source ~= "hex" then
                HexBox.Text = "#" .. selectedColor:ToHex():upper()
            end
        end

        local function UpdateSV(inputX, inputY)
            local absPos = SVBox.AbsolutePosition
            local absSize = SVBox.AbsoluteSize
            if absSize.X <= 0 or absSize.Y <= 0 then return end
            curS = math.clamp((inputX - absPos.X) / absSize.X, 0, 1)
            curV = math.clamp(1 - ((inputY - absPos.Y) / absSize.Y), 0, 1)
            RefreshAll("sv")
        end

        local function UpdateHue(inputX)
            local absPos = HueBar.AbsolutePosition
            local absSize = HueBar.AbsoluteSize
            if absSize.X <= 0 then return end
            curH = math.clamp((inputX - absPos.X) / absSize.X, 0, 1)
            RefreshAll("hue")
        end

        SVTrigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSV = true
                UpdateSV(input.Position.X, input.Position.Y)
            end
        end)

        HueTrigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingHue = true
                UpdateHue(input.Position.X)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDraggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSV(input.Position.X, input.Position.Y)
            elseif isDraggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateHue(input.Position.X)
            end
        end)

        local endConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSV = false
                isDraggingHue = false
            end
        end)

        HexBox.FocusLost:Connect(function()
            local raw = HexBox.Text:gsub("#", ""):gsub("%s+", "")
            local success, col = pcall(function() return Color3.fromHex(raw) end)
            if success and col then
                curH, curS, curV = col:ToHSV()
                RefreshAll("hex")
            else
                HexBox.Text = "#" .. selectedColor:ToHex():upper()
            end
        end)

        for _, col in ipairs(presetColors) do
            local dot = Instance.new("TextButton")
            dot.Size = UDim2.new(0, 20, 0, 20)
            dot.BackgroundColor3 = col
            dot.Text = ""
            dot.BorderSizePixel = 0
            dot.ZIndex = 83
            dot.Parent = PresetsRow

            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot

            local dotStroke = Instance.new("UIStroke")
            dotStroke.Thickness = 1.2
            dotStroke.Color = Color3.fromRGB(255, 255, 255)
            dotStroke.Transparency = 0.6
            dotStroke.Parent = dot

            dot.MouseButton1Click:Connect(function()
                PlayClickSFX()
                curH, curS, curV = col:ToHSV()
                RefreshAll("preset")
            end)
        end

        local function CloseModal()
            PlayClickSFX()
            if endConn then endConn:Disconnect() end
            TweenService:Create(ModalBackdrop, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            local t = TweenService:Create(ModalCard, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.5, 40),
                Size = UDim2.new(0, 270, 0, 290)
            })
            t:Play()
            t.Completed:Connect(function()
                if ModalBackdrop and ModalBackdrop.Parent then
                    ModalBackdrop:Destroy()
                end
                if ActiveColorPickerModal == ModalBackdrop then
                    ActiveColorPickerModal = nil
                end
            end)
        end

        CloseModalBtn.MouseButton1Click:Connect(CloseModal)
        ModalBackdrop.MouseButton1Click:Connect(function()
            CloseModal()
        end)

        ApplyBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            if onColorSelected then
                pcall(onColorSelected, selectedColor)
            end
            CloseModal()
        end)

        -- Animate In
        TweenService:Create(ModalBackdrop, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.45}):Play()
        TweenService:Create(ModalCard, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 290, 0, 310)
        }):Play()

        RefreshAll("init")
    end

    function Window:CreateMDColorPicker(parent, position, size, title, defaultColor, onColorChanged, identifier)
        size = size or UDim2.new(1, 0, 0, 44)
        position = position or UDim2.new(0, 0, 0, 0)
        defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)

        local CardFrame = Instance.new("Frame")
        CardFrame.Name = "ColorPickerCard"
        CardFrame.Size = size
        CardFrame.Position = position
        CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        CardFrame.BackgroundTransparency = 0.05
        CardFrame.BorderSizePixel = 0
        CardFrame.ZIndex = 10
        CardFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = CardFrame

        AddUIShadow(CardFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0.8
        Stroke.Parent = CardFrame

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(1, -65, 1, 0)
        TitleLabel.Position = UDim2.new(0, 14, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.FontFace = FontMichromaRegular
        TitleLabel.Text = title or "Color"
        TitleLabel.TextColor3 = Window.CurrentTheme.Text
        TitleLabel.TextSize = 12
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
        TitleLabel.ZIndex = 11
        TitleLabel.Parent = CardFrame

        local SwatchButton = Instance.new("TextButton")
        SwatchButton.Name = "SwatchButton"
        SwatchButton.Size = UDim2.new(0, 36, 0, 24)
        SwatchButton.Position = UDim2.new(1, -48, 0.5, -12)
        SwatchButton.BackgroundColor3 = defaultColor
        SwatchButton.BorderSizePixel = 0
        SwatchButton.Text = ""
        SwatchButton.ZIndex = 12
        SwatchButton.Parent = CardFrame

        local SwatchCorner = Instance.new("UICorner")
        SwatchCorner.CornerRadius = UDim.new(0, 6)
        SwatchCorner.Parent = SwatchButton

        local SwatchStroke = Instance.new("UIStroke")
        SwatchStroke.Thickness = 1.2
        SwatchStroke.Color = Color3.fromRGB(255, 255, 255)
        SwatchStroke.Transparency = 0.4
        SwatchStroke.Parent = SwatchButton

        local currentColor = defaultColor

        local colorPickerName = identifier or ("ColorPicker_" .. (#Window.RegisteredColorPickersList + 1))
        local colorPickerData = {
            Name = colorPickerName,
            Frame = CardFrame,
            Swatch = SwatchButton,
            GetColor = function() return currentColor end,
            SetColor = function(col, triggerCallback)
                currentColor = col
                SwatchButton.BackgroundColor3 = col
                if triggerCallback and onColorChanged then
                    pcall(onColorChanged, col)
                end
            end,
            RefreshTheme = function(theme)
                CardFrame.BackgroundColor3 = theme.CardBG
                TitleLabel.TextColor3 = theme.Text
            end
        }

        TrackConn(SwatchButton.MouseButton1Click:Connect(function()
            PlayClickSFX()
            Window:OpenColorPicker(title, currentColor, function(newCol)
                colorPickerData.SetColor(newCol, true)
            end)
        end))

        Window.RegisteredColorPickers[colorPickerName] = colorPickerData
        table.insert(Window.RegisteredColorPickersList, colorPickerData)
        return colorPickerData
    end

    -- =========================================================================
    -- SCRIPTING QOL: SIZE FRACTIONS & ROW WIDTH ENGINE
    -- =========================================================================
    local function ResolveSizeFraction(sizeInput, defaultFraction)
        if sizeInput == nil then
            return defaultFraction or 1.0, nil
        end
        if typeof(sizeInput) == "UDim2" then
            return nil, sizeInput
        end
        if type(sizeInput) == "number" then
            return math.clamp(sizeInput, 0.05, 1.0), nil
        end
        if type(sizeInput) == "string" then
            local lower = sizeInput:lower():gsub("%s+", "")
            if lower == "1" or lower == "full" or lower == "100%" or lower == "1/1" or lower == "single" then
                return 1.0, nil
            elseif lower == "1/2" or lower == "half" or lower == "50%" or lower == "0.5" or lower == "dual" then
                return 0.5, nil
            elseif lower == "1/3" or lower == "third" or lower == "33%" or lower == "0.33" or lower == "0.333" or lower == "triple" then
                return 1/3, nil
            elseif lower == "2/3" or lower == "two-thirds" or lower == "66%" or lower == "0.66" or lower == "0.666" or lower == "0.67" then
                return 2/3, nil
            elseif lower == "1/4" or lower == "quarter" or lower == "fourth" or lower == "25%" or lower == "0.25" or lower == "quad" then
                return 0.25, nil
            elseif lower == "3/4" or lower == "three-fourths" or lower == "75%" or lower == "0.75" then
                return 0.75, nil
            else
                local num = tonumber(lower)
                if num then
                    return math.clamp(num, 0.05, 1.0), nil
                end
            end
        end
        return defaultFraction or 1.0, nil
    end

    local function ComputeRowItemWidth(fraction, height)
        height = height or 44
        if not fraction or fraction >= 0.98 then
            return UDim2.new(1, 0, 0, height)
        elseif fraction >= 0.48 and fraction <= 0.52 then
            return UDim2.new(0.5, -4, 0, height)
        elseif fraction >= 0.31 and fraction <= 0.35 then
            return UDim2.new(0.3333, -5, 0, height)
        elseif fraction >= 0.64 and fraction <= 0.68 then
            return UDim2.new(0.6666, -5, 0, height)
        elseif fraction >= 0.23 and fraction <= 0.27 then
            return UDim2.new(0.25, -6, 0, height)
        elseif fraction >= 0.73 and fraction <= 0.77 then
            return UDim2.new(0.75, -6, 0, height)
        else
            local items = math.max(1, math.floor((1 / fraction) + 0.5))
            local gapSub = math.floor(((items - 1) * 8 / items) + 0.5)
            return UDim2.new(fraction, -gapSub, 0, height)
        end
    end

    -- Long Button Generator (Half-Side / Full-Row / Fractional)
    function Window:CreateMDButtonLong(parent, position, size, text, onClick)
        local btnText, callback, btnSize, btnPos, targetParent

        if type(parent) == "table" and not parent.IsA then
            targetParent = parent.Parent or parent.parent or parent.Row or parent[1]
            btnPos = parent.Position or parent.pos or UDim2.new(0, 0, 0, 0)
            btnSize = parent.Size or parent.size or parent.Fraction or parent[2]
            btnText = parent.Text or parent.text or parent.Title or parent.Name or parent[3] or "Button"
            callback = parent.Callback or parent.callback or parent.OnClick or parent[4]
        else
            targetParent = parent
            btnPos = position or UDim2.new(0, 0, 0, 0)
            btnSize = size
            btnText = text or "Function"
            callback = onClick
        end

        local fraction, explicitUDim = ResolveSizeFraction(btnSize, nil)
        if explicitUDim then
            size = explicitUDim
        elseif fraction then
            size = ComputeRowItemWidth(fraction, 44)
        else
            size = UDim2.new(1, 0, 0, 44)
        end
        position = btnPos or UDim2.new(0, 0, 0, 0)
        text = btnText or "Function"
        onClick = callback

        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = "TopFrame"
        BtnFrame.Size = size
        BtnFrame.Position = position
        BtnFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        BtnFrame.BackgroundTransparency = 0.05
        BtnFrame.BorderSizePixel = 0
        BtnFrame.ZIndex = 10
        BtnFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 22)
        Corner.Parent = BtnFrame

        AddUIShadow(BtnFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.5
        Stroke.Transparency = 0
        Stroke.Parent = BtnFrame

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = "Text"
        MDTextFolder.Parent = BtnFrame

        local BtnText = Instance.new("TextLabel")
        BtnText.Name = "btntext"
        BtnText.Size = UDim2.new(1, -12, 1, 0)
        BtnText.Position = UDim2.new(0, 6, 0, 0)
        BtnText.BackgroundTransparency = 1
        BtnText.FontFace = FontMichromaRegular
        BtnText.RichText = true
        BtnText.Text = text or "Function"
        BtnText.TextColor3 = Window.CurrentTheme.Text
        BtnText.TextScaled = false
        BtnText.TextSize = 11
        BtnText.TextWrapped = true
        BtnText.TextWrapped = true
        BtnText.TextXAlignment = Enum.TextXAlignment.Center
        BtnText.TextYAlignment = Enum.TextYAlignment.Center
        BtnText.ZIndex = 11
        BtnText.Parent = MDTextFolder

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = "ClickTrigger"
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 12
        ClickBtn.Parent = BtnFrame

        TrackConn(ClickBtn.MouseEnter:Connect(function()
            PlayHoverSFX()
            TweenService:Create(Stroke, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 2.2}):Play()
            local hoverSize = UDim2.new(size.X.Scale, math.floor(size.X.Offset * 1.02), size.Y.Scale, math.floor(size.Y.Offset * 1.02))
            TweenService:Create(BtnFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = hoverSize}):Play()
        end))

        TrackConn(ClickBtn.MouseLeave:Connect(function()
            TweenService:Create(Stroke, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 1.5}):Play()
            TweenService:Create(BtnFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = size}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Down:Connect(function()
            PlayClickSFX()
            local pressedSize = UDim2.new(size.X.Scale, math.floor(size.X.Offset * 0.96), size.Y.Scale, math.floor(size.Y.Offset * 0.96))
            TweenService:Create(BtnFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = pressedSize}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Up:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = size}):Play()
        end))

        if onClick then
            TrackConn(ClickBtn.MouseButton1Click:Connect(onClick))
        end

        local btnData = {
            Frame = BtnFrame,
            TextLabel = BtnText,
            Stroke = Stroke,
            Trigger = ClickBtn,
            BaseSize = size
        }
        table.insert(Window.RegisteredMDButtons, btnData)

        return btnData
    end

    -- Half-Side Embedded Toggle Generator
    function Window:CreateMDToggleHalf(parent, position, size, text, initialState, onToggle, keybindConfig)
        size = size or UDim2.new(0, 260, 0, 44)
        position = position or UDim2.new(0, 0, 0, 0)

        local CardFrame = Instance.new("Frame")
        CardFrame.Name = "TopFrame"
        CardFrame.Size = size
        CardFrame.Position = position
        CardFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        CardFrame.BackgroundTransparency = 0.05
        CardFrame.BorderSizePixel = 0
        CardFrame.ZIndex = 10
        CardFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 22)
        Corner.Parent = CardFrame

        AddUIShadow(CardFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.5
        Stroke.Transparency = 0
        Stroke.Parent = CardFrame

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = "Text"
        MDTextFolder.Parent = CardFrame

        local hasKeybind = keybindConfig ~= nil and keybindConfig ~= false

        local TitleText = Instance.new("TextLabel")
        TitleText.Name = "btntext"
        TitleText.Size = hasKeybind and UDim2.new(1, -104, 1, 0) or UDim2.new(1, -65, 1, 0)
        TitleText.Position = UDim2.new(0, 14, 0, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.FontFace = FontMichromaRegular
        TitleText.RichText = true
        TitleText.Text = text or "Function"
        TitleText.TextColor3 = Window.CurrentTheme.Text
        TitleText.TextSize = 13
        TitleText.TextWrapped = true
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.TextYAlignment = Enum.TextYAlignment.Center
        TitleText.ZIndex = 11
        TitleText.Parent = MDTextFolder

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "TogglePill"
        ToggleFrame.Size = UDim2.new(0, 44, 0, 24)
        ToggleFrame.Position = UDim2.new(1, -54, 0.5, -12)
        ToggleFrame.BackgroundColor3 = initialState and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
        ToggleFrame.BackgroundTransparency = 0.05
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.ClipsDescendants = false
        ToggleFrame.ZIndex = 11
        ToggleFrame.Parent = CardFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 12)
        ToggleCorner.Parent = ToggleFrame

        AddUIShadow(ToggleFrame, 20, 0.5)

        local KnobFolder = Instance.new("Folder")
        KnobFolder.Name = "Knob"
        KnobFolder.Parent = ToggleFrame

        local isToggled = initialState

        local BaseCircle = Instance.new("ImageLabel")
        BaseCircle.Name = "ToggleThingLikeCircle"
        BaseCircle.Size = UDim2.new(0, 18, 0, 18)
        BaseCircle.Position = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ZIndex = 12
        BaseCircle.Parent = KnobFolder

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = "ThethingOnTopThatMatchesBGofIt"
        OverlayCircle.Size = UDim2.new(0, 19, 0, 19)
        OverlayCircle.Position = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        OverlayCircle.BackgroundTransparency = 1
        OverlayCircle.Image = "rbxassetid://100354746235648"
        OverlayCircle.ImageColor3 = Window.CurrentTheme.ButtonBG
        OverlayCircle.ZIndex = 13
        OverlayCircle.Parent = KnobFolder

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = "ClickTrigger"
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 14
        ClickBtn.Parent = CardFrame

        local function PerformToggle(newState, triggerCallback)
            isToggled = (newState == true)
            local targetKnobPosBase = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            local targetKnobPosOver = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            local targetBG = isToggled and Window.CurrentTheme.ButtonBG or ((Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))

            TweenService:Create(BaseCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetKnobPosBase}):Play()
            TweenService:Create(OverlayCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetKnobPosOver}):Play()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetBG}):Play()

            if triggerCallback and onToggle then
                pcall(onToggle, isToggled)
            end
        end

        TrackConn(ClickBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            PerformToggle(not isToggled, true)
        end))

        local toggleName = text or ("ToggleHalf_" .. (#Window.RegisteredMDToggles + 1))
        local toggleData = {
            Name = toggleName,
            Frame = CardFrame,
            ToggleFrame = ToggleFrame,
            BaseCircle = BaseCircle,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetState = function() return isToggled end,
            SetState = function(state, triggerCallback)
                PerformToggle(state, triggerCallback)
            end
        }

        if hasKeybind then
            local defaultKey = (type(keybindConfig) == "table" and (keybindConfig.Default or keybindConfig.Bind)) or (keybindConfig ~= true and keybindConfig or nil)
            toggleData.Keybind = Window:CreateKeybindBadge(CardFrame, UDim2.new(1, -96, 0.5, -11), UDim2.new(0, 36, 0, 22), defaultKey, function()
                toggleData.SetState(not isToggled, true)
                PlayClickSFX()
            end, toggleName)
        end

        Window.RegisteredToggles[toggleName] = toggleData
        table.insert(Window.RegisteredMDToggles, toggleData)

        return toggleData
    end


    ScriptUi = Instance.new("ScreenGui")
    ScriptUi.Name = "ScriptUi"
    ScriptUi.ResetOnSpawn = false
    ScriptUi.Enabled = false
    ScriptUi.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScriptUi.DisplayOrder = 10
    ScriptUi.Parent = ParentGui

    MinimisedUI = Instance.new("ScreenGui")
    MinimisedUI.Name = "MinimisedUI"
    MinimisedUI.ResetOnSpawn = false
    MinimisedUI.Enabled = false
    MinimisedUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MinimisedUI.DisplayOrder = 25
    MinimisedUI.Parent = ParentGui

    NotificationUI = Instance.new("ScreenGui")
    NotificationUI.Name = "NotificationUI"
    NotificationUI.ResetOnSpawn = false
    NotificationUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationUI.DisplayOrder = 30
    NotificationUI.Parent = ParentGui

    MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 660, 0, 430)
    MainContainer.Position = UDim2.new(0.5, -330, 0.5, -215)
    MainContainer.BackgroundTransparency = 1
    MainContainer.ClipsDescendants = false
    MainContainer.Parent = ScriptUi

    UIScaleConstraint = Instance.new("UIScale")
    UIScaleConstraint.Name = "MainUIScale"
    UIScaleConstraint.Parent = MainContainer

    -- =========================================================================
    -- LOCAL UI-ONLY BACKGROUND BLUR ENGINE
    -- =========================================================================
    local Lighting = game:GetService("Lighting")
    for _, item in ipairs(Lighting:GetChildren()) do
        if item.Name == "ScriptHubBlur" or item.Name == "ScriptHubDOF" or item.Name == "MDScriptHubBlur" or item.Name == "MDScriptHubDOF" then
            pcall(function() item:Destroy() end)
        end
    end
    for _, item in ipairs(Camera:GetChildren()) do
        if item.Name == "ScriptHubBlur" or item.Name == "ScriptHubBlurCam" or item.Name == "ScriptHubDOF" or item.Name == "LocalUIBlurPart" or item.Name == "MDScriptHubBlur" or item.Name == "MDScriptHubBlurCam" or item.Name == "MDScriptHubDOF" or item.Name == "MD_LocalUIBlurPart" then
            pcall(function() item:Destroy() end)
        end
    end
    for _, item in ipairs(workspace:GetChildren()) do
        if item.Name == "LocalUIBlurPart" or item.Name == "MD_LocalUIBlurPart" then
            pcall(function() item:Destroy() end)
        end
    end

    local BackgroundDOF = Instance.new("DepthOfFieldEffect")
    BackgroundDOF.Name = "ScriptHubDOF"
    BackgroundDOF.FocusDistance = 2.5
    BackgroundDOF.InFocusRadius = 0
    BackgroundDOF.NearIntensity = 1.0
    BackgroundDOF.FarIntensity = 0.0
    BackgroundDOF.Enabled = false -- Disabled during loading screen
    BackgroundDOF.Parent = Lighting

    local LocalUIBlurPart = Instance.new("Part")
    LocalUIBlurPart.Name = "LocalUIBlurPart"
    LocalUIBlurPart.Material = Enum.Material.Glass
    LocalUIBlurPart.Transparency = 1 -- Fully transparent during loading screen
    LocalUIBlurPart.Color = Color3.fromRGB(255, 255, 255)
    LocalUIBlurPart.CastShadow = false
    LocalUIBlurPart.CanCollide = false
    LocalUIBlurPart.CanTouch = false
    LocalUIBlurPart.CanQuery = false
    LocalUIBlurPart.Anchored = true
    LocalUIBlurPart.Size = Vector3.new(1, 1, 0.01)
    LocalUIBlurPart.Parent = workspace

    Window.BackgroundDOF = BackgroundDOF
    Window.LocalUIBlurPart = LocalUIBlurPart

    local function UpdateLocalUIBlur()
        if not Window.BackgroundBlurEnabled then return end
        if not ScriptUi or not ScriptUi.Enabled then return end
        if not MainContainer or not MainContainer.Parent then return end

        local Camera = workspace.CurrentCamera
        if not Camera or not Camera.FieldOfView then return end

        local absPos = MainContainer.AbsolutePosition
        local absSize = MainContainer.AbsoluteSize
        if not absPos or not absSize or absSize.X <= 30 or absSize.Y <= 30 then return end

        local padX = 16
        local padY = 16
        local minX = absPos.X + padX
        local minY = absPos.Y + padY
        local maxX = absPos.X + absSize.X - padX
        local maxY = absPos.Y + absSize.Y - padY

        local rayTL = Camera:ScreenPointToRay(minX, minY)
        local rayBR = Camera:ScreenPointToRay(maxX, maxY)
        local rayC = Camera:ScreenPointToRay((minX + maxX) * 0.5, (minY + maxY) * 0.5)

        local depth = 1.0
        local dirTL = Camera.CFrame:VectorToObjectSpace(rayTL.Direction)
        local dirBR = Camera.CFrame:VectorToObjectSpace(rayBR.Direction)
        local dirC = Camera.CFrame:VectorToObjectSpace(rayC.Direction)

        if dirTL.Z >= 0 or dirBR.Z >= 0 or dirC.Z >= 0 then return end

        local x1 = (dirTL.X / -dirTL.Z) * depth
        local y1 = (dirTL.Y / -dirTL.Z) * depth
        local x2 = (dirBR.X / -dirBR.Z) * depth
        local y2 = (dirBR.Y / -dirBR.Z) * depth
        local cX = (dirC.X / -dirC.Z) * depth
        local cY = (dirC.Y / -dirC.Z) * depth

        local partW = math.abs(x2 - x1)
        local partH = math.abs(y1 - y2)

        LocalUIBlurPart.Size = Vector3.new(partW, partH, 0.01)
        LocalUIBlurPart.CFrame = Camera.CFrame * CFrame.new(cX, cY, -depth)
    end

    TrackConn(RunService.RenderStepped:Connect(function()
        UpdateLocalUIBlur()
    end))

    -- =========================================================================
    -- SPIDERWEB BACKGROUND ENGINE
    -- =========================================================================
    local GuiService = game:GetService("GuiService")
    local function InitSpiderwebBackground(container, screenGui)
        local WebCanvas = Instance.new("Frame")
        WebCanvas.Name = "SpiderwebCanvas"
        WebCanvas.Size = UDim2.new(1, 0, 1, 0)
        WebCanvas.Position = UDim2.new(0, 0, 0, 0)
        WebCanvas.BackgroundTransparency = 1
        WebCanvas.ClipsDescendants = true
        WebCanvas.ZIndex = 2
        WebCanvas.Parent = container

        local WebCorner = Instance.new("UICorner")
        WebCorner.CornerRadius = UDim.new(0, 10)
        WebCorner.Parent = WebCanvas

        local nodes = {}
        local linePool = {}
        local maxLines = 110

        for i = 1, maxLines do
            local line = Instance.new("Frame")
            line.Name = "WebLine_" .. i
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.BorderSizePixel = 0
            line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            line.BackgroundTransparency = 1
            line.ZIndex = 2
            line.Visible = false
            line.Parent = WebCanvas
            table.insert(linePool, line)
        end

        local function GetBrighterThemeColor()
            local base = Window.CurrentTheme.Divider or Window.CurrentTheme.ButtonBG or Color3.fromRGB(180, 180, 200)
            local h, s, v = Color3.toHSV(base)
            return Color3.fromHSV(h, math.clamp(s * 0.85, 0.35, 1), math.clamp(v * 1.4, 0.75, 1))
        end

        local function ResetNodes()
            nodes = {}
            local absSize = WebCanvas.AbsoluteSize
            local w = (absSize.X > 100) and absSize.X or 660
            local h = (absSize.Y > 100) and absSize.Y or 440

            local cols, rows = 7, 5
            local cellW = w / cols
            local cellH = h / rows

            for r = 1, rows do
                for c = 1, cols do
                    local bx = math.floor((c - 0.5) * cellW + math.random(-cellW * 0.35, cellW * 0.35))
                    local by = math.floor((r - 0.5) * cellH + math.random(-cellH * 0.35, cellH * 0.35))
                    bx = math.clamp(bx, 15, w - 15)
                    by = math.clamp(by, 15, h - 15)
                    table.insert(nodes, {
                        base = Vector2.new(bx, by),
                        current = Vector2.new(bx, by),
                        vel = Vector2.new(0, 0)
                    })
                end
            end
        end

        ResetNodes()
        TrackConn(WebCanvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResetNodes))

        TrackConn(RunService.RenderStepped:Connect(function(dt)
            if not WebCanvas or not WebCanvas.Parent or not screenGui.Enabled then return end
            dt = dt or (1 / 60)

            if not Window.SpiderwebBGEnabled then
                for k = 1, maxLines do
                    linePool[k].Visible = false
                end
                return
            end

            local rawMouse = UserInputService:GetMouseLocation()
            local guiInset = GuiService:GetGuiInset()
            local canvasPos = WebCanvas.AbsolutePosition
            local scale = (UIScaleConstraint and UIScaleConstraint.Scale > 0) and UIScaleConstraint.Scale or 1.0

            local relMouse = Vector2.new(
                (rawMouse.X - canvasPos.X) / scale,
                (rawMouse.Y - canvasPos.Y - guiInset.Y) / scale
            )

            local mouseRadius = 200
            local maxConnectDist = 125
            local brightColor = GetBrighterThemeColor()

            local stepDt = math.min(dt, 0.05)
            local dampFactor = math.exp(-14.0 * stepDt)
            local pullStrength = 1600.0
            local springStiffness = 32.0
            local maxSpeed = 450.0

            for _, node in ipairs(nodes) do
                local toMouse = relMouse - node.current
                local distMouse = toMouse.Magnitude

                if distMouse < mouseRadius and distMouse > 1 then
                    local normDist = distMouse / mouseRadius
                    local pullFactor = 1 - (normDist * normDist)
                    local pullAccel = pullStrength * pullFactor
                    node.vel = node.vel + (toMouse.Unit * (pullAccel * stepDt))
                end

                local toBase = node.base - node.current
                node.vel = node.vel + (toBase * (springStiffness * stepDt))
                node.vel = node.vel * dampFactor

                local currentSpeed = node.vel.Magnitude
                if currentSpeed > maxSpeed then
                    node.vel = (node.vel / currentSpeed) * maxSpeed
                end

                local absCanvas = WebCanvas.AbsoluteSize
                local maxW = (absCanvas.X > 50) and (absCanvas.X - 12) or 648
                local maxH = (absCanvas.Y > 50) and (absCanvas.Y - 12) or 428
                local nextX = math.clamp(node.current.X + (node.vel.X * stepDt), 12, maxW)
                local nextY = math.clamp(node.current.Y + (node.vel.Y * stepDt), 12, maxH)
                node.current = Vector2.new(nextX, nextY)
            end

            local lineIdx = 1

            for i = 1, #nodes do
                for j = i + 1, #nodes do
                    if lineIdx > maxLines then break end

                    local n1 = nodes[i]
                    local n2 = nodes[j]

                    local dNodes = (n2.current - n1.current).Magnitude
                    if dNodes < maxConnectDist then
                        local midPoint = (n1.current + n2.current) / 2
                        local distToMouse = (relMouse - midPoint).Magnitude

                        if distToMouse < mouseRadius then
                            local alpha = math.clamp(distToMouse / mouseRadius, 0, 1)
                            local transparency = 0.05 + (alpha * 0.85)

                            local line = linePool[lineIdx]
                            local dir = n2.current - n1.current
                            local angle = math.deg(math.atan2(dir.Y, dir.X))

                            line.Size = UDim2.new(0, dNodes, 0, 1.5)
                            line.Position = UDim2.new(0, midPoint.X, 0, midPoint.Y)
                            line.Rotation = angle
                            line.BackgroundColor3 = brightColor
                            line.BackgroundTransparency = transparency
                            line.Visible = true

                            lineIdx = lineIdx + 1
                        end
                    end
                end
            end

            for k = lineIdx, maxLines do
                linePool[k].Visible = false
            end
        end))
    end


    local function GetTargetViewportScale()
        if not Camera then return 0.85 end
        local viewport = Camera.ViewportSize
        local scaleX = viewport.X / 680
        local scaleY = viewport.Y / 440
        return math.clamp(math.min(scaleX, scaleY), 0.45, 1.0)
    end

    local function UpdateScreenScaling()
        UIScaleConstraint.Scale = GetTargetViewportScale()
    end

    TrackConn(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScreenScaling))
    UpdateScreenScaling()

    local LastWindowSize = MainContainer.Size
    local LastWindowPos = MainContainer.Position

    local SwitchTab = nil

    -- TopFrame
    local TopFrame = Instance.new("Frame")
    TopFrame.Name = "TopFrame"
    TopFrame.Size = UDim2.new(1, 0, 0, 42)
    TopFrame.Position = UDim2.new(0, 0, 0, 0)
    TopFrame.BackgroundColor3 = Window.CurrentTheme.TopBG
    TopFrame.BackgroundTransparency = Window.CurrentTheme.TopTrans
    TopFrame.BorderSizePixel = 0
    TopFrame.ZIndex = 4
    TopFrame.Parent = MainContainer

    local TopCorner = Instance.new("UICorner")
    ApplyCornerRadii(TopCorner, 8, 8, 0, 0)
    TopCorner.Parent = TopFrame

    AddUIShadow(TopFrame, 20, 0.5)

    local MDTextFolder = Instance.new("Folder")
    MDTextFolder.Name = "Text"
    MDTextFolder.Parent = TopFrame

    local MDHUBNAME = Instance.new("TextLabel")
    MDHUBNAME.Name = "HubName"
    MDHUBNAME.Size = UDim2.new(0, 180, 0, 46)
    MDHUBNAME.Position = UDim2.new(0.0259, 0, -0.052, 0)
    MDHUBNAME.BackgroundTransparency = 1
    MDHUBNAME.FontFace = FontMichromaHeavy
    MDHUBNAME.Text = hubTitle
    MDHUBNAME.TextColor3 = Window.CurrentTheme.Text
    MDHUBNAME.TextSize = 15
    MDHUBNAME.TextXAlignment = Enum.TextXAlignment.Left
    MDHUBNAME.ZIndex = 5
    MDHUBNAME.Parent = MDTextFolder

    -- Topbar Search Bar
    local SearchBarContainer = Instance.new("Frame")
    SearchBarContainer.Name = "SearchBarContainer"
    SearchBarContainer.Size = UDim2.new(0, 230, 0, 26)
    SearchBarContainer.Position = UDim2.new(0.5, -115, 0.5, -13)
    SearchBarContainer.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(22, 24, 30)
    SearchBarContainer.BackgroundTransparency = 0.1
    SearchBarContainer.BorderSizePixel = 0
    SearchBarContainer.ZIndex = 6
    SearchBarContainer.Parent = TopFrame

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 13)
    SearchCorner.Parent = SearchBarContainer

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Thickness = 1.1
    SearchStroke.Color = Color3.fromRGB(255, 255, 255)
    SearchStroke.Transparency = 0.82
    SearchStroke.Parent = SearchBarContainer

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://6031154871"
    SearchIcon.ImageColor3 = Window.CurrentTheme.SubText
    SearchIcon.ZIndex = 7
    SearchIcon.Parent = SearchBarContainer

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -48, 1, 0)
    SearchInput.Position = UDim2.new(0, 26, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.FontFace = FontMichromaRegular
    SearchInput.PlaceholderText = "Search scripts..."
    SearchInput.PlaceholderColor3 = Window.CurrentTheme.SubText
    SearchInput.Text = ""
    SearchInput.TextColor3 = Window.CurrentTheme.Text
    SearchInput.TextSize = 11
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.ZIndex = 7
    SearchInput.Parent = SearchBarContainer

    local ClearSearchBtn = Instance.new("TextButton")
    ClearSearchBtn.Name = "ClearSearchBtn"
    ClearSearchBtn.Size = UDim2.new(0, 16, 0, 16)
    ClearSearchBtn.Position = UDim2.new(1, -22, 0.5, -8)
    ClearSearchBtn.BackgroundTransparency = 1
    ClearSearchBtn.FontFace = FontMichromaBold
    ClearSearchBtn.Text = "X"
    ClearSearchBtn.TextColor3 = Window.CurrentTheme.SubText
    ClearSearchBtn.TextSize = 10
    ClearSearchBtn.Visible = false
    ClearSearchBtn.ZIndex = 8
    ClearSearchBtn.Parent = SearchBarContainer

    -- Search Results Dropdown Overlay (Floats on MainContainer)
    local SearchResultsOverlay = Instance.new("Frame")
    SearchResultsOverlay.Name = "SearchResultsOverlay"
    SearchResultsOverlay.Size = UDim2.new(0, 230, 0, 0)
    SearchResultsOverlay.Position = UDim2.new(0.5, -115, 0, 44)
    SearchResultsOverlay.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(240, 245, 255) or Color3.fromRGB(20, 22, 28)
    SearchResultsOverlay.BackgroundTransparency = 0.05
    SearchResultsOverlay.BorderSizePixel = 0
    SearchResultsOverlay.ClipsDescendants = true
    SearchResultsOverlay.ZIndex = 50
    SearchResultsOverlay.Visible = false
    SearchResultsOverlay.Parent = MainContainer

    local ResultsCorner = Instance.new("UICorner")
    ResultsCorner.CornerRadius = UDim.new(0, 8)
    ResultsCorner.Parent = SearchResultsOverlay

    local ResultsStroke = Instance.new("UIStroke")
    ResultsStroke.Thickness = 1.2
    ResultsStroke.Color = Color3.fromRGB(255, 255, 255)
    ResultsStroke.Transparency = 0.8
    ResultsStroke.Parent = SearchResultsOverlay

    AddUIShadow(SearchResultsOverlay, 20, 0.5)

    local ResultsScroll = Instance.new("ScrollingFrame")
    ResultsScroll.Name = "ResultsScroll"
    ResultsScroll.Size = UDim2.new(1, 0, 1, 0)
    ResultsScroll.Position = UDim2.new(0, 0, 0, 0)
    ResultsScroll.BackgroundTransparency = 1
    ResultsScroll.BorderSizePixel = 0
    ResultsScroll.ScrollBarThickness = 0
    ResultsScroll.ScrollBarImageTransparency = 1
    ResultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ResultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ResultsScroll.ZIndex = 51
    ResultsScroll.Parent = SearchResultsOverlay

    local ResultsPadding = Instance.new("UIPadding")
    ResultsPadding.PaddingTop = UDim.new(0, 5)
    ResultsPadding.PaddingBottom = UDim.new(0, 5)
    ResultsPadding.PaddingLeft = UDim.new(0, 4)
    ResultsPadding.PaddingRight = UDim.new(0, 4)
    ResultsPadding.Parent = ResultsScroll

    local ResultsLayout = Instance.new("UIListLayout")
    ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ResultsLayout.Padding = UDim.new(0, 3)
    ResultsLayout.Parent = ResultsScroll

    local function PerformSearch(rawText)
        local query = rawText:gsub("^%s+", ""):gsub("%s+$", ""):lower()
        if query == "" then
            ClearSearchBtn.Visible = false
            SearchResultsOverlay.Visible = false
            SearchResultsOverlay.Size = UDim2.new(0, 230, 0, 0)
            for _, item in ipairs(Window.SearchableItems) do
                if item.Instance and item.Instance.Parent then
                    item.Instance.Visible = true
                end
            end
            return
        end

        ClearSearchBtn.Visible = true

        for _, item in ipairs(Window.SearchableItems) do
            if item.TabName == Window.ActiveTab and item.Instance and item.Instance.Parent then
                local match = item.Name:lower():find(query, 1, true) or item.Desc:lower():find(query, 1, true)
                item.Instance.Visible = (match ~= nil)
            end
        end

        for _, child in ipairs(ResultsScroll:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end

        local matches = {}
        for _, item in ipairs(Window.SearchableItems) do
            local nameMatch = item.Name:lower():find(query, 1, true)
            local descMatch = item.Desc:lower():find(query, 1, true)
            local tabMatch = item.TabName:lower():find(query, 1, true)
            if nameMatch or descMatch or tabMatch then
                table.insert(matches, item)
            end
        end

        if #matches == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 0, 28)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.FontFace = FontMichromaRegular
            emptyLabel.Text = "No results found"
            emptyLabel.TextColor3 = Window.CurrentTheme.SubText
            emptyLabel.TextSize = 10
            emptyLabel.ZIndex = 52
            emptyLabel.Parent = ResultsScroll

            SearchResultsOverlay.Visible = true
            TweenService:Create(SearchResultsOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 230, 0, 38)
            }):Play()
            return
        end

        local maxToShow = math.min(#matches, 6)
        for i = 1, maxToShow do
            local item = matches[i]
            local rowBtn = Instance.new("TextButton")
            rowBtn.Name = "SearchResult"
            rowBtn.Size = UDim2.new(1, -4, 0, 30)
            rowBtn.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(30, 33, 42)
            rowBtn.BackgroundTransparency = 0.4
            rowBtn.Text = ""
            rowBtn.ZIndex = 52
            rowBtn.Parent = ResultsScroll

            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 6)
            rowCorner.Parent = rowBtn

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(1, -12, 0, 15)
            titleLbl.Position = UDim2.new(0, 8, 0, 1)
            titleLbl.BackgroundTransparency = 1
            titleLbl.FontFace = FontMichromaBold
            titleLbl.Text = item.Name
            titleLbl.TextColor3 = Window.CurrentTheme.Text
            titleLbl.TextSize = 10
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
            titleLbl.ZIndex = 53
            titleLbl.Parent = rowBtn

            local subLbl = Instance.new("TextLabel")
            subLbl.Size = UDim2.new(1, -12, 0, 12)
            subLbl.Position = UDim2.new(0, 8, 0, 15)
            subLbl.BackgroundTransparency = 1
            subLbl.FontFace = FontMichromaRegular
            subLbl.Text = item.TabName
            subLbl.TextColor3 = Window.CurrentTheme.SubText
            subLbl.TextSize = 8
            subLbl.TextXAlignment = Enum.TextXAlignment.Left
            subLbl.TextTruncate = Enum.TextTruncate.AtEnd
            subLbl.ZIndex = 53
            subLbl.Parent = rowBtn

            rowBtn.MouseEnter:Connect(function()
                TweenService:Create(rowBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
            end)
            rowBtn.MouseLeave:Connect(function()
                TweenService:Create(rowBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
            end)

            rowBtn.MouseButton1Click:Connect(function()
                PlayClickSFX()
                if SwitchTab then
                    SwitchTab(item.TabName)
                end
                SearchResultsOverlay.Visible = false
                SearchResultsOverlay.Size = UDim2.new(0, 230, 0, 0)
                if item.Instance and item.Instance.Parent then
                    item.Instance.Visible = true
                end
            end)
        end

        -- Exact snug fit: each row 30px + 3px layout spacing + 10px vertical padding (5 top + 5 bottom)
        local targetHeight = (maxToShow * 30) + math.max(0, (maxToShow - 1) * 3) + 10
        SearchResultsOverlay.Visible = true
        TweenService:Create(SearchResultsOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 230, 0, targetHeight)
        }):Play()
    end

    TrackConn(SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        PerformSearch(SearchInput.Text)
    end))

    TrackConn(ClearSearchBtn.MouseButton1Click:Connect(function()
        PlayClickSFX()
        SearchInput.Text = ""
        PerformSearch("")
    end))

    local TopRightFolder = Instance.new("Folder")
    TopRightFolder.Name = "toprightbuttons"
    TopRightFolder.Parent = TopFrame

    local MinimiseBtnFrame = Instance.new("Frame")
    MinimiseBtnFrame.Size = UDim2.new(0, 30, 0, 30)
    MinimiseBtnFrame.Position = UDim2.new(0.877, 0, 0.14, 0)
    MinimiseBtnFrame.BackgroundTransparency = 1
    MinimiseBtnFrame.ZIndex = 5
    MinimiseBtnFrame.Parent = TopRightFolder

    local MinimiseBtn = Instance.new("ImageButton")
    MinimiseBtn.Size = UDim2.new(1, 0, 1, 0)
    MinimiseBtn.BackgroundTransparency = 1
    MinimiseBtn.ZIndex = 5
    MinimiseBtn.Parent = MinimiseBtnFrame

    local MinimiseIcon = Instance.new("ImageLabel")
    MinimiseIcon.Size = UDim2.new(0, 20, 0, 20)
    MinimiseIcon.Position = UDim2.new(0.168, 0, 0.168, 0)
    MinimiseIcon.BackgroundTransparency = 1
    MinimiseIcon.Image = "rbxassetid://15396333997"
    MinimiseIcon.ZIndex = 6
    MinimiseIcon.Parent = MinimiseBtn

    TrackConn(MinimiseBtn.MouseEnter:Connect(PlayHoverSFX))

    local CloseBtnFrame = Instance.new("Frame")
    CloseBtnFrame.Size = UDim2.new(0, 30, 0, 30)
    CloseBtnFrame.Position = UDim2.new(0.939, 0, 0.14, 0)
    CloseBtnFrame.BackgroundTransparency = 1
    CloseBtnFrame.ZIndex = 5
    CloseBtnFrame.Parent = TopRightFolder

    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 5
    CloseBtn.Parent = CloseBtnFrame

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.new(0, 27, 0, 27)
    CloseIcon.Position = UDim2.new(0.05, 0, 0.05, 0)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://132261474823036"
    CloseIcon.ZIndex = 6
    CloseIcon.Parent = CloseBtn

    TrackConn(CloseBtn.MouseEnter:Connect(PlayHoverSFX))

    -- Left Sidebar Background Panel (ZIndex 1)
    local LeftFrame = Instance.new("Frame")
    LeftFrame.Name = "LeftFrame"
    LeftFrame.Size = UDim2.new(0, 175, 1, -94)
    LeftFrame.Position = UDim2.new(0, 0, 0, 42)
    LeftFrame.BackgroundColor3 = Window.CurrentTheme.AccentBG
    LeftFrame.BackgroundTransparency = Window.CurrentTheme.AccentTrans
    LeftFrame.BorderSizePixel = 0
    LeftFrame.ZIndex = 1
    LeftFrame.Parent = MainContainer

    -- Main Content Background Panel (ZIndex 1)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, -175, 1, -94)
    MainFrame.Position = UDim2.new(0, 175, 0, 42)
    MainFrame.BackgroundColor3 = Window.CurrentTheme.MainBG
    MainFrame.BackgroundTransparency = Window.CurrentTheme.MainTrans
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.ZIndex = 1
    MainFrame.Parent = MainContainer

    AddUIShadow(MainFrame, 20, 0.5)

    -- Init Spiderweb Background at ZIndex 2 (Above LeftFrame & MainFrame panel backgrounds, below UI contents)
    InitSpiderwebBackground(MainContainer, ScriptUi)

    -- Content Overlay Layer (ZIndex 3 for all UI controls, cards, tab buttons, dividers, and text)
    local ContentOverlay = Instance.new("Frame")
    ContentOverlay.Name = "ContentOverlay"
    ContentOverlay.Size = UDim2.new(1, 0, 1, -94)
    ContentOverlay.Position = UDim2.new(0, 0, 0, 42)
    ContentOverlay.BackgroundTransparency = 1
    ContentOverlay.BorderSizePixel = 0
    ContentOverlay.ClipsDescendants = true
    ContentOverlay.ZIndex = 3
    ContentOverlay.Parent = MainContainer

    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Name = "ScrollingFrame"
    SidebarScroll.Size = UDim2.new(0, 175, 1, 0)
    SidebarScroll.Position = UDim2.new(0, 0, 0, 0)
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.BorderSizePixel = 0
    SidebarScroll.ScrollBarThickness = 0
    SidebarScroll.ScrollBarImageTransparency = 1
    SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidebarScroll.ClipsDescendants = true
    SidebarScroll.ZIndex = 3
    SidebarScroll.Parent = ContentOverlay

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Name = "UIListLayout"
    SidebarLayout.FillDirection = Enum.FillDirection.Vertical
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    SidebarLayout.Padding = UDim.new(0, 3)
    SidebarLayout.Parent = SidebarScroll

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20)
    end)

    MainContentFrame = Instance.new("Frame")
    MainContentFrame.Name = "MainContentFrame"
    MainContentFrame.Size = UDim2.new(1, -175, 1, 0)
    MainContentFrame.Position = UDim2.new(0, 175, 0, 0)
    MainContentFrame.BackgroundTransparency = 1
    MainContentFrame.BorderSizePixel = 0
    MainContentFrame.ClipsDescendants = true
    MainContentFrame.ZIndex = 3
    MainContentFrame.Parent = ContentOverlay

    -- Bottom Frame
    local BottomFrame = Instance.new("Frame")
    BottomFrame.Name = "BottomFrame"
    BottomFrame.Size = UDim2.new(1, 0, 0, 52)
    BottomFrame.Position = UDim2.new(0, 0, 1, -52)
    BottomFrame.BackgroundColor3 = Window.CurrentTheme.BottomBG
    BottomFrame.BackgroundTransparency = Window.CurrentTheme.BottomTrans
    BottomFrame.BorderSizePixel = 0
    BottomFrame.ZIndex = 5
    BottomFrame.Parent = MainContainer

    local BottomCorner = Instance.new("UICorner")
    ApplyCornerRadii(BottomCorner, 0, 0, 8, 8)
    BottomCorner.Parent = BottomFrame

    local BottomGradient = Instance.new("UIGradient")
    BottomGradient.Name = "UIGradient"
    BottomGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Window.CurrentTheme.BottomGradient[1]),
        ColorSequenceKeypoint.new(0.496, Window.CurrentTheme.BottomGradient[2]),
        ColorSequenceKeypoint.new(1, Window.CurrentTheme.BottomGradient[3])
    })
    BottomGradient.Parent = BottomFrame

    local MDicon = Instance.new("ImageLabel")
    MDicon.Name = "Icon"
    MDicon.Size = UDim2.new(0, 35, 0, 35)
    MDicon.Position = UDim2.new(0.0142, 0, 0.16, 0)
    MDicon.BackgroundTransparency = 0
    MDicon.Image = "rbxassetid://77044087750639"
    MDicon.ZIndex = 6
    MDicon.Parent = BottomFrame

    local MDiconCorner = Instance.new("UICorner")
    MDiconCorner.CornerRadius = UDim.new(0, 10)
    MDiconCorner.Parent = MDicon

    AddUIShadow(MDicon, 20, 0.5)

    local MadebyText = Instance.new("TextLabel")
    MadebyText.Size = UDim2.new(0, 180, 0, 24)
    MadebyText.Position = UDim2.new(0.0803, 0, 0.05, 0)
    MadebyText.BackgroundTransparency = 1
    MadebyText.FontFace = FontMichromaHeavy
    MadebyText.Text = "Made by MorningDrift"
    MadebyText.TextColor3 = Window.CurrentTheme.Text
    MadebyText.TextSize = 16
    MadebyText.TextXAlignment = Enum.TextXAlignment.Left
    MadebyText.ZIndex = 6
    MadebyText.Parent = BottomFrame

    -- DISCORD SERVER LINK UNDER MADE BY MORNINGDRIFT
    local DiscordBtn = Instance.new("TextButton")
    DiscordBtn.Name = "DiscordServerLink"
    DiscordBtn.Size = UDim2.new(0, 210, 0, 20)
    DiscordBtn.Position = UDim2.new(0.0803, 0, 0.52, 0)
    DiscordBtn.BackgroundTransparency = 1
    DiscordBtn.FontFace = FontMichromaRegular
    DiscordBtn.Text = "discord.gg/48jdqB8rAw"
    DiscordBtn.TextColor3 = Window.CurrentTheme.SubText
    DiscordBtn.TextSize = 11
    DiscordBtn.TextXAlignment = Enum.TextXAlignment.Left
    DiscordBtn.ZIndex = 7
    DiscordBtn.Parent = BottomFrame

    TrackConn(DiscordBtn.MouseEnter:Connect(function()
        PlayHoverSFX()
        TweenService:Create(DiscordBtn, TweenInfo.new(0.15), {TextColor3 = Window.CurrentTheme.Text}):Play()
    end))

    TrackConn(DiscordBtn.MouseLeave:Connect(function()
        TweenService:Create(DiscordBtn, TweenInfo.new(0.15), {TextColor3 = Window.CurrentTheme.SubText}):Play()
    end))

    TrackConn(DiscordBtn.MouseButton1Click:Connect(function()
        PlayClickSFX()
        pcall(function()
            if setclipboard then
                setclipboard("https://discord.gg/48jdqB8rAw")
            end
        end)
        Window:Notify("Discord server", "Copied invite link to clipboard:\nhttps://discord.gg/48jdqB8rAw", 3)
    end))

    local LocalTime = Instance.new("TextLabel")
    LocalTime.Size = UDim2.new(0, 210, 1, 0)
    LocalTime.Position = UDim2.new(0.58, 0, 0, 0)
    LocalTime.BackgroundTransparency = 1
    LocalTime.FontFace = FontMichromaRegular
    LocalTime.Text = "Local time: 5:33 AM"
    LocalTime.TextColor3 = Window.CurrentTheme.Text
    LocalTime.TextSize = 12
    LocalTime.TextXAlignment = Enum.TextXAlignment.Left
    LocalTime.TextYAlignment = Enum.TextYAlignment.Center
    LocalTime.ZIndex = 6
    LocalTime.Parent = BottomFrame

    local ResizeBtnFrame = Instance.new("Frame")
    ResizeBtnFrame.Size = UDim2.new(0, 35, 0, 35)
    ResizeBtnFrame.Position = UDim2.new(0.935, 0, 0.142, 0)
    ResizeBtnFrame.BackgroundTransparency = 1
    ResizeBtnFrame.ZIndex = 6
    ResizeBtnFrame.Parent = BottomFrame

    local ResizeBtn = Instance.new("ImageButton")
    ResizeBtn.Size = UDim2.new(1, 0, 1, 0)
    ResizeBtn.Position = UDim2.new(0, 0, 0.025, 0)
    ResizeBtn.BackgroundTransparency = 1
    ResizeBtn.ZIndex = 6
    ResizeBtn.Parent = ResizeBtnFrame

    local ResizeIcon = Instance.new("ImageLabel")
    ResizeIcon.Size = UDim2.new(0, 28, 0, 28)
    ResizeIcon.Position = UDim2.new(0.085, 0, 0.085, 0)
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Image = "rbxassetid://104249430704982"
    ResizeIcon.ZIndex = 7
    ResizeIcon.Parent = ResizeBtn

    AttachUniversalDrag(TopFrame, MainContainer)
    AttachUniversalDrag(LeftFrame, MainContainer)
    AttachUniversalDrag(MainFrame, MainContainer)
    AttachUniversalDrag(BottomFrame, MainContainer)

    -- FILLFRAME (Top Spacer, LayoutOrder 0)
    local FillFrame = Instance.new("Frame")
    FillFrame.Name = "FILLFRAME"
    FillFrame.Size = UDim2.new(0, 140, 0, 8)
    FillFrame.Position = UDim2.new(0.2628, 0, 0, 0)
    FillFrame.BackgroundTransparency = 1
    FillFrame.BorderSizePixel = 0
    FillFrame.LayoutOrder = 0
    FillFrame.ZIndex = 2
    FillFrame.Parent = SidebarScroll

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 8)
    FillCorner.Parent = FillFrame

    -- Minimized Icon Elements (100% Draggable, DisplayOrder 25)
    local MinimizedFrame = Instance.new("Frame")
    MinimizedFrame.Size = UDim2.new(0, 52, 0, 52)
    MinimizedFrame.AnchorPoint = Vector2.new(0.5, 0)
    MinimizedFrame.Position = UDim2.new(0.5, 0, 0, 15)
    MinimizedFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizedFrame.ZIndex = 100
    MinimizedFrame.Parent = MinimisedUI

    local MinimizedFrameCorner = Instance.new("UICorner")
    MinimizedFrameCorner.CornerRadius = UDim.new(1, 0)
    MinimizedFrameCorner.Parent = MinimizedFrame

    local MinimizedImage = Instance.new("ImageButton")
    MinimizedImage.Size = UDim2.new(1, 0, 1, 0)
    MinimizedImage.BackgroundTransparency = 0
    MinimizedImage.Image = "rbxassetid://77044087750639"
    MinimizedImage.ZIndex = 101
    MinimizedImage.Parent = MinimizedFrame

    local MinimizedImageCorner = Instance.new("UICorner")
    MinimizedImageCorner.CornerRadius = UDim.new(1, 0)
    MinimizedImageCorner.Parent = MinimizedImage

    local MinimizedStroke = Instance.new("UIStroke")
    MinimizedStroke.Color = Color3.fromRGB(255, 255, 255)
    MinimizedStroke.Thickness = 3
    MinimizedStroke.Parent = MinimizedImage

    local MinimizedGradient = Instance.new("UIGradient")
    MinimizedGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Window.CurrentTheme.MinGradient[1]),
        ColorSequenceKeypoint.new(0.5, Window.CurrentTheme.MinGradient[2]),
        ColorSequenceKeypoint.new(1, Window.CurrentTheme.MinGradient[3])
    })
    MinimizedGradient.Parent = MinimizedStroke

    TrackConn(RunService.RenderStepped:Connect(function(dt)
        if MinimisedUI.Enabled and MinimizedGradient and MinimizedGradient.Parent then
            MinimizedGradient.Rotation = (MinimizedGradient.Rotation + (dt * 120)) % 360
        end
    end))

    AttachUniversalDrag(MinimizedFrame, MinimizedFrame)
    AttachUniversalDrag(MinimizedImage, MinimizedFrame)

    -- Notification Engine (Placed at Y = 1, -105)
    function Window:Notify(titleText, contentText, duration)
        if not Window.NotificationsEnabled then return end
        duration = duration or 3.5

        local NotifContainer = Instance.new("Frame")
        NotifContainer.Name = "NotifContainer"
        NotifContainer.Size = UDim2.new(0, 290, 0, 105)
        NotifContainer.Position = UDim2.new(1, 350, 1, -105)
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.ZIndex = 30
        NotifContainer.Parent = NotificationUI

        local NotifTop = Instance.new("Frame")
        NotifTop.Name = "TopFrame"
        NotifTop.Size = UDim2.new(1, 0, 0, 28)
        NotifTop.Position = UDim2.new(0, 0, 0, 0)
        NotifTop.BackgroundColor3 = Window.CurrentTheme.TopBG
        NotifTop.BackgroundTransparency = Window.CurrentTheme.TopTrans
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
        NotifTitle.Size = UDim2.new(0, 153, 0, 45)
        NotifTitle.Position = UDim2.new(0.019, 0, -0.31, 0)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.FontFace = FontMichromaRegular
        NotifTitle.Text = titleText or "MD Notification"
        NotifTitle.TextColor3 = Window.CurrentTheme.Text
        NotifTitle.TextSize = 15
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.ZIndex = 32
        NotifTitle.Parent = NotifTextFolder

        local NotifMain = Instance.new("Frame")
        NotifMain.Name = "MainFrame"
        NotifMain.Size = UDim2.new(1, 0, 0, 77)
        NotifMain.Position = UDim2.new(0, 0, 0, 28)
        NotifMain.BackgroundColor3 = Window.CurrentTheme.MainBG
        NotifMain.BackgroundTransparency = Window.CurrentTheme.MainTrans
        NotifMain.BorderSizePixel = 0
        NotifMain.ZIndex = 31
        NotifMain.Parent = NotifContainer

        AddUIShadow(NotifMain, 20, 0.5)

        local NotifIcon = Instance.new("ImageLabel")
        NotifIcon.Name = "Icon"
        NotifIcon.Size = UDim2.new(0, 52, 0, 52)
        NotifIcon.Position = UDim2.new(0.0217, 0, 0.1317, 0)
        NotifIcon.BackgroundTransparency = 0
        NotifIcon.Image = "rbxassetid://77044087750639"
        NotifIcon.ZIndex = 32
        NotifIcon.Parent = NotifMain

        local NotifIconCorner = Instance.new("UICorner")
        NotifIconCorner.CornerRadius = UDim.new(0, 10)
        NotifIconCorner.Parent = NotifIcon

        AddUIShadow(NotifIcon, 20, 0.5)

        local NotifBody = Instance.new("TextLabel")
        NotifBody.Name = "NOTIFICATIONTXT"
        NotifBody.Size = UDim2.new(0, 210, 0, 54)
        NotifBody.Position = UDim2.new(0.2413, 0, 0.1317, 0)
        NotifBody.BackgroundTransparency = 1
        NotifBody.FontFace = FontMichromaBold
        NotifBody.Text = contentText or ""
        NotifBody.TextColor3 = Window.CurrentTheme.Text
        NotifBody.TextSize = 17
        NotifBody.TextWrapped = true
        NotifBody.TextXAlignment = Enum.TextXAlignment.Left
        NotifBody.ZIndex = 32
        NotifBody.Parent = NotifMain

        table.insert(Window.ActiveNotifications, 1, NotifContainer)
        for index, notif in ipairs(Window.ActiveNotifications) do
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

            for idx, item in ipairs(Window.ActiveNotifications) do
                if item == NotifContainer then
                    table.remove(Window.ActiveNotifications, idx)
                    break
                end
            end
            NotifContainer:Destroy()

            for index, notif in ipairs(Window.ActiveNotifications) do
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

    local CurrentTabSwitchToken = 0

    -- Smooth Tab Switch Transition Engine
    SwitchTab = function(tabName)
        if Window.ActiveTab == tabName then return end

        local oldTab = Window.Tabs[Window.ActiveTab]
        local newTab = Window.Tabs[tabName]
        Window.ActiveTab = tabName

        -- 1. Animate Sidebar Tab Buttons
        if oldTab and oldTab.Button then
            TweenService:Create(oldTab.Button, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextSize = 15,
                TextColor3 = Window.CurrentTheme.SubText
            }):Play()
            oldTab.Button.FontFace = FontMichromaRegular
            if oldTab.HoverGlow then
                TweenService:Create(oldTab.HoverGlow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()
            end
        end

        if newTab and newTab.Button then
            TweenService:Create(newTab.Button, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextSize = 18,
                TextColor3 = Window.CurrentTheme.Text
            }):Play()
            newTab.Button.FontFace = FontMichromaBold
            if newTab.HoverGlow then
                TweenService:Create(newTab.HoverGlow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.85
                }):Play()
            end
        end

        -- 2. Hide all other tab frames cleanly with zero overlap
        for name, tabObj in pairs(Window.Tabs) do
            if name ~= tabName and tabObj and tabObj.ContentFrame then
                tabObj.ContentFrame.Visible = false
                tabObj.ContentFrame.Position = UDim2.new(0, 0, 0, 0)
            end
        end

        -- 3. Smooth entrance of active tab content
        if newTab and newTab.ContentFrame then
            newTab.ContentFrame.Position = UDim2.new(0, 0, 0, 10)
            newTab.ContentFrame.Visible = true
            TweenService:Create(newTab.ContentFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
        end
    end

    function Window:AddSidebarBigDivider(layoutOrder)
        local DivideFrame = Instance.new("Frame")
        DivideFrame.Name = "DIVIDEFRAME"
        DivideFrame.Size = UDim2.new(0, 140, 0, 5)
        DivideFrame.BackgroundColor3 = Window.CurrentTheme.Divider
        DivideFrame.BorderSizePixel = 0
        DivideFrame.LayoutOrder = layoutOrder or 2
        DivideFrame.Parent = SidebarScroll

        local DivideCorner = Instance.new("UICorner")
        DivideCorner.CornerRadius = UDim.new(0, 8)
        DivideCorner.Parent = DivideFrame

        AddUIShadow(DivideFrame, 8, 0.5)
        table.insert(Window.SidebarDividers, DivideFrame)
        return DivideFrame
    end

    function Window:AddSidebarSmallDivider(layoutOrder)
        local DivideFrameSmall = Instance.new("Frame")
        DivideFrameSmall.Name = "DIVIDEFRAMESMALL"
        DivideFrameSmall.Size = UDim2.new(0, 115, 0, 3)
        DivideFrameSmall.BackgroundColor3 = Window.CurrentTheme.Divider
        DivideFrameSmall.BorderSizePixel = 0
        DivideFrameSmall.LayoutOrder = layoutOrder or 4
        DivideFrameSmall.Parent = SidebarScroll

        local DivideSmallCorner = Instance.new("UICorner")
        DivideSmallCorner.CornerRadius = UDim.new(0, 8)
        DivideSmallCorner.Parent = DivideFrameSmall

        AddUIShadow(DivideFrameSmall, 8, 0.5)
        table.insert(Window.SidebarDividers, DivideFrameSmall)
        return DivideFrameSmall
    end

    function Window:CreateTab(tabName, layoutOrder)
        local TabContainer = Instance.new("Frame")
        TabContainer.Name = tabName
        TabContainer.Size = UDim2.new(0, 165, 0, 34)
        TabContainer.BackgroundTransparency = 1
        TabContainer.LayoutOrder = layoutOrder or 1
        TabContainer.Parent = SidebarScroll

        local HoverGlow = Instance.new("Frame")
        HoverGlow.Name = "HoverGlow"
        HoverGlow.Size = UDim2.new(1, -10, 1, -4)
        HoverGlow.Position = UDim2.new(0, 5, 0, 2)
        HoverGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HoverGlow.BackgroundTransparency = 1
        HoverGlow.BorderSizePixel = 0
        HoverGlow.ZIndex = 1
        HoverGlow.Parent = TabContainer

        local HoverCorner = Instance.new("UICorner")
        HoverCorner.CornerRadius = UDim.new(0, 6)
        HoverCorner.Parent = HoverGlow

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TextButton"
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Position = UDim2.new(0, 0, 0, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.FontFace = FontMichromaRegular
        TabButton.Text = tabName
        TabButton.TextColor3 = Window.CurrentTheme.SubText
        TabButton.TextSize = 15
        TabButton.TextXAlignment = Enum.TextXAlignment.Center
        TabButton.TextYAlignment = Enum.TextYAlignment.Center
        TabButton.ZIndex = 2
        TabButton.Parent = TabContainer

        local ContentFrame = Instance.new("ScrollingFrame")
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.Position = UDim2.new(0, 0, 0, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderSizePixel = 0
        ContentFrame.ScrollBarThickness = 0
        ContentFrame.ScrollBarImageTransparency = 1
        ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        ContentFrame.ClipsDescendants = true
        ContentFrame.Visible = false
        ContentFrame.ZIndex = 3
        ContentFrame.Parent = MainContentFrame or MainFrame

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.PaddingTop = UDim.new(0, 8)
        ContentPadding.PaddingBottom = UDim.new(0, 14)
        ContentPadding.Parent = ContentFrame

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = ContentFrame

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 40)
        end)

        local TabObj = {
            Name = tabName,
            Button = TabButton,
            HoverGlow = HoverGlow,
            ContentFrame = ContentFrame,
            Layout = ContentLayout
        }

        function TabObj:AddWelcomeHeader()
            local MainHeaderFrame = Instance.new("Frame")
            MainHeaderFrame.Name = "MainHeaderFrame"
            MainHeaderFrame.Size = UDim2.new(1, -10, 0, 90)
            MainHeaderFrame.BackgroundTransparency = 1
            MainHeaderFrame.BorderSizePixel = 0
            MainHeaderFrame.ZIndex = 3
            MainHeaderFrame.Parent = ContentFrame

            local UserAvatar = Instance.new("ImageLabel")
            UserAvatar.Name = "USERCHARACTERIMAGE"
            UserAvatar.Size = UDim2.new(0, 68, 0, 68)
            UserAvatar.Position = UDim2.new(0.0217, 0, 0.0286, 0)
            UserAvatar.BackgroundTransparency = 1
            UserAvatar.BorderSizePixel = 0
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            if LocalPlayer then
                UserAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
            end
            UserAvatar.ZIndex = 4
            UserAvatar.Parent = MainHeaderFrame

            local AvatarCorner = Instance.new("UICorner")
            AvatarCorner.CornerRadius = UDim.new(0, 11)
            AvatarCorner.Parent = UserAvatar
            AddUIShadow(UserAvatar, 20, 0.5)

            local function GetGreeting()
                local hour = tonumber(os.date("%H"))
                if hour >= 5 and hour < 12 then
                    return "Good morning"
                elseif hour >= 12 and hour < 17 then
                    return "Good afternoon"
                elseif hour >= 17 and hour < 21 then
                    return "Good evening"
                else
                    return "Night"
                end
            end

            local pName = (LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name)) or "User"
            local WelcomeMsg = Instance.new("TextLabel")
            WelcomeMsg.Name = "Welcomemsg"
            WelcomeMsg.Size = UDim2.new(0, 360, 0, 45)
            WelcomeMsg.Position = UDim2.new(0.2, 0, 0.11198, 0)
            WelcomeMsg.BackgroundTransparency = 1
            WelcomeMsg.BorderSizePixel = 0
            WelcomeMsg.FontFace = FontMichromaBold
            WelcomeMsg.Text = GetGreeting() .. ", " .. pName
            WelcomeMsg.TextColor3 = Window.CurrentTheme.Text
            WelcomeMsg.TextSize = 28
            WelcomeMsg.TextWrapped = true
            WelcomeMsg.TextXAlignment = Enum.TextXAlignment.Left
            WelcomeMsg.TextYAlignment = Enum.TextYAlignment.Center
            WelcomeMsg.ZIndex = 4
            WelcomeMsg.Parent = MainHeaderFrame

            Window.WelcomeMsg = WelcomeMsg
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return MainHeaderFrame
        end

        function TabObj:AddButton(title, desc, callback)
            local CardFrame = Instance.new("Frame")
            CardFrame.Size = UDim2.new(1, -10, 0, 60)
            CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
            CardFrame.BorderSizePixel = 0
            CardFrame.Parent = ContentFrame

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            local hasDesc = desc and desc ~= ""

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FontMichromaBold
            TitleLabel.Text = title
            TitleLabel.TextColor3 = Window.CurrentTheme.Text
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = CardFrame

            if hasDesc then
                TitleLabel.Size = UDim2.new(1, -125, 0, 22)
                TitleLabel.Position = UDim2.new(0, 12, 0, 7)
                TitleLabel.TextSize = 12
                TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            else
                TitleLabel.Size = UDim2.new(1, -125, 1, 0)
                TitleLabel.Position = UDim2.new(0, 12, 0, 0)
                TitleLabel.TextSize = 14
                TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            end

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Size = UDim2.new(1, -125, 0, 22)
            DescLabel.Position = UDim2.new(0, 12, 0, 29)
            DescLabel.BackgroundTransparency = 1
            DescLabel.FontFace = FontMichromaRegular
            DescLabel.Text = hasDesc and desc or ""
            DescLabel.TextColor3 = Window.CurrentTheme.SubText
            DescLabel.TextSize = 10
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Visible = hasDesc
            DescLabel.Parent = CardFrame

            Window:CreateMDButton(CardFrame, UDim2.new(0, 110, 0, 30), UDim2.new(1, -120, 0.5, -15), "Execute", function()
                Window:Notify("Executing", "Running " .. title .. "...", 2.5)
                task.spawn(function()
                    if type(callback) == "function" then
                        pcall(callback)
                    elseif type(callback) == "string" then
                        pcall(function() loadstring(callback)() end)
                    end
                end)
            end, true)

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Button",
                Name = title or "Button",
                Desc = desc or "",
                TabName = tabName,
                Instance = CardFrame,
                Callback = callback
            })
        end

        function TabObj:AddRow(height, padding)
            height = height or 44
            padding = padding or 8

            local RowFrame = Instance.new("Frame")
            RowFrame.Name = "RowFrame"
            RowFrame.Size = UDim2.new(1, -10, 0, height)
            RowFrame.BackgroundTransparency = 1
            RowFrame.BorderSizePixel = 0
            RowFrame.ZIndex = 3
            RowFrame.ClipsDescendants = false
            RowFrame.Parent = ContentFrame

            local RowLayout = Instance.new("UIListLayout")
            RowLayout.Name = "RowLayout"
            RowLayout.FillDirection = Enum.FillDirection.Horizontal
            RowLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RowLayout.Padding = UDim.new(0, padding)
            RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            RowLayout.Parent = RowFrame

            function RowFrame:AddButton(text, callback, sizeFraction)
                return TabObj:AddLongButton(text, callback, sizeFraction or 0.5, RowFrame)
            end
            function RowFrame:AddLongButton(text, callback, sizeFraction)
                return TabObj:AddLongButton(text, callback, sizeFraction or 0.5, RowFrame)
            end
            function RowFrame:AddToggle(titleOrConfig, initialState, onToggle, sizeFraction)
                return TabObj:AddToggle(titleOrConfig, initialState, onToggle, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowFrame:AddDropdown(title, options, defaultOption, onSelect, sizeFraction)
                return TabObj:AddDropdown(title, options, defaultOption, onSelect, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowFrame:AddTextbox(title, placeholder, defaultText, onSubmit, sizeFraction)
                return TabObj:AddTextbox(title, placeholder, defaultText, onSubmit, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowFrame:AddColorPicker(title, defaultColor, callback, sizeFraction)
                return TabObj:AddColorPicker(title, defaultColor, callback, RowFrame, nil, sizeFraction or 0.5)
            end

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return RowFrame
        end

        function TabObj:AddLongButton(arg1, arg2, arg3, arg4, arg5)
            local text, callback, sizeInput, parentRow, position
            if type(arg1) == "table" and not arg1.IsA then
                text = arg1.Text or arg1.Title or arg1.Name or arg1[1] or "Button"
                callback = arg1.Callback or arg1.OnClick or arg1.callback or arg1[2]
                sizeInput = arg1.Size or arg1.Fraction or arg1.size or arg1[3]
                parentRow = arg1.Parent or arg1.Row or arg1.parentRow
                position = arg1.Position or arg1.pos
            else
                text = arg1 or "Button"
                callback = arg2
                if typeof(arg3) == "Instance" then
                    parentRow = arg3
                    position = arg4
                else
                    sizeInput = arg3
                    parentRow = arg4
                    position = arg5
                end
            end

            local fraction, explicitUDim = ResolveSizeFraction(sizeInput, parentRow and 0.5 or 1.0)
            local targetParent = parentRow
            local finalSize

            if explicitUDim then
                finalSize = explicitUDim
                targetParent = targetParent or ContentFrame
            elseif targetParent then
                finalSize = ComputeRowItemWidth(fraction or 0.5, 44)
            else
                -- Auto-Flow Left-to-Right Sorting Engine
                if fraction and fraction < 0.98 then
                    local needsNewRow = false
                    if not TabObj.CurrentAutoRow or not TabObj.CurrentAutoRow.Parent or TabObj.CurrentAutoRow.Parent ~= ContentFrame then
                        needsNewRow = true
                    elseif (TabObj.CurrentAutoRowRemaining or 0) < (fraction - 0.02) then
                        needsNewRow = true
                    end

                    if needsNewRow then
                        TabObj.CurrentAutoRow = TabObj:AddRow(44, 8)
                        TabObj.CurrentAutoRowRemaining = 1.0
                    end

                    targetParent = TabObj.CurrentAutoRow
                    finalSize = ComputeRowItemWidth(fraction, 44)
                    TabObj.CurrentAutoRowRemaining = (TabObj.CurrentAutoRowRemaining or 1.0) - fraction
                    if TabObj.CurrentAutoRowRemaining <= 0.05 then
                        TabObj.CurrentAutoRow = nil
                    end
                else
                    TabObj.CurrentAutoRow = nil
                    TabObj.CurrentAutoRowRemaining = 0
                    targetParent = ContentFrame
                    finalSize = UDim2.new(1, -10, 0, 44)
                end
            end

            local pos = position or UDim2.new(0, 0, 0, 0)
            local btnData = Window:CreateMDButtonLong(targetParent, pos, finalSize, text, callback)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Button",
                Name = text or "Button",
                Desc = "",
                TabName = tabName,
                Instance = btnData.Frame,
                Callback = callback
            })

            return btnData
        end

        function TabObj:AddButtonRow(buttonList, height)
            height = height or 44
            if type(buttonList) ~= "table" then return end

            local row = TabObj:AddRow(height, 8)
            local count = #buttonList
            local defaultFraction = count > 0 and (1 / count) or 0.5

            local results = {}
            for i, item in ipairs(buttonList) do
                local text, callback, sizeInput
                if type(item) == "table" and not item.IsA then
                    text = item.Text or item.Title or item.Name or item[1] or "Button"
                    callback = item.Callback or item.OnClick or item.callback or item[2]
                    sizeInput = item.Size or item.Fraction or item[3] or defaultFraction
                else
                    text = tostring(item)
                    sizeInput = defaultFraction
                end

                local fraction, explicitUDim = ResolveSizeFraction(sizeInput, defaultFraction)
                local itemSize = explicitUDim or ComputeRowItemWidth(fraction, height)
                local btn = Window:CreateMDButtonLong(row, UDim2.new(0, 0, 0, 0), itemSize, text, callback)

                table.insert(Window.SearchableItems, {
                    Type = "Button",
                    Name = text,
                    Desc = "",
                    TabName = tabName,
                    Instance = btn.Frame,
                    Callback = callback
                })
                table.insert(results, btn)
            end

            return row, results
        end

        function TabObj:AddDropdown(title, options, defaultOption, onSelect, parentRow, position, sizeFraction)
            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local size = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 44) or UDim2.new(1, -10, 0, 44))
            local pos = position or UDim2.new(0, 0, 0, 0)
            local dropObj = Window:CreateMDDropdown(targetParent, pos, size, title, options, defaultOption, onSelect)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Dropdown",
                Name = title or "Dropdown",
                Desc = "",
                TabName = tabName,
                Instance = dropObj.Frame
            })

            return dropObj
        end

        function TabObj:AddTextbox(title, placeholder, defaultText, onSubmit, parentRow, position, sizeFraction)
            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local size = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 44) or UDim2.new(1, -10, 0, 44))
            local pos = position or UDim2.new(0, 0, 0, 0)
            local boxObj = Window:CreateMDTextbox(targetParent, pos, size, title, placeholder, defaultText, onSubmit)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Textbox",
                Name = title or "Textbox",
                Desc = placeholder or "",
                TabName = tabName,
                Instance = boxObj.Frame
            })

            return boxObj
        end

        function TabObj:AddColorPicker(title, defaultColor, callback, parentRow, position, sizeFraction)
            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local size = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 44) or UDim2.new(1, -10, 0, 44))
            local pos = position or UDim2.new(0, 0, 0, 0)
            local cpData = Window:CreateMDColorPicker(targetParent, pos, size, title, defaultColor, callback)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Color picker",
                Name = title or "Color",
                Desc = "",
                TabName = tabName,
                Instance = cpData.Frame
            })

            return cpData
        end

        function TabObj:CreateConfigSection()
            return Window:CreateConfigSection(TabObj)
        end

        function TabObj:AddToggle(titleOrConfig, initialState, onToggle, parentRow, position, sizeFraction, bindConfig)
            local targetParent = parentRow or ContentFrame
            local text = (type(titleOrConfig) == "table" and (titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1])) or tostring(titleOrConfig)
            local state = (type(titleOrConfig) == "table" and (titleOrConfig.Default or titleOrConfig.Value or titleOrConfig.State or titleOrConfig[2])) or initialState
            local cb = (type(titleOrConfig) == "table" and (titleOrConfig.Callback or titleOrConfig.OnChanged or titleOrConfig.callback or titleOrConfig[3])) or onToggle
            local bind = (type(titleOrConfig) == "table" and (titleOrConfig.Bind or titleOrConfig.Keybind or titleOrConfig.DefaultBind or titleOrConfig[4])) or bindConfig

            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local size = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 44) or UDim2.new(1, -10, 0, 44))
            local pos = position or UDim2.new(0, 0, 0, 0)

            local toggleData = Window:CreateMDToggleHalf(targetParent, pos, size, text, state, cb, bind)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Toggle",
                Name = text or "Toggle",
                Desc = "",
                TabName = tabName,
                Instance = toggleData.Frame
            })

            return toggleData
        end

        function TabObj:AddHalfToggle(text, initialState, onToggle, parentRow, position)
            return TabObj:AddToggle(text, initialState, onToggle, parentRow, position)
        end

        function TabObj:AddSlider(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
            local targetParent = ContentFrame
            local pos = UDim2.new(0, 0, 0, 0)
            local size = UDim2.new(1, -10, 0, 14)
            local sliderName = nil
            local minVal, maxVal, defaultVal, onValueChange

            if type(arg1) == "string" then
                sliderName = arg1
                if type(arg2) == "table" then
                    minVal = arg2.Min or arg2.min or 0
                    maxVal = arg2.Max or arg2.max or 100
                    defaultVal = arg2.Default or arg2.default or minVal
                    onValueChange = arg2.Callback or arg2.callback or arg2.OnChanged
                    targetParent = arg3 or targetParent
                    pos = arg4 or pos
                else
                    minVal = arg2 or 0
                    maxVal = arg3 or 100
                    defaultVal = arg4 or minVal
                    onValueChange = arg5
                    targetParent = arg6 or targetParent
                    pos = arg7 or pos
                end
            elseif type(arg1) == "table" then
                sliderName = arg1.Title or arg1.Name
                minVal = arg1.Min or arg1.min or 0
                maxVal = arg1.Max or arg1.max or 100
                defaultVal = arg1.Default or arg1.default or minVal
                onValueChange = arg1.Callback or arg1.callback or arg1.OnChanged
                targetParent = arg2 or targetParent
                pos = arg3 or pos
            else
                minVal = arg1 or 0
                maxVal = arg2 or 100
                defaultVal = arg3 or minVal
                onValueChange = arg4
                targetParent = arg5 or targetParent
                pos = arg6 or pos
            end

            if targetParent and targetParent.Name == "RowFrame" then
                size = UDim2.new(0.485, -4, 0, 14)
            end

            local sliderData = Window:CreateMDSlider(targetParent, pos, size, minVal, maxVal, defaultVal, onValueChange, sliderName)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Slider",
                Name = sliderName or "Slider",
                Desc = "",
                TabName = tabName,
                Instance = sliderData.Track
            })

            return sliderData
        end

        TrackConn(TabButton.MouseEnter:Connect(function()
            PlayHoverSFX()
            if Window.ActiveTab ~= tabName then
                TweenService:Create(HoverGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.90}):Play()
                TweenService:Create(TabButton, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextColor3 = Window.CurrentTheme.Text}):Play()
            end
        end))

        TrackConn(TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= tabName then
                TweenService:Create(HoverGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                TweenService:Create(TabButton, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextColor3 = Window.CurrentTheme.SubText}):Play()
            end
        end))

        TrackConn(TabButton.MouseButton1Click:Connect(function()
            PlayClickSFX()
            SwitchTab(tabName)
        end))

        Window.Tabs[tabName] = TabObj
        if not Window.ActiveTab or (Window.ActiveTab == "Settings" and tabName ~= "Settings") then
            if Window.ActiveTab and Window.ActiveTab ~= tabName then
                local oldTabData = Window.Tabs[Window.ActiveTab]
                if oldTabData then
                    oldTabData.Button.TextColor3 = Window.CurrentTheme.SubText
                    oldTabData.Button.TextSize = 15
                    oldTabData.Button.FontFace = FontMichromaRegular
                    if oldTabData.HoverGlow then
                        oldTabData.HoverGlow.BackgroundTransparency = 1
                    end
                    local oldTarget = oldTabData.TabGroup or oldTabData.ContentFrame
                    if oldTarget then
                        oldTarget.Visible = false
                    end
                end
            end
            Window.ActiveTab = tabName
            -- Show first active tab with a gentle fade-in from slightly below
            ContentFrame.Position = UDim2.new(0, 0, 0, 8)
            ContentFrame.Visible = true
            TweenService:Create(ContentFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            TabButton.TextColor3 = Window.CurrentTheme.Text
            TabButton.TextSize = 18
            TabButton.FontFace = FontMichromaBold
            HoverGlow.BackgroundTransparency = 0.85
        else
            ContentFrame.Visible = false
            ContentFrame.Position = UDim2.new(0, 0, 0, 0)
            TabButton.TextColor3 = Window.CurrentTheme.SubText
            TabButton.TextSize = 15
            TabButton.FontFace = FontMichromaRegular
            HoverGlow.BackgroundTransparency = 1
        end

        return TabObj
    end

    -- =========================================================================
    -- DEFAULT BUILT-IN SETTINGS TAB BUILDER
    -- =========================================================================
    local function CreateDefaultSettingsTab()
        Window:AddSidebarBigDivider(998)
        local SettingsTab = Window:CreateTab("Settings", 999)

        -- 1. Enable Notifications Card
        local NotifCard = Instance.new("Frame")
        NotifCard.Name = "NotifCard"
        NotifCard.Size = UDim2.new(1, -10, 0, 50)
        NotifCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        NotifCard.ZIndex = 3
        NotifCard.ClipsDescendants = false
        NotifCard.Parent = SettingsTab.ContentFrame

        local NotifCardCorner = Instance.new("UICorner")
        NotifCardCorner.CornerRadius = UDim.new(0, 8)
        NotifCardCorner.Parent = NotifCard
        AddUIShadow(NotifCard, 12, 0.45)

        local NotifLabel = Instance.new("TextLabel")
        NotifLabel.Name = "NotifLabel"
        NotifLabel.Size = UDim2.new(1, -90, 1, 0)
        NotifLabel.Position = UDim2.new(0, 12, 0, 0)
        NotifLabel.BackgroundTransparency = 1
        NotifLabel.FontFace = FontMichromaBold
        NotifLabel.Text = "Enable notifications"
        NotifLabel.TextColor3 = Window.CurrentTheme.Text
        NotifLabel.TextSize = 12
        NotifLabel.TextXAlignment = Enum.TextXAlignment.Left
        NotifLabel.ZIndex = 4
        NotifLabel.Parent = NotifCard

        Window:CreateMDToggle(NotifCard, UDim2.new(1, -72, 0.5, -13), UDim2.new(0, 56, 0, 26), Window.NotificationsEnabled, function(state)
            Window.NotificationsEnabled = state
            if state then
                Window:Notify("Settings", "Notifications enabled", 2)
            end
        end, "Notifications", true)

        -- 2. Enable UI Sounds Card
        local SoundCard = Instance.new("Frame")
        SoundCard.Name = "SoundCard"
        SoundCard.Size = UDim2.new(1, -10, 0, 50)
        SoundCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        SoundCard.ZIndex = 3
        SoundCard.ClipsDescendants = false
        SoundCard.Parent = SettingsTab.ContentFrame

        local SoundCardCorner = Instance.new("UICorner")
        SoundCardCorner.CornerRadius = UDim.new(0, 8)
        SoundCardCorner.Parent = SoundCard
        AddUIShadow(SoundCard, 12, 0.45)

        local SoundLabel = Instance.new("TextLabel")
        SoundLabel.Name = "SoundLabel"
        SoundLabel.Size = UDim2.new(1, -90, 1, 0)
        SoundLabel.Position = UDim2.new(0, 12, 0, 0)
        SoundLabel.BackgroundTransparency = 1
        SoundLabel.FontFace = FontMichromaBold
        SoundLabel.Text = "Enable UI sounds"
        SoundLabel.TextColor3 = Window.CurrentTheme.Text
        SoundLabel.TextSize = 12
        SoundLabel.TextXAlignment = Enum.TextXAlignment.Left
        SoundLabel.ZIndex = 4
        SoundLabel.Parent = SoundCard

        Window:CreateMDToggle(SoundCard, UDim2.new(1, -72, 0.5, -13), UDim2.new(0, 56, 0, 26), Window.UISoundsEnabled, function(state)
            Window:SetUISounds(state)
            if state then
                Window:Notify("Settings", "UI sounds enabled", 2)
            end
        end, "UISounds")

        -- 3. UI Sound Volume Card
        local VolumeCard = Instance.new("Frame")
        VolumeCard.Name = "VolumeCard"
        VolumeCard.Size = UDim2.new(1, -10, 0, 50)
        VolumeCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        VolumeCard.ZIndex = 3
        VolumeCard.ClipsDescendants = false
        VolumeCard.Parent = SettingsTab.ContentFrame

        local VolumeCardCorner = Instance.new("UICorner")
        VolumeCardCorner.CornerRadius = UDim.new(0, 8)
        VolumeCardCorner.Parent = VolumeCard
        AddUIShadow(VolumeCard, 12, 0.45)

        local VolumeLabel = Instance.new("TextLabel")
        VolumeLabel.Name = "VolumeLabel"
        VolumeLabel.Size = UDim2.new(1, -240, 1, 0)
        VolumeLabel.Position = UDim2.new(0, 12, 0, 0)
        VolumeLabel.BackgroundTransparency = 1
        VolumeLabel.FontFace = FontMichromaBold
        local currentVolPct = math.floor((Window.SoundVolume or 0.8) * 100)
        VolumeLabel.Text = string.format("UI sound volume : %d%%", currentVolPct)
        VolumeLabel.TextColor3 = Window.CurrentTheme.Text
        VolumeLabel.TextSize = 11
        VolumeLabel.TextXAlignment = Enum.TextXAlignment.Left
        VolumeLabel.ZIndex = 4
        VolumeLabel.Parent = VolumeCard

        Window:CreateMDSlider(VolumeCard, UDim2.new(1, -210, 0.5, -7), UDim2.new(0, 195, 0, 14), 0, 100, currentVolPct, function(val, pct)
            VolumeLabel.Text = string.format("UI sound volume : %d%%", val)
            Window:SetSoundVolume(pct)
        end, "SoundVolume")

        -- 4. Spiderweb Background Card
        local WebCard = Instance.new("Frame")
        WebCard.Name = "WebCard"
        WebCard.Size = UDim2.new(1, -10, 0, 50)
        WebCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        WebCard.ZIndex = 3
        WebCard.ClipsDescendants = false
        WebCard.Parent = SettingsTab.ContentFrame

        local WebCardCorner = Instance.new("UICorner")
        WebCardCorner.CornerRadius = UDim.new(0, 8)
        WebCardCorner.Parent = WebCard
        AddUIShadow(WebCard, 12, 0.45)

        local WebTitle = Instance.new("TextLabel")
        WebTitle.Name = "WebTitle"
        WebTitle.Size = UDim2.new(0, 220, 0, 24)
        WebTitle.Position = UDim2.new(0, 12, 0, 6)
        WebTitle.BackgroundTransparency = 1
        WebTitle.FontFace = FontMichromaBold
        WebTitle.Text = "Spiderweb background"
        WebTitle.TextColor3 = Window.CurrentTheme.Text
        WebTitle.TextSize = 14
        WebTitle.TextXAlignment = Enum.TextXAlignment.Left
        WebTitle.ZIndex = 4
        WebTitle.Parent = WebCard

        local WebDesc = Instance.new("TextLabel")
        WebDesc.Name = "WebDesc"
        WebDesc.Size = UDim2.new(0, 280, 0, 16)
        WebDesc.Position = UDim2.new(0, 12, 0, 28)
        WebDesc.BackgroundTransparency = 1
        WebDesc.FontFace = FontMichromaRegular
        WebDesc.Text = "Warping web bg"
        WebDesc.TextColor3 = Window.CurrentTheme.SubText
        WebDesc.TextSize = 11
        WebDesc.TextXAlignment = Enum.TextXAlignment.Left
        WebDesc.ZIndex = 4
        WebDesc.Parent = WebCard

        Window:CreateMDToggle(WebCard, UDim2.new(1, -72, 0.5, -13), UDim2.new(0, 56, 0, 26), Window.SpiderwebBGEnabled, function(state)
            Window:SetSpiderwebBackground(state)
            if state then
                Window:Notify("Settings", "Spiderweb background enabled", 2)
            else
                Window:Notify("Settings", "Spiderweb background disabled", 2)
            end
        end, "SpiderwebBG", "Y")

        -- 5. Background Blur Card
        local BlurCard = Instance.new("Frame")
        BlurCard.Name = "BlurCard"
        BlurCard.Size = UDim2.new(1, -10, 0, 50)
        BlurCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        BlurCard.ZIndex = 3
        BlurCard.ClipsDescendants = false
        BlurCard.Parent = SettingsTab.ContentFrame

        local BlurCardCorner = Instance.new("UICorner")
        BlurCardCorner.CornerRadius = UDim.new(0, 8)
        BlurCardCorner.Parent = BlurCard
        AddUIShadow(BlurCard, 12, 0.45)

        local BlurTitle = Instance.new("TextLabel")
        BlurTitle.Name = "BlurTitle"
        BlurTitle.Size = UDim2.new(0, 220, 0, 24)
        BlurTitle.Position = UDim2.new(0, 12, 0, 6)
        BlurTitle.BackgroundTransparency = 1
        BlurTitle.FontFace = FontMichromaBold
        BlurTitle.Text = "Background blur"
        BlurTitle.TextColor3 = Window.CurrentTheme.Text
        BlurTitle.TextSize = 14
        BlurTitle.TextXAlignment = Enum.TextXAlignment.Left
        BlurTitle.ZIndex = 4
        BlurTitle.Parent = BlurCard

        local BlurDesc = Instance.new("TextLabel")
        BlurDesc.Name = "BlurDesc"
        BlurDesc.Size = UDim2.new(0, 280, 0, 16)
        BlurDesc.Position = UDim2.new(0, 12, 0, 28)
        BlurDesc.BackgroundTransparency = 1
        BlurDesc.FontFace = FontMichromaRegular
        BlurDesc.Text = "Blurry bg for the ui"
        BlurDesc.TextColor3 = Window.CurrentTheme.SubText
        BlurDesc.TextSize = 11
        BlurDesc.TextXAlignment = Enum.TextXAlignment.Left
        BlurDesc.ZIndex = 4
        BlurDesc.Parent = BlurCard

        Window:CreateMDToggle(BlurCard, UDim2.new(1, -72, 0.5, -13), UDim2.new(0, 56, 0, 26), Window.BackgroundBlurEnabled, function(state)
            Window:SetBackgroundBlur(state)
            if state then
                Window:Notify("Settings", "Background blur enabled", 2)
            else
                Window:Notify("Settings", "Background blur disabled", 2)
            end
        end, "BackgroundBlur")

        -- 6. Background Transparency Card
        local TransCard = Instance.new("Frame")
        TransCard.Name = "TransCard"
        TransCard.Size = UDim2.new(1, -10, 0, 50)
        TransCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        TransCard.ZIndex = 3
        TransCard.ClipsDescendants = false
        TransCard.Parent = SettingsTab.ContentFrame

        local TransCardCorner = Instance.new("UICorner")
        TransCardCorner.CornerRadius = UDim.new(0, 8)
        TransCardCorner.Parent = TransCard
        AddUIShadow(TransCard, 12, 0.45)

        local TransLabel = Instance.new("TextLabel")
        TransLabel.Name = "TransLabel"
        TransLabel.Size = UDim2.new(1, -240, 1, 0)
        TransLabel.Position = UDim2.new(0, 12, 0, 0)
        TransLabel.BackgroundTransparency = 1
        TransLabel.FontFace = FontMichromaBold
        local currentTransPct = math.floor((Window.CustomBGTransparency or 0.10) * 100)
        TransLabel.Text = string.format("Background transparency : %d%%", currentTransPct)
        TransLabel.TextColor3 = Window.CurrentTheme.Text
        TransLabel.TextSize = 11
        TransLabel.TextXAlignment = Enum.TextXAlignment.Left
        TransLabel.ZIndex = 4
        TransLabel.Parent = TransCard

        Window:CreateMDSlider(TransCard, UDim2.new(1, -210, 0.5, -7), UDim2.new(0, 195, 0, 14), 0, 90, currentTransPct, function(val, pct)
            TransLabel.Text = string.format("Background transparency : %d%%", val)
            Window:SetBackgroundTransparency(val / 100)
        end, "BGTransparency")

        -- 7. Custom Theme Builder Card (1-Color)
        local CustomThemeCard = Instance.new("Frame")
        CustomThemeCard.Name = "CustomThemeCard"
        CustomThemeCard.Size = UDim2.new(1, -10, 0, 50)
        CustomThemeCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        CustomThemeCard.ZIndex = 3
        CustomThemeCard.ClipsDescendants = false
        CustomThemeCard.Parent = SettingsTab.ContentFrame

        local CustomThemeCorner = Instance.new("UICorner")
        CustomThemeCorner.CornerRadius = UDim.new(0, 8)
        CustomThemeCorner.Parent = CustomThemeCard
        AddUIShadow(CustomThemeCard, 12, 0.45)

        local CustomThemeTitle = Instance.new("TextLabel")
        CustomThemeTitle.Name = "CustomThemeTitle"
        CustomThemeTitle.Size = UDim2.new(0, 220, 0, 24)
        CustomThemeTitle.Position = UDim2.new(0, 12, 0, 6)
        CustomThemeTitle.BackgroundTransparency = 1
        CustomThemeTitle.FontFace = FontMichromaBold
        CustomThemeTitle.Text = "Custom theme"
        CustomThemeTitle.TextColor3 = Window.CurrentTheme.Text
        CustomThemeTitle.TextSize = 14
        CustomThemeTitle.TextXAlignment = Enum.TextXAlignment.Left
        CustomThemeTitle.ZIndex = 4
        CustomThemeTitle.Parent = CustomThemeCard

        local CustomThemeDesc = Instance.new("TextLabel")
        CustomThemeDesc.Name = "CustomThemeDesc"
        CustomThemeDesc.Size = UDim2.new(0, 280, 0, 16)
        CustomThemeDesc.Position = UDim2.new(0, 12, 0, 28)
        CustomThemeDesc.BackgroundTransparency = 1
        CustomThemeDesc.FontFace = FontMichromaRegular
        CustomThemeDesc.Text = "Ts changes whole ui color"
        CustomThemeDesc.TextColor3 = Window.CurrentTheme.SubText
        CustomThemeDesc.TextSize = 11
        CustomThemeDesc.TextXAlignment = Enum.TextXAlignment.Left
        CustomThemeDesc.ZIndex = 4
        CustomThemeDesc.Parent = CustomThemeCard

        local CustomSwatchBtn = Instance.new("TextButton")
        CustomSwatchBtn.Name = "CustomSwatchBtn"
        CustomSwatchBtn.Size = UDim2.new(0, 56, 0, 26)
        CustomSwatchBtn.Position = UDim2.new(1, -72, 0.5, -13)
        CustomSwatchBtn.BackgroundColor3 = Window.CustomThemeColor or Window.CurrentTheme.ButtonBG
        CustomSwatchBtn.BorderSizePixel = 0
        CustomSwatchBtn.Text = ""
        CustomSwatchBtn.ZIndex = 5
        CustomSwatchBtn.Parent = CustomThemeCard

        local CustomSwatchCorner = Instance.new("UICorner")
        CustomSwatchCorner.CornerRadius = UDim.new(0, 6)
        CustomSwatchCorner.Parent = CustomSwatchBtn

        local CustomSwatchStroke = Instance.new("UIStroke")
        CustomSwatchStroke.Thickness = 1.2
        CustomSwatchStroke.Color = Color3.fromRGB(255, 255, 255)
        CustomSwatchStroke.Transparency = 0.4
        CustomSwatchStroke.Parent = CustomSwatchBtn

        TrackConn(CustomSwatchBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            local initCol = Window.CustomThemeColor or Window.CurrentTheme.ButtonBG
            Window:OpenColorPicker("Base theme color", initCol, function(newCol)
                CustomSwatchBtn.BackgroundColor3 = newCol
                Window:ApplyCustomTheme(newCol)
            end)
        end))

        -- 8. Click Effects Toggle Card
        local ClickEffectsCard = Instance.new("Frame")
        ClickEffectsCard.Name = "ClickEffectsCard"
        ClickEffectsCard.Size = UDim2.new(1, -10, 0, 50)
        ClickEffectsCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        ClickEffectsCard.ZIndex = 3
        ClickEffectsCard.ClipsDescendants = false
        ClickEffectsCard.Parent = SettingsTab.ContentFrame

        local ClickEffectsCorner = Instance.new("UICorner")
        ClickEffectsCorner.CornerRadius = UDim.new(0, 8)
        ClickEffectsCorner.Parent = ClickEffectsCard
        AddUIShadow(ClickEffectsCard, 12, 0.45)

        local ClickEffectsTitle = Instance.new("TextLabel")
        ClickEffectsTitle.Name = "ClickEffectsTitle"
        ClickEffectsTitle.Size = UDim2.new(0, 220, 0, 24)
        ClickEffectsTitle.Position = UDim2.new(0, 12, 0, 6)
        ClickEffectsTitle.BackgroundTransparency = 1
        ClickEffectsTitle.FontFace = FontMichromaBold
        ClickEffectsTitle.Text = "Enable click effects"
        ClickEffectsTitle.TextColor3 = Window.CurrentTheme.Text
        ClickEffectsTitle.TextSize = 14
        ClickEffectsTitle.TextXAlignment = Enum.TextXAlignment.Left
        ClickEffectsTitle.ZIndex = 4
        ClickEffectsTitle.Parent = ClickEffectsCard

        local ClickEffectsDesc = Instance.new("TextLabel")
        ClickEffectsDesc.Name = "ClickEffectsDesc"
        ClickEffectsDesc.Size = UDim2.new(0, 280, 0, 16)
        ClickEffectsDesc.Position = UDim2.new(0, 12, 0, 28)
        ClickEffectsDesc.BackgroundTransparency = 1
        ClickEffectsDesc.FontFace = FontMichromaRegular
        ClickEffectsDesc.Text = "Particles on click"
        ClickEffectsDesc.TextColor3 = Window.CurrentTheme.SubText
        ClickEffectsDesc.TextSize = 11
        ClickEffectsDesc.TextXAlignment = Enum.TextXAlignment.Left
        ClickEffectsDesc.ZIndex = 4
        ClickEffectsDesc.Parent = ClickEffectsCard

        Window:CreateMDToggle(ClickEffectsCard, UDim2.new(1, -72, 0.5, -13), UDim2.new(0, 56, 0, 26), Window.ClickEffectsEnabled, function(state)
            Window.ClickEffectsEnabled = state
            if state then
                Window:Notify("Settings", "Click effects enabled", 2)
            else
                Window:Notify("Settings", "Click effects disabled", 2)
            end
        end, "ClickEffects")

        -- 9. Particle Customization Row (Dropdown + Custom Image Textbox)
        local ParticleRow = Instance.new("Frame")
        ParticleRow.Name = "ParticleRow"
        ParticleRow.Size = UDim2.new(1, -10, 0, 44)
        ParticleRow.BackgroundTransparency = 1
        ParticleRow.ZIndex = 3
        ParticleRow.Parent = SettingsTab.ContentFrame

        local particleOptions = {"Theme default", "Leaves", "Gems", "Sparkles", "Rings", "Dots", "Custom image"}
        Window:CreateMDDropdown(ParticleRow, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 0, 44), "Particle style", particleOptions, Window.ClickParticleType or "Theme default", function(selected)
            Window.ClickParticleType = selected
            Window:Notify("Settings", "Particle style: " .. selected:lower(), 2)
        end)

        Window:CreateMDTextbox(ParticleRow, UDim2.new(0.515, 4, 0, 0), UDim2.new(0.485, -4, 0, 44), "Custom image ID", "rbxassetid://...", Window.CustomParticleAsset or "", function(entered)
            Window.CustomParticleAsset = entered
            if entered ~= "" then
                Window:Notify("Settings", "Custom particle image updated", 2)
            end
        end)

        -- 10. Configurations Management Section
        SettingsTab:CreateConfigSection()

        -- 7. Theme Presets Card
        local ThemeCard = Instance.new("Frame")
        ThemeCard.Name = "ThemeCard"
        ThemeCard.Size = UDim2.new(1, -10, 0, 122)
        ThemeCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        ThemeCard.ZIndex = 3
        ThemeCard.ClipsDescendants = false
        ThemeCard.Parent = SettingsTab.ContentFrame

        local ThemeCardCorner = Instance.new("UICorner")
        ThemeCardCorner.CornerRadius = UDim.new(0, 8)
        ThemeCardCorner.Parent = ThemeCard
        AddUIShadow(ThemeCard, 12, 0.45)

        local ThemeTitle = Instance.new("TextLabel")
        ThemeTitle.Name = "ThemeTitle"
        ThemeTitle.Size = UDim2.new(1, -20, 0, 22)
        ThemeTitle.Position = UDim2.new(0, 12, 0, 6)
        ThemeTitle.BackgroundTransparency = 1
        ThemeTitle.FontFace = FontMichromaBold
        ThemeTitle.Text = "Theme presets"
        ThemeTitle.TextColor3 = Window.CurrentTheme.Text
        ThemeTitle.TextSize = 16
        ThemeTitle.TextXAlignment = Enum.TextXAlignment.Left
        ThemeTitle.ZIndex = 4
        ThemeTitle.Parent = ThemeCard

        local ThemeContainer = Instance.new("Frame")
        ThemeContainer.Name = "ThemeContainer"
        ThemeContainer.Size = UDim2.new(1, -24, 0, 80)
        ThemeContainer.Position = UDim2.new(0, 12, 0, 34)
        ThemeContainer.BackgroundTransparency = 1
        ThemeContainer.Parent = ThemeCard

        local ThemeGridLayout = Instance.new("UIGridLayout")
        ThemeGridLayout.CellSize = UDim2.new(0.31, 0, 0, 36)
        ThemeGridLayout.CellPadding = UDim2.new(0.03, 0, 0, 8)
        ThemeGridLayout.Parent = ThemeContainer

        local ThemePresetBtnMap = {}
        for themeKey, themeData in pairs(Library.ThemePresets) do
            local btnData = Window:CreateMDButtonLong(ThemeContainer, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0), themeData.Name, function()
                Window:ApplyTheme(themeKey)
            end)
            ThemePresetBtnMap[themeKey] = btnData
        end
        Window.ThemePresetBtnMap = ThemePresetBtnMap
        if ThemePresetBtnMap[Window.CurrentThemeKey or "Dark"] and ThemePresetBtnMap[Window.CurrentThemeKey or "Dark"].Stroke then
            ThemePresetBtnMap[Window.CurrentThemeKey or "Dark"].Stroke.Thickness = 2.2
        end

        SettingsTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, SettingsTab.Layout.AbsoluteContentSize.Y + 20)
        Window.SettingsTab = SettingsTab
        return SettingsTab
    end

    CreateDefaultSettingsTab()

    -- Resizing Engine
    local IsResizing, ResizeStartPos, StartWindowSize = false, nil, nil
    TrackConn(ResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsResizing = true
            ResizeStartPos = input.Position
            StartWindowSize = MainContainer.Size
        end
    end))

    TrackConn(UserInputService.InputChanged:Connect(function(input)
        if IsResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - ResizeStartPos
            local newWidth = math.clamp(StartWindowSize.X.Offset + delta.X, 500, 1000)
            local newHeight = math.clamp(StartWindowSize.Y.Offset + delta.Y, 340, 700)
            MainContainer.Size = UDim2.new(0, newWidth, 0, newHeight)
            LastWindowSize = MainContainer.Size
        end
    end))

    TrackConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsResizing = false
        end
    end))

    -- MINIMIZE / RESTORE ENGINE
    local IsAnimatingMinimize = false
    local function MinimizeWindowAnimation()
        if IsAnimatingMinimize then return end
        IsAnimatingMinimize = true
        PlayClickSFX()

        LocalUIBlurPart.Transparency = 1
        BackgroundDOF.Enabled = false

        LastWindowPos = MainContainer.Position
        local targetPos = MinimizedFrame.Position

        MinimisedUI.Enabled = true
        MinimizedImage.Rotation = 0
        local spinTween = TweenService:Create(MinimizedImage, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Rotation = 360
        })
        spinTween:Play()

        task.delay(0.18, function()
            if IsAnimatingMinimize then
                ScriptUi.Enabled = false
            end
        end)

        local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local moveTween = TweenService:Create(MainContainer, tweenInfo, {Position = targetPos})
        local scaleTween = TweenService:Create(UIScaleConstraint, tweenInfo, {Scale = 0.05})

        moveTween:Play()
        scaleTween:Play()

        scaleTween.Completed:Wait()

        ScriptUi.Enabled = false
        MainContainer.Position = LastWindowPos
        UIScaleConstraint.Scale = GetTargetViewportScale()

        Window:Notify("Minimized", "Click icon to restore UI", 2)
        IsAnimatingMinimize = false
    end

    local function RestoreWindowAnimation()
        if IsAnimatingMinimize then return end
        IsAnimatingMinimize = true
        PlayClickSFX()

        BackgroundDOF.Enabled = Window.BackgroundBlurEnabled
        LocalUIBlurPart.Transparency = Window.BackgroundBlurEnabled and 0.98 or 1

        -- HIDE MINIMIZED FLOATING ICON IMMEDIATELY (Zero delay!)
        MinimisedUI.Enabled = false
        MinimizedImage.Rotation = 0

        local targetScale = GetTargetViewportScale()
        MainContainer.Position = MinimizedFrame.Position
        UIScaleConstraint.Scale = 0.05
        ScriptUi.Enabled = true

        local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local moveTween = TweenService:Create(MainContainer, tweenInfo, {Position = LastWindowPos})
        local scaleTween = TweenService:Create(UIScaleConstraint, tweenInfo, {Scale = targetScale})

        moveTween:Play()
        scaleTween:Play()

        scaleTween.Completed:Wait()
        IsAnimatingMinimize = false
    end

    TrackConn(MinimiseBtn.MouseButton1Click:Connect(function()
        MinimizeWindowAnimation()
    end))

    local minClick = 0
    TrackConn(MinimizedImage.MouseButton1Click:Connect(function()
        if (os.clock() - minClick) > 0.25 then
            minClick = os.clock()
            RestoreWindowAnimation()
        end
    end))

    -- =========================================================================
    -- UI CLICK THEME-SPECIFIC PARTICLE ENGINE (Built into library)
    -- =========================================================================
    local ParticleLayer = Instance.new("Frame")
    ParticleLayer.Name = "ParticleLayer"
    ParticleLayer.Size = UDim2.new(1, 0, 1, 0)
    ParticleLayer.BackgroundTransparency = 1
    ParticleLayer.ZIndex = 60
    ParticleLayer.ClipsDescendants = false
    ParticleLayer.Parent = ScriptUi

    local ActiveParticleConns = {}

    TrackConn(CloseBtn.MouseButton1Click:Connect(function()
        PlayClickSFX()
        Window:Notify("Unloading", "Script hub closed.", 1.5)
        task.wait(0.5)
        for _, conn in ipairs(ActiveParticleConns) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        table.clear(ActiveParticleConns)
        for _, conn in ipairs(Window.Connections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        if ParticleLayer and ParticleLayer.Parent then ParticleLayer:Destroy() end
        if LocalUIBlurPart and LocalUIBlurPart.Parent then LocalUIBlurPart:Destroy() end
        if BackgroundDOF and BackgroundDOF.Parent then BackgroundDOF:Destroy() end
        if ScriptUi then ScriptUi:Destroy() end
        if MinimisedUI.Parent then MinimisedUI:Destroy() end
        if NotificationUI.Parent then NotificationUI:Destroy() end
        if SoundFolder.Parent then SoundFolder:Destroy() end
    end))

    TrackConn(RunService.Heartbeat:Connect(function()
        if ScriptUi and ScriptUi.Enabled then
            LocalTime.Text = "Local time: " .. os.date("%I:%M:%S %p")
        end
    end))

    local function SampleThemeColor()
        local cur = Window.CurrentTheme or Library.ThemePresets.Dark
        local palette = {
            cur.MainBG,
            cur.AccentBG,
            cur.ButtonBG,
            cur.Divider,
            cur.TopBG,
        }
        return palette[math.random(1, #palette)]
    end

    local function VaryBrightness(base)
        local factor = 0.75 + math.random() * 0.50
        return Color3.new(
            math.clamp(base.R * factor, 0, 1),
            math.clamp(base.G * factor, 0, 1),
            math.clamp(base.B * factor, 0, 1)
        )
    end

    local function SpawnClickParticles(screenX, screenY)
        if not Window.ClickEffectsEnabled or not ScriptUi or not ScriptUi.Enabled then return end
        local themeKey = Window.CurrentThemeKey or "Dark"
        local style = Window.ClickParticleType or "Theme default"

        if style == "Leaves" or (style == "Theme default" and themeKey == "Nature") then
            -- 8x8 Animated Flipbook Falling Leaves (109451333999691)
            local count = math.random(9, 14)
            for _ = 1, count do
                local size = math.random(20, 28)
                local greenColor = Color3.fromRGB(math.random(45, 80), math.random(190, 245), math.random(75, 115))
                local lifeT = 0.9 + math.random() * 0.5
                local vx = math.random(-70, 70)
                local vy = math.random(55, 90)
                local rotSpeed = math.random(-110, 110)
                local swaySeed = math.random() * 10
                local flipFrame = math.random(0, 63)

                local p = Instance.new("ImageLabel")
                p.Name = "LeafParticle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundTransparency = 1
                p.Image = "rbxassetid://109451333999691"
                p.ImageColor3 = greenColor
                p.ImageRectSize = Vector2.new(128, 128)
                p.ImageRectOffset = Vector2.new((flipFrame % 8) * 128, math.floor(flipFrame / 8) * 128)
                p.ZIndex = 61
                p.Parent = ParticleLayer

                local elapsed = 0
                local flipAccum = 0
                local flipInterval = 1 / 30
                local startX = screenX - size / 2
                local startY = screenY - size / 2
                local conn

                local function removeFromActive()
                    for i = #ActiveParticleConns, 1, -1 do
                        if ActiveParticleConns[i] == conn then
                            table.remove(ActiveParticleConns, i)
                            break
                        end
                    end
                end

                conn = RunService.RenderStepped:Connect(function(dt)
                    elapsed = elapsed + dt
                    flipAccum = flipAccum + dt
                    if not p or not p.Parent then
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end
                    if elapsed >= lifeT then
                        p:Destroy()
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end

                    if flipAccum >= flipInterval then
                        flipAccum = flipAccum - flipInterval
                        flipFrame = (flipFrame + 1) % 64
                        p.ImageRectOffset = Vector2.new((flipFrame % 8) * 128, math.floor(flipFrame / 8) * 128)
                    end

                    p.Rotation = p.Rotation + rotSpeed * dt
                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed + math.sin(elapsed * 3.5 + swaySeed) * 18
                    local cy = startY + vy * elapsed
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.ImageTransparency = math.clamp(t * 1.2, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end

        elseif style == "Gems" or (style == "Theme default" and themeKey == "Amethyst") then
            -- Falling Gem Particles (138774461279155)
            local count = math.random(9, 13)
            for _ = 1, count do
                local size = math.random(10, 16)
                local purpleColor = Color3.fromRGB(math.random(180, 220), math.random(90, 140), 255)
                local lifeT = 0.75 + math.random() * 0.4
                local vx = math.random(-40, 40)
                local vy = math.random(55, 90)
                local rotSpeed = math.random(-100, 100)
                local swaySeed = math.random() * 10

                local p = Instance.new("ImageLabel")
                p.Name = "GemParticle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundTransparency = 1
                p.Image = "rbxassetid://138774461279155"
                p.ImageColor3 = purpleColor
                p.ZIndex = 61
                p.Parent = ParticleLayer

                local elapsed = 0
                local startX = screenX - size / 2
                local startY = screenY - size / 2
                local conn

                local function removeFromActive()
                    for i = #ActiveParticleConns, 1, -1 do
                        if ActiveParticleConns[i] == conn then
                            table.remove(ActiveParticleConns, i)
                            break
                        end
                    end
                end

                conn = RunService.RenderStepped:Connect(function(dt)
                    elapsed = elapsed + dt
                    if not p or not p.Parent then
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end
                    if elapsed >= lifeT then
                        p:Destroy()
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end

                    p.Rotation = p.Rotation + rotSpeed * dt
                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed + math.sin(elapsed * 4 + swaySeed) * 10
                    local cy = startY + vy * elapsed
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.ImageTransparency = math.clamp(t * 1.2, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end

        elseif style == "Rings" then
            -- Expanding Pulsing Rings
            local count = math.random(3, 5)
            for i = 1, count do
                local initialSize = math.random(12, 18)
                local finalSize = initialSize + math.random(30, 50)
                local color = VaryBrightness(SampleThemeColor())
                local lifeT = 0.5 + math.random() * 0.3

                local p = Instance.new("ImageLabel")
                p.Name = "RingParticle"
                p.Size = UDim2.new(0, initialSize, 0, initialSize)
                p.Position = UDim2.new(0, screenX - initialSize / 2, 0, screenY - initialSize / 2)
                p.BackgroundTransparency = 1
                p.Image = "rbxassetid://118376432250064"
                p.ImageColor3 = color
                p.ZIndex = 61
                p.Parent = ParticleLayer

                local elapsed = 0
                local conn

                local function removeFromActive()
                    for idx = #ActiveParticleConns, 1, -1 do
                        if ActiveParticleConns[idx] == conn then
                            table.remove(ActiveParticleConns, idx)
                            break
                        end
                    end
                end

                conn = RunService.RenderStepped:Connect(function(dt)
                    elapsed = elapsed + dt
                    if not p or not p.Parent then
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end
                    if elapsed >= lifeT then
                        p:Destroy()
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end

                    local t = elapsed / lifeT
                    local curSz = initialSize + (finalSize - initialSize) * t
                    p.Size = UDim2.new(0, curSz, 0, curSz)
                    p.Position = UDim2.new(0, screenX - curSz / 2, 0, screenY - curSz / 2)
                    p.ImageTransparency = math.clamp(t * 1.3, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end

        elseif style == "Dots" then
            -- Glowing Circle Burst
            local count = math.random(6, 10)
            for _ = 1, count do
                local size = math.random(6, 12)
                local color = VaryBrightness(SampleThemeColor())
                local lifeT = 0.6 + math.random() * 0.3
                local angle = math.random() * math.pi * 2
                local speed = math.random(40, 90)
                local vx = math.cos(angle) * speed
                local vy = math.sin(angle) * speed

                local p = Instance.new("Frame")
                p.Name = "DotParticle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundColor3 = color
                p.BorderSizePixel = 0
                p.ZIndex = 61
                p.Parent = ParticleLayer

                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(1, 0)
                c.Parent = p

                local elapsed = 0
                local startX = screenX - size / 2
                local startY = screenY - size / 2
                local conn

                local function removeFromActive()
                    for idx = #ActiveParticleConns, 1, -1 do
                        if ActiveParticleConns[idx] == conn then
                            table.remove(ActiveParticleConns, idx)
                            break
                        end
                    end
                end

                conn = RunService.RenderStepped:Connect(function(dt)
                    elapsed = elapsed + dt
                    if not p or not p.Parent then
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end
                    if elapsed >= lifeT then
                        p:Destroy()
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end

                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed
                    local cy = startY + vy * elapsed + (80 * elapsed * elapsed)
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.BackgroundTransparency = math.clamp(t * 1.2, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end

        elseif style == "Sparkles" or style == "Custom image" or (style == "Theme default" and themeKey == "Original") then
            local count = math.random(6, 9)
            local customRaw = (style == "Custom image" and (Window.CustomParticleAsset or "")) or ""
            local customId = (customRaw:match("^%d+$") and ("rbxassetid://" .. customRaw)) or customRaw
            if customId == "" then
                customId = (style == "Sparkles" and "rbxassetid://15396333997") or "rbxassetid://80640700930724"
            end

            for _ = 1, count do
                local size = math.random(14, 22)
                local color = VaryBrightness(SampleThemeColor())
                local lifeT = 0.75 + math.random() * 0.4
                local vx = math.random(-60, 60)
                local vy = -(math.random(60, 120))
                local gravity = 350
                local rotSpeed = math.random(-120, 120)

                local p = Instance.new("ImageLabel")
                p.Name = "CustomParticle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundTransparency = 1
                p.Image = customId
                p.ImageColor3 = color
                p.ZIndex = 61
                p.Parent = ParticleLayer

                local elapsed = 0
                local startX = screenX - size / 2
                local startY = screenY - size / 2
                local conn

                local function removeFromActive()
                    for idx = #ActiveParticleConns, 1, -1 do
                        if ActiveParticleConns[idx] == conn then
                            table.remove(ActiveParticleConns, idx)
                            break
                        end
                    end
                end

                conn = RunService.RenderStepped:Connect(function(dt)
                    elapsed = elapsed + dt
                    if not p or not p.Parent then
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end
                    if elapsed >= lifeT then
                        p:Destroy()
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end

                    p.Rotation = p.Rotation + rotSpeed * dt
                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed
                    local cy = startY + vy * elapsed + 0.5 * gravity * elapsed * elapsed
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.ImageTransparency = math.clamp(t * 1.15, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end

        else
            -- Default Flipbook burst
            local count = math.random(4, 5)
            local baseSize = math.random(20, 26)
            for _ = 1, count do
                local size = baseSize + math.random(-3, 3)
                local color = VaryBrightness(SampleThemeColor())
                local lifeT = 0.85 + math.random() * 0.4

                local angle = math.random() * math.pi * 2
                local speed = math.random(35, 75)
                local vx = math.cos(angle) * speed
                local vy = math.sin(angle) * speed + math.random(5, 20)
                local gravity = math.random(60, 100)
                local swaySeed = math.random() * 10
                local flipFrame = math.random(0, 15)

                local p = Instance.new("ImageLabel")
                p.Name = "FlipParticle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundTransparency = 1
                p.Image = "rbxassetid://8733226116"
                p.ImageColor3 = color
                p.ImageRectSize = Vector2.new(256, 256)
                p.ImageRectOffset = Vector2.new((flipFrame % 4) * 256, math.floor(flipFrame / 4) * 256)
                p.ZIndex = 61
                p.Parent = ParticleLayer

                local elapsed = 0
                local flipAccum = 0
                local flipInterval = 1 / 15
                local startX = screenX - size / 2
                local startY = screenY - size / 2
                local conn

                local function removeFromActive()
                    for idx = #ActiveParticleConns, 1, -1 do
                        if ActiveParticleConns[idx] == conn then
                            table.remove(ActiveParticleConns, idx)
                            break
                        end
                    end
                end

                conn = RunService.RenderStepped:Connect(function(dt)
                    elapsed = elapsed + dt
                    flipAccum = flipAccum + dt
                    if not p or not p.Parent then
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end
                    if elapsed >= lifeT then
                        p:Destroy()
                        if conn then conn:Disconnect() end
                        removeFromActive()
                        return
                    end

                    if flipAccum >= flipInterval then
                        flipAccum = flipAccum - flipInterval
                        flipFrame = (flipFrame + 1) % 16
                        p.ImageRectOffset = Vector2.new((flipFrame % 4) * 256, math.floor(flipFrame / 4) * 256)
                    end

                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed + math.sin(elapsed * 3 + swaySeed) * 10
                    local cy = startY + vy * elapsed + 0.5 * gravity * elapsed * elapsed
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.ImageTransparency = math.clamp(t * 1.15, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end
        end
    end

    TrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if ScriptUi and ScriptUi.Enabled then
                local pos = input.Position
                local mainAbs = MainContainer.AbsolutePosition
                local mainSz = MainContainer.AbsoluteSize
                if pos.X >= mainAbs.X and pos.X <= mainAbs.X + mainSz.X and pos.Y >= mainAbs.Y and pos.Y <= mainAbs.Y + mainSz.Y then
                    SpawnClickParticles(pos.X, pos.Y)
                end
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            if UserInputService:GetFocusedTextBox() then return end

            -- 1. Check if a keybind badge is currently in editing/listening mode
            if ActiveListeningBadge then
                local b = ActiveListeningBadge
                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Escape then
                    b.ClearKey(true)
                    b.StopListening()
                else
                    b.SetKey(input.KeyCode, true)
                    b.StopListening()
                end
                return
            end

            -- 2. Trigger active keybinds
            if not gameProcessed and ScriptUi and ScriptUi.Enabled then
                local boundBadge = Window.KeybindMap[input.KeyCode]
                if boundBadge and boundBadge.OnTrigger then
                    boundBadge.OnTrigger()
                end
            end
        end
    end))

    Window.SpawnClickParticles = SpawnClickParticles
    Window.ParticleLayer = ParticleLayer
    Window.ActiveParticleConns = ActiveParticleConns

    Window.ScriptUi = ScriptUi
    Window.MinimisedUI = MinimisedUI
    Window.NotificationUI = NotificationUI
    Window.MainContainer = MainContainer
    Window.TopFrame = TopFrame
    Window.LeftFrame = LeftFrame
    Window.MainFrame = MainFrame
    Window.MainContentFrame = MainContentFrame
    Window.BottomFrame = BottomFrame
    Window.BottomGradient = BottomGradient
    Window.MinimizedGradient = MinimizedGradient
    Window.MDHUBNAME = MDHUBNAME
    Window.MadebyText = MadebyText
    Window.DiscordBtn = DiscordBtn
    Window.LocalTime = LocalTime
    Window.SidebarScroll = SidebarScroll
    Window.UIScaleConstraint = UIScaleConstraint
    Window.PlayHoverSFX = PlayHoverSFX
    Window.PlayClickSFX = PlayClickSFX
    Window.ApplyCornerRadii = ApplyCornerRadii
    Window.AddUIShadow = AddUIShadow

    function Window:ApplyTheme(themeKey)
        local newTheme = Library.ThemePresets[themeKey]
        if not newTheme then return end
        Window.CurrentTheme = newTheme
        Window.CurrentThemeKey = themeKey

        if Window.MainFrame then
            Window.MainFrame.BackgroundColor3 = newTheme.MainBG
            Window.MainFrame.BackgroundTransparency = newTheme.MainTrans
        end
        if Window.LeftFrame then
            Window.LeftFrame.BackgroundColor3 = newTheme.AccentBG
            Window.LeftFrame.BackgroundTransparency = newTheme.AccentTrans
        end
        if Window.TopFrame then
            Window.TopFrame.BackgroundColor3 = newTheme.TopBG
            Window.TopFrame.BackgroundTransparency = newTheme.TopTrans
        end
        if Window.BottomFrame then
            Window.BottomFrame.BackgroundColor3 = newTheme.BottomBG
            Window.BottomFrame.BackgroundTransparency = newTheme.BottomTrans
        end

        if Window.SidebarScroll then
            Window.SidebarScroll.ScrollBarImageColor3 = newTheme.Divider
        end

        if Window.BottomGradient then
            Window.BottomGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, newTheme.BottomGradient[1]),
                ColorSequenceKeypoint.new(0.496, newTheme.BottomGradient[2]),
                ColorSequenceKeypoint.new(1, newTheme.BottomGradient[3])
            })
        end

        if Window.MinimizedGradient then
            Window.MinimizedGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, newTheme.MinGradient[1]),
                ColorSequenceKeypoint.new(0.5, newTheme.MinGradient[2]),
                ColorSequenceKeypoint.new(1, newTheme.MinGradient[3])
            })
        end

        if Window.SidebarDividers then
            for _, div in ipairs(Window.SidebarDividers) do
                if div and div.Parent then
                    div.BackgroundColor3 = newTheme.Divider
                    div.BackgroundTransparency = 0
                end
            end
        end

        for _, btnData in ipairs(Window.RegisteredMDButtons) do
            if btnData and btnData.Frame and btnData.Frame.Parent then
                btnData.Frame.BackgroundColor3 = newTheme.ButtonBG
                if btnData.TextLabel then
                    btnData.TextLabel.TextColor3 = newTheme.Text
                end
                if btnData.Stroke then
                    btnData.Stroke.Color = Color3.fromRGB(255, 255, 255)
                    btnData.Stroke.Thickness = 1.2
                end
                if btnData.ArrowIcon then
                    btnData.ArrowIcon.ImageColor3 = newTheme.Text
                end
            end
        end

        for _, toggle in ipairs(Window.RegisteredMDToggles) do
            if toggle and toggle.Frame and toggle.Frame.Parent then
                if toggle.Overlay then toggle.Overlay.ImageColor3 = newTheme.ButtonBG end
                local isToggled = (toggle.GetState and toggle.GetState())
                toggle.Frame.BackgroundColor3 = isToggled and newTheme.ButtonBG or ((newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))
            end
        end

        for _, slider in ipairs(Window.RegisteredMDSliders) do
            if slider and slider.Track and slider.Track.Parent then
                slider.Track.BackgroundColor3 = (newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(20, 22, 28)
                if slider.FilledPart then slider.FilledPart.BackgroundColor3 = newTheme.ButtonBG end
                if slider.Overlay then slider.Overlay.ImageColor3 = newTheme.ButtonBG end
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
                    b.Container.BackgroundColor3 = (newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(24, 26, 34)
                    if b.Label then
                        b.Label.TextColor3 = newTheme.Text
                    end
                end
            end
        end

        if SearchBarContainer then
            SearchBarContainer.BackgroundColor3 = (newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(22, 24, 30)
            if SearchInput then
                SearchInput.TextColor3 = newTheme.Text
                SearchInput.PlaceholderColor3 = newTheme.SubText
            end
            if SearchIcon then
                SearchIcon.ImageColor3 = newTheme.SubText
            end
            if ClearSearchBtn then
                ClearSearchBtn.TextColor3 = newTheme.SubText
            end
        end
        if SearchResultsOverlay then
            SearchResultsOverlay.BackgroundColor3 = (newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(240, 245, 255) or Color3.fromRGB(20, 22, 28)
        end

        if Window.ThemePresetBtnMap then
            for k, btnData in pairs(Window.ThemePresetBtnMap) do
                if btnData and btnData.Stroke then
                    btnData.Stroke.Thickness = (k == themeKey) and 2.2 or 1.2
                end
            end
        end

        if Window.MDHUBNAME then Window.MDHUBNAME.TextColor3 = newTheme.Text end
        if Window.MadebyText then Window.MadebyText.TextColor3 = newTheme.Text end
        if Window.DiscordBtn then Window.DiscordBtn.TextColor3 = newTheme.SubText end
        if Window.LocalTime then Window.LocalTime.TextColor3 = newTheme.Text end
        if Window.WelcomeMsg then Window.WelcomeMsg.TextColor3 = newTheme.Text end

        if Window.Tabs then
            for name, tabData in pairs(Window.Tabs) do
                if tabData.Button then
                    tabData.Button.TextColor3 = (name == Window.ActiveTab) and newTheme.Text or newTheme.SubText
                end

                if tabData.ContentFrame then
                    tabData.ContentFrame.ScrollBarImageColor3 = newTheme.Divider
                    for _, card in ipairs(tabData.ContentFrame:GetChildren()) do
                        if card:IsA("Frame") and card.Name ~= "TopFrame" and card.Name ~= "MainHeaderFrame" then
                            if card.Name == "RowContainer" or card.Name == "RowFrame" or card.Name == "ParticleRow" or card.Name:find("Row") then
                                card.BackgroundTransparency = 1
                                for _, subCard in ipairs(card:GetChildren()) do
                                    if subCard:IsA("Frame") then
                                        subCard.BackgroundColor3 = newTheme.CardBG
                                        subCard.BackgroundTransparency = 0
                                        for _, child in ipairs(subCard:GetChildren()) do
                                            if child:IsA("TextLabel") then
                                                child.TextColor3 = (child.Name == "CardTitle" and newTheme.Text) or newTheme.SubText
                                            elseif child.Name == "CardDividerLine" then
                                                child.BackgroundTransparency = 1
                                            end
                                        end
                                    end
                                end
                            else
                                card.BackgroundColor3 = newTheme.CardBG
                                card.BackgroundTransparency = 0
                                for _, child in ipairs(card:GetChildren()) do
                                    if child:IsA("TextLabel") then
                                        if child.Name == "CardTitle" or child.Name == "TitleLabel" or child.Name == "ThemeTitle" or child.Name == "SectionTitle" or child.Name == "NotifLabel" or child.Name == "SoundLabel" or child.Name == "VolumeLabel" or child.Name == "WebTitle" or child.Name == "BlurTitle" or child.Name == "TransLabel" or child.Name == "CustomThemeTitle" or child.Name == "ClickEffectsTitle" or child.Name == "Welcomemsg" then
                                            child.TextColor3 = newTheme.Text
                                        elseif child.Name == "CardBody" or child.Name == "DescLabel" or child.Name == "WebDesc" or child.Name == "BlurDesc" or child.Name == "CustomThemeDesc" or child.Name == "ClickEffectsDesc" then
                                            child.TextColor3 = newTheme.SubText
                                        elseif child.Name ~= "LocalTime" and child.Name ~= "btntext" and child.Name ~= "drpdwntext" then
                                            child.TextColor3 = newTheme.Text
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        Window:Notify("Theme updated", "Applied " .. newTheme.Name .. " theme!", 2.5)
    end

    function Window:ApplyCustomTheme(baseColor)
        if not baseColor then return end
        Window.CustomThemeColor = baseColor
        local h, s, v = baseColor:ToHSV()

        local buttonBG = Color3.fromHSV(h, math.clamp(s * 0.95, 0.4, 1), math.clamp(v * 0.9, 0.4, 0.95))
        local accentBG = Color3.fromHSV(h, math.clamp(s * 0.75, 0.2, 0.8), math.clamp(v * 0.45, 0.15, 0.45))
        local topBG = Color3.fromHSV(h, math.clamp(s * 0.7, 0.2, 0.75), math.clamp(v * 0.35, 0.12, 0.38))
        local bottomBG = topBG
        local mainBG = Color3.fromHSV(h, math.clamp(s * 0.65, 0.15, 0.6), math.clamp(v * 0.22, 0.08, 0.24))
        local cardBG = Color3.fromHSV(h, math.clamp(s * 0.6, 0.15, 0.55), math.clamp(v * 0.15, 0.05, 0.16))
        local divider = Color3.fromHSV(h, math.clamp(s * 0.9, 0.3, 0.95), math.clamp(v * 0.7, 0.3, 0.85))

        local text = Color3.fromRGB(245, 245, 250)
        local subText = Color3.fromHSV(h, math.clamp(s * 0.25, 0.05, 0.35), 0.85)

        local bot1 = Color3.fromHSV(h, math.clamp(s * 0.8, 0.25, 0.85), math.clamp(v * 0.35, 0.15, 0.4))
        local bot2 = Color3.fromHSV(h, math.clamp(s * 0.85, 0.3, 0.9), math.clamp(v * 0.55, 0.25, 0.65))
        local bot3 = Color3.fromHSV(h, math.clamp(s * 0.8, 0.25, 0.85), math.clamp(v * 0.3, 0.12, 0.35))

        local min1 = Color3.fromHSV(h, math.clamp(s * 0.9, 0.4, 0.95), math.clamp(v * 0.65, 0.35, 0.8))
        local min2 = Color3.fromHSV(h, math.clamp(s * 0.75, 0.3, 0.8), math.clamp(v * 0.95, 0.6, 1.0))
        local min3 = Color3.fromHSV(h, math.clamp(s * 0.9, 0.4, 0.95), math.clamp(v * 0.7, 0.4, 0.85))

        local customTheme = {
            Name = "Custom",
            MainBG = mainBG,
            MainTrans = Window.CustomBGTransparency or 0.10,
            AccentBG = accentBG,
            AccentTrans = math.clamp((Window.CustomBGTransparency or 0.10) + 0.10, 0, 1),
            TopBG = topBG,
            TopTrans = 0.05,
            BottomBG = bottomBG,
            BottomTrans = 0.0,
            BottomGradient = { bot1, bot2, bot3 },
            MinGradient = { min1, min2, min3 },
            Divider = divider,
            Text = text,
            SubText = subText,
            CardBG = cardBG,
            ButtonBG = buttonBG
        }

        Library.ThemePresets["Custom"] = customTheme
        Window:ApplyTheme("Custom")
    end

    function Window:SetBackgroundTransparency(transparency)
        local pct = math.clamp(transparency or 0.10, 0, 0.95)
        Window.CustomBGTransparency = pct
        if Window.MainFrame then
            Window.MainFrame.BackgroundTransparency = pct
        end
        if Window.LeftFrame then
            Window.LeftFrame.BackgroundTransparency = math.clamp(pct + 0.10, 0, 1)
        end
    end

    function Window:SetUISounds(enabled)
        Window.UISoundsEnabled = enabled
    end

    function Window:SetSoundVolume(volume)
        local pct = math.clamp(volume or 0.8, 0, 1)
        Window.SoundVolume = pct
        if HoverSoundTemplate then HoverSoundTemplate.Volume = pct * 0.4 end
        if ClickSoundTemplate then ClickSoundTemplate.Volume = pct * 0.5 end
    end

    function Window:SetBackgroundBlur(enabled)
        Window.BackgroundBlurEnabled = enabled
        if BackgroundDOF and BackgroundDOF.Parent then
            BackgroundDOF.Enabled = enabled
        elseif enabled then
            BackgroundDOF = Instance.new("DepthOfFieldEffect")
            BackgroundDOF.Name = "ScriptHubDOF"
            BackgroundDOF.FocusDistance = 2.5
            BackgroundDOF.InFocusRadius = 0
            BackgroundDOF.NearIntensity = 1.0
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

    -- =========================================================================
    -- REAL ASSET PRELOADER & INITIALIZATION ENGINE
    -- =========================================================================
    task.defer(function()
        Window:UpdateLoadingProgress(10, "Initializing...")

        if not game:IsLoaded() then
            Window:UpdateLoadingProgress(15, "Waiting for game...")
            pcall(function() game.Loaded:Wait() end)
        end

        local Players = game:GetService("Players")
        local ContentProvider = game:GetService("ContentProvider")

        local lp = Players.LocalPlayer
        while not lp do
            Window:UpdateLoadingProgress(25, "Waiting for player...")
            task.wait(0.1)
            lp = Players.LocalPlayer
        end

        Window:UpdateLoadingProgress(35, "Preparing assets...")

        local assetsToPreload = {
            "rbxassetid://5852311399",
            "rbxassetid://5852311745",
            "rbxassetid://77044087750639",
            "rbxassetid://15396333997",
            "rbxassetid://132261474823036",
            "rbxassetid://104249430704982",
            "rbxassetid://118376432250064",
            "rbxassetid://100354746235648",
            "rbxassetid://2418686949",
            "rbxassetid://5054663650",
            "rbxassetid://5054663737",
            "rbxassetid://6031094678",
            "rbxassetid://98226027552943"
        }

        if lp and lp.UserId then
            table.insert(assetsToPreload, "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=420&h=420")
        end

        if ScriptUi then
            for _, desc in ipairs(ScriptUi:GetDescendants()) do
                if desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                    if desc.Image and desc.Image ~= "" and not table.find(assetsToPreload, desc.Image) then
                        table.insert(assetsToPreload, desc.Image)
                    end
                elseif desc:IsA("Sound") then
                    if desc.SoundId and desc.SoundId ~= "" and not table.find(assetsToPreload, desc.SoundId) then
                        table.insert(assetsToPreload, desc.SoundId)
                    end
                end
            end
        end

        local totalAssets = #assetsToPreload
        local loadedAssets = 0

        if totalAssets > 0 then
            pcall(function()
                ContentProvider:PreloadAsync(assetsToPreload, function(contentId, status)
                    loadedAssets = loadedAssets + 1
                    local pct = 40 + math.floor((loadedAssets / totalAssets) * 55)
                    Window:UpdateLoadingProgress(pct, string.format("Preloading assets (%d/%d)...", loadedAssets, totalAssets))
                end)
            end)
        end

        Window:UpdateLoadingProgress(100, "Loaded!")
        Window:FinishLoading()
    end)

    return Window
end

return Library
