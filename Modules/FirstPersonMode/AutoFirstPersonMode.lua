-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local EM = EVENT_MANAGER
local AutoFirstPersonMode = {}
AutoFirstPersonMode.__index = AutoFirstPersonMode

local GetTimeMs = FOXUC_Utils.GetTimeMs
local IsInPvpArea = FOXUC_Utils.IsInPvpArea
local IsInRelevantInterior = FOXUC_Utils.IsInRelevantInterior



function AutoFirstPersonMode:New()
    local instance = setmetatable({}, AutoFirstPersonMode)
    instance.addon = nil
    instance.inCombat = false
    instance.isMounted = false
    instance.isInterior = false
    instance.pendingChangeToken = 0
    instance.currentApplied = nil
    instance.manualOverrideUntilMs = 0
    instance.enabled = false
    instance.lastCombatEndMs = 0
    return instance
end

function AutoFirstPersonMode:IsMasterEnabled()
    if not self.addon or not self.addon.savedVars then
        return false
    end
    return self.addon.savedVars.firstPersonAutoEnabled and true or false
end

function AutoFirstPersonMode:IsManualOverrideActive(nowMs)
    local addon = self.addon
    if not addon or not addon.savedVars then
        return false
    end
    if not addon.savedVars.firstPersonAutoRespectManual then
        return false
    end
    return nowMs < (self.manualOverrideUntilMs or 0)
end

function AutoFirstPersonMode:ComputeTargetActive(nowMs)
    local addon = self.addon
    if not addon or not addon.savedVars then
        return nil
    end

    if addon.modules and addon.modules.InteractionGuard then
        local guard = addon.modules.InteractionGuard
        if guard.ShouldBlockAutoCamera and guard:ShouldBlockAutoCamera() then
            return nil
        end
    end

    if not self:IsMasterEnabled() then
        return nil
    end

    if addon.savedVars.firstPersonAutoIgnorePvp and IsInPvpArea() then
        return false
    end

    if self:IsManualOverrideActive(nowMs) then
        return nil
    end

    local mountActive = addon.savedVars.firstPersonAutoMount and self.isMounted

    local combatActive = false
    if addon.savedVars.firstPersonAutoCombat then
        if self.inCombat then
            combatActive = true
        else
            local timeoutSec = addon.savedVars.firstPersonAutoCombatChainTimeout or 0
            if timeoutSec > 0 and self.lastCombatEndMs and self.lastCombatEndMs > 0 then
                local timeoutMs = math.floor(timeoutSec * 1000)
                local elapsed = nowMs - self.lastCombatEndMs
                if elapsed >= 0 and elapsed < timeoutMs then
                    combatActive = true
                end
            end
        end
    end
    local interiorActive = addon.savedVars.firstPersonAutoInteriors and self.isInterior

    if mountActive then
        return true
    end
    if combatActive then
        return true
    end
    if interiorActive then
        return true
    end

    return false
end

function AutoFirstPersonMode:ApplyNowIfValid(expectedTarget, token, reason)
    if not self.addon then
        return
    end

    if token ~= self.pendingChangeToken then
        return
    end

    local nowMs = GetTimeMs()
    local recomputed = self:ComputeTargetActive(nowMs)
    if recomputed ~= expectedTarget then
        return
    end

    if recomputed == nil then
        return
    end

    if type(self.addon.ApplyFirstPersonAutoState) == "function" then
        self.addon:ApplyFirstPersonAutoState(recomputed and true or false, reason)
        self.currentApplied = recomputed and true or false
    end
end

function AutoFirstPersonMode:Evaluate(reason)
    if not self.addon then
        return
    end

    local nowMs = GetTimeMs()
    local target = self:ComputeTargetActive(nowMs)
    if target == nil then
        self.pendingChangeToken = self.pendingChangeToken + 1
        return
    end

    if self.currentApplied ~= nil and self.currentApplied == target then
        return
    end

    local addon = self.addon
    local delaySec
    if target then
        delaySec = addon.savedVars.firstPersonAutoEnterDelay or 0
    else
        delaySec = addon.savedVars.firstPersonAutoExitDelay or 0
    end

    local delayMs = 0
    if type(delaySec) == "number" and delaySec > 0 then
        delayMs = math.floor(delaySec * 1000)
    end

    self.pendingChangeToken = self.pendingChangeToken + 1
    local token = self.pendingChangeToken

    if delayMs <= 0 then
        self:ApplyNowIfValid(target, token, reason)
    else
        zo_callLater(function()
            self:ApplyNowIfValid(target, token, reason)
        end, delayMs)
    end
end

function AutoFirstPersonMode:OnCombatState(inCombat)
    local nowMs = GetTimeMs()
    self.inCombat = inCombat and true or false
    if not self.inCombat then
        self.lastCombatEndMs = nowMs
    end
    self:Evaluate("combat")
end

function AutoFirstPersonMode:OnMountedState(isMounted)
    self.isMounted = isMounted and true or false
    self:Evaluate("mount")
end

function AutoFirstPersonMode:OnPlayerContextChanged()
    self.isInterior = IsInRelevantInterior()
    self:Evaluate("zone")
end

function AutoFirstPersonMode:OnManualToggle()
    local addon = self.addon
    if not addon or not addon.savedVars then
        return
    end

    if not addon.savedVars.firstPersonAutoRespectManual then
        return
    end

    local timeoutSec = addon.savedVars.firstPersonAutoManualTimeout or 0
    if timeoutSec <= 0 then
        return
    end

    local nowMs = GetTimeMs()
    self.manualOverrideUntilMs = nowMs + math.floor(timeoutSec * 1000)
end

function AutoFirstPersonMode:RegisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:RegisterForEvent(name .. "_AutoFP_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatState(inCombat)
    end)

    EM:RegisterForEvent(name .. "_AutoFP_Mount", EVENT_MOUNTED_STATE_CHANGED, function(_, isMounted)
        self:OnMountedState(isMounted)
    end)

    EM:RegisterForEvent(name .. "_AutoFP_Activated", EVENT_PLAYER_ACTIVATED, function()
        self:OnPlayerContextChanged()
    end)

    if EVENT_ZONE_CHANGED ~= nil then
        EM:RegisterForEvent(name .. "_AutoFP_ZoneChanged", EVENT_ZONE_CHANGED, function()
            self:OnPlayerContextChanged()
        end)
    end
end

function AutoFirstPersonMode:UnregisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:UnregisterForEvent(name .. "_AutoFP_Combat", EVENT_PLAYER_COMBAT_STATE)
    EM:UnregisterForEvent(name .. "_AutoFP_Mount", EVENT_MOUNTED_STATE_CHANGED)
    EM:UnregisterForEvent(name .. "_AutoFP_Activated", EVENT_PLAYER_ACTIVATED)

    if EVENT_ZONE_CHANGED ~= nil then
        EM:UnregisterForEvent(name .. "_AutoFP_ZoneChanged", EVENT_ZONE_CHANGED)
    end
end

function AutoFirstPersonMode:Initialize(addon)
    if self.initialized then
        return
    end

    self.addon = addon
    self.inCombat = false
    self.isMounted = IsMounted and IsMounted() or false
    self.isInterior = IsInRelevantInterior()
    self.manualOverrideUntilMs = 0
    self.currentApplied = nil
    self.pendingChangeToken = 0
    self.lastCombatEndMs = 0
    self.initialized = true

    self:RegisterEvents()
    self:Evaluate("startup")
end

function AutoFirstPersonMode:Shutdown()
    if not self.initialized then
        return
    end

    self:UnregisterEvents()
    self.initialized = false
    self.addon = nil
end

local FOXUC = FOXUltimateCamera

if not FOXUC.modules.autoFirstPerson then
    FOXUC.modules.autoFirstPerson = AutoFirstPersonMode:New()
end
