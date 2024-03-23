--[[
   * ReaScript Name: Mark Measure
   * Author: Richard Cook
   * Author URI: https://github.com/rcook/reaper-extensions.git
   * Licence: MIT
   * Version: 0.0
--]]

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")
run("Mark Measure", mark_measure_action)
