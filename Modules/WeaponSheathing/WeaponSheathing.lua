-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local EM = EVENT_MANAGER
local WeaponSheathing = {}
WeaponSheathing.__index = WeaponSheathing

local GetTimeMs = FOXUC_Utils.GetTimeMs
local IsInPvpArea = FOXUC_Utils.IsInPvpArea



function WeaponSheathing:New()
    local instance = setmetatable({}, WeaponSheathing)
    instance.addon = nil
    instance.inCombat = false
    instance.lastCombatEndMs = 0
    instance.pendingSheathToken = 0
    instance.initialized = false
    return instance
end

function WeaponSheathing:IsEnabled()
    if not self.addon or not self.addon.savedVars then
        return false
    end
    return self.addon.savedVars.autoSheathEnabled and true or false
end

function WeaponSheathing:ScheduleSheath()
    local addon = self.addon
    if not addon or not addon.savedVars then
        return
    end

    if not addon.savedVars.autoSheathEnabled then
        return
    end

    if self.inCombat then
        return
    end

    if IsUnitDead("player") then
        return
    end

    if addon.savedVars.autoSheathIgnorePvp ~= false and IsInPvpArea() then
        return
    end

    local delaySec = addon.savedVars.autoSheathDelay or 2
    if type(delaySec) ~= "number" or delaySec < 0 then
        delaySec = 0
    end

    local chainTimeoutSec = addon.savedVars.firstPersonAutoCombatChainTimeout or 0
    if type(chainTimeoutSec) ~= "number" or chainTimeoutSec < 0 then
        chainTimeoutSec = 0
    end

    -- Effective delay: wait at least longer than the combat chain window
    -- so we do not sheath the weapon between closely chained combat waves.
    local effectiveDelaySec = delaySec
    if chainTimeoutSec > effectiveDelaySec then
        effectiveDelaySec = chainTimeoutSec
    end

    local delayMs = math.floor(effectiveDelaySec * 1000)

    self.pendingSheathToken = (self.pendingSheathToken or 0) + 1
    local token = self.pendingSheathToken
    local scheduledCombatEndMs = self.lastCombatEndMs

    zo_callLater(function()
        if token ~= self.pendingSheathToken then
            return
        end

        local nowMs = GetTimeMs()

        -- If a new combat started during the delay, or the last combat end time changed,
        -- cancel the scheduled weapon sheathing.
        if self.inCombat then
            return
        end

        if IsUnitDead("player") then
            return
        end

        if not self.lastCombatEndMs or self.lastCombatEndMs == 0 then
            return
        end

        if self.lastCombatEndMs ~= scheduledCombatEndMs then
            return
        end

        -- Extra safety check for the combat chain window: if we are still inside it, do not sheath.
        if chainTimeoutSec > 0 then
            local elapsed = nowMs - self.lastCombatEndMs
            local chainTimeoutMs = math.floor(chainTimeoutSec * 1000)
            if elapsed >= 0 and elapsed < chainTimeoutMs then
                return
            end
        end

        if not self:IsEnabled() then
            return
        end

        if type(IsPlayerWeaponSheathed) == "function" and type(TogglePlayerWield) == "function" then
            if not IsPlayerWeaponSheathed() then
                TogglePlayerWield()
            end
        elseif type(TogglePlayerWield) == "function" then
            -- Fallback: if we cannot check the state, just toggle
            TogglePlayerWield()
        end
    end, delayMs)
end

function WeaponSheathing:OnCombatState(inCombat)
    local nowMs = GetTimeMs()
    self.inCombat = inCombat and true or false

    if self.inCombat then
        -- Cancel any pending sheathing when combat starts again
        self.pendingSheathToken = (self.pendingSheathToken or 0) + 1
    else
        self.lastCombatEndMs = nowMs
        self:ScheduleSheath()
    end
end

function WeaponSheathing:RegisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:RegisterForEvent(name .. "_WeaponSheath_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatState(inCombat)
    end)
end

function WeaponSheathing:UnregisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:UnregisterForEvent(name .. "_WeaponSheath_Combat", EVENT_PLAYER_COMBAT_STATE)
end

function WeaponSheathing:OnPlayEmote()
    if not self.addon or not self.addon.savedVars then
        return
    end

    if not self.addon.savedVars.autoSheathOnEmote then
        return
    end

    -- Do not sheath weapon if we are in combat (safety)
    if self.inCombat then
        return
    end

    -- Also check PvP if ignore is enabled
    if self.addon.savedVars.autoSheathIgnorePvp ~= false and IsInPvpArea() then
        return
    end

    if type(IsPlayerWeaponSheathed) == "function" and type(TogglePlayerWield) == "function" then
        if not IsPlayerWeaponSheathed() then
            TogglePlayerWield()
        end
    elseif type(TogglePlayerWield) == "function" then
        TogglePlayerWield()
    end
end

function WeaponSheathing:Initialize(addon)
    if self.initialized then
        return
    end

    self.addon = addon
    self.inCombat = (IsUnitInCombat and IsUnitInCombat("player")) or false
    self.lastCombatEndMs = 0
    self.pendingSheathToken = 0
    self.initialized = true

    self:RegisterEvents()

    -- Hook PlayEmote to catch emote actions from the UI
    if not self.hookedPlayEmote then
        SecurePostHook("PlayEmote", function()
            self:OnPlayEmote()
        end)
        self.hookedPlayEmote = true
    end
end

function WeaponSheathing:Shutdown()
    if not self.initialized then
        return
    end

    self:UnregisterEvents()
    self.initialized = false
    self.addon = nil
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.weaponSheathing then
    FOXUC.modules.weaponSheathing = WeaponSheathing:New()
end
