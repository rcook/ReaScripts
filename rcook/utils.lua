--[[
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

function delete_all_tempo_time_sig_markers(project_id)
  for i = reaper.CountTempoTimeSigMarkers(project_id) - 1, 0, -1 do
    local status, _, _, _, _, _, _, _ = reaper.GetTempoTimeSigMarker(project_id, i)
    if not status then
      abort("GetTempoTimeSigMarker failed")
    end
    if not reaper.DeleteTempoTimeSigMarker(project_id, i) then
      abort("DeleteTempoTimeSigMarker failed")
    end
  end
end

function get_tempo_time_sig_marker(project_id, time)
  for i = 0, reaper.CountTempoTimeSigMarkers(project_id) - 1 do
    status, marker_time, _, _, _, _, _, _ = reaper.GetTempoTimeSigMarker(project_id, i)
    if not status then
      abort("GetTempoTimeSigMarker failed")
    end

    if marker_time == time then
      return { marker_id = i, is_fuzzy = false }
    end

    if format_time(marker_time) == format_time(time) then
      return { marker_id = i, is_fuzzy = true }
    end

  end
  return nil
end

function create_single_measure_tempo_time_sig_marker(project_id, start_time, end_time, time_sig_num, time_sig_denom)
  assert(end_time > start_time)
  assert(time_sig_num > 0)
  assert(time_sig_denom > 0)

  local len = end_time - start_time
  local start_qn = reaper.TimeMap2_timeToQN(project_id, start_time)
  local end_qn  = reaper.TimeMap2_timeToQN(project_id, end_time)
  local tempo = 240.0 / len / (time_sig_denom / time_sig_num)

  local result = get_tempo_time_sig_marker(project_id, start_time)
  if result ~= nil then
    if result.is_fuzzy then
      if not confirm("There is a tempo/time signature marker nearby: continue?") then
        exit()
      end
    end

    if not reaper.DeleteTempoTimeSigMarker(project_id, result.marker_id) then
      abort("DeleteTempoTimeSigMarker failed")
    end
  end

  if not reaper.SetTempoTimeSigMarker(project_id, -1, start_time, -1, -1, tempo, time_sig_num, time_sig_denom, 0) then
    abort("SetTempoTimeSigMarker failed")
  end
end

function run_create_single_measure_action()
  local PROJECT_ID = 0
  local s = (({reaper.get_action_context()})[2])
  local time_sig_num_str, time_sig_denom_str = s:match('CreateSingleMeasure_(%d+)_(%d+)')
  local time_sig_num = tonumber(time_sig_num_str)
  local time_sig_denom = tonumber(time_sig_denom_str)
  run_create_single_measure_action2(time_sig_num, time_sig_denom)
end

function run_create_single_measure_action2(time_sig_num, time_sig_denom)
  local start_time, end_time = reaper.GetSet_LoopTimeRange2(PROJECT_ID, false, false, 0, 0, false)
  local len = end_time - start_time
  if len == 0 then
    exit("Selected time range is empty")
  end

  create_single_measure_tempo_time_sig_marker(
    PROJECT_ID,
    start_time,
    end_time,
    time_sig_num,
    time_sig_denom)

  reaper.UpdateTimeline()
end
