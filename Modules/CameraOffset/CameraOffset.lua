-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

local CameraOffset = {}

-- Camera setting identifiers
local CAMERA_TYPE = SETTING_TYPE_CAMERA
local CAMERA_FRAME_X = CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET
local CAMERA_FRAME_Y = CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET
local CAMERA_DISTANCE = CAMERA_SETTING_DISTANCE

-- Offset adjustment steps
local OFFSET_STEP_HOLD = 0.03 -- Hold increment per update (increased for better speed)
local UPDATE_INTERVAL_MS = 30 -- Update interval for hold (ms) - faster updates

-- ESO API limits for camera frame offset
local MIN_CAMERA_OFFSET_X = -1.0
local MAX_CAMERA_OFFSET_X = 1.0
local MIN_CAMERA_OFFSET_Y = -0.6 -- Restricted vertical range as per reference
local MAX_CAMERA_OFFSET_Y = 0.6

local function DetectCameraOffsetYLimits()
    local original = tonumber(GetSetting(CAMERA_TYPE, CAMERA_FRAME_Y))
    if not original then
        return
    end

    local function probe(value)
        SetSetting(CAMERA_TYPE, CAMERA_FRAME_Y, tostring(value))
        local result = tonumber(GetSetting(CAMERA_TYPE, CAMERA_FRAME_Y))
        return result
    end

    local minProbe = probe(-1.0)
    local maxProbe = probe(1.0)

    if type(minProbe) == "number" and type(maxProbe) == "number" and minProbe < maxProbe then
        MIN_CAMERA_OFFSET_Y = minProbe
        MAX_CAMERA_OFFSET_Y = maxProbe
    end

    SetSetting(CAMERA_TYPE, CAMERA_FRAME_Y, tostring(original))
end

-- Preset slot count
local PRESET_SLOT_COUNT = 3

local addon = nil
local EM = EVENT_MANAGER
local smoothingActive = false
local smoothingSilent = false -- Don't notify indicator during smoothing
local targetOffsetX = 0
local targetOffsetY = 0

-- Hold state tracking
local holdState = {
    left = false,
    right = false,
    up = false,
    down = false,
}

-- Clamp offset value to valid range
local function ClampOffsetX(value)
    if type(value) ~= "number" then
        return 0
    end
    return zo_clamp(value, MIN_CAMERA_OFFSET_X, MAX_CAMERA_OFFSET_X)
end

local function ClampOffsetY(value)
    if type(value) ~= "number" then
        return 0
    end
    return zo_clamp(value, MIN_CAMERA_OFFSET_Y, MAX_CAMERA_OFFSET_Y)
end

-- Get current camera offset X
local function GetCurrentOffsetX()
    -- If smoothing is active, we might return the actual setting value which is "in transit",
    -- or we could return the target. For logic consistency (like presets), returning the target
    -- when smoothing is active makes sense so we don't save "half-way" values.
    -- But native GetSetting returns the actual visual value.
    -- Let's return the actual value from the game to be safe.
    local value = tonumber(GetSetting(CAMERA_TYPE, CAMERA_FRAME_X))
    return value or 0
end

-- Get current camera offset Y
local function GetCurrentOffsetY()
    local value = tonumber(GetSetting(CAMERA_TYPE, CAMERA_FRAME_Y))
    return value or 0
end

local function IsSmoothingEnabled()
    return addon and addon.savedVars and addon.savedVars.offsetSmoothingEnabled
end

local function GetBaselineOffsetX()
    if IsSmoothingEnabled() and smoothingActive then
        return targetOffsetX
    end
    return GetCurrentOffsetX()
end

local function GetBaselineOffsetY()
    if IsSmoothingEnabled() and smoothingActive then
        return targetOffsetY
    end
    return GetCurrentOffsetY()
end

local function UpdateSmoothing()
    if not smoothingActive then return end

    local currentX = GetCurrentOffsetX()
    local currentY = GetCurrentOffsetY()

    local speed = (addon and addon.savedVars and addon.savedVars.offsetSmoothingSpeed) or 10
    -- GetFrameTimeSeconds() returns the frame delta time (seconds since last frame).
    -- At 60fps dt ≈ 0.016, so speed=10 gives factor ≈ 0.16 per frame — smooth lerp.
    local dt = GetFrameTimeSeconds()
    local lerpFactor = math.min(speed * dt, 1.0)

    local diffX = targetOffsetX - currentX
    local diffY = targetOffsetY - currentY

    local newX = currentX + (diffX * lerpFactor)
    local newY = currentY + (diffY * lerpFactor)

    -- Snap if close enough to stop micro-updates
    if math.abs(targetOffsetX - newX) < 0.001 then newX = targetOffsetX end
    if math.abs(targetOffsetY - newY) < 0.001 then newY = targetOffsetY end

    SetSetting(CAMERA_TYPE, CAMERA_FRAME_X, tostring(newX))
    SetSetting(CAMERA_TYPE, CAMERA_FRAME_Y, tostring(newY))

    -- Notify indicator during smoothing for live updates (unless silent)
    if not smoothingSilent and CameraOffset.OnOffsetChanged then
        CameraOffset.OnOffsetChanged()
    end

    if newX == targetOffsetX and newY == targetOffsetY then
        smoothingActive = false
        smoothingSilent = false -- Reset silent flag when smoothing completes
        EM:UnregisterForUpdate("FOXUC_CameraOffsetSmoothing")
    end
end

-- Set camera offset X
-- @param value: number - the offset value
-- @param silent: boolean - if true, don't notify indicator
local function SetOffsetX(value, silent)
    local clamped = ClampOffsetX(value)

    if IsSmoothingEnabled() then
        targetOffsetX = clamped
        -- Set silent flag for smoothing animation
        if silent then
            smoothingSilent = true
        end
        -- Sync target Y if not set yet
        if not smoothingActive then
            targetOffsetY = GetCurrentOffsetY()
            smoothingActive = true
            EM:RegisterForUpdate("FOXUC_CameraOffsetSmoothing", 0, UpdateSmoothing)
        end
    else
        SetSetting(CAMERA_TYPE, CAMERA_FRAME_X, tostring(clamped))
        -- Notify indicator (unless silent)
        if not silent and CameraOffset.OnOffsetChanged then
            CameraOffset.OnOffsetChanged()
        end
    end

    return clamped
end

-- Set camera offset Y
local function SetOffsetY(value)
    local clamped = ClampOffsetY(value)

    if IsSmoothingEnabled() then
        targetOffsetY = clamped
        -- Sync target X if not set yet
        if not smoothingActive then
            targetOffsetX = GetCurrentOffsetX()
            smoothingActive = true
            EM:RegisterForUpdate("FOXUC_CameraOffsetSmoothing", 0, UpdateSmoothing)
        end
    else
        SetSetting(CAMERA_TYPE, CAMERA_FRAME_Y, tostring(clamped))
        -- Notify indicator
        if CameraOffset.OnOffsetChanged then
            CameraOffset.OnOffsetChanged()
        end
    end

    return clamped
end

-- Hold timers using RegisterForUpdate for safe, cancellable updates
local EM = EVENT_MANAGER
local HOLD_TIMER_LEFT  = "FOXUC_CameraHold_Left"
local HOLD_TIMER_RIGHT = "FOXUC_CameraHold_Right"
local HOLD_TIMER_UP    = "FOXUC_CameraHold_Up"
local HOLD_TIMER_DOWN  = "FOXUC_CameraHold_Down"

local function StartHold(timerName, axis, direction)
    EM:UnregisterForUpdate(timerName)
    EM:RegisterForUpdate(timerName, UPDATE_INTERVAL_MS, function()
        if axis == "x" then
            local currentX = GetBaselineOffsetX()
            SetOffsetX(currentX + (direction * OFFSET_STEP_HOLD))
        else
            local currentY = GetBaselineOffsetY()
            SetOffsetY(currentY + (direction * OFFSET_STEP_HOLD))
        end
    end)
end

local function StopHold(timerName)
    EM:UnregisterForUpdate(timerName)
end

-- Move camera left
function CameraOffset.OnCameraLeft(keyDown)
    if keyDown then
        holdState.left = true
        StartHold(HOLD_TIMER_LEFT, "x", -1)
    else
        holdState.left = false
        StopHold(HOLD_TIMER_LEFT)
    end
end

-- Move camera right
function CameraOffset.OnCameraRight(keyDown)
    if keyDown then
        holdState.right = true
        StartHold(HOLD_TIMER_RIGHT, "x", 1)
    else
        holdState.right = false
        StopHold(HOLD_TIMER_RIGHT)
    end
end

-- Move camera up
function CameraOffset.OnCameraUp(keyDown)
    if keyDown then
        holdState.up = true
        StartHold(HOLD_TIMER_UP, "y", 1)
    else
        holdState.up = false
        StopHold(HOLD_TIMER_UP)
    end
end

-- Move camera down
function CameraOffset.OnCameraDown(keyDown)
    if keyDown then
        holdState.down = true
        StartHold(HOLD_TIMER_DOWN, "y", -1)
    else
        holdState.down = false
        StopHold(HOLD_TIMER_DOWN)
    end
end

-- Reset to center (0, 0)
function CameraOffset.OnResetToCenter()
    SetOffsetX(0)
    SetOffsetY(0)

    if addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d("[FOXUC] Camera offset reset to center (0, 0)")
    end
end

-- Shoulder Swap: Toggle between left and right shoulder X offset
function CameraOffset.OnShoulderSwap()
    local currentX = GetCurrentOffsetX()
    local newX

    -- Check if smart mode is enabled
    local smartMode = addon and addon.savedVars and addon.savedVars.shoulderSwapSmartMode

    if smartMode then
        -- Smart mode: mirror current X offset
        newX = -currentX
        -- If current X is near zero, use a default offset
        if math.abs(currentX) < 0.01 then
            newX = (addon and addon.savedVars and addon.savedVars.shoulderSwapRightValue) or MAX_CAMERA_OFFSET_X
        end
    else
        -- Fixed mode: toggle between left and right values
        local leftValue = (addon and addon.savedVars and addon.savedVars.shoulderSwapLeftValue) or MIN_CAMERA_OFFSET_X
        local rightValue = (addon and addon.savedVars and addon.savedVars.shoulderSwapRightValue) or MAX_CAMERA_OFFSET_X

        if currentX > 0 then
            newX = leftValue
        else
            newX = rightValue
        end
    end

    -- Silent mode: don't show indicator
    SetOffsetX(newX, true)

    if addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        local mode = smartMode and "smart" or "fixed"
        d(string.format("[FOXUC] Shoulder swap (%s): X %.2f -> %.2f", mode, currentX, newX))
    end
end

-- Save current offset and zoom to preset slot
function CameraOffset.SavePreset(slotIndex)
    if type(slotIndex) ~= "number" or slotIndex < 1 or slotIndex > PRESET_SLOT_COUNT then
        return false
    end

    if not addon or not addon.savedVars then
        return false
    end

    local currentX = GetCurrentOffsetX()
    local currentY = GetCurrentOffsetY()
    local currentZoom = tonumber(GetSetting(CAMERA_TYPE, CAMERA_DISTANCE)) or 0

    local fovFirstPerson = nil
    local fovThirdPerson = nil

    if addon and addon.modules and addon.modules.FovController then
        local fovModule = addon.modules.FovController
        if fovModule.GetFirstPersonFovGame and fovModule.GetThirdPersonFovGame then
            fovFirstPerson = fovModule:GetFirstPersonFovGame()
            fovThirdPerson = fovModule:GetThirdPersonFovGame()
        end
    end

    local slotKey = "cameraPresetSlot" .. slotIndex
    addon.savedVars[slotKey] = {
        x = currentX,
        y = currentY,
        zoom = currentZoom,
        fovFirstPerson = fovFirstPerson,
        fovThirdPerson = fovThirdPerson,
    }

    if addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC] Preset %d saved: X=%.2f, Y=%.2f, Zoom=%.1f",
            slotIndex, currentX, currentY, currentZoom))
    end

    return true
end

-- Load preset from slot
function CameraOffset.LoadPreset(slotIndex)
    if type(slotIndex) ~= "number" or slotIndex < 1 or slotIndex > PRESET_SLOT_COUNT then
        return false
    end

    if not addon or not addon.savedVars then
        return false
    end

    local slotKey = "cameraPresetSlot" .. slotIndex
    local preset = addon.savedVars[slotKey]

    if not preset or type(preset) ~= "table" then
        if addon.IsDebugEnabled and addon:IsDebugEnabled() then
            d(string.format("[FOXUC] Preset %d is empty", slotIndex))
        end
        return false
    end

    -- Apply offset
    if type(preset.x) == "number" then
        SetOffsetX(preset.x)
    end

    if type(preset.y) == "number" then
        SetOffsetY(preset.y)
    end

    -- Apply zoom if available
    if type(preset.zoom) == "number" and addon.SetCameraDistance then
        addon:SetCameraDistance(preset.zoom, { forceInstant = true })
    end

    -- Apply FOV if available
    if addon.modules and addon.modules.FovController then
        local fovModule = addon.modules.FovController

        if type(preset.fovFirstPerson) == "number" and fovModule.SetFirstPersonFovGame then
            fovModule:SetFirstPersonFovGame(preset.fovFirstPerson)
        end

        if type(preset.fovThirdPerson) == "number" and fovModule.SetThirdPersonFovGame then
            fovModule:SetThirdPersonFovGame(preset.fovThirdPerson)
        end
    end

    if addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC] Preset %d loaded: X=%.2f, Y=%.2f, Zoom=%.1f",
            slotIndex, preset.x or 0, preset.y or 0, preset.zoom or 0))
    end

    return true
end

-- Keybinding handlers for presets
function CameraOffset.OnSavePreset1()
    CameraOffset.SavePreset(1)
end

function CameraOffset.OnSavePreset2()
    CameraOffset.SavePreset(2)
end

function CameraOffset.OnSavePreset3()
    CameraOffset.SavePreset(3)
end

function CameraOffset.OnLoadPreset1()
    CameraOffset.LoadPreset(1)
end

function CameraOffset.OnLoadPreset2()
    CameraOffset.LoadPreset(2)
end

function CameraOffset.OnLoadPreset3()
    CameraOffset.LoadPreset(3)
end

-- Restore original camera settings
function CameraOffset.RestoreOriginalSettings()
    if not addon or not addon.savedVars then
        return false
    end

    local originalX = addon.savedVars.originalCameraX
    local originalY = addon.savedVars.originalCameraY
    local originalDistance = addon.savedVars.originalCameraDistance

    if type(originalX) ~= "number" or type(originalY) ~= "number" then
        if addon.IsDebugEnabled and addon:IsDebugEnabled() then
            d("[FOXUC] Original camera settings not found")
        end
        return false
    end

    -- Restore offset
    SetOffsetX(originalX)
    SetOffsetY(originalY)

    -- Restore zoom if available
    if type(originalDistance) == "number" and addon.SetCameraDistance then
        addon:SetCameraDistance(originalDistance, { forceInstant = true })
    end

    if addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC] Restored original settings: X=%.2f, Y=%.2f, Zoom=%.1f",
            originalX, originalY, originalDistance or 0))
    end

    return true
end

-- Keybinding handler for restore
function CameraOffset.OnRestoreOriginal()
    CameraOffset.RestoreOriginalSettings()
end

-- Update original settings to current values
function CameraOffset.UpdateOriginalSettings()
    if not addon or not addon.savedVars then
        return false
    end

    local currentX = GetCurrentOffsetX()
    local currentY = GetCurrentOffsetY()
    local currentDistance = tonumber(GetSetting(CAMERA_TYPE, CAMERA_DISTANCE)) or 0

    addon.savedVars.originalCameraX = currentX
    addon.savedVars.originalCameraY = currentY
    addon.savedVars.originalCameraDistance = currentDistance

    if addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC] Original settings updated: X=%.2f, Y=%.2f, Zoom=%.1f",
            currentX, currentY, currentDistance))
    end

    return true
end

function CameraOffset:GetCurrentOffsetX()
    return GetCurrentOffsetX()
end

function CameraOffset:GetCurrentOffsetY()
    return GetCurrentOffsetY()
end

function CameraOffset:SetOffsetX(value)
    return SetOffsetX(value)
end

function CameraOffset:SetOffsetY(value)
    return SetOffsetY(value)
end

function CameraOffset:GetOriginalOffsetX()
    if addon and addon.savedVars then
        return addon.savedVars.originalCameraX
    end
    return nil
end

function CameraOffset:GetOriginalOffsetY()
    if addon and addon.savedVars then
        return addon.savedVars.originalCameraY
    end
    return nil
end

function CameraOffset:GetOriginalDistance()
    if addon and addon.savedVars then
        return addon.savedVars.originalCameraDistance
    end
    return nil
end

function CameraOffset:Initialize(addonRef)
    addon = addonRef

    if not addon or not addon.savedVars then
        return false
    end

    DetectCameraOffsetYLimits()

    -- Save original settings ONLY if not already saved
    if addon.savedVars.originalCameraX == nil then
        addon.savedVars.originalCameraX = GetCurrentOffsetX()
        addon.savedVars.originalCameraY = GetCurrentOffsetY()
        addon.savedVars.originalCameraDistance = tonumber(GetSetting(CAMERA_TYPE, CAMERA_DISTANCE)) or 0

        if addon.IsDebugEnabled and addon:IsDebugEnabled() then
            d(string.format("[FOXUC] Original camera settings saved: X=%.2f, Y=%.2f, Zoom=%.1f",
                addon.savedVars.originalCameraX,
                addon.savedVars.originalCameraY,
                addon.savedVars.originalCameraDistance))
        end
    end

    -- Initialize preset slots if needed
    for i = 1, PRESET_SLOT_COUNT do
        local slotKey = "cameraPresetSlot" .. i
        if addon.savedVars[slotKey] == nil then
            addon.savedVars[slotKey] = {
                x = 0,
                y = 0,
                zoom = nil,
                fovFirstPerson = nil,
                fovThirdPerson = nil,
            }
        end
    end

    return true
end

function CameraOffset:Shutdown()
    -- Reset hold state (zo_callLater will stop automatically when flags are false)
    holdState.left = false
    holdState.right = false
    holdState.up = false
    holdState.down = false

    -- Stop smoothing if active
    smoothingActive = false
    EM:UnregisterForUpdate("FOXUC_CameraOffsetSmoothing")
end

FOXUltimateCamera.modules.CameraOffset = CameraOffset
