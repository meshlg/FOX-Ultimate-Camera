-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local ZoomSpeed = {}
ZoomSpeed.__index = ZoomSpeed

local Clamp = FOXUC_Utils.Clamp

function ZoomSpeed:New()
    local instance = setmetatable({}, ZoomSpeed)
    instance.owner = nil
    instance.minSpeed = 0.5
    instance.maxSpeed = 2.0
    instance.defaultSpeed = 1.0
    return instance
end

function ZoomSpeed:Initialize(owner, options)
    self.owner = owner
    options = options or {}

    if type(options.minSpeed) == "number" then
        self.minSpeed = options.minSpeed
    end
    if type(options.maxSpeed) == "number" then
        self.maxSpeed = options.maxSpeed
    end
    if type(options.defaultSpeed) == "number" then
        self.defaultSpeed = options.defaultSpeed
    end

    local savedVars = owner and owner.savedVars
    if savedVars then
        local savedValue = self:ClampValue(savedVars.zoomSpeed)
        savedVars.zoomSpeed = savedValue
    end
end

function ZoomSpeed:Shutdown()
    self.owner = nil
end

function ZoomSpeed:ClampValue(value)
    local clamped = Clamp(value, self.minSpeed, self.maxSpeed)
    if clamped == nil then
        clamped = self.defaultSpeed
    end
    return clamped
end

function ZoomSpeed:GetZoomSpeedRange()
    return self.minSpeed, self.maxSpeed, self.defaultSpeed
end

function ZoomSpeed:GetZoomSpeed()
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return self.defaultSpeed
    end
    return self:ClampValue(savedVars.zoomSpeed)
end

function ZoomSpeed:SetZoomSpeed(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = self:ClampValue(value)
    if savedVars.zoomSpeed == clamped then
        return
    end

    savedVars.zoomSpeed = clamped
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.zoomSpeed then
    FOXUC.modules.zoomSpeed = ZoomSpeed:New()
end
