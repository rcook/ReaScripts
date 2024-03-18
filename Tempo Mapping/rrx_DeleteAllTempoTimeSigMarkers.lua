--[[
  * ReaScript Name: Delete All Tempo and Time Signature Markers
  * Author: Richard Cook
  * Author URI: https://github.com/rcook/rrx.git
  * Licence: MIT
  * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")

local function main(ctx)
  delete_all_tempo_time_sig_markers(ctx.project_id)
  reaper.UpdateTimeline()
  message("All tempo and time signature markers successfully deleted")
end

run("Delete All Tempo and Time Signature Markers", main)
