-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local FOXUC = FOXUltimateCamera
local modules = FOXUC.modules

local EM = EVENT_MANAGER

local InteractionGuard = {}
InteractionGuard.__index = InteractionGuard

function InteractionGuard:New()
    local instance = setmetatable({}, InteractionGuard)
    instance.addon = nil
    instance.initialized = false
    instance.interactionActive = false
    instance.interactionType = nil
    return instance
end

function InteractionGuard:IsEnabled()
    local addon = self.addon
    if not addon or not addon.savedVars then
        return false
    end
    return addon.savedVars.immersionBlockAutoCamera ~= false
end

function InteractionGuard:IsInteractionActive()
    return self.interactionActive and true or false
end

function InteractionGuard:ShouldBlockAutoCamera()
    if not self:IsEnabled() then
        return false
    end
    return self:IsInteractionActive()
end

function InteractionGuard:OnBeginInteraction()
    local interactionType = nil
    if GetInteractionType then
        interactionType = GetInteractionType()
    end

    self.interactionActive = true
    self.interactionType = interactionType
end

function InteractionGuard:OnEndInteraction()
    self.interactionActive = false
    self.interactionType = nil
end

function InteractionGuard:RegisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:RegisterForEvent(name .. "_Interaction_Begin", EVENT_BEGIN_INTERACTION, function()
        self:OnBeginInteraction()
    end)

    EM:RegisterForEvent(name .. "_Interaction_End", EVENT_END_INTERACTION, function()
        self:OnEndInteraction()
    end)

    if EVENT_PLAYER_DEACTIVATED ~= nil then
        EM:RegisterForEvent(name .. "_Interaction_PlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function()
            self:OnEndInteraction()
        end)
    end

    EM:RegisterForEvent(name .. "_Interaction_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        self:OnEndInteraction()
    end)
end

function InteractionGuard:UnregisterEvents()
    local name = self.addon and self.addon.name or "FOXUltimateCamera"

    EM:UnregisterForEvent(name .. "_Interaction_Begin", EVENT_BEGIN_INTERACTION)
    EM:UnregisterForEvent(name .. "_Interaction_End", EVENT_END_INTERACTION)

    if EVENT_PLAYER_DEACTIVATED ~= nil then
        EM:UnregisterForEvent(name .. "_Interaction_PlayerDeactivated", EVENT_PLAYER_DEACTIVATED)
    end

    EM:UnregisterForEvent(name .. "_Interaction_PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

function InteractionGuard:Initialize(addon)
    if self.initialized then
        return
    end

    self.addon = addon
    self.interactionActive = false
    self.interactionType = nil

    self:RegisterEvents()
    self.initialized = true
end

function InteractionGuard:Shutdown()
    if not self.initialized then
        return
    end

    self:UnregisterEvents()
    self.interactionActive = false
    self.interactionType = nil
    self.addon = nil
    self.initialized = false
end

if not modules.InteractionGuard then
    modules.InteractionGuard = InteractionGuard:New()
end
