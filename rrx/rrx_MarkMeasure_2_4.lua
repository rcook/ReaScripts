-- @noindex
-- @key 21 50
-- @description Mark Measure 2/4
-- @author Richard Cook
-- @version 0.0
-- @about
--  Marks current time selection as one measure in 2/4 time

dofile(debug.getinfo(1).source:match("@?(.*[/\\])") .. "rrx.lua")
run("Mark Measure", mark_measure_action)
