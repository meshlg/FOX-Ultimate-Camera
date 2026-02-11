-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

local ContextSensitivity = {}
ContextSensitivity.__index = ContextSensitivity

local DEFAULT_MULTIPLIER = 1.0
local MIN_MULTIPLIER = 0.5
local MAX_MULTIPLIER = 3.0

-- ESO API constants (use globals directly)
local CAMERA_SENS_THIRD = CAMERA_SETTING_SENSITIVITY_THIRD_PERSON
local CAMERA_SENS_FIRST = CAMERA_SETTING_SENSITIVITY_FIRST_PERSON

local EM = EVENT_MANAGER

local function ClampMultiplier(value)
    if type(value) ~= "number" then
        return DEFAULT_MULTIPLIER
    end
    if value < MIN_MULTIPLIER then
        return MIN_MULTIPLIER
    end
    if value > MAX_MULTIPLIER then
        return MAX_MULTIPLIER
    end
    return value
end

function ContextSensitivity:New()
    local instance = setmetatable({}, ContextSensitivity)
    instance.owner = nil
    instance.initialized = false
    
    -- Multipliers for different contexts
    instance.combatMultiplier = DEFAULT_MULTIPLIER
    instance.mountedMultiplier = DEFAULT_MULTIPLIER
    instance.sprintMultiplier = DEFAULT_MULTIPLIER
    
    -- Base sensitivity values (from game settings)
    instance.baseSensitivity1st = 0.85
    instance.baseSensitivity3rd = 0.85
    
    -- Current state tracking
    instance.currentState = "default" -- "default", "combat", "mounted", "sprint"
    instance.appliedMultiplier = DEFAULT_MULTIPLIER
    
    -- Player states
    instance.isMounted = false
    instance.isInCombat = false
    instance.isSprinting = false
    
    -- Update interval (ms)
    instance.updateInterval = 50
    
    return instance
end

function ContextSensitivity:Initialize(owner)
    if self.initialized then
        return
    end
    
    self.owner = owner
    
    -- Load saved multipliers
    local savedVars = owner and owner.savedVars
    if savedVars then
        self.combatMultiplier = ClampMultiplier(savedVars.contextSensitivityCombat)
        self.mountedMultiplier = ClampMultiplier(savedVars.contextSensitivityMounted)
        self.sprintMultiplier = ClampMultiplier(savedVars.contextSensitivitySprint)
    end
    
    -- Get base camera sensitivity from game settings
    self.baseSensitivity3rd = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_THIRD)) or 0.85
    self.baseSensitivity1st = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_FIRST)) or 0.85
    
    -- Initialize player states
    self.isMounted = IsMounted()
    self.isInCombat = IsUnitInCombat("player")
    
    -- Register event handlers
    self:RegisterEvents()
    
    -- Start update loop
    EM:RegisterForUpdate(owner.name .. "_ContextSensitivity", self.updateInterval, function()
        self:OnUpdate()
    end)
    
    self.initialized = true
end

function ContextSensitivity:Shutdown()
    if not self.initialized then
        return
    end
    
    -- Unregister events
    self:UnregisterEvents()
    
    -- Stop update loop
    if self.owner then
        EM:UnregisterForUpdate(self.owner.name .. "_ContextSensitivity")
    end
    
    -- Restore base sensitivity
    self:RestoreBaseSensitivity()
    
    self.owner = nil
    self.initialized = false
end

function ContextSensitivity:RegisterEvents()
    local addonName = self.owner and self.owner.name or "FOXUltimateCamera"
    
    -- Combat state change
    EM:RegisterForEvent(addonName .. "_ContextSens_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatStateChanged(inCombat)
    end)
    
    -- Mounted state change
    EM:RegisterForEvent(addonName .. "_ContextSens_Mounted", EVENT_MOUNTED_STATE_CHANGED, function(_, mounted)
        self:OnMountedStateChanged(mounted)
    end)
end

function ContextSensitivity:UnregisterEvents()
    local addonName = self.owner and self.owner.name or "FOXUltimateCamera"
    
    EM:UnregisterForEvent(addonName .. "_ContextSens_Combat", EVENT_PLAYER_COMBAT_STATE)
    EM:UnregisterForEvent(addonName .. "_ContextSens_Mounted", EVENT_MOUNTED_STATE_CHANGED)
end

function ContextSensitivity:OnCombatStateChanged(inCombat)
    self.isInCombat = inCombat
    self:UpdateSensitivity()
end

function ContextSensitivity:OnMountedStateChanged(mounted)
    self.isMounted = mounted
    self:UpdateSensitivity()
end

function ContextSensitivity:OnUpdate()
    local isSprinting = false
    
    if IsUnitSprinting then
        isSprinting = IsUnitSprinting("player")
    else
        -- Fallback for when IsUnitSprinting is not available (older APIs or restriction)
        local isMoving = IsPlayerMoving()
        local isShiftDown = IsShiftKeyDown() -- Default sprint key
        local hasStamina = GetUnitPower("player", POWERTYPE_STAMINA) > 0
        
        isSprinting = isMoving and isShiftDown and hasStamina and not self.isMounted
    end
    
    if self.isMounted then
        isSprinting = false
    end

    if isSprinting ~= self.isSprinting then
        self.isSprinting = isSprinting
        self:UpdateSensitivity()
    end
end

function ContextSensitivity:GetCurrentMultiplier()
    -- Priority: mounted > combat > sprint > default
    if self.isMounted then
        return self.mountedMultiplier
    end
    
    if self.isInCombat then
        return self.combatMultiplier
    end
    
    if self.isSprinting then
        return self.sprintMultiplier
    end
    
    return DEFAULT_MULTIPLIER
end

function ContextSensitivity:GetCurrentState()
    if self.isMounted then
        return "mounted"
    end
    
    if self.isInCombat then
        return "combat"
    end
    
    if self.isSprinting then
        return "sprint"
    end
    
    return "default"
end

function ContextSensitivity:UpdateSensitivity()
    local owner = self.owner
    if owner and owner.modules and owner.modules.InteractionGuard then
        local guard = owner.modules.InteractionGuard
        if guard.ShouldBlockAutoCamera and guard:ShouldBlockAutoCamera() then
            self:RestoreBaseSensitivity()
            return
        end
    end

    local newState = self:GetCurrentState()
    local newMultiplier = self:GetCurrentMultiplier()
    
    -- Only update if state or multiplier changed
    if newState == self.currentState and newMultiplier == self.appliedMultiplier then
        return
    end
    
    self.currentState = newState
    self.appliedMultiplier = newMultiplier
    
    -- Apply multiplier to base sensitivity
    local newSensitivity3rd = self.baseSensitivity3rd * newMultiplier
    local newSensitivity1st = self.baseSensitivity1st * newMultiplier
    
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_THIRD, tostring(newSensitivity3rd))
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_FIRST, tostring(newSensitivity1st))
end

function ContextSensitivity:RestoreBaseSensitivity()
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_THIRD, tostring(self.baseSensitivity3rd))
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_FIRST, tostring(self.baseSensitivity1st))
    self.appliedMultiplier = DEFAULT_MULTIPLIER
    self.currentState = "default"
end

function ContextSensitivity:RefreshBaseSensitivity()
    -- Read current game settings as new base (useful when player changes settings)
    if self.currentState == "default" then
        self.baseSensitivity3rd = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_THIRD)) or self.baseSensitivity3rd
        self.baseSensitivity1st = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SENS_FIRST)) or self.baseSensitivity1st
    end
end

-- Combat multiplier
function ContextSensitivity:GetCombatMultiplier()
    return self.combatMultiplier or DEFAULT_MULTIPLIER
end

function ContextSensitivity:SetCombatMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end
    
    local clamped = ClampMultiplier(value)
    if savedVars.contextSensitivityCombat == clamped then
        return
    end
    
    savedVars.contextSensitivityCombat = clamped
    self.combatMultiplier = clamped
    
    -- Update sensitivity if currently in combat
    if self.isInCombat then
        self:UpdateSensitivity()
    end
end

-- Mounted multiplier
function ContextSensitivity:GetMountedMultiplier()
    return self.mountedMultiplier or DEFAULT_MULTIPLIER
end

function ContextSensitivity:SetMountedMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end
    
    local clamped = ClampMultiplier(value)
    if savedVars.contextSensitivityMounted == clamped then
        return
    end
    
    savedVars.contextSensitivityMounted = clamped
    self.mountedMultiplier = clamped
    
    -- Update sensitivity if currently mounted
    if self.isMounted then
        self:UpdateSensitivity()
    end
end

-- Sprint multiplier
function ContextSensitivity:GetSprintMultiplier()
    return self.sprintMultiplier or DEFAULT_MULTIPLIER
end

function ContextSensitivity:SetSprintMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end
    
    local clamped = ClampMultiplier(value)
    if savedVars.contextSensitivitySprint == clamped then
        return
    end
    
    savedVars.contextSensitivitySprint = clamped
    self.sprintMultiplier = clamped
    
    -- Update sensitivity if currently sprinting
    if self.isSprinting then
        self:UpdateSensitivity()
    end
end

-- Module registration
FOXUltimateCamera = FOXUltimateCamera or {}
local FOXUC = FOXUltimateCamera
FOXUC.modules = FOXUC.modules or {}

if not FOXUC.modules.contextSensitivity then
    FOXUC.modules.contextSensitivity = ContextSensitivity:New()
end
