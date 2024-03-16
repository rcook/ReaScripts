--[[
   * ReaScript Name: Delete All Tempo and Time Signature Markers
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "utils.lua")
init_lib("Delete All Tempo and Time Signature Markers")

local function main()
  local PROJECT_ID = 0
  delete_all_tempo_time_sig_markers(PROJECT_ID)  
  reaper.UpdateTimeline()
  message("All tempo and time signature markers successfully deleted")
end

run(main)
