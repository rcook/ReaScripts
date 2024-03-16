--[[
   * ReaScript Name: Set Project Absolute Timebases
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "utils.lua")
init_lib("Set Project Absolute Timebases")

local function main()
  local PROJECT_ID = 0

  if not reaper.SNM_SetIntConfigVarEx(PROJECT_ID, "itemtimelock", 0) then
    abort("SNM_SetIntConfigVarEx failed")
  end
  if not reaper.SNM_SetIntConfigVarEx(PROJECT_ID, "tempoenvtimelock", 0) then
    abort("SNM_SetIntConfigVarEx failed")
  end

  reaper.SelectAllMediaItems(PROJECT_ID, true)
  run_action_command(PROJECT_ID, "_BR_MIDI_PROJ_TEMPO_ENB_TIME")

  message("Project timebases successfully set to absolute")
  reaper.UpdateTimeline()
end

run(main)
