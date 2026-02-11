-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local CameraLimits = {}
CameraLimits.__index = CameraLimits

local Clamp = FOXUC_Utils.Clamp

function CameraLimits:New()
    local instance = setmetatable({}, CameraLimits)
    instance.owner = nil
    instance.minBoundary = 0
    instance.minAllowed = 2
    instance.maxAllowed = 10
    instance.defaultMax = 10
    instance.epsilon = 1e-4
    return instance
end

function CameraLimits:Initialize(owner, options)
    self.owner = owner
    options = options or {}
    self.minBoundary = options.minBoundary or self.minBoundary
    self.minAllowed = options.configMin or self.minAllowed
    self.maxAllowed = options.configMax or self.maxAllowed
    self.defaultMax = options.defaultMax or self.defaultMax
    self.epsilon = options.epsilon or self.epsilon

    local savedVars = owner and owner.savedVars
    if savedVars then
        local savedValue = savedVars.maxZoomDistance
        if type(savedValue) ~= "number" then
            savedValue = self.defaultMax
        end
        savedVars.maxZoomDistance = self:ClampConfigValue(savedValue)
    end

    self:EnforceMaxZoomDistance()
end

function CameraLimits:Shutdown()
    self.owner = nil
end

function CameraLimits:ClampConfigValue(value)
    local clamped = Clamp(value, self.minAllowed, self.maxAllowed)
    if clamped == nil then
        clamped = self.defaultMax
    end
    return clamped
end

function CameraLimits:GetMaxZoomDistanceRange()
    return self.minAllowed, self.maxAllowed, self.defaultMax
end

function CameraLimits:GetMaxZoomDistance()
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return self.defaultMax
    end
    return self:ClampConfigValue(savedVars.maxZoomDistance)
end

function CameraLimits:SetMaxZoomDistance(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = self:ClampConfigValue(value)
    if savedVars.maxZoomDistance == clamped then
        return
    end

    savedVars.maxZoomDistance = clamped
    self:EnforceMaxZoomDistance()

    if self.owner and self.owner.RememberZoom then
        self.owner:RememberZoom()
    end
end

function CameraLimits:ClampDistance(distance)
    if type(distance) ~= "number" then
        return nil
    end

    local clamped = distance
    local maxZoom = self:GetMaxZoomDistance()
    if clamped > maxZoom then
        clamped = maxZoom
    end

    if clamped < self.minBoundary then
        clamped = self.minBoundary
    end

    return clamped
end

function CameraLimits:EnforceMaxZoomDistance()
    if not (self.owner and self.owner._SetCameraDistanceInternal) then
        return
    end

    local rawValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
    local clamped = self:ClampDistance(rawValue)
    if rawValue == nil or clamped == nil then
        return
    end

    if math.abs(clamped - rawValue) > self.epsilon then
        self.owner:_SetCameraDistanceInternal(clamped)
    end
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.cameraLimits then
    FOXUC.modules.cameraLimits = CameraLimits:New()
end
