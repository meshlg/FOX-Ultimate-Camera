-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local FOXUC = FOXUltimateCamera
local modules = FOXUC.modules

local EM = EVENT_MANAGER

local CAMERA_TYPE = SETTING_TYPE_CAMERA
local CAMERA_SETTING_FIRST_PERSON_FOV_ID = 7
local CAMERA_SETTING_THIRD_PERSON_FOV_ID = 12

-- Game stores FOV in range [35, 65], UI shows [70, 130]
local GAME_FOV_MIN = 35
local GAME_FOV_MAX = 65
local UI_FOV_MIN = 70
local UI_FOV_MAX = 130

local FOV_SMOOTHING_EPSILON = 0.01

local function ClampGameFov(value)
    if type(value) ~= "number" then
        return nil
    end
    if value < GAME_FOV_MIN then
        return GAME_FOV_MIN
    end
    if value > GAME_FOV_MAX then
        return GAME_FOV_MAX
    end
    return value
end

local function UiToGameFov(uiValue)
    if type(uiValue) ~= "number" then
        return nil
    end
    -- UI is simply game value * 2 (35-65 -> 70-130)
    local gameValue = uiValue / 2
    return ClampGameFov(gameValue)
end

local function GameToUiFov(gameValue)
    if type(gameValue) ~= "number" then
        return UI_FOV_MIN
    end
    local clamped = ClampGameFov(gameValue)
    return clamped * 2
end

local FovController = {}
FovController.__index = FovController

function FovController:New()
    local instance = setmetatable({}, FovController)
    instance.addon = nil
    instance.initialized = false
    instance._targetFirst = nil
    instance._targetThird = nil
    instance._smoothingActive = false
    return instance
end

local function UpdateSmoothingCallback()
    local controller = modules.FovController
    if controller and controller.UpdateSmoothing then
        controller:UpdateSmoothing()
    end
end

local function ReadGameFov(settingId)
    local value = GetSetting(CAMERA_TYPE, settingId)
    local numberValue = tonumber(value)
    return ClampGameFov(numberValue)
end

local function WriteGameFov(settingId, gameValue)
    local clamped = ClampGameFov(gameValue)
    if not clamped then
        return
    end
    SetSetting(CAMERA_TYPE, settingId, string.format("%.4f", clamped))
end

function FovController:GetFirstPersonFovGame()
    return ReadGameFov(CAMERA_SETTING_FIRST_PERSON_FOV_ID)
end

function FovController:GetThirdPersonFovGame()
    return ReadGameFov(CAMERA_SETTING_THIRD_PERSON_FOV_ID)
end

function FovController:GetFirstPersonFovUi()
    local gameValue = self:GetFirstPersonFovGame()
    return GameToUiFov(gameValue)
end

function FovController:GetThirdPersonFovUi()
    local gameValue = self:GetThirdPersonFovGame()
    return GameToUiFov(gameValue)
end

function FovController:SetFirstPersonFovUi(uiValue)
    if not self.addon or not self.addon.savedVars then
        return
    end

    local gameValue = UiToGameFov(uiValue)
    if not gameValue then
        return
    end

    self:SetFirstPersonFovGame(gameValue)
end

function FovController:SetThirdPersonFovUi(uiValue)
    if not self.addon or not self.addon.savedVars then
        return
    end

    local gameValue = UiToGameFov(uiValue)
    if not gameValue then
        return
    end

    self:SetThirdPersonFovGame(gameValue)
end

function FovController:SetFirstPersonFovGame(gameValue, options)
    if not self.addon or not self.addon.savedVars then
        return
    end

    local clamped = ClampGameFov(gameValue)
    if not clamped then
        return
    end

    local useSmoothing = not (self.addon and self.addon.savedVars and self.addon.savedVars.fovSmoothingEnabled == false)

    if d and self.addon and self.addon.IsDebugEnabled and self.addon:IsDebugEnabled() then
        d(string.format("[FOXUC:Fov] SetFirstPersonFovGame value=%.2f skipSave=%s useSmoothing=%s", clamped, tostring(options and options.skipSave), tostring(useSmoothing)))
    end

    if useSmoothing then
        self._targetFirst = clamped
        if not self._smoothingActive then
            self._smoothingActive = true
            EM:UnregisterForUpdate("FOXUC_FovSmoothing")
            EM:RegisterForUpdate("FOXUC_FovSmoothing", 0, UpdateSmoothingCallback)
        end
    else
        WriteGameFov(CAMERA_SETTING_FIRST_PERSON_FOV_ID, clamped)
    end

    -- Only persist to savedVars if not a temporary context change
    local skipSave = options and options.skipSave
    if not skipSave and self.addon and self.addon.savedVars then
        self.addon.savedVars.fovFirstPerson = clamped

        -- Notify FovContext that base FOV changed (for proper restore when leaving context)
        if self.addon.modules and self.addon.modules.FovContext then
            local fovContext = self.addon.modules.FovContext
            if fovContext.OnBaseFovChanged then
                fovContext:OnBaseFovChanged(clamped, nil)
            end
        end
    end
end

function FovController:SetThirdPersonFovGame(gameValue, options)
    if not self.addon or not self.addon.savedVars then
        return
    end

    local clamped = ClampGameFov(gameValue)
    if not clamped then
        return
    end

    local useSmoothing = not (self.addon and self.addon.savedVars and self.addon.savedVars.fovSmoothingEnabled == false)

    if useSmoothing then
        self._targetThird = clamped
        if not self._smoothingActive then
            self._smoothingActive = true
            EM:UnregisterForUpdate("FOXUC_FovSmoothing")
            EM:RegisterForUpdate("FOXUC_FovSmoothing", 0, UpdateSmoothingCallback)
        end
    else
        WriteGameFov(CAMERA_SETTING_THIRD_PERSON_FOV_ID, clamped)
    end

    -- Only persist to savedVars if not a temporary context change
    local skipSave = options and options.skipSave
    if not skipSave and self.addon and self.addon.savedVars then
        self.addon.savedVars.fovThirdPerson = clamped

        -- Notify FovContext that base FOV changed (for proper restore when leaving context)
        if self.addon.modules and self.addon.modules.FovContext then
            local fovContext = self.addon.modules.FovContext
            if fovContext.OnBaseFovChanged then
                fovContext:OnBaseFovChanged(nil, clamped)
            end
        end
    end
end

function FovController:UpdateSmoothing()
    if not self._smoothingActive then
        return
    end

    local addon = self.addon
    if not addon or not addon.savedVars then
        self._smoothingActive = false
        EM:UnregisterForUpdate("FOXUC_FovSmoothing")
        return
    end

    local speed = addon.savedVars.fovSmoothingSpeed or (addon.GetDefault and addon:GetDefault("fovSmoothingSpeed")) or 10
    local dt = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0.016
    local factor = math.min(speed * dt, 1.0)

    local anyTarget = false

    if self._targetFirst then
        local current = self:GetFirstPersonFovGame()
        if current then
            local diff = self._targetFirst - current
            if math.abs(diff) <= FOV_SMOOTHING_EPSILON or factor >= 1.0 then
                current = self._targetFirst
                self._targetFirst = nil
            else
                current = current + diff * factor
            end
            WriteGameFov(CAMERA_SETTING_FIRST_PERSON_FOV_ID, current)
        end
    end

    if self._targetThird then
        local current = self:GetThirdPersonFovGame()
        if current then
            local diff = self._targetThird - current
            if math.abs(diff) <= FOV_SMOOTHING_EPSILON or factor >= 1.0 then
                current = self._targetThird
                self._targetThird = nil
            else
                current = current + diff * factor
            end
            WriteGameFov(CAMERA_SETTING_THIRD_PERSON_FOV_ID, current)
        end
    end

    if self._targetFirst or self._targetThird then
        anyTarget = true
    end

    if not anyTarget then
        if d and addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
            d("[FOXUC:Fov] Smoothing finished")
        end
        self._smoothingActive = false
        EM:UnregisterForUpdate("FOXUC_FovSmoothing")
    end
end

function FovController:RestoreOriginalFov()
    if not self.addon or not self.addon.savedVars then
        return
    end

    local originalFirst = self.addon.savedVars.originalFovFirstPerson
    local originalThird = self.addon.savedVars.originalFovThirdPerson

    if type(originalFirst) == "number" then
        WriteGameFov(CAMERA_SETTING_FIRST_PERSON_FOV_ID, originalFirst)
    end

    if type(originalThird) == "number" then
        WriteGameFov(CAMERA_SETTING_THIRD_PERSON_FOV_ID, originalThird)
    end
end

function FovController:Initialize(addon)
    if self.initialized then
        return
    end

    self.addon = addon

    if not addon or not addon.savedVars then
        return
    end

    -- Save original FOV values once
    if addon.savedVars.originalFovFirstPerson == nil then
        local currentFirst = self:GetFirstPersonFovGame()
        if currentFirst ~= nil then
            addon.savedVars.originalFovFirstPerson = currentFirst
        end
    end

    if addon.savedVars.originalFovThirdPerson == nil then
        local currentThird = self:GetThirdPersonFovGame()
        if currentThird ~= nil then
            addon.savedVars.originalFovThirdPerson = currentThird
        end
    end

    self.initialized = true
end

function FovController:Shutdown()
    if not self.initialized then
        return
    end

    self._smoothingActive = false
    EM:UnregisterForUpdate("FOXUC_FovSmoothing")
    self._targetFirst = nil
    self._targetThird = nil

    self.initialized = false
end

if not modules.FovController then
    modules.FovController = FovController:New()
end
