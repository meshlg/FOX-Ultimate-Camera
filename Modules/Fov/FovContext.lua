-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local FOXUC = FOXUltimateCamera
local modules = FOXUC.modules

local EM = EVENT_MANAGER

local FovContext = {}
FovContext.__index = FovContext

local IsInPvpArea = FOXUC_Utils.IsInPvpArea
local IsInRelevantInterior = FOXUC_Utils.IsInRelevantInterior
local IsPlayerInCombat = FOXUC_Utils.IsPlayerInCombat
local IsPlayerMounted = FOXUC_Utils.IsPlayerMounted

function FovContext:New()
    local instance = setmetatable({}, FovContext)
    instance.addon = nil
    instance.initialized = false
    instance.inCombat = false
    instance.isMounted = false
    instance.isInterior = false
    instance.currentContext = nil -- "mounted" | "combat" | "interior" | nil
    instance.baseFovFirst = nil
    instance.baseFovThird = nil
    return instance
end

local function GetFovModule(addon)
    if not addon or not addon.modules then
        return nil
    end
    return addon.modules.FovController
end

local function GetContextState(self)
    local addon = self.addon
    if not addon or not addon.savedVars then
        return nil
    end

    if addon.savedVars.contextFovIgnorePvp and IsInPvpArea() then
        return nil
    end

    -- Use cached state flags updated by event handlers instead of querying
    -- the API directly, because IsMounted()/IsUnitInCombat() may lag behind
    -- EVENT_* state changes by a few frames.
    local mounted = self.isMounted and true or false
    local combat = self.inCombat and true or false
    local interior = self.isInterior and true or false

    if mounted then
        return "mounted"
    end
    if combat then
        return "combat"
    end
    if interior then
        return "interior"
    end

    return nil
end

local function ApplyContextFov(self, context)
    local addon = self.addon
    if not addon or not addon.savedVars then
        return
    end

    local fovModule = GetFovModule(addon)
    if not fovModule or not fovModule.SetFirstPersonFovGame or not fovModule.SetThirdPersonFovGame then
        return
    end

    local sv = addon.savedVars

    -- Save base FOV once when entering any context
    -- Always capture live game FOV as base, independent of savedVars
    if not self.currentContext then
        if fovModule.GetFirstPersonFovGame then
            self.baseFovFirst = fovModule:GetFirstPersonFovGame()
        end
        if fovModule.GetThirdPersonFovGame then
            self.baseFovThird = fovModule:GetThirdPersonFovGame()
        end
    end

    local targetFirst
    local targetThird

    if context == "mounted" then
        targetFirst = sv.contextFovMountedFirst
        targetThird = sv.contextFovMountedThird
    elseif context == "combat" then
        targetFirst = sv.contextFovCombatFirst
        targetThird = sv.contextFovCombatThird
    elseif context == "interior" then
        targetFirst = sv.contextFovInteriorFirst
        targetThird = sv.contextFovInteriorThird
    end

    if d and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] Apply context=%s baseFirst=%s baseThird=%s targetFirst=%s targetThird=%s", tostring(context), tostring(self.baseFovFirst), tostring(self.baseFovThird), tostring(targetFirst), tostring(targetThird)))
    end

    local contextOptions = { skipSave = true }

    if type(targetFirst) == "number" then
        fovModule:SetFirstPersonFovGame(targetFirst, contextOptions)
    end

    if type(targetThird) == "number" then
        fovModule:SetThirdPersonFovGame(targetThird, contextOptions)
    end

    self.currentContext = context
end

local function RestoreBaseFov(self)
    local addon = self.addon
    if not addon then
        return
    end

    local fovModule = GetFovModule(addon)
    if not fovModule then
        return
    end

    if d and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] Restore baseFovFirst=%s baseFovThird=%s", tostring(self.baseFovFirst), tostring(self.baseFovThird)))
    end

    local contextOptions = { skipSave = true }

    if type(self.baseFovFirst) == "number" and fovModule.SetFirstPersonFovGame then
        fovModule:SetFirstPersonFovGame(self.baseFovFirst, contextOptions)
    end

    if type(self.baseFovThird) == "number" and fovModule.SetThirdPersonFovGame then
        fovModule:SetThirdPersonFovGame(self.baseFovThird, contextOptions)
    end

    -- Reset base values so next context entry captures fresh user FOV
    self.baseFovFirst = nil
    self.baseFovThird = nil
    self.currentContext = nil
end

function FovContext:Evaluate(reason)
    local addon = self.addon
    if not addon or not addon.savedVars then
        return
    end

    if d and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] Evaluate reason=%s currentContext=%s", tostring(reason), tostring(self.currentContext)))
    end

    if addon.modules and addon.modules.InteractionGuard then
        local guard = addon.modules.InteractionGuard
        if guard.ShouldBlockAutoCamera and guard:ShouldBlockAutoCamera() then
            if self.currentContext ~= nil then
                RestoreBaseFov(self)
            end
            return
        end
    end

    if not addon.savedVars.contextFovEnabled then
        if self.currentContext ~= nil then
            RestoreBaseFov(self)
        end
        return
    end

    local context = GetContextState(self)

    if d and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] State context=%s currentContext=%s", tostring(context), tostring(self.currentContext)))
    end

    if context == nil then
        if self.currentContext ~= nil then
            RestoreBaseFov(self)
        end
        return
    end

    if context == self.currentContext then
        return
    end

    ApplyContextFov(self, context)
end

function FovContext:OnCombatState(inCombat)
    self.inCombat = inCombat and true or false

    local addon = self.addon
    if d and addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] EVENT_PLAYER_COMBAT_STATE inCombat=%s", tostring(self.inCombat)))
    end

    self:Evaluate("combat")
end

function FovContext:OnMountedState(isMounted)
    self.isMounted = isMounted and true or false

    local addon = self.addon
    if d and addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] EVENT_MOUNTED_STATE_CHANGED isMounted=%s", tostring(self.isMounted)))
    end

    self:Evaluate("mount")
end

function FovContext:OnPlayerContextChanged()
    self.isInterior = IsInRelevantInterior()

    local addon = self.addon
    if d and addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
        d(string.format("[FOXUC:FovCtx] OnPlayerContextChanged isInterior=%s", tostring(self.isInterior)))
    end

    self:Evaluate("zone")
end

function FovContext:RegisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:RegisterForEvent(name .. "_FovCtx_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatState(inCombat)
    end)

    EM:RegisterForEvent(name .. "_FovCtx_Mount", EVENT_MOUNTED_STATE_CHANGED, function(_, isMounted)
        self:OnMountedState(isMounted)
    end)

    EM:RegisterForEvent(name .. "_FovCtx_Activated", EVENT_PLAYER_ACTIVATED, function()
        self:OnPlayerContextChanged()
    end)

    if EVENT_ZONE_CHANGED ~= nil then
        EM:RegisterForEvent(name .. "_FovCtx_ZoneChanged", EVENT_ZONE_CHANGED, function()
            self:OnPlayerContextChanged()
        end)
    end
end

function FovContext:UnregisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:UnregisterForEvent(name .. "_FovCtx_Combat", EVENT_PLAYER_COMBAT_STATE)
    EM:UnregisterForEvent(name .. "_FovCtx_Mount", EVENT_MOUNTED_STATE_CHANGED)
    EM:UnregisterForEvent(name .. "_FovCtx_Activated", EVENT_PLAYER_ACTIVATED)

    if EVENT_ZONE_CHANGED ~= nil then
        EM:UnregisterForEvent(name .. "_FovCtx_ZoneChanged", EVENT_ZONE_CHANGED)
    end
end

function FovContext:Initialize(addon)
    if self.initialized then
        return
    end

    self.addon = addon

    if not addon or not addon.savedVars then
        return
    end

    self.inCombat = IsPlayerInCombat()
    self.isMounted = IsPlayerMounted()
    self.isInterior = IsInRelevantInterior()
    self.currentContext = nil
    self.baseFovFirst = nil
    self.baseFovThird = nil

    self:RegisterEvents()
    self.initialized = true

    self:Evaluate("startup")
end

function FovContext:Shutdown()
    if not self.initialized then
        return
    end

    self:UnregisterEvents()
    if self.currentContext ~= nil then
        RestoreBaseFov(self)
    end

    self.initialized = false
    self.addon = nil
end

-- Called when user changes base FOV through settings UI
-- Updates the stored base values so RestoreBaseFov uses correct values
function FovContext:OnBaseFovChanged(firstPerson, thirdPerson)
    if not self.initialized then
        return
    end

    -- Only update base values if we're in a context (otherwise they will be captured on next context entry)
    if self.currentContext then
        if type(firstPerson) == "number" then
            self.baseFovFirst = firstPerson
        end
        if type(thirdPerson) == "number" then
            self.baseFovThird = thirdPerson
        end
    end
end

if not modules.FovContext then
    modules.FovContext = FovContext:New()
end
