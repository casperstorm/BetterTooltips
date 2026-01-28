local _, Addon = ...

local function ApplyHealthBar()
    local statusBar = GameTooltipStatusBar or (GameTooltip and GameTooltip.StatusBar)

    if statusBar then
        if BetterTooltipsDB.hideHealthBar then
            statusBar:Hide()
            statusBar:SetScript("OnShow", function(self)
                if BetterTooltipsDB.hideHealthBar then
                    self:Hide()
                end
            end)
        else
            statusBar:SetScript("OnShow", nil)
            statusBar:Show()
        end
    end
end

function Addon:RefreshHealthBar()
    ApplyHealthBar()
end

function Addon:HookHealthBar()
    ApplyHealthBar()

    hooksecurefunc(GameTooltip, "Show", function()
        if BetterTooltipsDB.hideHealthBar then
            local statusBar = GameTooltipStatusBar or (GameTooltip and GameTooltip.StatusBar)
            if statusBar then
                statusBar:Hide()
            end
        end
    end)
end
