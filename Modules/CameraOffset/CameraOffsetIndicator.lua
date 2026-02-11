-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

local CameraOffsetIndicator = {}

local addon = nil
local control = nil
local label = nil
local marker = nil
local hideTimerId = nil
local hideTimerName = "FOXUC_OffsetIndicatorHide"
local isVisible = false

-- Normalized offset ranges (mirror CameraOffset.lua defaults)
local MIN_CAMERA_OFFSET_X = -1.0
local MAX_CAMERA_OFFSET_X = 1.0
local MIN_CAMERA_OFFSET_Y = -0.6
local MAX_CAMERA_OFFSET_Y = 0.6

-- Visual layout
-- a wide window so that the indicator text fits completely under the cross
local INDICATOR_WIDTH = 440
local INDICATOR_HEIGHT = 220
local CROSS_SIZE = 80
local CROSS_OFFSET_Y = -20

-- Default settings
local DEFAULT_HIDE_DELAY = 3500 -- 3.5 seconds in ms

local function GetHideDelay()
    if addon and addon.savedVars and type(addon.savedVars.cameraOffsetIndicatorDelay) == "number" then
        return addon.savedVars.cameraOffsetIndicatorDelay * 1000 -- Convert to ms
    end
    return DEFAULT_HIDE_DELAY
end

local function IsIndicatorEnabled()
    if addon and addon.savedVars then
        return addon.savedVars.cameraOffsetIndicatorEnabled ~= false
    end
    return true -- Enabled by default
end

local function NormalizeOffset(value, minValue, maxValue)
    if type(value) ~= "number" or minValue == nil or maxValue == nil or maxValue <= minValue then
        return 0
    end

    local t = (value - minValue) / (maxValue - minValue)
    t = zo_clamp(t, 0, 1)
    return (t * 2) - 1 -- Map [0,1] -> [-1,1]
end

local function CreateIndicatorUI()
    if control then
        return -- Already created
    end

    -- Create container
    control = WINDOW_MANAGER:CreateTopLevelWindow("FOXUltimateCamera_OffsetIndicator")
    control:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
    control:SetDimensions(INDICATOR_WIDTH, INDICATOR_HEIGHT)
    control:SetHidden(true)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLayer(DL_OVERLAY)

    -- Create backdrop
    local backdrop = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    backdrop:SetAnchorFill(control)
    backdrop:SetCenterColor(0, 0, 0, 0.7)
    backdrop:SetEdgeColor(0.3, 0.3, 0.3, 0.9)
    backdrop:SetEdgeTexture("", 8, 1, 1)

    -- Create cross lines
    local crossHalf = CROSS_SIZE * 0.5

    local horizontal = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    horizontal:SetAnchor(CENTER, control, CENTER, 0, CROSS_OFFSET_Y)
    horizontal:SetDimensions(CROSS_SIZE, 2)
    horizontal:SetTexture("")
    horizontal:SetColor(1, 1, 1, 0.5)

    local vertical = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    vertical:SetAnchor(CENTER, control, CENTER, 0, CROSS_OFFSET_Y)
    vertical:SetDimensions(2, CROSS_SIZE)
    vertical:SetTexture("")
    vertical:SetColor(1, 1, 1, 0.5)

    -- Create marker at the center of cross
    marker = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    marker:SetAnchor(CENTER, control, CENTER, 0, CROSS_OFFSET_Y)
    marker:SetFont("ZoFontGameLargeBold")
    marker:SetColor(1, 0.65, 0, 1)
    marker:SetText("•")

    -- Create label under the cross
    label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetAnchor(BOTTOM, control, BOTTOM, 0, -30)
    label:SetFont("ZoFontGameBold")
    label:SetColor(1, 1, 1, 1)
    label:SetText("")
end

local function UpdateIndicatorText()
    if not label then
        return
    end

    local offsetModule = addon and addon.modules and addon.modules.CameraOffset
    if not offsetModule then
        return
    end

    local offsetX = offsetModule:GetCurrentOffsetX() or 0
    local offsetY = offsetModule:GetCurrentOffsetY() or 0
    local zoom = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) or 0

    local formatString = GetString(SI_FOXUC_CAMERA_OFFSET_INDICATOR_TEXT)
    local text = string.format(formatString, offsetX, offsetY, zoom)

    label:SetText(text)

    if marker then
        local normX = NormalizeOffset(offsetX, MIN_CAMERA_OFFSET_X, MAX_CAMERA_OFFSET_X)
        local normY = NormalizeOffset(offsetY, MIN_CAMERA_OFFSET_Y, MAX_CAMERA_OFFSET_Y)
        local crossHalf = CROSS_SIZE * 0.5

        local pixelX = normX * crossHalf
        local pixelY = -normY * crossHalf

        marker:ClearAnchors()
        marker:SetAnchor(CENTER, control, CENTER, pixelX, CROSS_OFFSET_Y + pixelY)
    end
end

local function ScheduleHide()
    EVENT_MANAGER:UnregisterForUpdate(hideTimerName)
    EVENT_MANAGER:RegisterForUpdate(hideTimerName, GetHideDelay(), function()
        CameraOffsetIndicator.Hide()
    end)
end

function CameraOffsetIndicator.Show()
    if not IsIndicatorEnabled() then
        return
    end

    if not control then
        CreateIndicatorUI()
    end

    UpdateIndicatorText()

    if not isVisible then
        control:SetHidden(false)
        isVisible = true
    end

    -- Reset hide timer
    ScheduleHide()
end

function CameraOffsetIndicator.Hide()
    EVENT_MANAGER:UnregisterForUpdate(hideTimerName)

    if control and isVisible then
        control:SetHidden(true)
        isVisible = false
    end
end

function CameraOffsetIndicator.Update()
    if isVisible then
        UpdateIndicatorText()
        ScheduleHide() -- Reset timer on update
    end
end

function CameraOffsetIndicator:Initialize(addonRef)
    addon = addonRef

    if not addon then
        return false
    end

    -- Register callback with CameraOffset module
    local offsetModule = addon.modules and addon.modules.CameraOffset
    if offsetModule then
        offsetModule.OnOffsetChanged = function()
            CameraOffsetIndicator.Show()
        end
    end

    return true
end

function CameraOffsetIndicator:Shutdown()
    CameraOffsetIndicator.Hide()

    -- Unregister callback
    local offsetModule = addon and addon.modules and addon.modules.CameraOffset
    if offsetModule then
        offsetModule.OnOffsetChanged = nil
    end

    -- Destroy UI
    if control then
        control:SetHidden(true)
        control = nil
        label = nil
        marker = nil
        isVisible = false
    end
end

FOXUltimateCamera.modules.CameraOffsetIndicator = CameraOffsetIndicator
