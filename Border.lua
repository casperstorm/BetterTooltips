local _, Addon = ...

local isMainTooltipStyled = false

local borderPieces = {
    "TopLeftCorner",
    "TopRightCorner",
    "BottomLeftCorner",
    "BottomRightCorner",
    "TopEdge",
    "BottomEdge",
    "LeftEdge",
    "RightEdge",
}

local function ShouldStyle()
    local anchor = GameTooltip:GetAnchorType()
    return anchor == "ANCHOR_NONE"
end

local function ApplyBorderToTooltip(tooltip, opacity)
    if not tooltip.NineSlice then
        return
    end

    for _, pieceName in ipairs(borderPieces) do
        local piece = tooltip.NineSlice[pieceName]
        if piece then
            piece:SetAlpha(opacity)
        end
    end
end

local function ApplyBorder()
    isMainTooltipStyled = ShouldStyle()
    local opacity = isMainTooltipStyled and BetterTooltipsDB.borderOpacity or 1.0
    ApplyBorderToTooltip(GameTooltip, opacity)
end

local function ApplyShoppingBorder(tooltip)
    local opacity = isMainTooltipStyled and BetterTooltipsDB.borderOpacity or 1.0
    ApplyBorderToTooltip(tooltip, opacity)
end

function Addon:RefreshBorder()
    ApplyBorder()
end

function Addon:HookBorder()
    hooksecurefunc(GameTooltip, "Show", ApplyBorder)
    hooksecurefunc(ShoppingTooltip1, "Show", function() ApplyShoppingBorder(ShoppingTooltip1) end)
    hooksecurefunc(ShoppingTooltip2, "Show", function() ApplyShoppingBorder(ShoppingTooltip2) end)
end
