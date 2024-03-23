-- @noindex
-- @description Mark measure
-- @author Richard Cook
-- @version 0.0
-- @about
--  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam enim ante, condimentum in
--  maximus sed, pellentesque non est. Suspendisse sagittis justo eu tortor dignissim, non laoreet
--  lacus dictum. Aenean sodales ligula ante, id dapibus diam dapibus ac. Donec at dui consequat,
--  congue neque et, viverra ex. Integer eu massa quis sapien laoreet consequat ultrices quis
--  tortor. Fusce vel semper felis, at maximus mi. Nunc tellus elit, congue sed rhoncus vitae,
--  vestibulum vel sapien. Proin sapien est, commodo at commodo in, volutpat vitae leo. Maecenas
--  facilisis, quam sagittis pretium fringilla, mauris ex interdum dolor, sit amet ultrices dolor
--  odio vel tortor. Curabitur vestibulum lectus tincidunt felis fermentum malesuada. Aenean
--  commodo magna ac est fringilla, tempus ullamcorper eros mollis. Etiam sit amet mi arcu. Fusce
--  nec convallis metus. Nulla at tempus nisi, non varius mauris.

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rcook_Tempo_Mapping.lua")

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
