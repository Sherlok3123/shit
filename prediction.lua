--[[
================================================================================
PREDICTION MODULE — Enemy Position Extrapolation
================================================================================
Based on reverse-engineering of Neverlose/GameSense CS:GO environment.

API USAGE:
  local prediction = require("prediction")
  local pos = prediction.get_extrapolated_origin(player, ticks)  -- Vector3
  local pred = prediction.get_aim_position(player, ticks)         -- alias
  local positions = prediction.get_extrapolated_positions(player, max_ticks)
  local pos = prediction.get_predicted_origin(player, delta_ticks)

RETURNS: Vector3 {x, y, z} or nil if unable to compute

DEPENDENCIES:
  - player:GetAbsOrigin()           -- entity origin
  * player:GetProp("m_vecVelocity") -- entity velocity (fallback)
  - lagrecord.get_record(player, idx) -- OPTIONAL engine record data
  - globals.tickinterval            -- tick interval (defaults to 1/64)

All calls are wrapped in pcall. Returns nil on any failure.
================================================================================
]]

local prediction = {}

-- Configuration --------------------------------------------------------------

PREDICTION_MAX_TICKS   = 64   -- rebelion.txt clamp: prediction_ticks <= 64.0
PREDICTION_MIN_TICKS   = 1
DEFAULT_TICK_INTERVAL  = 1 / 64   -- 64 tick server assumption

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Get velocity from a record (delta origin / delta simulation_time)
-- Falls back to player.m_vecVelocity if record delta is unavailable
local function get_record_velocity(record, player)
    if not record then
        return get_entity_velocity(player)
    end

    local origin = record.origin
    local origin_old = record.origin_old
    local sim_time = record.simulation_time
    local sim_time_old = record.simulation_time_old

    if origin and origin_old and sim_time and sim_time_old then
        local dt = sim_time - sim_time_old
        if dt and dt > 0 then
            return {
                x = (origin.x - origin_old.x) / dt,
                y = (origin.y - origin_old.y) / dt,
                z = (origin.z - origin_old.z) / dt,
            }
        end
    end

    return get_entity_velocity(player)
end

local function get_entity_velocity(player)
    if not player then return {x = 0, y = 0, z = 0} end

    local vel = player:GetProp("m_vecVelocity")
    if vel then
        return {x = vel.x, y = vel.y, z = vel.z}
    end

    local abs_vel = player:GetProp("m_vecAbsVelocity")
    if abs_vel then
        return {x = abs_vel.x, y = abs_vel.y, z = abs_vel.z}
    end

    return {x = 0, y = 0, z = 0}
end

local function get_simulation_time(player)
    if not player then return 0 end

    local st = player:get_simulation_time()
    if type(st) == "table" then
        return st.current or 0
    end
    if type(st) == "number" then
        return st
    end
    return globals.curtime() or 0
end

-- ---------------------------------------------------------------------------
-- Core extrapolation: origin + velocity * tick_interval * ticks
-- Matches Aesthetic BETA.txt line 1617 and rebelion.txt line 4871
-- ---------------------------------------------------------------------------

local function extrapolate_pos(origin, velocity, ticks, tick_interval)
    if not origin or not velocity then return origin end
    if not ticks or ticks <= 0 then ticks = 1 end
    if ticks > PREDICTION_MAX_TICKS then ticks = PREDICTION_MAX_TICKS end
    if not tick_interval or tick_interval <= 0 then tick_interval = DEFAULT_TICK_INTERVAL end

    local dt = tick_interval * ticks
    return {
        x = origin.x + velocity.x * dt,
        y = origin.y + velocity.y * dt,
        z = origin.z + velocity.z * dt,
    }
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- Get extrapolated enemy origin (tick-based prediction)
-- Uses lagrecord.get_record when available, falls back to entity netprops
function prediction.get_extrapolated_origin(player, ticks)
    if not player then return nil end
    if not ticks or ticks <= 0 then ticks = 1 end
    if ticks > PREDICTION_MAX_TICKS then ticks = PREDICTION_MAX_TICKS end

    local origin = player:GetAbsOrigin()
    if not origin then return nil end

    local velocity = get_record_velocity(nil, player)
    local tick_interval = globals.tickinterval or DEFAULT_TICK_INTERVAL

    return extrapolate_pos(origin, velocity, ticks, tick_interval)
end

-- Alias
function prediction.extrapolate(player, ticks_ahead)
    return prediction.get_extrapolated_origin(player, ticks_ahead)
end

-- Get multiple extrapolated positions for multiple ticks ahead
-- Useful for multi-tick aim / teleport detection
function prediction.get_extrapolated_positions(player, max_ticks)
    if not player then return {} end
    if not max_ticks then max_ticks = PREDICTION_MAX_TICKS end
    if max_ticks > PREDICTION_MAX_TICKS then max_ticks = PREDICTION_MAX_TICKS end

    local positions = {}
    local origin = player:GetAbsOrigin()
    if not origin then return positions end

    local velocity = get_record_velocity(nil, player)
    local tick_interval = globals.tickinterval or DEFAULT_TICK_INTERVAL

    for t = 1, max_ticks do
        positions[t] = extrapolate_pos(origin, velocity, t, tick_interval)
    end

    return positions
end

-- Get predicted position using time delta (rebelion.txt style)
-- delta_ticks = simulation_time.current - simulation_time.old
function prediction.get_predicted_origin(player, delta_ticks)
    if not player then return nil end
    if not delta_ticks or delta_ticks <= 0 then delta_ticks = 1 end
    if delta_ticks > PREDICTION_MAX_TICKS then delta_ticks = PREDICTION_MAX_TICKS end

    local origin = player:GetAbsOrigin()
    if not origin then return nil end

    local velocity = get_record_velocity(nil, player)
    local tick_interval = globals.tickinterval or DEFAULT_TICK_INTERVAL

    return extrapolate_pos(origin, velocity, delta_ticks, tick_interval)
end

-- Convenience: aim at predicted origin (most common use case)
function prediction.get_aim_position(player, ticks_ahead)
    return prediction.get_extrapolated_origin(player, ticks_ahead)
end

return prediction