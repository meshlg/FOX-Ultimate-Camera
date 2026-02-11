-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

local CustomCheckbox = {}
CustomCheckbox.__index = CustomCheckbox

local WIDGET_NAME = "fox_checkbox"
local DEFAULT_CHECKBOX_SIZE = 18
local MIN_CHECKBOX_SIZE = 18
local MAX_CHECKBOX_SIZE = 18
local MIN_STATE_LABEL_WIDTH = 60
local MAX_STATE_LABEL_WIDTH = 140

function CustomCheckbox:New()
    local instance = setmetatable({}, CustomCheckbox)
    instance.initialized = false
    return instance
end

function CustomCheckbox:Initialize()
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
        -- Widget already registered elsewhere; mark as available and exit
        self.widgetAvailable = true
        self.initialized = true
        return
    elseif not registered then
        self.widgetAvailable = false
        self.initialized = true
        return
    end

    local wm = WINDOW_MANAGER
    local enabledColor = ZO_DEFAULT_ENABLED_COLOR
    local enabledHLcolor = ZO_HIGHLIGHT_TEXT
    local disabledColor = ZO_DEFAULT_DISABLED_COLOR
    local disabledHLcolor = ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR

    local DEFAULT_STATE_ON = GetString(SI_CHECK_BUTTON_ON)
    local DEFAULT_STATE_OFF = GetString(SI_CHECK_BUTTON_OFF)

    local function ResolveCheckboxSize(checkboxData)
        local size = DEFAULT_CHECKBOX_SIZE
        if checkboxData and type(checkboxData.checkboxSize) == "number" then
            size = checkboxData.checkboxSize
        end

        if size < MIN_CHECKBOX_SIZE then
            size = MIN_CHECKBOX_SIZE
        elseif size > MAX_CHECKBOX_SIZE then
            size = MAX_CHECKBOX_SIZE
        end

        return zo_round(size)
    end

    local function ResolveStateLabelWidth(control)
        local width = MIN_STATE_LABEL_WIDTH
        local data = control.data
        if data and type(data.stateTextWidth) == "number" then
            width = zo_floor(data.stateTextWidth)
        end
        if width < MIN_STATE_LABEL_WIDTH then
            width = MIN_STATE_LABEL_WIDTH
        elseif width > MAX_STATE_LABEL_WIDTH then
            width = MAX_STATE_LABEL_WIDTH
        end
        return width
    end

    local function ResolveStateText(control, value)
        local data = control.data
        if data then
            if type(data.stateTextFormatter) == "function" then
                local ok, text = pcall(data.stateTextFormatter, value, control)
                if ok and type(text) == "string" and text ~= "" then
                    return text
                end
            elseif type(data.stateTextFormatter) == "table" then
                local key = value and true or false
                local text = data.stateTextFormatter[key]
                if type(text) == "string" and text ~= "" then
                    return text
                end
            end
        end
        return value and DEFAULT_STATE_ON or DEFAULT_STATE_OFF
    end

    local function UpdateStateLabel(control)
        if not control.stateLabel then
            return
        end

        control.stateLabel:SetText(ResolveStateText(control, control.value))
        local color = control.isDisabled and disabledColor or (control.value and enabledColor or disabledColor)
        control.stateLabel:SetColor(color:UnpackRGBA())
    end

    local function RefreshVisualState(control)
        if not control.checkbox then
            return
        end

        local checked = control.value and true or false
        ZO_CheckButton_SetCheckState(control.checkbox, checked)

        local isImmersionMaster = control.data and control.data.layoutStyle == "immersion_master"

        if control.isDisabled then
            control.label:SetColor(disabledColor:UnpackRGBA())
        else
            if isImmersionMaster and not checked then
                -- For the immersive master toggle, make the OFF state more visibly dimmed
                local r, g, b, a = disabledColor:UnpackRGBA()
                control.label:SetColor(r, g, b, a * 0.6)
            else
                control.label:SetColor((checked and enabledColor or disabledColor):UnpackRGBA())
            end
        end
        UpdateStateLabel(control)
    end

    local function UpdateValue(control, forceDefault, value)
        if forceDefault then
            value = LAM.util.GetDefaultValue(control.data.default)
            control.data.setFunc(value)
        elseif value ~= nil then
            control.data.setFunc(value)
            LAM.util.RequestRefreshIfNeeded(control)
        else
            value = control.data.getFunc()
        end

        control.value = value and true or false
        RefreshVisualState(control)
    end

    local function UpdateDisabled(control)
        local disable
        if type(control.data.disabled) == "function" then
            disable = control.data.disabled()
        else
            disable = control.data.disabled
        end

        control.isDisabled = disable and true or false
        control.checkbox:SetEnabled(not control.isDisabled)
        control.label:SetColor((control.isDisabled and disabledColor or (control.value and enabledColor or disabledColor)):UnpackRGBA())
        UpdateStateLabel(control)
    end

    local function OnMouseEnter(control)
        ZO_Options_OnMouseEnter(control)
        if control.isDisabled then
            return
        end

        control.label:SetColor((control.value and enabledHLcolor or disabledHLcolor):UnpackRGBA())
    end

    local function OnMouseExit(control)
        ZO_Options_OnMouseExit(control)
        RefreshVisualState(control)
    end

    local function ApplyCheckedState(control, desiredState, skipSound)
        if control.isDisabled then
            ZO_CheckButton_SetCheckState(control.checkbox, control.value)
            return
        end

        if not skipSound then
            PlaySound(SOUNDS.DEFAULT_CLICK)
        end

        control:UpdateValue(false, desiredState)
    end

    function LAMCreateControl.fox_checkbox(parent, checkboxData, controlName)
        local control = LAM.util.CreateLabelAndContainerControl(parent, checkboxData, controlName)
        control:SetHandler("OnMouseEnter", OnMouseEnter)
        control:SetHandler("OnMouseExit", OnMouseExit)

        local checkboxSize = ResolveCheckboxSize(checkboxData)

        control.checkbox = CreateControlFromVirtual(nil, control.container, "ZO_CheckButton")
        local checkbox = control.checkbox
        checkbox:SetAnchor(LEFT, control.container, LEFT, 0, 0)
        checkbox:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        checkbox:SetDimensions(checkboxSize, checkboxSize)
        checkbox:SetClickSound(SOUNDS.NONE)
        -- Make the checkbox graphic itself mouse-passive so tooltips and hover state are handled only by the parent control
        checkbox:SetMouseEnabled(false)
        ZO_CheckButton_SetToggleFunction(checkbox, function(_, checked)
            ApplyCheckedState(control, checked, true)
        end)

        control:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift)
            if button ~= MOUSE_BUTTON_INDEX_LEFT or not upInside then
                return
            end

            if self.isDisabled then
                return
            end

            ApplyCheckedState(self, not self.value)
        end)

        local stateLabelWidth = ResolveStateLabelWidth(control)
        local stateLabel = wm:CreateControl(nil, control, CT_LABEL)
        stateLabel:SetFont("ZoFontGameSmall")
        stateLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        stateLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        stateLabel:SetWidth(stateLabelWidth)
        stateLabel:ClearAnchors()
        -- Place state text to the right of the checkbox, using the remaining space on the right side
        -- Small positive Y offset to visually center text with the checkbox
        stateLabel:SetAnchor(TOPLEFT, checkbox, TOPRIGHT, 4, 1)
        stateLabel:SetAnchor(BOTTOMLEFT, checkbox, BOTTOMRIGHT, 4, 1)
        stateLabel:SetMouseEnabled(false)
        control.stateLabel = stateLabel

        -- Label occupies the space from the left edge up to the state label, like default LAM layout
        control.label:ClearAnchors()
        control.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        control.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 1)
        control.label:SetAnchor(BOTTOMRIGHT, stateLabel, BOTTOMLEFT, -10, 1)

        -- Optional special layout for master immersive toggle: center label and show state text below
        if checkboxData and checkboxData.layoutStyle == "immersion_master" then
            checkbox:SetHidden(true)
            -- Main label: centered across the full row
            control.label:ClearAnchors()
            control.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            control.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 1)
            control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 1)

            -- State label: small ON/OFF text centered under the main label
            stateLabel:ClearAnchors()
            stateLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            stateLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            stateLabel:SetAnchor(TOPLEFT, control.label, BOTTOMLEFT, 0, 2)
            stateLabel:SetAnchor(TOPRIGHT, control.label, BOTTOMRIGHT, 0, 2)
        end

        control.UpdateValue = UpdateValue
        control:UpdateValue()

        if checkboxData.disabled ~= nil then
            control.UpdateDisabled = UpdateDisabled
            control:UpdateDisabled()
        else
            control.isDisabled = false
        end

        control.tooltipText = LAM.util.GetStringFromValue(checkboxData.tooltip)
        if checkboxData.warning ~= nil or checkboxData.requiresReload then
            control.UpdateWarning = LAM.util.UpdateWarning
            control.warning = wm:CreateControlFromVirtual(nil, control, "ZO_Options_WarningIcon")
            control.warning:SetAnchor(RIGHT, checkbox, LEFT, -5, 0)
            control:UpdateWarning()
        end

        LAM.util.RegisterForRefreshIfNeeded(control)
        LAM.util.RegisterForReloadIfNeeded(control)

        return control
    end

    self.widgetAvailable = true
    self.initialized = true
end

function CustomCheckbox:Shutdown()
    -- Nothing to clean up explicitly; provided for API symmetry
end

function CustomCheckbox:IsAvailable()
    return self.widgetAvailable == true
end

function CustomCheckbox:GetControlType()
    return WIDGET_NAME
end

FOXUltimateCamera = FOXUltimateCamera or {}
local FOXUC = FOXUltimateCamera
FOXUC.modules = FOXUC.modules or {}

if not FOXUC.modules.customCheckbox then
    FOXUC.modules.customCheckbox = CustomCheckbox:New()
end
