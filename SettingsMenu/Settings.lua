-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

local libName = "LibAddonMenu-2.0"
local LAM = LibAddonMenu2 or (LibStub and LibStub(libName, true))

local IMMERSION_INTERACTIONS_SETTINGS_ICON = "FOXUltimateCamera/Textures/IMMERSION_INTERACTIONS_SETTINGS_ICON.dds"
local CONTEXT_SPEED_SETTINGS_ICON = "FOXUltimateCamera/Textures/CONTEXT_SPEED_SETTINGS_ICON.dds"
local CONTEXT_SENSITIVITY_SETTINGS_ICON = "FOXUltimateCamera/Textures/CONTEXT_SENSITIVITY_SETTINGS_ICON.dds"
local FIRST_PERSON_AUTO_SETTINGS_ICON = "FOXUltimateCamera/Textures/FIRST_PERSON_AUTO_SETTINGS_ICON.dds"
local CAMERA_OFFSET_SETTINGS_ICON = "FOXUltimateCamera/Textures/CAMERA_OFFSET_SETTINGS_ICON.dds"
local MAIN_CATEGORY_SETTINGS_ICON = "FOXUltimateCamera/Textures/MAIN_CATEGORY_SETTINGS_ICON.dds"

local SettingsMenu = {}
SettingsMenu.__index = SettingsMenu

function SettingsMenu:New()
    local instance = setmetatable({}, SettingsMenu)
    instance.addon = nil
    instance.panel = nil
    instance.initialized = false
    return instance
end

local function RegisterDialogs(addon)
    if FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_DIALOG_REGISTERED then
        return
    end
    FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_DIALOG_REGISTERED = true

    ZO_Dialogs_RegisterCustomDialog("FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_CONFIRM", {
        title = { text = GetString(SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL) },
        mainText = { text = GetString(SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_WARNING_CONFIRM) },
        buttons = {
            [1] = {
                text = SI_DIALOG_CONFIRM,
                callback = function()
                    if addon and addon.modules and addon.modules.CameraOffset then
                        addon.modules.CameraOffset.UpdateOriginalSettings()
                    end
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

local function ResolveCheckboxControlType(addon)
    if addon and addon.IsCustomCheckboxAvailable and addon:IsCustomCheckboxAvailable() then
        if addon.GetCustomCheckboxControlType then
            return addon:GetCustomCheckboxControlType()
        end
    end
    return "checkbox"
end

local function ResolveSliderControlType(addon)
    if addon and addon.IsCustomSliderAvailable and addon:IsCustomSliderAvailable() then
        if addon.GetCustomSliderControlType then
            return addon:GetCustomSliderControlType()
        end
    end
    return "fox_slider"
end

local function GetImmersionInteractionControls(addon, checkboxType)
    local controls = {}

    if not addon or not addon.GetImmersionInteractionDefs then
        return controls
    end

    local defs = addon:GetImmersionInteractionDefs()
    if not defs then
        return controls
    end

    for _, def in ipairs(defs) do
        local constName = def.constName
        local labelStringId = def.labelStringId
        local label = constName

        if labelStringId and _G[labelStringId] ~= nil then
            label = GetString(_G[labelStringId])
        end

        table.insert(controls, {
            type = checkboxType,
            name = label,
            tooltip = GetString(SI_FOXUC_IMMERSION_INTERACTION_ENTRY_TT),
            getFunc = function()
                if addon and addon.IsImmersionInteractionSkippedByName then
                    return addon:IsImmersionInteractionSkippedByName(constName)
                end
                return true
            end,
            setFunc = function(value)
                if addon and addon.SetImmersionInteractionSkippedByName then
                    addon:SetImmersionInteractionSkippedByName(constName, value)
                end
            end,
            default = true,
            width = "full",
        })
    end

    return controls
end

local function GetPanelData(addon)
    return {
        type = "panel",
        name = "FOX Ultimate Camera",
        displayName = "|cFF8000FOX|r Ultimate Camera",
        author = "meshlg",
        version = "5.05.2234",
        slashCommand = GetString(SI_FOXUC_SLASH_COMMAND),
        registerForDefaults = false,
        registerForRefresh = true,
    }
end
local function GetOptionsTable(addon)
    local checkboxType = ResolveCheckboxControlType(addon)
    local sliderType = ResolveSliderControlType(addon)

    return {
        {
            type = "header",
            name = string.format("|t32:32:%s|t %s", MAIN_CATEGORY_SETTINGS_ICON, GetString(SI_FOXUC_MAIN_CATEGORY)),
        },
        {
            type = "description",
            text = GetString(SI_FOXUC_CAMERA_SECTION_DESC),
            width = "full",
        },
        { type = "divider" },
        -- Immersive Mode Visual Block
        {
            type = "description",
            text = function()
                local isEnabled = addon and addon.savedVars and addon.savedVars.immersionBlockAutoCamera ~= false
                local status = isEnabled and GetString(SI_FOXUC_IMMERSION_MODE_STATUS_ON) or GetString(SI_FOXUC_IMMERSION_MODE_STATUS_OFF)
                return string.format("%s    %s", GetString(SI_FOXUC_IMMERSION_MODE_HEADER), status)
            end,
            width = "full",
        },
        {
            type = "description",
            text = GetString(SI_FOXUC_IMMERSION_MODE_DESC),
            width = "full",
        },
        { -- Immersion interactions (master toggle)
            type = checkboxType,
            name = GetString(SI_FOXUC_IMMERSION_INTERACTIONS_ENABLED),
            tooltip = GetString(SI_FOXUC_IMMERSION_INTERACTIONS_ENABLED_TT),
            getFunc = function()
                if addon and addon.savedVars then
                    return addon.savedVars.immersionBlockAutoCamera ~= false
                end
                return true
            end,
            setFunc = function(value)
                if addon and addon.SetImmersionBlockAutoCameraEnabled then
                    addon:SetImmersionBlockAutoCameraEnabled(value)
                elseif addon and addon.savedVars then
                    addon.savedVars.immersionBlockAutoCamera = value and true or false
                end
            end,
            default = (function()
                return (addon and addon.GetDefault and addon:GetDefault("immersionBlockAutoCamera")) or true
            end)(),
        },
        { type = "divider" },
        {
            type = "submenu",
            name = function()
                -- Count enabled interaction exceptions (only if Immersive Mode is ON)
                local count = 0
                local total = 0
                local defs = addon and addon.GetImmersionInteractionDefs and addon:GetImmersionInteractionDefs()
                if defs then
                    total = #defs
                    local isImmersionOn = addon.savedVars and addon.savedVars.immersionBlockAutoCamera ~= false
                    if isImmersionOn then
                        for _, def in ipairs(defs) do
                            local result = addon:IsImmersionInteractionSkippedByName(def.constName)
                            if result then
                                count = count + 1
                            end
                        end
                    end
                end
                local color = count > 0 and "|c6AA84F" or "|c555555"
                return string.format("%s%d/%d|r %s", color, count, total, GetString(SI_FOXUC_IMMERSION_INTERACTIONS_SUBMENU))
            end,
            tooltip = GetString(SI_FOXUC_IMMERSION_INTERACTIONS_SUBMENU_TT),
            controls = GetImmersionInteractionControls(addon, checkboxType),
            icon = IMMERSION_INTERACTIONS_SETTINGS_ICON,
        },
        {
            type = "submenu",
            name = GetString(SI_FOXUC_IMMERSION_PREVIEW_GUIDE_SUBMENU),
            tooltip = GetString(SI_FOXUC_IMMERSION_PREVIEW_GUIDE_SUBMENU_TT),
            controls = {
                {
                    type = "description",
                    text = GetString(SI_FOXUC_IMMERSION_PREVIEW_GUIDE_TEXT),
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = GetString(SI_FOXUC_ZOOM_GUIDE_SUBMENU),
            tooltip = GetString(SI_FOXUC_ZOOM_GUIDE_SUBMENU_TT),
            controls = {
                {
                    type = "description",
                    text = GetString(SI_FOXUC_ZOOM_GUIDE_TEXT),
                    width = "full",
                },
            },
        },
        { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
        {   -- Max zoom distance
            type = sliderType,
            name = GetString(SI_FOXUC_MAX_ZOOM_DISTANCE),
            tooltip = GetString(SI_FOXUC_MAX_ZOOM_DISTANCE_TT),
            getFunc = function()
                if addon and addon.GetMaxZoomDistance then
                    return addon:GetMaxZoomDistance()
                end
                return 10
            end,
            setFunc = function(value)
                if addon and addon.SetMaxZoomDistance then
                    addon:SetMaxZoomDistance(value)
                end
            end,
            min = (function()
                if addon and addon.GetMaxZoomDistanceRange then
                    local minValue = select(1, addon:GetMaxZoomDistanceRange())
                    return minValue or 2
                end
                return 2
            end)(),
            max = (function()
                if addon and addon.GetMaxZoomDistanceRange then
                    local _, maxValue = addon:GetMaxZoomDistanceRange()
                    return maxValue or 10
                end
                return 10
            end)(),
            step = 0.1,
            decimals = 1,
            default = (function()
                if addon and addon.GetMaxZoomDistanceRange then
                    local _, _, defaultValue = addon:GetMaxZoomDistanceRange()
                    return defaultValue or (addon and addon.GetDefault and addon:GetDefault("maxZoomDistance")) or 10
                end
                return (addon and addon.GetDefault and addon:GetDefault("maxZoomDistance")) or 10
            end)(),
            requiresRefresh = false,
        },
        {   -- Zoom step
            type = sliderType,
            name = GetString(SI_FOXUC_ZOOM_STEP),
            tooltip = GetString(SI_FOXUC_ZOOM_STEP_TT),
            getFunc = function()
                if addon and addon.GetZoomStep then
                    return addon:GetZoomStep()
                end
                return 0.1
            end,
            setFunc = function(value)
                if addon and addon.SetZoomStep then
                    addon:SetZoomStep(value)
                end
            end,
            min = (function()
                if addon and addon.GetZoomStepRange then
                    local minValue = select(1, addon:GetZoomStepRange())
                    return minValue or 0.025
                end
                return 0.025
            end)(),
            max = (function()
                if addon and addon.GetZoomStepRange then
                    local _, maxValue = addon:GetZoomStepRange()
                    return maxValue or 1
                end
                return 1
            end)(),
            step = 0.025,
            decimals = 3,
            default = (function()
                if addon and addon.GetZoomStepRange then
                    local _, _, defaultValue = addon:GetZoomStepRange()
                    return defaultValue or (addon and addon.GetDefault and addon:GetDefault("zoomStep")) or 0.225
                end
                return (addon and addon.GetDefault and addon:GetDefault("zoomStep")) or 0.225
            end)(),
            requiresRefresh = false,
        },
        {   -- Zoom smoothing
            type = checkboxType,
            name = GetString(SI_FOXUC_ZOOM_SMOOTHING),
            tooltip = GetString(SI_FOXUC_ZOOM_SMOOTHING_TT),
            getFunc = function()
                if addon and addon.IsZoomSmoothingEnabled then
                    return addon:IsZoomSmoothingEnabled()
                end
                return false
            end,
            setFunc = function(value)
                if addon and addon.SetZoomSmoothingEnabled then
                    addon:SetZoomSmoothingEnabled(value)
                end
            end,
            default = (function()
                return (addon and addon.GetDefault and addon:GetDefault("zoomSmoothingEnabled")) or false
            end)(),
            requiresRefresh = false,
        },
        {   -- Zoom speed
            type = sliderType,
            name = GetString(SI_FOXUC_ZOOM_SPEED),
            tooltip = GetString(SI_FOXUC_ZOOM_SPEED_TT),
            getFunc = function()
                if addon and addon.GetZoomSpeed then
                    return addon:GetZoomSpeed()
                end
                return 1.0
            end,
            setFunc = function(value)
                if addon and addon.SetZoomSpeed then
                    addon:SetZoomSpeed(value)
                end
            end,
            min = (function()
                if addon and addon.GetZoomSpeedRange then
                    local minValue = select(1, addon:GetZoomSpeedRange())
                    return minValue or 0.5
                end
                return 0.5
            end)(),
            max = (function()
                if addon and addon.GetZoomSpeedRange then
                    local _, maxValue = addon:GetZoomSpeedRange()
                    return maxValue or 2.0
                end
                return 2.0
            end)(),
            step = 0.05,
            decimals = 2,
            default = (function()
                if addon and addon.GetZoomSpeedRange then
                    local _, _, defaultValue = addon:GetZoomSpeedRange()
                    return defaultValue or (addon and addon.GetDefault and addon:GetDefault("zoomSpeed")) or 1.5
                end
                return (addon and addon.GetDefault and addon:GetDefault("zoomSpeed")) or 1.5
            end)(),
            requiresRefresh = false,
        },
        {   -- First-person FOV
            type = sliderType,
            name = GetString(SI_FOXUC_FOV_FIRST_PERSON),
            tooltip = GetString(SI_FOXUC_FOV_FIRST_PERSON_TT),
            getFunc = function()
                local module = addon and addon.modules and addon.modules.FovController
                if module and module.GetFirstPersonFovUi then
                    return module:GetFirstPersonFovUi()
                end
                return 100
            end,
            setFunc = function(value)
                local module = addon and addon.modules and addon.modules.FovController
                if module and module.SetFirstPersonFovUi then
                    module:SetFirstPersonFovUi(value)
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
        },
        {   -- Third-person FOV
            type = sliderType,
            name = GetString(SI_FOXUC_FOV_THIRD_PERSON),
            tooltip = GetString(SI_FOXUC_FOV_THIRD_PERSON_TT),
            getFunc = function()
                local module = addon and addon.modules and addon.modules.FovController
                if module and module.GetThirdPersonFovUi then
                    return module:GetThirdPersonFovUi()
                end
                return 100
            end,
            setFunc = function(value)
                local module = addon and addon.modules and addon.modules.FovController
                if module and module.SetThirdPersonFovUi then
                    module:SetThirdPersonFovUi(value)
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
        },
        {
            type = "button",
            name = GetString(SI_FOXUC_FOV_RESTORE_ORIGINAL),
            tooltip = GetString(SI_FOXUC_FOV_RESTORE_ORIGINAL_TT),
            func = function()
                local module = addon and addon.modules and addon.modules.FovController
                if module and module.RestoreOriginalFov then
                    module:RestoreOriginalFov()
                end
            end,
            width = "full",
        },
        {   -- FOV smoothing
            type = checkboxType,
            name = GetString(SI_FOXUC_FOV_SMOOTHING),
            tooltip = GetString(SI_FOXUC_FOV_SMOOTHING_TT),
            getFunc = function()
                if addon and addon.savedVars then
                    return addon.savedVars.fovSmoothingEnabled ~= false
                end
                return true
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    addon.savedVars.fovSmoothingEnabled = value and true or false
                end
            end,
            default = (function()
                return (addon and addon.GetDefault and addon:GetDefault("fovSmoothingEnabled")) or true
            end)(),
            requiresRefresh = false,
        },
        {   -- FOV smoothing speed
            type = sliderType,
            name = GetString(SI_FOXUC_FOV_SMOOTHING_SPEED),
            tooltip = GetString(SI_FOXUC_FOV_SMOOTHING_SPEED_TT),
            getFunc = function()
                if addon and addon.savedVars then
                    return addon.savedVars.fovSmoothingSpeed or
                        (addon.GetDefault and addon:GetDefault("fovSmoothingSpeed")) or 10
                end
                return 10
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    addon.savedVars.fovSmoothingSpeed = value
                end
            end,
            min = 1,
            max = 30,
            step = 1,
            decimals = 0,
            default = 10,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.fovSmoothingEnabled ~= false)
            end,
        },
        { -- Contextual FOV header
            type = "header",
            name = GetString(SI_FOXUC_CONTEXT_FOV_HEADER),
        },
        { -- Context FOV enable
            type = checkboxType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_ENABLED),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_ENABLED_TT),
            getFunc = function()
                if addon and addon.savedVars then
                    return addon.savedVars.contextFovEnabled and true or false
                end
                return false
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    addon.savedVars.contextFovEnabled = value and true or false
                end
            end,
            default = false,
            requiresRefresh = false,
        },
        { -- Context FOV ignore PvP
            type = checkboxType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_IGNORE_PVP),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_IGNORE_PVP_TT),
            getFunc = function()
                if addon and addon.savedVars then
                    return addon.savedVars.contextFovIgnorePvp ~= false
                end
                return true
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    addon.savedVars.contextFovIgnorePvp = value and true or false
                end
            end,
            default = true,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { -- Combat FOV header
            type = "header",
            name = GetString(SI_FOXUC_HEADER_COMBAT_FOV),
        },
        { -- Combat FOV (1st person)
            type = sliderType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_COMBAT_FIRST),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_COMBAT_FIRST_TT),
            getFunc = function()
                if addon and addon.savedVars and addon.savedVars.contextFovCombatFirst then
                    local v = addon.savedVars.contextFovCombatFirst
                    return (v * 2)
                end
                return 100
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    local gameValue = value / 2
                    addon.savedVars.contextFovCombatFirst = gameValue
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { -- Combat FOV (3rd person)
            type = sliderType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_COMBAT_THIRD),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_COMBAT_THIRD_TT),
            getFunc = function()
                if addon and addon.savedVars and addon.savedVars.contextFovCombatThird then
                    local v = addon.savedVars.contextFovCombatThird
                    return (v * 2)
                end
                return 100
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    local gameValue = value / 2
                    addon.savedVars.contextFovCombatThird = gameValue
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { -- Mounted FOV header
            type = "header",
            name = GetString(SI_FOXUC_HEADER_MOUNTED_FOV),
        },
        { -- Mounted FOV (1st person)
            type = sliderType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_MOUNTED_FIRST),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_MOUNTED_FIRST_TT),
            getFunc = function()
                if addon and addon.savedVars and addon.savedVars.contextFovMountedFirst then
                    local v = addon.savedVars.contextFovMountedFirst
                    local uiValue = v * 2
                    if d and addon.IsDebugEnabled and addon:IsDebugEnabled() then
                        d(string.format("[FOXUC:Settings] MountedFirst getFunc saved=%s ui=%s", tostring(v), tostring(uiValue)))
                    end
                    return uiValue
                end
                if d and addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
                    d("[FOXUC:Settings] MountedFirst getFunc using fallback 100")
                end
                return 100
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    local gameValue = value / 2
                    local oldValue = addon.savedVars.contextFovMountedFirst
                    if d and addon.IsDebugEnabled and addon:IsDebugEnabled() then
                        d(string.format("[FOXUC:Settings] MountedFirst setFunc value=%s game=%s old=%s", tostring(value), tostring(gameValue), tostring(oldValue)))
                    end
                    addon.savedVars.contextFovMountedFirst = gameValue
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { -- Mounted FOV (3rd person)
            type = sliderType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_MOUNTED_THIRD),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_MOUNTED_THIRD_TT),
            getFunc = function()
                if addon and addon.savedVars and addon.savedVars.contextFovMountedThird then
                    local v = addon.savedVars.contextFovMountedThird
                    return (v * 2)
                end
                return 100
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    local gameValue = value / 2
                    addon.savedVars.contextFovMountedThird = gameValue
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { -- Interior FOV header
            type = "header",
            name = GetString(SI_FOXUC_HEADER_INTERIOR_FOV),
        },
        { -- Interior FOV (1st person)
            type = sliderType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_INTERIOR_FIRST),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_INTERIOR_FIRST_TT),
            getFunc = function()
                if addon and addon.savedVars and addon.savedVars.contextFovInteriorFirst then
                    local v = addon.savedVars.contextFovInteriorFirst
                    return (v * 2)
                end
                return 100
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    local gameValue = value / 2
                    addon.savedVars.contextFovInteriorFirst = gameValue
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { -- Interior FOV (3rd person)
            type = sliderType,
            name = GetString(SI_FOXUC_CONTEXT_FOV_INTERIOR_THIRD),
            tooltip = GetString(SI_FOXUC_CONTEXT_FOV_INTERIOR_THIRD_TT),
            getFunc = function()
                if addon and addon.savedVars and addon.savedVars.contextFovInteriorThird then
                    local v = addon.savedVars.contextFovInteriorThird
                    return (v * 2)
                end
                return 100
            end,
            setFunc = function(value)
                if addon and addon.savedVars then
                    local gameValue = value / 2
                    addon.savedVars.contextFovInteriorThird = gameValue
                end
            end,
            min = 70,
            max = 130,
            step = 1,
            decimals = 0,
            default = 100,
            requiresRefresh = false,
            disabled = function()
                return not (addon and addon.savedVars and addon.savedVars.contextFovEnabled)
            end,
        },
        { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
        { -- Toggle mode controlled zoom
            type = checkboxType,
            name = GetString(SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM),
            tooltip = GetString(SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM_TT),
            getFunc = function()
                if addon and addon.IsControlledToggleZoomEnabled then
                    return addon:IsControlledToggleZoomEnabled()
                end
                return true
            end,
            setFunc = function(value)
                if addon and addon.SetControlledToggleZoomEnabled then
                    addon:SetControlledToggleZoomEnabled(value)
                end
            end,
            default = (function()
                return (addon and addon.GetDefault and addon:GetDefault("useControlledToggleZoom")) or true
            end)(),
            requiresRefresh = false,
            warning = GetString(SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM_WARNING),
        },
        { type = "description", text = "", width = "full" }, -- Spacer | Do not remove

        -- Context Speed submenu (как отдельный блок)
        {
            type = "submenu",
            name = function()
                -- Count: Separate In/Out
                local count = 0
                local total = 1
                if addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled() then count = count + 1 end
                local color = count > 0 and "|c6AA84F" or "|c555555"
                return string.format("%s%d/%d|r %s", color, count, total, GetString(SI_FOXUC_CONTEXT_SPEED_SUBMENU))
            end,
            tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_SUBMENU_TT),
            icon = CONTEXT_SPEED_SETTINGS_ICON,
            controls = {
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = "submenu",
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_GUIDE_SUBMENU),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_GUIDE_SUBMENU_TT),
                    controls = {
                        {
                            type = "description",
                            text = GetString(SI_FOXUC_CONTEXT_SPEED_GUIDE_TEXT),
                            width = "full",
                        },
                    },
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {                                                    -- Separate In/Out Toggle
                    type = checkboxType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_SEPARATE_IN_OUT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_SEPARATE_IN_OUT_TT),
                    getFunc = function()
                        if addon and addon.IsSeparateInOutEnabled then
                            return addon:IsSeparateInOutEnabled()
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.SetSeparateInOutEnabled then
                            addon:SetSeparateInOutEnabled(value)
                        end
                    end,
                    default = (function()
                        if addon and addon.GetSeparateInOutDefault then
                            return addon:GetSeparateInOutDefault()
                        end
                        return false
                    end)(),
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                -- Combat
                {
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_COMBAT),
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_COMBAT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_COMBAT_TT),
                    getFunc = function()
                        if addon and addon.GetContextCombatSpeed then
                            return addon:GetContextCombatSpeed()
                        end
                        return 1.25
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextCombatSpeed then
                            addon:SetContextCombatSpeed(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedCombatOut")) or 1.25
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled()
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_COMBAT_IN),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_COMBAT_IN_TT),
                    getFunc = function()
                        if addon and addon.GetContextCombatSpeedIn then
                            return addon:GetContextCombatSpeedIn()
                        end
                        return 1.25
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextCombatSpeedIn then
                            addon:SetContextCombatSpeedIn(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedCombatIn")) or 1.0
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_COMBAT_OUT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_COMBAT_OUT_TT),
                    getFunc = function()
                        if addon and addon.GetContextCombatSpeed then
                            return addon:GetContextCombatSpeed()
                        end
                        return 1.25
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextCombatSpeedOut then
                            addon:SetContextCombatSpeedOut(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedCombatOut")) or 1.25
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                },
                -- Stealth
                {
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_STEALTH),
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_STEALTH),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_STEALTH_TT),
                    getFunc = function()
                        if addon and addon.GetContextStealthSpeed then
                            return addon:GetContextStealthSpeed()
                        end
                        return 1.5
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextStealthSpeed then
                            addon:SetContextStealthSpeed(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedStealthOut")) or 1.5
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled()
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_STEALTH_IN),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_STEALTH_IN_TT),
                    getFunc = function()
                        if addon and addon.GetContextStealthSpeedIn then
                            return addon:GetContextStealthSpeedIn()
                        end
                        return 1.5
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextStealthSpeedIn then
                            addon:SetContextStealthSpeedIn(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedStealthIn")) or 1.0
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_STEALTH_OUT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_STEALTH_OUT_TT),
                    getFunc = function()
                        if addon and addon.GetContextStealthSpeed then
                            return addon:GetContextStealthSpeed()
                        end
                        return 1.5
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextStealthSpeedOut then
                            addon:SetContextStealthSpeedOut(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedStealthOut")) or 1.5
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                },
                -- Mounted
                {
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_MOUNTED),
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_MOUNTED),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_MOUNTED_TT),
                    getFunc = function()
                        if addon and addon.GetContextMountedSpeed then
                            return addon:GetContextMountedSpeed()
                        end
                        return 1.4
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextMountedSpeed then
                            addon:SetContextMountedSpeed(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedMountedOut")) or 1.4
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and addon:IsSeparateInOutEnabled()
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_MOUNTED_IN),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_MOUNTED_IN_TT),
                    getFunc = function()
                        if addon and addon.GetContextMountedSpeedIn then
                            return addon:GetContextMountedSpeedIn()
                        end
                        return 1.4
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextMountedSpeedIn then
                            addon:SetContextMountedSpeedIn(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedMountedIn")) or 1.0
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SPEED_MOUNTED_OUT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SPEED_MOUNTED_OUT_TT),
                    getFunc = function()
                        if addon and addon.GetContextMountedSpeed then
                            return addon:GetContextMountedSpeed()
                        end
                        return 1.4
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextMountedSpeedOut then
                            addon:SetContextMountedSpeedOut(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.5,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSpeedMountedOut")) or 1.4
                    end)(),
                    disabled = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                    hidden = function()
                        return addon and addon.IsSeparateInOutEnabled and not addon:IsSeparateInOutEnabled()
                    end,
                },
            },
        },

        -- Остальные подменю оставляем как были
        {
            type = "submenu",
            name = function()
                -- Count: Module enabled
                local count = 0
                local total = 1
                if addon and addon.IsContextSensitivityEnabled and addon:IsContextSensitivityEnabled() then count = count + 1 end
                local color = count > 0 and "|c6AA84F" or "|c555555"
                return string.format("%s%d/%d|r %s", color, count, total, GetString(SI_FOXUC_CONTEXT_SENSITIVITY_SUBMENU))
            end,
            tooltip = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_SUBMENU_TT),
            icon = CONTEXT_SENSITIVITY_SETTINGS_ICON,
            controls = {
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = "submenu",
                    name = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_SUBMENU),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_SUBMENU_TT),
                    controls = {
                        {
                            type = "description",
                            text = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_TEXT),
                            width = "full",
                        },
                    },
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {                                                    -- Enable context sensitivity
                    type = checkboxType,
                    name = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_ENABLED),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_ENABLED_TT),
                    getFunc = function()
                        if addon and addon.IsContextSensitivityEnabled then
                            return addon:IsContextSensitivityEnabled()
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextSensitivityEnabled then
                            addon:SetContextSensitivityEnabled(value)
                        end
                    end,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSensitivityEnabled")) or false
                    end)(),
                    requiresRefresh = false,
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {                                                    -- Combat sensitivity
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_COMBAT),
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_COMBAT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_COMBAT_TT),
                    getFunc = function()
                        if addon and addon.GetContextSensitivityCombat then
                            return addon:GetContextSensitivityCombat()
                        end
                        return 1.0
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextSensitivityCombat then
                            addon:SetContextSensitivityCombat(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.0,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSensitivityCombat")) or 1.0
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return addon and addon.IsContextSensitivityEnabled and not addon:IsContextSensitivityEnabled()
                    end,
                },
                { -- Mounted sensitivity
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_MOUNTED),
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_MOUNTED),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_MOUNTED_TT),
                    getFunc = function()
                        if addon and addon.GetContextSensitivityMounted then
                            return addon:GetContextSensitivityMounted()
                        end
                        return 1.0
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextSensitivityMounted then
                            addon:SetContextSensitivityMounted(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.0,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSensitivityMounted")) or 1.0
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return addon and addon.IsContextSensitivityEnabled and not addon:IsContextSensitivityEnabled()
                    end,
                },
                { -- Sprint sensitivity
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_SPRINT),
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_SPRINT),
                    tooltip = GetString(SI_FOXUC_CONTEXT_SENSITIVITY_SPRINT_TT),
                    getFunc = function()
                        if addon and addon.GetContextSensitivitySprint then
                            return addon:GetContextSensitivitySprint()
                        end
                        return 1.0
                    end,
                    setFunc = function(value)
                        if addon and addon.SetContextSensitivitySprint then
                            addon:SetContextSensitivitySprint(value)
                        end
                    end,
                    min = 0.5,
                    max = 3.0,
                    step = 0.05,
                    decimals = 2,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("contextSensitivitySprint")) or 1.0
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return addon and addon.IsContextSensitivityEnabled and not addon:IsContextSensitivityEnabled()
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = function()
                -- Count: Interiors, Combat, Mount (only if master toggle is ON)
                local count = 0
                local total = 3
                if addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled then
                    if addon.savedVars.firstPersonAutoInteriors then count = count + 1 end
                    if addon.savedVars.firstPersonAutoCombat then count = count + 1 end
                    if addon.savedVars.firstPersonAutoMount then count = count + 1 end
                end
                local color = count > 0 and "|c6AA84F" or "|c555555"
                return string.format("%s%d/%d|r %s", color, count, total, GetString(SI_FOXUC_FIRST_PERSON_AUTO_SUBMENU))
            end,
            tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_SUBMENU_TT),
            icon = FIRST_PERSON_AUTO_SETTINGS_ICON,
            controls = {
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = "submenu",
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_SUBMENU),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_SUBMENU_TT),
                    controls = {
                        {
                            type = "description",
                            text = GetString(SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_TEXT),
                            width = "full",
                        },
                    },
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_ENABLED),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_ENABLED_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoEnabled and true or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoEnabled = value and true or false
                        end
                    end,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("firstPersonAutoEnabled")) or false
                    end)(),
                    requiresRefresh = false,
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_INTERIORS),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_INTERIORS_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoInteriors and true or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoInteriors = value and true or false
                        end
                    end,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_COMBAT),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoCombat and true or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoCombat = value and true or false
                        end
                    end,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_MOUNT),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_MOUNT_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoMount and true or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoMount = value and true or false
                        end
                    end,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_IGNORE_PVP),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_IGNORE_PVP_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoIgnorePvp ~= false
                        end
                        return true
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoIgnorePvp = value and true or false
                        end
                    end,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_RESPECT_MANUAL),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_RESPECT_MANUAL_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoRespectManual ~= false
                        end
                        return true
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoRespectManual = value and true or false
                        end
                    end,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_ENTER_DELAY),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_ENTER_DELAY_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoEnterDelay or 0.5
                        end
                        return 0.5
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoEnterDelay = value
                        end
                    end,
                    min = 0,
                    max = 3,
                    step = 0.1,
                    decimals = 1,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("firstPersonAutoEnterDelay")) or 0.5
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_EXIT_DELAY),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_EXIT_DELAY_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoExitDelay or 0.5
                        end
                        return 0.5
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoExitDelay = value
                        end
                    end,
                    min = 0,
                    max = 3,
                    step = 0.1,
                    decimals = 1,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("firstPersonAutoExitDelay")) or 0.5
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_CHAIN_TIMEOUT),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_CHAIN_TIMEOUT_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoCombatChainTimeout or 6
                        end
                        return 6
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoCombatChainTimeout = value
                        end
                    end,
                    min = 0,
                    max = 15,
                    step = 0.5,
                    decimals = 1,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("firstPersonAutoCombatChainTimeout"))
                            or 6
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled and
                            addon.savedVars.firstPersonAutoCombat)
                    end,
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_WEAPON_SHEATHING_ENABLED),
                    tooltip = GetString(SI_FOXUC_WEAPON_SHEATHING_ENABLED_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.autoSheathEnabled and true or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.autoSheathEnabled = value and true or false
                        end
                    end,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("autoSheathEnabled")) or false
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_WEAPON_SHEATHING_IGNORE_PVP),
                    tooltip = GetString(SI_FOXUC_WEAPON_SHEATHING_IGNORE_PVP_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.autoSheathIgnorePvp ~= false
                        end
                        return true
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.autoSheathIgnorePvp = value and true or false
                        end
                    end,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("autoSheathIgnorePvp")) or true
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled and
                            addon.savedVars.autoSheathEnabled)
                    end,
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_WEAPON_SHEATHING_ON_EMOTE),
                    tooltip = GetString(SI_FOXUC_WEAPON_SHEATHING_ON_EMOTE_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.autoSheathOnEmote ~= false
                        end
                        return true
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.autoSheathOnEmote = value and true or false
                        end
                    end,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("autoSheathOnEmote")) or true
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled and
                            addon.savedVars.autoSheathEnabled)
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_WEAPON_SHEATHING_DELAY),
                    tooltip = GetString(SI_FOXUC_WEAPON_SHEATHING_DELAY_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.autoSheathDelay or 2
                        end
                        return 2
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.autoSheathDelay = value
                        end
                    end,
                    min = 0,
                    max = 10,
                    step = 0.5,
                    decimals = 1,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("autoSheathDelay")) or 2
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled and
                            addon.savedVars.autoSheathEnabled)
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_FIRST_PERSON_AUTO_MANUAL_TIMEOUT),
                    tooltip = GetString(SI_FOXUC_FIRST_PERSON_AUTO_MANUAL_TIMEOUT_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.firstPersonAutoManualTimeout or 10
                        end
                        return 10
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.firstPersonAutoManualTimeout = value
                        end
                    end,
                    min = 0,
                    max = 60,
                    step = 1,
                    decimals = 0,
                    default = (function()
                        return (addon and addon.GetDefault and addon:GetDefault("firstPersonAutoManualTimeout")) or 10
                    end)(),
                    requiresRefresh = false,
                    disabled = function()
                        return not (addon and addon.savedVars and addon.savedVars.firstPersonAutoEnabled)
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = function()
                -- Count: Smoothing, Indicator, Smart Mode
                local count = 0
                local total = 3
                if addon and addon.savedVars then
                    if addon.savedVars.offsetSmoothingEnabled then count = count + 1 end
                    if addon.savedVars.cameraOffsetIndicatorEnabled ~= false then count = count + 1 end
                    if addon.savedVars.shoulderSwapSmartMode then count = count + 1 end
                end
                local color = count > 0 and "|c6AA84F" or "|c555555"
                return string.format("%s%d/%d|r %s", color, count, total, GetString(SI_FOXUC_CAMERA_OFFSET_SUBMENU))
            end,
            tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_SUBMENU_TT),
            icon = CAMERA_OFFSET_SETTINGS_ICON,
            controls = {
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = "submenu",
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_GUIDE_SUBMENU),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_GUIDE_SUBMENU_TT),
                    controls = {
                        {
                            type = "description",
                            text = GetString(SI_FOXUC_CAMERA_OFFSET_GUIDE_TEXT),
                            width = "full",
                        },
                    },
                },
                {
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_SMOOTHING),
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_SMOOTHING),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_SMOOTHING_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.offsetSmoothingEnabled and true or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.offsetSmoothingEnabled = value and true or false
                        end
                    end,
                    default = false,
                    requiresRefresh = false,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_SMOOTHING_SPEED),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_SMOOTHING_SPEED_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.offsetSmoothingSpeed or 10
                        end
                        return 10
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.offsetSmoothingSpeed = value
                        end
                    end,
                    min = 1,
                    max = 20,
                    step = 0.5,
                    decimals = 1,
                    default = 10,
                    requiresRefresh = false,
                    disabled = function()
                        if addon and addon.savedVars then
                            return not addon.savedVars.offsetSmoothingEnabled
                        end
                        return true
                    end,
                },
                {
                    type = "header",
                    name = GetString(SI_FOXUC_HEADER_INDICATOR),
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_INDICATOR_ENABLED),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_INDICATOR_ENABLED_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.cameraOffsetIndicatorEnabled ~= false
                        end
                        return true
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.cameraOffsetIndicatorEnabled = value
                        end
                    end,
                    default = true,
                    requiresRefresh = false,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_INDICATOR_DELAY),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_INDICATOR_DELAY_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.cameraOffsetIndicatorDelay or 3
                        end
                        return 3
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.cameraOffsetIndicatorDelay = value
                        end
                    end,
                    min = 1,
                    max = 10,
                    step = 1,
                    decimals = 0,
                    default = 3,
                    requiresRefresh = false,
                    disabled = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.cameraOffsetIndicatorEnabled == false
                        end
                        return false
                    end,
                },
                -- Shoulder Swap settings
                {
                    type = "header",
                    name = GetString(SI_FOXUC_SHOULDER_SWAP_HEADER),
                },
                {
                    type = checkboxType,
                    name = GetString(SI_FOXUC_SHOULDER_SWAP_SMART_MODE),
                    tooltip = GetString(SI_FOXUC_SHOULDER_SWAP_SMART_MODE_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.shoulderSwapSmartMode or false
                        end
                        return false
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.shoulderSwapSmartMode = value
                        end
                    end,
                    default = addon:GetDefault("shoulderSwapSmartMode"),
                    requiresRefresh = true,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_SHOULDER_SWAP_LEFT_VALUE),
                    tooltip = GetString(SI_FOXUC_SHOULDER_SWAP_LEFT_VALUE_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.shoulderSwapLeftValue or -1.0
                        end
                        return -1.0
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.shoulderSwapLeftValue = value
                        end
                    end,
                    min = -1.0,
                    max = 0,
                    step = 0.05,
                    decimals = 2,
                    default = addon:GetDefault("shoulderSwapLeftValue"),
                    requiresRefresh = false,
                    disabled = function()
                        return addon and addon.savedVars and addon.savedVars.shoulderSwapSmartMode
                    end,
                },
                {
                    type = sliderType,
                    name = GetString(SI_FOXUC_SHOULDER_SWAP_RIGHT_VALUE),
                    tooltip = GetString(SI_FOXUC_SHOULDER_SWAP_RIGHT_VALUE_TT),
                    getFunc = function()
                        if addon and addon.savedVars then
                            return addon.savedVars.shoulderSwapRightValue or 1.0
                        end
                        return 1.0
                    end,
                    setFunc = function(value)
                        if addon and addon.savedVars then
                            addon.savedVars.shoulderSwapRightValue = value
                        end
                    end,
                    min = 0,
                    max = 1.0,
                    step = 0.05,
                    decimals = 2,
                    default = addon:GetDefault("shoulderSwapRightValue"),
                    requiresRefresh = false,
                    disabled = function()
                        return addon and addon.savedVars and addon.savedVars.shoulderSwapSmartMode
                    end,
                },
                { type = "description", text = "", width = "full" }, -- Spacer | Do not remove
                {
                    type = "button",
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_RESTORE_ORIGINAL),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_RESTORE_ORIGINAL_TT),
                    func = function()
                        if addon and addon.modules and addon.modules.CameraOffset then
                            addon.modules.CameraOffset.RestoreOriginalSettings()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = GetString(SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL),
                    tooltip = GetString(SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_TT),
                    func = function()
                        ZO_Dialogs_ShowDialog("FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_CONFIRM")
                    end,
                    width = "full",
                    warning = GetString(SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_WARNING),
                },
            },
        },
        { type = "divider", alpha = 0 }, -- Spacer | Do not remove
        {                                -- Debug toggle
            type = checkboxType,
            name = GetString(SI_FOXUC_DEBUG_TOGGLE),
            tooltip = GetString(SI_FOXUC_DEBUG_TOGGLE_TT),
            getFunc = function()
                return addon:IsDebugEnabled()
            end,
            setFunc = function(value)
                addon:SetDebugEnabled(value)
            end,
            default = (function()
                return (addon and addon.GetDefault and addon:GetDefault("debugEnabled")) or false
            end)(),
            requiresRefresh = false,
            warning = GetString(SI_FOXUC_DEBUG_WARNING),
        },
        { type = "divider", alpha = 0 }, -- Spacer | Do not remove
    }
end

function SettingsMenu:Initialize(addon)
    if self.initialized then
        return
    end

    self.addon = addon

    RegisterDialogs(addon)

    if not LAM then
        if addon and addon.IsDebugEnabled and addon:IsDebugEnabled() then
            d("[FOXUltimateCamera] LibAddonMenu-2.0 not found, settings will not be available.")
        end
        return
    end

    local panelData = GetPanelData(addon)
    self.panel = LAM:RegisterAddonPanel("FOXUltimateCamera_SettingsPanel", panelData)
    local optionsTable = GetOptionsTable(addon)
    LAM:RegisterOptionControls("FOXUltimateCamera_SettingsPanel", optionsTable)

    self.initialized = true
end

function SettingsMenu:Shutdown()
    self.addon = nil
    self.panel = nil
    self.initialized = false
end

FOXUltimateCamera = FOXUltimateCamera or {}
local FOXUC = FOXUltimateCamera
FOXUC.modules = FOXUC.modules or {}

if not FOXUC.modules.settings then
    FOXUC.modules.settings = SettingsMenu:New()
end
