--[[
   * ReaScript Name: Create Single Measure
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-lua.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "lib.lua")
dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "utils.lua")
init_lib("Create Single Measure")
run(run_create_single_measure_action)
