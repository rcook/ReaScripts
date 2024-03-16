--[[
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

local EXIT_MARKER = "[EXIT]"
local SCRIPT_TITLE = nil

function run(title, main)
  local function on_terminated(e)
    local s = tostring(e)
    if s:sub(-#EXIT_MARKER) == EXIT_MARKER then
      return
    else
      return e
    end
  end

  SCRIPT_TITLE = title

  if not reaper.APIExists("SNM_GetIntConfigVarEx") then
    exit("Please install a recent version of SWS/S&M (https://www.sws-extension.org)")
  end

  local ctx = {
    project_id = 0,
    script_path = (({reaper.get_action_context()})[2])
  }

  local status, result = xpcall(main, on_terminated, ctx)
  if not status and result ~= nil then
    local s = tostring(result)
    trace("[ERROR] " .. s)
    reaper.ReaScriptError("!" .. s)
  else
    return result
  end
end

function message(obj)
  reaper.ShowMessageBox(tostring(obj), SCRIPT_TITLE, 0)
end

function trace(obj)
  reaper.ShowConsoleMsg("[" .. tostring(reaper.time_precise()) .. "] " .. tostring(obj) .. "\n")
end

function exit(obj)
  if obj == nil then
    error(EXIT_MARKER)
  else
    local s = tostring(obj)
    message(s)
    error(s .. EXIT_MARKER)
  end
end

function abort(obj)
  error(tostring(obj))
end

function ensure_absolute_project_timebases(project_id)
  if reaper.SNM_GetIntConfigVarEx(project_id, "itemtimelock", -100) ~= 0 then
    exit("Timebase for items/envelopes/markers must be set to \"Time\"")
  end

  if reaper.SNM_GetIntConfigVarEx(project_id, "tempoenvtimelock", -100) ~=0 then
    exit("Timebase for tempo/time signature envelope must be set to \"Time\"")
  end
end

function format_time(pos)
  return reaper.format_timestr_pos(pos, "", -1)
end

function get_user_inputs(inputs)
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

  local status, results_csv = reaper.GetUserInputs(SCRIPT_TITLE, #inputs, captions_csv, values_csv)
  if status then
    return true, results_csv:match(results_regex)
  else
    return false, nil
  end
end

function run_action_command(project_id, command_name)
  local command_id = reaper.NamedCommandLookup(command_name, 0, project_id)
  if command_id == 0 then
    abort("NamedCommandLookup failed for command " .. command_name)
  end

  reaper.Main_OnCommandEx(command_id, 0, project_id)
end

function parse_user_integer(s, label, validator)
  local label = label == nil and "Value" or label

  local value = math.tointeger(s)
  if value == nil then
    exit(label .. " \"" .. s .. "\" must be an integer")
  end

  if validator == nil then
    return value
  end

  if validator(value) then
    return value
  end

  exit(label .. " \"" .. s .. "\" is not valid")
end

function confirm(s)
  return reaper.ShowMessageBox(s, SCRIPT_TITLE, 1) == 1
end

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

function run_create_single_measure_action(ctx, time_sig_num, time_sig_denom)
  local time_sig_num_str, time_sig_denom_str = ctx.script_path:match("CreateSingleMeasure_(%d+)_(%d+)")

  if time_sig_num == nil then
    time_sig_num = math.tointeger(time_sig_num_str)
  end
  if time_sig_denom == nil then
    time_sig_denom = math.tointeger(time_sig_denom_str)
  end

  local start_time, end_time = reaper.GetSet_LoopTimeRange2(ctx.project_id, false, false, 0, 0, false)
  local len = end_time - start_time
  if len == 0 then
    exit("Selected time range is empty")
  end

  create_single_measure_tempo_time_sig_marker(
    ctx.project_id,
    start_time,
    end_time,
    time_sig_num,
    time_sig_denom)

  reaper.UpdateTimeline()
end
