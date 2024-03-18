-- @description Delete All Tempo and Time Signature Markers
-- @author Richard Cook
-- @version 0.0
-- @about
-- Deletes all tempo and time signature markers

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")

local function main(ctx)
  delete_all_tempo_time_sig_markers(ctx.project_id)
  reaper.UpdateTimeline()
  message("All tempo and time signature markers successfully deleted")
end

run("Delete All Tempo and Time Signature Markers", main)
