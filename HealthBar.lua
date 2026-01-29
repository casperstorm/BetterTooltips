local _, Addon = ...

local function ShouldStyle()
    local anchor = GameTooltip:GetAnchorType()
    return anchor == "ANCHOR_NONE"
end

local function ApplyHealthBar()
    local statusBar = GameTooltipStatusBar or (GameTooltip and GameTooltip.StatusBar)

    if statusBar then
        local shouldHide = ShouldStyle() and BetterTooltipsDB.hideHealthBar
        if shouldHide then
            statusBar:Hide()
            statusBar:SetScript("OnShow", function(self)
                if ShouldStyle() and BetterTooltipsDB.hideHealthBar then
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
        if ShouldStyle() and BetterTooltipsDB.hideHealthBar then
            local statusBar = GameTooltipStatusBar or (GameTooltip and GameTooltip.StatusBar)
            if statusBar then
                statusBar:Hide()
            end
        end
    end)
end
