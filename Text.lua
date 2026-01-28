local _, Addon = ...

local function ApplyText()
    local _, unit = GameTooltip:GetUnit()
    local opacity = unit and BetterTooltipsDB.textOpacity or 1.0

    for i = 1, GameTooltip:NumLines() do
        local leftText = _G["GameTooltipTextLeft" .. i]
        local rightText = _G["GameTooltipTextRight" .. i]

        if leftText then
            leftText:SetAlpha(opacity)
        end
        if rightText then
            rightText:SetAlpha(opacity)
        end
    end
end

function Addon:RefreshText()
    ApplyText()
end

function Addon:HookText()
    hooksecurefunc(GameTooltip, "Show", ApplyText)
end
