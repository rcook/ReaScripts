--[[
   * ReaScript Name: Foo
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
init_lib("Foo")

local function delete_all_tempo_time_sig_markers(project_id)
  for i = reaper.CountTempoTimeSigMarkers(project_id) - 1, 0, -1 do
    status, _, _, _, _, _, _, _ = reaper.GetTempoTimeSigMarker(project_id, i)
    if not status then
      abort("GetTempoTimeSigMarker failed")
    end
    if not reaper.DeleteTempoTimeSigMarker(project_id, i) then
      abort("DeleteTempoTimeSigMarker failed")
    end
  end
end

local function create_measure(project_id, start_time, end_time, time_sig_num, time_sig_denom)
  assert(end_time > start_time)
  assert(time_sig_num > 0)
  assert(time_sig_denom > 0)

  local len = end_time - start_time
  local start_qn = reaper.TimeMap2_timeToQN(project_id, start_time)
  local end_qn  = reaper.TimeMap2_timeToQN(project_id, end_time)

  local tempo = 240 / len / (time_sig_denom / time_sig_num)

  if not reaper.SetTempoTimeSigMarker(project_id, -1, start_time, -1, -1, tempo, time_sig_num, time_sig_denom, 0) then
    abort("SetTempoTimeSigMarker failed")
  end

  trace(tempo)
end

local function foo(project_id, time_sig_num, time_sig_denom)
  local start_time, end_time = reaper.GetSet_LoopTimeRange2(project_id, false, false, 0, 0, false)
  local len = end_time - start_time
  if len == 0 then
    exit("Selected time range is empty")
  end

  create_measure(project_id, start_time, end_time, time_sig_num, time_sig_denom)
end

local function main()
  local PROJECT_ID = 0
  local TIME_SIG_NUM = 4
  local TIME_SIG_DENOM = 4

  delete_all_tempo_time_sig_markers(PROJECT_ID)  
  --foo(PROJECT_ID, TIME_SIG_NUM, TIME_SIG_DENOM)
  reaper.UpdateTimeline()
end

run(main)

