local _, Addon = ...

local isMainTooltipStyled = false

local function ShouldStyle()
    local anchor = GameTooltip:GetAnchorType()
    return anchor == "ANCHOR_NONE"
end

local function ApplyBackgroundToTooltip(tooltip, opacity)
    if not tooltip.NineSlice or not tooltip.NineSlice.Center then
        return
    end

    tooltip.NineSlice.Center:SetAlpha(opacity)
end

local function ApplyBackground()
    isMainTooltipStyled = ShouldStyle()
    local opacity = isMainTooltipStyled and BetterTooltipsDB.backgroundOpacity or 1.0
    ApplyBackgroundToTooltip(GameTooltip, opacity)
end

local function ApplyShoppingBackground(tooltip)
    local opacity = isMainTooltipStyled and BetterTooltipsDB.backgroundOpacity or 1.0
    ApplyBackgroundToTooltip(tooltip, opacity)
end

function Addon:RefreshBackground()
    ApplyBackground()
end

function Addon:HookBackground()
    hooksecurefunc(GameTooltip, "Show", ApplyBackground)
    hooksecurefunc(ShoppingTooltip1, "Show", function() ApplyShoppingBackground(ShoppingTooltip1) end)
    hooksecurefunc(ShoppingTooltip2, "Show", function() ApplyShoppingBackground(ShoppingTooltip2) end)
end
