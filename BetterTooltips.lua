local addonName, Addon = ...

local defaults = {
    hideHealthBar = false,
    borderOpacity = 1.0,
    backgroundOpacity = 1.0,
    textOpacity = 1.0,
    useClassColorNames = false,
    hidePlayerServer = false,
    hidePlayerTitle = false,
    useGuildNameColor = false,
    guildNameColor = { r = 0.0, g = 1.0, b = 0.6 },
}

local function CopyTableShallow(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function InitializeDB()
    if not BetterTooltipsDB then
        BetterTooltipsDB = {}
    end

    for key, value in pairs(defaults) do
        if BetterTooltipsDB[key] == nil then
            BetterTooltipsDB[key] = type(value) == "table" and CopyTableShallow(value) or value
        elseif type(value) == "table" and type(BetterTooltipsDB[key]) == "table" then
            for subKey, subValue in pairs(value) do
                if BetterTooltipsDB[key][subKey] == nil then
                    BetterTooltipsDB[key][subKey] = subValue
                end
            end
        end
    end
end

local function RegisterOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "BetterTooltips"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BetterTooltips")

    local openBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    openBtn:SetSize(150, 24)
    openBtn:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    openBtn:SetText("Open Settings")
    openBtn:SetScript("OnClick", function()
        HideUIPanel(SettingsPanel)
        Addon:OpenConfig()
    end)

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    category.ID = panel.name
    Settings.RegisterAddOnCategory(category)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitializeDB()
        RegisterOptionsPanel()
    elseif event == "PLAYER_LOGIN" then
        Addon:HookHealthBar()
        Addon:HookBorder()
        Addon:HookBackground()
        Addon:HookText()
    end
end)

SLASH_BETTERTOOLTIPS1 = "/bt"
SLASH_BETTERTOOLTIPS2 = "/bettertooltips"

SlashCmdList["BETTERTOOLTIPS"] = function(msg)
    Addon:OpenConfig()
end
