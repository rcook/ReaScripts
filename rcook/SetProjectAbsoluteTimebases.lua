--[[
   * ReaScript Name: Set Project Absolute Timebases
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")

local function main(ctx)
  if not reaper.SNM_SetIntConfigVarEx(ctx.project_id, "itemtimelock", 0) then
    abort("SNM_SetIntConfigVarEx failed")
  end
  if not reaper.SNM_SetIntConfigVarEx(ctx.project_id, "tempoenvtimelock", 0) then
    abort("SNM_SetIntConfigVarEx failed")
  end

  reaper.SelectAllMediaItems(ctx.project_id, true)
  run_action_command(ctx.project_id, "_BR_MIDI_PROJ_TEMPO_ENB_TIME")

  reaper.UpdateTimeline()

  message("Project timebases successfully set to absolute")
end

run("Set Project Absolute Timebases", main)
