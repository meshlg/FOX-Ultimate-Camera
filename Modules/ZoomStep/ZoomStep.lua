-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local ZoomStep = {}
ZoomStep.__index = ZoomStep

local Clamp = FOXUC_Utils.Clamp

function ZoomStep:New()
    local instance = setmetatable({}, ZoomStep)
    instance.owner = nil
    instance.minStep = 0.025
    instance.maxStep = 1
    instance.defaultStep = 0.225
    return instance
end

function ZoomStep:Initialize(owner, options)
    self.owner = owner
    options = options or {}

    if type(options.minStep) == "number" then
        self.minStep = options.minStep
    end
    if type(options.maxStep) == "number" then
        self.maxStep = options.maxStep
    end
    if type(options.defaultStep) == "number" then
        self.defaultStep = options.defaultStep
    end

    local savedVars = owner and owner.savedVars
    if savedVars then
        local savedValue = self:ClampValue(savedVars.zoomStep)
        savedVars.zoomStep = savedValue
    end
end

function ZoomStep:Shutdown()
    self.owner = nil
end

function ZoomStep:ClampValue(value)
    local clamped = Clamp(value, self.minStep, self.maxStep)
    if clamped == nil then
        clamped = self.defaultStep
    end
    return clamped
end

function ZoomStep:GetZoomStepRange()
    return self.minStep, self.maxStep, self.defaultStep
end

function ZoomStep:GetZoomStep()
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return self.defaultStep
    end
    return self:ClampValue(savedVars.zoomStep)
end

function ZoomStep:SetZoomStep(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = self:ClampValue(value)
    if savedVars.zoomStep == clamped then
        return
    end

    savedVars.zoomStep = clamped
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.zoomStep then
    FOXUC.modules.zoomStep = ZoomStep:New()
end
