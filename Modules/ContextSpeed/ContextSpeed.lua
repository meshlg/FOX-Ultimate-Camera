-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local ContextSpeed = {}
ContextSpeed.__index = ContextSpeed

local MIN_MULTIPLIER = 0.5
local MAX_MULTIPLIER = 3.5
local DEFAULT_MULTIPLIER = 1.0

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

function ContextSpeed:New()
    local instance = setmetatable({}, ContextSpeed)
    instance.owner = nil
    instance.combatInMultiplier = DEFAULT_MULTIPLIER
    instance.combatOutMultiplier = DEFAULT_MULTIPLIER
    instance.stealthInMultiplier = DEFAULT_MULTIPLIER
    instance.stealthOutMultiplier = DEFAULT_MULTIPLIER
    instance.mountedInMultiplier = DEFAULT_MULTIPLIER
    instance.mountedOutMultiplier = DEFAULT_MULTIPLIER
    instance.separateInOut = false
    return instance
end

function ContextSpeed:Initialize(owner)
    self.owner = owner

    local savedVars = owner and owner.savedVars
    if savedVars then
        self.separateInOut = savedVars.contextSpeedSeparateInOut or false
        
        local combatBase = savedVars.contextSpeedCombat
        self.combatInMultiplier = ClampMultiplier(savedVars.contextSpeedCombatIn or combatBase or DEFAULT_MULTIPLIER)
        self.combatOutMultiplier = ClampMultiplier(savedVars.contextSpeedCombatOut or combatBase or DEFAULT_MULTIPLIER)
        savedVars.contextSpeedCombatIn = self.combatInMultiplier
        savedVars.contextSpeedCombatOut = self.combatOutMultiplier

        local stealthBase = savedVars.contextSpeedStealth
        self.stealthInMultiplier = ClampMultiplier(savedVars.contextSpeedStealthIn or stealthBase or DEFAULT_MULTIPLIER)
        self.stealthOutMultiplier = ClampMultiplier(savedVars.contextSpeedStealthOut or stealthBase or DEFAULT_MULTIPLIER)
        savedVars.contextSpeedStealthIn = self.stealthInMultiplier
        savedVars.contextSpeedStealthOut = self.stealthOutMultiplier

        local mountedBase = savedVars.contextSpeedMounted
        self.mountedInMultiplier = ClampMultiplier(savedVars.contextSpeedMountedIn or mountedBase or DEFAULT_MULTIPLIER)
        self.mountedOutMultiplier = ClampMultiplier(savedVars.contextSpeedMountedOut or mountedBase or DEFAULT_MULTIPLIER)
        savedVars.contextSpeedMountedIn = self.mountedInMultiplier
        savedVars.contextSpeedMountedOut = self.mountedOutMultiplier
    end
end

function ContextSpeed:Shutdown()
    self.owner = nil
end

local function IsPlayerInCombat()
    if type(IsUnitInCombat) ~= "function" then
        return false
    end
    return IsUnitInCombat("player") and true or false
end

local function IsPlayerMounted()
    if type(IsMounted) ~= "function" then
        return false
    end
    return IsMounted() and true or false
end

local function IsPlayerStealthed()
    if type(GetUnitStealthState) ~= "function" then
        return false
    end

    local state = GetUnitStealthState("player")
    if state == nil then
        return false
    end

    return state == STEALTH_STATE_STEALTH or state == STEALTH_STATE_HIDDEN
end

function ContextSpeed:IsSeparateInOutEnabled()
    return self.separateInOut
end

function ContextSpeed:SetSeparateInOutEnabled(enabled)
    local value = enabled and true or false
    if self.separateInOut == value then
        return
    end
    self.separateInOut = value
    
    if self.owner and self.owner.savedVars then
        self.owner.savedVars.contextSpeedSeparateInOut = value
    end
end

function ContextSpeed:GetCurrentSpeedFactor(direction)
    -- Priority: mounted > combat > stealth > default
    
    local owner = self.owner
    if owner and owner.modules and owner.modules.InteractionGuard then
        local guard = owner.modules.InteractionGuard
        if guard.ShouldBlockAutoCamera and guard:ShouldBlockAutoCamera() then
            return DEFAULT_MULTIPLIER
        end
    end

    local useIn = (direction == "in")
    local useOut = (direction == "out")
    
    if not self.separateInOut then
        -- When separation is disabled, we use the "Out" multiplier as the master value
        -- because the unified setters update both In and Out to match.
        -- If they were desynchronized, this effectively forces using one of them.
        if IsPlayerMounted() then
            return self.mountedOutMultiplier or DEFAULT_MULTIPLIER
        end
        if IsPlayerInCombat() then
            return self.combatOutMultiplier or DEFAULT_MULTIPLIER
        end
        if IsPlayerStealthed() then
            return self.stealthOutMultiplier or DEFAULT_MULTIPLIER
        end
        return DEFAULT_MULTIPLIER
    end

    if IsPlayerMounted() then
        if useIn and self.mountedInMultiplier then
            return self.mountedInMultiplier
        end
        if useOut and self.mountedOutMultiplier then
            return self.mountedOutMultiplier
        end
        return self.mountedOutMultiplier or self.mountedInMultiplier or DEFAULT_MULTIPLIER
    end

    if IsPlayerInCombat() then
        if useIn and self.combatInMultiplier then
            return self.combatInMultiplier
        end
        if useOut and self.combatOutMultiplier then
            return self.combatOutMultiplier
        end
        return self.combatOutMultiplier or self.combatInMultiplier or DEFAULT_MULTIPLIER
    end

    if IsPlayerStealthed() then
        if useIn and self.stealthInMultiplier then
            return self.stealthInMultiplier
        end
        if useOut and self.stealthOutMultiplier then
            return self.stealthOutMultiplier
        end
        return self.stealthOutMultiplier or self.stealthInMultiplier or DEFAULT_MULTIPLIER
    end

    return DEFAULT_MULTIPLIER
end

function ContextSpeed:GetCombatMultiplier()
    return self.combatOutMultiplier or self.combatInMultiplier or DEFAULT_MULTIPLIER
end

function ContextSpeed:SetCombatMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)

    if savedVars.contextSpeedCombatIn == clamped and savedVars.contextSpeedCombatOut == clamped then
        return
    end

    savedVars.contextSpeedCombatIn = clamped
    savedVars.contextSpeedCombatOut = clamped
    self.combatInMultiplier = clamped
    self.combatOutMultiplier = clamped
end

function ContextSpeed:GetStealthMultiplier()
    return self.stealthOutMultiplier or self.stealthInMultiplier or DEFAULT_MULTIPLIER
end

function ContextSpeed:SetStealthMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)

    if savedVars.contextSpeedStealthIn == clamped and savedVars.contextSpeedStealthOut == clamped then
        return
    end

    savedVars.contextSpeedStealthIn = clamped
    savedVars.contextSpeedStealthOut = clamped
    self.stealthInMultiplier = clamped
    self.stealthOutMultiplier = clamped
end

function ContextSpeed:GetMountedMultiplier()
    return self.mountedOutMultiplier or self.mountedInMultiplier or DEFAULT_MULTIPLIER
end

function ContextSpeed:SetMountedMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)

    if savedVars.contextSpeedMountedIn == clamped and savedVars.contextSpeedMountedOut == clamped then
        return
    end

    savedVars.contextSpeedMountedIn = clamped
    savedVars.contextSpeedMountedOut = clamped
    self.mountedInMultiplier = clamped
    self.mountedOutMultiplier = clamped
end

function ContextSpeed:GetCombatInMultiplier()
    return self.combatInMultiplier
end

function ContextSpeed:SetCombatInMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)
    if savedVars.contextSpeedCombatIn == clamped then
        return
    end

    savedVars.contextSpeedCombatIn = clamped
    self.combatInMultiplier = clamped
end

function ContextSpeed:GetCombatOutMultiplier()
    return self.combatOutMultiplier
end

function ContextSpeed:SetCombatOutMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)
    if savedVars.contextSpeedCombatOut == clamped then
        return
    end

    savedVars.contextSpeedCombatOut = clamped
    self.combatOutMultiplier = clamped
end

function ContextSpeed:GetStealthInMultiplier()
    return self.stealthInMultiplier
end

function ContextSpeed:SetStealthInMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)
    if savedVars.contextSpeedStealthIn == clamped then
        return
    end

    savedVars.contextSpeedStealthIn = clamped
    self.stealthInMultiplier = clamped
end

function ContextSpeed:GetStealthOutMultiplier()
    return self.stealthOutMultiplier
end

function ContextSpeed:SetStealthOutMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)
    if savedVars.contextSpeedStealthOut == clamped then
        return
    end

    savedVars.contextSpeedStealthOut = clamped
    self.stealthOutMultiplier = clamped
end

function ContextSpeed:GetMountedInMultiplier()
    return self.mountedInMultiplier
end

function ContextSpeed:SetMountedInMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)
    if savedVars.contextSpeedMountedIn == clamped then
        return
    end

    savedVars.contextSpeedMountedIn = clamped
    self.mountedInMultiplier = clamped
end

function ContextSpeed:GetMountedOutMultiplier()
    return self.mountedOutMultiplier
end

function ContextSpeed:SetMountedOutMultiplier(value)
    local savedVars = self.owner and self.owner.savedVars
    if not savedVars then
        return
    end

    local clamped = ClampMultiplier(value)
    if savedVars.contextSpeedMountedOut == clamped then
        return
    end

    savedVars.contextSpeedMountedOut = clamped
    self.mountedOutMultiplier = clamped
end

FOXUltimateCamera = FOXUltimateCamera or {}
local FOXUC = FOXUltimateCamera
FOXUC.modules = FOXUC.modules or {}

if not FOXUC.modules.contextSpeed then
    FOXUC.modules.contextSpeed = ContextSpeed:New()
end
