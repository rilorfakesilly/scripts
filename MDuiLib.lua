local Library = {}
Library.Version = "2.5"

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
        Name = "Original Orange",
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
        Name = "Very Dark",
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
        Name = "Green/Nature",
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

    local Window = {
        ScriptName = scriptName or hubTitle or "MD_Script",
        CurrentTheme = Library.ThemePresets.Dark,
        CurrentThemeKey = "Dark",
        NotificationsEnabled = true,
        UISoundsEnabled = true,
        SoundVolume = 0.8,
        BackgroundBlurEnabled = true,
        SpiderwebBGEnabled = true,
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

    local PlayHoverSFX = function()
        if not Window or not Window.UISoundsEnabled then return end
        pcall(function()
            if HoverSoundTemplate and SoundFolder then
                local snd = HoverSoundTemplate:Clone()
                local volFactor = (Window.SoundVolume ~= nil) and Window.SoundVolume or 0.8
                snd.Volume = 0.5 * volFactor
                snd.Parent = SoundFolder
                snd:Play()
                Debris:AddItem(snd, 1.5)
            end
        end)
    end

    local PlayClickSFX = function()
        if not Window or not Window.UISoundsEnabled then return end
        pcall(function()
            if ClickSoundTemplate and SoundFolder then
                local snd = ClickSoundTemplate:Clone()
                local volFactor = (Window.SoundVolume ~= nil) and Window.SoundVolume or 0.8
                snd.Volume = 0.6 * volFactor
                snd.Parent = SoundFolder
                snd:Play()
                Debris:AddItem(snd, 1.5)
            end
        end)
    end

    -- =========================================================================
    -- CONTROL REGISTRIES & CONFIG PERSISTENCE ENGINE
    -- =========================================================================


    local HttpService = game:GetService("HttpService")
    local SanitizedScriptName = (Window.ScriptName:gsub("[^%w_%-]", "_"))
    local ConfigFolderPath = "MD_Configs/" .. SanitizedScriptName

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
                    local fileName = filePath:match("([^/]+)%.json$") or filePath:match("([^\]+)%.json$")
                    if fileName and fileName ~= "DEFAULT" then
                        table.insert(list, fileName)
                    end
                end
            end
        end)
        return list
    end

    function Window:GetConfigSaveData()
        local data = {
            Theme = Window.CurrentThemeKey or "Dark",
            Settings = {
                Spiderweb = Window.SpiderwebEnabled,
                Blur = Window.BackgroundBlurEnabled,
                Sounds = Window.UISoundsEnabled,
                SoundVolume = Window.SoundVolume
            },
            Toggles = {},
            Sliders = {},
            Textboxes = {},
            Dropdowns = {}
        }
        for name, toggle in pairs(Window.RegisteredToggles) do
            pcall(function() data.Toggles[name] = toggle.GetState() end)
        end
        for name, slider in pairs(Window.RegisteredSliders) do
            pcall(function() data.Sliders[name] = slider.GetValue() end)
        end
        for name, box in pairs(Window.RegisteredTextboxes) do
            pcall(function() data.Textboxes[name] = box.GetText() end)
        end
        for name, drop in pairs(Window.RegisteredDropdowns) do
            pcall(function() data.Dropdowns[name] = drop.GetSelected() end)
        end
        return data
    end

    function Window:ApplyConfigSaveData(data)
        if not data then return end
        if data.Toggles then
            for name, state in pairs(data.Toggles) do
                local toggle = Window.RegisteredToggles[name]
                if toggle and toggle.SetState then
                    pcall(function() toggle.SetState(state, true) end)
                end
            end
        end
        if data.Sliders then
            for name, val in pairs(data.Sliders) do
                local slider = Window.RegisteredSliders[name]
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
        if data.Dropdowns then
            for name, selected in pairs(data.Dropdowns) do
                local drop = Window.RegisteredDropdowns[name]
                if drop and drop.SetSelected then
                    pcall(function() drop.SetSelected(selected, true) end)
                end
            end
        end
        if data.Theme then
            if Window.ApplyTheme then
                pcall(function() Window.ApplyTheme(data.Theme) end)
            elseif Library.ThemePresets[data.Theme] then
                Window.CurrentTheme = Library.ThemePresets[data.Theme]
                Window.CurrentThemeKey = data.Theme
            end
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
        end
    end

    local DefaultConfigMemoryData = Window:GetConfigSaveData()
    task.spawn(function()
        task.wait(0.3)
        DefaultConfigMemoryData = Window:GetConfigSaveData()
    end)

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
            Window:Notify("Config Error", "DEFAULT config cannot be overwritten!", 3)
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
            Window:Notify("Config Saved", "Saved config as '" .. finalName .. "'", 2.5)
            return finalName
        else
            Window:Notify("Config Error", "Failed to write config file", 3)
            return false
        end
    end

    function Window:RewriteConfig(configName)
        if not configName or configName:upper() == "DEFAULT" then
            Window:Notify("Config Error", "DEFAULT config cannot be overwritten!", 3)
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
            Window:Notify("Config Rewritten", "Overwrote '" .. configName .. "'!", 2.5)
            return true
        else
            Window:Notify("Config Error", "Failed to overwrite file", 3)
            return false
        end
    end

    function Window:LoadConfig(configName)
        configName = configName or "DEFAULT"

        if configName:upper() == "DEFAULT" then
            Window:ApplyConfigSaveData(DefaultConfigMemoryData)
            Window:Notify("Config Loaded", "Loaded DEFAULT config!", 2.5)
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
            Window:Notify("Config Loaded", "Loaded '" .. configName .. "'!", 2.5)
            return true
        else
            Window:Notify("Config Error", "Config '" .. configName .. "' not found!", 3)
            return false
        end
    end

    function Window:DeleteConfig(configName)
        if not configName or configName:upper() == "DEFAULT" then
            Window:Notify("Config Error", "DEFAULT config cannot be deleted!", 3)
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
            Window:Notify("Config Deleted", "Deleted config '" .. configName .. "'", 2.5)
            return true
        else
            Window:Notify("Config Error", "Failed to delete config file", 3)
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
        BoxFrame.Name = "MDTextboxFrame"
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

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = "DropdownExample"
        DropdownFrame.Size = size
        DropdownFrame.Position = position
        DropdownFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        DropdownFrame.BackgroundTransparency = 0.05
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.ZIndex = 15
        DropdownFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = DropdownFrame

        AddUIShadow(DropdownFrame, 20, 0.5)

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = "MDText"
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
        DropdownContent.ZIndex = 50
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
        InnerScroll.ZIndex = 51
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
                ItemBtn.BackgroundColor3 = (opt == selectedOption) and Window.CurrentTheme.ButtonBG or Color3.fromRGB(30, 32, 42)
                ItemBtn.BackgroundTransparency = 0.1
                ItemBtn.FontFace = FontMichromaRegular
                ItemBtn.RichText = true
                ItemBtn.Text = opt
                ItemBtn.TextColor3 = Window.CurrentTheme.Text
                ItemBtn.TextSize = 12
                ItemBtn.ZIndex = 52
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

            DropdownFrame.ZIndex = isExpanded and 45 or 15
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
        local nameBoxObj = Window:CreateMDTextbox(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "Config Name", "MyConfig", nil)

        -- 2. Config Selector Dropdown
        local configDropdownObj = Window:CreateMDDropdown(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "", GetConfigList(), "DEFAULT", nil)

        -- 3. Row 1: Left = CREATE CONFIG, Right = DELETE CONFIG
        local Row1 = Instance.new("Frame")
        Row1.Name = "ConfigRow1"
        Row1.Size = UDim2.new(1, 0, 0, 44)
        Row1.BackgroundTransparency = 1
        Row1.BorderSizePixel = 0
        Row1.ZIndex = 4
        Row1.Parent = SectionFrame

        Window:CreateMDButtonLong(Row1, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 1, 0), "CREATE CONFIG", function()
            local requested = nameBoxObj.GetText()
            local savedName = Window:SaveConfig(requested)
            if savedName then
                configDropdownObj.RefreshOptions(GetConfigList())
                configDropdownObj.SetSelected(savedName, false)
            end
        end)

        Window:CreateMDButtonLong(Row1, UDim2.new(0.515, 4, 0, 0), UDim2.new(0.485, -4, 1, 0), "DELETE CONFIG", function()
            local current = configDropdownObj.GetSelected()
            if Window:DeleteConfig(current) then
                configDropdownObj.RefreshOptions(GetConfigList())
                configDropdownObj.SetSelected("DEFAULT", false)
            end
        end)

        -- 4. Row 2: Left = OVERWRITE CONFIG, Right = LOAD CONFIG
        local Row2 = Instance.new("Frame")
        Row2.Name = "ConfigRow2"
        Row2.Size = UDim2.new(1, 0, 0, 44)
        Row2.BackgroundTransparency = 1
        Row2.BorderSizePixel = 0
        Row2.ZIndex = 4
        Row2.Parent = SectionFrame

        Window:CreateMDButtonLong(Row2, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 1, 0), "OVERWRITE CONFIG", function()
            local current = configDropdownObj.GetSelected()
            Window:RewriteConfig(current)
        end)

        Window:CreateMDButtonLong(Row2, UDim2.new(0.515, 4, 0, 0), UDim2.new(0.485, -4, 1, 0), "LOAD CONFIG", function()
            local current = configDropdownObj.GetSelected()
            Window:LoadConfig(current)
        end)

        parentTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, parentTab.Layout.AbsoluteContentSize.Y + 20)
        return SectionFrame
    end





    -- Audio SFX Controller (Parented to SoundService for guaranteed playback across all executors)
    local SoundService = game:GetService("SoundService")
    local SoundFolder = Instance.new("Folder")
    SoundFolder.Name = "MDSounds"
    pcall(function()
        SoundFolder.Parent = SoundService
    end)
    if not SoundFolder.Parent then
        pcall(function() SoundFolder.Parent = workspace end)
    end
    if not SoundFolder.Parent then
        SoundFolder.Parent = ParentGui
    end

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
    Loadingtext.Text = "LOADING..."
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

    function Window:UpdateLoadingProgress(pct, statusText)
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
        Window:UpdateLoadingProgress(100, "LOADED!")
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
        Window:SetBackgroundBlur(Window.BackgroundBlurEnabled)
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
        MDTextFolder.Name = "MDText"
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

    function Window:CreateMDToggle(parent, position, size, initialState, onToggle)
        size = size or UDim2.new(0, 56, 0, 26)

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "MDToggleFrame"
        ToggleFrame.Size = size
        ToggleFrame.Position = position or UDim2.new(0, 0, 0, 0)
        ToggleFrame.BackgroundColor3 = initialState and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
        ToggleFrame.BackgroundTransparency = 0.05
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.ClipsDescendants = true
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

        TrackConn(ClickBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            isToggled = not isToggled

            local targetKnobPos = isToggled and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0)
            local targetRotation = isToggled and 0 or 225
            local targetBG = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)

            TweenService:Create(KnobFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetKnobPos,
                Rotation = targetRotation
            }):Play()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetBG}):Play()

            if onToggle then
                onToggle(isToggled)
            end
        end))

        local toggleData = {
            Frame = ToggleFrame,
            Knob = KnobFrame,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetState = function() return isToggled end,
            SetState = function(state, triggerCallback)
                isToggled = state
                KnobFrame.Position = isToggled and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0)
                KnobFrame.Rotation = isToggled and 0 or 225
                ToggleFrame.BackgroundColor3 = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
                if triggerCallback and onToggle then
                    onToggle(isToggled)
                end
            end
        }
        table.insert(Window.RegisteredMDToggles, toggleData)
        return toggleData
    end

    function Window:CreateMDSlider(parent, position, size, minVal, maxVal, defaultVal, onValueChange)
        size = size or UDim2.new(0, 210, 0, 14)
        minVal = minVal or 0
        maxVal = maxVal or 100
        defaultVal = math.clamp(defaultVal or 80, minVal, maxVal)

        local TrackFrame = Instance.new("Frame")
        TrackFrame.Name = "SliderTrackFrame"
        TrackFrame.Size = size
        TrackFrame.Position = position or UDim2.new(0, 0, 0, 0)
        TrackFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        TrackFrame.BackgroundTransparency = 0.05
        TrackFrame.BorderSizePixel = 0
        TrackFrame.ZIndex = 10
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

        local initialPct = (defaultVal - minVal) / (maxVal - minVal)

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
        HandleFrame.Size = UDim2.new(0, 30, 0, 30)
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
                onValueChange(currentVal, pct)
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

        return {
            Track = TrackFrame,
            FilledPart = FilledPart,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetValue = function() return currentVal end,
            SetValue = function(val, triggerCallback)
                val = math.clamp(val, minVal, maxVal)
                currentVal = val
                local pct = (val - minVal) / (maxVal - minVal)
                FilledPart.Size = UDim2.new(pct, 0, 1, 0)
                HandleFrame.Position = UDim2.new(pct, 0, 0.5, 0)
                if triggerCallback and onValueChange then
                    onValueChange(currentVal, pct)
                end
            end
        }
    end

    -- Long Button Generator (Half-Side / Full-Row)
    function Window:CreateMDButtonLong(parent, position, size, text, onClick)
        size = size or UDim2.new(1, 0, 0, 44)
        position = position or UDim2.new(0, 0, 0, 0)

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
        MDTextFolder.Name = "MDText"
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
    function Window:CreateMDToggleHalf(parent, position, size, text, initialState, onToggle)
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
        MDTextFolder.Name = "MDText"
        MDTextFolder.Parent = CardFrame

        local TitleText = Instance.new("TextLabel")
        TitleText.Name = "btntext"
        TitleText.Size = UDim2.new(1, -65, 1, 0)
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
        ToggleFrame.ClipsDescendants = true
        ToggleFrame.ZIndex = 11
        ToggleFrame.Parent = CardFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 12)
        ToggleCorner.Parent = ToggleFrame

        AddUIShadow(ToggleFrame, 20, 0.5)

        local KnobFolder = Instance.new("Folder")
        KnobFolder.Name = "MDText"
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

        TrackConn(ClickBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            isToggled = not isToggled

            local targetKnobPosBase = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            local targetKnobPosOver = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            local targetBG = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)

            TweenService:Create(BaseCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetKnobPosBase}):Play()
            TweenService:Create(OverlayCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetKnobPosOver}):Play()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetBG}):Play()

            if onToggle then
                onToggle(isToggled)
            end
        end))

        local toggleData = {
            Frame = CardFrame,
            ToggleFrame = ToggleFrame,
            BaseCircle = BaseCircle,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetState = function() return isToggled end,
            SetState = function(state)
                isToggled = state
                BaseCircle.Position = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                OverlayCircle.Position = isToggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                ToggleFrame.BackgroundColor3 = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
            end
        }
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
        if item.Name == "MDScriptHubBlur" or item.Name == "MDScriptHubDOF" then
            pcall(function() item:Destroy() end)
        end
    end
    for _, item in ipairs(Camera:GetChildren()) do
        if item.Name == "MDScriptHubBlur" or item.Name == "MDScriptHubBlurCam" or item.Name == "MDScriptHubDOF" or item.Name == "MD_LocalUIBlurPart" then
            pcall(function() item:Destroy() end)
        end
    end
    for _, item in ipairs(workspace:GetChildren()) do
        if item.Name == "MD_LocalUIBlurPart" then
            pcall(function() item:Destroy() end)
        end
    end

    local BackgroundBlur = Instance.new("BlurEffect")
    BackgroundBlur.Name = "MDScriptHubBlur"
    BackgroundBlur.Size = 14
    BackgroundBlur.Enabled = false -- Enabled after FinishLoading
    BackgroundBlur.Parent = Lighting

    local BackgroundDOF = Instance.new("DepthOfFieldEffect")
    BackgroundDOF.Name = "MDScriptHubDOF"
    BackgroundDOF.FocusDistance = 2.5
    BackgroundDOF.InFocusRadius = 0
    BackgroundDOF.NearIntensity = 1.0
    BackgroundDOF.FarIntensity = 0.0
    BackgroundDOF.Enabled = false -- Enabled after FinishLoading
    BackgroundDOF.Parent = Lighting

    local LocalUIBlurPart = Instance.new("Part")
    LocalUIBlurPart.Name = "MD_LocalUIBlurPart"
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

    Window.BackgroundBlur = BackgroundBlur
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

    -- TopFrame
    local TopFrame = Instance.new("Frame")
    TopFrame.Name = "TopFrame"
    TopFrame.Size = UDim2.new(1, 0, 0, 42)
    TopFrame.Position = UDim2.new(0, 0, 0, 0)
    TopFrame.BackgroundColor3 = Window.CurrentTheme.TopBG
    TopFrame.BackgroundTransparency = Window.CurrentTheme.TopTrans
    TopFrame.BorderSizePixel = 0
    TopFrame.ZIndex = 2
    TopFrame.Parent = MainContainer

    local TopCorner = Instance.new("UICorner")
    ApplyCornerRadii(TopCorner, 8, 8, 0, 0)
    TopCorner.Parent = TopFrame

    AddUIShadow(TopFrame, 20, 0.5)

    local MDTextFolder = Instance.new("Folder")
    MDTextFolder.Name = "MDText"
    MDTextFolder.Parent = TopFrame

    local MDHUBNAME = Instance.new("TextLabel")
    MDHUBNAME.Name = "MDHUBNAME"
    MDHUBNAME.Size = UDim2.new(0, 190, 0, 46)
    MDHUBNAME.Position = UDim2.new(0.0259, 0, -0.052, 0)
    MDHUBNAME.BackgroundTransparency = 1
    MDHUBNAME.FontFace = FontMichromaHeavy
    MDHUBNAME.Text = hubTitle
    MDHUBNAME.TextColor3 = Window.CurrentTheme.Text
    MDHUBNAME.TextSize = 15
    MDHUBNAME.TextXAlignment = Enum.TextXAlignment.Left
    MDHUBNAME.ZIndex = 3
    MDHUBNAME.Parent = MDTextFolder

    local TopRightFolder = Instance.new("Folder")
    TopRightFolder.Name = "toprightbuttons"
    TopRightFolder.Parent = TopFrame

    local MinimiseBtnFrame = Instance.new("Frame")
    MinimiseBtnFrame.Size = UDim2.new(0, 30, 0, 30)
    MinimiseBtnFrame.Position = UDim2.new(0.877, 0, 0.14, 0)
    MinimiseBtnFrame.BackgroundTransparency = 1
    MinimiseBtnFrame.ZIndex = 3
    MinimiseBtnFrame.Parent = TopRightFolder

    local MinimiseBtn = Instance.new("ImageButton")
    MinimiseBtn.Size = UDim2.new(1, 0, 1, 0)
    MinimiseBtn.BackgroundTransparency = 1
    MinimiseBtn.ZIndex = 3
    MinimiseBtn.Parent = MinimiseBtnFrame

    local MinimiseIcon = Instance.new("ImageLabel")
    MinimiseIcon.Size = UDim2.new(0, 20, 0, 20)
    MinimiseIcon.Position = UDim2.new(0.168, 0, 0.168, 0)
    MinimiseIcon.BackgroundTransparency = 1
    MinimiseIcon.Image = "rbxassetid://15396333997"
    MinimiseIcon.ZIndex = 4
    MinimiseIcon.Parent = MinimiseBtn

    TrackConn(MinimiseBtn.MouseEnter:Connect(PlayHoverSFX))

    local CloseBtnFrame = Instance.new("Frame")
    CloseBtnFrame.Size = UDim2.new(0, 30, 0, 30)
    CloseBtnFrame.Position = UDim2.new(0.939, 0, 0.14, 0)
    CloseBtnFrame.BackgroundTransparency = 1
    CloseBtnFrame.ZIndex = 3
    CloseBtnFrame.Parent = TopRightFolder

    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 3
    CloseBtn.Parent = CloseBtnFrame

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.new(0, 27, 0, 27)
    CloseIcon.Position = UDim2.new(0.05, 0, 0.05, 0)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://132261474823036"
    CloseIcon.ZIndex = 4
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
        Window:Notify("Discord Server", "Copied invite link to clipboard:\nhttps://discord.gg/48jdqB8rAw", 3)
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
        NotifTextFolder.Name = "MDText"
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
        NotifIcon.Name = "MDicon"
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

    -- Smooth & Faster Tab Switch Engine
    local function SwitchTab(tabName)
        if Window.ActiveTab == tabName then return end

        local oldTab = Window.Tabs[Window.ActiveTab]
        local newTab = Window.Tabs[tabName]

        if oldTab then
            TweenService:Create(oldTab.Button, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextSize = 15,
                TextColor3 = Window.CurrentTheme.SubText
            }):Play()
            oldTab.Button.FontFace = FontMichromaRegular
            TweenService:Create(oldTab.HoverGlow, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        end

        if newTab then
            TweenService:Create(newTab.Button, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextSize = 18,
                TextColor3 = Window.CurrentTheme.Text
            }):Play()
            newTab.Button.FontFace = FontMichromaBold
            TweenService:Create(newTab.HoverGlow, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85}):Play()
        end

        if oldTab and oldTab.ContentFrame then
            local oldFrame = oldTab.ContentFrame
            local slideUpOut = TweenService:Create(oldFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 10, 0, -350)
            })
            slideUpOut:Play()
            slideUpOut.Completed:Connect(function()
                if Window.ActiveTab ~= oldTab.Name then
                    oldFrame.Visible = false
                    oldFrame.Position = UDim2.new(0, 10, 0, 10)
                end
            end)
        end

        if newTab and newTab.ContentFrame then
            local newFrame = newTab.ContentFrame
            newFrame.Position = UDim2.new(0, 10, 0, 350)
            newFrame.Visible = true

            TweenService:Create(newFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 10, 0, 10)
            }):Play()
        end

        Window.ActiveTab = tabName
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

            Window:CreateMDButton(CardFrame, UDim2.new(0, 110, 0, 30), UDim2.new(1, -120, 0.5, -15), "EXECUTE", function()
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
        end

        function TabObj:AddRow()
            local RowFrame = Instance.new("Frame")
            RowFrame.Name = "RowFrame"
            RowFrame.Size = UDim2.new(1, -10, 0, 44)
            RowFrame.BackgroundTransparency = 1
            RowFrame.BorderSizePixel = 0
            RowFrame.ZIndex = 3
            RowFrame.Parent = ContentFrame
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return RowFrame
        end

        function TabObj:AddLongButton(text, callback, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 44) or UDim2.new(1, -10, 0, 44)
            local pos = position or UDim2.new(0, 0, 0, 0)

            local btnData = Window:CreateMDButtonLong(targetParent, pos, size, text, callback)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return btnData
        end


        function TabObj:AddDropdown(title, options, defaultOption, onSelect, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 44) or UDim2.new(1, -10, 0, 44)
            local pos = position or UDim2.new(0, 0, 0, 0)
            local dropObj = Window:CreateMDDropdown(targetParent, pos, size, title, options, defaultOption, onSelect)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return dropObj
        end

        function TabObj:AddTextbox(title, placeholder, defaultText, onSubmit, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 44) or UDim2.new(1, -10, 0, 44)
            local pos = position or UDim2.new(0, 0, 0, 0)
            local boxObj = Window:CreateMDTextbox(targetParent, pos, size, title, placeholder, defaultText, onSubmit)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return boxObj
        end

        function TabObj:CreateConfigSection()
            return Window:CreateConfigSection(TabObj)
        end

        function TabObj:AddHalfToggle(text, initialState, onToggle, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 44) or UDim2.new(1, -10, 0, 44)
            local pos = position or UDim2.new(0, 0, 0, 0)

            local toggleData = Window:CreateMDToggleHalf(targetParent, pos, size, text, initialState, onToggle)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return toggleData
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
        if not Window.ActiveTab then
            Window.ActiveTab = tabName
            ContentFrame.Visible = true
            ContentFrame.Position = UDim2.new(0, 10, 0, 10)
            TabButton.TextColor3 = Window.CurrentTheme.Text
            TabButton.TextSize = 18
            TabButton.FontFace = FontMichromaBold
            HoverGlow.BackgroundTransparency = 0.85
        else
            ContentFrame.Visible = false
            TabButton.TextColor3 = Window.CurrentTheme.SubText
            TabButton.TextSize = 15
            TabButton.FontFace = FontMichromaRegular
            HoverGlow.BackgroundTransparency = 1
        end

        return TabObj
    end

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

    TrackConn(CloseBtn.MouseButton1Click:Connect(function()
        PlayClickSFX()
        Window:Notify("Unloading", "Script hub closed.", 1.5)
        task.wait(0.5)
        for _, conn in ipairs(Window.Connections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        if LocalUIBlurPart and LocalUIBlurPart.Parent then LocalUIBlurPart:Destroy() end
        if BackgroundDOF and BackgroundDOF.Parent then BackgroundDOF:Destroy() end
        if BackgroundBlur and BackgroundBlur.Parent then BackgroundBlur:Destroy() end
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
        if not ScriptUi or not ScriptUi.Enabled then return end
        local themeKey = Window.CurrentThemeKey or "Dark"

        if themeKey == "Nature" then
            -- 1. GREEN THEME: 8x8 Animated Flipbook Falling Leaves (109451333999691)
            local count = math.random(7, 11)
            for _ = 1, count do
                local size = math.random(20, 28)
                local greenColor = Color3.fromRGB(math.random(45, 80), math.random(190, 245), math.random(75, 115))
                local lifeT = 0.8 + math.random() * 0.4
                local vx = math.random(-35, 35)
                local vy = math.random(60, 95)
                local rotSpeed = math.random(-90, 90)
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

                    flipFrame = (flipFrame + 1) % 64
                    p.ImageRectOffset = Vector2.new((flipFrame % 8) * 128, math.floor(flipFrame / 8) * 128)
                    p.Rotation = p.Rotation + rotSpeed * dt

                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed + math.sin(elapsed * 4 + swaySeed) * 12
                    local cy = startY + vy * elapsed
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.ImageTransparency = math.clamp(t * 1.2, 0, 1)
                end)
                table.insert(ActiveParticleConns, conn)
            end

        elseif themeKey == "Amethyst" then
            -- 2. PURPLE THEME: Falling Gem Particles (138774461279155)
            local count = math.random(7, 11)
            for _ = 1, count do
                local size = math.random(18, 26)
                local purpleColor = Color3.fromRGB(math.random(180, 220), math.random(90, 140), 255)
                local lifeT = 0.8 + math.random() * 0.4
                local vx = math.random(-30, 30)
                local vy = math.random(60, 95)
                local rotSpeed = math.random(-80, 80)
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

        elseif themeKey == "Original" then
            -- 3. ORANGE THEME: Falling Light Orange Particles (80640700930724)
            local count = math.random(7, 11)
            for _ = 1, count do
                local size = math.random(18, 26)
                local orangeColor = Color3.fromRGB(255, math.random(165, 195), math.random(50, 85))
                local lifeT = 0.8 + math.random() * 0.4
                local vx = math.random(-30, 30)
                local vy = math.random(60, 95)
                local rotSpeed = math.random(-80, 80)
                local swaySeed = math.random() * 10

                local p = Instance.new("ImageLabel")
                p.Name = "OrangeParticle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundTransparency = 1
                p.Image = "rbxassetid://80640700930724"
                p.ImageColor3 = orangeColor
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

        else
            -- 4. DARK, VERY DARK, WHITE: Geometric debris burst matching theme colors
            local count = math.random(8, 14)
            for _ = 1, count do
                local shape = math.random(1, 3)
                local size = math.random(5, 14)
                local color = VaryBrightness(SampleThemeColor())

                local angle = math.random() * math.pi * 2
                local speed = math.random(55, 160)
                local vx = math.cos(angle) * speed
                local vy = math.sin(angle) * speed + math.random(20, 60)
                local lifeT = 0.35 + math.random() * 0.35
                local gravity = math.random(350, 600)

                local p = Instance.new("Frame")
                p.Name = "Particle"
                p.Size = UDim2.new(0, size, 0, size)
                p.Position = UDim2.new(0, screenX - size / 2, 0, screenY - size / 2)
                p.BackgroundColor3 = color
                p.BackgroundTransparency = 0
                p.BorderSizePixel = 0
                p.ZIndex = 61
                p.Parent = ParticleLayer

                if shape == 2 then
                    local c = Instance.new("UICorner")
                    c.CornerRadius = UDim.new(1, 0)
                    c.Parent = p
                elseif shape == 3 then
                    p.Rotation = 45
                    local c = Instance.new("UICorner")
                    c.CornerRadius = UDim.new(0, 2)
                    c.Parent = p
                else
                    local c = Instance.new("UICorner")
                    c.CornerRadius = UDim.new(0, 3)
                    c.Parent = p
                end

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
                    local t = elapsed / lifeT
                    local cx = startX + vx * elapsed
                    local cy = startY + vy * elapsed + 0.5 * gravity * elapsed * elapsed
                    local alpha = math.clamp(1 - (t * t), 0, 1)
                    local sz = size * (1 - t * 0.5)
                    p.Position = UDim2.new(0, cx, 0, cy)
                    p.Size = UDim2.new(0, sz, 0, sz)
                    p.BackgroundTransparency = 1 - alpha
                end)
                table.insert(ActiveParticleConns, conn)
            end
        end
    end

    TrackConn(UserInputService.InputBegan:Connect(function(input)
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
        end
    end))

    Window.SpawnClickParticles = SpawnClickParticles

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
                        if card:IsA("Frame") and card.Name ~= "TopFrame" and card.Name ~= "MainHeaderFrame" and card.Name ~= "ConfigRow1" and card.Name ~= "ConfigRow2" then
                            if card.Name == "RowContainer" then
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
                                        if child.Name == "CardTitle" or child.Name == "TitleLabel" or child.Name == "ThemeTitle" or child.Name == "SectionTitle" or child.Name == "NotifLabel" or child.Name == "SoundLabel" or child.Name == "VolumeLabel" or child.Name == "WebTitle" or child.Name == "BlurTitle" or child.Name == "Welcomemsg" then
                                            child.TextColor3 = newTheme.Text
                                        elseif child.Name == "CardBody" or child.Name == "DescLabel" or child.Name == "WebDesc" or child.Name == "BlurDesc" then
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

        Window:Notify("Theme Updated", "Applied " .. newTheme.Name .. " theme!", 2.5)
    end

    function Window:SetUISounds(enabled)
        Window.UISoundsEnabled = enabled
    end

    function Window:SetSoundVolume(volume)
        Window.SoundVolume = math.clamp(volume or 0.8, 0, 1)
    end

    function Window:SetBackgroundBlur(enabled)
        Window.BackgroundBlurEnabled = enabled
        if BackgroundBlur and BackgroundBlur.Parent then BackgroundBlur.Enabled = enabled end
        if BackgroundDOF and BackgroundDOF.Parent then BackgroundDOF.Enabled = enabled end
        if LocalUIBlurPart and LocalUIBlurPart.Parent then LocalUIBlurPart.Transparency = enabled and 0.96 or 1 end
    end

    function Window:SetSpiderwebBackground(enabled)
        Window.SpiderwebBGEnabled = enabled
    end

    return Window
end

return Library
