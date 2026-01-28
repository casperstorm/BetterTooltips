local _, Addon = ...

local function ApplyBackground()
    if not GameTooltip.NineSlice or not GameTooltip.NineSlice.Center then
        return
    end

    local _, unit = GameTooltip:GetUnit()
    local opacity = unit and BetterTooltipsDB.backgroundOpacity or 1.0

    GameTooltip.NineSlice.Center:SetAlpha(opacity)
end

function Addon:RefreshBackground()
    ApplyBackground()
end

function Addon:HookBackground()
    hooksecurefunc(GameTooltip, "Show", ApplyBackground)
end
