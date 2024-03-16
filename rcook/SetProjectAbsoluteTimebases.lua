--[[
   * ReaScript Name: Set Project Absolute Timebases
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

-- Standard preamble
SCRIPT_TITLE = "Set Project Absolute Timebases"
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
lib_init()

local function set_project_absolute_timebases(project_id)
  if not reaper.SNM_SetIntConfigVarEx(project_id, "itemtimelock", 0) then
    abort("SNM_SetIntConfigVarEx failed")
  end
  if not reaper.SNM_SetIntConfigVarEx(project_id, "tempoenvtimelock", 0) then
    abort("SNM_SetIntConfigVarEx failed")
  end

  reaper.SelectAllMediaItems(project_id, true)
  run_action_command(project_id, "_BR_MIDI_PROJ_TEMPO_ENB_TIME")
end

local function main()
  local PROJECT_ID = 0
  set_project_absolute_timebases(PROJECT_ID)
  message("Project timebases successfully set to absolute")
end

main()
