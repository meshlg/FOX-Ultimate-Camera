-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local ZoomSmoothing = {}
ZoomSmoothing.__index = ZoomSmoothing

local DEFAULT_STEP_INTERVAL_MS = 16
local DEFAULT_LERP_FACTOR = 0.35
local MIN_PROGRESS_THRESHOLD = 0.001

local function ReadCameraDistance()
    local value = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
    return tonumber(value)
end

function ZoomSmoothing:New()
    local instance = setmetatable({}, ZoomSmoothing)
    instance.owner = nil
    instance.enabled = false
    instance.targetDistance = nil
    instance.pendingHandle = nil
    instance.stepIntervalMs = DEFAULT_STEP_INTERVAL_MS
    instance.lerpFactor = DEFAULT_LERP_FACTOR
    return instance
end

function ZoomSmoothing:Initialize(owner, options)
    self.owner = owner
    options = options or {}

    if type(options.stepIntervalMs) == "number" then
        self.stepIntervalMs = math.max(1, options.stepIntervalMs)
    end
    if type(options.lerpFactor) == "number" then
        self.lerpFactor = zo_clamp(options.lerpFactor, 0.05, 0.95)
    end

    self:SetEnabled(owner and owner:IsZoomSmoothingEnabled())
end

function ZoomSmoothing:Shutdown()
    self:Cancel()
    self.owner = nil
end

function ZoomSmoothing:SetEnabled(state)
    local enabled = state and true or false
    if self.enabled == enabled then
        return
    end

    self.enabled = enabled
    if not self.enabled then
        self:Cancel()
    end
end

function ZoomSmoothing:IsEnabled()
    return self.enabled and true or false
end

function ZoomSmoothing:Cancel()
    if self.pendingHandle then
        zo_removeCallLater(self.pendingHandle)
        self.pendingHandle = nil
    end
    self.targetDistance = nil
end

local function NeedsSmoothing(current, target)
    if current == nil or target == nil then
        return false
    end
    return math.abs(target - current) > MIN_PROGRESS_THRESHOLD
end

function ZoomSmoothing:Apply(targetDistance, options)
    options = options or {}

    if not self.owner then
        return
    end

    if options.forceInstant or not self:IsEnabled() then
        self:Cancel()
        self.owner:_SetCameraDistanceImmediate(targetDistance)
        return
    end

    local current = ReadCameraDistance()
    if not NeedsSmoothing(current, targetDistance) then
        self:Cancel()
        self.owner:_SetCameraDistanceImmediate(targetDistance)
        return
    end

    self.targetDistance = targetDistance
    self:ScheduleStep()
end

local function GetSpeedFactor(self, delta)
    local owner = self.owner
    if not owner or not owner.GetZoomSpeed then
        return 1
    end

    local speed = owner:GetZoomSpeed()
    if type(speed) ~= "number" then
        return 1
    end

    local direction
    if type(delta) == "number" then
        if delta > 0 then
            direction = "out"
        elseif delta < 0 then
            direction = "in"
        end
    end

    if direction and owner.GetContextSpeedFactor then
        local contextFactor = owner:GetContextSpeedFactor(direction)
        if type(contextFactor) == "number" and contextFactor > 0 then
            speed = speed * contextFactor
        end
    end

    if speed < 0.1 then
        speed = 0.1
    end

    return speed
end

function ZoomSmoothing:ScheduleStep()
    if self.pendingHandle then
        zo_removeCallLater(self.pendingHandle)
        self.pendingHandle = nil
    end

    local function step()
        self.pendingHandle = nil

        if not self.owner or not self.enabled or not self.targetDistance then
            self:Cancel()
            return
        end

        local current = ReadCameraDistance()
        local target = self.targetDistance
        if not NeedsSmoothing(current, target) then
            self.owner:_SetCameraDistanceImmediate(target)
            self.targetDistance = nil
            return
        end

        local delta = target - current
        local lerpFactor = self.lerpFactor * GetSpeedFactor(self, delta)
        if lerpFactor < 0.05 then
            lerpFactor = 0.05
        elseif lerpFactor > 0.95 then
            lerpFactor = 0.95
        end

        local nextValue = current + (delta * lerpFactor)
        if math.abs(nextValue - current) < MIN_PROGRESS_THRESHOLD then
            nextValue = target
        end

        self.owner:_SetCameraDistanceImmediate(nextValue)
        self.pendingHandle = zo_callLater(step, self.stepIntervalMs)
    end

    self.pendingHandle = zo_callLater(step, 0)
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.zoomSmoothing then
    FOXUC.modules.zoomSmoothing = ZoomSmoothing:New()
end
