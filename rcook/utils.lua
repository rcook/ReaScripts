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

function create_single_measure_tempo_time_sig_marker(project_id, start_time, end_time, time_sig_num, time_sig_denom)
  assert(end_time > start_time)
  assert(time_sig_num > 0)
  assert(time_sig_denom > 0)

  local len = end_time - start_time
  local start_qn = reaper.TimeMap2_timeToQN(project_id, start_time)
  local end_qn  = reaper.TimeMap2_timeToQN(project_id, end_time)
  local tempo = 240.0 / len / (time_sig_denom / time_sig_num)

  if not reaper.SetTempoTimeSigMarker(project_id, -1, start_time, -1, -1, tempo, time_sig_num, time_sig_denom, 0) then
    abort("SetTempoTimeSigMarker failed")
  end
end