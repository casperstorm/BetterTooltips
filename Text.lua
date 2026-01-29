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

local function ApplyText()
    isMainTooltipStyled = ShouldStyle()
    local opacity = isMainTooltipStyled and BetterTooltipsDB.textOpacity or 1.0
    ApplyTextToTooltip(GameTooltip, opacity)
end

local function ApplyShoppingText(tooltip)
    local opacity = isMainTooltipStyled and BetterTooltipsDB.textOpacity or 1.0
    ApplyTextToTooltip(tooltip, opacity)
end

function Addon:RefreshText()
    ApplyText()
end

function Addon:HookText()
    hooksecurefunc(GameTooltip, "Show", ApplyText)
    hooksecurefunc(ShoppingTooltip1, "Show", function() ApplyShoppingText(ShoppingTooltip1) end)
    hooksecurefunc(ShoppingTooltip2, "Show", function() ApplyShoppingText(ShoppingTooltip2) end)
end
