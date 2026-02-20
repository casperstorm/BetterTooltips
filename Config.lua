local _, Addon = ...

local configFrame = nil

local function CreateCheckbox(parent, label, dbKey, onClick)
    local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox.Text:SetText(label)
    checkbox.Text:SetFontObject("GameFontNormal")

    checkbox:SetChecked(BetterTooltipsDB[dbKey])
    checkbox:SetScript("OnClick", function(self)
        BetterTooltipsDB[dbKey] = self:GetChecked()
        if onClick then
            onClick(self:GetChecked())
        end
    end)

    return checkbox
end

local function CreateSlider(parent, label, dbKey, minVal, maxVal, step, yOffset, onChange, isPercent)
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", 0, yOffset)
    container:SetPoint("TOPRIGHT", 0, yOffset)
    container:SetHeight(32)

    local currentValue = BetterTooltipsDB[dbKey] or minVal

    local function FormatValue(val)
        if isPercent then
            return string.format("%d%%", math.floor(val * 100 + 0.5))
        end
        return tostring(math.floor(val + 0.5))
    end

    local labelText = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    labelText:SetPoint("LEFT", 0, 0)
    labelText:SetWidth(120)
    labelText:SetJustifyH("LEFT")
    labelText:SetText(label)

    local sliderFrame = CreateFrame("Frame", nil, container, "MinimalSliderWithSteppersTemplate")
    sliderFrame:SetPoint("LEFT", labelText, "RIGHT", 8, 0)
    sliderFrame:SetPoint("RIGHT", -40, 0)
    sliderFrame:SetHeight(16)

    local steps = math.floor((maxVal - minVal) / step + 0.5)

    local formatters = {}
    formatters[MinimalSliderWithSteppersMixin.Label.Right] = CreateMinimalSliderFormatter(
        MinimalSliderWithSteppersMixin.Label.Right,
        function(val) return FormatValue(val) end
    )

    sliderFrame.initInProgress = true
    sliderFrame:Init(currentValue, minVal, maxVal, steps, formatters)

    if sliderFrame.MinText then sliderFrame.MinText:Hide() end
    if sliderFrame.MaxText then sliderFrame.MaxText:Hide() end

    sliderFrame.initInProgress = false

    if sliderFrame.Slider then
        sliderFrame.Slider:HookScript("OnValueChanged", function(self, value)
            if not sliderFrame.initInProgress then
                value = math.floor(value / step + 0.5) * step
                BetterTooltipsDB[dbKey] = value
                if onChange then onChange(value) end
            end
        end)
    end

    return container
end

local function CreateColorSwatchButton(parent, dbKey, onChange)
    local swatchButton = CreateFrame("Button", nil, parent, "BackdropTemplate")
    swatchButton:SetSize(28, 18)
    swatchButton:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    local function SetColor(r, g, b)
        BetterTooltipsDB[dbKey] = { r = r, g = g, b = b }
        swatchButton:SetBackdropColor(r, g, b, 1)
        if onChange then
            onChange(r, g, b)
        end
    end

    local initial = BetterTooltipsDB[dbKey] or { r = 1, g = 1, b = 1 }
    swatchButton:SetBackdropColor(initial.r, initial.g, initial.b, 1)

    swatchButton:SetScript("OnClick", function()
        local current = BetterTooltipsDB[dbKey] or { r = 1, g = 1, b = 1 }
        local info = {
            r = current.r,
            g = current.g,
            b = current.b,
            hasOpacity = false,
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                SetColor(r, g, b)
            end,
            cancelFunc = function(previousValues)
                if previousValues then
                    SetColor(previousValues.r, previousValues.g, previousValues.b)
                end
            end,
        }

        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    return swatchButton
end

local function CreateConfigFrame()
    local frame = CreateFrame("Frame", "BetterTooltipsConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(400, 355)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)

    frame.TitleText:SetText("Better Tooltips")

    frame.CloseButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    tinsert(UISpecialFrames, "BetterTooltipsConfigFrame")

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", frame.InsetBg, "BOTTOMRIGHT", -20, 10)

    local y = 0

    local hideHealthBarCheckbox = CreateCheckbox(content, "Hide Health Bar", "hideHealthBar", function()
        Addon:RefreshHealthBar()
    end)
    hideHealthBarCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)

    y = y - 35

    local borderOpacitySlider = CreateSlider(content, "Border Opacity", "borderOpacity", 0, 1, 0.1, y, function()
        Addon:RefreshBorder()
    end, true)

    y = y - 35

    local backgroundOpacitySlider = CreateSlider(content, "Background Opacity", "backgroundOpacity", 0, 1, 0.1, y, function()
        Addon:RefreshBackground()
    end, true)

    y = y - 35

    local textOpacitySlider = CreateSlider(content, "Text Opacity", "textOpacity", 0, 1, 0.1, y, function()
        Addon:RefreshText()
    end, true)

    y = y - 35

    local classColorNamesCheckbox = CreateCheckbox(content, "Use Class Colors for Names", "useClassColorNames", function()
        Addon:RefreshNameClassColor()
    end)
    classColorNamesCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)

    y = y - 35

    local hidePlayerServerCheckbox = CreateCheckbox(content, "Hide Server in Player Names", "hidePlayerServer", function()
        Addon:RefreshNameClassColor()
    end)
    hidePlayerServerCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)

    y = y - 35

    local hidePlayerTitleCheckbox = CreateCheckbox(content, "Hide Title in Player Names", "hidePlayerTitle", function()
        Addon:RefreshNameClassColor()
    end)
    hidePlayerTitleCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)

    y = y - 35

    local useGuildNameColorCheckbox = CreateCheckbox(content, "Use Custom Guild Name Color", "useGuildNameColor", function()
        Addon:RefreshNameClassColor()
    end)
    useGuildNameColorCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    local guildColorSwatch = CreateColorSwatchButton(content, "guildNameColor", function()
        Addon:RefreshNameClassColor()
    end)
    guildColorSwatch:SetPoint("LEFT", useGuildNameColorCheckbox.Text, "RIGHT", 8, 1)

    return frame
end

function Addon:OpenConfig()
    if not configFrame then
        configFrame = CreateConfigFrame()
        configFrame:Show()
        return
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end
