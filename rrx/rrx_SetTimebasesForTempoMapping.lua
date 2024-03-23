-- @noindex
-- @description Set Timebases for Tempo Mapping
-- @author Richard Cook
-- @version 0.0
-- @about
--  Sets timebases for tempo mapping

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")

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

  message("Timebases successfully set for tempo mapping")
end

run("Set Timebases for Tempo Mapping", main)
