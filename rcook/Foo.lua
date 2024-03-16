--[[
   * ReaScript Name: Foo
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "utils.lua")
init_lib("Foo")

local function main()
  local PROJECT_ID = 0
  local TIME_SIG_NUM = 3
  local TIME_SIG_DENOM = 4

  local s = ({reaper.get_action_context()})[2]
  local s = "/path/to/CreateSingleMeasure_1_4.lua"

  local time_sig_num_str, time_sig_denom_str = s:match('CreateSingleMeasure_(%d+)_(%d+)')
  local time_sig_num = tonumber(time_sig_num_str)
  local time_sig_denom = tonumber(time_sig_denom_str)
  exit(tostring(time_sig_num) .. " | " .. tostring(time_sig_denom))
  delete_all_tempo_time_sig_markers(PROJECT_ID)  

  local start_time, end_time = reaper.GetSet_LoopTimeRange2(PROJECT_ID, false, false, 0, 0, false)
  local len = end_time - start_time
  if len == 0 then
    exit("Selected time range is empty")
  end

  create_single_measure_tempo_time_sig_marker(
    PROJECT_ID,
    start_time,
    end_time,
    TIME_SIG_NUM,
    TIME_SIG_DENOM)

  reaper.UpdateTimeline()
end

run(main)
