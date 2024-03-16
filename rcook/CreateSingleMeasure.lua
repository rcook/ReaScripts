--[[
   * ReaScript Name: Create Single Measure
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "utils.lua")
init_lib("Create Single Measure")

local TIME_SIG_NUM_LABEL = "Time signature numerator"
local TIME_SIG_DENOM_LABEL = "Time signature denominator"
local VALID_TIME_SIG_DENOMS = {
  [1] = true,
  [2] = true,
  [4] = true,
  [8] = true,
  [16] = true,
  [32] = true,
  [64] = true
}

local function is_time_sig_num(value)
  return value >= 1
end

local function is_time_sig_denom(value)
  return VALID_TIME_SIG_DENOMS[value] ~= nil
end

local function main()
  local status,
    time_sig_num_str,
    time_sig_denom_str = get_user_inputs({
    {TIME_SIG_NUM_LABEL, 4},
    {TIME_SIG_DENOM_LABEL, 4}
  })
  if not status then
    return
  end

  local time_sig_num = parse_user_integer {
    time_sig_num_str,
    label = TIME_SIG_NUM_LABEL,
    validator = is_time_sig_num
  }

  local time_sig_denom = parse_user_integer {
    time_sig_denom_str,
    label = TIME_SIG_DENOM_LABEL,
    validator = is_time_sig_denom
  }

  run_create_single_measure_action2(time_sig_num, time_sig_denom)
end

run(main)

