-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

-- Main
ZO_CreateStringId("SI_FOXUC_ADDON_NAME", "FOX Ultimate Camera")
ZO_CreateStringId("SI_FOXUC_SLASH_COMMAND", "/foxuc")
ZO_CreateStringId("SI_FOXUC_MAIN_CATEGORY", "Main Camera Settings")

-- Debug
ZO_CreateStringId("SI_FOXUC_DEBUG_TOGGLE", "Enable Debug Mode")
ZO_CreateStringId("SI_FOXUC_DEBUG_TOGGLE_TT", "Show debug messages in chat when switching camera views (first/third person).")
ZO_CreateStringId("SI_FOXUC_DEBUG_WARNING", "Debug mode can spam your chat with technical information.")

-- Toggle mode
ZO_CreateStringId("SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM", "Controlled View Toggle")
ZO_CreateStringId("SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM_WARNING", "|cFFD700Warning:|r In this mode, the transition between views will not be instant, as the addon smoothly animates the zoom, unlike the default game behavior.")
ZO_CreateStringId("SI_FOXUC_TOGGLE_MODE_CONTROLLED_ZOOM_TT", "If enabled, the view toggle key will cycle the camera between your saved third-person position and first-person view.\n\n|cFFD700Warning:|r In this mode, the transition between views will not be instant, as the addon smoothly animates the zoom, unlike the default game behavior.\n\nIf disabled, the key will use the game's default behavior, and the addon will only track the switch without changing the zoom level.")

-- Zoom distance
ZO_CreateStringId("SI_FOXUC_MAX_ZOOM_DISTANCE", "Max Zoom Distance")
ZO_CreateStringId("SI_FOXUC_MAX_ZOOM_DISTANCE_TT", "Sets the maximum distance you can zoom out the camera in third-person view. This limit applies to all zoom methods (mouse wheel, keys, addon transitions).")

-- Zoom step
ZO_CreateStringId("SI_FOXUC_ZOOM_STEP", "Zoom Step")
ZO_CreateStringId("SI_FOXUC_ZOOM_STEP_TT", "Determines how much the camera zoom changes with a single action (e.g., one mouse wheel click). Smaller values offer finer, smoother control, while larger values allow for faster zooming in/out.")

-- Zoom smoothing
ZO_CreateStringId("SI_FOXUC_ZOOM_SMOOTHING", "Zoom Smoothing")
ZO_CreateStringId("SI_FOXUC_ZOOM_SMOOTHING_TT", "If enabled, the camera will smoothly transition to the new zoom distance. If disabled, the change is instantaneous.")

-- Zoom speed
ZO_CreateStringId("SI_FOXUC_ZOOM_SPEED", "Zoom Speed")
ZO_CreateStringId("SI_FOXUC_ZOOM_SPEED_TT", "Controls the speed of the smooth camera transition when smoothing is enabled. Lower values result in a slow, gentle transition. Higher values make the zoom faster and more responsive.")

-- Field of View
ZO_CreateStringId("SI_FOXUC_FOV_FIRST_PERSON", "Field of View (1st Person)")
ZO_CreateStringId("SI_FOXUC_FOV_FIRST_PERSON_TT", "Adjusts the field of view in first-person mode. The slider uses a 70–130 range, which corresponds to the game's internal FOV value of 35–65.")
ZO_CreateStringId("SI_FOXUC_FOV_THIRD_PERSON", "Field of View (3rd Person)")
ZO_CreateStringId("SI_FOXUC_FOV_THIRD_PERSON_TT", "Adjusts the field of view in third-person mode. The slider uses a 70–130 range, which corresponds to the game's internal FOV value of 35–65.")
ZO_CreateStringId("SI_FOXUC_FOV_RESTORE_ORIGINAL", "Restore Original FOV")
ZO_CreateStringId("SI_FOXUC_FOV_RESTORE_ORIGINAL_TT", "Restores the original field of view values for both first and third-person, saved when the addon was first run.")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING", "FOV Smoothing")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING_TT", "If enabled, field of view changes will be applied smoothly, not instantly.")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING_SPEED", "FOV Smoothing Speed")
ZO_CreateStringId("SI_FOXUC_FOV_SMOOTHING_SPEED_TT", "Determines how quickly the field of view transitions to the target value. Higher values result in a faster transition.")

-- Zoom settings submenu
ZO_CreateStringId("SI_FOXUC_ZOOM_SUBMENU", "Zoom Settings")
ZO_CreateStringId("SI_FOXUC_ZOOM_SUBMENU_TT", "Main zoom parameters: max distance, step, smoothing, and speed.")

-- Contextual FOV
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_HEADER", "Contextual FOV")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_ENABLED", "Contextual Field of View (FOV)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_ENABLED_TT", "Automatically changes the field of view based on the situation: in combat, on a mount, or in interiors.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_IGNORE_PVP", "Ignore PvP Zones")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_IGNORE_PVP_TT", "If enabled, contextual FOV will not apply in PvP locations (Cyrodiil, Battlegrounds).")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_FIRST", "FOV in Combat (1st Person)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_FIRST_TT", "Target field of view for first-person mode while in combat. Uses a 70–130 range, just like the standard camera settings.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_THIRD", "FOV in Combat (3rd Person)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_COMBAT_THIRD_TT", "Target field of view for third-person mode while in combat. Uses a 70–130 range, just like the standard camera settings.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_FIRST", "FOV on Mount (1st Person)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_FIRST_TT", "Target field of view for first-person mode while mounted. Uses a 70–130 range, just like the standard camera settings.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_THIRD", "FOV on Mount (3rd Person)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_MOUNTED_THIRD_TT", "Target field of view for third-person mode while mounted. Uses a 70–130 range, just like the standard camera settings.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_FIRST", "FOV in Interiors (1st Person)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_FIRST_TT", "Target field of view for first-person mode in interiors (houses/dungeons). Uses a 70–130 range, just like the standard camera settings.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_THIRD", "FOV in Interiors (3rd Person)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_FOV_INTERIOR_THIRD_TT", "Target field of view for third-person mode in interiors (houses/dungeons). Uses a 70–130 range, just like the standard camera settings.")
-- Contextual FOV headers
ZO_CreateStringId("SI_FOXUC_HEADER_COMBAT_FOV", "Combat FOV")
ZO_CreateStringId("SI_FOXUC_HEADER_MOUNTED_FOV", "Mounted FOV")
ZO_CreateStringId("SI_FOXUC_HEADER_INTERIOR_FOV", "Interior FOV")

-- Context speed submenu
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SUBMENU", "Contextual Zoom Speed")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SUBMENU_TT", "Adjust zoom speed for different situations: in combat, in stealth, or while mounted.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SEPARATE_IN_OUT", "Separate Zoom In/Out Speed")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_SEPARATE_IN_OUT_TT", "If enabled, you can set different speeds for zooming in and out for each state (combat, stealth, mounted). If disabled, a single slider will be used for both directions.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT", "Combat Zoom Speed")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_TT", "Multiplier for zoom speed while in combat. Values below 1 slow it down, values above 1 speed it up.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH", "Stealth Zoom Speed")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_TT", "Multiplier for zoom speed while you are in stealth.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED", "Mounted Zoom Speed")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_TT", "Multiplier for zoom speed while you are mounted.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_IN", "Combat Zoom Speed (In)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_IN_TT", "Multiplier for zoom speed when zooming in while in combat.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_OUT", "Combat Zoom Speed (Out)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_COMBAT_OUT_TT", "Multiplier for zoom speed when zooming out while in combat.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_IN", "Stealth Zoom Speed (In)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_IN_TT", "Multiplier for zoom speed when zooming in while in stealth.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_OUT", "Stealth Zoom Speed (Out)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_STEALTH_OUT_TT", "Multiplier for zoom speed when zooming out while in stealth.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_IN", "Mounted Zoom Speed (In)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_IN_TT", "Multiplier for zoom speed when zooming in while mounted.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_OUT", "Mounted Zoom Speed (Out)")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_MOUNTED_OUT_TT", "Multiplier for zoom speed when zooming out while mounted.")
-- Context Speed headers
ZO_CreateStringId("SI_FOXUC_HEADER_COMBAT", "Combat")
ZO_CreateStringId("SI_FOXUC_HEADER_STEALTH", "Stealth")
ZO_CreateStringId("SI_FOXUC_HEADER_MOUNTED", "Mounted")
ZO_CreateStringId("SI_FOXUC_HEADER_SPRINT", "Sprint")

-- Zoom Settings Guide
ZO_CreateStringId("SI_FOXUC_ZOOM_GUIDE_SUBMENU", "Guide: Zoom Settings")
ZO_CreateStringId("SI_FOXUC_ZOOM_GUIDE_SUBMENU_TT", "A detailed explanation of all zoom parameters in this section.")
ZO_CreateStringId("SI_FOXUC_ZOOM_GUIDE_TEXT", "|cFFFFCCMax Distance:|r Sets the upper limit for how far you can zoom out in third-person view. Any attempt to zoom beyond this point will be clamped.\n\n|cFFFFCCZoom Step:|r Determines how much the camera distance changes with a single action (e.g., a mouse wheel click). This step is used for both instant and smooth zooming.\n\n|cFFFFCCSmoothing:|r Toggles between instant zoom changes and a smooth, animated transition. When enabled, the camera glides to the new distance instead of jumping.\n\n|cFFFFCCSpeed:|r Controls how fast the smooth transition is. Higher values mean a quicker change, while lower values make it slower.\n\n|cFFFFCCControlled View Toggle:|r When enabled, the view toggle key will use the addon's zoom system to switch between your saved third-person distance and first-person view, replacing the default game behavior.")

-- Contextual Speed Guide
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_GUIDE_SUBMENU", "Guide: Contextual Speed")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_GUIDE_SUBMENU_TT", "A detailed explanation of all contextual zoom speed parameters.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SPEED_GUIDE_TEXT", "|cFFFFCCBase Speed:|r The global multiplier that sets the default zoom speed.\n\n|cFFFFCCSeparate In/Out Speed:|r If enabled, you can set different multipliers for zooming in and zooming out. If disabled, a single slider controls both directions simultaneously.\n\n|cFFFFCCContextual Multipliers:|r Additional multipliers for combat, stealth, and while mounted. Only one context is active at a time. Priority: |cFFFFCCMounted|r > |cFFFFCCCombat|r > |cFFFFCCStealth|r.\n\n|cFFFFCCOverall Effect:|r These multipliers apply to both the zoom step and the smooth transition speed. They directly control how quickly the camera moves towards or away from your character in each state.")

-- Context Sensitivity submenu
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SUBMENU", "Context Sensitivity")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SUBMENU_TT", "Adjust mouse sensitivity for camera rotation in different situations: combat, mounted, and sprinting.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_ENABLED", "Enable Context Sensitivity")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_ENABLED_TT", "Enables or disables automatic camera sensitivity changes based on your character's state. When disabled, this feature has no effect.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_COMBAT", "Combat Sensitivity")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_COMBAT_TT", "Mouse sensitivity multiplier for camera rotation while in combat. Values below 1.0 slow it down, values above 1.0 speed it up.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_MOUNTED", "Mounted Sensitivity")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_MOUNTED_TT", "Mouse sensitivity multiplier for camera rotation while you are mounted.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SPRINT", "Sprint Sensitivity")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_SPRINT_TT", "Mouse sensitivity multiplier for camera rotation while sprinting.")

-- Context Sensitivity Guide
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_SUBMENU", "Guide: Context Sensitivity")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_SUBMENU_TT", "A detailed explanation of all context sensitivity settings.")
ZO_CreateStringId("SI_FOXUC_CONTEXT_SENSITIVITY_GUIDE_TEXT", "|cFFFFCCWhat it is:|r Context sensitivity changes the speed of camera rotation (mouse movement) depending on your character's state.\n\n|cFFFFCCMultipliers:|r Each state (Combat, Mounted, Sprint) has its own multiplier. 1.0 is the default sensitivity. Below 1.0 is slower, above 1.0 is faster.\n\n|cFFFFCCPriority:|r If multiple states are active at once, the following priority is applied: |cFFFFCCMounted|r > |cFFFFCCCombat|r > |cFFFFSprint|r.\n\n|cFFFFCCApplication:|r Multipliers affect the camera's rotation speed when moving the mouse left, right, up, and down.")

-- Camera Offset submenu
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SUBMENU", "Camera Offset")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SUBMENU_TT", "Dynamically adjust the camera position with hotkeys. Save and load position presets.")

-- Camera Offset settings
ZO_CreateStringId("SI_FOXUC_HEADER_SMOOTHING", "Smoothing")
ZO_CreateStringId("SI_FOXUC_HEADER_INDICATOR", "Indicator")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_ENABLED", "Show UI Indicator")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_ENABLED_TT", "Displays the current camera offset values on screen while adjusting the position.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_DELAY", "Indicator Hide Delay")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_DELAY_TT", "How long to show the offset indicator after the last adjustment (in seconds).")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_RESTORE_ORIGINAL", "Restore Original Settings")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_RESTORE_ORIGINAL_TT", "Resets the camera position to the original values saved when the module was first activated.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL", "Update Original Settings")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_TT", "Saves the current camera position as the new 'original' settings. This will overwrite the previously saved values.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_WARNING", "|cFFA500Warning:|r This will overwrite the original camera settings.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_UPDATE_ORIGINAL_WARNING_CONFIRM", "This will overwrite the original camera settings. Continue?")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_CURRENT_VALUES", "Current Offset")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_ORIGINAL_VALUES", "Saved Original")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_INDICATOR_TEXT", "Camera Offset: X: %+.2f  Y: %+.2f  -  Zoom: %.1f")

-- Shoulder Swap
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_HEADER", "Shoulder Swap")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_SMART_MODE", "Smart Mode")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_SMART_MODE_TT", "Dynamically mirrors the camera's X-axis position, adapting to your changes in real-time instead of using fixed values.")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_LEFT_VALUE", "Left Shoulder Offset")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_LEFT_VALUE_TT", "The camera's X-axis position for the view over the left shoulder.")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_RIGHT_VALUE", "Right Shoulder Offset")
ZO_CreateStringId("SI_FOXUC_SHOULDER_SWAP_RIGHT_VALUE_TT", "The camera's X-axis position for the view over the right shoulder.")

-- Camera Offset keybindings
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_LEFT", "Camera Left")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_RIGHT", "Camera Right")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_UP", "Camera Up")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_DOWN", "Camera Down")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_CAMERA_RESET", "Reset to Center")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SHOULDER_SWAP", "Shoulder Swap")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SAVE_PRESET_1", "Save Preset 1")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SAVE_PRESET_2", "Save Preset 2")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_SAVE_PRESET_3", "Save Preset 3")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_LOAD_PRESET_1", "Load Preset 1")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_LOAD_PRESET_2", "Load Preset 2")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_LOAD_PRESET_3", "Load Preset 3")
ZO_CreateStringId("SI_BINDING_NAME_FOXUC_RESTORE_ORIGINAL", "Restore Original")

-- Camera Offset Guide
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_GUIDE_SUBMENU", "Guide: Camera Offset")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_GUIDE_SUBMENU_TT", "A detailed explanation of camera offset controls and features.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_GUIDE_TEXT", "|cFFFFCCWhat it is:|r Camera offset allows you to adjust the horizontal (X) and vertical (Y) position of the camera in real-time using hotkeys.\n\n|cFFFFCCHotkeys:|r Set up bindings in Controls > Add-on Keybindings. Use Left/Right/Up/Down to move the camera. A single press is a small step, holding it down moves continuously.\n\n|cFFFFCCPresets:|r Save up to 3 camera position presets (including zoom level). Quickly restore your favorite camera angles with a single keypress.\n\n|cFFFFCCOriginal Settings:|r Your camera settings are automatically saved when you first activate the module. Use 'Restore Original' to undo all changes.\n\n|cFFFFCCLimitations:|r The offset range is limited by ESO's native camera settings. The available range depends on the current zoom level.")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING", "Enable Smoothing")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING_TT", "When enabled, the camera will smoothly transition to the new offset position (when loading a preset or restoring).")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING_SPEED", "Smoothing Speed")
ZO_CreateStringId("SI_FOXUC_CAMERA_OFFSET_SMOOTHING_SPEED_TT", "Determines the speed of the camera's smooth transition to the new position.")

-- Main camera section
ZO_CreateStringId("SI_FOXUC_CAMERA_SECTION_DESC", "It expands zoom and smoothing limits, allows you to offset the camera horizontally and vertically, save multiple position and distance presets, automatically adjust FOV and camera speed/sensitivity based on context (combat, mount, stealth), and also includes more immersive dialog camera modes.")

-- First-Person Auto Mode
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_SUBMENU", "First-Person Auto Mode")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_SUBMENU_TT", "Automatically switches the view between first and third person based on the situation: interiors, combat, mount.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENABLED", "Enable Auto Mode")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENABLED_TT", "When enabled, the addon will automatically switch the camera to first-person and back to third-person based on the conditions below.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_INTERIORS", "In Interiors")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_INTERIORS_TT", "Automatically switch to first-person view when you are in a house or a dungeon instance.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT", "In Combat")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_TT", "Automatically switch to first-person view when you enter combat, and return to third-person view after it ends.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MOUNT", "On Mount")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MOUNT_TT", "Automatically switch to first-person view when you mount up, and return to third-person view after dismounting.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_IGNORE_PVP", "Ignore PvP Zones")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_IGNORE_PVP_TT", "If enabled, auto-mode will not change the camera in PvP locations (Cyrodiil, Battlegrounds).")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_ENABLED", "Enable Immersive Mode")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_HEADER", "|cE5FBC8Immersive Mode|r")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_DESC", "Preserves camera position during dialogues and interactions.\nPrevents abrupt viewpoint changes caused by both the game and the addon.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_STATUS_ON", "|c00FF00ACTIVE|r")
ZO_CreateStringId("SI_FOXUC_IMMERSION_MODE_STATUS_OFF", "|cFF6666OFF|r")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_ENABLED_TT", "Prevents abrupt camera changes from both the addon and the game's dialogue camera during world interactions.\n\n|cFFFFCCHow it works:|r\n- |cFFFFFFFree Dialog Camera:|r For most NPC conversations, book reading, and simple interactions, the game's dialogue camera is disabled - the view stays as it was when the interaction started. Service interfaces (bank, guild store, guild bank, house stores, crafting stations, wayshrines, mount stables, etc.) retain the default camera behavior.\n- |cFFFFFFFreeze Addon Logic:|r During any interaction, the addon temporarily \"freezes\" its camera-controlling features. Your current view and camera settings are preserved until the interaction is complete, then gently restored.\n\n|cFFFFCCImpact on FOX Ultimate Camera features:|r\n- |cFFFFFFAuto First-Person Mode:|r Temporarily disabled. The camera will not switch until you finish the interaction.\n- |cFFFFFFContextual FOV:|r If a context (e.g., combat) was active, the FOV first reverts to the base value and will not change during the interaction. After the interaction ends, the FOV smoothly transitions back to the contextual value.\n- |cFFFFFFContextual Speed/Sensitivity:|r Temporarily disabled. The camera uses base speed and sensitivity values from the settings. After the interaction, the correct multipliers are reapplied.")
-- Interaction Camera Exceptions
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_SUBMENU", "Interaction Camera Exceptions")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTIONS_SUBMENU_TT", "Choose which interaction types keep the default game camera instead of Free Dialog Camera.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ENTRY_TT", "If enabled, this interaction type keeps the default game camera (no Free Dialog Camera override). If disabled, the addon will try to keep your current view.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_PREVIEW_GUIDE_SUBMENU", "Guide: Immersive Mode & Preview")
ZO_CreateStringId("SI_FOXUC_IMMERSION_PREVIEW_GUIDE_SUBMENU_TT", "Explains how Immersive Mode interacts with item previews and why some services are excluded by default.")
ZO_CreateStringId("SI_FOXUC_IMMERSION_PREVIEW_GUIDE_TEXT", "|cFFFFCCFree Dialog Camera vs. Service Interfaces:|r Immersive Mode is primarily designed for NPC conversations, book reading, and simple interactions where preserving your current viewpoint is key.\n\nService interfaces - like merchants, guild stores, banks, armories, and stables - rely on the default game camera and scenes to correctly display item and 3D model previews. If you force-enable 'Free Dialog Camera' for these windows, the preview might work incorrectly or not at all.\n\n|cFFFFCCDialog Camera Exceptions:|r In the list above, you can choose which interaction types always use the default camera. |cFFFFFFRecommendation:|r Keep all trading, banking, housing, armory, stable, and antiquity systems enabled to ensure the preview works as it does in the vanilla game.\n\nIf you disable these exceptions, you get a more aggressive style camera, but you might partially lose the familiar preview functionality.")

-- Immersive interaction types (service interfaces)
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_CRAFT", "Crafting Stations")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_DYE_STATION", "Dye Station")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_RETRAIT", "Transmutation Station")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ARMORY", "Armory Station")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ATTRIBUTE_RESPEC", "Attribute Respec Shrine")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_LOCKPICK", "Lockpicking")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_SIEGE", "Siege Weapons")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_FURNITURE", "Housing / Interactables")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_BANK", "Bank")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_GUILD_BANK", "Guild Bank")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_HOUSE_BANK", "House Bank")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_STORE", "Merchant / Store")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_TRADING_HOUSE", "Guild Store / Trading House")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_FENCE", "Fence / Launder")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_HOUSE_STORE", "House Vendors / House Store")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_AVA_HOOK_POINT", "AVA Structures / Siege Hooks")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_WAYSHRINE", "Wayshrines")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_KEEP_GUILD_CLAIM", "Claim Keep for Guild")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_KEEP_GUILD_RELEASE", "Release Keep from Guild")

ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_STABLE", "Mount Stable")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_MAIL", "Mailbox")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ANTIQUITY_DIG_SPOT", "Antiquity Dig Site")
ZO_CreateStringId("SI_FOXUC_IMMERSION_INTERACTION_ANTIQUITY_SCRYING", "Antiquity Scrying")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_RESPECT_MANUAL", "Respect Manual Switching")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_RESPECT_MANUAL_TT", "After you manually switch the camera view, auto-mode will temporarily pause to avoid overriding your choice.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENTER_DELAY", "Enter Delay (sec)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_ENTER_DELAY_TT", "How long a condition must remain active before the camera switches to first-person. Helps prevent flickering when briefly entering combat or mounting.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_EXIT_DELAY", "Exit Delay (sec)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_EXIT_DELAY_TT", "How long conditions must remain inactive before the camera returns to third-person view.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MANUAL_TIMEOUT", "Manual Mode Timeout (sec)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_MANUAL_TIMEOUT_TT", "After a manual view switch, auto-mode will be disabled for the specified time. Set to 0 to disable this delay.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_CHAIN_TIMEOUT", "Combat Chain Window (sec)")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_COMBAT_CHAIN_TIMEOUT_TT", "After combat ends, the addon will still consider you 'in combat' for this duration. This prevents the view from switching back and forth if you enter combat again within this window.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ENABLED", "Auto Sheathe Weapon")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ENABLED_TT", "Automatically sheathes your weapon after a short delay following the end of combat.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_IGNORE_PVP", "Ignore PvP Zones")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_IGNORE_PVP_TT", "If enabled, your weapon will not be auto-sheathed in PvP zones (Cyrodiil, Battlegrounds).\n\n|cFFA500Enabled by default|r to prevent accidentally sheathing your weapon in PvP.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ON_EMOTE", "Sheathe on Emote")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_ON_EMOTE_TT", "Automatically sheathes your weapon when you use an emote.\n\n|cFFA500Enabled by default|r.")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_DELAY", "Sheathing Delay (sec)")
ZO_CreateStringId("SI_FOXUC_WEAPON_SHEATHING_DELAY_TT", "How long to wait after combat ends before automatically sheathing the weapon.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_SUBMENU", "Guide: First-Person Auto Mode")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_SUBMENU_TT", "A detailed explanation of all auto-mode settings.")
ZO_CreateStringId("SI_FOXUC_FIRST_PERSON_AUTO_GUIDE_TEXT", "|cFFFFCCWhat it is:|r First-person auto mode automatically switches the camera between first and third-person view based on context (interiors, combat, mount).\n\n|cFFFFCCConditions:|r You can enable any combination of conditions. If multiple are active at the same time, the following priority is used: |cFFFFCCMount|r > |cFFFFCCCombat|r > |cFFFFCCInteriors|r.\n\n|cFFFFCCDelays:|r Enter and exit delays help prevent flickering when you only enter combat or mount for a moment. The condition must remain active/inactive for the entire duration of the delay before the view changes.\n\n|cFFFFCCManual Control:|r When you manually switch the view, auto-mode can temporarily pause its work so as not to cancel your choice.")
