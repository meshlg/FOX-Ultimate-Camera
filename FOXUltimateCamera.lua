-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

FOXUltimateCamera = FOXUltimateCamera or {}
FOXUltimateCamera.modules = FOXUltimateCamera.modules or {}

local ADDON_NAME = "FOXUltimateCamera"
local EM = EVENT_MANAGER
local modules = FOXUltimateCamera.modules

local FOXUC = FOXUltimateCamera
FOXUC.name = ADDON_NAME

local addon = FOXUC

-- Camera thresholds and increment (in game units)
local THIRD_PERSON_FLOOR = 2 -- Game minimum third-person distance
local FIRST_PERSON_BOUNDARY = 0 -- Absolute first-person distance
local FIRST_PERSON_SNAP_THRESHOLD = 0.5 -- Values at/below this distance snap to first-person
local THIRD_PERSON_FALLBACK_DISTANCE = 3.5 -- Distance to use when leaving first-person without a stored zoom
local DEFAULT_MAX_ZOOM_DISTANCE = 10 -- Game default maximum zoom distance
local MAX_ZOOM_DISTANCE_MIN = 2 -- Game minimum maximum zoom distance
local MAX_ZOOM_DISTANCE_MAX = 10 -- Game maximum maximum zoom distance
local DEFAULT_ZOOM_STEP = 0.225 -- Default zoom step
local MIN_ZOOM_STEP = 0.025 -- Minimum zoom step
local MAX_ZOOM_STEP = 1 -- Maximum zoom step

local DEFAULT_ZOOM_SPEED = 1.5 -- Default zoom speed multiplier
local MIN_ZOOM_SPEED = 0.5 -- Minimum zoom speed multiplier
local MAX_ZOOM_SPEED = 2.0 -- Maximum zoom speed multiplier
local FIRST_PERSON_EPSILON = 1e-4 -- First-person epsilon

-- Settings
local CAMERA_TYPE = SETTING_TYPE_CAMERA
local CAMERA_DISTANCE = CAMERA_SETTING_DISTANCE
local SKIP_FREE_DIALOG_INTERACTION = {}

-- Definition list for immersive interaction exceptions (per INTERACTION_* constant)
local IMMERSION_INTERACTION_DEFS = {
    -- Crafting & equipment services
    { constName = "INTERACTION_CRAFT",              labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_CRAFT" },
    { constName = "INTERACTION_DYE_STATION",        labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_DYE_STATION" },
    { constName = "INTERACTION_RETRAIT",            labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_RETRAIT" },
    { constName = "INTERACTION_ARMORY",             labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_ARMORY" },
    { constName = "INTERACTION_ATTRIBUTE_RESPEC",   labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_ATTRIBUTE_RESPEC" },

    -- Locks, siege, furniture
    { constName = "INTERACTION_LOCKPICK",           labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_LOCKPICK" },
    { constName = "INTERACTION_SIEGE",              labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_SIEGE" },
    { constName = "INTERACTION_FURNITURE",          labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_FURNITURE" },

    -- Banking & trading
    { constName = "INTERACTION_BANK",               labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_BANK" },
    { constName = "INTERACTION_GUILD_BANK",         labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_GUILD_BANK" },
    { constName = "INTERACTION_HOUSE_BANK",         labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_HOUSE_BANK" },
    { constName = "INTERACTION_STORE",              labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_STORE" },
    { constName = "INTERACTION_TRADING_HOUSE",      labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_TRADING_HOUSE" },
    { constName = "INTERACTION_FENCE",              labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_FENCE" },
    { constName = "INTERACTION_HOUSE_STORE",        labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_HOUSE_STORE" },

    -- Travel / keeps / hooks
    { constName = "INTERACTION_AVA_HOOK_POINT",     labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_AVA_HOOK_POINT" },
    { constName = "INTERACTION_WAYSHRINE",          labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_WAYSHRINE" },
    { constName = "INTERACTION_KEEP_GUILD_CLAIM",   labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_KEEP_GUILD_CLAIM" },
    { constName = "INTERACTION_KEEP_GUILD_RELEASE", labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_KEEP_GUILD_RELEASE" },

    -- Companions / stable / mail / misc services
    { constName = "INTERACTION_STABLE",             labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_STABLE" },
    { constName = "INTERACTION_MAIL",               labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_MAIL" },
    { constName = "INTERACTION_ANTIQUITY_DIG_SPOT", labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_ANTIQUITY_DIG_SPOT" },
    { constName = "INTERACTION_ANTIQUITY_SCRYING",  labelStringId = "SI_FOXUC_IMMERSION_INTERACTION_ANTIQUITY_SCRYING" },
}

local function RebuildSkipFreeDialogInteraction(addonInstance)
    -- Clear current mapping
    for key in pairs(SKIP_FREE_DIALOG_INTERACTION) do
        SKIP_FREE_DIALOG_INTERACTION[key] = nil
    end

    local savedVars = addonInstance and addonInstance.savedVars
    local flags = savedVars and savedVars.immersionSkipInteractionsByName

    for _, def in ipairs(IMMERSION_INTERACTION_DEFS) do
        local name = def.constName
        local enabled = true -- Enabled by default when no explicit flag is present
        if flags and flags[name] ~= nil then
            enabled = flags[name] and true or false
        end

        if enabled then
            local id = _G[name]
            if type(id) == "number" then
                SKIP_FREE_DIALOG_INTERACTION[id] = true
            end
        end
    end
end

local defaults = {
    storedDistance = nil, -- The last observed camera distance
    debugEnabled = false, -- Whether debug mode is enabled
    useControlledToggleZoom = false, -- Whether to use controlled toggle zoom
    maxZoomDistance = DEFAULT_MAX_ZOOM_DISTANCE, -- The maximum zoom distance
    zoomStep = DEFAULT_ZOOM_STEP, -- The zoom step
    zoomSmoothingEnabled = false, -- Whether zoom smoothing is enabled
    zoomSpeed = DEFAULT_ZOOM_SPEED, -- The zoom speed
    fovSmoothingEnabled = true, -- Whether FOV smoothing is enabled
    fovSmoothingSpeed = 10, -- FOV smoothing speed factor
    immersionBlockAutoCamera = true, -- Whether to pause auto camera during interactions
    -- Per-interaction flags for immersive dialog camera exceptions.
    -- Keys are INTERACTION_* constant names; true/nil = keep default camera (skip Free Dialog), false = use Free Dialog.
    immersionSkipInteractionsByName = nil,
    contextSpeedSeparateInOut = false, -- Whether context speed has separate in/out values
    -- Context speeds
    contextSpeedCombatIn = 1.0, -- Context speed in combat (zooming in)
    contextSpeedCombatOut = 1.25, -- Context speed in combat (zooming out)
    contextSpeedStealthIn = 1.0, -- Context speed in stealth (zooming in)
    contextSpeedStealthOut = 1.5, -- Context speed in stealth (zooming out)
    contextSpeedMountedIn = 1.0, -- Context speed while mounted (zooming in)
    contextSpeedMountedOut = 1.4, -- Context speed while mounted (zooming out)
    -- Context sensitivity
    contextSensitivityEnabled = false, -- Whether context sensitivity is enabled
    contextSensitivityCombat = 1.0, -- Context sensitivity in combat
    contextSensitivityMounted = 1.0, -- Context sensitivity while mounted
    contextSensitivitySprint = 1.0, -- Context sensitivity while sprinting
    -- Contextual FOV
    contextFovEnabled = false, -- Whether contextual FOV changes are enabled
    contextFovIgnorePvp = true, -- Do not change FOV in PvP areas
    contextFovCombatFirst = nil, -- Target first-person FOV in combat (game units, 35-65)
    contextFovCombatThird = nil, -- Target third-person FOV in combat (game units, 35-65)
    contextFovMountedFirst = nil, -- Target first-person FOV while mounted
    contextFovMountedThird = nil, -- Target third-person FOV while mounted
    contextFovInteriorFirst = nil, -- Target first-person FOV in interiors (houses/dungeons)
    contextFovInteriorThird = nil, -- Target third-person FOV in interiors
    -- Field of View
    fovFirstPerson = nil, -- Preferred first-person FOV (game units, 35-65)
    fovThirdPerson = nil, -- Preferred third-person FOV (game units, 35-65)
    originalFovFirstPerson = nil, -- Original first-person FOV (saved on first run)
    originalFovThirdPerson = nil, -- Original third-person FOV (saved on first run)
    -- Camera Offset
    originalCameraX = nil, -- Original camera X offset (saved on first run)
    originalCameraY = nil, -- Original camera Y offset (saved on first run)
    originalCameraDistance = nil, -- Original camera distance (saved on first run)
    offsetSmoothingEnabled = true, -- Whether camera offset smoothing is enabled
    offsetSmoothingSpeed = 10, -- Speed of offset smoothing interpolation
    cameraOffsetIndicatorEnabled = true, -- Whether to show the camera offset indicator
    cameraOffsetIndicatorDelay = 3, -- Delay before hiding the indicator (in seconds)
    cameraPresetSlot1 = nil, -- Camera preset slot 1 {x, y, zoom}
    cameraPresetSlot2 = nil, -- Camera preset slot 2 {x, y, zoom}
    cameraPresetSlot3 = nil, -- Camera preset slot 3 {x, y, zoom}
    -- Shoulder Swap
    shoulderSwapSmartMode = true, -- Smart mode: mirror current X offset instead of using fixed values
    shoulderSwapLeftValue = -1.0, -- X offset for left shoulder
    shoulderSwapRightValue = 1.0, -- X offset for right shoulder
    -- Auto First-Person mode
    firstPersonAutoEnabled = false, -- Master toggle for automatic first-person mode
    firstPersonAutoInteriors = false, -- Enable auto first-person in houses and dungeons
    firstPersonAutoCombat = false, -- Enable auto first-person while in combat
    firstPersonAutoMount = false, -- Enable auto first-person while mounted
    firstPersonAutoIgnorePvp = true, -- Do not change camera in PvP areas
    firstPersonAutoRespectManual = true, -- Respect manual view toggles for a short time
    firstPersonAutoEnterDelay = 0.5, -- Delay before auto-entering first-person (seconds)
    firstPersonAutoExitDelay = 0.5, -- Delay before auto-leaving first-person (seconds)
    firstPersonAutoManualTimeout = 10, -- Duration after manual toggle to suppress auto mode (seconds)
    firstPersonAutoCombatChainTimeout = 6, -- Minimum time window to treat consecutive combats as one (seconds)
    -- Weapon sheathing
    autoSheathEnabled = false, -- Automatically sheath weapon after combat
    autoSheathIgnorePvp = true, -- Do not sheath weapon in PvP areas
    autoSheathOnEmote = true, -- Automatically sheath weapon when playing an emote
    autoSheathDelay = 2, -- Delay before sheathing weapon after combat (seconds)
}

local function GetCameraLimitsModule()
    return modules.cameraLimits
end

local function GetZoomStepModule()
    return modules.zoomStep
end

local function GetZoomSmoothingModule()
    return modules.zoomSmoothing
end

local function GetZoomSpeedModule()
    return modules.zoomSpeed
end

local function GetContextSpeedModule()
    return modules.contextSpeed
end

local function GetCustomCheckboxModule()
    return modules.customCheckbox
end

local function GetCustomSliderModule()
    return modules.customSlider
end

local function GetContextSensitivityModule()
    return modules.contextSensitivity
end

local function GetCameraOffsetModule()
    return modules.CameraOffset
end

local function GetCameraOffsetIndicatorModule()
    return modules.CameraOffsetIndicator
end

local function GetWeaponSheathingModule()
    return modules.weaponSheathing
end

local function GetFovModule()
    return modules.FovController
end

local function GetFovContextModule()
    return modules.FovContext
end

local function GetInteractionGuardModule()
    return modules.InteractionGuard
end

function addon:IsCustomCheckboxAvailable()
    local module = GetCustomCheckboxModule()
    if module and module.IsAvailable then
        return module:IsAvailable()
    end
    return false
end

function addon:GetCustomCheckboxControlType()
    local module = GetCustomCheckboxModule()
    if module and module.GetControlType then
        return module:GetControlType()
    end
    return "checkbox"
end

function addon:IsCustomSliderAvailable()
    local module = GetCustomSliderModule()
    if module and module.IsAvailable then
        return module:IsAvailable()
    end
    return false
end

function addon:GetCustomSliderControlType()
    local module = GetCustomSliderModule()
    if module and module.GetControlType then
        return module:GetControlType()
    end
    return "slider"
end

local function ClampMaxZoomFallback(value)
    if type(value) ~= "number" then
        return defaults.maxZoomDistance
    end
    if value < MAX_ZOOM_DISTANCE_MIN then
        return MAX_ZOOM_DISTANCE_MIN
    end
    if value > MAX_ZOOM_DISTANCE_MAX then
        return MAX_ZOOM_DISTANCE_MAX
    end
    return value
end

local function ClampZoomSpeedFallback(value)
    if type(value) ~= "number" then
        return DEFAULT_ZOOM_SPEED
    end
    if value < MIN_ZOOM_SPEED then
        return MIN_ZOOM_SPEED
    end
    if value > MAX_ZOOM_SPEED then
        return MAX_ZOOM_SPEED
    end
    return value
end

local function ClampCameraDistanceFallback(distance)
    if type(distance) ~= "number" then
        return nil
    end

    local clamped = distance
    if clamped < FIRST_PERSON_BOUNDARY then
        clamped = FIRST_PERSON_BOUNDARY
    end

    local maxZoom = defaults.maxZoomDistance
    if addon.savedVars and type(addon.savedVars.maxZoomDistance) == "number" then
        maxZoom = ClampMaxZoomFallback(addon.savedVars.maxZoomDistance)
    end

    if clamped > maxZoom then
        clamped = maxZoom
    end

    return clamped
end

local function ClampZoomStepFallback(value)
    if type(value) ~= "number" then
        return DEFAULT_ZOOM_STEP
    end
    if value < MIN_ZOOM_STEP then
        return MIN_ZOOM_STEP
    end
    if value > MAX_ZOOM_STEP then
        return MAX_ZOOM_STEP
    end
    return value
end

local function ClampCameraDistanceValue(distance)
    local clamped = ClampCameraDistanceFallback(distance)
    local limits = GetCameraLimitsModule()
    if limits and limits.ClampDistance then
        clamped = limits:ClampDistance(clamped)
    end
    return clamped
end

local function WriteCameraDistanceImmediate(distance)
    if distance == nil then
        return
    end

    local clamped = ClampCameraDistanceValue(distance)
    if clamped == nil then
        return
    end

    addon._suppressInterfaceSettingChanged = true
    SetSetting(CAMERA_TYPE, CAMERA_DISTANCE, string.format("%.4f", clamped))
    zo_callLater(function()
        addon._suppressInterfaceSettingChanged = false
    end, 0)
end

function addon:_SetCameraDistanceImmediate(distance)
    WriteCameraDistanceImmediate(distance)
end

function addon:_SetCameraDistanceInternal(distance)
    WriteCameraDistanceImmediate(distance)
end

function addon:SetCameraDistance(distance, options)
    local clamped = ClampCameraDistanceValue(distance)
    if clamped == nil then
        return
    end

    local smoothing = GetZoomSmoothingModule()
    if options and options.forceInstant then
        if smoothing and smoothing.Cancel then
            smoothing:Cancel()
        end
        WriteCameraDistanceImmediate(clamped)
        return
    end

    if smoothing and smoothing.Apply then
        smoothing:Apply(clamped, options)
    else
        WriteCameraDistanceImmediate(clamped)
    end
end

local function OnGameCameraDeactivated()
    if not addon:IsImmersiveModeEnabled() then
        return
    end

    if type(GetInteractionType) ~= "function" or type(SetInteractionUsingInteractCamera) ~= "function" then
        return
    end

    local interactionType = GetInteractionType()
    if interactionType == nil or SKIP_FREE_DIALOG_INTERACTION[interactionType] then
        return
    end

    SetInteractionUsingInteractCamera(false)
end

function addon:OnInterfaceSettingChanged(settingType, settingId)
    if settingType ~= CAMERA_TYPE or settingId ~= CAMERA_DISTANCE then
        return
    end

    if self._suppressInterfaceSettingChanged then
        self._suppressInterfaceSettingChanged = false
        return
    end

    local currentValue = tonumber(GetSetting(CAMERA_TYPE, CAMERA_DISTANCE))
    if not currentValue then
        return
    end

    if self._lastObservedDistance ~= nil and math.abs(self._lastObservedDistance - currentValue) <= FIRST_PERSON_EPSILON then
        return
    end

    local clamped = ClampCameraDistanceFallback(currentValue)
    if clamped and math.abs(clamped - currentValue) > FIRST_PERSON_EPSILON then
        self:SetCameraDistance(clamped, { forceInstant = true })
        return
    end

    self._lastObservedDistance = currentValue
    self.lastZoom = currentValue
    UpdateFirstPersonDistance(currentValue)
    self:RememberZoom()

    if not overridesRegistered then
        RegisterOverrides()
    end
end

function addon:GetZoomStepRange()
    local module = GetZoomStepModule()
    if module and module.GetZoomStepRange then
        return module:GetZoomStepRange()
    end
    return MIN_ZOOM_STEP, MAX_ZOOM_STEP, DEFAULT_ZOOM_STEP
end

function addon:GetZoomStep()
    local module = GetZoomStepModule()
    if module and module.GetZoomStep then
        return module:GetZoomStep()
    end
    return ClampZoomStepFallback(self.savedVars and self.savedVars.zoomStep)
end

function addon:SetZoomStep(value)
    local module = GetZoomStepModule()
    if module and module.SetZoomStep then
        module:SetZoomStep(value)
        return
    end

    if not self.savedVars then
        return
    end

    self.savedVars.zoomStep = ClampZoomStepFallback(value)
end

function addon:GetZoomSpeedRange()
    local module = GetZoomSpeedModule()
    if module and module.GetZoomSpeedRange then
        return module:GetZoomSpeedRange()
    end
    return MIN_ZOOM_SPEED, MAX_ZOOM_SPEED, DEFAULT_ZOOM_SPEED
end

function addon:GetZoomSpeed()
    local module = GetZoomSpeedModule()
    if module and module.GetZoomSpeed then
        return module:GetZoomSpeed()
    end
    return ClampZoomSpeedFallback(self.savedVars and self.savedVars.zoomSpeed)
end

function addon:SetZoomSpeed(value)
    local module = GetZoomSpeedModule()
    if module and module.SetZoomSpeed then
        module:SetZoomSpeed(value)
        return
    end

    if not self.savedVars then
        return
    end

    self.savedVars.zoomSpeed = ClampZoomSpeedFallback(value)
end

function addon:GetContextSpeedFactor(direction)
    local module = GetContextSpeedModule()
    if module and module.GetCurrentSpeedFactor then
        local factor = module:GetCurrentSpeedFactor(direction)
        if type(factor) == "number" and factor > 0 then
            return factor
        end
    end
    return 1
end

function addon:GetContextCombatSpeed()
    local module = GetContextSpeedModule()
    if module and module.GetCombatOutMultiplier then
        return module:GetCombatOutMultiplier()
    end
    return 1
end

function addon:SetContextCombatSpeed(value)
    local module = GetContextSpeedModule()
    if module and module.SetCombatMultiplier then
        module:SetCombatMultiplier(value)
    end
end

function addon:SetContextCombatSpeedOut(value)
    local module = GetContextSpeedModule()
    if module and module.SetCombatOutMultiplier then
        module:SetCombatOutMultiplier(value)
    end
end

function addon:GetContextStealthSpeed()
    local module = GetContextSpeedModule()
    if module and module.GetStealthOutMultiplier then
        return module:GetStealthOutMultiplier()
    end
    return 1
end

function addon:SetContextStealthSpeed(value)
    local module = GetContextSpeedModule()
    if module and module.SetStealthMultiplier then
        module:SetStealthMultiplier(value)
    end
end

function addon:SetContextStealthSpeedOut(value)
    local module = GetContextSpeedModule()
    if module and module.SetStealthOutMultiplier then
        module:SetStealthOutMultiplier(value)
    end
end

function addon:GetContextMountedSpeed()
    local module = GetContextSpeedModule()
    if module and module.GetMountedOutMultiplier then
        return module:GetMountedOutMultiplier()
    end
    return 1
end

function addon:SetContextMountedSpeed(value)
    local module = GetContextSpeedModule()
    if module and module.SetMountedMultiplier then
        module:SetMountedMultiplier(value)
    end
end

function addon:SetContextMountedSpeedOut(value)
    local module = GetContextSpeedModule()
    if module and module.SetMountedOutMultiplier then
        module:SetMountedOutMultiplier(value)
    end
end

function addon:GetContextCombatSpeedIn()
    local module = GetContextSpeedModule()
    if module and module.GetCombatInMultiplier then
        return module:GetCombatInMultiplier()
    end
    return 1
end

function addon:SetContextCombatSpeedIn(value)
    local module = GetContextSpeedModule()
    if module and module.SetCombatInMultiplier then
        module:SetCombatInMultiplier(value)
    end
end

function addon:GetContextStealthSpeedIn()
    local module = GetContextSpeedModule()
    if module and module.GetStealthInMultiplier then
        return module:GetStealthInMultiplier()
    end
    return 1
end

function addon:SetContextStealthSpeedIn(value)
    local module = GetContextSpeedModule()
    if module and module.SetStealthInMultiplier then
        module:SetStealthInMultiplier(value)
    end
end

function addon:GetContextMountedSpeedIn()
    local module = GetContextSpeedModule()
    if module and module.GetMountedInMultiplier then
        return module:GetMountedInMultiplier()
    end
    return 1
end

function addon:SetContextMountedSpeedIn(value)
    local module = GetContextSpeedModule()
    if module and module.SetMountedInMultiplier then
        module:SetMountedInMultiplier(value)
    end
end

function addon:IsSeparateInOutEnabled()
    local module = GetContextSpeedModule()
    if module and module.IsSeparateInOutEnabled then
        return module:IsSeparateInOutEnabled()
    end
    return false
end

function addon:GetSeparateInOutDefault()
    return defaults.contextSpeedSeparateInOut
end

function addon:GetDefault(key)
    return defaults[key]
end

function addon:IsImmersiveModeEnabled()
    if not self.savedVars then
        return defaults.immersionBlockAutoCamera
    end
    return self.savedVars.immersionBlockAutoCamera ~= false
end

function addon:SetImmersionBlockAutoCameraEnabled(enabled)
    if not self.savedVars then
        return
    end

    local value = enabled and true or false
    if self.savedVars.immersionBlockAutoCamera == value then
        return
    end
    self.savedVars.immersionBlockAutoCamera = value
end

-- Returns immutable definition list for interaction exceptions (for settings UI)
function addon:GetImmersionInteractionDefs()
    return IMMERSION_INTERACTION_DEFS
end

-- Returns true when the given interaction (by INTERACTION_* name) should keep default camera
function addon:IsImmersionInteractionSkippedByName(interactionConstName)
    if type(interactionConstName) ~= "string" then
        return true
    end

    local savedVars = self.savedVars
    if not savedVars then
        return true
    end

    local flags = savedVars.immersionSkipInteractionsByName
    if not flags then
        return true
    end

    local value = flags[interactionConstName]
    if value == nil then
        return true
    end

    return value and true or false
end

function addon:SetImmersionInteractionSkippedByName(interactionConstName, enabled)
    if type(interactionConstName) ~= "string" or not self.savedVars then
        return
    end

    local flags = self.savedVars.immersionSkipInteractionsByName
    if not flags then
        flags = {}
        self.savedVars.immersionSkipInteractionsByName = flags
    end

    local value = enabled and true or false
    if flags[interactionConstName] == value then
        return
    end

    flags[interactionConstName] = value
    RebuildSkipFreeDialogInteraction(self)
end

function addon:SetSeparateInOutEnabled(enabled)
    local module = GetContextSpeedModule()
    if module and module.SetSeparateInOutEnabled then
        module:SetSeparateInOutEnabled(enabled)
    end
end

-- Context Sensitivity methods
function addon:GetContextSensitivityMultiplier()
    local module = GetContextSensitivityModule()
    if module and module.GetCurrentMultiplier then
        return module:GetCurrentMultiplier()
    end
    return 1
end

function addon:GetContextSensitivityCombat()
    local module = GetContextSensitivityModule()
    if module and module.GetCombatMultiplier then
        return module:GetCombatMultiplier()
    end
    return 1
end

function addon:SetContextSensitivityCombat(value)
    local module = GetContextSensitivityModule()
    if module and module.SetCombatMultiplier then
        module:SetCombatMultiplier(value)
    end
end

function addon:GetContextSensitivityMounted()
    local module = GetContextSensitivityModule()
    if module and module.GetMountedMultiplier then
        return module:GetMountedMultiplier()
    end
    return 1
end

function addon:SetContextSensitivityMounted(value)
    local module = GetContextSensitivityModule()
    if module and module.SetMountedMultiplier then
        module:SetMountedMultiplier(value)
    end
end

function addon:GetContextSensitivitySprint()
    local module = GetContextSensitivityModule()
    if module and module.GetSprintMultiplier then
        return module:GetSprintMultiplier()
    end
    return 1
end

function addon:SetContextSensitivitySprint(value)
    local module = GetContextSensitivityModule()
    if module and module.SetSprintMultiplier then
        module:SetSprintMultiplier(value)
    end
end

function addon:RefreshContextSensitivityBase()
    local module = GetContextSensitivityModule()
    if module and module.RefreshBaseSensitivity then
        module:RefreshBaseSensitivity()
    end
end

function addon:IsContextSensitivityEnabled()
    if not self.savedVars then
        return defaults.contextSensitivityEnabled
    end
    return self.savedVars.contextSensitivityEnabled and true or false
end

function addon:SetContextSensitivityEnabled(enabled)
    if not self.savedVars then
        return
    end

    self.savedVars.contextSensitivityEnabled = enabled

    local module = GetContextSensitivityModule()
    if not module then
        return
    end

    if enabled then
        -- Initialize and start the module
        if not module.initialized and module.Initialize then
            module:Initialize(self)
        end
    else
        -- Shutdown the module
        if module.initialized and module.Shutdown then
            module:Shutdown()
        end
    end
end

function addon:IsZoomSmoothingEnabled()
    if not self.savedVars then
        return defaults.zoomSmoothingEnabled
    end
    return self.savedVars.zoomSmoothingEnabled and true or false
end

function addon:SetZoomSmoothingEnabled(enabled)
    if not self.savedVars then
        return
    end

    local value = enabled and true or false
    if self.savedVars.zoomSmoothingEnabled == value then
        return
    end

    self.savedVars.zoomSmoothingEnabled = value

    local module = GetZoomSmoothingModule()
    if module and module.SetEnabled then
        module:SetEnabled(value)
    end
end

function addon:GetMaxZoomDistanceRange()
    local limits = GetCameraLimitsModule()
    if limits and limits.GetMaxZoomDistanceRange then
        return limits:GetMaxZoomDistanceRange()
    end
    return MAX_ZOOM_DISTANCE_MIN, MAX_ZOOM_DISTANCE_MAX, defaults.maxZoomDistance
end

function addon:GetMaxZoomDistance()
    local limits = GetCameraLimitsModule()
    if limits and limits.GetMaxZoomDistance then
        return limits:GetMaxZoomDistance()
    end
    local saved = self.savedVars and self.savedVars.maxZoomDistance
    return ClampMaxZoomFallback(saved)
end

function addon:SetMaxZoomDistance(value)
    local limits = GetCameraLimitsModule()
    if limits and limits.SetMaxZoomDistance then
        limits:SetMaxZoomDistance(value)
        return
    end

    if not self.savedVars then
        return
    end

    local clamped = ClampMaxZoomFallback(value)
    if self.savedVars.maxZoomDistance == clamped then
        return
    end

    self.savedVars.maxZoomDistance = clamped
    self:EnforceMaxZoomDistance()
    self:RememberZoom()
end

function addon:EnforceMaxZoomDistance()
    local limits = GetCameraLimitsModule()
    if limits and limits.EnforceMaxZoomDistance then
        limits:EnforceMaxZoomDistance()
        return
    end

    local rawValue = tonumber(GetSetting(CAMERA_TYPE, CAMERA_DISTANCE))
    local clamped = ClampCameraDistanceFallback(rawValue)
    if rawValue == nil or clamped == nil then
        return
    end

    if math.abs(clamped - rawValue) > FIRST_PERSON_EPSILON then
        ApplyCameraDistance(clamped, { forceInstant = true })
    end
end

-- Returns the first-person module instance
local function GetFirstPersonModule()
    return modules.firstPerson
end

-- Returns the settings module instance
local function GetSettingsModule()
    return modules.settings
end

local function GetTransitionLogger()
    return modules.transitionLogger
end

-- Returns the first-person transition sources table
local function GetFirstPersonSources()
    local module = GetFirstPersonModule()
    return module and module.TRANSITION_SOURCE
end

local function MarkFirstPersonPending(source)
    local module = GetFirstPersonModule()
    if module and module.SetPendingSource then
        module:SetPendingSource(source)
    end
end

-- Updates the first-person module with the current camera distance
-- Returns true when the provided distance should be treated as first-person
local function IsWithinFirstPersonSnap(distance)
    return distance ~= nil and distance <= (FIRST_PERSON_SNAP_THRESHOLD + FIRST_PERSON_EPSILON)
end

local function UpdateFirstPersonDistance(distance)
    if distance == nil then
        return
    end

    local module = GetFirstPersonModule()
    if module and module.OnZoomValue then
        module:OnZoomValue(distance)
    end
end

-- Prepares a scroll transition based on the previous and new camera distances
local function PrepareScrollTransition(previousDistance, newDistance)
    local module = GetFirstPersonModule()
    if not module or not module.SetPendingSource then
        return
    end

    local sources = module.TRANSITION_SOURCE
    if not sources then
        return
    end

    if previousDistance ~= nil and newDistance ~= nil then
        local wasFirstPerson = IsWithinFirstPersonSnap(previousDistance)
        local willBeFirstPerson = IsWithinFirstPersonSnap(newDistance)

        if wasFirstPerson ~= willBeFirstPerson then
            if willBeFirstPerson then
                module:SetPendingSource(sources.SCROLL_ENTER or sources.SCROLL_ADJUST)
            else
                module:SetPendingSource(sources.SCROLL_EXIT or sources.SCROLL_ADJUST)
            end
            return
        end
    end

    module:SetPendingSource(sources.SCROLL_ADJUST or sources.SCROLL_ENTER)
end

-- Reads current camera distance from user settings
local function GetCameraDistance()
    local value = GetSetting(CAMERA_TYPE, CAMERA_DISTANCE)
    local distance = tonumber(value)
    return ClampCameraDistanceValue(distance)
end

local function ApplyCameraDistance(distance, options)
    addon:SetCameraDistance(distance, options)
end

-- Returns true when camera clamping is enforced by the game
local function IsZoomLimited()
    return IsMounted() or IsWerewolf()
end

function addon:RememberZoom()
    local zoom = GetCameraDistance()
    if zoom then
        self.savedVars.storedDistance = zoom
        -- First-person tracking is updated explicitly when we know the transition context
    end
end

function addon:RememberZoomDeferred()
    zo_callLater(function()
        addon:RememberZoom()
    end, 0)
end

function addon:IsDebugEnabled()
    if not self.savedVars then
        return false
    end
    return self.savedVars.debugEnabled and true or false
end

function addon:SetDebugEnabled(enabled)
    if not self.savedVars then
        return
    end

    local value = enabled and true or false
    if self.savedVars.debugEnabled == value then
        return
    end

    self.savedVars.debugEnabled = value

    local logger = GetTransitionLogger()
    if logger and logger.OnDebugPreferenceChanged then
        logger:OnDebugPreferenceChanged(value)
    end
end

function addon:IsControlledToggleZoomEnabled()
    if not self.savedVars then
        return defaults.useControlledToggleZoom
    end

    return self.savedVars.useControlledToggleZoom and true or false
end

function addon:SetControlledToggleZoomEnabled(enabled)
    if not self.savedVars then
        return
    end

    local value = enabled and true or false
    if self.savedVars.useControlledToggleZoom == value then
        return
    end

    self.savedVars.useControlledToggleZoom = value
end

function addon:OnFirstPersonTransition(isActive, source, distance)
    local logger = GetTransitionLogger()
    if logger and logger.OnFirstPersonTransition then
        logger:OnFirstPersonTransition(isActive, source, distance)
    end
    if self.owner and self.owner.OnFirstPersonTransition then
        self.owner:OnFirstPersonTransition(isActive, source, distance)
    end
end

-- Toggles runtime logic without removing hook registrations
function addon:SetEnabled(enabled)
    enabled = not not enabled

    if enabled == self.enabled then
        if enabled then
            self:RestoreZoom()
        end
        return
    end

    self.enabled = enabled

    if enabled then
        self:RestoreZoom()
    else
        local zoom = GetCameraDistance()
        if zoom then
            self.lastZoom = zoom
            self:RememberZoom()
        end
    end
end

-- Applies a first-person state change on behalf of the auto first-person module.
-- This uses the same zoom logic as the controlled toggle path, but is invoked
-- from safe event contexts instead of secure input handlers.
function addon:ApplyFirstPersonAutoState(active, reason)
    if not self.enabled then
        return
    end

    local zoom = GetCameraDistance()
    if not zoom then
        return
    end

    local firstPersonModule = GetFirstPersonModule()
    if not firstPersonModule or type(firstPersonModule.IsFirstPersonActive) ~= "function" then
        return
    end

    local isFirstPerson = firstPersonModule:IsFirstPersonActive()
    if isFirstPerson == active then
        return
    end

    local sources = GetFirstPersonSources()
    if sources then
        if active then
            MarkFirstPersonPending(sources.SCROLL_ENTER or sources.SCROLL_ADJUST)
        else
            MarkFirstPersonPending(sources.SCROLL_EXIT or sources.SCROLL_ADJUST)
        end
    end

    if active then
        -- Enter first person: remember current zoom and move camera to boundary.
        self.lastZoom = zoom
        PrepareScrollTransition(zoom, FIRST_PERSON_BOUNDARY)
        ApplyCameraDistance(FIRST_PERSON_BOUNDARY)
        UpdateFirstPersonDistance(FIRST_PERSON_BOUNDARY)
    else
        -- Exit first person: restore last known third-person zoom or fallback distance.
        local exitTarget = self.lastZoom
        if not exitTarget or exitTarget <= FIRST_PERSON_SNAP_THRESHOLD then
            exitTarget = THIRD_PERSON_FALLBACK_DISTANCE
        end

        local maxZoom = self:GetMaxZoomDistance()
        if exitTarget > maxZoom then
            exitTarget = maxZoom
        end

        PrepareScrollTransition(zoom, exitTarget)
        ApplyCameraDistance(exitTarget)
        UpdateFirstPersonDistance(exitTarget)
        self.lastZoom = exitTarget
    end

    self:RememberZoom()
end

-- Handles first-person toggle while respecting ESO's secure restrictions
function addon:HandleToggleGameCameraFirstPerson()
    if not self.enabled then
        return false
    end

    -- Notify auto first-person module about manual view toggle
    local autoFirstPersonModule = modules.autoFirstPerson
    if autoFirstPersonModule and autoFirstPersonModule.OnManualToggle then
        autoFirstPersonModule:OnManualToggle()
    end

    local zoom = GetCameraDistance()
    if not zoom then
        return false
    end

    local sources = GetFirstPersonSources()
    -- Mark upcoming transition as a toggle so the first-person module will classify it as TOGGLE_ENTER/EXIT
    MarkFirstPersonPending(sources and (sources.TOGGLE or sources.STARTUP))

    local useControlledToggle = self:IsControlledToggleZoomEnabled()

    if useControlledToggle and not IsZoomLimited() then
        -- When camera is not zoom-limited (normal on-foot gameplay) and controlled
        -- toggle zoom is enabled, we fully emulate the first-person toggle by moving
        -- the camera between our first- and third-person distances. This guarantees that
        -- the first-person module sees the transition, even though the game normally
        -- would not change the distance for a keyboard toggle.

        local inFirstPerson = IsWithinFirstPersonSnap(zoom)

        if inFirstPerson then
            -- Exit first person: restore last known third-person zoom or fallback distance.
            local exitTarget = self.lastZoom
            if not exitTarget or exitTarget <= FIRST_PERSON_SNAP_THRESHOLD then
                exitTarget = THIRD_PERSON_FALLBACK_DISTANCE
            end

            local maxZoom = self:GetMaxZoomDistance()
            if exitTarget > maxZoom then
                exitTarget = maxZoom
            end

            ApplyCameraDistance(exitTarget)
            self.lastZoom = exitTarget
            UpdateFirstPersonDistance(exitTarget)
        else
            -- Enter first person: remember current zoom and move camera to first-person boundary.
            self.lastZoom = zoom
            ApplyCameraDistance(FIRST_PERSON_BOUNDARY)
            UpdateFirstPersonDistance(FIRST_PERSON_BOUNDARY)
        end

        self:RememberZoom()
        return true
    end

    -- Native toggle path: do not change camera distance, let the game handle
    -- the first-person camera switch and only synchronize logical state using
    -- either the engine's first-person flag (when available) or our internal
    -- state in the first-person module.

    self.lastZoom = zoom
    self:RememberZoomDeferred()

    local firstPersonModule = GetFirstPersonModule()
    if firstPersonModule and type(firstPersonModule.SetFirstPersonActive) == "function" then
        local newState

        if type(IsInFirstPerson) == "function" then
            -- ZO_PreHook runs before the original function, so IsInFirstPerson
            -- still returns the current state. We invert it to predict the
            -- state after the native toggle.
            newState = not IsInFirstPerson()
        elseif type(firstPersonModule.IsFirstPersonActive) == "function" then
            -- Fallback for clients where IsInFirstPerson is not available:
            -- we track the logical first-person state ourselves and toggle it.
            newState = not firstPersonModule:IsFirstPersonActive()
        end

        if newState ~= nil then
            local distance = GetCameraDistance()
            zo_callLater(function()
                firstPersonModule:SetFirstPersonActive(newState, distance)
            end, 0)
        end
    end

    return false
end

function addon:HandleCameraZoomIn()
    if not self.enabled then
        return false
    end

    if IsGameCameraSiegeControlled() then
        self:RememberZoomDeferred()
        return false
    end

    local zoom = GetCameraDistance()
    if not zoom then
        return false
    end

    local maxZoom = self:GetMaxZoomDistance()
    if zoom > maxZoom then
        self:EnforceMaxZoomDistance()
        self:RememberZoomDeferred()
        return false
    end

    local zoomStep = self:GetZoomStep()
    local contextFactor = self.GetContextSpeedFactor and self:GetContextSpeedFactor("in") or 1
    if type(contextFactor) ~= "number" or contextFactor <= 0 then
        contextFactor = 1
    end
    local adjustedStep = zoomStep * contextFactor

    local newZoom = zoom - adjustedStep

    -- Snap directly to first-person when entering the snap threshold while zooming in
    if newZoom <= FIRST_PERSON_SNAP_THRESHOLD then
        newZoom = FIRST_PERSON_BOUNDARY
    end

    if newZoom < FIRST_PERSON_BOUNDARY then
        newZoom = FIRST_PERSON_BOUNDARY
    end

    if newZoom < zoom then
        PrepareScrollTransition(zoom, newZoom)
        self.lastZoom = zoom
        ApplyCameraDistance(newZoom)
        UpdateFirstPersonDistance(newZoom)
        self:RememberZoom()
    end

    return true
end

function addon:HandleCameraZoomOut()
    if not self.enabled then
        return false
    end

    if IsGameCameraSiegeControlled() then
        self:RememberZoomDeferred()
        return false
    end

    local zoom = GetCameraDistance()
    if not zoom then
        return false
    end

    local maxZoom = self:GetMaxZoomDistance()
    if zoom >= maxZoom - FIRST_PERSON_EPSILON then
        self:EnforceMaxZoomDistance()
        self:RememberZoomDeferred()
        return true
    end

    local zoomStep = self:GetZoomStep()
    local contextFactor = self.GetContextSpeedFactor and self:GetContextSpeedFactor("out") or 1
    if type(contextFactor) ~= "number" or contextFactor <= 0 then
        contextFactor = 1
    end
    local adjustedStep = zoomStep * contextFactor

    local newZoom = zoom + adjustedStep
    if newZoom > maxZoom then
        newZoom = maxZoom
    end

    if math.abs(newZoom - zoom) <= FIRST_PERSON_EPSILON then
        self:RememberZoomDeferred()
        return false
    end

    -- When leaving first-person the value increases above the snap threshold, so subsequent zoom-in snaps again
    -- only after re-entering <= FIRST_PERSON_SNAP_THRESHOLD. We update the first-person module with the new distance.
    PrepareScrollTransition(zoom, newZoom)
    ApplyCameraDistance(newZoom)
    UpdateFirstPersonDistance(newZoom)
    self:RememberZoom()

    return true
end

-- Store original functions for fallback
local originalCameraZoomIn = CameraZoomIn
local originalCameraZoomOut = CameraZoomOut
local originalToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson

local overridesRegistered = false

local function RegisterOverrides()
    if overridesRegistered then
        return
    end

    -- Override CameraZoomIn
    CameraZoomIn = function(...)
        local handled = addon:HandleCameraZoomIn(...)
        if not handled and originalCameraZoomIn then
            originalCameraZoomIn(...)
        end
    end

    -- Override CameraZoomOut
    CameraZoomOut = function(...)
        local handled = addon:HandleCameraZoomOut(...)
        if not handled and originalCameraZoomOut then
            originalCameraZoomOut(...)
        end
    end

    -- Override ToggleGameCameraFirstPerson
    ToggleGameCameraFirstPerson = function(...)
        local handled = addon:HandleToggleGameCameraFirstPerson(...)
        if not handled and originalToggleGameCameraFirstPerson then
            originalToggleGameCameraFirstPerson(...)
        end
    end

    overridesRegistered = true
end

-- Applies saved zoom (if available) after reload/login
function addon:RestoreZoom()
    -- Try to restore saved zoom value, or use last known zoom value
    local target = self.savedVars.storedDistance or self.lastZoom or GetCameraDistance()
    if target then
        local previousDistance = GetCameraDistance()
        PrepareScrollTransition(previousDistance, target)
        ApplyCameraDistance(target, { forceInstant = true })
        self.lastZoom = target
        UpdateFirstPersonDistance(target)
    end
end

function addon:OnPlayerActivated()
    if self:IsDebugEnabled() then
        d("[FOXUltimateCamera] Player activated - enabling addon")
    end

    RegisterOverrides()
    self:SetEnabled(true)

    local firstPersonModule = GetFirstPersonModule()
    if firstPersonModule then
        local sources = firstPersonModule.TRANSITION_SOURCE
        if sources then
            MarkFirstPersonPending(sources.STARTUP)
        end
        if type(firstPersonModule.SetFirstPersonActive) == "function" then
            firstPersonModule:SetFirstPersonActive()
        end
        UpdateFirstPersonDistance(GetCameraDistance())
    end
end

function addon:Shutdown(keepHandlers)
    if self:IsDebugEnabled() then
        d("[FOXUltimateCamera] Shutdown called - keepHandlers: " .. tostring(keepHandlers or false))
    end

    self:SetEnabled(false)

    local firstPersonModule = GetFirstPersonModule()
    if not keepHandlers then
        if firstPersonModule and firstPersonModule.Shutdown then
            firstPersonModule:Shutdown()
        end
    end

    local zoomSmoothingModule = GetZoomSmoothingModule()
    if zoomSmoothingModule then
        if zoomSmoothingModule.Cancel then
            zoomSmoothingModule:Cancel()
        end
        if not keepHandlers and zoomSmoothingModule.Shutdown then
            zoomSmoothingModule:Shutdown()
        end
    end

    local logger = GetTransitionLogger()
    if not keepHandlers and logger and logger.Shutdown then
        logger:Shutdown()
    end

    local contextSensitivityModule = GetContextSensitivityModule()
    if not keepHandlers and contextSensitivityModule and contextSensitivityModule.Shutdown then
        contextSensitivityModule:Shutdown()
    end

    local autoFirstPersonModule = modules.autoFirstPerson
    if not keepHandlers and autoFirstPersonModule and autoFirstPersonModule.Shutdown then
        autoFirstPersonModule:Shutdown()
    end

    local weaponSheathingModule = GetWeaponSheathingModule()
    if not keepHandlers and weaponSheathingModule and weaponSheathingModule.Shutdown then
        weaponSheathingModule:Shutdown()
    end

    local fovContextModule = GetFovContextModule()
    if not keepHandlers and fovContextModule and fovContextModule.Shutdown then
        fovContextModule:Shutdown()
    end

    local interactionGuardModule = GetInteractionGuardModule()
    if not keepHandlers and interactionGuardModule and interactionGuardModule.Shutdown then
        interactionGuardModule:Shutdown()
    end

    local fovModule = GetFovModule()
    if not keepHandlers and fovModule and fovModule.Shutdown then
        fovModule:Shutdown()
    end

    -- Only unregister event handlers if this is a full shutdown (not just deactivation)
    if not keepHandlers then
        EM:UnregisterForEvent(self.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
        EM:UnregisterForEvent(self.name .. "_InterfaceSettingChanged", EVENT_INTERFACE_SETTING_CHANGED)

        EM:UnregisterForEvent(self.name .. "_GameCameraDeactivated", EVENT_GAME_CAMERA_DEACTIVATED)

        if EVENT_PLAYER_DEACTIVATED ~= nil then
            EM:UnregisterForEvent(self.name .. "_PlayerDeactivated", EVENT_PLAYER_DEACTIVATED)
        end

        EM:UnregisterForEvent(self.name .. "_Loaded", EVENT_ADD_ON_LOADED)
    end
end

function addon:Initialize()
    local currentZoom = GetCameraDistance() or THIRD_PERSON_FLOOR
    defaults.storedDistance = currentZoom

    self.savedVars = ZO_SavedVars:NewAccountWide(self.name .. "_SavedVariables", 2, nil, defaults)
    if type(self.savedVars.storedDistance) ~= "number" then
        self.savedVars.storedDistance = currentZoom
    end
    if type(self.savedVars.debugEnabled) ~= "boolean" then
        self.savedVars.debugEnabled = defaults.debugEnabled
    end
    if type(self.savedVars.useControlledToggleZoom) ~= "boolean" then
        self.savedVars.useControlledToggleZoom = defaults.useControlledToggleZoom
    end
    if type(self.savedVars.maxZoomDistance) ~= "number" then
        self.savedVars.maxZoomDistance = defaults.maxZoomDistance
    end

    if type(self.savedVars.zoomSmoothingEnabled) ~= "boolean" then
        self.savedVars.zoomSmoothingEnabled = defaults.zoomSmoothingEnabled
    end

    if type(self.savedVars.zoomSpeed) ~= "number" then
        self.savedVars.zoomSpeed = defaults.zoomSpeed
    end

    if type(self.savedVars.contextSpeedSeparateInOut) ~= "boolean" then
        self.savedVars.contextSpeedSeparateInOut = defaults.contextSpeedSeparateInOut
    end

    if type(self.savedVars.contextSensitivityEnabled) ~= "boolean" then
        self.savedVars.contextSensitivityEnabled = defaults.contextSensitivityEnabled
    end

    if type(self.savedVars.contextSensitivityCombat) ~= "number" then
        self.savedVars.contextSensitivityCombat = defaults.contextSensitivityCombat
    end

    if type(self.savedVars.contextSensitivityMounted) ~= "number" then
        self.savedVars.contextSensitivityMounted = defaults.contextSensitivityMounted
    end

    if type(self.savedVars.contextSensitivitySprint) ~= "number" then
        self.savedVars.contextSensitivitySprint = defaults.contextSensitivitySprint
    end

    -- Rebuild immersive interaction skip list for Free Dialog Camera based on saved preferences
    RebuildSkipFreeDialogInteraction(self)

    self.lastZoom = self.savedVars.storedDistance or currentZoom

    local firstPersonModule = GetFirstPersonModule()
    if firstPersonModule and firstPersonModule.Initialize then
        firstPersonModule:Initialize(self, FIRST_PERSON_BOUNDARY)
    end

    local cameraLimits = GetCameraLimitsModule()
    if cameraLimits and cameraLimits.Initialize then
        cameraLimits:Initialize(self, {
            minBoundary = FIRST_PERSON_BOUNDARY,
            configMin = MAX_ZOOM_DISTANCE_MIN,
            configMax = MAX_ZOOM_DISTANCE_MAX,
            defaultMax = DEFAULT_MAX_ZOOM_DISTANCE,
            epsilon = FIRST_PERSON_EPSILON,
        })
    end

    local zoomStepModule = GetZoomStepModule()
    if zoomStepModule and zoomStepModule.Initialize then
        zoomStepModule:Initialize(self, {
            minStep = MIN_ZOOM_STEP,
            maxStep = MAX_ZOOM_STEP,
            defaultStep = DEFAULT_ZOOM_STEP,
        })
    end

    local zoomSpeedModule = GetZoomSpeedModule()
    if zoomSpeedModule and zoomSpeedModule.Initialize then
        zoomSpeedModule:Initialize(self, {
            minSpeed = MIN_ZOOM_SPEED,
            maxSpeed = MAX_ZOOM_SPEED,
            defaultSpeed = DEFAULT_ZOOM_SPEED,
        })
    end

    local zoomSmoothingModule = GetZoomSmoothingModule()
    if zoomSmoothingModule and zoomSmoothingModule.Initialize then
        zoomSmoothingModule:Initialize(self)
    end

    local contextSpeedModule = GetContextSpeedModule()
    if contextSpeedModule and contextSpeedModule.Initialize then
        contextSpeedModule:Initialize(self)
    end

    local contextSensitivityModule = GetContextSensitivityModule()
    if contextSensitivityModule and contextSensitivityModule.Initialize and self.savedVars.contextSensitivityEnabled then
        contextSensitivityModule:Initialize(self)
    end

    local customSliderModule = GetCustomSliderModule()
    if customSliderModule and customSliderModule.Initialize then
        customSliderModule:Initialize()
    end

    local customCheckboxModule = GetCustomCheckboxModule()
    if customCheckboxModule and customCheckboxModule.Initialize then
        customCheckboxModule:Initialize()
    end

    local cameraOffsetModule = GetCameraOffsetModule()
    if cameraOffsetModule and cameraOffsetModule.Initialize then
        cameraOffsetModule:Initialize(self)
    end

    local cameraOffsetIndicatorModule = GetCameraOffsetIndicatorModule()
    if cameraOffsetIndicatorModule and cameraOffsetIndicatorModule.Initialize then
        cameraOffsetIndicatorModule:Initialize(self)
    end

    local logger = GetTransitionLogger()
    if logger and logger.Initialize then
        logger:Initialize(self)
        if logger.OnDebugPreferenceChanged then
            logger:OnDebugPreferenceChanged(self:IsDebugEnabled())
        end
    end

    local fovModule = GetFovModule()
    if fovModule and fovModule.Initialize then
        fovModule:Initialize(self)
    end

    local fovContextModule = GetFovContextModule()
    if fovContextModule and fovContextModule.Initialize then
        fovContextModule:Initialize(self)
    end

    local settingsModule = GetSettingsModule()
    if settingsModule and settingsModule.Initialize then
        settingsModule:Initialize(self)
    end

    local interactionGuardModule = GetInteractionGuardModule()
    if interactionGuardModule and interactionGuardModule.Initialize then
        interactionGuardModule:Initialize(self)
    end

    local autoFirstPersonModule = modules.autoFirstPerson
    if autoFirstPersonModule and autoFirstPersonModule.Initialize then
        autoFirstPersonModule:Initialize(self)
    end

    local weaponSheathingModule = GetWeaponSheathingModule()
    if weaponSheathingModule and weaponSheathingModule.Initialize then
        weaponSheathingModule:Initialize(self)
    end

    RegisterOverrides()

    EM:RegisterForEvent(self.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        addon:OnPlayerActivated()
    end)

    EM:RegisterForEvent(self.name .. "_InterfaceSettingChanged", EVENT_INTERFACE_SETTING_CHANGED,
        function(_, changedType, changedSetting)
            addon:OnInterfaceSettingChanged(changedType, changedSetting)
        end)

    if EVENT_PLAYER_DEACTIVATED ~= nil then
        EM:RegisterForEvent(self.name .. "_PlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function()
            addon:Shutdown(true)
        end)
    end

    EM:RegisterForEvent(self.name .. "_GameCameraDeactivated", EVENT_GAME_CAMERA_DEACTIVATED, function()
        OnGameCameraDeactivated()
    end)

    self:SetEnabled(true)
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= addon.name then
        return
    end

    EM:UnregisterForEvent(addon.name .. "_Loaded", EVENT_ADD_ON_LOADED)
    addon:Initialize()
end

EM:RegisterForEvent(addon.name .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
