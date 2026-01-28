local _, Addon = ...

local function ApplyBackground()
    if not GameTooltip.NineSlice or not GameTooltip.NineSlice.Center then
        return
    end

    GameTooltip.NineSlice.Center:SetAlpha(BetterTooltipsDB.backgroundOpacity)
end

function Addon:RefreshBackground()
    ApplyBackground()
end

function Addon:HookBackground()
    hooksecurefunc(GameTooltip, "Show", ApplyBackground)
end
