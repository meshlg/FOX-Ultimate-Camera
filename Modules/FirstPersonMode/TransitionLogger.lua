-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local TransitionLogger = {}
TransitionLogger.__index = TransitionLogger

local DEFAULT_CAPACITY = 20

local function ClampHistory(self)
    while #self.history > DEFAULT_CAPACITY do
        table.remove(self.history, 1)
    end
end

local function FormatStateString(isActive)
    return isActive and "First Person" or "Third Person"
end

function TransitionLogger:New()
    local instance = setmetatable({}, TransitionLogger)
    instance.history = {}
    instance.owner = nil
    instance.capacity = DEFAULT_CAPACITY
    instance.debugEnabled = false
    return instance
end

function TransitionLogger:Initialize(owner, capacity)
    self.owner = owner
    if type(capacity) == "number" and capacity > 0 then
        self.capacity = math.floor(capacity)
    end
end

function TransitionLogger:SetCapacity(capacity)
    if type(capacity) ~= "number" or capacity <= 0 then
        return
    end

    self.capacity = math.floor(capacity)
    ClampHistory(self)
end

function TransitionLogger:LogTransition(isActive, source, distance)
    local entry = {
        state = isActive,
        source = source,
        distance = distance,
        timestamp = GetTimeStamp and GetTimeStamp() or 0,
    }

    table.insert(self.history, entry)
    ClampHistory(self)

    if d and self.debugEnabled then
        local message = string.format("[FOXUltimateCamera] FPV %s via %s (%.2f)", FormatStateString(isActive), tostring(source or "unknown"), tonumber(distance or 0) or 0)
        d(message)
    end
end

function TransitionLogger:OnFirstPersonTransition(isActive, source, distance)
    self:LogTransition(isActive, source, distance)
end

function TransitionLogger:GetHistory()
    return self.history
end

function TransitionLogger:OnDebugPreferenceChanged(enabled)
    self.debugEnabled = enabled and true or false
end

function TransitionLogger:Shutdown()
    self.history = {}
    self.owner = nil
    self.debugEnabled = false
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.transitionLogger then
    FOXUC.modules.transitionLogger = TransitionLogger:New()
end
