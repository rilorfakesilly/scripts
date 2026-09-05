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

local FontMichromaBold = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
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
        RegisteredDropdowns = {},
        ThemePresetBtnMap = {},
        Tabs = {},
        ActiveTab = nil
    }

    local function TrackConn(conn)
        if conn then
            table.insert(Window.Connections, conn)
        end
        return conn
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
        BoxFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        BoxFrame.BackgroundTransparency = 0.05
        BoxFrame.BorderSizePixel = 0
        BoxFrame.ZIndex = 10
        BoxFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = BoxFrame

        AddUIShadow(BoxFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0
        Stroke.Parent = BoxFrame

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(0, 160, 1, 0)
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
        InputBox.Size = UDim2.new(1, -180, 0, 32)
        InputBox.Position = UDim2.new(1, -170, 0.5, -16)
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
        InputBox.ClearTextOnFocus = false
        InputBox.ZIndex = 12
        InputBox.Parent = BoxFrame

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 6)
        InputCorner.Parent = InputBox

        local boxObj = {
            Frame = BoxFrame,
            InputBox = InputBox,
            GetText = function() return InputBox.Text end,
            SetText = function(txt, triggerCallback)
                InputBox.Text = txt or ""
                if triggerCallback and onSubmit then onSubmit(InputBox.Text) end
            end
        }

        TrackConn(InputBox.FocusLost:Connect(function(enterPressed)
            PlayClickSFX()
            if onSubmit then onSubmit(InputBox.Text, enterPressed) end
        end))

        if title and title ~= "" then
            Window.RegisteredTextboxes[title] = boxObj
        end

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
        DropdownFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        DropdownFrame.BackgroundTransparency = 0.05
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.ZIndex = 15
        DropdownFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = DropdownFrame

        AddUIShadow(DropdownFrame, 20, 0.5)

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = "UIStroke"
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.5
        Stroke.Transparency = 0
        Stroke.Parent = DropdownFrame

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
        TitleText.Text = title .. ": " .. defaultOption
        TitleText.TextColor3 = Window.CurrentTheme.Text
        TitleText.TextScaled = true
        TitleText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        TitleText.TextStrokeTransparency = 0.77
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
        DropdownContent.ZIndex = 25
        DropdownContent.Parent = DropdownFrame

        local ContentCorner = Instance.new("UICorner")
        ContentCorner.CornerRadius = UDim.new(0, 8)
        ContentCorner.Parent = DropdownContent

        local ContentStroke = Instance.new("UIStroke")
        ContentStroke.Name = "UIStroke"
        ContentStroke.Color = Color3.fromRGB(255, 255, 255)
        ContentStroke.Thickness = 1.2
        ContentStroke.Parent = DropdownContent

        AddUIShadow(DropdownContent, 20, 0.5)

        local InnerScroll = Instance.new("ScrollingFrame")
        InnerScroll.Name = "DropdownContentcontents"
        InnerScroll.Size = UDim2.new(1, -10, 1, -10)
        InnerScroll.Position = UDim2.new(0, 5, 0, 5)
        InnerScroll.BackgroundTransparency = 1
        InnerScroll.BorderSizePixel = 0
        InnerScroll.ScrollBarThickness = 3
        InnerScroll.ZIndex = 26
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
                ItemBtn.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
                ItemBtn.TextStrokeTransparency = 0.77
                ItemBtn.ZIndex = 27
                ItemBtn.Parent = InnerScroll

                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 6)
                ItemCorner.Parent = ItemBtn

                TrackConn(ItemBtn.MouseButton1Click:Connect(function()
                    PlayClickSFX()
                    selectedOption = opt
                    TitleText.Text = title .. ": " .. selectedOption
                    
                    isExpanded = false
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
                    if not isExpanded then DropdownContent.Visible = false end
                end)
            end
        end))

        local dropObj = {
            Frame = DropdownFrame,
            Content = DropdownContent,
            GetSelected = function() return selectedOption end,
            SetSelected = function(opt, triggerCallback)
                selectedOption = opt
                TitleText.Text = title .. ": " .. selectedOption
                RefreshOptions(options)
                if triggerCallback and onSelect then onSelect(selectedOption) end
            end,
            RefreshOptions = RefreshOptions
        }

        if title and title ~= "" then
            Window.RegisteredDropdowns[title] = dropObj
        end

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
        SectionTitle.Text = "Configuration Manager (" .. Window.ScriptName .. ")"
        SectionTitle.TextColor3 = Window.CurrentTheme.Text
        SectionTitle.TextSize = 15
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.ZIndex = 4
        SectionTitle.Parent = SectionFrame

        -- 1. Config Name Textbox
        local nameBoxObj = Window:CreateMDTextbox(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 48), "Config Name", "MyConfig", nil)

        -- 2. Config Selector Dropdown
        local configDropdownObj = Window:CreateMDDropdown(SectionFrame, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 52), "Selected Config", GetConfigList(), "DEFAULT", nil)

        -- 3. Row of Action Buttons (Create, Rewrite, Delete, Load)
        local ActionRow = Instance.new("Frame")
        ActionRow.Size = UDim2.new(1, 0, 0, 42)
        ActionRow.BackgroundTransparency = 1
        ActionRow.ZIndex = 4
        ActionRow.Parent = SectionFrame

        local ActionLayout = Instance.new("UIGridLayout")
        ActionLayout.CellSize = UDim2.new(0.235, 0, 1, 0)
        ActionLayout.CellPadding = UDim2.new(0.02, 0, 0, 0)
        ActionLayout.Parent = ActionRow

        -- Create Config Button
        Window:CreateMDButton(ActionRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "CREATE", function()
            local requested = nameBoxObj.GetText()
            local savedName = Window:SaveConfig(requested)
            if savedName then
                configDropdownObj.RefreshOptions(GetConfigList())
                configDropdownObj.SetSelected(savedName, false)
            end
        end)

        -- Rewrite Config Button
        Window:CreateMDButton(ActionRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "REWRITE", function()
            local current = configDropdownObj.GetSelected()
            Window:RewriteConfig(current)
        end)

        -- Delete Config Button
        Window:CreateMDButton(ActionRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "DELETE", function()
            local current = configDropdownObj.GetSelected()
            if Window:DeleteConfig(current) then
                configDropdownObj.RefreshOptions(GetConfigList())
                configDropdownObj.SetSelected("DEFAULT", false)
            end
        end)

        -- Load Config Button
        Window:CreateMDButton(ActionRow, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "LOAD", function()
            local current = configDropdownObj.GetSelected()
            Window:LoadConfig(current)
        end)

        parentTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, parentTab.Layout.AbsoluteContentSize.Y + 20)
        return SectionFrame
    end





    -- Audio SFX Controller
    local SoundFolder = Instance.new("Folder")
    SoundFolder.Name = "MDSounds"
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
    end


    local function PlayHoverSFX()
        if not Window.UISoundsEnabled then return end
        pcall(function()
            local snd = HoverSoundTemplate:Clone()
            snd.Parent = SoundFolder
            snd:Play()
            Debris:AddItem(snd, 1.5)
        end)
    end

    local function PlayClickSFX()
        if not Window.UISoundsEnabled then return end
        pcall(function()
            local snd = ClickSoundTemplate:Clone()
            snd.Parent = SoundFolder
            snd:Play()
            Debris:AddItem(snd, 1.5)
        end)
    end

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
        BtnText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        BtnText.TextStrokeTransparency = 0.92
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

        return {
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
        size = size or UDim2.new(0, 260, 0, 62)
        position = position or UDim2.new(0, 0, 0, 0)

        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = "TopFrame"
        BtnFrame.Size = size or UDim2.new(0, 260, 0, 62)
        BtnFrame.AutomaticSize = Enum.AutomaticSize.Y
        BtnFrame.Position = position
        BtnFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        BtnFrame.BackgroundTransparency = 0.05
        BtnFrame.BorderSizePixel = 0
        BtnFrame.ZIndex = 10
        BtnFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 36)
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
        BtnText.Size = UDim2.new(1, -24, 0, 39)
        BtnText.Position = UDim2.new(0, 12, 0.5, -19)
        BtnText.BackgroundTransparency = 1
        BtnText.FontFace = FontMichromaRegular
        BtnText.RichText = true
        BtnText.Text = text or "Function"
        BtnText.TextColor3 = Window.CurrentTheme.Text
        BtnText.TextScaled = true
        BtnText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        BtnText.TextStrokeTransparency = 0.77
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
        size = size or UDim2.new(0, 260, 0, 62)
        position = position or UDim2.new(0, 0, 0, 0)

        local CardFrame = Instance.new("Frame")
        CardFrame.Name = "TopFrame"
        CardFrame.Size = size or UDim2.new(0, 260, 0, 62)
        CardFrame.AutomaticSize = Enum.AutomaticSize.Y
        CardFrame.Position = position
        CardFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        CardFrame.BackgroundTransparency = 0.05
        CardFrame.BorderSizePixel = 0
        CardFrame.ZIndex = 10
        CardFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 36)
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
        TitleText.Size = UDim2.new(0, 131, 0, 39)
        TitleText.Position = UDim2.new(0.0616, 0, 0.1738, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.FontFace = FontMichromaRegular
        TitleText.RichText = true
        TitleText.Text = text or "Function"
        TitleText.TextColor3 = Window.CurrentTheme.Text
        TitleText.TextScaled = true
        TitleText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        TitleText.TextStrokeTransparency = 0.77
        TitleText.TextWrapped = true
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.TextYAlignment = Enum.TextYAlignment.Center
        TitleText.ZIndex = 11
        TitleText.Parent = MDTextFolder

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "TopFrame"
        ToggleFrame.Size = UDim2.new(0, 89, 0, 36)
        ToggleFrame.Position = UDim2.new(0.6025, 0, 0.2271, 0)
        ToggleFrame.BackgroundColor3 = initialState and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
        ToggleFrame.BackgroundTransparency = 0.05
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.ClipsDescendants = false
        ToggleFrame.ZIndex = 11
        ToggleFrame.Parent = CardFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 33)
        ToggleCorner.Parent = ToggleFrame

        AddUIShadow(ToggleFrame, 20, 0.5)

        local KnobFolder = Instance.new("Folder")
        KnobFolder.Name = "MDText"
        KnobFolder.Parent = ToggleFrame

        local isToggled = initialState

        local BaseCircle = Instance.new("ImageLabel")
        BaseCircle.Name = "ToggleThingLikeCircle"
        BaseCircle.Size = UDim2.new(0, 44, 0, 44)
        BaseCircle.Position = isToggled and UDim2.new(1, -45, 0.5, -22) or UDim2.new(0, 1, 0.5, -22)
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ZIndex = 12
        BaseCircle.Parent = KnobFolder

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = "ThethingOnTopThatMatchesBGofIt"
        OverlayCircle.Size = UDim2.new(0, 45, 0, 45)
        OverlayCircle.Position = isToggled and UDim2.new(1, -46, 0.5, -22) or UDim2.new(0, 0, 0.5, -22)
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

            local targetKnobPosBase = isToggled and UDim2.new(1, -45, 0.5, -22) or UDim2.new(0, 1, 0.5, -22)
            local targetKnobPosOver = isToggled and UDim2.new(1, -46, 0.5, -22) or UDim2.new(0, 0, 0.5, -22)
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
                BaseCircle.Position = isToggled and UDim2.new(1, -45, 0.5, -22) or UDim2.new(0, 1, 0.5, -22)
                OverlayCircle.Position = isToggled and UDim2.new(1, -46, 0.5, -22) or UDim2.new(0, 0, 0.5, -22)
                ToggleFrame.BackgroundColor3 = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(35, 38, 48)
            end
        }
        table.insert(Window.RegisteredMDToggles, toggleData)

        return toggleData
    end


    local ScriptUi = Instance.new("ScreenGui")
    ScriptUi.Name = "ScriptUi"
    ScriptUi.ResetOnSpawn = false
    ScriptUi.Enabled = false
    ScriptUi.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScriptUi.DisplayOrder = 10
    ScriptUi.Parent = ParentGui

    local MinimisedUI = Instance.new("ScreenGui")
    MinimisedUI.Name = "MinimisedUI"
    MinimisedUI.ResetOnSpawn = false
    MinimisedUI.Enabled = false
    MinimisedUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MinimisedUI.DisplayOrder = 25
    MinimisedUI.Parent = ParentGui

    local NotificationUI = Instance.new("ScreenGui")
    NotificationUI.Name = "NotificationUI"
    NotificationUI.ResetOnSpawn = false
    NotificationUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationUI.DisplayOrder = 30
    NotificationUI.Parent = ParentGui

    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 660, 0, 430)
    MainContainer.Position = UDim2.new(0.5, -330, 0.5, -215)
    MainContainer.BackgroundTransparency = 1
    MainContainer.ClipsDescendants = false
    MainContainer.Parent = ScriptUi

    local UIScaleConstraint = Instance.new("UIScale")
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

    local BackgroundDOF = Instance.new("DepthOfFieldEffect")
    BackgroundDOF.Name = "MDScriptHubDOF"
    BackgroundDOF.FocusDistance = 2.5
    BackgroundDOF.InFocusRadius = 0
    BackgroundDOF.NearIntensity = 1.0
    BackgroundDOF.FarIntensity = 0.0
    BackgroundDOF.Enabled = Window.BackgroundBlurEnabled
    BackgroundDOF.Parent = Lighting

    local LocalUIBlurPart = Instance.new("Part")
    LocalUIBlurPart.Name = "MD_LocalUIBlurPart"
    LocalUIBlurPart.Material = Enum.Material.Glass
    LocalUIBlurPart.Transparency = Window.BackgroundBlurEnabled and 0.98 or 1
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
    MDHUBNAME.Size = UDim2.new(0, 153, 0, 46)
    MDHUBNAME.Position = UDim2.new(0.0259, 0, -0.052, 0)
    MDHUBNAME.BackgroundTransparency = 1
    MDHUBNAME.FontFace = FontMichromaRegular
    MDHUBNAME.Text = hubTitle
    MDHUBNAME.TextColor3 = Window.CurrentTheme.Text
    MDHUBNAME.TextSize = 15
    MDHUBNAME.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    MDHUBNAME.TextStrokeTransparency = 0.77
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

    -- Left Sidebar Frame
    local LeftFrame = Instance.new("Frame")
    LeftFrame.Name = "LeftFrame"
    LeftFrame.Size = UDim2.new(0, 175, 1, -94)
    LeftFrame.Position = UDim2.new(0, 0, 0, 42)
    LeftFrame.BackgroundColor3 = Window.CurrentTheme.AccentBG
    LeftFrame.BackgroundTransparency = Window.CurrentTheme.AccentTrans
    LeftFrame.BorderSizePixel = 0
    LeftFrame.ZIndex = 1
    LeftFrame.Parent = MainContainer

    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Name = "ScrollingFrame"
    SidebarScroll.Size = UDim2.new(0, 174, 1, 0)
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.BorderSizePixel = 0
    SidebarScroll.ScrollBarThickness = 0
    SidebarScroll.Parent = LeftFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Name = "UIListLayout"
    SidebarLayout.FillDirection = Enum.FillDirection.Vertical
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    SidebarLayout.Padding = UDim.new(0, 3)
    SidebarLayout.Parent = SidebarScroll

    -- Main Content Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, -175, 1, -94)
    MainFrame.Position = UDim2.new(0, 175, 0, 42)
    MainFrame.BackgroundColor3 = Window.CurrentTheme.MainBG
    MainFrame.BackgroundTransparency = Window.CurrentTheme.MainTrans
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 1
    MainFrame.Parent = MainContainer

    AddUIShadow(MainFrame, 20, 0.5)

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

    InitSpiderwebBackground(MainContainer, ScriptUi)

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
        NotifTitle.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        NotifTitle.TextStrokeTransparency = 0.77
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
        ContentFrame.Size = UDim2.new(1, -20, 1, -20)
        ContentFrame.Position = UDim2.new(0, 10, 0, 10)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderSizePixel = 0
        ContentFrame.ScrollBarThickness = 4
        ContentFrame.ScrollBarImageColor3 = Window.CurrentTheme.Divider
        ContentFrame.Visible = false
        ContentFrame.Parent = MainFrame

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = ContentFrame

        local TabObj = {
            Name = tabName,
            Button = TabButton,
            HoverGlow = HoverGlow,
            ContentFrame = ContentFrame,
            Layout = ContentLayout
        }

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
            RowFrame.Size = UDim2.new(1, -10, 0, 62)
            RowFrame.BackgroundTransparency = 1
            RowFrame.BorderSizePixel = 0
            RowFrame.ZIndex = 3
            RowFrame.Parent = ContentFrame
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return RowFrame
        end

        function TabObj:AddLongButton(text, callback, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 62) or UDim2.new(1, -10, 0, 62)
            local pos = position or UDim2.new(0, 0, 0, 0)

            local btnData = Window:CreateMDButtonLong(targetParent, pos, size, text, callback)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return btnData
        end


        function TabObj:AddDropdown(title, options, defaultOption, onSelect, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 62) or UDim2.new(1, -10, 0, 62)
            local pos = position or UDim2.new(0, 0, 0, 0)
            local dropObj = Window:CreateMDDropdown(targetParent, pos, size, title, options, defaultOption, onSelect)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return dropObj
        end

        function TabObj:AddTextbox(title, placeholder, defaultText, onSubmit, parentRow, position)
            local targetParent = parentRow or ContentFrame
            local size = parentRow and UDim2.new(0.485, -4, 0, 50) or UDim2.new(1, -10, 0, 50)
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
            local size = parentRow and UDim2.new(0.485, -4, 0, 62) or UDim2.new(1, -10, 0, 62)
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
            task.spawn(function()
                task.wait(0.05)
                ContentFrame.Visible = true
                TabButton.TextColor3 = Window.CurrentTheme.Text
                TabButton.TextSize = 18
                TabButton.FontFace = FontMichromaBold
                HoverGlow.BackgroundTransparency = 0.85
                Window.ActiveTab = tabName
            end)
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

    Window.ScriptUi = ScriptUi
    Window.MinimisedUI = MinimisedUI
    Window.NotificationUI = NotificationUI
    Window.MainContainer = MainContainer
    Window.TopFrame = TopFrame
    Window.LeftFrame = LeftFrame
    Window.MainFrame = MainFrame
    Window.BottomFrame = BottomFrame
    Window.SidebarScroll = SidebarScroll
    Window.UIScaleConstraint = UIScaleConstraint
    Window.PlayHoverSFX = PlayHoverSFX
    Window.PlayClickSFX = PlayClickSFX
    Window.ApplyCornerRadii = ApplyCornerRadii
    Window.AddUIShadow = AddUIShadow

    function Window:SetBackgroundBlur(enabled)
        Window.BackgroundBlurEnabled = enabled
        BackgroundDOF.Enabled = enabled
        LocalUIBlurPart.Transparency = enabled and 0.98 or 1
    end

    function Window:SetSpiderwebBackground(enabled)
        Window.SpiderwebBGEnabled = enabled
    end

    return Window
end

return Library
