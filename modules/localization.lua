-- modules/localization.lua
-- MorningDrift UI Library: Localization & Multi-Language Module

return function(Library, Window)
    function Window:Translate(input, targetLang)
        if input == nil then return "" end
        targetLang = targetLang or Window.CurrentLanguage or "English"

        -- If input is a table (multi-language map or element config)
        if type(input) == "table" then
            -- 1. Direct language key match (e.g. { Russian = "Текст", English = "Text" })
            if input[targetLang] ~= nil and type(input[targetLang]) == "string" and input[targetLang] ~= "" then
                return input[targetLang]
            end

            -- 2. Extract fallback string (English / en / Title / Name / Text / Label / 1)
            local fallback = input["English"] or input["en"] or input.Title or input.Name or input.Text or input.Label or input[1]
            if type(fallback) == "table" then
                fallback = fallback[targetLang] or fallback["English"] or fallback[1] or ""
            end
            local fallbackStr = (fallback ~= nil and type(fallback) ~= "table") and tostring(fallback) or ""

            -- 3. If target language is not English, check dictionary for fallback string
            if targetLang ~= "English" and fallbackStr ~= "" then
                local langDict = Window.Translations and Window.Translations[targetLang]
                if langDict and langDict[fallbackStr] ~= nil then
                    local val = langDict[fallbackStr]
                    if type(val) == "string" and val ~= "" then
                        return val
                    end
                end
            end

            -- Never return tostring(table); always return clean English/fallback string
            return fallbackStr
        end

        local str = tostring(input)
        if targetLang == "English" then
            local engDict = Window.Translations and Window.Translations["English"]
            if engDict and engDict[str] ~= nil and type(engDict[str]) == "string" and engDict[str] ~= "" then
                return engDict[str]
            end
            return str
        end

        local langDict = Window.Translations and Window.Translations[targetLang]
        if langDict and langDict[str] ~= nil then
            local val = langDict[str]
            if type(val) == "table" then
                val = val[targetLang] or val["English"] or val[1]
            end
            if type(val) == "string" and val ~= "" then
                return val
            end
        end

        -- If there is NO translation for that language:
        -- Keep the original English language text!
        return str
    end
    Window.T = Window.Translate

    function Window:RegisterTranslations(lang, dict)
        if not lang or type(dict) ~= "table" then return end
        Window.Translations = Window.Translations or {}
        Window.Translations[lang] = Window.Translations[lang] or {}
        for k, v in pairs(dict) do
            Window.Translations[lang][k] = v
        end
        if Window.CurrentLanguage == lang then
            Window:SetLanguage(lang)
        end
    end

    function Window:SetLanguage(newLang)
        if not newLang or newLang == "" then return end
        local oldLang = Window.CurrentLanguage or "English"
        Window.CurrentLanguage = newLang

        if Window.RegisteredLocalizedElements then
            for _, item in ipairs(Window.RegisteredLocalizedElements) do
                pcall(function()
                    if item.Update and item.OriginalText then
                        local translated = Window:Translate(item.OriginalText, newLang)
                        item.Update(translated, newLang)
                    end
                    if item.UpdateDesc and item.OriginalDesc then
                        local translatedDesc = Window:Translate(item.OriginalDesc, newLang)
                        item.UpdateDesc(translatedDesc, newLang)
                    end
                end)
            end
        end

        if Window.LanguageDropdowns then
            for _, drop in ipairs(Window.LanguageDropdowns) do
                pcall(function()
                    if drop and drop.SetSelected then
                        drop.SetSelected(newLang, false)
                    end
                end)
            end
        elseif Window.LanguageDropdown and Window.LanguageDropdown.SetSelected then
            pcall(function()
                Window.LanguageDropdown.SetSelected(newLang, false)
            end)
        end

        if Window.LanguageChangedCallbacks then
            for _, cb in ipairs(Window.LanguageChangedCallbacks) do
                pcall(cb, newLang, oldLang)
            end
        end
    end

    function Window:GetLanguage()
        return Window.CurrentLanguage or "English"
    end

    function Window:GetLanguages()
        return Window.Languages or { "English" }
    end

    function Window:SetLanguages(list)
        if type(list) ~= "table" then return end
        Window.Languages = list
        if Window.LanguageDropdowns then
            for _, drop in ipairs(Window.LanguageDropdowns) do
                if drop and drop.RefreshOptions then
                    drop.RefreshOptions(list)
                end
            end
        elseif Window.LanguageDropdown and Window.LanguageDropdown.RefreshOptions then
            Window.LanguageDropdown.RefreshOptions(list)
        end
    end

    function Window:OnLanguageChanged(cb)
        if type(cb) ~= "function" then return end
        Window.LanguageChangedCallbacks = Window.LanguageChangedCallbacks or {}
        table.insert(Window.LanguageChangedCallbacks, cb)
    end

    function Window:RegisterLocalizedElement(elemData, originalText, updateFn, originalDesc, descUpdateFn)
        if not (originalText or originalDesc) then return end

        -- If originalText is a table representing an element, unwrap its title
        if type(originalText) == "table" and (originalText.Frame or originalText.Instance or originalText.CardFrame or originalText.SetTitle) then
            originalText = originalText.Title or originalText.Name or originalText.Text or ""
        end
        if type(originalDesc) == "table" and (originalDesc.Frame or originalDesc.Instance) then
            originalDesc = originalDesc.Desc or originalDesc.Description or ""
        end

        Window.RegisteredLocalizedElements = Window.RegisteredLocalizedElements or {}
        local entry = {
            Element = elemData,
            OriginalText = originalText,
            OriginalDesc = originalDesc,
            Update = updateFn,
            UpdateDesc = descUpdateFn
        }
        table.insert(Window.RegisteredLocalizedElements, entry)

        local curLang = Window.CurrentLanguage or "English"
        if curLang ~= "English" or (Window.Translations and Window.Translations[curLang]) or type(originalText) == "table" or type(originalDesc) == "table" then
            pcall(function()
                if updateFn and originalText then
                    local translated = Window:Translate(originalText, curLang)
                    if type(translated) == "string" and translated ~= "" and translated ~= originalText then
                        updateFn(translated, curLang)
                    end
                end
                if descUpdateFn and originalDesc then
                    local translatedDesc = Window:Translate(originalDesc, curLang)
                    if type(translatedDesc) == "string" and translatedDesc ~= "" and translatedDesc ~= originalDesc then
                        descUpdateFn(translatedDesc, curLang)
                    end
                end
            end)
        end
    end

    function Window:EnableLanguageSelector(config)
        config = config or {}
        Window.LanguageSelectorEnabled = true
        if config.Languages and type(config.Languages) == "table" then
            Window.Languages = config.Languages
        elseif not Window.Languages then
            Window.Languages = { "English", "Russian" }
        end
        if config.Default or config.Language then
            Window.CurrentLanguage = tostring(config.Default or config.Language)
        end
        if config.Translations and type(config.Translations) == "table" then
            for lang, dict in pairs(config.Translations) do
                Window:RegisterTranslations(lang, dict)
            end
        end

        if Window.SettingsTab and not Window.LanguageDropdown then
            local SettingsTab = Window.SettingsTab
            local langSection = SettingsTab:AddSection("Language", true)
            local langDrop = SettingsTab:AddDropdown({
                Title = "Interface language",
                Options = Window.Languages,
                Default = Window.CurrentLanguage or Window.Languages[1] or "English",
                Callback = function(selectedLang)
                    Window:SetLanguage(selectedLang)
                end
            })
            Window.LanguageDropdown = langDrop
            Window.LanguageDropdowns = Window.LanguageDropdowns or {}
            table.insert(Window.LanguageDropdowns, langDrop)
            if SettingsTab.ContentFrame and SettingsTab.Layout then
                SettingsTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, SettingsTab.Layout.AbsoluteContentSize.Y + 20)
            end
        elseif Window.LanguageDropdown and Window.LanguageDropdown.RefreshOptions then
            Window.LanguageDropdown.RefreshOptions(Window.Languages)
            if Window.CurrentLanguage then
                Window.LanguageDropdown.SetSelected(Window.CurrentLanguage, false)
            end
        end
    end

    function Window:AddLanguageDropdown(targetTab, config)
        local target = targetTab or Window.SettingsTab
        if target and target.AddLanguageDropdown then
            return target:AddLanguageDropdown(config)
        end
    end


end
