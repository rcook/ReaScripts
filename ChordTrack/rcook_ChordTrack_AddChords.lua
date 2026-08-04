-- @noindex
-- @description Add media items to a given chord track labelled with chord names
-- @author Richard Cook
-- @version 0.0
-- @about
--  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam enim ante, condimentum in
--  maximus sed, pellentesque non est. Suspendisse sagittis justo eu tortor dignissim, non laoreet
--  lacus dictum. Aenean sodales ligula ante, id dapibus diam dapibus ac. Donec at dui consequat,
--  congue neque et, viverra ex. Integer eu massa quis sapien laoreet consequat ultrices quis
--  tortor. Fusce vel semper felis, at maximus mi. Nunc tellus elit, congue sed rhoncus vitae,
--  vestibulum vel sapien. Proin sapien est, commodo at commodo in, volutpat vitae leo. Maecenas
--  facilisis, quam sagittis pretium fringilla, mauris ex interdum dolor, sit amet ultrices dolor
--  odio vel tortor. Curabitur vestibulum lectus tincidunt felis fermentum malesuada. Aenean
--  commodo magna ac est fringilla, tempus ullamcorper eros mollis. Etiam sit amet mi arcu. Fusce
--  nec convallis metus. Nulla at tempus nisi, non varius mauris.

package.path = package.path .. ";" .. debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]] .. "?.lua"
local Constants = require("lib/Constants")
local ReaperUtil = require("lib/ReaperUtil")
local Util = require("lib/Util")

local appendEmptyItems = ReaperUtil.appendEmptyItems
local getTrackByName = ReaperUtil.getTrackByName
local split = Util.split

local TITLE = "Add Chords to Chord Track"

local function getOptions()
  local is_ok, s = reaper.GetUserInputs(
    TITLE,
    2,
    "Chords,Chord track",
    string.format("C Am F G,%s", Constants.DEFAULT_CHORD_TRACK_NAME),
    0)
  if not is_ok then
    return
  end

  local values = split(s, ",")
  assert(#values == 2)
  return values[2], split(values[1])
end

local function doAddChords()
  local chord_track_name, chords = getOptions()
  if not chord_track_name then
    return
  end

  reaper.Undo_BeginBlock()

  local chord_track = getTrackByName(chord_track_name)
  if not chord_track then
    reaper.InsertTrackAtIndex(0, true)
    chord_track = reaper.GetTrack(0, 0)
    reaper.GetSetMediaTrackInfo_String(chord_track, "P_NAME", chord_track_name, 1)
    reaper.SetMediaTrackInfo_Value(chord_track, "B_TCPPIN", 1)
  end

  appendEmptyItems(chord_track, chords)

  reaper.Undo_EndBlock("Add chords to chord track", -1)

  reaper.UpdateArrange()
  reaper.UpdateTimeline()
end

doAddChords()
