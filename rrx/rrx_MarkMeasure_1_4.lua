-- @noindex
-- @description Mark Measure 1/4
-- @author Richard Cook
-- @version 0.0
-- @about
--  Marks current time selection as one measure in 1/4 time

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")
run("Mark Measure", mark_measure_action)
