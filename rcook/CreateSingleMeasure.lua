local SCRIPT_TITLE = "CreateSingleMeasure"


local function print(param)
  reaper.ShowConsoleMsg("[" .. tostring(reaper.time_precise()) .. "] " .. tostring(param) .. "\n")
end

local function show_user_error(param)
  local s = tostring(param)
  reaper.ShowMessageBox(s, SCRIPT_TITLE, 0)
end

local function abort(param)
  local s = tostring(param)
  reaper.ShowMessageBox("Error: " .. s, SCRIPT_TITLE, 0)
  reaper.ReaScriptError("!" .. s)
end

local function format_time(pos)
  return reaper.format_timestr_pos(pos, "", -1)
end

local function get_user_inputs(title, inputs)
  local captions_csv = ""
  local values_csv = ""
  local results_regex = ""
  for i, p in ipairs(inputs) do
    if i > 1 then
      captions_csv = captions_csv .. ","
      values_csv = values_csv .. ","
      results_regex = results_regex .. ","
    end
    captions_csv = captions_csv .. p[1]
    values_csv = values_csv .. p[2]
    results_regex = results_regex .. "([^,]+)"
  end
  local status, results_csv = reaper.GetUserInputs(title, #inputs, captions_csv, values_csv)
  if status then
    return true, results_csv:match(results_regex)
  else
    return false, nil
  end
end

local function create_single_measure(
  project_id,
  leading_measure_qns,
  leading_measure_basis,
  new_measure_qns,
  new_measure_basis,
  trailing_measure_qns,
  trailing_measure_basis,
  dry_run)

  local new_measure_start_time, new_measure_end_time = reaper.GetSet_LoopTimeRange2(project_id, false, false, 0, 0, false)
  local new_measure_length = new_measure_end_time - new_measure_start_time
  if new_measure_length == 0 then
    abort("Invalid time range selection")
  end

  local new_measure_start_qn = reaper.TimeMap2_timeToQN(project_id, new_measure_start_time)
  local new_measure_end_qn = reaper.TimeMap2_timeToQN(project_id, new_measure_end_time)

  -- Measure immediately before selection
  -- Measure starts at leading_measure_start_time and ends at new_measure_start_time
  local measure_number = reaper.TimeMap_QNToMeasures(project_id, new_measure_start_qn)
  local leading_measure_start_time, _, _, original_time_sig_num, original_time_sig_denom, original_tempo = reaper.TimeMap_GetMeasureInfo(project_id, measure_number - 1)
  local leading_measure_length = new_measure_start_time - leading_measure_start_time
  if leading_measure_length == 0 then
    abort("Invalid time range selection")
  end

  -- Measure immediately after selection
  -- Measure starts at new_measure_end_time and ends at trailing_measure_end_time
  local measure_number = reaper.TimeMap_QNToMeasures(project_id, new_measure_end_qn)
  local trailing_measure_end_time, _, _, _, _, _= reaper.TimeMap_GetMeasureInfo(project_id, measure_number)
  local trailing_measure_length = trailing_measure_end_time - new_measure_end_time
  if trailing_measure_length == 0 then
    abort("Invalid time range selection")
  end

  local leading_measure_tempo = 240 / leading_measure_length / (leading_measure_basis / leading_measure_qns)
  if not dry_run then
    if not reaper.SetTempoTimeSigMarker(project_id, -1, leading_measure_start_time, -1, -1, leading_measure_tempo, leading_measure_qns, leading_measure_basis, 0) then
      abort("SetTempoTimeSigMarker failed")
    end
  end

  local new_measure_tempo = 240 / new_measure_length / (new_measure_basis / new_measure_qns)
  if not dry_run then
    if not reaper.SetTempoTimeSigMarker(project_id, -1, new_measure_start_time, -1, -1, new_measure_tempo, new_measure_qns, new_measure_basis, 0) then
      abort("SetTempoTimeSigMarker failed")
    end
  end

  local trailing_measure_tempo = 240 / trailing_measure_length / (trailing_measure_basis / trailing_measure_qns)
  if not dry_run then
    if not reaper.SetTempoTimeSigMarker(project_id, -1, new_measure_end_time, -1, -1, trailing_measure_tempo, trailing_measure_qns, trailing_measure_basis, 0) then
      abort("SetTempoTimeSigMarker failed")
    end
  end

  if not dry_run then
    if not reaper.SetTempoTimeSigMarker(project_id, -1, trailing_measure_end_time, -1, -1, original_tempo, original_time_sig_num, original_time_sig_denom, 0) then
      abort("SetTempoTimeSigMarker failed")
    end
  end
end

local function main()
  local PROJECT_ID = 0
  local LEADING_MEASURE_BASIS = 4
  local NEW_MEASURE_BASIS = 4
  local TRAILING_MEASURE_BASIS = 4
  local DRY_RUN = false

  if reaper.SNM_GetIntConfigVarEx(PROJECT_ID, "itemtimelock", -100) ~= 0 then
    show_user_error("Timebase for items/envelopes/markers must be set to \"Time\"")
    return false
  end

  if reaper.SNM_GetIntConfigVarEx(PROJECT_ID, "tempoenvtimelock", -100) ~=0 then
    show_user_error("Timebase for tempo/time signature envelope must be set to \"Time\"")
    return false
  end

  local new_measure_start_time, new_measure_end_time = reaper.GetSet_LoopTimeRange2(PROJECT_ID, false, false, 0, 0, false)
  local new_measure_length = new_measure_end_time - new_measure_start_time
  if new_measure_length == 0 then
    show_user_error("Selected time range is empty")
    return false
  end

  local marker_count = reaper.CountTempoTimeSigMarkers(PROJECT_ID)
  for i = 0, marker_count - 1 do
    local status, marker_time = reaper.GetTempoTimeSigMarker(PROJECT_ID, i)
    if not status then
      abort("GetTempoTimeSigMarker failed")
    end

    if marker_time >= new_measure_start_time and marker_time <= new_measure_end_time then
      show_user_error("Selected time range already contains one or more tempo/time signature markers")
      return false
    end
  end

  local status, leading_measure_qns_str, new_measure_qns_str, trailing_measure_qns_str = get_user_inputs(SCRIPT_TITLE, {{"Beats in leading measure", 4}, {"Beats in new measure", 4}, {"Beats in trailing measure", 4}})
  if not status then
    -- Operation cancelled
    return false
  end

  local leading_measure_qns = tonumber(leading_measure_qns_str)
  local new_measure_qns = tonumber(new_measure_qns_str)
  local trailing_measure_qns = tonumber(trailing_measure_qns_str)

  create_single_measure(
    PROJECT_ID,
    leading_measure_qns,
    LEADING_MEASURE_BASIS,
    new_measure_qns,
    NEW_MEASURE_BASIS,
    trailing_measure_qns,
    TRAILING_MEASURE_BASIS,
    DRY_RUN)

  reaper.UpdateTimeline()
  return true
end

main()
