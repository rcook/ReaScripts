--[[
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

local EXIT_MARKER = "[EXIT]"
local SCRIPT_TITLE = nil

function init_lib(script_title)
  if not reaper.APIExists("SNM_GetIntConfigVarEx") then
    exit("Please install a recent version of SWS/S&M (https://www.sws-extension.org)")
  end

  SCRIPT_TITLE = script_title
end

function message(obj)
  reaper.ShowMessageBox(tostring(obj), SCRIPT_TITLE, 0)
end

function trace(obj)
  reaper.ShowConsoleMsg("[" .. tostring(reaper.time_precise()) .. "] " .. tostring(obj) .. "\n")
end

function exit(obj)
  local s = tostring(obj)
  message(s)
  error(s .. EXIT_MARKER)
end

function abort(obj)
  error(tostring(obj))
end

function run(main)
  function on_terminated(e)
    local s = tostring(e)
    if s:sub(-#EXIT_MARKER) == EXIT_MARKER then
      return
    else
      return e
    end
  end

  local status, result = xpcall(main, on_terminated)
  if not status and result ~= nil then
    reaper.ReaScriptError("!" .. tostring(result))
  else
    return result
  end
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
