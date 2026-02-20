local _, Addon = ...

local isMainTooltipStyled = false

local function ShouldStyle()
    local anchor = GameTooltip:GetAnchorType()
    return anchor == "ANCHOR_NONE"
end

local function ApplyTextToTooltip(tooltip, opacity)
    for i = 1, tooltip:NumLines() do
        local leftText = _G[tooltip:GetName() .. "TextLeft" .. i]
        local rightText = _G[tooltip:GetName() .. "TextRight" .. i]

        if leftText then
            leftText:SetAlpha(opacity)
        end
        if rightText then
            rightText:SetAlpha(opacity)
        end
    end
end

local function RecalculateTooltipWidth(tooltip)
    local tooltipName = tooltip and tooltip:GetName()
    if not tooltipName then
        return
    end

    local maxLineWidth = 0
    for i = 1, tooltip:NumLines() do
        local leftText = _G[tooltipName .. "TextLeft" .. i]
        local rightText = _G[tooltipName .. "TextRight" .. i]

        local lineWidth = 0
        if leftText and leftText:IsShown() then
            lineWidth = lineWidth + leftText:GetStringWidth()
        end

        if rightText and rightText:IsShown() then
            if lineWidth > 0 then
                lineWidth = lineWidth + 8
            end
            lineWidth = lineWidth + rightText:GetStringWidth()
        end

        if lineWidth > maxLineWidth then
            maxLineWidth = lineWidth
        end
    end

    if maxLineWidth <= 0 then
        return
    end

    if tooltip.SetMinimumWidth then
        tooltip:SetMinimumWidth(0)
    end

    tooltip:SetWidth(maxLineWidth + 24)
end

local function StripServerSuffix(nameText)
    if not nameText or nameText == "" then
        return nameText
    end

    return nameText:gsub("%-[^%-%s]+$", "")
end

local function BuildPlayerNameText(unit, hideServer, hideTitle)
    if hideTitle then
        local name, realm = UnitName(unit)
        if not name or name == "" then
            return nil
        end

        if hideServer or not realm or realm == "" then
            return name
        end

        return name .. "-" .. realm
    end

    local nameText = UnitPVPName(unit) or GetUnitName(unit, true)
    if not nameText or nameText == "" then
        return nil
    end

    if hideServer then
        nameText = StripServerSuffix(nameText)
    end

    return nameText
end

local function ApplyPlayerNameFormatting(tooltip, shouldFormatName)
    if not shouldFormatName then
        return
    end

    local _, unit = tooltip:GetUnit()
    if not unit or not UnitIsPlayer(unit) then
        return
    end

    local nameLine = _G[tooltip:GetName() .. "TextLeft1"]
    if not nameLine then
        return
    end

    local hideServer = BetterTooltipsDB.hidePlayerServer
    local hideTitle = BetterTooltipsDB.hidePlayerTitle
    if not hideServer and not hideTitle then
        return
    end

    local nameText = BuildPlayerNameText(unit, hideServer, hideTitle)
    if nameText and nameText ~= "" then
        nameLine:SetText(nameText)
        RecalculateTooltipWidth(tooltip)
    end
end

local function ApplyPlayerNameClassColor(tooltip, shouldUseClassColor)
    if not shouldUseClassColor then
        return
    end

    local _, unit = tooltip:GetUnit()
    if not unit or not UnitIsPlayer(unit) then
        return
    end

    local _, classToken = UnitClass(unit)
    if not classToken then
        return
    end

    local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
    local color = classColors and classColors[classToken]
    if not color then
        return
    end

    local nameLine = _G[tooltip:GetName() .. "TextLeft1"]
    if nameLine then
        nameLine:SetTextColor(color.r, color.g, color.b)
    end
end

local function ApplyPlayerGuildColor(tooltip, shouldApplyGuildColor)
    if not shouldApplyGuildColor then
        return
    end

    local _, unit = tooltip:GetUnit()
    if not unit or not UnitIsPlayer(unit) then
        return
    end

    local guildColor = BetterTooltipsDB.guildNameColor
    if type(guildColor) ~= "table" then
        return
    end

    local tooltipName = tooltip:GetName()
    local r = guildColor.r or 1
    local g = guildColor.g or 1
    local b = guildColor.b or 1
    local guildName = GetGuildInfo(unit)

    local function StripColorCodes(text)
        if not text then
            return nil
        end
        return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    end

    local line2 = _G[tooltipName .. "TextLeft2"]
    if line2 then
        local line2Text = StripColorCodes(line2:GetText())
        if line2Text and line2Text ~= "" then
            if guildName and (line2Text == guildName or line2Text == "<" .. guildName .. ">") then
                line2:SetTextColor(r, g, b)
                return
            end

            local looksLikeFaction = line2Text == FACTION_HORDE or line2Text == FACTION_ALLIANCE
            local looksLikeLevel = LEVEL and line2Text:find(LEVEL, 1, true) == 1
            if not looksLikeFaction and not looksLikeLevel then
                line2:SetTextColor(r, g, b)
                return
            end
        end
    end

    for i = 2, tooltip:NumLines() do
        local leftText = _G[tooltipName .. "TextLeft" .. i]
        if leftText then
            local plain = StripColorCodes(leftText:GetText())
            if plain and plain ~= "" then
                if guildName and (plain == guildName or plain == "<" .. guildName .. ">") then
                    leftText:SetTextColor(r, g, b)
                    return
                end
            end
        end
    end
end

local function ApplyText()
    isMainTooltipStyled = ShouldStyle()
    local opacity = isMainTooltipStyled and BetterTooltipsDB.textOpacity or 1.0
    ApplyTextToTooltip(GameTooltip, opacity)
    ApplyPlayerNameFormatting(GameTooltip, isMainTooltipStyled)
    local shouldUseClassColor = isMainTooltipStyled and BetterTooltipsDB.useClassColorNames
    ApplyPlayerNameClassColor(GameTooltip, shouldUseClassColor)
    local shouldUseGuildColor = isMainTooltipStyled and BetterTooltipsDB.useGuildNameColor
    ApplyPlayerGuildColor(GameTooltip, shouldUseGuildColor)
end

local function ApplyShoppingText(tooltip)
    local opacity = isMainTooltipStyled and BetterTooltipsDB.textOpacity or 1.0
    ApplyTextToTooltip(tooltip, opacity)
end

function Addon:RefreshText()
    ApplyText()
end

function Addon:RefreshNameClassColor()
    ApplyText()
    local _, unit = GameTooltip:GetUnit()
    if unit then
        GameTooltip:SetUnit(unit)
    end
end

function Addon:HookText()
    hooksecurefunc(GameTooltip, "SetUnit", ApplyText)
    hooksecurefunc(GameTooltip, "Show", ApplyText)
    hooksecurefunc(ShoppingTooltip1, "Show", function() ApplyShoppingText(ShoppingTooltip1) end)
    hooksecurefunc(ShoppingTooltip2, "Show", function() ApplyShoppingText(ShoppingTooltip2) end)
end
