local Library = {}
Library.Version = "2.26.4"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GenerateSafeName(prefix)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = {}
    for i = 1, 8 do
        local r = math.random(1, #chars)
        table.insert(res, chars:sub(r, r))
    end
    local id = table.concat(res)
    return prefix and (tostring(prefix) .. "_" .. id) or id
end

local function GetSafeParentGui()
    local success, hui = pcall(function()
        if gethui then return gethui() end
        if get_hidden_gui then return get_hidden_gui() end
    end)
    if success and hui then return hui end

    if syn and syn.protect_gui then
        local protectedFolder = nil
        pcall(function()
            protectedFolder = Instance.new("Folder")
            syn.protect_gui(protectedFolder)
            local cg = (cloneref and cloneref(CoreGui)) or CoreGui
            protectedFolder.Parent = cg
        end)
        if protectedFolder then return protectedFolder end
    elseif protectgui then
        local protectedFolder = nil
        pcall(function()
            protectedFolder = Instance.new("Folder")
            protectgui(protectedFolder)
            local cg = (cloneref and cloneref(CoreGui)) or CoreGui
            protectedFolder.Parent = cg
        end)
        if protectedFolder then return protectedFolder end
    end

    local cgSuccess, cg = pcall(function()
        return (cloneref and cloneref(CoreGui)) or CoreGui
    end)
    if cgSuccess and cg then
        local testOk = pcall(function()
            local t = Instance.new("Folder")
            t.Parent = cg
            t:Destroy()
        end)
        if testOk then return cg end
    end

    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pg then return pg end
    end

    return CoreGui
end

local ParentGui = GetSafeParentGui()

local function ProtectGui(gui)
    if not gui then return end
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        elseif protectgui then
            protectgui(gui)
        end
    end)
end
local function ResolveParent(parent)
    if type(parent) == "table" then
        if parent.Frame and typeof(parent.Frame) == "Instance" then
            return parent.Frame
        elseif parent.Instance and typeof(parent.Instance) == "Instance" then
            return parent.Instance
        end
    end
    return parent
end

Library.ActiveGuis = Library.ActiveGuis or {}

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
    shadowNode.Name = GenerateSafeName("UIShadow")
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
Library.ActiveWindows = {}

function Library:RegisterTheme(name, data)
    if type(name) ~= "string" or type(data) ~= "table" then return end
    local defaultTheme = Library.ThemePresets.Dark
    local newTheme = {
        Name = data.Name or name,
        MainBG = data.MainBG or defaultTheme.MainBG,
        MainTrans = data.MainTrans or defaultTheme.MainTrans,
        AccentBG = data.AccentBG or defaultTheme.AccentBG,
        AccentTrans = data.AccentTrans or defaultTheme.AccentTrans,
        TopBG = data.TopBG or defaultTheme.TopBG,
        TopTrans = data.TopTrans or defaultTheme.TopTrans,
        BottomBG = data.BottomBG or defaultTheme.BottomBG,
        BottomTrans = data.BottomTrans or defaultTheme.BottomTrans,
        CardBG = data.CardBG or defaultTheme.CardBG,
        ButtonBG = data.ButtonBG or defaultTheme.ButtonBG,
        Text = data.Text or defaultTheme.Text,
        SubText = data.SubText or defaultTheme.SubText,
        Divider = data.Divider or defaultTheme.Divider,
        BottomGradient = data.BottomGradient or defaultTheme.BottomGradient,
        MinGradient = data.MinGradient or defaultTheme.MinGradient
    }
    Library.ThemePresets[name] = newTheme

    for _, win in ipairs(Library.ActiveWindows or {}) do
        if win and win.ThemeContainer and win.ThemePresetBtnMap and not win.ThemePresetBtnMap[name] then
            local btnData = win:CreateMDButtonLong(win.ThemeContainer, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0), newTheme.Name, function()
                win:ApplyTheme(name)
            end)
            win.ThemePresetBtnMap[name] = btnData
            if win.SettingsTab and win.SettingsTab.ContentFrame and win.SettingsTab.Layout then
                win.SettingsTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, win.SettingsTab.Layout.AbsoluteContentSize.Y + 20)
            end
        end
    end
    return newTheme
end
Library.RegisterTheme = Library.RegisterTheme

function Library:CreateWindow(arg1, arg2, arg3, arg4, arg5)
    local hubTitle, scriptName, authorText, discordLink, iconAsset

    if type(arg1) == "table" then
        hubTitle = arg1.Title or arg1.HubTitle or arg1.Name or arg1.hubTitle or "MD SCRIPT HUB"
        scriptName = arg1.ScriptName or arg1.scriptName or hubTitle or "MD_Script"
        authorText = arg1.Author or arg1.AuthorText or arg1.MadeBy or arg1.madeBy or arg1.Creator
        discordLink = arg1.Discord or arg1.DiscordLink or arg1.DiscordServer or arg1.discord or arg1.Invite
        iconAsset = arg1.Icon or arg1.IconAsset or arg1.Logo or arg1.IconId or arg1.icon
    else
        hubTitle = arg1 or "MD SCRIPT HUB"
        scriptName = arg2 or hubTitle or "MD_Script"
        authorText = arg3
        discordLink = arg4
        iconAsset = arg5
    end

    -- Defaults
    if not authorText or authorText == "" then
        authorText = "Made by MorningDrift"
    elseif not authorText:lower():find("^made by") then
        authorText = "Made by " .. authorText
    end

    if not discordLink or discordLink == "" then
        discordLink = "discord.gg/48jdqB8rAw"
    end

    local discordDisplay = discordLink:gsub("^https?://", "")
    local discordCopyUrl = discordLink:find("^https?://") and discordLink or ("https://" .. discordDisplay)

    if not iconAsset or iconAsset == "" then
        iconAsset = "rbxassetid://77044087750639"
    elseif type(iconAsset) == "number" or tostring(iconAsset):match("^%d+$") then
        iconAsset = "rbxassetid://" .. tostring(iconAsset)
    end

    local minimizedIcon = (type(arg1) == "table" and (arg1.MinimizedIcon or arg1.MinimisedIcon or arg1.MiniIcon)) or iconAsset
    if not minimizedIcon or minimizedIcon == "" then
        minimizedIcon = "rbxassetid://77044087750639"
    elseif type(minimizedIcon) == "number" or tostring(minimizedIcon):match("^%d+$") then
        minimizedIcon = "rbxassetid://" .. tostring(minimizedIcon)
    end
    local autoSmallDividers = type(arg1) == "table" and (arg1.AutoSmallDividers == true or arg1.AutoDividers == true)

    if Library.ActiveGuis then
        for _, gui in ipairs(Library.ActiveGuis) do
            pcall(function()
                if gui and gui.Parent then gui:Destroy() end
            end)
        end
    end
    Library.ActiveGuis = {}

    local Window = {
        ScriptName = scriptName or hubTitle or "MD_Script",
        AuthorText = authorText,
        DiscordLink = discordLink,
        IconAsset = iconAsset,
        MinimizedIcon = minimizedIcon,
        AutoSmallDividers = autoSmallDividers,
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
        RegisteredMobileButtons = {},
        MobileButtonsLocked = false,
        MobileButtonsLayout = {
            BaseOffsetX = 70,
            BaseOffsetY = 70,
            SpacingY = 56,
            SpacingX = 64,
            MaxButtonsPerColumn = 6
        },
        RegisteredToggles = {},
        RegisteredSliders = {},
        RegisteredTextboxes = {},
        RegisteredTextboxesList = {},
        RegisteredDropdowns = {},
        RegisteredDropdownsList = {},
        RegisteredNumberInputs = {},
        RegisteredNumberInputsList = {},
        RegisteredMultiDropdowns = {},
        RegisteredMultiDropdownsList = {},
        RegisteredColorPickers = {},
        RegisteredColorPickersList = {},
        RegisteredKeybindBadges = {},
        ConfigLoadedCallbacks = {},
        ConfigSavedCallbacks = {},
        SidebarCollapsed = false,
        SidebarWidth = 175,
        CollapsedSidebarWidth = 56,
        KeybindMap = {},
        SearchableItems = {},
        ThemePresetBtnMap = {},
        Tabs = {},
        ActiveTab = nil
    }
    table.insert(Library.ActiveWindows, Window)

    function Window:OnConfigLoaded(fn)
        if type(fn) == "function" then
            table.insert(Window.ConfigLoadedCallbacks, fn)
        end
    end

    function Window:OnConfigSaved(fn)
        if type(fn) == "function" then
            table.insert(Window.ConfigSavedCallbacks, fn)
        end
    end

    function Window:RegisterTheme(name, data)
        return Library:RegisterTheme(name, data)
    end

    function Window:GetSettingsTab()
        return Window.SettingsTab
    end

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
    SoundFolder.Name = GenerateSafeName("Sounds")
    SoundFolder.Parent = ParentGui

    local HoverSoundTemplate = Instance.new("Sound")
    HoverSoundTemplate.Name = GenerateSafeName("HoverSound")
    HoverSoundTemplate.SoundId = "rbxassetid://5852311399"
    HoverSoundTemplate.Volume = 0.4
    HoverSoundTemplate.Parent = SoundFolder

    local ClickSoundTemplate = Instance.new("Sound")
    ClickSoundTemplate.Name = GenerateSafeName("ClickSound")
    ClickSoundTemplate.SoundId = "rbxassetid://5852311745"
    ClickSoundTemplate.Volume = 0.5
    ClickSoundTemplate.Parent = SoundFolder

    local function PlayHoverSFX()
        if not Window or not Window.UISoundsEnabled then return end
        pcall(function()
            local vol = (Window.SoundVolume ~= nil) and Window.SoundVolume or 0.8
            local snd = HoverSoundTemplate:Clone()
            snd.Volume = 0.35 * vol
            snd.Parent = SoundFolder
            snd:Play()
            Debris:AddItem(snd, 1.5)
        end)
    end

    local function PlayClickSFX()
        if not Window or not Window.UISoundsEnabled then return end
        pcall(function()
            local vol = (Window.SoundVolume ~= nil) and Window.SoundVolume or 0.8
            local snd = ClickSoundTemplate:Clone()
            snd.Volume = 0.45 * vol
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
            SidebarCollapsed = Window.SidebarCollapsed == true,
            Settings = {
                Spiderweb = (Window.SpiderwebBGEnabled ~= nil) and Window.SpiderwebBGEnabled or Window.SpiderwebEnabled,
                Blur = Window.BackgroundBlurEnabled,
                Sounds = Window.UISoundsEnabled,
                SoundVolume = Window.SoundVolume or 0.8,
                Notifications = Window.NotificationsEnabled,
                CustomThemeColor = (Window.IsCustomTheme and Window.CustomThemeColor) and Window.CustomThemeColor:ToHex() or nil,
                BGTransparency = Window.CustomBGTransparency or 0.10,
                ClickEffects = Window.ClickEffectsEnabled,
                ClickParticle = Window.ClickParticleType or "Theme default",
                CustomParticle = Window.CustomParticleAsset or ""
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
        for name, toggle in pairs(Window.RegisteredToggles) do
            pcall(function()
                if toggle and toggle.GetState then
                    data.Toggles[name] = toggle.GetState()
                end
                if toggle and toggle.Keybind and toggle.Keybind.CurrentKey then
                    data.ToggleBinds[name] = toggle.Keybind.CurrentKey.Name
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
        for name, mdrop in pairs(Window.RegisteredMultiDropdowns) do
            pcall(function()
                if mdrop and mdrop.GetSelections then
                    data.MultiDropdowns[name] = mdrop.GetSelections()
                end
            end)
        end
        for name, numInput in pairs(Window.RegisteredNumberInputs) do
            pcall(function()
                if numInput and numInput.GetValue then
                    data.NumberInputs[name] = numInput.GetValue()
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

        -- 1. Apply Theme Preset or Custom Theme First
        if data.Settings and data.Settings.CustomThemeColor and data.Settings.CustomThemeColor ~= "" and Window.ApplyCustomTheme then
            pcall(function()
                local col = Color3.fromHex(data.Settings.CustomThemeColor)
                Window:ApplyCustomTheme(col)
            end)
        elseif data.Theme and data.Theme ~= "Custom" then
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

        if data.SidebarCollapsed ~= nil and Window.SetSidebarCollapsed then
            pcall(function() Window:SetSidebarCollapsed(data.SidebarCollapsed) end)
        end

        -- 3. Apply Toggles
        if data.Toggles then
            for name, state in pairs(data.Toggles) do
                local toggle = Window.RegisteredToggles[name]
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

        -- 4. Apply Sliders
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

        -- 7. Apply Multi Dropdowns
        if data.MultiDropdowns then
            for name, selected in pairs(data.MultiDropdowns) do
                local mdrop = Window.RegisteredMultiDropdowns[name]
                if mdrop and mdrop.SetSelections then
                    pcall(function() mdrop.SetSelections(selected, true) end)
                end
            end
        end

        -- 8. Apply Number Inputs
        if data.NumberInputs then
            for name, val in pairs(data.NumberInputs) do
                local numInput = Window.RegisteredNumberInputs[name]
                if numInput and numInput.SetValue then
                    pcall(function() numInput.SetValue(val, true) end)
                end
            end
        end

        -- 9. Apply Color Pickers
        if data.ColorPickers then
            for name, hex in pairs(data.ColorPickers) do
                local cp = Window.RegisteredColorPickers[name]
                if cp and cp.SetColor then
                    pcall(function()
                        local col = Color3.fromHex(hex)
                        if name == "CustomTheme" then
                            cp.SetColor(col, false)
                        else
                            cp.SetColor(col, true)
                        end
                    end)
                end
            end
        end

        -- 10. Apply Mobile Buttons
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

        -- Fire ConfigLoaded Callbacks
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
        local filePath = ConfigFolderPath .. "/" .. finalName .. ".json"
        local success = pcall(function()
            if writefile then
                writefile(filePath, jsonString)
            end
        end)

        if success then
            Window:Notify("Config saved", "Saved config as '" .. finalName .. "'", 2.5)
            if Window.ConfigSavedCallbacks then
                for _, fn in ipairs(Window.ConfigSavedCallbacks) do
                    pcall(fn, finalName, saveData)
                end
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
        local filePath = ConfigFolderPath .. "/" .. configName .. ".json"
        local success = pcall(function()
            if writefile then writefile(filePath, jsonString) end
        end)

        if success then
            Window:Notify("Config rewritten", "Overwrote '" .. configName .. "'!", 2.5)
            if Window.ConfigSavedCallbacks then
                for _, fn in ipairs(Window.ConfigSavedCallbacks) do
                    pcall(fn, configName, saveData)
                end
            end
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
        local filePath = ConfigFolderPath .. "/TAB_" .. tabName:gsub("[^%w_%-]", "_") .. "_" .. configName .. ".json"
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
        local filePath = ConfigFolderPath .. "/TAB_" .. tabName:gsub("[^%w_%-]", "_") .. "_" .. configName .. ".json"
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

    -- =========================================================================
    -- TEXTBOX GENERATORS (Full & Half Width)
    -- =========================================================================
    function Window:CreateMDTextbox(parent, position, size, title, placeholder, defaultText, onSubmit, boxOptions)
        parent = ResolveParent(parent)
        size = size or UDim2.new(1, -10, 0, 50)
        position = position or UDim2.new(0, 0, 0, 0)

        local boxWidth = 160
        local titleWidth = nil
        if type(boxOptions) == "table" then
            boxWidth = boxOptions.BoxWidth or boxOptions.InputWidth or boxOptions.boxWidth or boxWidth
            titleWidth = boxOptions.TitleWidth or boxOptions.titleWidth
        elseif type(boxOptions) == "number" then
            boxWidth = boxOptions
        end

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Name = GenerateSafeName("TextboxFrame")
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
        TitleLabel.Name = GenerateSafeName("TitleLabel")
        TitleLabel.Size = titleWidth and UDim2.new(0, titleWidth, 1, 0) or UDim2.new(1, -(boxWidth + 24), 1, 0)
        TitleLabel.Position = UDim2.new(0, 12, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.FontFace = FontMichromaBold
        TitleLabel.Text = title or "Input"
        TitleLabel.TextColor3 = Window.CurrentTheme.Text
        TitleLabel.TextSize = 14
        TitleLabel.TextWrapped = true
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
        TitleLabel.ZIndex = 11
        TitleLabel.Parent = BoxFrame

        local InputBox = Instance.new("TextBox")
        InputBox.Name = GenerateSafeName("InputBox")
        InputBox.AnchorPoint = Vector2.new(1, 0.5)
        InputBox.Size = UDim2.new(0, boxWidth, 0, 30)
        InputBox.Position = UDim2.new(1, -12, 0.5, 0)
        InputBox.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        InputBox.BackgroundTransparency = 0.2
        InputBox.BorderSizePixel = 0
        InputBox.FontFace = FontMichromaRegular
        InputBox.PlaceholderText = placeholder or "Type here..."
        InputBox.PlaceholderColor3 = Window.CurrentTheme.SubText
        InputBox.Text = defaultText or ""
        InputBox.TextColor3 = Window.CurrentTheme.Text
        InputBox.TextSize = 13
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
            SetBoxWidth = function(newWidth)
                boxWidth = newWidth or boxWidth
                InputBox.Size = UDim2.new(0, boxWidth, 0, 30)
                if not titleWidth then
                    TitleLabel.Size = UDim2.new(1, -(boxWidth + 24), 1, 0)
                end
            end,
            RefreshTheme = function(theme)
                BoxFrame.BackgroundColor3 = theme.CardBG
                TitleLabel.TextColor3 = theme.Text
                InputBox.TextColor3 = theme.Text
                InputBox.PlaceholderColor3 = theme.SubText
                InputBox.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(230, 234, 242) or Color3.fromRGB(20, 22, 28)
            end
        }

        boxObj.WithCallback = function(self, cb)
            onSubmit = cb
            return self
        end
        boxObj.WithTooltip = function(self, tt)
            if Window.AttachTooltip and BoxFrame then
                Window:AttachTooltip(BoxFrame, tt)
            end
            return self
        end
        boxObj.WithSaveKey = function(self, key)
            if key and key ~= "" then
                self.SaveKey = key
                Window.RegisteredTextboxes[key] = self
            end
            return self
        end
        boxObj.WithText = function(self, txt)
            self.SetText(txt)
            return self
        end
        boxObj.WithPlaceholder = function(self, ph)
            if InputBox then InputBox.PlaceholderText = ph end
            return self
        end

        TrackConn(InputBox.FocusLost:Connect(function(enterPressed)
            PlayClickSFX()
            if onSubmit then onSubmit(InputBox.Text, enterPressed) end
        end))

        local boxName = (boxOptions and type(boxOptions) == "table" and (boxOptions.SaveKey or boxOptions.saveKey or boxOptions.Identifier or boxOptions.identifier)) or (title and title ~= "" and title) or ("Textbox_" .. (#Window.RegisteredTextboxesList + 1))
        boxObj.Name = boxName
        Window.RegisteredTextboxes[boxName] = boxObj
        table.insert(Window.RegisteredTextboxesList, boxObj)

        if boxOptions and type(boxOptions) == "table" and (boxOptions.Tooltip or boxOptions.tooltip) then
            boxObj:WithTooltip(boxOptions.Tooltip or boxOptions.tooltip)
        end
        if boxOptions and type(boxOptions) == "table" and (boxOptions.SaveKey or boxOptions.saveKey) then
            boxObj:WithSaveKey(boxOptions.SaveKey or boxOptions.saveKey)
        end

        return boxObj
    end

    -- =========================================================================
    -- DROPDOWN GENERATORS (Full-Width & Half-Width from XML Specs)
    -- =========================================================================
    function Window:CreateMDDropdown(parent, position, size, title, options, defaultOption, onSelect, dropConfig)
        parent = ResolveParent(parent)
        size = size or UDim2.new(1, -10, 0, 62)
        position = position or UDim2.new(0, 0, 0, 0)
        options = options or {}
        defaultOption = defaultOption or options[1] or "Select..."

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = GenerateSafeName("Dropdown")
        DropdownFrame.Size = size
        DropdownFrame.Position = position
        DropdownFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        DropdownFrame.BackgroundTransparency = 0.05
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.ZIndex = 4
        DropdownFrame.ClipsDescendants = false
        DropdownFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = DropdownFrame

        AddUIShadow(DropdownFrame, 20, 0.5)

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = GenerateSafeName("Text")
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
        TitleText.TextSize = 14
        TitleText.TextWrapped = true
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.TextYAlignment = Enum.TextYAlignment.Center
        TitleText.ZIndex = 5
        TitleText.Parent = MDTextFolder

        local ArrowIcon = Instance.new("ImageLabel")
        ArrowIcon.Name = GenerateSafeName("Icon")
        ArrowIcon.Size = UDim2.new(0, 36, 0, 36)
        ArrowIcon.Position = UDim2.new(1, -46, 0.5, -18)
        ArrowIcon.BackgroundTransparency = 1
        ArrowIcon.Image = "rbxassetid://11552476728"
        ArrowIcon.ImageColor3 = Window.CurrentTheme.Text
        ArrowIcon.ZIndex = 5
        ArrowIcon.Parent = DropdownFrame

        local HeaderTrigger = Instance.new("TextButton")
        HeaderTrigger.Name = GenerateSafeName("Trigger")
        HeaderTrigger.Size = UDim2.new(1, 0, 1, 0)
        HeaderTrigger.BackgroundTransparency = 1
        HeaderTrigger.Text = ""
        HeaderTrigger.ZIndex = 6
        HeaderTrigger.Parent = DropdownFrame

        local isSearchable = (type(dropConfig) == "table" and (dropConfig.Searchable or dropConfig.Search or dropConfig.searchable)) or false

        -- Dropdown Content List Frame (Parented to Window.DropdownOverlay or MainContainer)
        local DropdownContent = Instance.new("Frame")
        DropdownContent.Name = GenerateSafeName("Content")
        DropdownContent.Size = UDim2.new(0, 0, 0, 0)
        DropdownContent.Position = UDim2.new(0, 0, 0, 0)
        DropdownContent.BackgroundColor3 = Window.CurrentTheme.CardBG
        DropdownContent.BackgroundTransparency = 0.05
        DropdownContent.BorderSizePixel = 0
        DropdownContent.ClipsDescendants = true
        DropdownContent.Visible = false
        DropdownContent.ZIndex = 501
        DropdownContent.Parent = Window.DropdownOverlay or MainContainer

        local ContentCorner = Instance.new("UICorner")
        ContentCorner.CornerRadius = UDim.new(0, 8)
        ContentCorner.Parent = DropdownContent

        AddUIShadow(DropdownContent, 20, 0.5)

        local SearchContainer = Instance.new("Frame")
        SearchContainer.Name = GenerateSafeName("Search")
        SearchContainer.Size = UDim2.new(1, -10, 0, 26)
        SearchContainer.Position = UDim2.new(0, 5, 0, 5)
        SearchContainer.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(230, 235, 245) or Color3.fromRGB(18, 20, 26)
        SearchContainer.BackgroundTransparency = 0.1
        SearchContainer.BorderSizePixel = 0
        SearchContainer.ZIndex = 502
        SearchContainer.Visible = isSearchable
        SearchContainer.Parent = DropdownContent

        local SearchCorner = Instance.new("UICorner")
        SearchCorner.CornerRadius = UDim.new(0, 6)
        SearchCorner.Parent = SearchContainer

        local SearchIcon = Instance.new("ImageLabel")
        SearchIcon.Name = GenerateSafeName("Icon")
        SearchIcon.Size = UDim2.new(0, 14, 0, 14)
        SearchIcon.Position = UDim2.new(0, 6, 0.5, -7)
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.Image = "rbxassetid://6031154871"
        SearchIcon.ImageColor3 = Window.CurrentTheme.SubText
        SearchIcon.ZIndex = 503
        SearchIcon.Parent = SearchContainer

        local SearchInput = Instance.new("TextBox")
        SearchInput.Name = GenerateSafeName("Input")
        SearchInput.Size = UDim2.new(1, -26, 1, 0)
        SearchInput.Position = UDim2.new(0, 24, 0, 0)
        SearchInput.BackgroundTransparency = 1
        SearchInput.FontFace = FontMichromaRegular
        SearchInput.PlaceholderText = "Search..."
        SearchInput.PlaceholderColor3 = Window.CurrentTheme.SubText
        SearchInput.Text = ""
        SearchInput.TextColor3 = Window.CurrentTheme.Text
        SearchInput.TextSize = 11
        SearchInput.TextXAlignment = Enum.TextXAlignment.Left
        SearchInput.ClearTextOnFocus = false
        SearchInput.ZIndex = 503
        SearchInput.Parent = SearchContainer

        local InnerScroll = Instance.new("ScrollingFrame")
        InnerScroll.Name = GenerateSafeName("Scroll")
        InnerScroll.Size = isSearchable and UDim2.new(1, -10, 1, -41) or UDim2.new(1, -10, 1, -10)
        InnerScroll.Position = isSearchable and UDim2.new(0, 5, 0, 36) or UDim2.new(0, 5, 0, 5)
        InnerScroll.BackgroundTransparency = 1
        InnerScroll.BorderSizePixel = 0
        InnerScroll.ScrollBarThickness = 3
        InnerScroll.ZIndex = 502
        InnerScroll.Parent = DropdownContent

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.Parent = InnerScroll

        local selectedOption = defaultOption
        local isExpanded = false
        local dropObj = nil

        local function UpdateDropdownPos()
            if not DropdownFrame or not DropdownFrame.Parent then return end
            local overlay = Window.DropdownOverlay or MainContainer
            if not overlay then return end

            local scale = (UIScaleConstraint and UIScaleConstraint.Scale) or 1
            if scale <= 0 then scale = 1 end

            local fPos = DropdownFrame.AbsolutePosition
            local oPos = overlay.AbsolutePosition
            local fSize = DropdownFrame.AbsoluteSize

            local relX = (fPos.X - oPos.X) / scale
            local relY = ((fPos.Y - oPos.Y) / scale) + (fSize.Y / scale) + 4
            local width = fSize.X / scale

            DropdownContent.Position = UDim2.new(0, relX, 0, relY)
            return width
        end

        local function CloseDropdown()
            if not isExpanded then return end
            isExpanded = false
            if Window.ActiveDropdown == dropObj then
                Window.ActiveDropdown = nil
            end
            TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0}):Play()
            local scale = (UIScaleConstraint and UIScaleConstraint.Scale) or 1
            if scale <= 0 then scale = 1 end
            local curWidth = DropdownContent.AbsoluteSize.X / scale
            local t = TweenService:Create(DropdownContent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, curWidth, 0, 0)
            })
            t:Play()
            t.Completed:Connect(function()
                if not isExpanded then
                    DropdownContent.Visible = false
                end
            end)
        end

        local currentFilter = ""
        local function RefreshOptions(newOptions, filterText)
            options = newOptions or options
            if filterText ~= nil then
                currentFilter = tostring(filterText):lower()
            end
            for _, child in ipairs(InnerScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            for idx, opt in ipairs(options) do
                local optStr = tostring(opt)
                if currentFilter == "" or optStr:lower():find(currentFilter, 1, true) then
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Name = GenerateSafeName("Item")
                    ItemBtn.Size = UDim2.new(1, -6, 0, 34)
                    ItemBtn.BackgroundColor3 = (opt == selectedOption) and Window.CurrentTheme.ButtonBG or Window.CurrentTheme.AccentBG
                    ItemBtn.BackgroundTransparency = 0.1
                    ItemBtn.FontFace = FontMichromaRegular
                    ItemBtn.RichText = true
                    ItemBtn.Text = optStr
                    ItemBtn.TextColor3 = Window.CurrentTheme.Text
                    ItemBtn.TextSize = 13
                    ItemBtn.ZIndex = 503
                    ItemBtn.Parent = InnerScroll

                    local ItemCorner = Instance.new("UICorner")
                    ItemCorner.CornerRadius = UDim.new(0, 6)
                    ItemCorner.Parent = ItemBtn

                    ItemBtn.MouseButton1Click:Connect(function()
                        PlayClickSFX()
                        selectedOption = opt
                        local newDisplay = (title and title ~= "") and (title .. ": " .. selectedOption) or selectedOption
                        TitleText.Text = newDisplay
                        
                        CloseDropdown()

                        if onSelect then onSelect(selectedOption) end
                    end)
                end
            end
            InnerScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end

        TrackConn(SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            RefreshOptions(options, SearchInput.Text)
        end))

        RefreshOptions(options)

        local function OpenDropdown()
            if Window.ActiveDropdown and Window.ActiveDropdown ~= dropObj then
                pcall(function() Window.ActiveDropdown.Close() end)
            end
            Window.ActiveDropdown = dropObj
            isExpanded = true

            if DropdownContent.Parent ~= (Window.DropdownOverlay or MainContainer) then
                DropdownContent.Parent = (Window.DropdownOverlay or MainContainer)
            end

            if isSearchable then
                SearchInput.Text = ""
                RefreshOptions(options, "")
            end

            local scale = (UIScaleConstraint and UIScaleConstraint.Scale) or 1
            if scale <= 0 then scale = 1 end
            local width = UpdateDropdownPos() or (DropdownFrame.AbsoluteSize.X / scale)
            local extraH = isSearchable and 36 or 0
            local targetHeight = math.clamp(#options * 39 + 15 + extraH, 45 + extraH, 220 + extraH)

            DropdownContent.Size = UDim2.new(0, width, 0, 0)
            DropdownContent.Visible = true

            TweenService:Create(ArrowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 180}):Play()
            TweenService:Create(DropdownContent, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, width, 0, targetHeight)
            }):Play()
        end

        TrackConn(HeaderTrigger.MouseButton1Click:Connect(function()
            PlayClickSFX()
            if isExpanded then
                CloseDropdown()
            else
                OpenDropdown()
            end
        end))

        -- Auto close when scrolling the tab
        local scrollParent = parent
        while scrollParent and not scrollParent:IsA("ScrollingFrame") and scrollParent ~= MainContainer do
            scrollParent = scrollParent.Parent
        end
        if scrollParent and scrollParent:IsA("ScrollingFrame") then
            TrackConn(scrollParent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if isExpanded then
                    CloseDropdown()
                end
            end))
        end

        TrackConn(DropdownFrame.AncestryChanged:Connect(function(_, newParent)
            if not newParent then
                pcall(function() DropdownContent:Destroy() end)
            end
        end))

        dropObj = {
            Frame = DropdownFrame,
            Content = DropdownContent,
            InnerScroll = InnerScroll,
            TitleText = TitleText,
            ArrowIcon = ArrowIcon,
            Close = CloseDropdown,
            Open = OpenDropdown,
            GetSelected = function() return selectedOption end,
            SetSelected = function(opt, triggerCallback)
                selectedOption = opt
                local newDisplay = (title and title ~= "") and (title .. ": " .. selectedOption) or selectedOption
                TitleText.Text = newDisplay
                RefreshOptions(options)
                if triggerCallback and onSelect then onSelect(selectedOption) end
            end,
            RefreshOptions = RefreshOptions,
            SetOptions = function(selfOrOpts, maybeOpts)
                local newOpts = (type(selfOrOpts) == "table" and selfOrOpts ~= dropObj) and selfOrOpts or maybeOpts or {}
                options = newOpts
                RefreshOptions(options)
                return dropObj
            end,
            AddOption = function(selfOrOpt, maybeOpt)
                local newOpt = (type(selfOrOpt) == "string" or type(selfOrOpt) == "number") and selfOrOpt or maybeOpt
                if newOpt then
                    table.insert(options, tostring(newOpt))
                    RefreshOptions(options)
                end
                return dropObj
            end,
            RemoveOption = function(selfOrOpt, maybeOpt)
                local optToRemove = (type(selfOrOpt) == "string" or type(selfOrOpt) == "number") and tostring(selfOrOpt) or tostring(maybeOpt or "")
                for i, v in ipairs(options) do
                    if tostring(v) == optToRemove then
                        table.remove(options, i)
                        break
                    end
                end
                if tostring(selectedOption) == optToRemove then
                    selectedOption = options[1] or ""
                    local newDisplay = (title and title ~= "") and (title .. ": " .. tostring(selectedOption or "")) or tostring(selectedOption or "")
                    TitleText.Text = newDisplay
                end
                RefreshOptions(options)
                return dropObj
            end,
            ClearOptions = function()
                options = {}
                selectedOption = ""
                local newDisplay = (title and title ~= "") and (title .. ": ") or ""
                TitleText.Text = newDisplay
                RefreshOptions(options)
                return dropObj
            end,
            SearchContainer = SearchContainer,
            SearchInput = SearchInput,
            WithSearch = function(self, enabled)
                isSearchable = (enabled ~= false)
                SearchContainer.Visible = isSearchable
                if isSearchable then
                    InnerScroll.Position = UDim2.new(0, 5, 0, 36)
                    InnerScroll.Size = UDim2.new(1, -10, 1, -41)
                else
                    InnerScroll.Position = UDim2.new(0, 5, 0, 5)
                    InnerScroll.Size = UDim2.new(1, -10, 1, -10)
                end
                return dropObj
            end,
            RefreshTheme = function(theme)
                DropdownFrame.BackgroundColor3 = theme.CardBG
                TitleText.TextColor3 = theme.Text
                ArrowIcon.ImageColor3 = theme.Text
                DropdownContent.BackgroundColor3 = theme.CardBG
                InnerScroll.ScrollBarImageColor3 = theme.Divider
                if SearchContainer then
                    SearchContainer.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(230, 235, 245) or Color3.fromRGB(18, 20, 26)
                end
                if SearchInput then
                    SearchInput.TextColor3 = theme.Text
                    SearchInput.PlaceholderColor3 = theme.SubText
                end
                RefreshOptions(options)
            end
        }

        dropObj.WithCallback = function(self, cb)
            onSelect = cb
            return self
        end
        dropObj.WithTooltip = function(self, tt)
            if Window.AttachTooltip and DropdownFrame then
                Window:AttachTooltip(DropdownFrame, tt)
            end
            return self
        end
        dropObj.WithSaveKey = function(self, key)
            if key and key ~= "" then
                self.SaveKey = key
                Window.RegisteredDropdowns[key] = self
            end
            return self
        end
        dropObj.WithSelected = function(self, opt, triggerCb)
            self.SetSelected(opt, triggerCb)
            return self
        end
        dropObj.WithOptions = function(self, newOpts)
            options = newOpts or {}
            self.RefreshOptions(options)
            return self
        end

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
        SectionFrame.Name = GenerateSafeName("ConfigSection")
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

        -- 4. Row 2: Left = Overwrite config, Right = Load config
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

        -- 5. Row 3: Config share — paste JSON textbox + Export/Import buttons
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

        -- Paste box label
        local PasteLabel = Instance.new("TextLabel")
        PasteLabel.Name = GenerateSafeName("Label")
        PasteLabel.Size = UDim2.new(1, 0, 0, 16)
        PasteLabel.LayoutOrder = 1
        PasteLabel.BackgroundTransparency = 1
        PasteLabel.FontFace = FontMichromaRegular
        PasteLabel.Text = "Paste config JSON here to import:"
        PasteLabel.TextColor3 = Window.CurrentTheme.SubText
        PasteLabel.TextSize = 11
        PasteLabel.TextXAlignment = Enum.TextXAlignment.Left
        PasteLabel.ZIndex = 5
        PasteLabel.Parent = ShareSection

        -- Multiline paste input box
        local PasteBoxFrame = Instance.new("Frame")
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

        local PasteBoxStroke = Instance.new("UIStroke")
        PasteBoxStroke.Thickness = 1
        PasteBoxStroke.Transparency = 0.6
        PasteBoxStroke.Color = Window.CurrentTheme.Divider or Color3.fromRGB(80, 85, 100)
        PasteBoxStroke.Parent = PasteBoxFrame

        local PasteInput = Instance.new("TextBox")
        PasteInput.Name = GenerateSafeName("Input")
        PasteInput.Size = UDim2.new(1, -16, 1, -8)
        PasteInput.Position = UDim2.new(0, 8, 0, 4)
        PasteInput.BackgroundTransparency = 1
        PasteInput.BorderSizePixel = 0
        PasteInput.FontFace = FontMichromaRegular
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

        -- Export + Import button row
        local ShareBtnRow = Instance.new("Frame")
        ShareBtnRow.Name = GenerateSafeName("BtnRow")
        ShareBtnRow.Size = UDim2.new(1, 0, 0, 36)
        ShareBtnRow.LayoutOrder = 3
        ShareBtnRow.BackgroundTransparency = 1
        ShareBtnRow.BorderSizePixel = 0
        ShareBtnRow.ZIndex = 4
        ShareBtnRow.Parent = ShareSection

        -- "Copy Export" — writes to clipboard so user can share
        Window:CreateMDButtonLong(ShareBtnRow, UDim2.new(0, 0, 0, 0), UDim2.new(0.485, -4, 1, 0), "Copy Config", function()
            local jsonString = Window:ExportConfigToClipboard()
            if jsonString then
                -- Also populate the paste box so user can see/edit what was exported
                PasteInput.Text = jsonString
            end
        end)

        -- "Import" — reads from the textbox, NOT getclipboard
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



        -- 6. Row 4: Single Long Button for Autoload config
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
    if Library.ActiveLoadingUI and Library.ActiveLoadingUI.Parent then
        pcall(function() Library.ActiveLoadingUI:Destroy() end)
    end

    local LoadingUI = Instance.new("ScreenGui")
    LoadingUI.Name = GenerateSafeName("UI")
    LoadingUI.ResetOnSpawn = false
    LoadingUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadingUI.DisplayOrder = 100
    ProtectGui(LoadingUI)
    LoadingUI.Parent = ParentGui
    Library.ActiveLoadingUI = LoadingUI
    table.insert(Library.ActiveGuis, LoadingUI)

    local LoadCenterFrame = Instance.new("Frame")
    LoadCenterFrame.Name = GenerateSafeName("Center")
    LoadCenterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadCenterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadCenterFrame.Size = UDim2.new(0, 360, 0, 140)
    LoadCenterFrame.BackgroundTransparency = 1
    LoadCenterFrame.ClipsDescendants = false
    LoadCenterFrame.ZIndex = 100
    LoadCenterFrame.Parent = LoadingUI

    local LoadScale = Instance.new("UIScale")
    LoadScale.Name = GenerateSafeName("Scale")
    LoadScale.Scale = 1
    LoadScale.Parent = LoadCenterFrame

    local Loadbarempty = Instance.new("Frame")
    Loadbarempty.Name = GenerateSafeName("BarEmpty")
    Loadbarempty.Size = UDim2.new(0, 326, 0, 23)
    Loadbarempty.Position = UDim2.new(0.5, -163, 0.5, -5)
    Loadbarempty.BackgroundColor3 = Color3.fromRGB(106, 106, 106)
    Loadbarempty.BackgroundTransparency = 0.15
    Loadbarempty.BorderSizePixel = 0
    Loadbarempty.ClipsDescendants = true
    Loadbarempty.ZIndex = 101
    Loadbarempty.Parent = LoadCenterFrame

    local LoadbaremptyCorner = Instance.new("UICorner")
    LoadbaremptyCorner.CornerRadius = UDim.new(0, 8)
    LoadbaremptyCorner.Parent = Loadbarempty

    local LoadbaremptyStroke = Instance.new("UIStroke")
    LoadbaremptyStroke.Name = GenerateSafeName("Stroke")
    LoadbaremptyStroke.Color = Color3.fromRGB(179, 179, 179)
    LoadbaremptyStroke.Thickness = 1.5
    LoadbaremptyStroke.Transparency = 0
    LoadbaremptyStroke.Parent = Loadbarempty

    local LoadbarBGImage = Instance.new("ImageLabel")
    LoadbarBGImage.Name = GenerateSafeName("BarBG")
    LoadbarBGImage.Size = UDim2.new(1, 0, 1, 0)
    LoadbarBGImage.Position = UDim2.new(0, 0, 0, 0)
    LoadbarBGImage.BackgroundTransparency = 1
    LoadbarBGImage.Image = "rbxassetid://139688890190075"
    LoadbarBGImage.ScaleType = Enum.ScaleType.Tile
    LoadbarBGImage.TileSize = UDim2.new(0, 25, 1, 0)
    LoadbarBGImage.ImageTransparency = 0.4
    LoadbarBGImage.ZIndex = 101
    LoadbarBGImage.Parent = Loadbarempty

    AddUIShadow(Loadbarempty, 20, 0.5, Color3.fromRGB(255, 255, 255))

    local Loadbar = Instance.new("Frame")
    Loadbar.Name = GenerateSafeName("Bar")
    Loadbar.Size = UDim2.new(0, 0, 1, 0)
    Loadbar.Position = UDim2.new(0, 0, 0, 0)
    Loadbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Loadbar.BackgroundTransparency = 0.15
    Loadbar.BorderSizePixel = 0
    Loadbar.ClipsDescendants = true
    Loadbar.ZIndex = 102
    Loadbar.Parent = Loadbarempty

    local LoadbarCorner = Instance.new("UICorner")
    LoadbarCorner.CornerRadius = UDim.new(0, 8)
    LoadbarCorner.Parent = Loadbar

    local Loadingtext = Instance.new("TextLabel")
    Loadingtext.Name = GenerateSafeName("LoadingText")
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
    percloaded.Name = GenerateSafeName("PercLoaded")
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
        pct = math.clamp(pct or 0, 0, 100)
        percloaded.Text = string.format("%d %%", math.floor(pct))
        if statusText then
            Loadingtext.Text = statusText
        end
        local targetWidth = math.floor(326 * (pct / 100))
        TweenService:Create(Loadbar, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, targetWidth, 1, 0)
        }):Play()
    end

    function Window:FinishLoading()
        if isFinishedLoading then return end
        isFinishedLoading = true

        Window:UpdateLoadingProgress(100, "Loaded!")
        task.wait(0.25)
        if LoadScale and LoadScale.Parent then
            local shrinkTween = TweenService:Create(LoadScale, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Scale = 0
            })
            shrinkTween:Play()
            pcall(function() shrinkTween.Completed:Wait() end)
        end
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

        task.delay(1.5, function()
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

    local function BrightenColor(col, factor)
        if not col then return col end
        local h, s, v = col:ToHSV()
        return Color3.fromHSV(h, math.clamp(s * 0.96, 0, 1), math.clamp(v * (factor or 1.05), 0, 1))
    end

    -- Ultra-Smooth Button Generator Helper
    function Window:CreateMDButton(parent, size, position, text, onClick, showArrow)
        parent = ResolveParent(parent)
        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = GenerateSafeName("BtnFrame")
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

        -- UIScale drives hover/press scaling so UIStroke naturally
        -- scales with the frame. AnchorPoint 0.5,0.5 keeps the button centered while scaling.
        BtnFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        BtnFrame.Position = UDim2.new(
            (position or UDim2.new(0,0,0,0)).X.Scale + 0.5 * (size or UDim2.new(0,260,0,62)).X.Scale,
            (position or UDim2.new(0,0,0,0)).X.Offset + math.floor((size or UDim2.new(0,260,0,62)).X.Offset * 0.5),
            (position or UDim2.new(0,0,0,0)).Y.Scale + 0.5 * (size or UDim2.new(0,260,0,62)).Y.Scale,
            (position or UDim2.new(0,0,0,0)).Y.Offset + math.floor((size or UDim2.new(0,260,0,62)).Y.Offset * 0.5)
        )

        local BtnScale = Instance.new("UIScale")
        BtnScale.Scale = 1.0
        BtnScale.Parent = BtnFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = GenerateSafeName("Stroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0
        Stroke.Parent = BtnFrame

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = GenerateSafeName("Text")
        MDTextFolder.Parent = BtnFrame

        local BtnText = Instance.new("TextLabel")
        BtnText.Name = GenerateSafeName("btnTitle")
        BtnText.BackgroundTransparency = 1
        BtnText.FontFace = FontMichromaBold
        BtnText.RichText = true
        BtnText.Text = text or "Button"
        BtnText.TextColor3 = Window.CurrentTheme.Text
        BtnText.TextScaled = false
        BtnText.TextSize = 14
        BtnText.TextWrapped = true
        BtnText.ZIndex = 11
        BtnText.Parent = MDTextFolder

        local ArrowIcon = nil
        if showArrow then
            BtnText.Size = UDim2.new(1, -30, 1, 0)
            BtnText.Position = UDim2.new(0, 8, 0, 0)
            BtnText.TextXAlignment = Enum.TextXAlignment.Left

            ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Name = GenerateSafeName("Arrow")
            ArrowIcon.Size = UDim2.new(0, 18, 0, 18)
            ArrowIcon.Position = UDim2.new(1, -23, 0.5, -9)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://2418686949"
            ArrowIcon.ImageColor3 = Window.CurrentTheme.Text
            ArrowIcon.ZIndex = 11
            ArrowIcon.Parent = BtnFrame
        else
            BtnText.Size = UDim2.new(1, -6, 1, 0)
            BtnText.Position = UDim2.new(0, 3, 0, 0)
            BtnText.TextXAlignment = Enum.TextXAlignment.Center
            BtnText.TextYAlignment = Enum.TextYAlignment.Center
        end

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = GenerateSafeName("Trigger")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 12
        ClickBtn.Parent = BtnFrame

        local _hoverActive = false
        local _pressActive = false

        TrackConn(ClickBtn.MouseEnter:Connect(function()
            _hoverActive = true
            PlayHoverSFX()
            local baseBg = Window.CurrentTheme.ButtonBG
            local hoverBg = BrightenColor(baseBg, 1.05)
            TweenService:Create(Stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 2.0}):Play()
            TweenService:Create(BtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1.02}):Play()
            TweenService:Create(BtnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = hoverBg}):Play()
        end))

        TrackConn(ClickBtn.MouseLeave:Connect(function()
            _hoverActive = false
            _pressActive = false
            local baseBg = Window.CurrentTheme.ButtonBG
            TweenService:Create(Stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 1.2}):Play()
            TweenService:Create(BtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1.0}):Play()
            TweenService:Create(BtnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = baseBg}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Down:Connect(function()
            _pressActive = true
            PlayClickSFX()
            TweenService:Create(BtnScale, TweenInfo.new(0.09, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Up:Connect(function()
            if not _pressActive then return end
            _pressActive = false
            -- spring back: Back Out gives +1% overshoot then settles at 100% (or 102% if still hovering)
            local targetScale = _hoverActive and 1.02 or 1.0
            TweenService:Create(BtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
            -- fire click on up, not on down
            if onClick then
                pcall(onClick)
            end
        end))



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
        BadgeContainer.Name = GenerateSafeName("Badge")
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
        BadgeStroke.Name = GenerateSafeName("Stroke")
        BadgeStroke.Thickness = 1.1
        BadgeStroke.Color = Color3.fromRGB(255, 255, 255)
        BadgeStroke.Transparency = 0.75
        BadgeStroke.Parent = BadgeContainer

        local BadgeText = Instance.new("TextLabel")
        BadgeText.Name = GenerateSafeName("KeyLabel")
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
        TriggerBtn.Name = GenerateSafeName("Trigger")
        TriggerBtn.Size = UDim2.new(1, 0, 1, 0)
        TriggerBtn.BackgroundTransparency = 1
        TriggerBtn.Text = ""
        TriggerBtn.ZIndex = 17
        TriggerBtn.Parent = BadgeContainer

        -- Close icon that appears when editing to delete/clear bind
        local DeleteBtn = Instance.new("ImageButton")
        DeleteBtn.Name = GenerateSafeName("Delete")
        DeleteBtn.Size = UDim2.new(0, 14, 0, 14)
        DeleteBtn.Position = UDim2.new(1, -15, 0.5, -7)
        DeleteBtn.BackgroundTransparency = 1
        DeleteBtn.Image = "rbxassetid://132261474823036"
        DeleteBtn.ImageColor3 = Window.CurrentTheme.Text
        DeleteBtn.ZIndex = 18
        DeleteBtn.Visible = false
        DeleteBtn.Parent = BadgeContainer

        local badgeData = {
            Container = BadgeContainer,
            Badge = BadgeContainer,
            Frame = BadgeContainer,
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
        parent = ResolveParent(parent)
        size = size or UDim2.new(0, 56, 0, 26)

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = GenerateSafeName("Toggle")
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
        Stroke.Name = GenerateSafeName("Stroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.2
        Stroke.Transparency = 0
        Stroke.Parent = ToggleFrame

        local KnobFrame = Instance.new("Frame")
        KnobFrame.Name = GenerateSafeName("Knob")
        KnobFrame.Size = UDim2.new(0, 22, 0, 22)
        KnobFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        KnobFrame.Position = initialState and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0)
        KnobFrame.Rotation = initialState and 0 or 225
        KnobFrame.BackgroundTransparency = 1
        KnobFrame.ZIndex = 11
        KnobFrame.Parent = ToggleFrame

        local BaseCircle = Instance.new("ImageLabel")
        BaseCircle.Name = GenerateSafeName("Knob")
        BaseCircle.Size = UDim2.new(1, 0, 1, 0)
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ImageColor3 = initialState and Color3.fromRGB(255, 255, 255) or Window.CurrentTheme.ButtonBG
        BaseCircle.ZIndex = 11
        BaseCircle.Parent = KnobFrame

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = GenerateSafeName("Overlay")
        OverlayCircle.Size = UDim2.new(1, 0, 1, 0)
        OverlayCircle.BackgroundTransparency = 1
        OverlayCircle.Image = "rbxassetid://100354746235648"
        OverlayCircle.ImageColor3 = initialState and Window.CurrentTheme.ButtonBG or Color3.fromRGB(255, 255, 255)
        OverlayCircle.ZIndex = 12
        OverlayCircle.Parent = KnobFrame

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = GenerateSafeName("Trigger")
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
            local targetBaseColor = isToggled and Color3.fromRGB(255, 255, 255) or Window.CurrentTheme.ButtonBG
            local targetOverlayColor = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(255, 255, 255)

            TweenService:Create(KnobFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetKnobPos,
                Rotation = targetRotation
            }):Play()
            TweenService:Create(BaseCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = targetBaseColor}):Play()
            TweenService:Create(OverlayCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = targetOverlayColor}):Play()
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
            BaseCircle = BaseCircle,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            GetState = function() return isToggled end,
            SetState = function(state, triggerCallback)
                PerformToggle(state, triggerCallback)
            end,
            RefreshTheme = function(theme)
                local isTog = isToggled
                ToggleFrame.BackgroundColor3 = isTog and theme.ButtonBG or ((theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))
                BaseCircle.ImageColor3 = isTog and Color3.fromRGB(255, 255, 255) or theme.ButtonBG
                OverlayCircle.ImageColor3 = isTog and theme.ButtonBG or Color3.fromRGB(255, 255, 255)
                if toggleData.Keybind and toggleData.Keybind.Container then
                    toggleData.Keybind.Container.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(24, 26, 34)
                    if toggleData.Keybind.Label then toggleData.Keybind.Label.TextColor3 = theme.Text end
                    if toggleData.Keybind.DeleteBtn then toggleData.Keybind.DeleteBtn.ImageColor3 = theme.Text end
                end
            end
        }

        local keybindProp = nil
        if type(keybindConfig) == "table" then
            keybindProp = keybindConfig.Bind or keybindConfig.Keybind or keybindConfig.DefaultBind or keybindConfig.Key or keybindConfig.KeyBind or keybindConfig.DefaultKey
            if keybindProp == nil and keybindConfig.Default ~= nil and typeof(keybindConfig.Default) ~= "boolean" then
                keybindProp = keybindConfig.Default
            end
        elseif keybindConfig ~= nil and keybindConfig ~= false and keybindConfig ~= true then
            keybindProp = keybindConfig
        end

        if keybindProp then
            local defaultKey = keybindProp
            local pos = position or UDim2.new(0, 0, 0, 0)
            local badgePos = UDim2.new(pos.X.Scale, pos.X.Offset - 42, pos.Y.Scale, pos.Y.Offset + 2)
            toggleData.Keybind = Window:CreateKeybindBadge(parent, badgePos, UDim2.new(0, 36, 0, 22), defaultKey, function()
                toggleData.SetState(not isToggled, true)
            end, toggleName)
        end

        Window.RegisteredToggles[toggleName] = toggleData
        table.insert(Window.RegisteredMDToggles, toggleData)
        return toggleData
    end

    function Window:CreateMDSlider(parent, position, size, minVal, maxVal, defaultVal, onValueChange, identifier, sliderOptions)
        parent = ResolveParent(parent)
        size = size or UDim2.new(0, 210, 0, 14)
        minVal = minVal or 0
        maxVal = maxVal or 100

        local showValue = false
        local valueFormat = "number"
        local suffix = ""
        local prefix = ""
        local increment = 1
        local precision = 0

        local function GetDecimalPlaces(num)
            local s = tostring(num)
            local dot = s:find("%.")
            if dot then return #s - dot end
            return 0
        end

        if type(sliderOptions) == "table" then
            showValue = (sliderOptions.ShowValue ~= false)
            valueFormat = sliderOptions.ValueFormat or (sliderOptions.IsPercent and "percent") or (sliderOptions.Suffix == "%" and "percent") or "number"
            suffix = sliderOptions.Suffix or (valueFormat == "percent" and "%" or "")
            prefix = sliderOptions.Prefix or ""
            increment = tonumber(sliderOptions.Increment or sliderOptions.increment or sliderOptions.Step or sliderOptions.step or sliderOptions.StepAmount or sliderOptions.IncrementAmount) or 1
            if increment <= 0 then increment = 1 end
            precision = tonumber(sliderOptions.Precision or sliderOptions.precision or sliderOptions.Decimals or sliderOptions.decimals) or GetDecimalPlaces(increment)
        elseif type(sliderOptions) == "number" then
            increment = sliderOptions > 0 and sliderOptions or 1
            precision = GetDecimalPlaces(increment)
        elseif type(sliderOptions) == "string" then
            showValue = true
            suffix = sliderOptions
            if suffix == "%" then valueFormat = "percent" end
        elseif sliderOptions == true then
            showValue = true
        end

        local function RoundToPrecision(val, prec)
            if (prec or 0) <= 0 then
                return math.floor(val + 0.5)
            else
                local mult = 10 ^ prec
                return math.floor((val * mult) + 0.5) / mult
            end
        end

        local function SnapToIncrement(val)
            if increment and increment > 0 then
                local steps = math.floor(((val - minVal) / increment) + 0.5)
                local snapped = minVal + (steps * increment)
                snapped = math.clamp(snapped, minVal, maxVal)
                return RoundToPrecision(snapped, precision)
            end
            return RoundToPrecision(val, precision)
        end

        defaultVal = SnapToIncrement(math.clamp(defaultVal or minVal or 0, minVal, maxVal))

        local TrackFrame = Instance.new("Frame")
        TrackFrame.Name = GenerateSafeName("Track")
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

        local initialPct = (maxVal > minVal) and math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1) or 0
        local knobSize = 22

        local function GetFormattedValue(val, pct)
            if valueFormat == "percent" or valueFormat == "%" or suffix == "%" then
                local pctVal = (precision > 0) and RoundToPrecision(pct * 100, precision) or math.floor(pct * 100 + 0.5)
                local strPct = (precision > 0) and string.format("%." .. precision .. "f", pctVal) or tostring(pctVal)
                return prefix .. strPct .. "%"
            else
                local strVal = (precision > 0) and string.format("%." .. precision .. "f", val) or tostring(val)
                return prefix .. strVal .. suffix
            end
        end

        local ValueLabel = nil
        if showValue then
            ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Size = UDim2.new(0, 60, 0, 14)
            ValueLabel.Position = UDim2.new(1, -64, 0, -16)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.FontFace = FontMichromaRegular
            ValueLabel.TextColor3 = Window.CurrentTheme.Text
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
            ValueLabel.Text = GetFormattedValue(defaultVal, initialPct)
            ValueLabel.ZIndex = 14
            ValueLabel.Parent = TrackFrame
        end

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
        BaseCircle.Name = GenerateSafeName("Knob")
        BaseCircle.Size = UDim2.new(1, 0, 1, 0)
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ZIndex = 12
        BaseCircle.Parent = HandleFrame

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = GenerateSafeName("Overlay")
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
        local displayedVal = defaultVal
        local counterThread = nil
        local sliderData = nil

        local function AnimateValueLabel(targetVal, targetPct)
            local lbl = (sliderData and sliderData.ValueLabel) or ValueLabel
            if not lbl then return end
            if counterThread then
                task.cancel(counterThread)
                counterThread = nil
            end
            counterThread = task.spawn(function()
                local startVal = displayedVal
                local diff = targetVal - startVal
                if math.abs(diff) <= (0.01 * increment) then
                    displayedVal = targetVal
                    lbl.Text = GetFormattedValue(targetVal, targetPct)
                    return
                end
                local duration = 0.12
                local startTime = os.clock()
                while true do
                    local elapsed = os.clock() - startTime
                    local alpha = math.clamp(elapsed / duration, 0, 1)
                    local eased = 1 - math.pow(1 - alpha, 3)
                    displayedVal = SnapToIncrement(startVal + (diff * eased))
                    local curPct = (maxVal > minVal) and ((displayedVal - minVal) / (maxVal - minVal)) or 0
                    lbl.Text = GetFormattedValue(displayedVal, curPct)
                    if alpha >= 1 then break end
                    task.wait()
                end
                displayedVal = targetVal
                lbl.Text = GetFormattedValue(targetVal, targetPct)
            end)
        end

        local function UpdateSlider(inputPos, isFirstClick)
            local trackAbsPos = TrackFrame.AbsolutePosition.X
            local trackAbsSize = TrackFrame.AbsoluteSize.X
            if trackAbsSize <= 0 then return end
            local rawPct = math.clamp((inputPos - trackAbsPos) / trackAbsSize, 0, 1)
            local rawVal = minVal + (rawPct * (maxVal - minVal))
            local snappedVal = SnapToIncrement(rawVal)
            local pct = (maxVal > minVal) and math.clamp((snappedVal - minVal) / (maxVal - minVal), 0, 1) or 0

            FilledPart.Size = UDim2.new(pct, 0, 1, 0)
            HandleFrame.Position = UDim2.new(pct, 0, 0.5, 0)

            if snappedVal ~= currentVal or isFirstClick then
                currentVal = snappedVal
                AnimateValueLabel(currentVal, pct)
                if onValueChange then
                    pcall(onValueChange, currentVal, pct)
                end
            end
        end

        TrackConn(Trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                UpdateSlider(input.Position.X, true)
            end
        end))

        TrackConn(UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input.Position.X, false)
            end
        end))

        TrackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end))

        local sliderName = identifier or ("Slider_" .. (#Window.RegisteredMDSliders + 1))
        sliderData = {
            Name = sliderName,
            Track = TrackFrame,
            FilledPart = FilledPart,
            Overlay = OverlayCircle,
            Stroke = Stroke,
            ValueLabel = ValueLabel,
            GetValue = function() return currentVal end,
            GetFormattedValue = function(val, pct)
                val = val or currentVal
                pct = pct or ((maxVal > minVal) and ((val - minVal) / (maxVal - minVal)) or 0)
                return GetFormattedValue(val, pct)
            end,
            GetIncrement = function() return increment end,
            SetIncrement = function(newInc, newPrec)
                increment = tonumber(newInc) or increment
                if increment <= 0 then increment = 1 end
                if newPrec ~= nil then
                    precision = tonumber(newPrec) or 0
                else
                    precision = GetDecimalPlaces(increment)
                end
                sliderData.SetValue(currentVal, false)
            end,
            SetValue = function(val, triggerCallback)
                val = SnapToIncrement(math.clamp(val, minVal, maxVal))
                currentVal = val
                local pct = (maxVal > minVal) and math.clamp((val - minVal) / (maxVal - minVal), 0, 1) or 0
                FilledPart.Size = UDim2.new(pct, 0, 1, 0)
                HandleFrame.Position = UDim2.new(pct, 0, 0.5, 0)
                AnimateValueLabel(currentVal, pct)
                if triggerCallback and onValueChange then
                    pcall(onValueChange, currentVal, pct)
                end
            end,
            SetSuffix = function(newSuffix)
                suffix = tostring(newSuffix or "")
                if suffix == "%" then
                    valueFormat = "percent"
                elseif valueFormat == "percent" and suffix ~= "%" then
                    valueFormat = "number"
                end
                local pct = (maxVal > minVal) and ((currentVal - minVal) / (maxVal - minVal)) or 0
                if ValueLabel then
                    ValueLabel.Text = GetFormattedValue(currentVal, pct)
                end
            end,
            GetSuffix = function()
                return suffix
            end,
            SetPrefix = function(newPrefix)
                prefix = tostring(newPrefix or "")
                local pct = (maxVal > minVal) and ((currentVal - minVal) / (maxVal - minVal)) or 0
                if ValueLabel then
                    ValueLabel.Text = GetFormattedValue(currentVal, pct)
                end
            end,
            GetPrefix = function()
                return prefix
            end,
            SetPrecision = function(newPrec)
                precision = tonumber(newPrec) or precision
                local pct = (maxVal > minVal) and ((currentVal - minVal) / (maxVal - minVal)) or 0
                if ValueLabel then
                    ValueLabel.Text = GetFormattedValue(currentVal, pct)
                end
            end,
            GetPrecision = function()
                return precision
            end,
            SetValueFormat = function(format, newSuffix, newPrefix)
                valueFormat = format or valueFormat
                if newSuffix ~= nil then suffix = tostring(newSuffix) end
                if newPrefix ~= nil then prefix = tostring(newPrefix) end
                local pct = (maxVal > minVal) and ((currentVal - minVal) / (maxVal - minVal)) or 0
                if ValueLabel then
                    ValueLabel.Text = GetFormattedValue(currentVal, pct)
                end
            end,
            RefreshTheme = function(theme)
                TrackFrame.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(20, 22, 28)
                FilledPart.BackgroundColor3 = theme.ButtonBG
                OverlayCircle.ImageColor3 = theme.ButtonBG
                if ValueLabel then
                    ValueLabel.TextColor3 = theme.Text
                end
            end,
            WithCallback = function(self, cb)
                onValueChange = cb
                return self
            end,
            WithTooltip = function(self, tt)
                if Window.AttachTooltip and TrackFrame then
                    Window:AttachTooltip(TrackFrame, tt)
                end
                return self
            end,
            WithSaveKey = function(self, key)
                if key and key ~= "" then
                    Window.RegisteredSliders[key] = self
                end
                return self
            end,
            WithValue = function(self, val)
                self.SetValue(val, true)
                return self
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

        local ModalBackdrop = Instance.new("Frame")
        ModalBackdrop.Name = GenerateSafeName("Backdrop")
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.Position = UDim2.new(0, 0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 1
        ModalBackdrop.BorderSizePixel = 0
        ModalBackdrop.Active = false
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
        HeaderLabel.Active = true
        HeaderLabel.ZIndex = 82
        HeaderLabel.Parent = ModalCard

        AttachUniversalDrag(HeaderLabel, ModalCard)

        local CloseModalBtn = Instance.new("ImageButton")
        CloseModalBtn.Name = "CloseBtn"
        CloseModalBtn.Size = UDim2.new(0, 22, 0, 22)
        CloseModalBtn.Position = UDim2.new(1, -30, 0, 8)
        CloseModalBtn.BackgroundTransparency = 1
        CloseModalBtn.Image = "rbxassetid://132261474823036"
        CloseModalBtn.ImageColor3 = Window.CurrentTheme.Text or Color3.fromRGB(245, 245, 250)
        CloseModalBtn.ZIndex = 83
        CloseModalBtn.Parent = ModalCard

        TrackConn(CloseModalBtn.MouseEnter:Connect(PlayHoverSFX))

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


        ApplyBtn.MouseButton1Click:Connect(function()
            PlayClickSFX()
            if onColorSelected then
                pcall(onColorSelected, selectedColor)
            end
            CloseModal()
        end)

        -- Animate In (No dark background!)
        ModalBackdrop.BackgroundTransparency = 1
        TweenService:Create(ModalCard, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 290, 0, 310)
        }):Play()

        RefreshAll("init")
    end

    -- Lightweight Confirm Dialog (No dark background, follows theme)
    function Window:Confirm(titleOrOptions, message, onYes, onNo)
        local title, desc, yesText, noText
        if type(titleOrOptions) == "table" then
            title = titleOrOptions.Title or titleOrOptions.title or "Confirm"
            desc = titleOrOptions.Message or titleOrOptions.Description or titleOrOptions.text or message or "Are you sure?"
            yesText = titleOrOptions.ConfirmText or titleOrOptions.YesText or "Confirm"
            noText = titleOrOptions.CancelText or titleOrOptions.NoText or "Cancel"
            onYes = titleOrOptions.OnConfirm or titleOrOptions.onConfirm or onYes
            onNo = titleOrOptions.OnCancel or titleOrOptions.onCancel or onNo
        else
            title = titleOrOptions or "Confirm"
            desc = message or "Are you sure?"
            yesText = "Confirm"
            noText = "Cancel"
        end

        local ConfirmBackdrop = Instance.new("Frame")
        ConfirmBackdrop.Name = GenerateSafeName("Backdrop")
        ConfirmBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ConfirmBackdrop.Position = UDim2.new(0, 0, 0, 0)
        ConfirmBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ConfirmBackdrop.BackgroundTransparency = 1
        ConfirmBackdrop.BorderSizePixel = 0
        ConfirmBackdrop.Active = false
        ConfirmBackdrop.ZIndex = 120
        ConfirmBackdrop.Parent = ScriptUi

        local ModalCard = Instance.new("Frame")
        ModalCard.Name = "ConfirmModal"
        ModalCard.Size = UDim2.new(0, 320, 0, 150)
        ModalCard.AnchorPoint = Vector2.new(0.5, 0.5)
        ModalCard.Position = UDim2.new(0.5, 0, 0.5, 20)
        ModalCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        ModalCard.BackgroundTransparency = 0.02
        ModalCard.BorderSizePixel = 0
        ModalCard.ZIndex = 121
        ModalCard.Parent = ConfirmBackdrop

        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 10)
        ModalCorner.Parent = ModalCard

        local ModalStroke = Instance.new("UIStroke")
        ModalStroke.Thickness = 1.3
        ModalStroke.Color = Color3.fromRGB(255, 255, 255)
        ModalStroke.Transparency = 0.8
        ModalStroke.Parent = ModalCard

        AddUIShadow(ModalCard, 24, 0.55)

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -24, 0, 26)
        TitleLabel.Position = UDim2.new(0, 12, 0, 10)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.FontFace = FontMichromaBold
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Window.CurrentTheme.Text
        TitleLabel.TextSize = 13
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 122
        TitleLabel.Parent = ModalCard

        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(1, -24, 0, 52)
        DescLabel.Position = UDim2.new(0, 12, 0, 38)
        DescLabel.BackgroundTransparency = 1
        DescLabel.FontFace = FontMichromaRegular
        DescLabel.Text = desc
        DescLabel.TextColor3 = Window.CurrentTheme.SubText
        DescLabel.TextSize = 11
        DescLabel.TextWrapped = true
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextYAlignment = Enum.TextYAlignment.Top
        DescLabel.ZIndex = 122
        DescLabel.Parent = ModalCard

        local BtnRow = Instance.new("Frame")
        BtnRow.Size = UDim2.new(1, -24, 0, 32)
        BtnRow.Position = UDim2.new(0, 12, 1, -42)
        BtnRow.BackgroundTransparency = 1
        BtnRow.ZIndex = 122
        BtnRow.Parent = ModalCard

        local CancelBtn = Instance.new("TextButton")
        CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
        CancelBtn.Position = UDim2.new(0, 0, 0, 0)
        CancelBtn.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(35, 38, 48)
        CancelBtn.BorderSizePixel = 0
        CancelBtn.FontFace = FontMichromaRegular
        CancelBtn.Text = noText
        CancelBtn.TextColor3 = Window.CurrentTheme.Text
        CancelBtn.TextSize = 11
        CancelBtn.ZIndex = 123
        CancelBtn.Parent = BtnRow

        local CancelCorner = Instance.new("UICorner")
        CancelCorner.CornerRadius = UDim.new(0, 6)
        CancelCorner.Parent = CancelBtn

        local YesBtn = Instance.new("TextButton")
        YesBtn.Size = UDim2.new(0.48, 0, 1, 0)
        YesBtn.Position = UDim2.new(0.52, 0, 0, 0)
        YesBtn.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        YesBtn.BorderSizePixel = 0
        YesBtn.FontFace = FontMichromaBold
        YesBtn.Text = yesText
        YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        YesBtn.TextSize = 11
        YesBtn.ZIndex = 123
        YesBtn.Parent = BtnRow

        local YesCorner = Instance.new("UICorner")
        YesCorner.CornerRadius = UDim.new(0, 6)
        YesCorner.Parent = YesBtn

        local function Close()
            PlayClickSFX()
            TweenService:Create(ModalCard, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.5, 20),
                Size = UDim2.new(0, 300, 0, 130)
            }):Play()
            task.delay(0.18, function()
                if ConfirmBackdrop and ConfirmBackdrop.Parent then
                    ConfirmBackdrop:Destroy()
                end
            end)
        end

        CancelBtn.MouseButton1Click:Connect(function()
            Close()
            if onNo then pcall(onNo) end
        end)

        YesBtn.MouseButton1Click:Connect(function()
            Close()
            if onYes then pcall(onYes) end
        end)

        TweenService:Create(ModalCard, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 320, 0, 150)
        }):Play()
    end
    Window.PromptConfirm = Window.Confirm

    function Window:CreateMDColorPicker(parent, position, size, title, defaultColor, onColorChanged, identifier)
        parent = ResolveParent(parent)
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

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(1, -65, 1, 0)
        TitleLabel.Position = UDim2.new(0, 14, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.FontFace = FontMichromaRegular
        TitleLabel.Text = title or "Color"
        TitleLabel.TextColor3 = Window.CurrentTheme.Text
        TitleLabel.TextSize = 14
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

        colorPickerData.WithCallback = function(self, cb)
            onColorChanged = cb
            return self
        end
        colorPickerData.WithTooltip = function(self, tt)
            if Window.AttachTooltip and CardFrame then
                Window:AttachTooltip(CardFrame, tt)
            end
            return self
        end
        colorPickerData.WithSaveKey = function(self, key)
            if key and key ~= "" then
                self.SaveKey = key
                Window.RegisteredColorPickers[key] = self
            end
            return self
        end
        colorPickerData.WithColor = function(self, col, triggerCb)
            self.SetColor(col, triggerCb)
            return self
        end

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
        height = height or 31
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

        if type(parent) == "table" and not parent.IsA and not parent.Frame and not parent.Instance then
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
            size = ComputeRowItemWidth(fraction, 31)
        else
            size = UDim2.new(1, 0, 0, 31)
        end
        position = btnPos or UDim2.new(0, 0, 0, 0)
        text = btnText or "Function"
        onClick = callback

        local BtnFrame = Instance.new("Frame")
        BtnFrame.Name = "MDButtonCard"
        BtnFrame.Size = size
        BtnFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        BtnFrame.Position = UDim2.new(
            position.X.Scale + 0.5 * size.X.Scale,
            position.X.Offset + math.floor(size.X.Offset * 0.5),
            position.Y.Scale + 0.5 * size.Y.Scale,
            position.Y.Offset + math.floor(size.Y.Offset * 0.5)
        )
        BtnFrame.BackgroundColor3 = Window.CurrentTheme.ButtonBG
        BtnFrame.BackgroundTransparency = 0.05
        BtnFrame.BorderSizePixel = 0
        BtnFrame.ZIndex = 10
        BtnFrame.Parent = ResolveParent(targetParent or parent)

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 22)
        Corner.Parent = BtnFrame

        AddUIShadow(BtnFrame, 20, 0.5)

        local BtnScale = Instance.new("UIScale")
        BtnScale.Scale = 1.0
        BtnScale.Parent = BtnFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Name = GenerateSafeName("Stroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1.5
        Stroke.Transparency = 0
        Stroke.Parent = BtnFrame

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = GenerateSafeName("Text")
        MDTextFolder.Parent = BtnFrame

        local BtnText = Instance.new("TextLabel")
        BtnText.Name = "btntext"
        BtnText.Size = UDim2.new(1, -12, 1, 0)
        BtnText.Position = UDim2.new(0, 6, 0, 0)
        BtnText.BackgroundTransparency = 1
        BtnText.FontFace = FontMichromaBold
        BtnText.RichText = true
        BtnText.Text = text or "Function"
        BtnText.TextColor3 = Window.CurrentTheme.Text
        BtnText.TextScaled = false
        BtnText.TextSize = 14
        BtnText.TextWrapped = true
        BtnText.TextXAlignment = Enum.TextXAlignment.Center
        BtnText.TextYAlignment = Enum.TextYAlignment.Center
        BtnText.ZIndex = 11
        BtnText.Parent = MDTextFolder

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = GenerateSafeName("Trigger")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 12
        ClickBtn.Parent = BtnFrame

        local _hoverActive = false
        local _pressActive = false

        TrackConn(ClickBtn.MouseEnter:Connect(function()
            _hoverActive = true
            PlayHoverSFX()
            local baseBg = Window.CurrentTheme.ButtonBG
            local hoverBg = BrightenColor(baseBg, 1.05)
            TweenService:Create(Stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 2.2}):Play()
            TweenService:Create(BtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1.02}):Play()
            TweenService:Create(BtnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = hoverBg}):Play()
        end))

        TrackConn(ClickBtn.MouseLeave:Connect(function()
            _hoverActive = false
            _pressActive = false
            local baseBg = Window.CurrentTheme.ButtonBG
            TweenService:Create(Stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Thickness = 1.5}):Play()
            TweenService:Create(BtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1.0}):Play()
            TweenService:Create(BtnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = baseBg}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Down:Connect(function()
            _pressActive = true
            PlayClickSFX()
            TweenService:Create(BtnScale, TweenInfo.new(0.09, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
        end))

        TrackConn(ClickBtn.MouseButton1Up:Connect(function()
            if not _pressActive then return end
            _pressActive = false
            local targetScale = _hoverActive and 1.02 or 1.0
            TweenService:Create(BtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
            if onClick then
                pcall(onClick)
            end
        end))



        local btnData = {
            Frame = BtnFrame,
            TextLabel = BtnText,
            Stroke = Stroke,
            Trigger = ClickBtn,
            BaseSize = size,
            SetText = function(self, newTxt)
                BtnText.Text = tostring(newTxt or "")
            end,
            RefreshTheme = function(theme)
                BtnFrame.BackgroundColor3 = theme.ButtonBG
                BtnText.TextColor3 = theme.Text
            end
        }

        btnData.WithCallback = function(self, cb)
            onClick = cb
            return self
        end
        btnData.WithTooltip = function(self, tt)
            if Window.AttachTooltip and BtnFrame then
                Window:AttachTooltip(BtnFrame, tt)
            end
            return self
        end
        btnData.WithSaveKey = function(self, key)
            if key and key ~= "" then
                self.SaveKey = key
            end
            return self
        end
        btnData.WithText = function(self, txt)
            self:SetText(txt)
            return self
        end

        table.insert(Window.RegisteredMDButtons, btnData)

        return btnData
    end

    -- Half-Side Embedded Toggle Generator
    function Window:CreateMDToggleHalf(parent, position, size, text, initialState, onToggle, keybindConfig, connectMode)
        parent = ResolveParent(parent)
        size = size or UDim2.new(0, 260, 0, 44)
        position = position or UDim2.new(0, 0, 0, 0)

        local CardFrame = Instance.new("Frame")
        CardFrame.Name = GenerateSafeName("Card")
        CardFrame.Size = size
        CardFrame.Position = position
        CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
        CardFrame.BackgroundTransparency = 0.05
        CardFrame.BorderSizePixel = 0
        CardFrame.ZIndex = 10
        CardFrame.Parent = parent

        local Corner = Instance.new("UICorner")
        if connectMode == "Top" or connectMode == "First" then
            ApplyCornerRadii(Corner, 22, 22, 0, 0)
        elseif connectMode == "Middle" then
            ApplyCornerRadii(Corner, 0, 0, 0, 0)
        elseif connectMode == "Bottom" or connectMode == "Last" then
            ApplyCornerRadii(Corner, 0, 0, 22, 22)
        else
            Corner.CornerRadius = UDim.new(0, 22)
        end
        Corner.Parent = CardFrame

        AddUIShadow(CardFrame, 20, 0.5)

        local MDTextFolder = Instance.new("Folder")
        MDTextFolder.Name = "Text"
        MDTextFolder.Parent = CardFrame

        local bgImageOn = nil
        local bgImageOff = nil
        if type(keybindConfig) == "table" then
            bgImageOn = keybindConfig.BackgroundImageOn or keybindConfig.OnImage or keybindConfig.BackgroundImage or keybindConfig.Background
            bgImageOff = keybindConfig.BackgroundImageOff or keybindConfig.OffImage or keybindConfig.BackgroundImage or keybindConfig.Background
        end

        local CardBgImage = nil
        local function UpdateCardBgImage()
            local targetImg = isToggled and (bgImageOn or bgImageOff) or (bgImageOff or bgImageOn)
            if targetImg and targetImg ~= "" then
                if type(targetImg) == "number" or tostring(targetImg):match("^%d+$") then
                    targetImg = "rbxassetid://" .. tostring(targetImg)
                end
                if not CardBgImage then
                    CardBgImage = Instance.new("ImageLabel")
                    CardBgImage.Name = "CardBgImage"
                    CardBgImage.Size = UDim2.new(1, 0, 1, 0)
                    CardBgImage.Position = UDim2.new(0, 0, 0, 0)
                    CardBgImage.BackgroundTransparency = 1
                    CardBgImage.ImageTransparency = 0.25
                    CardBgImage.ScaleType = Enum.ScaleType.Crop
                    CardBgImage.ZIndex = 10
                    CardBgImage.Parent = CardFrame

                    local imgCorner = Corner:Clone()
                    imgCorner.Parent = CardBgImage
                end
                CardBgImage.Image = targetImg
                CardBgImage.Visible = true
            elseif CardBgImage then
                CardBgImage.Visible = false
            end
        end

        local keybindProp = nil
        if type(keybindConfig) == "table" then
            keybindProp = keybindConfig.Bind or keybindConfig.Keybind or keybindConfig.DefaultBind or keybindConfig.Key or keybindConfig.KeyBind or keybindConfig.DefaultKey
            if keybindProp == nil and keybindConfig.Default ~= nil and typeof(keybindConfig.Default) ~= "boolean" then
                keybindProp = keybindConfig.Default
            end
        elseif keybindConfig ~= nil and keybindConfig ~= false and keybindConfig ~= true then
            keybindProp = keybindConfig
        end

        local hasKeybind = (keybindProp ~= nil and keybindProp ~= false and keybindProp ~= "")

        local TitleText = Instance.new("TextLabel")
        TitleText.Name = "btntext"
        TitleText.Size = hasKeybind and UDim2.new(1, -104, 1, 0) or UDim2.new(1, -65, 1, 0)
        TitleText.Position = UDim2.new(0, 14, 0, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.FontFace = FontMichromaRegular
        TitleText.RichText = true
        TitleText.Text = text or "Function"
        TitleText.TextColor3 = Window.CurrentTheme.Text
        TitleText.TextSize = 14
        TitleText.TextWrapped = true
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.TextYAlignment = Enum.TextYAlignment.Center
        TitleText.ZIndex = 11
        TitleText.Parent = MDTextFolder

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "TogglePill"
        ToggleFrame.Size = UDim2.new(0, 44, 0, 24)
        ToggleFrame.Position = UDim2.new(1, -54, 0.5, -12)
        ToggleFrame.BackgroundColor3 = initialState and Window.CurrentTheme.ButtonBG or ((Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))
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
        if bgImageOn or bgImageOff then
            UpdateCardBgImage()
        end

        local BaseCircle = Instance.new("ImageLabel")
        BaseCircle.Name = GenerateSafeName("Knob")
        BaseCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        BaseCircle.Size = UDim2.new(0, 18, 0, 18)
        BaseCircle.Position = isToggled and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 12, 0.5, 0)
        BaseCircle.Rotation = isToggled and 0 or 225
        BaseCircle.BackgroundTransparency = 1
        BaseCircle.Image = "rbxassetid://118376432250064"
        BaseCircle.ImageColor3 = isToggled and Color3.fromRGB(255, 255, 255) or Window.CurrentTheme.ButtonBG
        BaseCircle.ZIndex = 12
        BaseCircle.Parent = KnobFolder

        local OverlayCircle = Instance.new("ImageLabel")
        OverlayCircle.Name = GenerateSafeName("Overlay")
        OverlayCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        OverlayCircle.Size = UDim2.new(0, 18, 0, 18)
        OverlayCircle.Position = isToggled and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 12, 0.5, 0)
        OverlayCircle.Rotation = isToggled and 0 or 225
        OverlayCircle.BackgroundTransparency = 1
        OverlayCircle.Image = "rbxassetid://100354746235648"
        OverlayCircle.ImageColor3 = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(255, 255, 255)
        OverlayCircle.ZIndex = 13
        OverlayCircle.Parent = KnobFolder

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Name = "ClickTrigger"
        -- Only cover the toggle pill area (right side), not the whole card
        ClickBtn.Size = UDim2.new(0, 56, 0, 36)
        ClickBtn.Position = UDim2.new(1, -58, 0.5, -18)
        ClickBtn.AnchorPoint = Vector2.new(0, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 14
        ClickBtn.Parent = CardFrame

        local function PerformToggle(newState, triggerCallback)
            isToggled = (newState == true)
            local targetKnobPos = isToggled and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 12, 0.5, 0)
            local targetRotation = isToggled and 0 or 225
            local targetBG = isToggled and Window.CurrentTheme.ButtonBG or ((Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))
            local targetBaseColor = isToggled and Color3.fromRGB(255, 255, 255) or Window.CurrentTheme.ButtonBG
            local targetOverlayColor = isToggled and Window.CurrentTheme.ButtonBG or Color3.fromRGB(255, 255, 255)

            TweenService:Create(BaseCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetKnobPos,
                Rotation = targetRotation,
                ImageColor3 = targetBaseColor
            }):Play()
            TweenService:Create(OverlayCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetKnobPos,
                Rotation = targetRotation,
                ImageColor3 = targetOverlayColor
            }):Play()
            TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetBG}):Play()
            UpdateCardBgImage()

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
            CardFrame = CardFrame,
            Frame = CardFrame,
            ToggleFrame = ToggleFrame,
            TitleText = TitleText,
            BaseCircle = BaseCircle,
            Overlay = OverlayCircle,
            Corner = Corner,
            CardBgImage = CardBgImage,
            GetState = function() return isToggled end,
            SetState = function(state, triggerCallback)
                PerformToggle(state, triggerCallback)
            end,
            SetBackgroundImage = function(self, onImg, offImg)
                bgImageOn = onImg
                bgImageOff = offImg or onImg
                UpdateCardBgImage()
            end,
            SetToggleImages = function(self, onImg, offImg)
                bgImageOn = onImg
                bgImageOff = offImg or onImg
                UpdateCardBgImage()
            end,
            RefreshTheme = function(theme)
                CardFrame.BackgroundColor3 = theme.CardBG
                TitleText.TextColor3 = theme.Text
                local isTog = isToggled
                ToggleFrame.BackgroundColor3 = isTog and theme.ButtonBG or ((theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))
                BaseCircle.ImageColor3 = isTog and Color3.fromRGB(255, 255, 255) or theme.ButtonBG
                OverlayCircle.ImageColor3 = isTog and theme.ButtonBG or Color3.fromRGB(255, 255, 255)
                if toggleData.ConnectedSlider and toggleData.ConnectedSlider.RefreshTheme then
                    toggleData.ConnectedSlider.RefreshTheme(theme)
                end
                if toggleData.ValueLabel then
                    toggleData.ValueLabel.TextColor3 = theme.Text
                end
                if toggleData.Keybind and toggleData.Keybind.Container then
                    toggleData.Keybind.Container.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(24, 26, 34)
                    if toggleData.Keybind.Label then toggleData.Keybind.Label.TextColor3 = theme.Text end
                    if toggleData.Keybind.DeleteBtn then toggleData.Keybind.DeleteBtn.ImageColor3 = theme.Text end
                end
            end
        }

        toggleData.AddSlider = function(self, sliderConfig)
            sliderConfig = sliderConfig or {}
            local minVal = sliderConfig.Min or sliderConfig.min or 0
            local maxVal = sliderConfig.Max or sliderConfig.max or 100
            local defVal = sliderConfig.Default or sliderConfig.default or minVal
            local cb = sliderConfig.Callback or sliderConfig.callback or sliderConfig.OnChanged
            local suffix = sliderConfig.Suffix or (sliderConfig.ValueFormat == "percent" and "%") or ""
            local prefix = sliderConfig.Prefix or ""
            local showVal = sliderConfig.ShowValue ~= false
            local inc = sliderConfig.Increment or sliderConfig.increment or sliderConfig.Step or sliderConfig.step or 1
            local prec = sliderConfig.Precision or sliderConfig.precision or sliderConfig.Decimals or sliderConfig.decimals

            -- Expand card to contain slider underneath (Screenshot 2 style)
            CardFrame.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 76)
            TitleText.Size = hasKeybind and UDim2.new(1, -190, 0, 44) or UDim2.new(1, -145, 0, 44)
            ToggleFrame.Position = UDim2.new(1, -54, 0, 10)
            local kbObj = self.Keybind or toggleData.Keybind
            if kbObj then
                local kb = kbObj.Container or kbObj.Badge or kbObj.Frame or (kbObj.IsA and kbObj:IsA("GuiObject") and kbObj)
                if kb then
                    kb.Position = UDim2.new(1, -96, 0, 11)
                end
            end

            local ValueLabel = nil
            if showVal then
                ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "ValueLabel"
                ValueLabel.Size = UDim2.new(0, 85, 0, 20)
                ValueLabel.Position = hasKeybind and UDim2.new(1, -102, 0, 12) or UDim2.new(1, -60, 0, 12)
                ValueLabel.AnchorPoint = Vector2.new(1, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.FontFace = FontMichromaRegular
                ValueLabel.TextColor3 = Window.CurrentTheme.Text
                ValueLabel.TextSize = 11
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                ValueLabel.ZIndex = 11
                ValueLabel.Parent = CardFrame
            end

            local sliderTrack
            sliderTrack = Window:CreateMDSlider(CardFrame, UDim2.new(0, 14, 0, 50), UDim2.new(1, -28, 0, 12), minVal, maxVal, defVal, function(val, pct)
                if ValueLabel then
                    ValueLabel.Text = sliderTrack and sliderTrack.GetFormattedValue(val, pct) or (prefix .. tostring(val) .. suffix)
                end
                if cb then cb(val, pct) end
            end, toggleName .. "_Slider", {
                ShowValue = false,
                Increment = inc,
                Precision = prec,
                Suffix = suffix,
                Prefix = prefix,
                ValueFormat = sliderConfig.ValueFormat or (suffix == "%" and "percent") or "number"
            })

            if ValueLabel then
                ValueLabel.Text = sliderTrack.GetFormattedValue(defVal)
                sliderTrack.ValueLabel = ValueLabel
            end

            local oldSetSuffix = sliderTrack.SetSuffix
            sliderTrack.SetSuffix = function(newSuffix)
                if oldSetSuffix then oldSetSuffix(newSuffix) end
                if ValueLabel then ValueLabel.Text = sliderTrack.GetFormattedValue() end
            end
            local oldSetPrefix = sliderTrack.SetPrefix
            sliderTrack.SetPrefix = function(newPrefix)
                if oldSetPrefix then oldSetPrefix(newPrefix) end
                if ValueLabel then ValueLabel.Text = sliderTrack.GetFormattedValue() end
            end
            local oldSetValueFormat = sliderTrack.SetValueFormat
            sliderTrack.SetValueFormat = function(format, newSuffix, newPrefix)
                if oldSetValueFormat then oldSetValueFormat(format, newSuffix, newPrefix) end
                if ValueLabel then ValueLabel.Text = sliderTrack.GetFormattedValue() end
            end
            local oldSetValue = sliderTrack.SetValue
            sliderTrack.SetValue = function(val, triggerCallback)
                if oldSetValue then oldSetValue(val, triggerCallback) end
                if ValueLabel then ValueLabel.Text = sliderTrack.GetFormattedValue() end
            end
            local oldSetIncrement = sliderTrack.SetIncrement
            sliderTrack.SetIncrement = function(newInc, newPrec)
                if oldSetIncrement then oldSetIncrement(newInc, newPrec) end
                if ValueLabel then ValueLabel.Text = sliderTrack.GetFormattedValue() end
            end
            local oldSetPrecision = sliderTrack.SetPrecision
            sliderTrack.SetPrecision = function(newPrec)
                if oldSetPrecision then oldSetPrecision(newPrec) end
                if ValueLabel then ValueLabel.Text = sliderTrack.GetFormattedValue() end
            end

            toggleData.ConnectedSlider = sliderTrack
            toggleData.ValueLabel = ValueLabel
            return sliderTrack
        end

        toggleData.WithKeybind = function(self, keyOrConfig, cb)
            if not self.Keybind then
                local kbProp = nil
                if type(keyOrConfig) == "table" then
                    kbProp = keyOrConfig.Bind or keyOrConfig.Keybind or keyOrConfig.DefaultBind or keyOrConfig.Key or keyOrConfig.KeyBind or keyOrConfig.DefaultKey
                    if kbProp == nil and keyOrConfig.Default ~= nil and typeof(keyOrConfig.Default) ~= "boolean" then
                        kbProp = keyOrConfig.Default
                    end
                elseif keyOrConfig ~= nil and keyOrConfig ~= false and keyOrConfig ~= true then
                    kbProp = keyOrConfig
                end
                local defaultKey = kbProp
                local keyPos = (self.ConnectedSlider or CardFrame.Size.Y.Offset > 50) and UDim2.new(1, -96, 0, 11) or UDim2.new(1, -96, 0.5, -11)
                self.Keybind = Window:CreateKeybindBadge(CardFrame, keyPos, UDim2.new(0, 36, 0, 22), defaultKey, function()
                    self.SetState(not isToggled, true)
                    if cb then pcall(cb, isToggled) end
                end, toggleName)
            end
            return self
        end
        toggleData.WithSlider = function(self, sliderConfig, cb)
            if type(sliderConfig) == "table" then
                if cb and not sliderConfig.Callback then
                    sliderConfig.Callback = cb
                end
                self:AddSlider(sliderConfig)
            end
            return self
        end
        toggleData.WithCallback = function(self, cb)
            onToggle = cb
            return self
        end
        toggleData.WithTooltip = function(self, tt)
            if Window.AttachTooltip and CardFrame then
                Window:AttachTooltip(CardFrame, tt)
            end
            return self
        end
        toggleData.WithSaveKey = function(self, key)
            if key and key ~= "" then
                Window.RegisteredToggles[key] = self
            end
            return self
        end
        toggleData.WithState = function(self, state)
            self.SetState(state, true)
            return self
        end
        toggleData.WithImages = function(self, onImg, offImg)
            self:SetBackgroundImage(onImg, offImg)
            return self
        end

        if hasKeybind then
            local defaultKey = keybindProp
            local keyPos = (toggleData.ConnectedSlider or CardFrame.Size.Y.Offset > 50) and UDim2.new(1, -96, 0, 11) or UDim2.new(1, -96, 0.5, -11)
            toggleData.Keybind = Window:CreateKeybindBadge(CardFrame, keyPos, UDim2.new(0, 36, 0, 22), defaultKey, function()
                toggleData.SetState(not isToggled, true)
            end, toggleName)
        end

        Window.RegisteredToggles[toggleName] = toggleData
        table.insert(Window.RegisteredMDToggles, toggleData)

        return toggleData
    end


    ScriptUi = Instance.new("ScreenGui")
    ScriptUi.Name = GenerateSafeName("UI")
    ScriptUi.ResetOnSpawn = false
    ScriptUi.Enabled = false
    ScriptUi.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScriptUi.DisplayOrder = 10
    ProtectGui(ScriptUi)
    ScriptUi.Parent = ParentGui
    table.insert(Library.ActiveGuis, ScriptUi)

    MinimisedUI = Instance.new("ScreenGui")
    MinimisedUI.Name = GenerateSafeName("UI")
    MinimisedUI.ResetOnSpawn = false
    MinimisedUI.Enabled = false
    MinimisedUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MinimisedUI.DisplayOrder = 25
    ProtectGui(MinimisedUI)
    MinimisedUI.Parent = ParentGui
    table.insert(Library.ActiveGuis, MinimisedUI)

    NotificationUI = Instance.new("ScreenGui")
    NotificationUI.Name = GenerateSafeName("UI")
    NotificationUI.ResetOnSpawn = false
    NotificationUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationUI.DisplayOrder = 30
    ProtectGui(NotificationUI)
    NotificationUI.Parent = ParentGui
    table.insert(Library.ActiveGuis, NotificationUI)

    local MobileUI = Instance.new("ScreenGui")
    MobileUI.Name = GenerateSafeName("UI")
    MobileUI.ResetOnSpawn = false
    MobileUI.Enabled = false
    MobileUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MobileUI.DisplayOrder = 22
    ProtectGui(MobileUI)
    MobileUI.Parent = ParentGui
    table.insert(Library.ActiveGuis, MobileUI)
    Window.MobileUI = MobileUI

    -- =========================================================================
    -- MOBILE FLOATING ACTION & TOGGLE BUTTON ENGINE
    -- =========================================================================
    function Window:CreateMobileButton(arg1, arg2, arg3, arg4, arg5)
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
        Stroke.Thickness = config.StrokeThickness or 1.2
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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
            TextLabel.FontFace = FontMichromaBold
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
                    local delta = input.Position - dragStart
                    if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                        hasMoved = true
                    end
                    if hasMoved then
                        BtnFrame.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
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
                TextLabel.FontFace = FontMichromaBold
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

    local DropdownOverlay = Instance.new("Frame")
    DropdownOverlay.Name = "DropdownOverlay"
    DropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
    DropdownOverlay.Position = UDim2.new(0, 0, 0, 0)
    DropdownOverlay.BackgroundTransparency = 1
    DropdownOverlay.BorderSizePixel = 0
    DropdownOverlay.ClipsDescendants = false
    DropdownOverlay.ZIndex = 500
    DropdownOverlay.Parent = MainContainer
    Window.DropdownOverlay = DropdownOverlay

    -- =========================================================================
    -- GLOBAL FLOATING TOOLTIP ENGINE
    -- =========================================================================
    local TooltipFrame = Instance.new("Frame")
    TooltipFrame.Name = GenerateSafeName("Tooltip")
    TooltipFrame.Size = UDim2.new(0, 100, 0, 24)
    TooltipFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    TooltipFrame.BackgroundTransparency = 1
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.ZIndex = 10000
    TooltipFrame.Visible = false
    TooltipFrame.Parent = ScriptUi

    local TooltipCorner = Instance.new("UICorner")
    TooltipCorner.CornerRadius = UDim.new(0, 6)
    TooltipCorner.Parent = TooltipFrame

    local TooltipStroke = Instance.new("UIStroke")
    TooltipStroke.Thickness = 1.1
    TooltipStroke.Color = Color3.fromRGB(255, 255, 255)
    TooltipStroke.Transparency = 1
    TooltipStroke.Parent = TooltipFrame

    local TooltipPadding = Instance.new("UIPadding")
    TooltipPadding.PaddingLeft = UDim.new(0, 8)
    TooltipPadding.PaddingRight = UDim.new(0, 8)
    TooltipPadding.PaddingTop = UDim.new(0, 4)
    TooltipPadding.PaddingBottom = UDim.new(0, 4)
    TooltipPadding.Parent = TooltipFrame

    local TooltipText = Instance.new("TextLabel")
    TooltipText.Name = "TooltipText"
    TooltipText.Size = UDim2.new(1, 0, 1, 0)
    TooltipText.BackgroundTransparency = 1
    TooltipText.FontFace = FontMichromaRegular
    TooltipText.Text = ""
    TooltipText.TextColor3 = Color3.fromRGB(235, 240, 255)
    TooltipText.TextSize = 11
    TooltipText.TextXAlignment = Enum.TextXAlignment.Center
    TooltipText.TextYAlignment = Enum.TextYAlignment.Center
    TooltipText.TextTransparency = 1
    TooltipText.ZIndex = 10001
    TooltipText.Parent = TooltipFrame

    local activeTooltipTarget = nil
    local tooltipTween = nil

    function Window:AttachTooltip(guiObject, text)
        if not guiObject or not text or text == "" then return end
        guiObject._TooltipContent = text

        TrackConn(guiObject.MouseEnter:Connect(function()
            if not guiObject or not guiObject._TooltipContent or guiObject._TooltipContent == "" then return end
            activeTooltipTarget = guiObject
            TooltipText.Text = tostring(guiObject._TooltipContent)

            local TextService = game:GetService("TextService")
            local bounds = TextService:GetTextSize(TooltipText.Text, 11, Enum.Font.Michroma or Enum.Font.SourceSansBold, Vector2.new(320, 120))
            local tw = math.clamp(bounds.X + 20, 50, 340)
            local th = math.clamp(bounds.Y + 10, 22, 120)
            TooltipFrame.Size = UDim2.new(0, tw, 0, th)

            local mousePos = UserInputService:GetMouseLocation()
            local inset = game:GetService("GuiService"):GetGuiInset()
            TooltipFrame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - inset.Y + 12)
            TooltipFrame.BackgroundColor3 = (Window.CurrentTheme and Window.CurrentTheme.CardBG) or Color3.fromRGB(18, 20, 26)
            TooltipText.TextColor3 = (Window.CurrentTheme and Window.CurrentTheme.Text) or Color3.fromRGB(235, 240, 255)
            TooltipFrame.Visible = true

            if tooltipTween then tooltipTween:Cancel() end
            tooltipTween = TweenService:Create(TooltipFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.08
            })
            tooltipTween:Play()
            TweenService:Create(TooltipStroke, TweenInfo.new(0.15), {Transparency = 0.75}):Play()
            TweenService:Create(TooltipText, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
        end))

        TrackConn(guiObject.MouseMoved:Connect(function()
            if activeTooltipTarget == guiObject and TooltipFrame.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local inset = game:GetService("GuiService"):GetGuiInset()
                TooltipFrame.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y - inset.Y + 12)
            end
        end))

        TrackConn(guiObject.MouseLeave:Connect(function()
            if activeTooltipTarget == guiObject then
                activeTooltipTarget = nil
                if tooltipTween then tooltipTween:Cancel() end
                tooltipTween = TweenService:Create(TooltipFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                })
                tooltipTween:Play()
                TweenService:Create(TooltipStroke, TweenInfo.new(0.15), {Transparency = 1}):Play()
                TweenService:Create(TooltipText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
                task.delay(0.16, function()
                    if activeTooltipTarget == nil then
                        TooltipFrame.Visible = false
                    end
                end)
            end
        end))
    end

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
    LocalUIBlurPart.Archivable = false
    LocalUIBlurPart.Anchored = true
    LocalUIBlurPart.Size = Vector3.new(1, 1, 0.01)
    LocalUIBlurPart.CFrame = CFrame.new(0, 999999, 0)
    LocalUIBlurPart.Parent = workspace

    Window.BackgroundDOF = BackgroundDOF
    Window.LocalUIBlurPart = LocalUIBlurPart

    local GuiService = game:GetService("GuiService")
    local function UpdateLocalUIBlur()
        if not Window.BackgroundBlurEnabled or not ScriptUi or not ScriptUi.Enabled or not MainContainer or not MainContainer.Parent or not LocalUIBlurPart or not LocalUIBlurPart.Parent then
            if LocalUIBlurPart and LocalUIBlurPart.Parent then
                LocalUIBlurPart.Transparency = 1
                LocalUIBlurPart.CFrame = CFrame.new(0, 999999, 0)
            end
            if BackgroundDOF and BackgroundDOF.Parent then
                BackgroundDOF.Enabled = false
            end
            return
        end

        local Camera = workspace.CurrentCamera
        if not Camera or not Camera.FieldOfView then
            if LocalUIBlurPart and LocalUIBlurPart.Parent then
                LocalUIBlurPart.Transparency = 1
                LocalUIBlurPart.CFrame = CFrame.new(0, 999999, 0)
            end
            if BackgroundDOF and BackgroundDOF.Parent then
                BackgroundDOF.Enabled = false
            end
            return
        end

        local absPos = MainContainer.AbsolutePosition
        local absSize = MainContainer.AbsoluteSize
        if not absPos or not absSize or absSize.X <= 30 or absSize.Y <= 30 then
            LocalUIBlurPart.Transparency = 1
            LocalUIBlurPart.CFrame = CFrame.new(0, 999999, 0)
            if BackgroundDOF and BackgroundDOF.Parent then
                BackgroundDOF.Enabled = false
            end
            return
        end

        local viewW = Camera.ViewportSize.X
        local viewH = Camera.ViewportSize.Y
        if viewW <= 0 or viewH <= 0 then return end

        local camCF = Camera.CFrame
        local camPos = camCF.Position
        local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = camCF:GetComponents()

        local vecR = Vector3.new(r00, r10, r20)
        local vecU = Vector3.new(r01, r11, r21)
        local vecL = -Vector3.new(r02, r12, r22)

        local sx = vecR.Magnitude
        if sx < 0.0001 then sx = 1 end

        local sy = vecU.Magnitude
        if sy < 0.0001 then sy = 1 end

        local sz = vecL.Magnitude
        if sz < 0.0001 then sz = 1 end

        local uR = vecR / sx
        local uU = vecU / sy
        local uL = vecL / sz

        local depth = 1.0
        local tanHalfFov = math.tan(math.rad(Camera.FieldOfView or 70) * 0.5)
        local scaleFactor = (2 * depth * tanHalfFov) / math.max(viewH, 1)

        local inset = GuiService:GetGuiInset()
        local insetX = ScriptUi.IgnoreGuiInset and 0 or inset.X
        local insetY = ScriptUi.IgnoreGuiInset and 0 or inset.Y

        local padX = 10
        local padY = 4

        local minX = absPos.X + insetX + padX
        local minY = absPos.Y + insetY + padY
        local uiW = math.max(absSize.X - (padX * 2), 1)
        local uiH = math.max(absSize.Y - (padY * 2), 1)

        local midX = minX + (uiW * 0.5)
        local midY = minY + (uiH * 0.5)

        local partW = (uiW * scaleFactor) / sx
        local partH = (uiH * scaleFactor) / sy

        local cX = ((midX - (viewW * 0.5)) * scaleFactor) / sx
        local cY = (((viewH * 0.5) - midY) * scaleFactor) / sy

        local pCenter = camPos + (uR * cX) + (uU * cY) + (uL * depth)

        LocalUIBlurPart.Size = Vector3.new(partW, partH, 0.01)
        LocalUIBlurPart.CFrame = CFrame.fromMatrix(pCenter, uR, uU, -uL)
        LocalUIBlurPart.Transparency = 0.98
        if BackgroundDOF and BackgroundDOF.Parent then
            BackgroundDOF.Enabled = true
        end
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
            local pullStrength = 850.0
            local springStiffness = 32.0
            local maxSpeed = 300.0

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
    TopFrame.ZIndex = 20
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
    SearchInput.PlaceholderText = "Search in script..."
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
    MainFrame.ClipsDescendants = true
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
    ContentOverlay.ClipsDescendants = false
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
    SidebarScroll.ZIndex = 4
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

    local SidebarCollapseBtn = Instance.new("ImageButton")
    SidebarCollapseBtn.Name = "SidebarCollapseBtn"
    SidebarCollapseBtn.Size = UDim2.new(0, 20, 0, 20)
    SidebarCollapseBtn.BackgroundTransparency = 1
    SidebarCollapseBtn.Image = "rbxassetid://6031091004"
    SidebarCollapseBtn.ImageColor3 = Window.CurrentTheme.Text
    SidebarCollapseBtn.LayoutOrder = 9999
    SidebarCollapseBtn.ZIndex = 5
    SidebarCollapseBtn.Parent = SidebarScroll

    TrackConn(SidebarCollapseBtn.MouseButton1Click:Connect(function()
        PlayClickSFX()
        Window:ToggleSidebar()
    end))
    Window.SidebarCollapseBtn = SidebarCollapseBtn

    MainContentFrame = Instance.new("Frame")
    MainContentFrame.Name = "MainContentFrame"
    MainContentFrame.Size = UDim2.new(1, -175, 1, 0)
    MainContentFrame.Position = UDim2.new(0, 175, 0, 0)
    MainContentFrame.BackgroundTransparency = 1
    MainContentFrame.BorderSizePixel = 0
    MainContentFrame.ClipsDescendants = true
    MainContentFrame.ZIndex = 4
    MainContentFrame.Parent = ContentOverlay

    -- Bottom Frame
    local BottomFrame = Instance.new("Frame")
    BottomFrame.Name = "BottomFrame"
    BottomFrame.Size = UDim2.new(1, 0, 0, 52)
    BottomFrame.Position = UDim2.new(0, 0, 1, -52)
    BottomFrame.BackgroundColor3 = Window.CurrentTheme.BottomBG
    BottomFrame.BackgroundTransparency = Window.CurrentTheme.BottomTrans
    BottomFrame.BorderSizePixel = 0
    BottomFrame.ZIndex = 20
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
    MDicon.Image = iconAsset
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
    MadebyText.Text = authorText
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
    DiscordBtn.Text = discordDisplay
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
                setclipboard(discordCopyUrl)
            end
        end)
        Window:Notify("Discord server", "Copied invite link to clipboard:\n" .. discordCopyUrl, 3)
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
    MinimizedFrame.BackgroundTransparency = 1
    MinimizedFrame.ClipsDescendants = false
    MinimizedFrame.ZIndex = 100
    MinimizedFrame.Parent = MinimisedUI

    -- 2nd bigger layer spinning just a bit faster counter-clockwise (rbxassetid://95108160130077)
    local MinLayer2_Big = Instance.new("ImageLabel")
    MinLayer2_Big.Name = "MinLayer2_Big"
    MinLayer2_Big.AnchorPoint = Vector2.new(0.5, 0.5)
    MinLayer2_Big.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinLayer2_Big.Size = UDim2.new(1, 28, 1, 28)
    MinLayer2_Big.BackgroundTransparency = 1
    MinLayer2_Big.Image = "rbxassetid://137088387997132"
    MinLayer2_Big.ZIndex = 98
    MinLayer2_Big.Parent = MinimizedFrame

    local MinGrad2 = Instance.new("UIGradient")
    MinGrad2.Rotation = 0
    MinGrad2.Parent = MinLayer2_Big

    -- 1st smaller layer spinning slowly clockwise (rbxassetid://137088387997132)
    local MinLayer1_Small = Instance.new("ImageLabel")
    MinLayer1_Small.Name = "MinLayer1_Small"
    MinLayer1_Small.AnchorPoint = Vector2.new(0.5, 0.5)
    MinLayer1_Small.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinLayer1_Small.Size = UDim2.new(1, 14, 1, 14)
    MinLayer1_Small.BackgroundTransparency = 1
    MinLayer1_Small.Image = "rbxassetid://95108160130077"
    MinLayer1_Small.ZIndex = 99
    MinLayer1_Small.Parent = MinimizedFrame

    local MinGrad1 = Instance.new("UIGradient")
    MinGrad1.Rotation = 0
    MinGrad1.Parent = MinLayer1_Small

    -- Center icon button
    local MinimizedImage = Instance.new("ImageButton")
    MinimizedImage.Name = "MinimizedImage"
    MinimizedImage.AnchorPoint = Vector2.new(0.5, 0.5)
    MinimizedImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinimizedImage.Size = UDim2.new(1, 0, 1, 0)
    MinimizedImage.BackgroundTransparency = 0
    MinimizedImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MinimizedImage.Image = minimizedIcon
    MinimizedImage.ZIndex = 101
    MinimizedImage.Parent = MinimizedFrame

    local MinimizedImageCorner = Instance.new("UICorner")
    MinimizedImageCorner.CornerRadius = UDim.new(1, 0)
    MinimizedImageCorner.Parent = MinimizedImage

    local rot1 = 0
    local rot2 = 0
    TrackConn(RunService.RenderStepped:Connect(function(dt)
        if MinimisedUI.Enabled then
            rot1 = (rot1 + (dt * 30)) % 360
            rot2 = (rot2 - (dt * 28)) % 360
            if MinLayer1_Small and MinLayer1_Small.Parent then
                MinLayer1_Small.Rotation = rot1
            end
            if MinLayer2_Big and MinLayer2_Big.Parent then
                MinLayer2_Big.Rotation = rot2
            end

            local curTheme = Window.CurrentTheme or {}
            local curGrad = curTheme.MinGradient or curTheme.BottomGradient or {Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150), Color3.fromRGB(255, 255, 255)}
            local c1 = curGrad[1] or Color3.fromRGB(255, 255, 255)
            local c2 = curGrad[2] or c1
            local c3 = curGrad[3] or c2

            local shiftSpeed = 3
            local phase = (tick() * (shiftSpeed * 0.15)) % 1.0
            local function getSmoothCol(off)
                local tVal = (math.sin((phase + off) * math.pi * 2) + 1) * 0.5
                if tVal < 0.5 then
                    return c1:Lerp(c2, tVal * 2)
                else
                    return c2:Lerp(c3, (tVal - 0.5) * 2)
                end
            end

            local animSeq = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    getSmoothCol(0)),
                ColorSequenceKeypoint.new(0.25, getSmoothCol(0.25)),
                ColorSequenceKeypoint.new(0.5,  getSmoothCol(0.5)),
                ColorSequenceKeypoint.new(0.75, getSmoothCol(0.75)),
                ColorSequenceKeypoint.new(1,    getSmoothCol(1))
            })

            if MinGrad1 and MinGrad1.Parent then
                MinGrad1.Color = animSeq
                MinGrad1.Rotation = 0
            end
            if MinGrad2 and MinGrad2.Parent then
                MinGrad2.Color = animSeq
                MinGrad2.Rotation = 0
            end
        end
    end))

    AttachUniversalDrag(MinimizedFrame, MinimizedFrame)
    AttachUniversalDrag(MinimizedImage, MinimizedFrame)
    AttachUniversalDrag(MinLayer1_Small, MinimizedFrame)
    AttachUniversalDrag(MinLayer2_Big, MinimizedFrame)

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
        NotifIcon.Image = Window.IconAsset or iconAsset or "rbxassetid://77044087750639"
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

    function Window:SetAuthor(newAuthor)
        if not newAuthor or newAuthor == "" then
            newAuthor = "Made by MorningDrift"
        elseif not tostring(newAuthor):lower():find("^made by") then
            newAuthor = "Made by " .. tostring(newAuthor)
        end
        Window.AuthorText = newAuthor
        if MadebyText then
            MadebyText.Text = newAuthor
        end
    end

    function Window:SetDiscord(newDiscord)
        if not newDiscord or newDiscord == "" then
            newDiscord = "discord.gg/48jdqB8rAw"
        end
        Window.DiscordLink = tostring(newDiscord)
        discordDisplay = Window.DiscordLink:gsub("^https?://", "")
        discordCopyUrl = Window.DiscordLink:find("^https?://") and Window.DiscordLink or ("https://" .. discordDisplay)
        if DiscordBtn then
            DiscordBtn.Text = discordDisplay
        end
    end

    function Window:SetIcon(newIcon)
        if not newIcon or newIcon == "" then
            newIcon = "rbxassetid://77044087750639"
        elseif type(newIcon) == "number" or tostring(newIcon):match("^%d+$") then
            newIcon = "rbxassetid://" .. tostring(newIcon)
        else
            newIcon = tostring(newIcon)
        end
        Window.IconAsset = newIcon
        if MDicon then
            MDicon.Image = newIcon
        end
    end

    function Window:SetMinimizedIcon(newIcon)
        if not newIcon or newIcon == "" then
            newIcon = "rbxassetid://77044087750639"
        elseif type(newIcon) == "number" or tostring(newIcon):match("^%d+$") then
            newIcon = "rbxassetid://" .. tostring(newIcon)
        else
            newIcon = tostring(newIcon)
        end
        Window.MinimizedIcon = newIcon
        if MinimizedImage then
            MinimizedImage.Image = newIcon
        end
    end

    local CurrentTabSwitchToken = 0

    -- Smooth Tab Switch Transition Engine
    SwitchTab = function(tabName)
        if Window.ActiveDropdown then
            pcall(function() Window.ActiveDropdown.Close() end)
        end
        if Window.ActiveTab == tabName then return end

        local oldTab = Window.Tabs[Window.ActiveTab]
        local newTab = Window.Tabs[tabName]
        Window.ActiveTab = tabName

        -- 1. Animate Sidebar Tab Buttons
        local oldTargetSize = Window.SidebarCollapsed and 11 or 15
        local newTargetSize = Window.SidebarCollapsed and 11 or 18

        if oldTab and oldTab.Button then
            TweenService:Create(oldTab.Button, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextSize = oldTargetSize,
                TextColor3 = Window.CurrentTheme.SubText
            }):Play()
            oldTab.Button.FontFace = FontMichromaRegular
            if oldTab.HoverGlow then
                TweenService:Create(oldTab.HoverGlow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()
                if oldTab.HoverGradient then
                    oldTab.HoverGradient.Transparency = NumberSequence.new(1)
                end
            end
            if oldTab.Icon then
                TweenService:Create(oldTab.Icon, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    ImageColor3 = Window.CurrentTheme.SubText
                }):Play()
            end
        end

        if newTab and newTab.Button then
            TweenService:Create(newTab.Button, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextSize = newTargetSize,
                TextColor3 = Window.CurrentTheme.Text
            }):Play()
            newTab.Button.FontFace = FontMichromaBold
            if newTab.HoverGlow then
                -- Active tab: invisible (1.0) at ends -> subtle glow (0.75) in middle -> invisible (1.0)
                TweenService:Create(newTab.HoverGlow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0
                }):Play()
                if newTab.HoverGradient then
                    newTab.HoverGradient.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0.0, 1.0),
                        NumberSequenceKeypoint.new(0.2, 0.75),
                        NumberSequenceKeypoint.new(0.8, 0.75),
                        NumberSequenceKeypoint.new(1.0, 1.0)
                    })
                end
            end
            if newTab.Icon then
                TweenService:Create(newTab.Icon, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    ImageColor3 = Window.CurrentTheme.Text
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

    function Window:SetSidebarWidth(width)
        Window.SidebarWidth = math.max(width or 175, 40)
        if not Window.SidebarCollapsed then
            local w = Window.SidebarWidth
            LeftFrame.Size = UDim2.new(0, w, 1, -94)
            MainFrame.Size = UDim2.new(1, -w, 1, -94)
            MainFrame.Position = UDim2.new(0, w, 0, 42)
            SidebarScroll.Size = UDim2.new(0, w, 1, 0)
            MainContentFrame.Size = UDim2.new(1, -w, 1, 0)
            MainContentFrame.Position = UDim2.new(0, w, 0, 0)
        end
    end

    function Window:SetSidebarCollapsed(collapsed)
        Window.SidebarCollapsed = (collapsed == true)
        local targetW = Window.SidebarCollapsed and (Window.CollapsedSidebarWidth or 48) or (Window.SidebarWidth or 175)
        local animTime = 0.22
        local ease = TweenInfo.new(animTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        TweenService:Create(LeftFrame, ease, {Size = UDim2.new(0, targetW, 1, -94)}):Play()
        TweenService:Create(MainFrame, ease, {Size = UDim2.new(1, -targetW, 1, -94), Position = UDim2.new(0, targetW, 0, 42)}):Play()
        TweenService:Create(SidebarScroll, ease, {Size = UDim2.new(0, targetW, 1, 0)}):Play()
        TweenService:Create(MainContentFrame, ease, {Size = UDim2.new(1, -targetW, 1, 0), Position = UDim2.new(0, targetW, 0, 0)}):Play()

        for name, tab in pairs(Window.Tabs) do
            if tab.Container then
                TweenService:Create(tab.Container, ease, {Size = UDim2.new(0, targetW - 8, 0, 34)}):Play()
            end
            if tab.Button then
                local fullTabName = tostring(tab.Name or name)
                if Window.SidebarCollapsed then
                    if tab.Icon then
                        tab.Button.Visible = false
                        TweenService:Create(tab.Icon, ease, {Position = UDim2.new(0.5, -9, 0.5, -9)}):Play()
                    else
                        tab.Button.Visible = true
                        tab.Button.Size = UDim2.new(1, 0, 1, 0)
                        tab.Button.Position = UDim2.new(0, 0, 0, 0)
                        tab.Button.TextSize = 11
                        tab.Button.Text = (string.len(fullTabName) > 4) and (string.sub(fullTabName, 1, 4) .. ".") or fullTabName
                    end
                else
                    if tab.Icon then
                        tab.Button.Visible = true
                        tab.Button.Size = UDim2.new(1, -38, 1, 0)
                        tab.Button.Position = UDim2.new(0, 34, 0, 0)
                        tab.Button.Text = fullTabName
                        TweenService:Create(tab.Icon, ease, {Position = UDim2.new(0, 10, 0.5, -9)}):Play()
                    else
                        tab.Button.Visible = true
                        tab.Button.Size = UDim2.new(1, 0, 1, 0)
                        tab.Button.Position = UDim2.new(0, 0, 0, 0)
                        tab.Button.TextSize = (Window.ActiveTab == name or Window.ActiveTab == tab.Name) and 18 or 16
                        tab.Button.Text = fullTabName
                    end
                end
            end
        end

        for _, div in ipairs(Window.SidebarDividers) do
            if div and div.Parent then
                local divW = Window.SidebarCollapsed and (targetW - 14) or (div.Name == "DIVIDEFRAME" and 140 or 115)
                TweenService:Create(div, ease, {Size = UDim2.new(0, divW, 0, div.Size.Y.Offset)}):Play()
            end
        end
    end

    function Window:ToggleSidebar()
        Window:SetSidebarCollapsed(not Window.SidebarCollapsed)
    end

    function Window:CreateTab(arg1, arg2, arg3, arg4)
        local tabName, layoutOrder, tabIcon, autoDivider
        if type(arg1) == "table" then
            tabName = arg1.Name or arg1.Title or arg1.TabName or arg1[1] or "Tab"
            layoutOrder = arg1.LayoutOrder or arg1.Order or arg1[2]
            tabIcon = arg1.Icon or arg1.IconAsset or arg1[3]
            autoDivider = arg1.AutoSmallDivider or arg1.Divider or arg1[4]
        else
            tabName = arg1 or "Tab"
            layoutOrder = arg2
            tabIcon = arg3
            autoDivider = arg4
        end

        if tabName and tostring(tabName):lower() == "settings" and Window.SettingsTab then
            return Window.SettingsTab
        end

        local totalTabs = 0
        for _ in pairs(Window.Tabs) do
            totalTabs = totalTabs + 1
        end

        if autoDivider or (Window.AutoSmallDividers and totalTabs > 0 and not Window._FirstTabCreated) then
            Window:AddSidebarSmallDivider((layoutOrder or (totalTabs + 1)) - 0.5)
        end
        Window._FirstTabCreated = true

        local TabContainer = Instance.new("Frame")
        TabContainer.Name = tabName
        TabContainer.Size = UDim2.new(0, 165, 0, 34)
        TabContainer.BackgroundTransparency = 1
        TabContainer.LayoutOrder = layoutOrder or (totalTabs + 1)
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

        local HoverGradient = Instance.new("UIGradient")
        HoverGradient.Name = "HoverGradient"
        HoverGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 1.0),
            NumberSequenceKeypoint.new(0.2, 0.90),
            NumberSequenceKeypoint.new(0.8, 0.90),
            NumberSequenceKeypoint.new(1.0, 1.0)
        })
        HoverGradient.Parent = HoverGlow

        local TabIcon = nil
        if tabIcon and tabIcon ~= "" and tabIcon ~= false then
            if type(tabIcon) == "number" or tostring(tabIcon):match("^%d+$") then
                tabIcon = "rbxassetid://" .. tostring(tabIcon)
            end
            TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "TabIcon"
            TabIcon.Size = UDim2.new(0, 18, 0, 18)
            TabIcon.Position = UDim2.new(0, 10, 0.5, -9)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = tabIcon
            TabIcon.ImageColor3 = Window.CurrentTheme.SubText
            TabIcon.ZIndex = 3
            TabIcon.Parent = TabContainer
        end

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TextButton"
        if TabIcon then
            TabButton.Size = UDim2.new(1, -38, 1, 0)
            TabButton.Position = UDim2.new(0, 34, 0, 0)
            TabButton.TextXAlignment = Enum.TextXAlignment.Left
        else
            TabButton.Size = UDim2.new(1, 0, 1, 0)
            TabButton.Position = UDim2.new(0, 0, 0, 0)
            TabButton.TextXAlignment = Enum.TextXAlignment.Center
        end
        TabButton.BackgroundTransparency = 1
        TabButton.FontFace = FontMichromaRegular
        TabButton.Text = tabName
        TabButton.TextColor3 = Window.CurrentTheme.SubText
        TabButton.TextSize = 16
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
        ContentFrame.ZIndex = 4
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
            Container = TabContainer,
            Button = TabButton,
            HoverGlow = HoverGlow,
            HoverGradient = HoverGradient,
            Icon = TabIcon,
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

            local pName = "User"
            if LocalPlayer then
                local dn = LocalPlayer.DisplayName
                local n  = LocalPlayer.Name
                if dn and dn ~= "" then
                    pName = dn
                elseif n and n ~= "" then
                    pName = n
                end
            end
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
            local btnTitle, btnDesc, btnCb, btnOpts
            if type(title) == "table" and not title.IsA then
                btnTitle = title.Title or title.Name or title.Text or title[1] or "Button"
                btnDesc = title.Desc or title.Description or title[2] or ""
                btnCb = title.Callback or title.OnClick or title.callback or title[3]
                btnOpts = title
            else
                btnTitle = title or "Button"
                btnDesc = desc or ""
                btnCb = callback
                btnOpts = {}
            end

            local CardFrame = Instance.new("Frame")
            CardFrame.Size = UDim2.new(1, -10, 0, 60)
            CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
            CardFrame.BorderSizePixel = 0
            CardFrame.Parent = ContentFrame

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            local hasDesc = btnDesc and btnDesc ~= ""

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FontMichromaBold
            TitleLabel.Text = btnTitle
            TitleLabel.TextColor3 = Window.CurrentTheme.Text
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = CardFrame

            if hasDesc then
                TitleLabel.Size = UDim2.new(1, -125, 0, 22)
                TitleLabel.Position = UDim2.new(0, 12, 0, 7)
                TitleLabel.TextSize = 14
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
            DescLabel.Text = hasDesc and btnDesc or ""
            DescLabel.TextColor3 = Window.CurrentTheme.SubText
            DescLabel.TextSize = 11
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Visible = hasDesc
            DescLabel.Parent = CardFrame

            local function ExecuteAction()
                Window:Notify("Executing", "Running " .. btnTitle .. "...", 2.5)
                task.spawn(function()
                    if type(btnCb) == "function" then
                        pcall(btnCb)
                    elseif type(btnCb) == "string" then
                        pcall(function() loadstring(btnCb)() end)
                    end
                end)
            end

            local ActionBtn = Window:CreateMDButton(CardFrame, UDim2.new(0, 110, 0, 30), UDim2.new(1, -120, 0.5, -15), (btnOpts and btnOpts.ButtonText) or "Execute", ExecuteAction, true)

            local buttonData = {
                CardFrame = CardFrame,
                TitleLabel = TitleLabel,
                DescLabel = DescLabel,
                Button = ActionBtn,
                Execute = ExecuteAction,
                SetText = function(self, newTitle)
                    btnTitle = tostring(newTitle or "")
                    TitleLabel.Text = btnTitle
                end,
                SetDescription = function(self, newDesc)
                    btnDesc = tostring(newDesc or "")
                    local hd = btnDesc ~= ""
                    DescLabel.Text = btnDesc
                    DescLabel.Visible = hd
                    if hd then
                        TitleLabel.Size = UDim2.new(1, -125, 0, 22)
                        TitleLabel.Position = UDim2.new(0, 12, 0, 7)
                        TitleLabel.TextSize = 14
                    else
                        TitleLabel.Size = UDim2.new(1, -125, 1, 0)
                        TitleLabel.Position = UDim2.new(0, 12, 0, 0)
                        TitleLabel.TextSize = 14
                    end
                end,
                RefreshTheme = function(theme)
                    CardFrame.BackgroundColor3 = theme.CardBG
                    TitleLabel.TextColor3 = theme.Text
                    DescLabel.TextColor3 = theme.SubText
                end
            }

            buttonData.WithCallback = function(self, cb)
                btnCb = cb
                return self
            end
            buttonData.WithTooltip = function(self, tt)
                if Window.AttachTooltip and CardFrame then
                    Window:AttachTooltip(CardFrame, tt)
                end
                return self
            end
            buttonData.WithSaveKey = function(self, key)
                if key and key ~= "" then
                    self.SaveKey = key
                end
                return self
            end
            buttonData.WithText = function(self, txt)
                self:SetText(txt)
                return self
            end
            buttonData.WithDescription = function(self, d)
                self:SetDescription(d)
                return self
            end

            if btnOpts and type(btnOpts) == "table" and (btnOpts.Tooltip or btnOpts.tooltip) then
                buttonData:WithTooltip(btnOpts.Tooltip or btnOpts.tooltip)
            end
            if btnOpts and type(btnOpts) == "table" and (btnOpts.SaveKey or btnOpts.saveKey) then
                buttonData:WithSaveKey(btnOpts.SaveKey or btnOpts.saveKey)
            end

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Button",
                Name = btnTitle or "Button",
                Desc = btnDesc or "",
                TabName = tabName,
                Instance = CardFrame,
                Callback = btnCb
            })

            return buttonData
        end

        function TabObj:AddLabel(textOrConfig, options)
            local labelText, descText, textColor, labelOptions
            if type(textOrConfig) == "table" and not textOrConfig.IsA then
                labelText = textOrConfig.Text or textOrConfig.Title or textOrConfig.Name or textOrConfig[1] or "Section Header"
                descText = textOrConfig.Desc or textOrConfig.Description or textOrConfig.SubText or textOrConfig[2]
                textColor = textOrConfig.Color or textOrConfig.TextColor
                labelOptions = textOrConfig
            else
                labelText = tostring(textOrConfig or "Section Header")
                if type(options) == "table" then
                    descText = options.Desc or options.Description or options.SubText
                    textColor = options.Color or options.TextColor
                    labelOptions = options
                elseif type(options) == "string" then
                    descText = options
                end
            end

            local hasDesc = descText and descText ~= ""
            local frameHeight = hasDesc and 40 or 26

            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = "MDLabelFrame_" .. labelText:gsub("%s+", "_")
            LabelFrame.Size = UDim2.new(1, -10, 0, frameHeight)
            LabelFrame.AutomaticSize = Enum.AutomaticSize.Y
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.BorderSizePixel = 0
            LabelFrame.ZIndex = 3
            LabelFrame.Parent = ContentFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "LabelTitle"
            TitleLabel.Size = UDim2.new(1, -12, 0, 20)
            TitleLabel.Position = UDim2.new(0, 6, 0, 2)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FontMichromaBold
            TitleLabel.Text = labelText
            TitleLabel.TextColor3 = textColor or Window.CurrentTheme.Text
            TitleLabel.TextSize = 14
            TitleLabel.TextWrapped = true
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            TitleLabel.ZIndex = 4
            TitleLabel.Parent = LabelFrame

            local DescLabel = nil
            if hasDesc then
                DescLabel = Instance.new("TextLabel")
                DescLabel.Name = "LabelDesc"
                DescLabel.Size = UDim2.new(1, -12, 0, 16)
                DescLabel.Position = UDim2.new(0, 6, 0, 22)
                DescLabel.BackgroundTransparency = 1
                DescLabel.FontFace = FontMichromaRegular
                DescLabel.Text = descText
                DescLabel.TextColor3 = Window.CurrentTheme.SubText
                DescLabel.TextSize = 11
                DescLabel.TextWrapped = true
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                DescLabel.TextYAlignment = Enum.TextYAlignment.Center
                DescLabel.ZIndex = 4
                DescLabel.Parent = LabelFrame
            end

            local labelObj = {
                Frame = LabelFrame,
                TitleLabel = TitleLabel,
                DescLabel = DescLabel,
                SetText = function(self, newText)
                    TitleLabel.Text = tostring(newText or "")
                end,
                SetDescription = function(self, newDesc)
                    if DescLabel then
                        DescLabel.Text = tostring(newDesc or "")
                    end
                end,
                SetColor = function(self, newCol)
                    if newCol then
                        TitleLabel.TextColor3 = newCol
                    end
                end,
                RefreshTheme = function(theme)
                    if not textColor then
                        TitleLabel.TextColor3 = theme.Text
                    end
                    if DescLabel then
                        DescLabel.TextColor3 = theme.SubText
                    end
                end
            }

            labelObj.WithTooltip = function(self, tt)
                if Window.AttachTooltip and LabelFrame then
                    Window:AttachTooltip(LabelFrame, tt)
                end
                return self
            end
            labelObj.WithText = function(self, txt)
                self:SetText(txt)
                return self
            end
            labelObj.WithColor = function(self, col)
                self:SetColor(col)
                return self
            end

            if labelOptions and type(labelOptions) == "table" and (labelOptions.Tooltip or labelOptions.tooltip) then
                labelObj:WithTooltip(labelOptions.Tooltip or labelOptions.tooltip)
            end

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return labelObj
        end

        function TabObj:AddDivider(options)
            local divHeight = (type(options) == "table" and (options.Height or options.height)) or (type(options) == "number" and options) or 8
            local divThickness = (type(options) == "table" and (options.Thickness or options.thickness)) or 1.2
            local divColor = type(options) == "table" and (options.Color or options.color) or nil

            local DividerContainer = Instance.new("Frame")
            DividerContainer.Name = "MDContentDivider"
            DividerContainer.Size = UDim2.new(1, -10, 0, divHeight)
            DividerContainer.BackgroundTransparency = 1
            DividerContainer.BorderSizePixel = 0
            DividerContainer.ZIndex = 3
            DividerContainer.Parent = ContentFrame

            local Line = Instance.new("Frame")
            Line.Name = "Line"
            Line.Size = UDim2.new(1, -16, 0, divThickness)
            Line.Position = UDim2.new(0, 8, 0.5, -math.floor(divThickness / 2))
            Line.BackgroundColor3 = divColor or Window.CurrentTheme.Divider or Window.CurrentTheme.CardBG
            Line.BackgroundTransparency = 0.4
            Line.BorderSizePixel = 0
            Line.ZIndex = 4
            Line.Parent = DividerContainer

            local LineCorner = Instance.new("UICorner")
            LineCorner.CornerRadius = UDim.new(1, 0)
            LineCorner.Parent = Line

            local dividerObj = {
                Frame = DividerContainer,
                Line = Line,
                SetVisible = function(self, vis)
                    DividerContainer.Visible = (vis ~= false)
                end,
                SetColor = function(self, col)
                    Line.BackgroundColor3 = col
                end,
                RefreshTheme = function(theme)
                    if not divColor then
                        Line.BackgroundColor3 = theme.Divider or theme.CardBG
                    end
                end
            }

            dividerObj.WithVisible = function(self, vis)
                self:SetVisible(vis)
                return self
            end

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return dividerObj
        end

        function TabObj:AddNumberInput(titleOrConfig, options, callback, parentRow, position, sizeFraction)
            local title, minVal, maxVal, defaultVal, stepVal, cb, inputOpts
            if type(titleOrConfig) == "table" and not titleOrConfig.IsA then
                title = titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1] or "Number Input"
                minVal = titleOrConfig.Min or titleOrConfig.min or 0
                maxVal = titleOrConfig.Max or titleOrConfig.max or 100
                defaultVal = titleOrConfig.Default or titleOrConfig.default or minVal
                stepVal = titleOrConfig.Step or titleOrConfig.step or 1
                cb = titleOrConfig.Callback or titleOrConfig.callback or titleOrConfig.OnChanged or titleOrConfig[2]
                inputOpts = titleOrConfig
                parentRow = titleOrConfig.Parent or titleOrConfig.Row or parentRow
                position = titleOrConfig.Position or position
                sizeFraction = titleOrConfig.Size or titleOrConfig.Fraction or sizeFraction
            else
                title = tostring(titleOrConfig or "Number Input")
                if type(options) == "table" then
                    minVal = options.Min or options.min or 0
                    maxVal = options.Max or options.max or 100
                    defaultVal = options.Default or options.default or minVal
                    stepVal = options.Step or options.step or 1
                    cb = options.Callback or options.callback or callback
                    inputOpts = options
                else
                    minVal = 0
                    maxVal = 100
                    defaultVal = tonumber(options) or 0
                    stepVal = 1
                    cb = callback
                    inputOpts = {}
                end
            end

            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local cardSize = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 52) or UDim2.new(1, -10, 0, 52))
            local pos = position or UDim2.new(0, 0, 0, 0)
            local suffix = (inputOpts and inputOpts.Suffix) or ""

            local currentValue = math.clamp(tonumber(defaultVal) or minVal, minVal, maxVal)

            local CardFrame = Instance.new("Frame")
            CardFrame.Name = "MDNumberInputCard_" .. title:gsub("%s+", "_")
            CardFrame.Size = cardSize
            CardFrame.Position = pos
            CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
            CardFrame.BackgroundTransparency = 0.05
            CardFrame.BorderSizePixel = 0
            CardFrame.ZIndex = 10
            CardFrame.Parent = targetParent

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            AddUIShadow(CardFrame, 20, 0.5)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "TitleLabel"
            TitleLabel.Size = UDim2.new(1, -145, 1, 0)
            TitleLabel.Position = UDim2.new(0, 14, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FontMichromaRegular
            TitleLabel.Text = title
            TitleLabel.TextColor3 = Window.CurrentTheme.Text
            TitleLabel.TextSize = 13
            TitleLabel.TextWrapped = true
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            TitleLabel.ZIndex = 11
            TitleLabel.Parent = CardFrame

            local ControlBox = Instance.new("Frame")
            ControlBox.Name = "ControlBox"
            ControlBox.Size = UDim2.new(0, 126, 0, 32)
            ControlBox.Position = UDim2.new(1, -136, 0.5, -16)
            ControlBox.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(230, 234, 242) or Color3.fromRGB(20, 22, 28)
            ControlBox.BackgroundTransparency = 0.1
            ControlBox.BorderSizePixel = 0
            ControlBox.ZIndex = 11
            ControlBox.Parent = CardFrame

            local ControlCorner = Instance.new("UICorner")
            ControlCorner.CornerRadius = UDim.new(0, 6)
            ControlCorner.Parent = ControlBox

            local ControlStroke = Instance.new("UIStroke")
            ControlStroke.Thickness = 1.0
            ControlStroke.Color = Color3.fromRGB(255, 255, 255)
            ControlStroke.Transparency = 0.8
            ControlStroke.Parent = ControlBox

            local MinusBtn = Instance.new("TextButton")
            MinusBtn.Name = "MinusBtn"
            MinusBtn.Size = UDim2.new(0, 30, 1, 0)
            MinusBtn.Position = UDim2.new(0, 0, 0, 0)
            MinusBtn.BackgroundColor3 = Window.CurrentTheme.ButtonBG
            MinusBtn.BackgroundTransparency = 0.2
            MinusBtn.BorderSizePixel = 0
            MinusBtn.FontFace = FontMichromaBold
            MinusBtn.Text = "-"
            MinusBtn.TextColor3 = Window.CurrentTheme.Text
            MinusBtn.TextSize = 16
            MinusBtn.ZIndex = 12
            MinusBtn.Parent = ControlBox

            local MinusCorner = Instance.new("UICorner")
            MinusCorner.CornerRadius = UDim.new(0, 6)
            MinusCorner.Parent = MinusBtn

            local PlusBtn = Instance.new("TextButton")
            PlusBtn.Name = "PlusBtn"
            PlusBtn.Size = UDim2.new(0, 30, 1, 0)
            PlusBtn.Position = UDim2.new(1, -30, 0, 0)
            PlusBtn.BackgroundColor3 = Window.CurrentTheme.ButtonBG
            PlusBtn.BackgroundTransparency = 0.2
            PlusBtn.BorderSizePixel = 0
            PlusBtn.FontFace = FontMichromaBold
            PlusBtn.Text = "+"
            PlusBtn.TextColor3 = Window.CurrentTheme.Text
            PlusBtn.TextSize = 15
            PlusBtn.ZIndex = 12
            PlusBtn.Parent = ControlBox

            local PlusCorner = Instance.new("UICorner")
            PlusCorner.CornerRadius = UDim.new(0, 6)
            PlusCorner.Parent = PlusBtn

            local NumberBox = Instance.new("TextBox")
            NumberBox.Name = "NumberBox"
            NumberBox.Size = UDim2.new(1, -64, 1, 0)
            NumberBox.Position = UDim2.new(0, 32, 0, 0)
            NumberBox.BackgroundTransparency = 1
            NumberBox.FontFace = FontMichromaRegular
            NumberBox.Text = tostring(currentValue) .. suffix
            NumberBox.TextColor3 = Window.CurrentTheme.Text
            NumberBox.TextSize = 12
            NumberBox.TextXAlignment = Enum.TextXAlignment.Center
            NumberBox.ClearTextOnFocus = false
            NumberBox.ZIndex = 12
            NumberBox.Parent = ControlBox

            local function FormatDisplay(val)
                return tostring(val) .. suffix
            end

            local saveKey = (inputOpts and (inputOpts.SaveKey or inputOpts.saveKey)) or title
            local numberObj = {
                Name = title,
                SaveKey = saveKey,
                TabName = tabName,
                CardFrame = CardFrame,
                TitleLabel = TitleLabel,
                ControlBox = ControlBox,
                NumberBox = NumberBox,
                MinusBtn = MinusBtn,
                PlusBtn = PlusBtn,
                GetValue = function() return currentValue end,
                SetValue = function(self, newVal, triggerCb)
                    local parsed = tonumber(newVal)
                    if parsed then
                        currentValue = math.clamp(parsed, minVal, maxVal)
                        if stepVal >= 1 and math.floor(stepVal) == stepVal then
                            currentValue = math.floor(currentValue + 0.5)
                        end
                    end
                    NumberBox.Text = FormatDisplay(currentValue)
                    if triggerCb and cb then
                        pcall(cb, currentValue)
                    end
                end,
                RefreshTheme = function(theme)
                    CardFrame.BackgroundColor3 = theme.CardBG
                    TitleLabel.TextColor3 = theme.Text
                    ControlBox.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(230, 234, 242) or Color3.fromRGB(20, 22, 28)
                    MinusBtn.BackgroundColor3 = theme.ButtonBG
                    MinusBtn.TextColor3 = theme.Text
                    PlusBtn.BackgroundColor3 = theme.ButtonBG
                    PlusBtn.TextColor3 = theme.Text
                    NumberBox.TextColor3 = theme.Text
                end
            }

            local function StepValue(delta)
                PlayClickSFX()
                local newVal = math.clamp(currentValue + delta, minVal, maxVal)
                if stepVal >= 1 and math.floor(stepVal) == stepVal then
                    newVal = math.floor(newVal + 0.5)
                end
                currentValue = newVal
                NumberBox.Text = FormatDisplay(currentValue)
                if cb then
                    pcall(cb, currentValue)
                end
            end

            TrackConn(MinusBtn.MouseButton1Click:Connect(function()
                StepValue(-stepVal)
            end))

            TrackConn(PlusBtn.MouseButton1Click:Connect(function()
                StepValue(stepVal)
            end))

            TrackConn(NumberBox.FocusLost:Connect(function()
                local cleanText = NumberBox.Text:gsub("[^%-%d%.]", "")
                local parsed = tonumber(cleanText)
                if parsed then
                    currentValue = math.clamp(parsed, minVal, maxVal)
                    if stepVal >= 1 and math.floor(stepVal) == stepVal then
                        currentValue = math.floor(currentValue + 0.5)
                    end
                end
                NumberBox.Text = FormatDisplay(currentValue)
                if cb then
                    pcall(cb, currentValue)
                end
            end))

            numberObj.WithCallback = function(self, fn)
                cb = fn
                return self
            end
            numberObj.WithTooltip = function(self, tt)
                if Window.AttachTooltip and CardFrame then
                    Window:AttachTooltip(CardFrame, tt)
                end
                return self
            end
            numberObj.WithSaveKey = function(self, key)
                if key and key ~= "" then
                    self.SaveKey = key
                    Window.RegisteredNumberInputs[key] = self
                end
                return self
            end
            numberObj.WithValue = function(self, v, triggerCb)
                self:SetValue(v, triggerCb)
                return self
            end
            numberObj.WithMin = function(self, mn)
                minVal = mn
                return self
            end
            numberObj.WithMax = function(self, mx)
                maxVal = mx
                return self
            end
            numberObj.WithStep = function(self, st)
                stepVal = st
                return self
            end

            if inputOpts and type(inputOpts) == "table" and (inputOpts.Tooltip or inputOpts.tooltip) then
                numberObj:WithTooltip(inputOpts.Tooltip or inputOpts.tooltip)
            end
            if inputOpts and type(inputOpts) == "table" and (inputOpts.SaveKey or inputOpts.saveKey) then
                numberObj:WithSaveKey(inputOpts.SaveKey or inputOpts.saveKey)
            end

            if saveKey and saveKey ~= "" then
                Window.RegisteredNumberInputs[saveKey] = numberObj
            end
            table.insert(Window.RegisteredNumberInputsList, numberObj)

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            table.insert(Window.SearchableItems, {
                Type = "NumberInput",
                Name = title or "NumberInput",
                Desc = "",
                TabName = tabName,
                Instance = CardFrame
            })

            return numberObj
        end
        TabObj.AddSpinbox = TabObj.AddNumberInput

        function TabObj:AddMultiDropdown(titleOrConfig, options, defaultSelections, onSelect, parentRow, position, sizeFraction)
            local title, dropOpts, defSels, cb, multiOpts
            if type(titleOrConfig) == "table" and not titleOrConfig.IsA then
                title = titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1] or "Select Options"
                dropOpts = titleOrConfig.Options or titleOrConfig.options or titleOrConfig[2] or {}
                defSels = titleOrConfig.Default or titleOrConfig.default or titleOrConfig.Selections or titleOrConfig[3] or {}
                cb = titleOrConfig.Callback or titleOrConfig.OnSelect or titleOrConfig.callback or titleOrConfig[4]
                multiOpts = titleOrConfig
                parentRow = titleOrConfig.Parent or titleOrConfig.Row or parentRow
                position = titleOrConfig.Position or position
                sizeFraction = titleOrConfig.Size or titleOrConfig.Fraction or sizeFraction
            else
                title = tostring(titleOrConfig or "Select Options")
                dropOpts = options or {}
                defSels = defaultSelections or {}
                cb = onSelect
                multiOpts = {}
            end

            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local cardSize = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 44) or UDim2.new(1, -10, 0, 44))
            local pos = position or UDim2.new(0, 0, 0, 0)

            local selectedMap = {}
            if type(defSels) == "table" then
                for k, v in pairs(defSels) do
                    if type(k) == "number" then
                        selectedMap[tostring(v)] = true
                    elseif v == true then
                        selectedMap[tostring(k)] = true
                    end
                end
            elseif type(defSels) == "string" then
                selectedMap[defSels] = true
            end

            local function GetSelectedList()
                local list = {}
                for opt, isSel in pairs(selectedMap) do
                    if isSel then table.insert(list, opt) end
                end
                table.sort(list)
                return list
            end

            local CardFrame = Instance.new("Frame")
            CardFrame.Name = GenerateSafeName("Card")
            CardFrame.Size = cardSize
            CardFrame.Position = pos
            CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
            CardFrame.BackgroundTransparency = 0.05
            CardFrame.BorderSizePixel = 0
            CardFrame.ZIndex = 10
            CardFrame.Parent = targetParent

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            AddUIShadow(CardFrame, 20, 0.5)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "DropdownTitle"
            TitleLabel.Size = UDim2.new(1, -40, 1, 0)
            TitleLabel.Position = UDim2.new(0, 14, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FontMichromaRegular
            TitleLabel.Text = title
            TitleLabel.TextColor3 = Window.CurrentTheme.Text
            TitleLabel.TextSize = 14
            TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            TitleLabel.ZIndex = 11
            TitleLabel.Parent = CardFrame

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Name = "ArrowIcon"
            ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
            ArrowIcon.Position = UDim2.new(1, -26, 0.5, -7)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://6031091004"
            ArrowIcon.ImageColor3 = Window.CurrentTheme.Text
            ArrowIcon.ZIndex = 11
            ArrowIcon.Parent = CardFrame

            local ClickButton = Instance.new("TextButton")
            ClickButton.Name = "ClickButton"
            ClickButton.Size = UDim2.new(1, 0, 1, 0)
            ClickButton.BackgroundTransparency = 1
            ClickButton.Text = ""
            ClickButton.ZIndex = 12
            ClickButton.Parent = CardFrame

            local function UpdateTitleDisplay()
                local count = 0
                for _, sel in pairs(selectedMap) do
                    if sel then count = count + 1 end
                end
                if count == 0 then
                    TitleLabel.Text = title .. ": None"
                elseif count == 1 then
                    local single = GetSelectedList()[1] or "1 selected"
                    TitleLabel.Text = title .. ": " .. single
                else
                    TitleLabel.Text = title .. ": (" .. tostring(count) .. " Selected)"
                end
            end
            UpdateTitleDisplay()

            local DropdownMenu = Instance.new("Frame")
            DropdownMenu.Name = GenerateSafeName("Menu")
            DropdownMenu.Size = UDim2.new(0, 200, 0, 0)
            DropdownMenu.BackgroundColor3 = Window.CurrentTheme.CardBG
            DropdownMenu.BackgroundTransparency = 0.05
            DropdownMenu.BorderSizePixel = 0
            DropdownMenu.ClipsDescendants = true
            DropdownMenu.ZIndex = 600
            DropdownMenu.Visible = false
            DropdownMenu.Parent = Window.DropdownOverlay or MainContainer

            local MenuCorner = Instance.new("UICorner")
            MenuCorner.CornerRadius = UDim.new(0, 8)
            MenuCorner.Parent = DropdownMenu

            local MenuStroke = Instance.new("UIStroke")
            MenuStroke.Thickness = 1.2
            MenuStroke.Color = Color3.fromRGB(255, 255, 255)
            MenuStroke.Transparency = 0.6
            MenuStroke.Parent = DropdownMenu

            AddUIShadow(DropdownMenu, 20, 0.5)

            local MenuScroll = Instance.new("ScrollingFrame")
            MenuScroll.Size = UDim2.new(1, -8, 1, -8)
            MenuScroll.Position = UDim2.new(0, 4, 0, 4)
            MenuScroll.BackgroundTransparency = 1
            MenuScroll.BorderSizePixel = 0
            MenuScroll.ScrollBarThickness = 2
            MenuScroll.ScrollBarImageColor3 = Window.CurrentTheme.Divider
            MenuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            MenuScroll.ZIndex = 601
            MenuScroll.Parent = DropdownMenu

            local MenuLayout = Instance.new("UIListLayout")
            MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
            MenuLayout.Padding = UDim.new(0, 4)
            MenuLayout.Parent = MenuScroll

            local isOpen = false

            local function RefreshOptions()
                for _, child in ipairs(MenuScroll:GetChildren()) do
                    if child:IsA("GuiObject") then child:Destroy() end
                end

                for _, opt in ipairs(dropOpts) do
                    local optStr = tostring(opt)
                    local isSelected = selectedMap[optStr] == true

                    local itemBtn = Instance.new("TextButton")
                    itemBtn.Name = "Option_" .. optStr
                    itemBtn.Size = UDim2.new(1, 0, 0, 28)
                    itemBtn.BackgroundColor3 = isSelected and Window.CurrentTheme.ButtonBG or Color3.fromRGB(0, 0, 0)
                    itemBtn.BackgroundTransparency = isSelected and 0.15 or 0.8
                    itemBtn.Text = ""
                    itemBtn.ZIndex = 602
                    itemBtn.Parent = MenuScroll

                    local itemCorner = Instance.new("UICorner")
                    itemCorner.CornerRadius = UDim.new(0, 6)
                    itemCorner.Parent = itemBtn

                    local checkIcon = Instance.new("TextLabel")
                    checkIcon.Size = UDim2.new(0, 20, 1, 0)
                    checkIcon.Position = UDim2.new(0, 4, 0, 0)
                    checkIcon.BackgroundTransparency = 1
                    checkIcon.FontFace = FontMichromaBold
                    checkIcon.Text = isSelected and "[✓]" or "[  ]"
                    checkIcon.TextColor3 = isSelected and Color3.fromRGB(80, 255, 140) or Window.CurrentTheme.SubText
                    checkIcon.TextSize = 10
                    checkIcon.ZIndex = 603
                    checkIcon.Parent = itemBtn

                    local itemLabel = Instance.new("TextLabel")
                    itemLabel.Size = UDim2.new(1, -30, 1, 0)
                    itemLabel.Position = UDim2.new(0, 26, 0, 0)
                    itemLabel.BackgroundTransparency = 1
                    itemLabel.FontFace = FontMichromaRegular
                    itemLabel.Text = optStr
                    itemLabel.TextColor3 = isSelected and Window.CurrentTheme.Text or Window.CurrentTheme.SubText
                    itemLabel.TextSize = 12
                    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                    itemLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    itemLabel.ZIndex = 603
                    itemLabel.Parent = itemBtn

                    itemBtn.MouseButton1Click:Connect(function()
                        PlayClickSFX()
                        selectedMap[optStr] = not selectedMap[optStr]
                        local nowSel = selectedMap[optStr]
                        checkIcon.Text = nowSel and "[✓]" or "[  ]"
                        checkIcon.TextColor3 = nowSel and Color3.fromRGB(80, 255, 140) or Window.CurrentTheme.SubText
                        itemLabel.TextColor3 = nowSel and Window.CurrentTheme.Text or Window.CurrentTheme.SubText
                        itemBtn.BackgroundColor3 = nowSel and Window.CurrentTheme.ButtonBG or Color3.fromRGB(0, 0, 0)
                        itemBtn.BackgroundTransparency = nowSel and 0.15 or 0.8
                        UpdateTitleDisplay()
                        if cb then
                            pcall(cb, GetSelectedList(), optStr, nowSel)
                        end
                    end)
                end
            end

            local function CloseDropdown()
                if not isOpen then return end
                isOpen = false
                TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                TweenService:Create(DropdownMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, DropdownMenu.Size.X.Offset, 0, 0)
                }):Play()
                task.delay(0.21, function()
                    if not isOpen then DropdownMenu.Visible = false end
                end)
            end

            local function OpenDropdown()
                if isOpen then
                    CloseDropdown()
                    return
                end
                if Window.ActiveDropdown and Window.ActiveDropdown.Close then
                    pcall(function() Window.ActiveDropdown.Close() end)
                end
                Window.ActiveDropdown = { Close = CloseDropdown }

                RefreshOptions()
                isOpen = true
                local overlay = Window.DropdownOverlay or MainContainer
                if DropdownMenu.Parent ~= overlay then
                    DropdownMenu.Parent = overlay
                end

                local absPos = CardFrame.AbsolutePosition
                local absSize = CardFrame.AbsoluteSize
                local overlayPos = (overlay and overlay.AbsolutePosition) or Vector2.new(0, 0)
                local scale = (UIScaleConstraint and UIScaleConstraint.Scale > 0) and UIScaleConstraint.Scale or 1.0

                local relX = (absPos.X - overlayPos.X) / scale
                local relY = (absPos.Y - overlayPos.Y + absSize.Y + 4) / scale
                local width = absSize.X / scale
                local height = math.min(#dropOpts * 32 + 10, 160)

                DropdownMenu.Position = UDim2.new(0, relX, 0, relY)
                DropdownMenu.Size = UDim2.new(0, width, 0, 0)
                DropdownMenu.Visible = true

                TweenService:Create(ArrowIcon, TweenInfo.new(0.2), {Rotation = 180}):Play()
                TweenService:Create(DropdownMenu, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, width, 0, height)
                }):Play()
            end

            TrackConn(ClickButton.MouseButton1Click:Connect(function()
                PlayClickSFX()
                OpenDropdown()
            end))

            local saveKey = (multiOpts and (multiOpts.SaveKey or multiOpts.saveKey)) or title
            local multiDropData = {
                Name = title,
                SaveKey = saveKey,
                TabName = tabName,
                CardFrame = CardFrame,
                Menu = DropdownMenu,
                Close = CloseDropdown,
                Open = OpenDropdown,
                GetSelections = GetSelectedList,
                SetSelections = function(self, listOrMap, triggerCb)
                    selectedMap = {}
                    if type(listOrMap) == "table" then
                        for k, v in pairs(listOrMap) do
                            if type(k) == "number" then
                                selectedMap[tostring(v)] = true
                            elseif v == true then
                                selectedMap[tostring(k)] = true
                            end
                        end
                    elseif type(listOrMap) == "string" then
                        selectedMap[listOrMap] = true
                    end
                    UpdateTitleDisplay()
                    RefreshOptions()
                    if triggerCb and cb then
                        pcall(cb, GetSelectedList(), nil, nil)
                    end
                end,
                Select = function(self, opt, triggerCb)
                    selectedMap[tostring(opt)] = true
                    UpdateTitleDisplay()
                    RefreshOptions()
                    if triggerCb and cb then pcall(cb, GetSelectedList(), opt, true) end
                end,
                Deselect = function(self, opt, triggerCb)
                    selectedMap[tostring(opt)] = nil
                    UpdateTitleDisplay()
                    RefreshOptions()
                    if triggerCb and cb then pcall(cb, GetSelectedList(), opt, false) end
                end,
                Toggle = function(self, opt, triggerCb)
                    local cur = selectedMap[tostring(opt)] == true
                    selectedMap[tostring(opt)] = not cur
                    UpdateTitleDisplay()
                    RefreshOptions()
                    if triggerCb and cb then pcall(cb, GetSelectedList(), opt, not cur) end
                end,
                RefreshOptions = RefreshOptions,
                SetOptions = function(selfOrOpts, maybeOpts)
                    local newOpts = (type(selfOrOpts) == "table" and selfOrOpts ~= multiDropData) and selfOrOpts or maybeOpts or {}
                    dropOpts = newOpts
                    RefreshOptions()
                    return multiDropData
                end,
                AddOption = function(selfOrOpt, maybeOpt)
                    local newOpt = (type(selfOrOpt) == "string" or type(selfOrOpt) == "number") and selfOrOpt or maybeOpt
                    if newOpt then
                        table.insert(dropOpts, tostring(newOpt))
                        RefreshOptions()
                    end
                    return multiDropData
                end,
                RemoveOption = function(selfOrOpt, maybeOpt)
                    local optToRemove = (type(selfOrOpt) == "string" or type(selfOrOpt) == "number") and tostring(selfOrOpt) or tostring(maybeOpt or "")
                    for i, v in ipairs(dropOpts) do
                        if tostring(v) == optToRemove then
                            table.remove(dropOpts, i)
                            break
                        end
                    end
                    selectedMap[optToRemove] = nil
                    UpdateTitleDisplay()
                    RefreshOptions()
                    return multiDropData
                end,
                ClearOptions = function()
                    dropOpts = {}
                    selectedMap = {}
                    UpdateTitleDisplay()
                    RefreshOptions()
                    return multiDropData
                end,
                RefreshTheme = function(theme)
                    CardFrame.BackgroundColor3 = theme.CardBG
                    TitleLabel.TextColor3 = theme.Text
                    ArrowIcon.ImageColor3 = theme.Text
                    DropdownMenu.BackgroundColor3 = theme.CardBG
                    MenuScroll.ScrollBarImageColor3 = theme.Divider
                    RefreshOptions()
                end
            }

            multiDropData.WithCallback = function(self, fn)
                cb = fn
                return self
            end
            multiDropData.WithTooltip = function(self, tt)
                if Window.AttachTooltip and CardFrame then
                    Window:AttachTooltip(CardFrame, tt)
                end
                return self
            end
            multiDropData.WithSaveKey = function(self, key)
                if key and key ~= "" then
                    self.SaveKey = key
                    Window.RegisteredMultiDropdowns[key] = self
                end
                return self
            end
            multiDropData.WithSelections = function(self, sels, triggerCb)
                self:SetSelections(sels, triggerCb)
                return self
            end

            if multiOpts and type(multiOpts) == "table" and (multiOpts.Tooltip or multiOpts.tooltip) then
                multiDropData:WithTooltip(multiOpts.Tooltip or multiOpts.tooltip)
            end
            if multiOpts and type(multiOpts) == "table" and (multiOpts.SaveKey or multiOpts.saveKey) then
                multiDropData:WithSaveKey(multiOpts.SaveKey or multiOpts.saveKey)
            end

            if saveKey and saveKey ~= "" then
                Window.RegisteredMultiDropdowns[saveKey] = multiDropData
            end
            table.insert(Window.RegisteredMultiDropdownsList, multiDropData)

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            table.insert(Window.SearchableItems, {
                Type = "MultiDropdown",
                Name = title or "MultiDropdown",
                Desc = "",
                TabName = tabName,
                Instance = CardFrame
            })

            return multiDropData
        end

        function TabObj:AddProgressBar(titleOrConfig, options)
            local title, initialPct, statusText, cardOpts
            if type(titleOrConfig) == "table" and not titleOrConfig.IsA then
                title = titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1] or "Progress"
                initialPct = titleOrConfig.Progress or titleOrConfig.Value or titleOrConfig.Default or titleOrConfig[2] or 0
                statusText = titleOrConfig.Status or titleOrConfig.Desc or titleOrConfig[3] or ""
                cardOpts = titleOrConfig
            else
                title = tostring(titleOrConfig or "Progress")
                if type(options) == "table" then
                    initialPct = options.Progress or options.Value or options.Default or 0
                    statusText = options.Status or options.Desc or ""
                    cardOpts = options
                elseif type(options) == "number" then
                    initialPct = options
                    statusText = ""
                    cardOpts = {}
                else
                    initialPct = 0
                    statusText = tostring(options or "")
                    cardOpts = {}
                end
            end

            if initialPct > 1 then initialPct = initialPct / 100 end
            initialPct = math.clamp(initialPct, 0, 1)

            local CardFrame = Instance.new("Frame")
            CardFrame.Name = "MDProgressBarCard_" .. title:gsub("%s+", "_")
            CardFrame.Size = UDim2.new(1, -10, 0, 52)
            CardFrame.BackgroundColor3 = Window.CurrentTheme.CardBG
            CardFrame.BackgroundTransparency = 0.05
            CardFrame.BorderSizePixel = 0
            CardFrame.ZIndex = 10
            CardFrame.Parent = ContentFrame

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 8)
            CardCorner.Parent = CardFrame

            AddUIShadow(CardFrame, 20, 0.5)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "ProgressTitle"
            TitleLabel.Size = UDim2.new(1, -120, 0, 20)
            TitleLabel.Position = UDim2.new(0, 14, 0, 7)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.FontFace = FontMichromaRegular
            TitleLabel.Text = title
            TitleLabel.TextColor3 = Window.CurrentTheme.Text
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            TitleLabel.ZIndex = 11
            TitleLabel.Parent = CardFrame

            local StatusLabel = Instance.new("TextLabel")
            StatusLabel.Name = "ProgressStatus"
            StatusLabel.Size = UDim2.new(0, 100, 0, 20)
            StatusLabel.Position = UDim2.new(1, -14, 0, 7)
            StatusLabel.AnchorPoint = Vector2.new(1, 0)
            StatusLabel.BackgroundTransparency = 1
            StatusLabel.FontFace = FontMichromaRegular
            StatusLabel.Text = (statusText ~= "" and statusText) or (tostring(math.floor(initialPct * 100)) .. "%")
            StatusLabel.TextColor3 = Window.CurrentTheme.SubText
            StatusLabel.TextSize = 12
            StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
            StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
            StatusLabel.ZIndex = 11
            StatusLabel.Parent = CardFrame

            local TrackFrame = Instance.new("Frame")
            TrackFrame.Name = "TrackFrame"
            TrackFrame.Size = UDim2.new(1, -28, 0, 8)
            TrackFrame.Position = UDim2.new(0, 14, 0, 32)
            TrackFrame.BackgroundColor3 = (Window.CurrentTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(25, 28, 36)
            TrackFrame.BackgroundTransparency = 0.2
            TrackFrame.BorderSizePixel = 0
            TrackFrame.ClipsDescendants = true
            TrackFrame.ZIndex = 11
            TrackFrame.Parent = CardFrame

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = TrackFrame

            local FillBar = Instance.new("Frame")
            FillBar.Name = "FillBar"
            FillBar.Size = UDim2.new(initialPct, 0, 1, 0)
            FillBar.Position = UDim2.new(0, 0, 0, 0)
            FillBar.BackgroundColor3 = (cardOpts and cardOpts.Color) or Window.CurrentTheme.Divider or Window.CurrentTheme.AccentBG
            FillBar.BorderSizePixel = 0
            FillBar.ZIndex = 12
            FillBar.Parent = TrackFrame

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = FillBar

            local currentProgress = initialPct

            local progressObj = {
                CardFrame = CardFrame,
                TitleLabel = TitleLabel,
                StatusLabel = StatusLabel,
                Track = TrackFrame,
                Fill = FillBar,
                GetProgress = function() return currentProgress end,
                SetProgress = function(self, pct, newStatus, animated)
                    if pct > 1 then pct = pct / 100 end
                    currentProgress = math.clamp(pct, 0, 1)
                    local targetSize = UDim2.new(currentProgress, 0, 1, 0)
                    if animated ~= false then
                        TweenService:Create(FillBar, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = targetSize
                        }):Play()
                    else
                        FillBar.Size = targetSize
                    end
                    if newStatus ~= nil then
                        StatusLabel.Text = tostring(newStatus)
                    else
                        StatusLabel.Text = tostring(math.floor(currentProgress * 100)) .. "%"
                    end
                end,
                SetStatus = function(self, newStatus)
                    StatusLabel.Text = tostring(newStatus or "")
                end,
                SetTitle = function(self, newTitle)
                    TitleLabel.Text = tostring(newTitle or "")
                end,
                SetColor = function(self, col)
                    FillBar.BackgroundColor3 = col
                end,
                RefreshTheme = function(theme)
                    CardFrame.BackgroundColor3 = theme.CardBG
                    TitleLabel.TextColor3 = theme.Text
                    StatusLabel.TextColor3 = theme.SubText
                    TrackFrame.BackgroundColor3 = (theme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(25, 28, 36)
                    if not (cardOpts and cardOpts.Color) then
                        FillBar.BackgroundColor3 = theme.Divider or theme.AccentBG
                    end
                end
            }

            progressObj.WithProgress = function(self, pct, stat, anim)
                self:SetProgress(pct, stat, anim)
                return self
            end
            progressObj.WithStatus = function(self, stat)
                self:SetStatus(stat)
                return self
            end
            progressObj.WithTooltip = function(self, tt)
                if Window.AttachTooltip and CardFrame then
                    Window:AttachTooltip(CardFrame, tt)
                end
                return self
            end

            if cardOpts and type(cardOpts) == "table" and (cardOpts.Tooltip or cardOpts.tooltip) then
                progressObj:WithTooltip(cardOpts.Tooltip or cardOpts.tooltip)
            end

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            table.insert(Window.SearchableItems, {
                Type = "ProgressBar",
                Name = title or "Progress",
                Desc = statusText,
                TabName = tabName,
                Instance = CardFrame
            })

            return progressObj
        end
        TabObj.AddStatusCard = TabObj.AddProgressBar

        function TabObj:AddItems(itemList)
            if type(itemList) ~= "table" then return {} end
            local created = {}
            for idx, item in ipairs(itemList) do
                if type(item) == "table" then
                    local iType = (item.Type or item.type or "Button"):lower()
                    local element = nil

                    if iType == "toggle" then
                        element = TabObj:AddToggle(item)
                    elseif iType == "slider" then
                        element = TabObj:AddSlider(item)
                    elseif iType == "button" then
                        element = TabObj:AddButton(item.Name or item.Title or item.Text or ("Button " .. idx), item.Desc or item.Description, item.Callback or item.OnClick)
                    elseif iType == "longbutton" then
                        element = TabObj:AddLongButton(item)
                    elseif iType == "dropdown" then
                        element = TabObj:AddDropdown(item.Title or item.Name or ("Dropdown " .. idx), item.Options or item.options or {}, item.Default or item.default, item.Callback or item.OnSelect)
                    elseif iType == "multidropdown" or iType == "multiselect" then
                        element = TabObj:AddMultiDropdown(item)
                    elseif iType == "numberinput" or iType == "spinbox" or iType == "number" then
                        element = TabObj:AddNumberInput(item)
                    elseif iType == "textbox" or iType == "input" then
                        element = TabObj:AddTextbox(item)
                    elseif iType == "colorpicker" or iType == "color" then
                        element = TabObj:AddColorPicker(item.Title or item.Name or "Color", item.Default or item.Color or Color3.fromRGB(255, 255, 255), item.Callback)
                    elseif iType == "progressbar" or iType == "progress" or iType == "status" then
                        element = TabObj:AddProgressBar(item)
                    elseif iType == "label" or iType == "header" or iType == "section" then
                        element = TabObj:AddLabel(item)
                    elseif iType == "divider" or iType == "separator" then
                        element = TabObj:AddDivider(item)
                    elseif iType == "toggleslider" then
                        element = TabObj:AddToggleSlider(item)
                    elseif iType == "togglegroup" then
                        element = TabObj:AddToggleGroup(item.Toggles or item.List or item)
                    elseif iType == "mobilebutton" then
                        element = Window:CreateMobileButton(item)
                    end

                    if element then
                        table.insert(created, element)
                        local key = item.Name or item.Title or item.SaveKey or item.Text
                        if key and key ~= "" then
                            created[key] = element
                        end
                    end
                end
            end
            return created
        end
        TabObj.AddElements = TabObj.AddItems

        function TabObj:SaveConfig(configName)
            return Window:SaveTabConfig(tabName, configName)
        end
        function TabObj:LoadConfig(configName)
            return Window:LoadTabConfig(tabName, configName)
        end

        function TabObj:AddRow(height, padding)
            height = height or 31
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

            local RowObj = {
                Frame = RowFrame,
                Instance = RowFrame,
            }

            function RowObj:AddButton(text, callback, sizeFraction)
                return TabObj:AddLongButton(text, callback, sizeFraction or 0.5, RowFrame)
            end
            function RowObj:AddLongButton(text, callback, sizeFraction)
                return TabObj:AddLongButton(text, callback, sizeFraction or 0.5, RowFrame)
            end
            function RowObj:AddToggle(titleOrConfig, initialState, onToggle, sizeFraction)
                return TabObj:AddToggle(titleOrConfig, initialState, onToggle, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddDropdown(title, options, defaultOption, onSelect, sizeFraction)
                return TabObj:AddDropdown(title, options, defaultOption, onSelect, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddMultiDropdown(titleOrConfig, options, defaultSelections, onSelect, sizeFraction)
                return TabObj:AddMultiDropdown(titleOrConfig, options, defaultSelections, onSelect, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddNumberInput(titleOrConfig, options, callback, sizeFraction)
                return TabObj:AddNumberInput(titleOrConfig, options, callback, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddSpinbox(titleOrConfig, options, callback, sizeFraction)
                return TabObj:AddNumberInput(titleOrConfig, options, callback, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddTextbox(title, placeholder, defaultText, onSubmit, sizeFraction)
                return TabObj:AddTextbox(title, placeholder, defaultText, onSubmit, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddColorPicker(title, defaultColor, callback, sizeFraction)
                return TabObj:AddColorPicker(title, defaultColor, callback, RowFrame, nil, sizeFraction or 0.5)
            end
            function RowObj:AddSlider(title, min, max, default, callback, sizeFraction, options)
                if type(title) == "table" then
                    return TabObj:AddSlider(title, RowFrame, nil, nil, nil, nil, sizeFraction)
                end
                return TabObj:AddSlider(title, min, max, default, callback, options or sizeFraction, RowFrame)
            end

            setmetatable(RowObj, {
                __index = function(t, k)
                    return RowFrame[k]
                end,
                __newindex = function(t, k, v)
                    RowFrame[k] = v
                end,
            })

            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return RowObj
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
                if typeof(arg3) == "Instance" or (type(arg3) == "table" and (arg3.Frame or arg3.Instance)) then
                    parentRow = arg3
                    position = arg4
                else
                    sizeInput = arg3
                    parentRow = arg4
                    position = arg5
                end
            end

            parentRow = ResolveParent(parentRow)
            local fraction, explicitUDim = ResolveSizeFraction(sizeInput, parentRow and 0.5 or 1.0)
            local targetParent = parentRow
            local finalSize

            if explicitUDim then
                finalSize = explicitUDim
                targetParent = targetParent or ContentFrame
            elseif targetParent then
                finalSize = ComputeRowItemWidth(fraction or 0.5, 31)
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
                        TabObj.CurrentAutoRow = TabObj:AddRow(31, 8)
                        TabObj.CurrentAutoRowRemaining = 1.0
                    end

                    targetParent = TabObj.CurrentAutoRow
                    finalSize = ComputeRowItemWidth(fraction, 31)
                    TabObj.CurrentAutoRowRemaining = (TabObj.CurrentAutoRowRemaining or 1.0) - fraction
                    if TabObj.CurrentAutoRowRemaining <= 0.05 then
                        TabObj.CurrentAutoRow = nil
                    end
                else
                    TabObj.CurrentAutoRow = nil
                    TabObj.CurrentAutoRowRemaining = 0
                    targetParent = ContentFrame
                    finalSize = UDim2.new(1, -10, 0, 31)
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
            height = height or 31
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

        function TabObj:AddDropdown(titleOrConfig, options, defaultOption, onSelect, parentRow, position, sizeFraction, dropConfig)
            local title, dropOpts, defOpt, cb, cfg
            if type(titleOrConfig) == "table" and not titleOrConfig.IsA then
                title = titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1] or "Dropdown"
                dropOpts = titleOrConfig.Options or titleOrConfig.options or titleOrConfig[2] or {}
                defOpt = titleOrConfig.Default or titleOrConfig.default or titleOrConfig[3]
                cb = titleOrConfig.Callback or titleOrConfig.OnSelect or titleOrConfig.callback or titleOrConfig[4]
                parentRow = titleOrConfig.Parent or titleOrConfig.Row or parentRow
                position = titleOrConfig.Position or position
                sizeFraction = titleOrConfig.Size or titleOrConfig.Fraction or sizeFraction
                cfg = titleOrConfig
            else
                title = titleOrConfig or "Dropdown"
                dropOpts = options or {}
                defOpt = defaultOption
                cb = onSelect
                cfg = dropConfig
            end

            parentRow = ResolveParent(parentRow)
            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local size = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 44) or UDim2.new(1, -10, 0, 44))
            local pos = position or UDim2.new(0, 0, 0, 0)
            local dropObj = Window:CreateMDDropdown(targetParent, pos, size, title, dropOpts, defOpt, cb, cfg)
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

        function TabObj:AddTextbox(titleOrConfig, placeholder, defaultText, onSubmit, parentRow, position, sizeFraction, boxOptions)
            local title, ph, def, cb, opts
            if type(titleOrConfig) == "table" and not titleOrConfig.IsA then
                title = titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1] or "Input"
                ph = titleOrConfig.Placeholder or titleOrConfig.placeholder or titleOrConfig[2] or "Type here..."
                def = titleOrConfig.Default or titleOrConfig.default or titleOrConfig[3] or ""
                cb = titleOrConfig.Callback or titleOrConfig.OnSubmit or titleOrConfig.callback or titleOrConfig[4]
                opts = titleOrConfig
                parentRow = titleOrConfig.Parent or titleOrConfig.Row or parentRow
                position = titleOrConfig.Position or position
                sizeFraction = titleOrConfig.Size or titleOrConfig.Fraction or sizeFraction
            else
                title = titleOrConfig or "Input"
                ph = placeholder or "Type here..."
                def = defaultText or ""
                cb = onSubmit
                opts = boxOptions
            end

            parentRow = ResolveParent(parentRow)
            local targetParent = parentRow or ContentFrame
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, parentRow and 0.5 or 1.0)
            local size = explicitUDim or (parentRow and ComputeRowItemWidth(fraction or 0.5, 50) or UDim2.new(1, -10, 0, 50))
            local pos = position or UDim2.new(0, 0, 0, 0)
            local boxObj = Window:CreateMDTextbox(targetParent, pos, size, title, ph, def, cb, opts)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            table.insert(Window.SearchableItems, {
                Type = "Textbox",
                Name = title or "Textbox",
                Desc = ph or "",
                TabName = tabName,
                Instance = boxObj.Frame
            })

            return boxObj
        end

        function TabObj:AddColorPicker(title, defaultColor, callback, parentRow, position, sizeFraction)
            parentRow = ResolveParent(parentRow)
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
            local text, state, cb, bind, connectMode, sliderConfig

            if type(titleOrConfig) == "table" and not titleOrConfig.IsA then
                text = titleOrConfig.Title or titleOrConfig.Name or titleOrConfig.Text or titleOrConfig[1] or "Toggle"
                state = titleOrConfig.Default or titleOrConfig.Value or titleOrConfig.State or titleOrConfig[2]
                cb = titleOrConfig.Callback or titleOrConfig.OnChanged or titleOrConfig.callback or titleOrConfig[3]
                bind = titleOrConfig
                connectMode = titleOrConfig.Connect or titleOrConfig.Connected or titleOrConfig.PositionInGroup
                sliderConfig = titleOrConfig.Slider or titleOrConfig.ConnectedSlider
                sizeFraction = titleOrConfig.Size or titleOrConfig.Fraction or sizeFraction
                parentRow = titleOrConfig.Parent or titleOrConfig.Row or parentRow
                position = titleOrConfig.Position or position
            else
                text = tostring(titleOrConfig or "Toggle")
                state = initialState
                cb = onToggle
                bind = bindConfig
            end

            parentRow = ResolveParent(parentRow)
            targetParent = parentRow or ContentFrame
            local isToggleGroup = parentRow and parentRow.Name == "ToggleGroup"
            local fraction, explicitUDim = ResolveSizeFraction(sizeFraction, (parentRow and not isToggleGroup) and 0.5 or 1.0)
            local defaultH = sliderConfig and 76 or 44
            local size = explicitUDim or (isToggleGroup and UDim2.new(1, 0, 0, defaultH)) or (parentRow and ComputeRowItemWidth(fraction or 0.5, defaultH)) or UDim2.new(1, -10, 0, defaultH)
            local pos = position or UDim2.new(0, 0, 0, 0)

            local toggleData = Window:CreateMDToggleHalf(targetParent, pos, size, text, state, cb, bind, connectMode)
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

            if sliderConfig then
                toggleData:AddSlider(sliderConfig)
            end

            table.insert(Window.SearchableItems, {
                Type = "Toggle",
                Name = text or "Toggle",
                Desc = "",
                TabName = tabName,
                Instance = toggleData.Frame
            })

            return toggleData
        end

        function TabObj:AddMobileButton(arg1, arg2, arg3, arg4, arg5)
            return Window:CreateMobileButton(arg1, arg2, arg3, arg4, arg5)
        end
        TabObj.CreateMobileButton = TabObj.AddMobileButton

        function TabObj:AddToggleGroup(toggleList)
            if type(toggleList) ~= "table" then return {} end
            local count = #toggleList
            if count == 0 then return {} end

            local GroupFrame = Instance.new("Frame")
            GroupFrame.Name = "ToggleGroup"
            GroupFrame.Size = UDim2.new(1, -10, 0, 0)
            GroupFrame.AutomaticSize = Enum.AutomaticSize.Y
            GroupFrame.BackgroundTransparency = 1
            GroupFrame.BorderSizePixel = 0
            GroupFrame.ZIndex = 10
            GroupFrame.Parent = ContentFrame

            local GroupLayout = Instance.new("UIListLayout")
            GroupLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupLayout.Padding = UDim.new(0, 0)
            GroupLayout.Parent = GroupFrame

            local results = {}
            for i, item in ipairs(toggleList) do
                local config
                if type(item) == "table" and not item.IsA then
                    config = item
                else
                    config = { Name = tostring(item) }
                end
                local connectMode
                if count == 1 then
                    connectMode = nil
                elseif i == 1 then
                    connectMode = "Top"
                elseif i == count then
                    connectMode = "Bottom"
                else
                    connectMode = "Middle"
                end
                config.Connect = config.Connect or connectMode
                config.Parent = GroupFrame
                local toggle = TabObj:AddToggle(config)
                table.insert(results, toggle)
            end
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
            return results
        end

        function TabObj:AddToggleSlider(config)
            if type(config) ~= "table" then return end
            local toggle = TabObj:AddToggle({
                Name = config.Name or config.Title or "Toggle",
                Default = config.Default or config.ToggleDefault or false,
                Callback = config.Callback or config.ToggleCallback,
                Bind = config.Bind or config.Keybind or config.DefaultBind,
                Connect = config.Connect
            })
            local slider = toggle:AddSlider(config.Slider or config)
            return toggle, slider
        end

        function TabObj:AddHalfToggle(text, initialState, onToggle, parentRow, position)
            return TabObj:AddToggle(text, initialState, onToggle, parentRow, position)
        end

        function TabObj:AddSlider(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
            local targetParent = ContentFrame
            local pos = UDim2.new(0, 0, 0, 0)
            local sliderName = nil
            local minVal, maxVal, defaultVal, onValueChange, sliderOptions
            local customParent = false

            if type(arg1) == "string" then
                sliderName = arg1
                if type(arg2) == "table" then
                    minVal = arg2.Min or arg2.min or 0
                    maxVal = arg2.Max or arg2.max or 100
                    defaultVal = arg2.Default or arg2.default or minVal
                    onValueChange = arg2.Callback or arg2.callback or arg2.OnChanged
                    sliderOptions = arg2
                    if arg3 then targetParent = arg3 customParent = true end
                    pos = arg4 or pos
                else
                    minVal = arg2 or 0
                    maxVal = arg3 or 100
                    defaultVal = arg4 or minVal
                    onValueChange = arg5
                    sliderOptions = arg6
                    if typeof(arg6) == "Instance" then targetParent = arg6 customParent = true
                    elseif typeof(arg7) == "Instance" then targetParent = arg7 customParent = true end
                    pos = (typeof(arg7) == "UDim2" and arg7) or pos
                end
            elseif type(arg1) == "table" then
                sliderName = arg1.Title or arg1.Name or arg1.Text
                minVal = arg1.Min or arg1.min or 0
                maxVal = arg1.Max or arg1.max or 100
                defaultVal = arg1.Default or arg1.default or minVal
                onValueChange = arg1.Callback or arg1.callback or arg1.OnChanged
                sliderOptions = arg1
                if arg2 then
                    targetParent = arg2
                    customParent = true
                elseif arg1.Parent or arg1.Row or arg1.parentRow then
                    targetParent = arg1.Parent or arg1.Row or arg1.parentRow
                    customParent = true
                end
                pos = arg3 or pos
            else
                minVal = arg1 or 0
                maxVal = arg2 or 100
                defaultVal = arg3 or minVal
                onValueChange = arg4
                sliderOptions = arg5
                if typeof(arg5) == "Instance" then targetParent = arg5 customParent = true
                elseif typeof(arg6) == "Instance" then targetParent = arg6 customParent = true end
                pos = (typeof(arg6) == "UDim2" and arg6) or (typeof(arg7) == "UDim2" and arg7) or pos
            end

            targetParent = ResolveParent(targetParent)
            local suffix = (type(sliderOptions) == "table" and (sliderOptions.Suffix or (sliderOptions.ValueFormat == "percent" and "%") or ""))
                or (type(sliderOptions) == "string" and sliderOptions)
                or ""
            local isCard = not customParent or targetParent == ContentFrame or (targetParent and targetParent.Name == "RowFrame")

            if isCard and (type(sliderOptions) ~= "table" or sliderOptions.AsCard ~= false) then
                local isRow = targetParent and targetParent.Name == "RowFrame"
                local cardSize = isRow and UDim2.new(0.485, -4, 0, 56) or UDim2.new(1, -10, 0, 56)

                local SliderCard = Instance.new("Frame")
                SliderCard.Name = (sliderName or "Slider") .. "_Card"
                SliderCard.Size = cardSize
                SliderCard.Position = pos
                SliderCard.BackgroundColor3 = Window.CurrentTheme.CardBG
                SliderCard.BackgroundTransparency = 0.05
                SliderCard.BorderSizePixel = 0
                SliderCard.ZIndex = 10
                SliderCard.Parent = targetParent

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 8)
                CardCorner.Parent = SliderCard

                AddUIShadow(SliderCard, 20, 0.5)

                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "SliderTitle"
                TitleLabel.Size = UDim2.new(1, -95, 0, 20)
                TitleLabel.Position = UDim2.new(0, 14, 0, 8)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.FontFace = FontMichromaRegular
                TitleLabel.Text = sliderName or "Slider"
                TitleLabel.TextColor3 = Window.CurrentTheme.Text
                TitleLabel.TextSize = 14
                TitleLabel.TextWrapped = true
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
                TitleLabel.ZIndex = 11
                TitleLabel.Parent = SliderCard

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "ValueLabel"
                ValueLabel.Size = UDim2.new(0, 80, 0, 20)
                ValueLabel.Position = UDim2.new(1, -14, 0, 8)
                ValueLabel.AnchorPoint = Vector2.new(1, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.FontFace = FontMichromaRegular
                ValueLabel.TextColor3 = Window.CurrentTheme.Text
                ValueLabel.TextSize = 11
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                ValueLabel.ZIndex = 11
                ValueLabel.Parent = SliderCard

                local effectiveOpts = {}
                if type(sliderOptions) == "table" then
                    for k, v in pairs(sliderOptions) do
                        effectiveOpts[k] = v
                    end
                elseif type(sliderOptions) == "string" then
                    effectiveOpts.Suffix = sliderOptions
                elseif type(sliderOptions) == "number" then
                    effectiveOpts.Increment = sliderOptions
                end
                effectiveOpts.ShowValue = false

                local sliderData
                sliderData = Window:CreateMDSlider(SliderCard, UDim2.new(0, 14, 0, 34), UDim2.new(1, -28, 0, 12), minVal, maxVal, defaultVal, function(val, pct)
                    ValueLabel.Text = sliderData and sliderData.GetFormattedValue(val, pct) or (tostring(val) .. suffix)
                    if onValueChange then
                        pcall(onValueChange, val, pct)
                    end
                end, sliderName, effectiveOpts)

                ValueLabel.Text = sliderData.GetFormattedValue(sliderData.GetValue())

                sliderData.CardFrame = SliderCard
                sliderData.TitleLabel = TitleLabel
                sliderData.ValueLabel = ValueLabel

                local oldSetSuffix = sliderData.SetSuffix
                sliderData.SetSuffix = function(newSuffix)
                    if oldSetSuffix then oldSetSuffix(newSuffix) end
                    ValueLabel.Text = sliderData.GetFormattedValue()
                end

                local oldSetPrefix = sliderData.SetPrefix
                sliderData.SetPrefix = function(newPrefix)
                    if oldSetPrefix then oldSetPrefix(newPrefix) end
                    ValueLabel.Text = sliderData.GetFormattedValue()
                end

                local oldSetValueFormat = sliderData.SetValueFormat
                sliderData.SetValueFormat = function(format, newSuffix, newPrefix)
                    if oldSetValueFormat then oldSetValueFormat(format, newSuffix, newPrefix) end
                    ValueLabel.Text = sliderData.GetFormattedValue()
                end

                local oldSetValue = sliderData.SetValue
                sliderData.SetValue = function(val, triggerCallback)
                    if oldSetValue then oldSetValue(val, triggerCallback) end
                    ValueLabel.Text = sliderData.GetFormattedValue()
                end

                local oldSetIncrement = sliderData.SetIncrement
                sliderData.SetIncrement = function(newInc, newPrec)
                    if oldSetIncrement then oldSetIncrement(newInc, newPrec) end
                    ValueLabel.Text = sliderData.GetFormattedValue()
                end

                local oldRefresh = sliderData.RefreshTheme
                sliderData.RefreshTheme = function(theme)
                    if oldRefresh then oldRefresh(theme) end
                    SliderCard.BackgroundColor3 = theme.CardBG
                    TitleLabel.TextColor3 = theme.Text
                    ValueLabel.TextColor3 = theme.Text
                end

                ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
                table.insert(Window.SearchableItems, {
                    Type = "Slider",
                    Name = sliderName or "Slider",
                    Desc = "",
                    TabName = tabName,
                    Instance = SliderCard
                })
                return sliderData
            else
                local size = (targetParent and targetParent.Name == "RowFrame") and UDim2.new(0.485, -4, 0, 14) or UDim2.new(1, -10, 0, 14)
                local sliderData = Window:CreateMDSlider(targetParent, pos, size, minVal, maxVal, defaultVal, onValueChange, sliderName, sliderOptions)
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
        end

        TrackConn(TabButton.MouseEnter:Connect(function()
            PlayHoverSFX()
            if Window.ActiveTab ~= tabName then
                -- Hover on inactive tab: invisible (1.0) at ends -> barely visible (0.90) in middle -> invisible (1.0)
                HoverGlow.BackgroundTransparency = 0
                HoverGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0.0, 1.0),
                    NumberSequenceKeypoint.new(0.2, 0.90),
                    NumberSequenceKeypoint.new(0.8, 0.90),
                    NumberSequenceKeypoint.new(1.0, 1.0)
                })
                TweenService:Create(TabButton, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextColor3 = Window.CurrentTheme.Text}):Play()
                if TabIcon then
                    TweenService:Create(TabIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = Window.CurrentTheme.Text}):Play()
                end
            end
        end))

        TrackConn(TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= tabName then
                -- Leaving inactive tab: hide glow entirely
                TweenService:Create(HoverGlow, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                HoverGradient.Transparency = NumberSequence.new(1)
                TweenService:Create(TabButton, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextColor3 = Window.CurrentTheme.SubText}):Play()
                if TabIcon then
                    TweenService:Create(TabIcon, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = Window.CurrentTheme.SubText}):Play()
                end
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
                    if oldTabData.HoverGradient then
                        oldTabData.HoverGradient.Transparency = NumberSequence.new(1)
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
            HoverGlow.BackgroundTransparency = 0
            HoverGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.0, 1.0),
                NumberSequenceKeypoint.new(0.2, 0.75),
                NumberSequenceKeypoint.new(0.8, 0.75),
                NumberSequenceKeypoint.new(1.0, 1.0)
            })
        else
            ContentFrame.Visible = false
            ContentFrame.Position = UDim2.new(0, 0, 0, 0)
            TabButton.TextColor3 = Window.CurrentTheme.SubText
            TabButton.TextSize = 16
            TabButton.FontFace = FontMichromaRegular
            HoverGlow.BackgroundTransparency = 1
            HoverGradient.Transparency = NumberSequence.new(1)
        end

        return TabObj
    end

    -- =========================================================================
    -- DEFAULT BUILT-IN SETTINGS TAB BUILDER
    -- =========================================================================
    local function CreateDefaultSettingsTab()
        Window:AddSidebarBigDivider(998)
        local SettingsTab = Window:CreateTab("Settings", 999)

        -- 1. Enable Notifications
        local notifToggle = SettingsTab:AddToggle({
            Title = "Enable notifications",
            Default = Window.NotificationsEnabled,
            Callback = function(state)
                Window.NotificationsEnabled = state
                if state then
                    Window:Notify("Settings", "Notifications enabled", 2)
                end
            end
        })
        Window.RegisteredToggles["Notifications"] = notifToggle

        -- 2. Enable UI Sounds
        local soundToggle = SettingsTab:AddToggle({
            Title = "Enable UI sounds",
            Default = Window.UISoundsEnabled,
            Callback = function(state)
                Window:SetUISounds(state)
                if state then
                    Window:Notify("Settings", "UI sounds enabled", 2)
                end
            end
        })
        Window.RegisteredToggles["UISounds"] = soundToggle

        -- 3. UI Sound Volume
        local currentVolPct = math.floor((Window.SoundVolume or 0.8) * 100)
        local volSlider = SettingsTab:AddSlider({
            Title = "UI sound volume",
            Min = 0,
            Max = 100,
            Default = currentVolPct,
            Suffix = "%",
            Callback = function(val, pct)
                Window:SetSoundVolume(pct)
            end
        })
        Window.RegisteredSliders["SoundVolume"] = volSlider

        -- 4. Spiderweb Background
        local webToggle = SettingsTab:AddToggle({
            Title = "Spiderweb background",
            Default = Window.SpiderwebBGEnabled,
            Callback = function(state)
                Window:SetSpiderwebBackground(state)
                if state then
                    Window:Notify("Settings", "Spiderweb background enabled", 2)
                else
                    Window:Notify("Settings", "Spiderweb background disabled", 2)
                end
            end
        })
        Window.RegisteredToggles["SpiderwebBG"] = webToggle

        -- 5. Background Blur
        local blurToggle = SettingsTab:AddToggle({
            Title = "Background blur",
            Default = Window.BackgroundBlurEnabled,
            Callback = function(state)
                Window:SetBackgroundBlur(state)
                if state then
                    Window:Notify("Settings", "Background blur enabled", 2)
                else
                    Window:Notify("Settings", "Background blur disabled", 2)
                end
            end
        })
        Window.RegisteredToggles["BackgroundBlur"] = blurToggle

        -- 6. Background Transparency
        local currentTransPct = math.floor((Window.CustomBGTransparency or 0.10) * 100)
        local transSlider = SettingsTab:AddSlider({
            Title = "Background transparency",
            Min = 0,
            Max = 90,
            Default = currentTransPct,
            Suffix = "%",
            Callback = function(val, pct)
                Window:SetBackgroundTransparency(val / 100)
            end
        })
        Window.RegisteredSliders["BGTransparency"] = transSlider

        -- 7. Custom Theme Builder
        local customThemeCP = SettingsTab:AddColorPicker(
            "Custom theme",
            Window.CustomThemeColor or Window.CurrentTheme.ButtonBG,
            function(newCol)
                Window:ApplyCustomTheme(newCol)
            end
        )
        Window.RegisteredColorPickers["CustomTheme"] = customThemeCP

        -- 8. Enable Click Effects
        local clickToggle = SettingsTab:AddToggle({
            Title = "Enable click effects",
            Default = Window.ClickEffectsEnabled,
            Callback = function(state)
                Window.ClickEffectsEnabled = state
                if state then
                    Window:Notify("Settings", "Click effects enabled", 2)
                else
                    Window:Notify("Settings", "Click effects disabled", 2)
                end
            end
        })
        Window.RegisteredToggles["ClickEffects"] = clickToggle

        -- 9. Particle Customization Row (Dropdown + Custom Image Textbox)
        local ParticleRow = SettingsTab:AddRow(31, 8)
        local particleOptions = {"Theme default", "Leaves", "Gems", "Sparkles", "Rings", "Dots", "Custom image"}
        SettingsTab:AddDropdown({
            Title = "Particle style",
            Options = particleOptions,
            Default = Window.ClickParticleType or "Theme default",
            Callback = function(selected)
                Window.ClickParticleType = selected
                Window:Notify("Settings", "Particle style: " .. selected:lower(), 2)
            end,
            Parent = ParticleRow,
            Size = 0.5
        })

        SettingsTab:AddTextbox({
            Title = "Custom image ID",
            Placeholder = "rbxassetid://...",
            Default = Window.CustomParticleAsset or "",
            Callback = function(entered)
                Window.CustomParticleAsset = entered
                if entered ~= "" then
                    Window:Notify("Settings", "Custom particle image updated", 2)
                end
            end,
            Parent = ParticleRow,
            Size = 0.5
        })

        -- 10. Configurations Management Section
        SettingsTab:CreateConfigSection()

        -- 7. Theme Presets Card
        local ThemeCard = Instance.new("Frame")
        ThemeCard.Name = "ThemeCard"
        ThemeCard.Size = UDim2.new(1, -10, 0, 0)
        ThemeCard.AutomaticSize = Enum.AutomaticSize.Y
        ThemeCard.BackgroundColor3 = Window.CurrentTheme.CardBG
        ThemeCard.ZIndex = 3
        ThemeCard.ClipsDescendants = false
        ThemeCard.Parent = SettingsTab.ContentFrame

        local ThemeCardCorner = Instance.new("UICorner")
        ThemeCardCorner.CornerRadius = UDim.new(0, 8)
        ThemeCardCorner.Parent = ThemeCard
        AddUIShadow(ThemeCard, 12, 0.45)

        local ThemeCardPadding = Instance.new("UIPadding")
        ThemeCardPadding.PaddingTop = UDim.new(0, 8)
        ThemeCardPadding.PaddingBottom = UDim.new(0, 12)
        ThemeCardPadding.PaddingLeft = UDim.new(0, 12)
        ThemeCardPadding.PaddingRight = UDim.new(0, 12)
        ThemeCardPadding.Parent = ThemeCard

        local ThemeTitle = Instance.new("TextLabel")
        ThemeTitle.Name = "ThemeTitle"
        ThemeTitle.Size = UDim2.new(1, 0, 0, 22)
        ThemeTitle.Position = UDim2.new(0, 0, 0, 0)
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
        ThemeContainer.Size = UDim2.new(1, 0, 0, 0)
        ThemeContainer.AutomaticSize = Enum.AutomaticSize.Y
        ThemeContainer.Position = UDim2.new(0, 0, 0, 28)
        ThemeContainer.BackgroundTransparency = 1
        ThemeContainer.Parent = ThemeCard

        local ThemeGridLayout = Instance.new("UIGridLayout")
        ThemeGridLayout.CellSize = UDim2.new(0.31, 0, 0, 36)
        ThemeGridLayout.CellPadding = UDim2.new(0.03, 0, 0, 8)
        ThemeGridLayout.Parent = ThemeContainer

        local ThemePresetBtnMap = {}
        for themeKey, themeData in pairs(Library.ThemePresets) do
            local btnData = Window:CreateMDButtonLong(ThemeContainer, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0), themeData.Name or themeKey, function()
                Window:ApplyTheme(themeKey)
            end)
            ThemePresetBtnMap[themeKey] = btnData
        end
        Window.ThemeCard = ThemeCard
        Window.ThemeContainer = ThemeContainer
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
        if Window.ActiveDropdown then
            pcall(function() Window.ActiveDropdown.Close() end)
        end
        IsAnimatingMinimize = true
        PlayClickSFX()

        LocalUIBlurPart.Transparency = 1
        LocalUIBlurPart.CFrame = CFrame.new(0, 999999, 0)
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
        if Window.BackgroundBlurEnabled and UpdateLocalUIBlur then
            pcall(UpdateLocalUIBlur)
        end
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
        if MobileUI and MobileUI.Parent then MobileUI:Destroy() end
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

            -- 2. Trigger active keybinds (works when UI is open or minimized)
            local boundBadge = Window.KeybindMap and Window.KeybindMap[input.KeyCode]
            if boundBadge and boundBadge.OnTrigger then
                local now = os.clock()
                if (now - (boundBadge._lastTrigger or 0)) >= 0.22 then
                    boundBadge._lastTrigger = now
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
    Window.MinGrad1 = MinGrad1
    Window.MinGrad2 = MinGrad2
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

        if themeKey == "Custom" then
            Window.IsCustomTheme = true
        else
            Window.IsCustomTheme = false
            Window.CustomThemeColor = nil
            if Window.RegisteredColorPickers and Window.RegisteredColorPickers["CustomTheme"] then
                pcall(function()
                    Window.RegisteredColorPickers["CustomTheme"].SetColor(newTheme.ButtonBG, false)
                end)
            end
        end

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

        if Window.SidebarCollapseBtn then
            Window.SidebarCollapseBtn.ImageColor3 = newTheme.Text
        end

        if Window.BottomGradient then
            Window.BottomGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, newTheme.BottomGradient[1]),
                ColorSequenceKeypoint.new(0.496, newTheme.BottomGradient[2]),
                ColorSequenceKeypoint.new(1, newTheme.BottomGradient[3])
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
            if btnData and btnData.RefreshTheme then
                pcall(function() btnData.RefreshTheme(newTheme) end)
            elseif btnData and btnData.Frame and btnData.Frame.Parent then
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
            if toggle and toggle.RefreshTheme then
                pcall(function() toggle.RefreshTheme(newTheme) end)
            elseif toggle and toggle.Frame and toggle.Frame.Parent then
                if toggle.Overlay then toggle.Overlay.ImageColor3 = newTheme.ButtonBG end
                local isToggled = (toggle.GetState and toggle.GetState())
                toggle.Frame.BackgroundColor3 = isToggled and newTheme.ButtonBG or ((newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(200, 205, 215) or Color3.fromRGB(35, 38, 48))
            end
        end

        for _, slider in ipairs(Window.RegisteredMDSliders) do
            if slider and slider.RefreshTheme then
                pcall(function() slider.RefreshTheme(newTheme) end)
            elseif slider and slider.Track and slider.Track.Parent then
                slider.Track.BackgroundColor3 = (newTheme.CardBG == Color3.fromRGB(255, 255, 255)) and Color3.fromRGB(220, 225, 235) or Color3.fromRGB(20, 22, 28)
                if slider.FilledPart then slider.FilledPart.BackgroundColor3 = newTheme.ButtonBG end
                if slider.Overlay then slider.Overlay.ImageColor3 = newTheme.ButtonBG end
                if slider.ValueLabel then slider.ValueLabel.TextColor3 = newTheme.Text end
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
                    if b.DeleteBtn then
                        b.DeleteBtn.ImageColor3 = newTheme.Text
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
                if tabData.Icon then
                    tabData.Icon.ImageColor3 = (name == Window.ActiveTab) and newTheme.Text or newTheme.SubText
                end

                if tabData.ContentFrame then
                    tabData.ContentFrame.ScrollBarImageColor3 = newTheme.Divider
                    for _, card in ipairs(tabData.ContentFrame:GetChildren()) do
                        if card:IsA("Frame") and card.Name ~= "MainHeaderFrame" and card.Name ~= "DropdownOverlay" then
                            if card.Name == "RowContainer" or card.Name == "RowFrame" or card.Name == "ParticleRow" or card.Name == "ToggleGroup" or card.Name:find("Row") or card.Name:find("Group") then
                                card.BackgroundTransparency = 1
                                for _, subCard in ipairs(card:GetChildren()) do
                                    if subCard:IsA("Frame") then
                                        if subCard.Name ~= "MDButtonCard" and subCard.Name ~= "TogglePill" and subCard.Name ~= "DropdownContent" then
                                            subCard.BackgroundColor3 = newTheme.CardBG
                                        end
                                        for _, child in ipairs(subCard:GetChildren()) do
                                            if child:IsA("TextLabel") then
                                                if child.Name == "CardTitle" or child.Name == "btntext" or child.Name == "drpdwntext" or child.Name == "TitleLabel" or child.Name == "SliderTitle" or child.Name == "ValueLabel" or child.Name:find("Title") or child.Name:find("Label") then
                                                    child.TextColor3 = newTheme.Text
                                                elseif child.Name == "CardBody" or child.Name == "DescLabel" or child.Name:find("Desc") then
                                                    child.TextColor3 = newTheme.SubText
                                                end
                                            elseif child.Name == "CardDividerLine" then
                                                child.BackgroundTransparency = 1
                                            end
                                        end
                                    end
                                end
                            elseif card.Name ~= "MDButtonCard" and card.Name ~= "DropdownContent" then
                                card.BackgroundColor3 = newTheme.CardBG
                                for _, child in ipairs(card:GetChildren()) do
                                    if child:IsA("TextLabel") then
                                        if child.Name == "CardTitle" or child.Name == "btntext" or child.Name == "drpdwntext" or child.Name == "TitleLabel" or child.Name == "SliderTitle" or child.Name == "ValueLabel" or child.Name == "ThemeTitle" or child.Name == "SectionTitle" or child.Name == "NotifLabel" or child.Name == "SoundLabel" or child.Name == "VolumeLabel" or child.Name == "WebTitle" or child.Name == "BlurTitle" or child.Name == "TransLabel" or child.Name == "CustomThemeTitle" or child.Name == "ClickEffectsTitle" or child.Name == "Welcomemsg" or child.Name:find("Title") or child.Name:find("Label") then
                                            child.TextColor3 = newTheme.Text
                                        elseif child.Name == "CardBody" or child.Name == "DescLabel" or child.Name == "WebDesc" or child.Name == "BlurDesc" or child.Name == "CustomThemeDesc" or child.Name == "ClickEffectsDesc" or child.Name:find("Desc") then
                                            child.TextColor3 = newTheme.SubText
                                        elseif child.Name ~= "LocalTime" then
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

        local mainBG, accentBG, topBG, bottomBG, cardBG, buttonBG, divider, text, subText
        local bot1, bot2, bot3, min1, min2, min3

        if s <= 0.05 then
            -- Grayscale / Monochrome selection (Black, Grey, White)
            local isDark = (v < 0.55)
            if v <= 0.10 then
                -- Pure / Deep Black theme
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
                -- Pure / Light White theme
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
                -- Intermediate Grey theme (No red tint!)
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
            -- Chromatic / Colored theme
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

function Library:CreateMobileButton(config, arg2, arg3, arg4, arg5)
    local win = Library.ActiveWindows and Library.ActiveWindows[#Library.ActiveWindows]
    if win and win.CreateMobileButton then
        return win:CreateMobileButton(config, arg2, arg3, arg4, arg5)
    end
end
Library.AddMobileButton = Library.CreateMobileButton

return Library
