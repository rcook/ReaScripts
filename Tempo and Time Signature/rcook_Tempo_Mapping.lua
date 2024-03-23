-- @noindex
-- @description Tempo mapping
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

local EXIT_MARKER = "[EXIT]"
local SCRIPT_TITLE = nil
local VALID_TIME_SIG_DENOMS = {
  [1] = true,
  [2] = true,
  [4] = true,
  [8] = true,
  [16] = true,
  [32] = true,
  [64] = true
}

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

  if not reaper.APIExists("JS_Dialog_BrowseForSaveFile") then
    exit("Please install a recent version of js_ReaScriptAPI (https://github.com/ReaTeam/Extensions/raw/master/index.xml)")
  end

  local ctx = {
    project_id = 0,
    script_path = (({reaper.get_action_context()})[2]),
    script_title = SCRIPT_TITLE
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

function to_integer(obj)
  local value = math.tointeger(obj)
  assert(is_integer(value))
  return value
end

function is_number(obj)
  return type(obj) == "number"
end

function is_integer(obj)
  return is_number(obj) and math.tointeger(obj) == obj
end

function dump(obj)
  local t = type(obj)
  if t == "userdata" then
    return "[userdata]"
  elseif t == "table" then
    local s = "{ "
    local i = 0
    for k, v in pairs(obj) do
      if i > 0 then s = s .. ", " end
      s = s .. "[" .. dump(k) .. "] = " .. dump(v)
      i = i + 1
    end
    return s .. "} "
  elseif t == "string" then
    return "\"" .. obj .. "\""
  else
    return tostring(obj)
  end
end

function check_timebases_for_tempo_mapping(project_id)
  assert(is_integer(project_id))

  local function is_midi_media_item(media_item)
    for i = 0, reaper.CountTakes(media_item) - 1 do
      local take = reaper.GetMediaItemTake(media_item, i)
      if reaper.TakeIsMIDI(take) then
        return true
      end
    end
    return false
  end

  local function all_midi_media_items_ignore_project_tempo(project_id)
    for i = 0, reaper.CountMediaItems(project_id) - 1 do
      local media_item = reaper.GetMediaItem(project_id, i)
      if is_midi_media_item(media_item) then
        local status, chunk = reaper.GetItemStateChunk(media_item, "", true)
        assert(status)
        if chunk:match("IGNTEMPO 1") == nil then
          return false
        end
      end
    end
    return true
  end

  local INSTRUCTIONS = "Please run \"rcook_Set_Project_Timebases.lua\" to configure your project and media items properly."

  if reaper.SNM_GetIntConfigVarEx(project_id, "itemtimelock", -100) ~= 0 then
    exit("Timebase for items/envelopes/markers must be set to \"Time\". " .. INSTRUCTIONS)
  end

  if reaper.SNM_GetIntConfigVarEx(project_id, "tempoenvtimelock", -100) ~=0 then
    exit("Timebase for tempo/time signature envelope must be set to \"Time\". " .. INSTRUCTIONS)
  end

  if not all_midi_media_items_ignore_project_tempo(project_id) then
    exit("One or more MIDI media items does not ignore project tempo. " .. INSTRUCTIONS)
  end
end

function format_time(pos)
  return reaper.format_timestr_pos(pos, "", -1)
end

function is_time_sig_num(value)
  return is_integer(value) and value >= 1
end

function is_time_sig_denom(value)
  return is_integer(value) and VALID_TIME_SIG_DENOMS[value] ~= nil
end

function to_time_sig_num(obj)
  local value = to_integer(obj)
  assert(is_time_sig_num(value))
  return value
end

function to_time_sig_denom(obj)
  local value = to_integer(obj)
  assert(is_time_sig_denom(value))
  return value
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
  assert(is_integer(project_id))

  for i = reaper.CountTempoTimeSigMarkers(project_id) - 1, 0, -1 do
    local status, _, _, _, _, _, _, _ = reaper.GetTempoTimeSigMarker(project_id, i)
    assert(status)
    assert(reaper.DeleteTempoTimeSigMarker(project_id, i))
  end
end

function get_tempo_time_sig_marker(project_id, time)
  assert(is_integer(project_id))
  assert(is_number(time))

  for i = 0, reaper.CountTempoTimeSigMarkers(project_id) - 1 do
    local status, marker_time, _, _, _, _, _, _ = reaper.GetTempoTimeSigMarker(project_id, i)
    assert(status)

    if marker_time == time then
      return { marker_id = i, is_fuzzy = false }
    end

    if format_time(marker_time) == format_time(time) then
      return { marker_id = i, is_fuzzy = true }
    end

  end
  return nil
end

function create_measure_tempo_time_sig_marker(project_id, start_time, end_time, time_sig_num, time_sig_denom)
  assert(is_integer(project_id))
  assert(is_number(start_time))
  assert(is_number(end_time))
  assert(is_time_sig_num(time_sig_num))
  assert(is_time_sig_denom(time_sig_denom))
  assert(end_time > start_time)

  check_timebases_for_tempo_mapping(project_id)

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

    assert(reaper.DeleteTempoTimeSigMarker(project_id, result.marker_id))
  end

  assert(reaper.SetTempoTimeSigMarker(project_id, -1, start_time, -1, -1, tempo, time_sig_num, time_sig_denom, 0))
end

function mark_measure_action(ctx, time_sig_num, time_sig_denom)
  assert(time_sig_num == nil or is_time_sig_num(time_sig_num))
  assert(time_sig_denom == nil or is_time_sig_denom(time_sig_denom))

  local time_sig_num_str, time_sig_denom_str = ctx.script_path:match("_(%d+)_(%d+)")

  if time_sig_num == nil then
    time_sig_num = to_time_sig_num(time_sig_num_str)
  end
  if time_sig_denom == nil then
    time_sig_denom = to_time_sig_denom(time_sig_denom_str)
  end

  local start_time, end_time = reaper.GetSet_LoopTimeRange2(ctx.project_id, false, false, 0, 0, false)
  local len = end_time - start_time
  if len == 0 then
    exit("Selected time range is empty")
  end

  create_measure_tempo_time_sig_marker(
    ctx.project_id,
    start_time,
    end_time,
    time_sig_num,
    time_sig_denom)

  reaper.UpdateTimeline()
end
