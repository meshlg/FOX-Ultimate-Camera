-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local FirstPersonMode = {}
FirstPersonMode.__index = FirstPersonMode

local TRANSITION_SOURCE = {
    STARTUP = "startup",
    TOGGLE = "toggle",
    TOGGLE_ENTER = "toggle_enter",
    TOGGLE_EXIT = "toggle_exit",
    SCROLL_ENTER = "scroll_enter",
    SCROLL_EXIT = "scroll_exit",
    SCROLL_ADJUST = "scroll_adjust",
}

local EPSILON = 1e-4

local function SafeIsInFirstPerson()
    if type(IsInFirstPerson) == "function" then
        return IsInFirstPerson()
    end
    return false
end

local function GetCameraSettingDistance()
    if type(GetSetting) == "function" then
        local value = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
        if value ~= nil then
            return tonumber(value)
        end
    end
    return nil
end

local function GetCurrentFrameTime()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

function FirstPersonMode:New()
    local instance = setmetatable({}, FirstPersonMode)
    instance:Reset()
    return instance
end

function FirstPersonMode:Reset()
    self.owner = nil
    self.boundary = 0
    self.isActive = false
    self.pendingSource = nil
    self.lastSource = TRANSITION_SOURCE.STARTUP
    self.lastDistance = nil
    self.lastChangeTimeMs = GetCurrentFrameTime()
end

function FirstPersonMode:Initialize(owner, boundary)
    self.owner = owner
    self.boundary = boundary or 0
    local currentDistance = GetCameraSettingDistance()
    self.isActive = SafeIsInFirstPerson() or (currentDistance and currentDistance <= self.boundary + EPSILON) or false
    self.lastDistance = currentDistance
    self.lastSource = TRANSITION_SOURCE.STARTUP
    self.lastChangeTimeMs = GetCurrentFrameTime()
end

function FirstPersonMode:SetPendingSource(source)
    self.pendingSource = source
end

function FirstPersonMode:IsFirstPersonActive()
    return self.isActive
end

function FirstPersonMode:GetLastTransition()
    return self.lastSource, self.lastChangeTimeMs, self.lastDistance
end

local function ResolveSource(instance, desiredState)
    local source = instance.pendingSource
    if source == nil then
        return desiredState and TRANSITION_SOURCE.SCROLL_ENTER or TRANSITION_SOURCE.SCROLL_EXIT
    end

    if source == TRANSITION_SOURCE.TOGGLE then
        return desiredState and TRANSITION_SOURCE.TOGGLE_ENTER or TRANSITION_SOURCE.TOGGLE_EXIT
    end

    return source
end

function FirstPersonMode:ApplyTransition(desiredState, distance)
    local source = ResolveSource(self, desiredState)
    self.pendingSource = nil

    self.isActive = desiredState
    self.lastDistance = distance
    self.lastSource = source
    self.lastChangeTimeMs = GetCurrentFrameTime()

    if self.owner and self.owner.OnFirstPersonTransition then
        self.owner:OnFirstPersonTransition(desiredState, source, distance)
    end
end

function FirstPersonMode:OnZoomValue(distance)
    if distance == nil then
        return
    end

    self.lastDistance = distance

    local isFirstPerson = distance <= (self.boundary + EPSILON)
    if isFirstPerson ~= self.isActive then
        self:ApplyTransition(isFirstPerson, distance)
    else
        self.pendingSource = nil
    end
end

function FirstPersonMode:SetFirstPersonActive(active, distance)
    if type(active) ~= "boolean" then
        active = SafeIsInFirstPerson()
    end

    if distance ~= nil then
        self.lastDistance = distance
    end

    if active ~= self.isActive then
        self:ApplyTransition(active and true or false, self.lastDistance)
    else
        self.pendingSource = nil
    end
end

function FirstPersonMode:Shutdown()
    self:Reset()
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.firstPerson then
    FOXUC.modules.firstPerson = FirstPersonMode:New()
end

FOXUC.modules.firstPerson.TRANSITION_SOURCE = TRANSITION_SOURCE
