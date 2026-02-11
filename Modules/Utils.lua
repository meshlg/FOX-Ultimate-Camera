-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 meshlg

-- Shared utility functions used by multiple FOXUltimateCamera modules.
-- Loaded before all other modules via the addon manifest.

FOXUC_Utils = {}

--- Clamp a numeric value between min and max.
--- @param value number|any  The value to clamp.
--- @param minValue number   Lower bound.
--- @param maxValue number   Upper bound.
--- @return number|nil       Clamped value, or nil if input is not a number.
function FOXUC_Utils.Clamp(value, minValue, maxValue)
    if type(value) ~= "number" then
        return nil
    end

    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

--- Return current frame time in milliseconds.
--- Falls back through available ESO API functions.
--- @return number
function FOXUC_Utils.GetTimeMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

--- Check if the player is currently in a PvP area (Cyrodiil or battleground).
--- @return boolean
function FOXUC_Utils.IsInPvpArea()
    if IsPlayerInAvAWorld and IsPlayerInAvAWorld() then
        return true
    end
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then
        return true
    end
    return false
end

--- Check if the player is in a relevant interior (house or dungeon).
--- @return boolean
function FOXUC_Utils.IsInRelevantInterior()
    if IsInHouse and IsInHouse() then
        return true
    end
    if IsUnitInDungeon and IsUnitInDungeon("player") then
        return true
    end
    return false
end

--- Check if the player is currently in combat (safe wrapper).
--- @return boolean
function FOXUC_Utils.IsPlayerInCombat()
    if type(IsUnitInCombat) ~= "function" then
        return false
    end
    return IsUnitInCombat("player") and true or false
end

--- Check if the player is currently mounted (safe wrapper).
--- @return boolean
function FOXUC_Utils.IsPlayerMounted()
    if type(IsMounted) ~= "function" then
        return false
    end
    return IsMounted() and true or false
end
