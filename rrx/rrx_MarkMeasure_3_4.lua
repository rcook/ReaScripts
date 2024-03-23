-- @noindex
-- @description Mark Measure 3/4
-- @author Richard Cook
-- @version 0.0
-- @about
--  Marks current time selection as one measure in 3/4 time

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx-lib.lua")
run("Mark Measure", mark_measure_action)
