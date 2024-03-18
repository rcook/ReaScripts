-- @description Mark Measure 6/8
-- @author Richard Cook
-- @version 0.0
-- @about
-- Marks current time selection as one measure in 6/8 time

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")
run("Mark Measure", mark_measure_action)
