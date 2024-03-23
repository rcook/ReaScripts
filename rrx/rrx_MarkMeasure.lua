-- @noindex
-- @description Mark Measure
-- @author Richard Cook
-- @version 0.0
-- @about
--  Marks current time selection as a measure with user-supplied time
--  signature

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx-lib.lua")

local TIME_SIG_NUM_LABEL = "Time signature numerator"
local TIME_SIG_DENOM_LABEL = "Time signature denominator"

local function main(ctx)
  local status,
    time_sig_num_str,
    time_sig_denom_str = get_user_inputs({
    {TIME_SIG_NUM_LABEL, 4},
    {TIME_SIG_DENOM_LABEL, 4}
  })
  if not status then
    return
  end

  local time_sig_num = parse_user_integer(
    time_sig_num_str,
    TIME_SIG_NUM_LABEL,
    is_time_sig_num)

  local time_sig_denom = parse_user_integer(
    time_sig_denom_str,
    TIME_SIG_DENOM_LABEL,
    is_time_sig_denom)

  mark_measure_action(ctx, time_sig_num, time_sig_denom)
end

run("Mark Measure", main)
