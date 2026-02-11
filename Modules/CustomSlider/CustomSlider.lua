-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

local CustomSlider = {}
CustomSlider.__index = CustomSlider

local WIDGET_NAME = "fox_slider"

function CustomSlider:New()
    local instance = setmetatable({}, CustomSlider)
    instance.initialized = false
    return instance
end

function CustomSlider:Initialize()
    if self.initialized then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM or not LAM.util or not LAMCreateControl then
        self.widgetAvailable = false
        return
    end

    local widgetVersion = 1
    local registered = LAM:RegisterWidget(WIDGET_NAME, widgetVersion)
    if not registered and LAMCreateControl[WIDGET_NAME] then
        -- Widget already registered elsewhere; mark as available
        self.widgetAvailable = true
        self.initialized = true
        return
    elseif not registered then
        self.widgetAvailable = false
        self.initialized = true
        return
    end

    local wm = WINDOW_MANAGER
    local util = LAM.util
    local strformat = string.format

    local NORMAL_BG_COLOR = ZO_ColorDef:New(0, 0, 0, 1)
    local HOVER_BG_COLOR = ZO_ColorDef:New(0.12, 0.12, 0.12, 1)
    local VALUE_FONT_NORMAL = "ZoFontGameSmall"
    local VALUE_FONT_ACTIVE = "ZoFontGameMedium"

    local function RoundDecimalToPlace(d, place)
        return tonumber(strformat("%." .. tostring(place) .. "f", d))
    end

    local function ClampValue(value, min, max)
        return math.max(math.min(value, max), min)
    end

    local function FormatValue(data, value)
        if data.decimals then
            value = RoundDecimalToPlace(value, data.decimals)
        end

        if type(data.valueFormat) == "function" then
            local ok, text = pcall(data.valueFormat, value)
            if ok and type(text) == "string" then
                return text
            end
        end

        return tostring(value)
    end

    local function RefreshColors(control)
        if not control.slider or not control.slider.bg then
            return
        end

        local isHovered = control.isHovered and not control.isDisabled

        -- Background highlight
        local bgColor = isHovered and HOVER_BG_COLOR or NORMAL_BG_COLOR
        control.slider.bg:SetCenterColor(bgColor:UnpackRGBA())

        -- Text colors
        local baseColor
        if control.isDisabled then
            baseColor = ZO_DEFAULT_DISABLED_COLOR
        elseif isHovered then
            baseColor = ZO_HIGHLIGHT_TEXT
        else
            baseColor = ZO_DEFAULT_ENABLED_COLOR
        end

        if control.label then
            control.label:SetColor(baseColor:UnpackRGBA())
        end
        if control.minLabel then
            control.minLabel:SetColor(baseColor:UnpackRGBA())
        end
        if control.maxLabel then
            control.maxLabel:SetColor(baseColor:UnpackRGBA())
        end
        if control.currentValueLabel then
            local valueLabel = control.currentValueLabel
            local valueColor = baseColor

            if not control.isDisabled and control.isActive then
                valueColor = ZO_HIGHLIGHT_TEXT
                valueLabel:SetFont(VALUE_FONT_ACTIVE)
            else
                valueLabel:SetFont(VALUE_FONT_NORMAL)
            end

            valueLabel:SetColor(valueColor:UnpackRGBA())
        end
    end

    local function UpdateDisabled(control)
        local disable
        if type(control.data.disabled) == "function" then
            disable = control.data.disabled()
        else
            disable = control.data.disabled
        end

        control.isDisabled = disable and true or false
        control.slider:SetEnabled(not control.isDisabled)

        RefreshColors(control)
    end

    local function SetVisualValue(control, value)
        local data = control.data
        control.slider:SetValue(value)

        if control.currentValueLabel then
            control.currentValueLabel:SetText(FormatValue(data, value))
        end
    end

    local function UpdateValue(control, forceDefault, value)
        local data = control.data
        if forceDefault then
            value = util.GetDefaultValue(data.default)
            data.setFunc(value)
        elseif value ~= nil then
            if data.decimals then
                value = RoundDecimalToPlace(value, data.decimals)
            end
            if data.clampInput ~= false then
                local clamp = data.clampFunction or ClampValue
                value = clamp(value, data.min, data.max)
            end
            data.setFunc(value)
            util.RequestRefreshIfNeeded(control)
        else
            value = data.getFunc()
        end

        control.value = value
        SetVisualValue(control, value)
    end

    local function OnSliderValueChanged(slider, value, eventReason)
        if eventReason == EVENT_REASON_SOFTWARE then
            return
        end
        local control = slider.control
        if not control or not control.currentValueLabel then
            return
        end

        control.isActive = true
        control.currentValueLabel:SetText(FormatValue(control.data, value))
        RefreshColors(control)
    end

    local function OnSliderReleased(slider, value)
        if not slider:GetEnabled() then
            return
        end
        local control = slider.control
        if control and control.UpdateValue then
            control:UpdateValue(false, value)
            control.isActive = false
            RefreshColors(control)
        end
    end

    local function OnMouseWheel(slider, delta)
        if not slider:GetEnabled() then
            return
        end

        local control = slider.control
        local data = control.data
        local step = data.step or 1
        local current = control.value or data.getFunc() or data.min or 0
        local newValue = current + step * delta
        control:UpdateValue(false, newValue)
    end

    function LAMCreateControl.fox_slider(parent, sliderData, controlName)
        local control = LAM.util.CreateLabelAndContainerControl(parent, sliderData, controlName)

        control.UpdateValue = UpdateValue
        control.UpdateDisabled = UpdateDisabled

        control.slider = wm:CreateControl(nil, control.container, CT_SLIDER)
        local slider = control.slider
        slider.control = control
        slider:SetAnchor(TOPLEFT)
        slider:SetAnchor(TOPRIGHT)
        slider:SetHeight(14)
        slider:SetMouseEnabled(true)
        slider:SetOrientation(ORIENTATION_HORIZONTAL)
        slider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 8, 16)

        local minValue = sliderData.min
        local maxValue = sliderData.max
        slider:SetMinMax(minValue, maxValue)
        slider:SetValueStep(sliderData.step or 1)

        control.isHovered = false
        control.isActive = false

        slider:SetHandler("OnMouseEnter", function()
            ZO_Options_OnMouseEnter(control)
            control.isHovered = true
            RefreshColors(control)
        end)
        slider:SetHandler("OnMouseExit", function()
            ZO_Options_OnMouseExit(control)
            control.isHovered = false
            RefreshColors(control)
        end)
        slider:SetHandler("OnValueChanged", OnSliderValueChanged)
        slider:SetHandler("OnSliderReleased", OnSliderReleased)
        slider:SetHandler("OnMouseWheel", OnMouseWheel)

        slider.bg = wm:CreateControl(nil, slider, CT_BACKDROP)
        local bg = slider.bg
        bg:SetCenterColor(0, 0, 0)
        bg:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
        bg:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
        bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4)

        -- MIN / CURRENT / MAX labels under the bar
        control.minLabel = wm:CreateControl(nil, slider, CT_LABEL)
        local minLabel = control.minLabel
        minLabel:SetFont("ZoFontGameSmall")
        minLabel:SetAnchor(TOPLEFT, slider, BOTTOMLEFT, 0, 0)
        minLabel:SetText(FormatValue(sliderData, minValue))

        control.maxLabel = wm:CreateControl(nil, slider, CT_LABEL)
        local maxLabel = control.maxLabel
        maxLabel:SetFont("ZoFontGameSmall")
        maxLabel:SetAnchor(TOPRIGHT, slider, BOTTOMRIGHT, 0, 0)
        maxLabel:SetText(FormatValue(sliderData, maxValue))

        control.currentValueLabel = wm:CreateControl(nil, slider, CT_LABEL)
        local currentLabel = control.currentValueLabel
        currentLabel:SetFont("ZoFontGameSmall")
        currentLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        currentLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        currentLabel:SetAnchor(TOP, slider, BOTTOM, 0, 0)

        if sliderData.warning ~= nil or sliderData.requiresReload then
            control.warning = wm:CreateControlFromVirtual(nil, control, "ZO_Options_WarningIcon")
            control.warning:SetAnchor(RIGHT, slider, LEFT, -5, 0)
            control.UpdateWarning = util.UpdateWarning
            control:UpdateWarning()
        end

        -- Initialize from current saved value via getFunc instead of default,
        -- so that opening the menu does not reset the value to the slider's
        -- default. Defaults are still applied when explicitly requested via
        -- the LAM reset mechanism.
        control:UpdateValue(false)

        if sliderData.disabled ~= nil then
            control:UpdateDisabled()
        end

        util.RegisterForRefreshIfNeeded(control)
        util.RegisterForReloadIfNeeded(control)

        return control
    end

    self.widgetAvailable = true
    self.initialized = true
end

function CustomSlider:Shutdown()
    -- nothing special to clean up
end

function CustomSlider:IsAvailable()
    return self.widgetAvailable == true
end

function CustomSlider:GetControlType()
    return WIDGET_NAME
end

FOXUltimateCamera = FOXUltimateCamera or {}
local FOXUC = FOXUltimateCamera
FOXUC.modules = FOXUC.modules or {}

if not FOXUC.modules.customSlider then
    FOXUC.modules.customSlider = CustomSlider:New()
end
