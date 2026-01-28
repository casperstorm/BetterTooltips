local _, Addon = ...

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

local function ApplyBorder()
    if not GameTooltip.NineSlice then
        return
    end

    local _, unit = GameTooltip:GetUnit()
    local opacity = unit and BetterTooltipsDB.borderOpacity or 1.0

    for _, pieceName in ipairs(borderPieces) do
        local piece = GameTooltip.NineSlice[pieceName]
        if piece then
            piece:SetAlpha(opacity)
        end
    end
end

function Addon:RefreshBorder()
    ApplyBorder()
end

function Addon:HookBorder()
    hooksecurefunc(GameTooltip, "Show", ApplyBorder)
end
